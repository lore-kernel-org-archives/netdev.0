From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Subject: [RFC v3 2/3] iwlwifi: mvm: allow to create A-MSDUs from a large send
Date: Thu, 20 Aug 2015 11:15:43 +0300
Message-ID: <1440058544-20342-3-git-send-email-emmanuel.grumbach@intel.com>
References: <1440058544-20342-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: sara.sharon@intel.com, eric.dumazet@gmail.com, ido@wizery.com,
	netdev@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:63269 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384AbbHTIQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 04:16:03 -0400
In-Reply-To: <1440058544-20342-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we can get a big chunk of data from the network
stack, we can create an A-MSDU out of it. The purpose is to
get a throughput improvement since sending one single A-MSDU
is more efficient than sending several MSDUs at least under
ideal link conditions.

type=feature

Change-Id: I5ea1b1132a57542187cd4c34c5299dbf44fe8b01
Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
 drivers/net/wireless/iwlwifi/mvm/mac80211.c |   3 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c      |   4 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h      |   6 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c       | 159 ++++++++++++++++++++++++++--
 4 files changed, 160 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
index 3dd4e97..dd15e04 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -925,7 +925,8 @@ static int iwl_mvm_mac_ampdu_action(struct ieee80211_hw *hw,
 		ret = iwl_mvm_sta_tx_agg_flush(mvm, vif, sta, tid);
 		break;
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
-		ret = iwl_mvm_sta_tx_agg_oper(mvm, vif, sta, tid, buf_size);
+		ret = iwl_mvm_sta_tx_agg_oper(mvm, vif, sta, tid,
+					      buf_size, amsdu);
 		break;
 	default:
 		WARN_ON_ONCE(1);
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/iwlwifi/mvm/sta.c
index df216cd..606fc09 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -976,7 +976,8 @@ int iwl_mvm_sta_tx_agg_start(struct iwl_mvm *mvm, struct ieee80211_vif *vif,
 }
 
 int iwl_mvm_sta_tx_agg_oper(struct iwl_mvm *mvm, struct ieee80211_vif *vif,
-			    struct ieee80211_sta *sta, u16 tid, u8 buf_size)
+			    struct ieee80211_sta *sta, u16 tid, u8 buf_size,
+			    bool amsdu)
 {
 	struct iwl_mvm_sta *mvmsta = iwl_mvm_sta_from_mac80211(sta);
 	struct iwl_mvm_tid_data *tid_data = &mvmsta->tid_data[tid];
@@ -995,6 +996,7 @@ int iwl_mvm_sta_tx_agg_oper(struct iwl_mvm *mvm, struct ieee80211_vif *vif,
 	queue = tid_data->txq_id;
 	tid_data->state = IWL_AGG_ON;
 	mvmsta->agg_tids |= BIT(tid);
+	tid_data->amsdu_in_ampdu_allowed = amsdu;
 	tid_data->ssn = 0xffff;
 	spin_unlock_bh(&mvmsta->lock);
 
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.h b/drivers/net/wireless/iwlwifi/mvm/sta.h
index eedb215..26d1e31 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.h
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.h
@@ -258,6 +258,8 @@ enum iwl_mvm_agg_state {
  *	Tx response (TX_CMD), and the block ack notification (COMPRESSED_BA).
  * @reduced_tpc: Reduced tx power. Holds the data between the
  *	Tx response (TX_CMD), and the block ack notification (COMPRESSED_BA).
+ * @amsdu_in_ampdu_allowed: true if A-MSDU in A-MPDU is allowed. Relevant only
+ *	if &state is %IWL_AGG_ON.
  * @state: state of the BA agreement establishment / tear down.
  * @txq_id: Tx queue used by the BA session
  * @ssn: the first packet to be sent in AGG HW queue in Tx AGG start flow, or
@@ -272,6 +274,7 @@ struct iwl_mvm_tid_data {
 	/* The rest is Tx AGG related */
 	u32 rate_n_flags;
 	u8 reduced_tpc;
+	bool amsdu_in_ampdu_allowed;
 	enum iwl_mvm_agg_state state;
 	u16 txq_id;
 	u16 ssn;
@@ -387,7 +390,8 @@ int iwl_mvm_sta_rx_agg(struct iwl_mvm *mvm, struct ieee80211_sta *sta,
 int iwl_mvm_sta_tx_agg_start(struct iwl_mvm *mvm, struct ieee80211_vif *vif,
 			struct ieee80211_sta *sta, u16 tid, u16 *ssn);
 int iwl_mvm_sta_tx_agg_oper(struct iwl_mvm *mvm, struct ieee80211_vif *vif,
-			struct ieee80211_sta *sta, u16 tid, u8 buf_size);
+			    struct ieee80211_sta *sta, u16 tid, u8 buf_size,
+			    bool amsdu);
 int iwl_mvm_sta_tx_agg_stop(struct iwl_mvm *mvm, struct ieee80211_vif *vif,
 			    struct ieee80211_sta *sta, u16 tid);
 int iwl_mvm_sta_tx_agg_flush(struct iwl_mvm *mvm, struct ieee80211_vif *vif,
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/iwlwifi/mvm/tx.c
index a63686c..5046833 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -488,8 +488,10 @@ static void iwl_update_ip_tcph(void *iph, struct tcphdr *tcph, bool ipv6,
  * @ieee80211_hdr *hdr: Points to the WiFi header.
  * @gso_nr_frags: The number of frags in the original GSO skb.
  * @wifi_hdr_iv_len: The length of the WiFi header including IV.
+ * @amsdu_pad: Number of bytes for the A-MSDU subframe
  * @tcp_fin: True if TCP_FIN is set in the original GSO skb.
  * @tcp_push: True if TCP_PSH is set in the original GSO skb.
+ * @amsdu: True if we are building an A-MSDU
  */
 struct iwl_lso_splitter {
 	unsigned int linear_payload_len;
@@ -505,8 +507,10 @@ struct iwl_lso_splitter {
 	struct ieee80211_hdr *hdr;
 	u8 gso_nr_frags;
 	u8 wifi_hdr_iv_len;
+	u8 amsdu_pad;
 	bool tcp_fin;
 	bool tcp_push;
+	bool amsdu;
 };
 
 /*
@@ -621,9 +625,10 @@ static int iwl_add_msdu(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 			u8 **hdr_page_pos, int ip_id,
 			struct iwl_lso_splitter *p)
 {
-	unsigned int tcp_seg_sz, snap_ip_tcp_len, copy_sz = 0;
+	unsigned int tcp_seg_sz, snap_ip_tcp_len, subframe_sz, copy_sz = 0;
 	bool ipv6 = p->si->gso_type & SKB_GSO_TCPV6;
 	u8 *start_hdr;
+	__be16 *length = NULL;
 	struct tcphdr *tcph;
 	struct iphdr *iph;
 
@@ -640,6 +645,45 @@ static int iwl_add_msdu(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 
 	start_hdr = *hdr_page_pos;
 
+	subframe_sz = snap_ip_tcp_len;
+
+	if (p->amsdu) {
+		memset(*hdr_page_pos, 0, p->amsdu_pad);
+		*hdr_page_pos += p->amsdu_pad;
+		switch (p->hdr->frame_control &
+			cpu_to_le16(IEEE80211_FCTL_TODS |
+				    IEEE80211_FCTL_FROMDS)) {
+		/* STA */
+		case cpu_to_le16(IEEE80211_FCTL_TODS):
+			memcpy(*hdr_page_pos, p->hdr->addr3, ETH_ALEN);
+			*hdr_page_pos += ETH_ALEN;
+
+			memcpy(*hdr_page_pos, p->hdr->addr2, ETH_ALEN);
+			*hdr_page_pos += ETH_ALEN;
+			break;
+		/* AP */
+		case cpu_to_le16(IEEE80211_FCTL_FROMDS):
+			memcpy(*hdr_page_pos, p->hdr->addr1, ETH_ALEN);
+			*hdr_page_pos += ETH_ALEN;
+
+			memcpy(*hdr_page_pos, p->hdr->addr3, ETH_ALEN);
+			*hdr_page_pos += ETH_ALEN;
+			break;
+		/* TDLS or IBSS */
+		case cpu_to_le16(0):
+			memcpy(*hdr_page_pos, p->hdr->addr1, ETH_ALEN);
+			*hdr_page_pos += ETH_ALEN;
+
+			memcpy(*hdr_page_pos, p->hdr->addr2, ETH_ALEN);
+			*hdr_page_pos += ETH_ALEN;
+			break;
+		}
+
+		length = (void *)*hdr_page_pos;
+		*hdr_page_pos += sizeof(*length);
+		subframe_sz += sizeof(struct ethhdr);
+	}
+
 	/*
 	 * Copy SNAP / IP / TCP headers from the original GSO skb to the
 	 * header page.
@@ -681,6 +725,11 @@ static int iwl_add_msdu(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 
 	/* .. and now add the payload coming from the frags. */
 	tcp_seg_sz = iwl_add_tcp_segment(mvm, skb_gso, skb, p, copy_sz);
+	subframe_sz += tcp_seg_sz;
+	p->amsdu_pad = (4 - (subframe_sz)) & 0x3;
+
+	if (length)
+		*length = cpu_to_be16(subframe_sz - sizeof(struct ethhdr));
 
 	iwl_update_ip_tcph(iph, tcph, ipv6, tcp_seg_sz,
 			   p->gso_payload_pos - tcp_seg_sz, ip_id);
@@ -701,13 +750,14 @@ static int iwl_add_msdu(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 						tcp_seg_sz,
 						tcp_hdrlen(skb_gso));
 
-	return 0;
+	return subframe_sz;
 }
 
 static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 			  struct ieee80211_sta *sta,
 			  struct sk_buff_head *mpdus_skb)
 {
+	struct iwl_mvm_sta *mvmsta = iwl_mvm_sta_from_mac80211(sta);
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb_gso);
 	struct ieee80211_key_conf *keyconf = info->control.hw_key;
 	struct ieee80211_hdr *wifi_hdr = (void *)skb_gso->data;
@@ -715,7 +765,7 @@ static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 	struct iwl_lso_splitter s = {};
 	struct page *hdr_page;
 	unsigned int mpdu_sz;
-	u8 *hdr_page_pos;
+	u8 *hdr_page_pos, *qc, tid;
 	int i, ret;
 
 	s.si = skb_shinfo(skb_gso);
@@ -864,9 +914,22 @@ static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 			keyconf->cipher == WLAN_CIPHER_SUITE_CCMP_256))
 		s.wifi_hdr_iv_len += IEEE80211_CCMP_HDR_LEN;
 
+	qc = ieee80211_get_qos_ctl(s.hdr);
+	tid = qc[0] & IEEE80211_QOS_CTL_TID_MASK;
+	if (WARN_ON_ONCE(tid >= IWL_MAX_TID_COUNT)) {
+		ret = -1;
+		goto out;
+	}
+
+	spin_lock(&mvmsta->lock);
+	s.amsdu = !(info->flags & IEEE80211_TX_CTL_AMPDU) ||
+		mvmsta->tid_data[tid].amsdu_in_ampdu_allowed;
+
+	spin_unlock(&mvmsta->lock);
+
 	while (s.gso_payload_pos < s.gso_payload_len) {
 		struct sk_buff *skb = dev_alloc_skb(s.wifi_hdr_iv_len);
-		int l;
+		unsigned int ip_tcp_snap_hdrlen, amsdu_sz, max_amsdu_len;
 
 		s.frag_in_mpdu = 0;
 
@@ -884,14 +947,92 @@ static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 		memcpy(skb_put(skb, s.wifi_hdr_iv_len),
 		       wifi_hdr, s.wifi_hdr_iv_len);
 
-		l = iwl_add_msdu(mvm, skb_gso, skb, &hdr_page,
-				 &hdr_page_pos, i++, &s);
-		if (l < 0) {
-			skb_queue_purge(mpdus_skb);
-			ret = l;
+		/* No need to have an AMSDU if we have at most mss bytes */
+		if (s.gso_payload_len - s.gso_payload_pos <= s.mss)
+			s.amsdu = false;
+
+		/*
+		 * Limit A-MSDU in A-MPDU to 4095 bytes when VHT is not
+		 * supported. This is a spec requirement (IEEE 802.11-2015
+		 * section 8.7.3 NOTE 3).
+		 */
+		if (info->flags & IEEE80211_TX_CTL_AMPDU &&
+		    mvmsta->tid_data[tid].amsdu_in_ampdu_allowed &&
+		    !sta->vht_cap.vht_supported)
+			max_amsdu_len = 4095;
+		else
+			max_amsdu_len = 0;
+
+		if (max_amsdu_len)
+			max_amsdu_len = min_t(unsigned int, sta->max_amsdu_len,
+					      max_amsdu_len);
+		else
+			max_amsdu_len = sta->max_amsdu_len;
+
+		/*
+		 * Technically, this will allow to have an A-MSDU will only
+		 * one subframe. But this won't happen on valid limits. Only
+		 * on custom limit set by debugfs. We could test that there is
+		 * enough room for the subframe header + data headers etc...
+		 * but these tests cost, and this is a hot path.
+		 */
+		if (!max_amsdu_len || !s.amsdu) {
+			int l;
+
+			s.amsdu = false;
+			l = iwl_add_msdu(mvm, skb_gso, skb, &hdr_page,
+					 &hdr_page_pos, i++, &s);
+			if (l < 0) {
+				skb_queue_purge(mpdus_skb);
+				ret = l;
+				goto out;
+			}
+
+			__skb_queue_tail(mpdus_skb, skb);
+			continue;
+		}
+
+		if (WARN_ON_ONCE(max_amsdu_len < s.mss)) {
+			ret = -1;
 			goto out;
 		}
 
+		qc = ieee80211_get_qos_ctl((void *)skb->data);
+		*qc |= IEEE80211_QOS_CTL_A_MSDU_PRESENT;
+
+		amsdu_sz = 0;
+		s.amsdu_pad = 0;
+		ip_tcp_snap_hdrlen =
+			8 + ip_hdrlen(skb_gso) + tcp_hdrlen(skb_gso);
+
+		i = 0;
+
+		/*
+		 * Make sure we have enough room for
+		 * ethernet header, SNAP header, IP header, TCP header and MSS.
+		 * Make sure we don't add more MSDUs than allowed
+		 */
+		while (amsdu_sz + sizeof(struct ethhdr) + s.mss +
+		       ip_tcp_snap_hdrlen < max_amsdu_len &&
+		       (!sta->max_amsdu_subframes ||
+			i < sta->max_amsdu_subframes) &&
+		       s.gso_payload_pos < s.gso_payload_len) {
+			unsigned int l;
+
+			if (s.frag_in_mpdu + 1 >= mvm->trans->max_skb_frags)
+				break;
+
+			l = iwl_add_msdu(mvm, skb_gso, skb, &hdr_page,
+					 &hdr_page_pos, i++, &s);
+			if (l < 0) {
+				skb_queue_purge(mpdus_skb);
+				ret = l;
+				goto out;
+			}
+
+			amsdu_sz += l + s.amsdu_pad;
+		}
+
 		__skb_queue_tail(mpdus_skb, skb);
 	}
 
-- 
2.1.4
