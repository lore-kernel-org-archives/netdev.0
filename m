From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Subject: [RFC v4 2/2] iwlwifi: mvm: send large SKBs to the transport
Date: Thu, 22 Oct 2015 16:07:12 +0300
Message-ID: <1445519232-11111-2-git-send-email-emmanuel.grumbach@intel.com>
References: <1445519232-11111-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	sara.sharon@intel.com, ido@wizery.com,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56184 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757300AbbJVNHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 09:07:19 -0400
In-Reply-To: <1445519232-11111-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that PCIe knows how to create A-MSDUs, use this
capability and prepare SKBs that are large enough to
build an A-MSDU.
Advertise TSO support towards the network stack and
segment the packet with gso_size set to be the maximal
A-MSDU length (after having taken the headers to be added
into account) to make sure that the skb that is passed
down to the transport are not longer than the maximal
A-MSDU allowed.

Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
v4: Don't use the original skb after it has been consumed
---
 drivers/net/wireless/iwlwifi/mvm/tx.c | 143 ++++++++++++++++++++++++++++++++--
 1 file changed, 135 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/iwlwifi/mvm/tx.c
index be9d7e4..d325de4 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -65,6 +65,7 @@
 #include <linux/ieee80211.h>
 #include <linux/etherdevice.h>
 #include <linux/tcp.h>
+#include <net/ip.h>
 
 #include "iwl-trans.h"
 #include "iwl-eeprom-parse.h"
@@ -181,7 +182,8 @@ void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
 
 	tx_cmd->tx_flags = cpu_to_le32(tx_flags);
 	/* Total # bytes to be transmitted */
-	tx_cmd->len = cpu_to_le16((u16)skb->len);
+	tx_cmd->len = cpu_to_le16((u16)skb->len +
+		(uintptr_t)info->driver_data[0]);
 	tx_cmd->next_frame_len = 0;
 	tx_cmd->life_time = cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
 	tx_cmd->sta_id = sta_id;
@@ -356,7 +358,6 @@ iwl_mvm_set_tx_params(struct iwl_mvm *mvm, struct sk_buff *skb,
 
 	memset(&info->status, 0, sizeof(info->status));
 
-	info->driver_data[0] = NULL;
 	info->driver_data[1] = dev_cmd;
 
 	return dev_cmd;
@@ -379,6 +380,9 @@ int iwl_mvm_tx_skb_non_sta(struct iwl_mvm *mvm, struct sk_buff *skb)
 			  info->hw_queue != info->control.vif->cab_queue)))
 		return -1;
 
+	/* This holds the amsdu headers length */
+	info->driver_data[0] = (void *)(uintptr_t)0;
+
 	/*
 	 * IWL_MVM_OFFCHANNEL_QUEUE is used for ROC packets that can be used
 	 * in 2 different types of vifs, P2P & STATION. P2P uses the offchannel
@@ -435,29 +439,148 @@ int iwl_mvm_tx_skb_non_sta(struct iwl_mvm *mvm, struct sk_buff *skb)
 	return 0;
 }
 
-static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
+static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb,
 			  struct ieee80211_sta *sta,
 			  struct sk_buff_head *mpdus_skb)
 {
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	struct ieee80211_hdr *hdr = (void *)skb->data;
+	unsigned int mss = skb_shinfo(skb)->gso_size;
 	struct sk_buff *tmp, *next;
-	char cb[sizeof(skb_gso->cb)];
+	char cb[sizeof(skb->cb)];
+	unsigned int num_subframes, tcp_payload_len, subf_len;
+	u16 amsdu_add, snap_ip_tcp, pad, i = 0;
+	/* Not used in IPv6 */
+	u16 ip_base_id = ntohs(ip_hdr(skb)->id);
+
+	snap_ip_tcp = 8 + skb_transport_header(skb) - skb_network_header(skb) +
+		tcp_hdrlen(skb);
+
+	if (!sta->max_amsdu_len ||
+	    !ieee80211_is_data_qos(hdr->frame_control)) {
+		num_subframes = 1;
+		/* TODO: for the compiler... */
+		pad = 0;
+		goto segment;
+	}
+
+	/*
+	 * Limit A-MSDU in A-MPDU to 4095 bytes when VHT is not
+	 * supported. This is a spec requirement (IEEE 802.11-2015
+	 * section 8.7.3 NOTE 3).
+	 */
+
+	/* TODO: for now, disable A-MSDU inside AMPDU */
+	if (info->flags & IEEE80211_TX_CTL_AMPDU) {
+		num_subframes = 1;
+		/* TODO: for the compiler... */
+		pad = 0;
+		goto segment;
+	}
+
+	/* Sub frame header + SNAP + IP header + TCP header + MSS */
+	subf_len = sizeof(struct ethhdr) + snap_ip_tcp + mss;
+	pad = (4 - subf_len) & 0x3;
+
+	/*
+	 * If we have N subframes in the A-MSDU, then the A-MSDU's size is
+	 * N * subf_len + (N - 1) * pad.
+	 */
+	num_subframes = (sta->max_amsdu_len + pad) / (subf_len + pad);
+	if (num_subframes > 1) {
+		u8 *qc = ieee80211_get_qos_ctl((void *)skb->data);
+
+		*qc |= IEEE80211_QOS_CTL_A_MSDU_PRESENT;
+	}
+
+	tcp_payload_len = skb_tail_pointer(skb) - skb_transport_header(skb) -
+		tcp_hdrlen(skb) + skb->data_len;
 
-	memcpy(cb, skb_gso->cb, sizeof(cb));
-	next = skb_gso_segment(skb_gso, 0);
-	if (IS_ERR(next))
+	/*
+	 * Make sure we have enough TBs for the A-MSDU:
+	 *	2 for each subframe
+	 *	1 more for each fragment
+	 *	1 more for the potential data in the header
+	 */
+	num_subframes =
+		min_t(unsigned int, num_subframes,
+		      (mvm->trans->max_skb_frags - 1 -
+		       skb_shinfo(skb)->nr_frags) / 2);
+
+	/* This skb fits in one single A-MSDU */
+	if (num_subframes * mss >= tcp_payload_len) {
+		/*
+		 * Compute the length of all the data added for the A-MSDU.
+		 * This will be used to compute the length to write in the TX
+		 * command. We have: SNAP + IP + TCP for n -1 subframes and
+		 * ETH header for n subframes. Note that the original skb
+		 * already had one set of SNAP / IP / TCP headers.
+		 */
+		num_subframes = DIV_ROUND_UP(tcp_payload_len, mss);
+		info = IEEE80211_SKB_CB(skb);
+		amsdu_add = num_subframes * sizeof(struct ethhdr) +
+			(num_subframes - 1) * (snap_ip_tcp + pad);
+		/* This holds the amsdu headers length */
+		info->driver_data[0] = (void *)(uintptr_t)amsdu_add;
+
+		__skb_queue_tail(mpdus_skb, skb);
+		return 0;
+	}
+
+	/*
+	 * Trick the segmentation function to make it
+	 * create SKBs that can fit into one A-MSDU.
+	 */
+segment:
+	skb_shinfo(skb)->gso_size = num_subframes * mss;
+	memcpy(cb, skb->cb, sizeof(cb));
+
+	next = skb_gso_segment(skb,
+			       mvm->hw->netdev_features & ~NETIF_F_ALL_TSO);
+	if (WARN_ON_ONCE(IS_ERR(next)))
 		return -EINVAL;
 	else if (next)
-		consume_skb(skb_gso);
+		consume_skb(skb);
 
 	while (next) {
 		tmp = next;
 		next = tmp->next;
+
 		memcpy(tmp->cb, cb, sizeof(tmp->cb));
+		/*
+		 * Compute the length of all the data added for the A-MSDU.
+		 * This will be used to compute the length to write in the TX
+		 * command. We have: SNAP + IP + TCP for n -1 subframes and
+		 * ETH header for n subframes.
+		 */
+		tcp_payload_len = skb_tail_pointer(tmp) -
+			skb_transport_header(tmp) -
+			tcp_hdrlen(tmp) + tmp->data_len;
+
+		if (skb->protocol == htons(ETH_P_IP))
+			ip_hdr(tmp)->id = htons(ip_base_id + i * num_subframes);
+
+		if (tcp_payload_len > mss) {
+			num_subframes = DIV_ROUND_UP(tcp_payload_len, mss);
+			info = IEEE80211_SKB_CB(tmp);
+			amsdu_add = num_subframes * sizeof(struct ethhdr) +
+				(num_subframes - 1) * (snap_ip_tcp + pad);
+			info->driver_data[0] = (void *)(uintptr_t)amsdu_add;
+			skb_shinfo(tmp)->gso_size = mss;
+		} else {
+			u8 *qc = ieee80211_get_qos_ctl((void *)tmp->data);
+
+			if (skb->protocol == htons(ETH_P_IP))
+				ip_send_check(ip_hdr(tmp));
+			*qc &= ~IEEE80211_QOS_CTL_A_MSDU_PRESENT;
+			skb_shinfo(tmp)->gso_size = 0;
+		}
 
 		tmp->prev = NULL;
 		tmp->next = NULL;
 
 		__skb_queue_tail(mpdus_skb, tmp);
+		i++;
 	}
 
 	return 0;
@@ -567,6 +690,7 @@ int iwl_mvm_tx_skb(struct iwl_mvm *mvm, struct sk_buff *skb,
 		   struct ieee80211_sta *sta)
 {
 	struct iwl_mvm_sta *mvmsta = iwl_mvm_sta_from_mac80211(sta);
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct sk_buff_head mpdus_skbs;
 	unsigned int payload_len;
 	int ret;
@@ -577,6 +701,9 @@ int iwl_mvm_tx_skb(struct iwl_mvm *mvm, struct sk_buff *skb,
 	if (WARN_ON_ONCE(mvmsta->sta_id == IWL_MVM_STATION_COUNT))
 		return -1;
 
+	/* This holds the amsdu headers length */
+	info->driver_data[0] = (void *)(uintptr_t)0;
+
 	payload_len = skb_tail_pointer(skb) - skb_transport_header(skb) -
 		tcp_hdrlen(skb) + skb->data_len;
 
-- 
2.1.4
