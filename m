From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH RFCv3 2/4] net: Export IGMP/MLD message validation code
Date: Tue,  7 Apr 2015 21:57:30 +0200
Message-ID: <1428436652-4676-3-git-send-email-linus.luessing@c0d3.blue>
References: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:40829 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677AbbDGT5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 15:57:45 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id A953E5863E5
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 21:57:41 +0200 (CEST)
In-Reply-To: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, the IGMP and MLD message validation functions are moved
from the bridge code to the IPv4/IPv6 multicast files. Some small
refactoring was done to enhance readibility and to iron out some
differences in behaviour between the IGMP and MLD parsing code (e.g. the
skb-cloning of MLD messages is now only done if necessary, just like the
IGMP part always did).

Finally, these IGMP and MLD message validation functions are exported so
that not only the bridge can use it but batman-adv later, too.
---
 include/linux/igmp.h      |    1 +
 include/linux/skbuff.h    |    3 +
 include/net/addrconf.h    |    1 +
 net/bridge/br_multicast.c |  218 +++++++--------------------------------------
 net/core/skbuff.c         |   38 ++++++++
 net/ipv4/igmp.c           |  152 +++++++++++++++++++++++++++++++
 net/ipv6/mcast.c          |  178 ++++++++++++++++++++++++++++++++++++
 7 files changed, 403 insertions(+), 188 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 2c677af..193ad48 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -130,5 +130,6 @@ extern void ip_mc_unmap(struct in_device *);
 extern void ip_mc_remap(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
+int ip_mc_check_igmp(struct sk_buff *skb, struct sk_buff **skb_trimmed);
 
 #endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 36f3f43..8f1b7de 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3398,6 +3398,9 @@ static inline void skb_checksum_none_assert(const struct sk_buff *skb)
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
+int skb_checksum_trimmed(struct sk_buff *skb, unsigned int transport_len,
+			 __sum16(*skb_check_func)(struct sk_buff *skb),
+			 struct sk_buff **skb_trimmed);
 
 u32 skb_get_poff(const struct sk_buff *skb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 80456f7..def59d3 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -142,6 +142,7 @@ void ipv6_mc_unmap(struct inet6_dev *idev);
 void ipv6_mc_remap(struct inet6_dev *idev);
 void ipv6_mc_init_dev(struct inet6_dev *idev);
 void ipv6_mc_destroy_dev(struct inet6_dev *idev);
+int ipv6_mc_check_mld(struct sk_buff *skb, struct sk_buff **skb_trimmed);
 void addrconf_dad_failure(struct inet6_ifaddr *ifp);
 
 bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 3c630c7..55a9e0c 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -974,9 +974,6 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	int err = 0;
 	__be32 group;
 
-	if (!pskb_may_pull(skb, sizeof(*ih)))
-		return -EINVAL;
-
 	ih = igmpv3_report_hdr(skb);
 	num = ntohs(ih->ngrec);
 	len = sizeof(*ih);
@@ -1247,25 +1244,14 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 			max_delay = 10 * HZ;
 			group = 0;
 		}
-	} else {
-		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query))) {
-			err = -EINVAL;
-			goto out;
-		}
-
+	} else if (skb->len >= sizeof(*ih3)) {
 		ih3 = igmpv3_query_hdr(skb);
 		if (ih3->nsrcs)
 			goto out;
 
 		max_delay = ih3->code ?
 			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE) : 1;
-	}
-
-	/* RFC2236+RFC3376 (IGMPv2+IGMPv3) require the multicast link layer
-	 * all-systems destination addresses (224.0.0.1) for general queries
-	 */
-	if (!group && iph->daddr != htonl(INADDR_ALLHOSTS_GROUP)) {
-		err = -EINVAL;
+	} else {
 		goto out;
 	}
 
@@ -1328,12 +1314,6 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	    (port && port->state == BR_STATE_DISABLED))
 		goto out;
 
-	/* RFC2710+RFC3810 (MLDv1+MLDv2) require link-local source addresses */
-	if (!(ipv6_addr_type(&ip6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
-		err = -EINVAL;
-		goto out;
-	}
-
 	if (skb->len == sizeof(*mld)) {
 		if (!pskb_may_pull(skb, sizeof(*mld))) {
 			err = -EINVAL;
@@ -1357,14 +1337,6 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 
 	is_general_query = group && ipv6_addr_any(group);
 
-	/* RFC2710+RFC3810 (MLDv1+MLDv2) require the multicast link layer
-	 * all-nodes destination address (ff02::1) for general queries
-	 */
-	if (is_general_query && !ipv6_addr_is_ll_all_nodes(&ip6h->daddr)) {
-		err = -EINVAL;
-		goto out;
-	}
-
 	if (is_general_query) {
 		saddr.proto = htons(ETH_P_IPV6);
 		saddr.u.ip6 = ip6h->saddr;
@@ -1556,66 +1528,22 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct sk_buff *skb,
 				 u16 vid)
 {
-	struct sk_buff *skb2 = skb;
-	const struct iphdr *iph;
+	struct sk_buff *skb_trimmed = NULL;
 	struct igmphdr *ih;
-	unsigned int len;
-	unsigned int offset;
 	int err;
 
-	/* We treat OOM as packet loss for now. */
-	if (!pskb_may_pull(skb, sizeof(*iph)))
-		return -EINVAL;
-
-	iph = ip_hdr(skb);
-
-	if (iph->ihl < 5 || iph->version != 4)
-		return -EINVAL;
-
-	if (!pskb_may_pull(skb, ip_hdrlen(skb)))
-		return -EINVAL;
-
-	iph = ip_hdr(skb);
+	err = ip_mc_check_igmp(skb, &skb_trimmed);
 
-	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
-		return -EINVAL;
-
-	if (iph->protocol != IPPROTO_IGMP) {
-		if (!ipv4_is_local_multicast(iph->daddr))
+	if (err == -ENOMSG) {
+		if (!ipv4_is_local_multicast(ip_hdr(skb)->daddr))
 			BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 		return 0;
+	} else if (err < 0) {
+		return err;
 	}
 
-	len = ntohs(iph->tot_len);
-	if (skb->len < len || len < ip_hdrlen(skb))
-		return -EINVAL;
-
-	if (skb->len > len) {
-		skb2 = skb_clone(skb, GFP_ATOMIC);
-		if (!skb2)
-			return -ENOMEM;
-
-		err = pskb_trim_rcsum(skb2, len);
-		if (err)
-			goto err_out;
-	}
-
-	len -= ip_hdrlen(skb2);
-	offset = skb_network_offset(skb2) + ip_hdrlen(skb2);
-	__skb_pull(skb2, offset);
-	skb_reset_transport_header(skb2);
-
-	err = -EINVAL;
-	if (!pskb_may_pull(skb2, sizeof(*ih)))
-		goto out;
-
-	if (skb_checksum_simple_validate(skb2))
-		goto out;
-
-	err = 0;
-
 	BR_INPUT_SKB_CB(skb)->igmp = 1;
-	ih = igmp_hdr(skb2);
+	ih = igmp_hdr(skb);
 
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_REPORT:
@@ -1624,21 +1552,19 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_add_group(br, port, ih->group, vid);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
-		err = br_ip4_multicast_igmp3_report(br, port, skb2, vid);
+		err = br_ip4_multicast_igmp3_report(br, port, skb_trimmed, vid);
 		break;
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		err = br_ip4_multicast_query(br, port, skb2, vid);
+		err = br_ip4_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
 		br_ip4_multicast_leave_group(br, port, ih->group, vid);
 		break;
 	}
 
-out:
-	__skb_push(skb2, offset);
-err_out:
-	if (skb2 != skb)
-		kfree_skb(skb2);
+	if (skb_trimmed && skb_trimmed != skb)
+		kfree_skb(skb_trimmed);
+
 	return err;
 }
 
@@ -1648,126 +1574,42 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct sk_buff *skb,
 				 u16 vid)
 {
-	struct sk_buff *skb2;
-	const struct ipv6hdr *ip6h;
-	u8 icmp6_type;
-	u8 nexthdr;
-	__be16 frag_off;
-	unsigned int len;
-	int offset;
+	struct sk_buff *skb_trimmed = NULL;
+	struct mld_msg *mld;
 	int err;
 
-	if (!pskb_may_pull(skb, sizeof(*ip6h)))
-		return -EINVAL;
+	err = ipv6_mc_check_mld(skb, &skb_trimmed);
 
-	ip6h = ipv6_hdr(skb);
-
-	/*
-	 * We're interested in MLD messages only.
-	 *  - Version is 6
-	 *  - MLD has always Router Alert hop-by-hop option
-	 *  - But we do not support jumbrograms.
-	 */
-	if (ip6h->version != 6)
-		return 0;
-
-	/* Prevent flooding this packet if there is no listener present */
-	if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
-		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-
-	if (ip6h->nexthdr != IPPROTO_HOPOPTS ||
-	    ip6h->payload_len == 0)
-		return 0;
-
-	len = ntohs(ip6h->payload_len) + sizeof(*ip6h);
-	if (skb->len < len)
-		return -EINVAL;
-
-	nexthdr = ip6h->nexthdr;
-	offset = ipv6_skip_exthdr(skb, sizeof(*ip6h), &nexthdr, &frag_off);
-
-	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
+	if (err == -ENOMSG) {
+		if (!ipv6_addr_is_ll_all_nodes(&ipv6_hdr(skb)->daddr))
+			BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 		return 0;
-
-	/* Okay, we found ICMPv6 header */
-	skb2 = skb_clone(skb, GFP_ATOMIC);
-	if (!skb2)
-		return -ENOMEM;
-
-	err = -EINVAL;
-	if (!pskb_may_pull(skb2, offset + sizeof(struct icmp6hdr)))
-		goto out;
-
-	len -= offset - skb_network_offset(skb2);
-
-	__skb_pull(skb2, offset);
-	skb_reset_transport_header(skb2);
-	skb_postpull_rcsum(skb2, skb_network_header(skb2),
-			   skb_network_header_len(skb2));
-
-	icmp6_type = icmp6_hdr(skb2)->icmp6_type;
-
-	switch (icmp6_type) {
-	case ICMPV6_MGM_QUERY:
-	case ICMPV6_MGM_REPORT:
-	case ICMPV6_MGM_REDUCTION:
-	case ICMPV6_MLD2_REPORT:
-		break;
-	default:
-		err = 0;
-		goto out;
-	}
-
-	/* Okay, we found MLD message. Check further. */
-	if (skb2->len > len) {
-		err = pskb_trim_rcsum(skb2, len);
-		if (err)
-			goto out;
-		err = -EINVAL;
+	} else if (err < 0) {
+		return err;
 	}
 
-	ip6h = ipv6_hdr(skb2);
-
-	if (skb_checksum_validate(skb2, IPPROTO_ICMPV6, ip6_compute_pseudo))
-		goto out;
-
-	err = 0;
-
 	BR_INPUT_SKB_CB(skb)->igmp = 1;
+	mld = (struct mld_msg *)skb_transport_header(skb);
 
-	switch (icmp6_type) {
+	switch (mld->mld_type) {
 	case ICMPV6_MGM_REPORT:
-	    {
-		struct mld_msg *mld;
-		if (!pskb_may_pull(skb2, sizeof(*mld))) {
-			err = -EINVAL;
-			goto out;
-		}
-		mld = (struct mld_msg *)skb_transport_header(skb2);
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca, vid);
 		break;
-	    }
 	case ICMPV6_MLD2_REPORT:
-		err = br_ip6_multicast_mld2_report(br, port, skb2, vid);
+		err = br_ip6_multicast_mld2_report(br, port, skb_trimmed, vid);
 		break;
 	case ICMPV6_MGM_QUERY:
-		err = br_ip6_multicast_query(br, port, skb2, vid);
+		err = br_ip6_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case ICMPV6_MGM_REDUCTION:
-	    {
-		struct mld_msg *mld;
-		if (!pskb_may_pull(skb2, sizeof(*mld))) {
-			err = -EINVAL;
-			goto out;
-		}
-		mld = (struct mld_msg *)skb_transport_header(skb2);
 		br_ip6_multicast_leave_group(br, port, &mld->mld_mca, vid);
-	    }
+		break;
 	}
 
-out:
-	kfree_skb(skb2);
+	if (skb_trimmed && skb_trimmed != skb)
+		kfree_skb(skb_trimmed);
+
 	return err;
 }
 #endif
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cdb939b..09e7236 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4013,6 +4013,44 @@ int skb_checksum_setup(struct sk_buff *skb, bool recalculate)
 }
 EXPORT_SYMBOL(skb_checksum_setup);
 
+int skb_checksum_trimmed(struct sk_buff *skb, unsigned int transport_len,
+			 __sum16(*skb_check_func)(struct sk_buff *skb),
+			 struct sk_buff **skb_trimmed)
+{
+	struct sk_buff *skb_chk = skb;
+	unsigned int offset = skb_transport_offset(skb);
+	int ret = 0;
+
+	__skb_pull(skb, offset);
+
+	/* if there's data beyond the IP packet:
+	 * avoid it in checksum validation by using a trimmed clone
+	 */
+	if (skb->len > transport_len) {
+		skb_chk = skb_clone(skb, GFP_ATOMIC);
+		if (!skb_chk) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		ret = pskb_trim_rcsum(skb_chk, transport_len);
+		if (ret)
+			goto out;
+	}
+
+	ret = skb_check_func(skb_chk);
+	if (ret)
+		goto out;
+
+	if (skb_trimmed)
+		*skb_trimmed = skb_chk;
+
+out:
+	__skb_push(skb, offset);
+	return ret;
+}
+EXPORT_SYMBOL(skb_checksum_trimmed);
+
 void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 {
 	net_warn_ratelimited("%s: received packets cannot be forwarded while LRO is enabled\n",
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a3a697f..3410e56 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1339,6 +1339,158 @@ out:
 }
 EXPORT_SYMBOL(ip_mc_inc_group);
 
+static int ip_mc_check_iphdr(struct sk_buff *skb)
+{
+	const struct iphdr *iph;
+	unsigned int len;
+	unsigned int offset = skb_network_offset(skb) + sizeof(*iph);
+
+	if (!pskb_may_pull(skb, offset))
+		return -EINVAL;
+
+	iph = ip_hdr(skb);
+
+	if (iph->version != 4 || ip_hdrlen(skb) < sizeof(*iph))
+		return -EINVAL;
+
+	offset += ip_hdrlen(skb) - sizeof(*iph);
+
+	if (!pskb_may_pull(skb, offset))
+		return -EINVAL;
+
+	iph = ip_hdr(skb);
+
+	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+		return -EINVAL;
+
+	len = skb_network_offset(skb) + ntohs(iph->tot_len);
+	if (skb->len < len || len < offset)
+		return -EINVAL;
+
+	skb_set_transport_header(skb, offset);
+
+	return 0;
+}
+
+static int ip_mc_check_igmp_reportv3(struct sk_buff *skb)
+{
+	unsigned int len = skb_transport_offset(skb);
+
+	len += sizeof(struct igmpv3_report);
+
+	return pskb_may_pull(skb, len) ? 0 : -EINVAL;
+}
+
+static int ip_mc_check_igmp_query(struct sk_buff *skb)
+{
+	unsigned int len = skb_transport_offset(skb);
+
+	len += sizeof(struct igmphdr);
+	if (skb->len < len)
+		return -EINVAL;
+
+	/* IGMPv{1,2}? */
+	if (skb->len != len) {
+		/* or IGMPv3? */
+		len += sizeof(struct igmpv3_query) - sizeof(struct igmphdr);
+		if (skb->len < len || !pskb_may_pull(skb, len))
+			return -EINVAL;
+	}
+
+	/* RFC2236+RFC3376 (IGMPv2+IGMPv3) require the multicast link layer
+	 * all-systems destination addresses (224.0.0.1) for general queries
+	 */
+	if (!igmp_hdr(skb)->group &&
+	    ip_hdr(skb)->daddr != htonl(INADDR_ALLHOSTS_GROUP))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int ip_mc_check_igmp_msg(struct sk_buff *skb)
+{
+	switch (igmp_hdr(skb)->type) {
+	case IGMP_HOST_LEAVE_MESSAGE:
+	case IGMP_HOST_MEMBERSHIP_REPORT:
+	case IGMPV2_HOST_MEMBERSHIP_REPORT:
+		/* fall through */
+		return 0;
+	case IGMPV3_HOST_MEMBERSHIP_REPORT:
+		return ip_mc_check_igmp_reportv3(skb);
+	case IGMP_HOST_MEMBERSHIP_QUERY:
+		return ip_mc_check_igmp_query(skb);
+	default:
+		return -ENOMSG;
+	}
+}
+
+static inline __sum16 ip_mc_validate_checksum(struct sk_buff *skb)
+{
+	return skb_checksum_simple_validate(skb);
+}
+
+static int __ip_mc_check_igmp(struct sk_buff *skb, struct sk_buff **skb_trimmed)
+
+{
+	struct sk_buff *skb_chk = NULL;
+	unsigned int transport_len;
+	unsigned int len = skb_transport_offset(skb) + sizeof(struct igmphdr);
+	int ret;
+
+	if (!pskb_may_pull(skb, len))
+		return -EINVAL;
+
+	transport_len = ntohs(ip_hdr(skb)->tot_len) - ip_hdrlen(skb);
+
+	if (skb_checksum_trimmed(skb, transport_len,
+				 ip_mc_validate_checksum, &skb_chk))
+		return -EINVAL;
+
+	ret = ip_mc_check_igmp_msg(skb_chk);
+
+	if (!ret && skb_trimmed)
+		*skb_trimmed = skb_chk;
+	else if (skb_chk && skb_chk != skb)
+		kfree_skb(skb_chk);
+
+	return ret;
+}
+
+/**
+ * ip_mc_check_igmp - checks whether this is a sane IGMP packet
+ * @skb: the skb to validate
+ * @skb_trimmed: to store an skb pointer trimmed to IPv4 packet tail (optional)
+ *
+ * Checks whether an IPv4 packet is a valid IGMP packet. If so sets
+ * skb network and transport headers accordingly and returns zero.
+ *
+ * -EINVAL: A broken packet was detected, i.e. it violates some internet
+ *  standard
+ * -ENOMSG: IP header validation succeeded but it is not an IGMP packet.
+ * -ENOMEM: A memory allocation failure happened.
+ *
+ * Optionally, an skb pointer might be provided via skb_trimmed (or set it
+ * to NULL): After parsing an IGMP packet successfully it will point to
+ * an skb which has its tail aligned to the IP packet end. This might
+ * either be the originally provided skb or a trimmed, cloned version if
+ * the skb frame was padded beyond the IP header. A cloned skb allows us
+ * to leave the original skb and its full frame unchanged (which might be
+ * desirable for layer 2 frame jugglers).
+ */
+int ip_mc_check_igmp(struct sk_buff *skb, struct sk_buff **skb_trimmed)
+{
+	int ret = ip_mc_check_iphdr(skb);
+
+	if (ret < 0)
+		return ret;
+
+	if (ip_hdr(skb)->protocol != IPPROTO_IGMP)
+		return -ENOMSG;
+
+	return __ip_mc_check_igmp(skb, skb_trimmed);
+}
+EXPORT_SYMBOL(ip_mc_check_igmp);
+
 /*
  *	Resend IGMP JOIN report; used by netdev notifier.
  */
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index fac1f27..d71cd6b 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2573,6 +2573,184 @@ void ipv6_mc_destroy_dev(struct inet6_dev *idev)
 	write_unlock_bh(&idev->lock);
 }
 
+static int ipv6_mc_check_ip6hdr(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ip6h;
+	unsigned int len;
+	unsigned int offset = skb_network_offset(skb) + sizeof(*ip6h);
+
+	if (!pskb_may_pull(skb, offset))
+		return -EINVAL;
+
+	ip6h = ipv6_hdr(skb);
+
+	if (ip6h->version != 6)
+		return -EINVAL;
+
+	len = offset + ntohs(ip6h->payload_len);
+	if (skb->len < len || len <= offset)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int ipv6_mc_check_exthdrs(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ip6h;
+	unsigned int offset;
+	u8 nexthdr;
+	__be16 frag_off;
+
+	ip6h = ipv6_hdr(skb);
+
+	if (ip6h->nexthdr != IPPROTO_HOPOPTS)
+		return -ENOMSG;
+
+	nexthdr = ip6h->nexthdr;
+	offset = skb_network_offset(skb) + sizeof(*ip6h);
+	offset = ipv6_skip_exthdr(skb, offset, &nexthdr, &frag_off);
+
+	if (offset < 0)
+		return -EINVAL;
+
+	if (nexthdr != IPPROTO_ICMPV6)
+		return -ENOMSG;
+
+	skb_set_transport_header(skb, offset);
+
+	return 0;
+}
+
+static int ipv6_mc_check_mld_reportv2(struct sk_buff *skb)
+{
+	unsigned int len = skb_transport_offset(skb);
+
+	len += sizeof(struct mld2_report);
+
+	return pskb_may_pull(skb, len) ? 0 : -EINVAL;
+}
+
+static int ipv6_mc_check_mld_query(struct sk_buff *skb)
+{
+	struct mld_msg *mld;
+	unsigned int len = skb_transport_offset(skb);
+
+	/* RFC2710+RFC3810 (MLDv1+MLDv2) require link-local source addresses */
+	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL))
+		return -EINVAL;
+
+	len += sizeof(struct mld_msg);
+	if (skb->len < len)
+		return -EINVAL;
+
+	/* MLDv1? */
+	if (skb->len != len) {
+		/* or MLDv2? */
+		len += sizeof(struct mld2_query) - sizeof(struct mld_msg);
+		if (skb->len < len || !pskb_may_pull(skb, len))
+			return -EINVAL;
+	}
+
+	mld = (struct mld_msg *)skb_transport_header(skb);
+
+	/* RFC2710+RFC3810 (MLDv1+MLDv2) require the multicast link layer
+	 * all-nodes destination address (ff02::1) for general queries
+	 */
+	if (ipv6_addr_any(&mld->mld_mca) &&
+	    !ipv6_addr_is_ll_all_nodes(&ipv6_hdr(skb)->daddr))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int ipv6_mc_check_mld_msg(struct sk_buff *skb)
+{
+	struct mld_msg *mld = (struct mld_msg *)skb_transport_header(skb);
+
+	switch (mld->mld_type) {
+	case ICMPV6_MGM_REDUCTION:
+	case ICMPV6_MGM_REPORT:
+		/* fall through */
+		return 0;
+	case ICMPV6_MLD2_REPORT:
+		return ipv6_mc_check_mld_reportv2(skb);
+	case ICMPV6_MGM_QUERY:
+		return ipv6_mc_check_mld_query(skb);
+	default:
+		return -ENOMSG;
+	}
+}
+
+static inline __sum16 ipv6_mc_validate_checksum(struct sk_buff *skb)
+{
+	return skb_checksum_validate(skb, IPPROTO_ICMPV6, ip6_compute_pseudo);
+}
+
+static int __ipv6_mc_check_mld(struct sk_buff *skb,
+			       struct sk_buff **skb_trimmed)
+
+{
+	struct sk_buff *skb_chk = NULL;
+	unsigned int transport_len;
+	unsigned int len = skb_transport_offset(skb) + sizeof(struct mld_msg);
+	int ret;
+
+	if (!pskb_may_pull(skb, len))
+		return -EINVAL;
+
+	transport_len = ipv6_hdr(skb)->payload_len;
+
+	if (skb_checksum_trimmed(skb, transport_len,
+				 ipv6_mc_validate_checksum, &skb_chk))
+		return -EINVAL;
+
+	ret = ipv6_mc_check_mld_msg(skb_chk);
+
+	if (!ret && skb_trimmed)
+		*skb_trimmed = skb_chk;
+	else if (skb_chk && skb_chk != skb)
+		kfree_skb(skb_chk);
+
+	return ret;
+}
+
+/**
+ * ipv6_mc_check_mld - checks whether this is a sane MLD packet
+ * @skb: the skb to validate
+ * @skb_trimmed: to store an skb pointer trimmed to IPv6 packet tail (optional)
+ *
+ * Checks whether an IPv6 packet is a valid MLD packet. If so sets
+ * skb network and transport headers accordingly and returns zero.
+ *
+ * -EINVAL: A broken packet was detected, i.e. it violates some internet
+ *  standard
+ * -ENOMSG: IP header validation succeeded but it is not an IGMP packet.
+ * -ENOMEM: A memory allocation failure happened.
+ *
+ * Optionally, an skb pointer might be provided via skb_trimmed (or set it
+ * to NULL): After parsing an IGMP packet successfully it will point to
+ * an skb which has its tail aligned to the IP packet end. This might
+ * either be the originally provided skb or a trimmed, cloned version if
+ * the skb frame was padded beyond the IP header. A cloned skb allows us
+ * to leave the original skb and its full frame unchanged (which might be
+ * desirable for layer 2 frame jugglers).
+ */
+int ipv6_mc_check_mld(struct sk_buff *skb, struct sk_buff **skb_trimmed)
+{
+	int ret;
+
+	ret = ipv6_mc_check_ip6hdr(skb);
+	if (ret < 0)
+		return ret;
+
+	ret = ipv6_mc_check_exthdrs(skb);
+	if (ret < 0)
+		return ret;
+
+	return __ipv6_mc_check_mld(skb, skb_trimmed);
+}
+EXPORT_SYMBOL(ipv6_mc_check_mld);
+
 #ifdef CONFIG_PROC_FS
 struct igmp6_mc_iter_state {
 	struct seq_net_private p;
-- 
1.7.10.4
