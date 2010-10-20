From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 01/14] ebtables: Allow filtering of hardware accelerated vlan frames.
Date: Wed, 20 Oct 2010 16:56:01 -0700
Message-ID: <1287618974-4714-2-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34344 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab0JTX4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:23 -0400
Received: by vws2 with SMTP id 2so2600261vws.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:22 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An upcoming commit will allow packets with hardware vlan acceleration
information to be passed though more parts of the network stack, including
packets trunked through the bridge.  This adds support for matching and
filtering those packets through ebtables.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/bridge/br_netfilter.c       |   16 +++++++++-------
 net/bridge/netfilter/ebt_vlan.c |   21 ++++++++++++++-------
 net/bridge/netfilter/ebtables.c |   15 +++++++++++----
 3 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 7f9ce96..47c2dab 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -64,22 +64,24 @@ static int brnf_filter_pppoe_tagged __read_mostly = 0;
 
 static inline __be16 vlan_proto(const struct sk_buff *skb)
 {
-	return vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+	if (vlan_tx_tag_present(skb))
+		return skb->protocol;
+	else if (skb->protocol == htons(ETH_P_8021Q))
+		return vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+	else
+		return 0;
 }
 
 #define IS_VLAN_IP(skb) \
-	(skb->protocol == htons(ETH_P_8021Q) && \
-	 vlan_proto(skb) == htons(ETH_P_IP) && 	\
+	(vlan_proto(skb) == htons(ETH_P_IP) && \
 	 brnf_filter_vlan_tagged)
 
 #define IS_VLAN_IPV6(skb) \
-	(skb->protocol == htons(ETH_P_8021Q) && \
-	 vlan_proto(skb) == htons(ETH_P_IPV6) &&\
+	(vlan_proto(skb) == htons(ETH_P_IPV6) && \
 	 brnf_filter_vlan_tagged)
 
 #define IS_VLAN_ARP(skb) \
-	(skb->protocol == htons(ETH_P_8021Q) &&	\
-	 vlan_proto(skb) == htons(ETH_P_ARP) &&	\
+	(vlan_proto(skb) == htons(ETH_P_ARP) &&	\
 	 brnf_filter_vlan_tagged)
 
 static inline __be16 pppoe_proto(const struct sk_buff *skb)
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index 87b53b3..cc11d6b 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -39,8 +39,6 @@ static bool
 ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_vlan_info *info = par->matchinfo;
-	const struct vlan_hdr *fp;
-	struct vlan_hdr _frame;
 
 	unsigned short TCI;	/* Whole TCI, given from parsed frame */
 	unsigned short id;	/* VLAN ID, given from frame TCI */
@@ -48,9 +46,20 @@ ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/* VLAN encapsulated Type/Length field, given from orig frame */
 	__be16 encap;
 
-	fp = skb_header_pointer(skb, 0, sizeof(_frame), &_frame);
-	if (fp == NULL)
-		return false;
+	if (vlan_tx_tag_present(skb)) {
+		TCI = vlan_tx_tag_get(skb);
+		encap = skb->protocol;
+	} else {
+		const struct vlan_hdr *fp;
+		struct vlan_hdr _frame;
+
+		fp = skb_header_pointer(skb, 0, sizeof(_frame), &_frame);
+		if (fp == NULL)
+			return false;
+
+		TCI = ntohs(fp->h_vlan_TCI);
+		encap = fp->h_vlan_encapsulated_proto;
+	}
 
 	/* Tag Control Information (TCI) consists of the following elements:
 	 * - User_priority. The user_priority field is three bits in length,
@@ -59,10 +68,8 @@ ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	 * (CFI) is a single bit flag value. Currently ignored.
 	 * - VLAN Identifier (VID). The VID is encoded as
 	 * an unsigned binary number. */
-	TCI = ntohs(fp->h_vlan_TCI);
 	id = TCI & VLAN_VID_MASK;
 	prio = (TCI >> 13) & 0x7;
-	encap = fp->h_vlan_encapsulated_proto;
 
 	/* Checking VLAN Identifier (VID) */
 	if (GET_BITMASK(EBT_VLAN_ID))
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index bcc102e..a1dcf83 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -124,16 +124,23 @@ ebt_dev_check(const char *entry, const struct net_device *device)
 #define FWINV2(bool,invflg) ((bool) ^ !!(e->invflags & invflg))
 /* process standard matches */
 static inline int
-ebt_basic_match(const struct ebt_entry *e, const struct ethhdr *h,
+ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
                 const struct net_device *in, const struct net_device *out)
 {
+	const struct ethhdr *h = eth_hdr(skb);
+	__be16 ethproto;
 	int verdict, i;
 
+	if (vlan_tx_tag_present(skb))
+		ethproto = htons(ETH_P_8021Q);
+	else
+		ethproto = h->h_proto;
+
 	if (e->bitmask & EBT_802_3) {
-		if (FWINV2(ntohs(h->h_proto) >= 1536, EBT_IPROTO))
+		if (FWINV2(ntohs(ethproto) >= 1536, EBT_IPROTO))
 			return 1;
 	} else if (!(e->bitmask & EBT_NOPROTO) &&
-	   FWINV2(e->ethproto != h->h_proto, EBT_IPROTO))
+	   FWINV2(e->ethproto != ethproto, EBT_IPROTO))
 		return 1;
 
 	if (FWINV2(ebt_dev_check(e->in, in), EBT_IIN))
@@ -213,7 +220,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	base = private->entries;
 	i = 0;
 	while (i < nentries) {
-		if (ebt_basic_match(point, eth_hdr(skb), in, out))
+		if (ebt_basic_match(point, skb, in, out))
 			goto letscontinue;
 
 		if (EBT_MATCH_ITERATE(point, ebt_do_match, skb, &acpar) != 0)
-- 
1.7.1

