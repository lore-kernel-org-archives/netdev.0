From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] wireless, ipv4, ipv6: drop GTK-protected unicast IP packets
Date: Thu, 21 Nov 2013 14:05:54 +0100
Message-ID: <1385039154-20637-1-git-send-email-johannes@sipsolutions.net>
Cc: Jouni Malinen <jouni@qca.qualcomm.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50061 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab3KUNF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 08:05:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jouni Malinen <jouni@qca.qualcomm.com>

The GTK is shared by all stations in an 802.11 BSS and as such any
one of them can send forged group-addressed frames. To prevent this
kind of attack, drop unicast IP packets if they were protected with
the GTK, i.e. were multicast packets at the 802.11 layer.

Signed-off-by: Jouni Malinen <jouni@qca.qualcomm.com>
[configuration, IPv6]
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/skbuff.h       |  5 ++++-
 include/net/cfg80211.h       |  7 +++++--
 include/uapi/linux/nl80211.h |  6 ++++++
 net/core/skbuff.c            |  1 +
 net/ipv4/ip_input.c          | 12 ++++++++++++
 net/ipv6/ip6_input.c         | 11 +++++++++++
 net/mac80211/ieee80211_i.h   |  3 ++-
 net/mac80211/mlme.c          |  2 ++
 net/mac80211/rx.c            |  7 +++++++
 net/wireless/nl80211.c       |  4 ++++
 10 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..5ed5a19 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -384,6 +384,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
+ *	@drop_unicast: Request protocols to drop frame if it's a unicast frame
+ *		in that protocol - used for frames received over wifi multicast
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
   *	@napi_id: id of the NAPI struct this skb came from
@@ -498,7 +500,8 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
+	__u8			drop_unicast:1;
+	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 6c2bc329..37a4c09 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1560,10 +1560,13 @@ struct cfg80211_auth_request {
  *
  * @ASSOC_REQ_DISABLE_HT:  Disable HT (802.11n)
  * @ASSOC_REQ_DISABLE_VHT:  Disable VHT
+ * @ASSOC_REQ_DROP_GROUP_PROTECTED_UNICAST: Drop protocol unicast packets
+ *	that were group-protected at the link layer.
  */
 enum cfg80211_assoc_req_flags {
-	ASSOC_REQ_DISABLE_HT		= BIT(0),
-	ASSOC_REQ_DISABLE_VHT		= BIT(1),
+	ASSOC_REQ_DISABLE_HT			= BIT(0),
+	ASSOC_REQ_DISABLE_VHT			= BIT(1),
+	ASSOC_REQ_DROP_GROUP_PROTECTED_UNICAST	= BIT(2),
 };
 
 /**
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 4bb8289..8fc8b05 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -1518,6 +1518,10 @@ enum nl80211_commands {
  * @NL80211_ATTR_SUPPORT_5_10_MHZ: A flag indicating that the device supports
  *	5 MHz and 10 MHz channel bandwidth.
  *
+ * @NL80211_ATTR_DROP_GROUP_PROTECTED_UNICAST: Drop protocol unicast packets
+ *	that were group protected at the wireless level. This flag attribute
+ *	is valid in the association command.
+ *
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
  */
@@ -1836,6 +1840,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_SUPPORT_5_10_MHZ,
 
+	NL80211_ATTR_DROP_GROUP_PROTECTED_UNICAST,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d81cff1..b751e7d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -737,6 +737,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 	new->vlan_proto		= old->vlan_proto;
 	new->vlan_tci		= old->vlan_tci;
+	new->drop_unicast	= old->drop_unicast;
 
 	skb_copy_secmark(new, old);
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 054a3e9..7de7f84 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -363,6 +363,18 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INBCAST,
 				skb->len);
 
+	/*
+	 * If the received packet was protected in a way that would allow
+	 * insider attacks (e.g. IEEE 802.11 networks with GTK shared for all
+	 * associated stations in an BSS), group-addressed link layer frames
+	 * can be forged. To reduce the effects of such an attack, drop the
+	 * packet if it is destined to unicast address, but was sent in a
+	 * group-addressed link layer frame.
+	 */
+	if (unlikely(skb->drop_unicast &&
+		     (rt->rt_type == RTN_UNICAST || rt->rt_type == RTN_LOCAL)))
+		goto drop;
+
 	return dst_input(skb);
 
 drop:
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 302d6fb..d9cbf4d 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -151,6 +151,17 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (ipv6_addr_is_multicast(&hdr->saddr))
 		goto err;
 
+	/*
+	 * If the received packet was protected in a way that would allow
+	 * insider attacks (e.g. IEEE 802.11 networks with GTK shared for all
+	 * associated stations in an BSS), group-addressed link layer frames
+	 * can be forged. To reduce the effects of such an attack, drop the
+	 * packet if it is destined to unicast address, but was sent in a
+	 * group-addressed link layer frame.
+	 */
+	if (unlikely(skb->drop_unicast && !ipv6_addr_is_multicast(&hdr->daddr)))
+		goto err;
+
 	skb->transport_header = skb->network_header + sizeof(*hdr);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 61ccf0d..d39cfb5 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -705,7 +705,8 @@ struct ieee80211_sub_if_data {
 
 	unsigned long state;
 
-	int drop_unencrypted;
+	bool drop_unencrypted;
+	bool drop_group_protected_unicast;
 
 	char name[IFNAMSIZ];
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index e7f0d53..649902b 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -4121,6 +4121,8 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 	sdata->control_port_no_encrypt = req->crypto.control_port_no_encrypt;
 	sdata->encrypt_headroom = ieee80211_cs_headroom(local, &req->crypto,
 							sdata->vif.type);
+	sdata->drop_group_protected_unicast =
+		req->flags & ASSOC_REQ_DROP_GROUP_PROTECTED_UNICAST;
 
 	/* kick off associate process */
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 5638782..2095be1 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1544,6 +1544,13 @@ ieee80211_rx_h_decrypt(struct ieee80211_rx_data *rx)
 			    !is_multicast_ether_addr(hdr->addr1))
 				rx->key = NULL;
 		}
+
+		if (rx->key && is_multicast_ether_addr(hdr->addr1) &&
+		    rx->sdata->vif.type == NL80211_IFTYPE_STATION &&
+		    rx->sdata->drop_group_protected_unicast &&
+		    rx->key->conf.cipher != WLAN_CIPHER_SUITE_WEP40 &&
+		    rx->key->conf.cipher != WLAN_CIPHER_SUITE_WEP104)
+			rx->skb->drop_unicast = 1;
 	}
 
 	if (rx->key) {
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index e39fadc..f8e3c83 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -357,6 +357,7 @@ static const struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] = {
 	[NL80211_ATTR_STA_SUPPORTED_CHANNELS] = { .type = NLA_BINARY },
 	[NL80211_ATTR_STA_SUPPORTED_OPER_CLASSES] = { .type = NLA_BINARY },
 	[NL80211_ATTR_HANDLE_DFS] = { .type = NLA_FLAG },
+	[NL80211_ATTR_DROP_GROUP_PROTECTED_UNICAST] = { .type = NLA_FLAG },
 };
 
 /* policy for the key attributes */
@@ -6345,6 +6346,9 @@ static int nl80211_associate(struct sk_buff *skb, struct genl_info *info)
 		       sizeof(req.vht_capa));
 	}
 
+	if (info->attrs[NL80211_ATTR_DROP_GROUP_PROTECTED_UNICAST])
+		req.flags |= ASSOC_REQ_DROP_GROUP_PROTECTED_UNICAST;
+
 	err = nl80211_crypto_settings(rdev, info, &req.crypto, 1);
 	if (!err) {
 		wdev_lock(dev->ieee80211_ptr);
-- 
1.8.4.rc3
