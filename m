From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCHv3 net-next 2/2] net: Export IGMP/MLD message validation code
Date: Sat,  2 May 2015 14:01:07 +0200
Message-ID: <1430568067-6912-3-git-send-email-linus.luessing@c0d3.blue>
References: <1430568067-6912-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:57094 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbbEBMBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 08:01:17 -0400
In-Reply-To: <1430568067-6912-1-git-send-email-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, the IGMP and MLD message validation functions are move=
d
from the bridge code to IPv4/IPv6 multicast files. Some small
refactoring was done to enhance readibility and to iron out some
differences in behaviour between the IGMP and MLD parsing code (e.g. th=
e
skb-cloning of MLD messages is now only done if necessary, just like th=
e
IGMP part always did).

=46inally, these IGMP and MLD message validation functions are exported=
 so
that not only the bridge can use it but batman-adv later, too.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---
 include/linux/igmp.h      |    1 +
 include/linux/skbuff.h    |    3 +
 include/net/addrconf.h    |    1 +
 net/bridge/br_multicast.c |  218 +++++++------------------------------=
--------
 net/core/skbuff.c         |   87 ++++++++++++++++++
 net/ipv4/igmp.c           |  162 +++++++++++++++++++++++++++++++++
 net/ipv6/Makefile         |    1 +
 net/ipv6/mcast_snoop.c    |  213 +++++++++++++++++++++++++++++++++++++=
++++++
 8 files changed, 498 insertions(+), 188 deletions(-)
 create mode 100644 net/ipv6/mcast_snoop.c

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 2c677af..193ad48 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -130,5 +130,6 @@ extern void ip_mc_unmap(struct in_device *);
 extern void ip_mc_remap(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
+int ip_mc_check_igmp(struct sk_buff *skb, struct sk_buff **skb_trimmed=
);
=20
 #endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 66e374d..cd34010 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3417,6 +3417,9 @@ static inline void skb_checksum_none_assert(const=
 struct sk_buff *skb)
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
=20
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
+struct sk_buff *skb_checksum_trimmed(struct sk_buff *skb,
+				     unsigned int transport_len,
+				     __sum16(*skb_chkf)(struct sk_buff *skb));
=20
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
+int ipv6_mc_check_mld(struct sk_buff *skb, struct sk_buff **skb_trimme=
d);
 void addrconf_dad_failure(struct inet6_ifaddr *ifp);
=20
 bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr=
 *group,
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b52f4cb..2d69d5c 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -975,9 +975,6 @@ static int br_ip4_multicast_igmp3_report(struct net=
_bridge *br,
 	int err =3D 0;
 	__be32 group;
=20
-	if (!pskb_may_pull(skb, sizeof(*ih)))
-		return -EINVAL;
-
 	ih =3D igmpv3_report_hdr(skb);
 	num =3D ntohs(ih->ngrec);
 	len =3D sizeof(*ih);
@@ -1248,25 +1245,14 @@ static int br_ip4_multicast_query(struct net_br=
idge *br,
 			max_delay =3D 10 * HZ;
 			group =3D 0;
 		}
-	} else {
-		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query))) {
-			err =3D -EINVAL;
-			goto out;
-		}
-
+	} else if (skb->len >=3D sizeof(*ih3)) {
 		ih3 =3D igmpv3_query_hdr(skb);
 		if (ih3->nsrcs)
 			goto out;
=20
 		max_delay =3D ih3->code ?
 			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE) : 1;
-	}
-
-	/* RFC2236+RFC3376 (IGMPv2+IGMPv3) require the multicast link layer
-	 * all-systems destination addresses (224.0.0.1) for general queries
-	 */
-	if (!group && iph->daddr !=3D htonl(INADDR_ALLHOSTS_GROUP)) {
-		err =3D -EINVAL;
+	} else {
 		goto out;
 	}
=20
@@ -1329,12 +1315,6 @@ static int br_ip6_multicast_query(struct net_bri=
dge *br,
 	    (port && port->state =3D=3D BR_STATE_DISABLED))
 		goto out;
=20
-	/* RFC2710+RFC3810 (MLDv1+MLDv2) require link-local source addresses =
*/
-	if (!(ipv6_addr_type(&ip6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
-		err =3D -EINVAL;
-		goto out;
-	}
-
 	if (skb->len =3D=3D sizeof(*mld)) {
 		if (!pskb_may_pull(skb, sizeof(*mld))) {
 			err =3D -EINVAL;
@@ -1358,14 +1338,6 @@ static int br_ip6_multicast_query(struct net_bri=
dge *br,
=20
 	is_general_query =3D group && ipv6_addr_any(group);
=20
-	/* RFC2710+RFC3810 (MLDv1+MLDv2) require the multicast link layer
-	 * all-nodes destination address (ff02::1) for general queries
-	 */
-	if (is_general_query && !ipv6_addr_is_ll_all_nodes(&ip6h->daddr)) {
-		err =3D -EINVAL;
-		goto out;
-	}
-
 	if (is_general_query) {
 		saddr.proto =3D htons(ETH_P_IPV6);
 		saddr.u.ip6 =3D ip6h->saddr;
@@ -1557,66 +1529,22 @@ static int br_multicast_ipv4_rcv(struct net_bri=
dge *br,
 				 struct sk_buff *skb,
 				 u16 vid)
 {
-	struct sk_buff *skb2 =3D skb;
-	const struct iphdr *iph;
+	struct sk_buff *skb_trimmed =3D NULL;
 	struct igmphdr *ih;
-	unsigned int len;
-	unsigned int offset;
 	int err;
=20
-	/* We treat OOM as packet loss for now. */
-	if (!pskb_may_pull(skb, sizeof(*iph)))
-		return -EINVAL;
-
-	iph =3D ip_hdr(skb);
-
-	if (iph->ihl < 5 || iph->version !=3D 4)
-		return -EINVAL;
-
-	if (!pskb_may_pull(skb, ip_hdrlen(skb)))
-		return -EINVAL;
-
-	iph =3D ip_hdr(skb);
+	err =3D ip_mc_check_igmp(skb, &skb_trimmed);
=20
-	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
-		return -EINVAL;
-
-	if (iph->protocol !=3D IPPROTO_IGMP) {
-		if (!ipv4_is_local_multicast(iph->daddr))
+	if (err =3D=3D -ENOMSG) {
+		if (!ipv4_is_local_multicast(ip_hdr(skb)->daddr))
 			BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;
 		return 0;
+	} else if (err < 0) {
+		return err;
 	}
=20
-	len =3D ntohs(iph->tot_len);
-	if (skb->len < len || len < ip_hdrlen(skb))
-		return -EINVAL;
-
-	if (skb->len > len) {
-		skb2 =3D skb_clone(skb, GFP_ATOMIC);
-		if (!skb2)
-			return -ENOMEM;
-
-		err =3D pskb_trim_rcsum(skb2, len);
-		if (err)
-			goto err_out;
-	}
-
-	len -=3D ip_hdrlen(skb2);
-	offset =3D skb_network_offset(skb2) + ip_hdrlen(skb2);
-	__skb_pull(skb2, offset);
-	skb_reset_transport_header(skb2);
-
-	err =3D -EINVAL;
-	if (!pskb_may_pull(skb2, sizeof(*ih)))
-		goto out;
-
-	if (skb_checksum_simple_validate(skb2))
-		goto out;
-
-	err =3D 0;
-
 	BR_INPUT_SKB_CB(skb)->igmp =3D 1;
-	ih =3D igmp_hdr(skb2);
+	ih =3D igmp_hdr(skb);
=20
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_REPORT:
@@ -1625,21 +1553,19 @@ static int br_multicast_ipv4_rcv(struct net_bri=
dge *br,
 		err =3D br_ip4_multicast_add_group(br, port, ih->group, vid);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
-		err =3D br_ip4_multicast_igmp3_report(br, port, skb2, vid);
+		err =3D br_ip4_multicast_igmp3_report(br, port, skb_trimmed, vid);
 		break;
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		err =3D br_ip4_multicast_query(br, port, skb2, vid);
+		err =3D br_ip4_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
 		br_ip4_multicast_leave_group(br, port, ih->group, vid);
 		break;
 	}
=20
-out:
-	__skb_push(skb2, offset);
-err_out:
-	if (skb2 !=3D skb)
-		kfree_skb(skb2);
+	if (skb_trimmed)
+		kfree_skb(skb_trimmed);
+
 	return err;
 }
=20
@@ -1649,126 +1575,42 @@ static int br_multicast_ipv6_rcv(struct net_br=
idge *br,
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
+	struct sk_buff *skb_trimmed =3D NULL;
+	struct mld_msg *mld;
 	int err;
=20
-	if (!pskb_may_pull(skb, sizeof(*ip6h)))
-		return -EINVAL;
+	err =3D ipv6_mc_check_mld(skb, &skb_trimmed);
=20
-	ip6h =3D ipv6_hdr(skb);
-
-	/*
-	 * We're interested in MLD messages only.
-	 *  - Version is 6
-	 *  - MLD has always Router Alert hop-by-hop option
-	 *  - But we do not support jumbrograms.
-	 */
-	if (ip6h->version !=3D 6)
-		return 0;
-
-	/* Prevent flooding this packet if there is no listener present */
-	if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
-		BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;
-
-	if (ip6h->nexthdr !=3D IPPROTO_HOPOPTS ||
-	    ip6h->payload_len =3D=3D 0)
-		return 0;
-
-	len =3D ntohs(ip6h->payload_len) + sizeof(*ip6h);
-	if (skb->len < len)
-		return -EINVAL;
-
-	nexthdr =3D ip6h->nexthdr;
-	offset =3D ipv6_skip_exthdr(skb, sizeof(*ip6h), &nexthdr, &frag_off);
-
-	if (offset < 0 || nexthdr !=3D IPPROTO_ICMPV6)
+	if (err =3D=3D -ENOMSG) {
+		if (!ipv6_addr_is_ll_all_nodes(&ipv6_hdr(skb)->daddr))
+			BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;
 		return 0;
-
-	/* Okay, we found ICMPv6 header */
-	skb2 =3D skb_clone(skb, GFP_ATOMIC);
-	if (!skb2)
-		return -ENOMEM;
-
-	err =3D -EINVAL;
-	if (!pskb_may_pull(skb2, offset + sizeof(struct icmp6hdr)))
-		goto out;
-
-	len -=3D offset - skb_network_offset(skb2);
-
-	__skb_pull(skb2, offset);
-	skb_reset_transport_header(skb2);
-	skb_postpull_rcsum(skb2, skb_network_header(skb2),
-			   skb_network_header_len(skb2));
-
-	icmp6_type =3D icmp6_hdr(skb2)->icmp6_type;
-
-	switch (icmp6_type) {
-	case ICMPV6_MGM_QUERY:
-	case ICMPV6_MGM_REPORT:
-	case ICMPV6_MGM_REDUCTION:
-	case ICMPV6_MLD2_REPORT:
-		break;
-	default:
-		err =3D 0;
-		goto out;
-	}
-
-	/* Okay, we found MLD message. Check further. */
-	if (skb2->len > len) {
-		err =3D pskb_trim_rcsum(skb2, len);
-		if (err)
-			goto out;
-		err =3D -EINVAL;
+	} else if (err < 0) {
+		return err;
 	}
=20
-	ip6h =3D ipv6_hdr(skb2);
-
-	if (skb_checksum_validate(skb2, IPPROTO_ICMPV6, ip6_compute_pseudo))
-		goto out;
-
-	err =3D 0;
-
 	BR_INPUT_SKB_CB(skb)->igmp =3D 1;
+	mld =3D (struct mld_msg *)skb_transport_header(skb);
=20
-	switch (icmp6_type) {
+	switch (mld->mld_type) {
 	case ICMPV6_MGM_REPORT:
-	    {
-		struct mld_msg *mld;
-		if (!pskb_may_pull(skb2, sizeof(*mld))) {
-			err =3D -EINVAL;
-			goto out;
-		}
-		mld =3D (struct mld_msg *)skb_transport_header(skb2);
 		BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;
 		err =3D br_ip6_multicast_add_group(br, port, &mld->mld_mca, vid);
 		break;
-	    }
 	case ICMPV6_MLD2_REPORT:
-		err =3D br_ip6_multicast_mld2_report(br, port, skb2, vid);
+		err =3D br_ip6_multicast_mld2_report(br, port, skb_trimmed, vid);
 		break;
 	case ICMPV6_MGM_QUERY:
-		err =3D br_ip6_multicast_query(br, port, skb2, vid);
+		err =3D br_ip6_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case ICMPV6_MGM_REDUCTION:
-	    {
-		struct mld_msg *mld;
-		if (!pskb_may_pull(skb2, sizeof(*mld))) {
-			err =3D -EINVAL;
-			goto out;
-		}
-		mld =3D (struct mld_msg *)skb_transport_header(skb2);
 		br_ip6_multicast_leave_group(br, port, &mld->mld_mca, vid);
-	    }
+		break;
 	}
=20
-out:
-	kfree_skb(skb2);
+	if (skb_trimmed)
+		kfree_skb(skb_trimmed);
+
 	return err;
 }
 #endif
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3cfff2a..1e4278a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4030,6 +4030,93 @@ int skb_checksum_setup(struct sk_buff *skb, bool=
 recalculate)
 }
 EXPORT_SYMBOL(skb_checksum_setup);
=20
+/**
+ * skb_checksum_maybe_trim - maybe trims the given skb
+ * @skb: the skb to check
+ * @transport_len: the data length beyond the network header
+ *
+ * Checks whether the given skb has data beyond the given transport le=
ngth.
+ * If so, returns a cloned skb trimmed to this transport length.
+ * Otherwise returns the provided skb. Returns NULL in error cases
+ * (e.g. transport_len exceeds skb length or out-of-memory).
+ *
+ * Caller needs to set the skb transport header and release the return=
ed skb.
+ * Provided skb is consumed.
+ */
+static struct sk_buff *skb_checksum_maybe_trim(struct sk_buff *skb,
+					       unsigned int transport_len)
+{
+	struct sk_buff *skb_chk;
+	unsigned int len =3D skb_transport_offset(skb) + transport_len;
+	int ret;
+
+	if (skb->len < len) {
+		kfree_skb(skb);
+		return NULL;
+	} else if (skb->len =3D=3D len) {
+		return skb;
+	}
+
+	skb_chk =3D skb_clone(skb, GFP_ATOMIC);
+	kfree_skb(skb);
+
+	if (!skb_chk)
+		return NULL;
+
+	ret =3D pskb_trim_rcsum(skb_chk, len);
+	if (ret) {
+		kfree_skb(skb_chk);
+		return NULL;
+	}
+
+	return skb_chk;
+}
+
+/**
+ * skb_checksum_trimmed - validate checksum of an skb
+ * @skb: the skb to check
+ * @transport_len: the data length beyond the network header
+ * @skb_chkf: checksum function to use
+ *
+ * Applies the given checksum function skb_chkf to the provided skb.
+ * Returns a checked and maybe trimmed skb. Returns NULL on error.
+ *
+ * If the skb has data beyond the given transport length, then a
+ * trimmed & cloned skb is checked and returned.
+ *
+ * Caller needs to set the skb transport header and release the return=
ed skb.
+ * Provided skb is consumed.
+ */
+struct sk_buff *skb_checksum_trimmed(struct sk_buff *skb,
+				     unsigned int transport_len,
+				     __sum16(*skb_chkf)(struct sk_buff *skb))
+{
+	struct sk_buff *skb_chk;
+	unsigned int offset =3D skb_transport_offset(skb);
+	int ret;
+
+	skb_chk =3D skb_checksum_maybe_trim(skb, transport_len);
+	if (!skb_chk)
+		return NULL;
+
+	if (!pskb_may_pull(skb_chk, offset)) {
+		kfree_skb(skb_chk);
+		return NULL;
+	}
+
+	__skb_pull(skb_chk, offset);
+	ret =3D skb_chkf(skb_chk);
+	__skb_push(skb_chk, offset);
+
+	if (ret) {
+		kfree_skb(skb_chk);
+		return NULL;
+	}
+
+	return skb_chk;
+}
+EXPORT_SYMBOL(skb_checksum_trimmed);
+
 void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 {
 	net_warn_ratelimited("%s: received packets cannot be forwarded while =
LRO is enabled\n",
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a3a697f..651cdf6 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1339,6 +1339,168 @@ out:
 }
 EXPORT_SYMBOL(ip_mc_inc_group);
=20
+static int ip_mc_check_iphdr(struct sk_buff *skb)
+{
+	const struct iphdr *iph;
+	unsigned int len;
+	unsigned int offset =3D skb_network_offset(skb) + sizeof(*iph);
+
+	if (!pskb_may_pull(skb, offset))
+		return -EINVAL;
+
+	iph =3D ip_hdr(skb);
+
+	if (iph->version !=3D 4 || ip_hdrlen(skb) < sizeof(*iph))
+		return -EINVAL;
+
+	offset +=3D ip_hdrlen(skb) - sizeof(*iph);
+
+	if (!pskb_may_pull(skb, offset))
+		return -EINVAL;
+
+	iph =3D ip_hdr(skb);
+
+	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+		return -EINVAL;
+
+	len =3D skb_network_offset(skb) + ntohs(iph->tot_len);
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
+	unsigned int len =3D skb_transport_offset(skb);
+
+	len +=3D sizeof(struct igmpv3_report);
+
+	return pskb_may_pull(skb, len) ? 0 : -EINVAL;
+}
+
+static int ip_mc_check_igmp_query(struct sk_buff *skb)
+{
+	unsigned int len =3D skb_transport_offset(skb);
+
+	len +=3D sizeof(struct igmphdr);
+	if (skb->len < len)
+		return -EINVAL;
+
+	/* IGMPv{1,2}? */
+	if (skb->len !=3D len) {
+		/* or IGMPv3? */
+		len +=3D sizeof(struct igmpv3_query) - sizeof(struct igmphdr);
+		if (skb->len < len || !pskb_may_pull(skb, len))
+			return -EINVAL;
+	}
+
+	/* RFC2236+RFC3376 (IGMPv2+IGMPv3) require the multicast link layer
+	 * all-systems destination addresses (224.0.0.1) for general queries
+	 */
+	if (!igmp_hdr(skb)->group &&
+	    ip_hdr(skb)->daddr !=3D htonl(INADDR_ALLHOSTS_GROUP))
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
+static int __ip_mc_check_igmp(struct sk_buff *skb, struct sk_buff **sk=
b_trimmed)
+
+{
+	struct sk_buff *skb_chk;
+	unsigned int transport_len;
+	unsigned int len =3D skb_transport_offset(skb) + sizeof(struct igmphd=
r);
+	int ret;
+
+	transport_len =3D ntohs(ip_hdr(skb)->tot_len) - ip_hdrlen(skb);
+
+	skb_get(skb);
+	skb_chk =3D skb_checksum_trimmed(skb, transport_len,
+				       ip_mc_validate_checksum);
+	if (!skb_chk)
+		return -EINVAL;
+
+	if (!pskb_may_pull(skb_chk, len)) {
+		kfree_skb(skb_chk);
+		return -EINVAL;
+	}
+
+	ret =3D ip_mc_check_igmp_msg(skb_chk);
+	if (ret) {
+		kfree_skb(skb_chk);
+		return ret;
+	}
+
+	if (skb_trimmed)
+		*skb_trimmed =3D skb_chk;
+	else
+		kfree_skb(skb_chk);
+
+	return 0;
+}
+
+/**
+ * ip_mc_check_igmp - checks whether this is a sane IGMP packet
+ * @skb: the skb to validate
+ * @skb_trimmed: to store an skb pointer trimmed to IPv4 packet tail (=
optional)
+ *
+ * Checks whether an IPv4 packet is a valid IGMP packet. If so sets
+ * skb network and transport headers accordingly and returns zero.
+ *
+ * -EINVAL: A broken packet was detected, i.e. it violates some intern=
et
+ *  standard
+ * -ENOMSG: IP header validation succeeded but it is not an IGMP packe=
t.
+ * -ENOMEM: A memory allocation failure happened.
+ *
+ * Optionally, an skb pointer might be provided via skb_trimmed (or se=
t it
+ * to NULL): After parsing an IGMP packet successfully it will point t=
o
+ * an skb which has its tail aligned to the IP packet end. This might
+ * either be the originally provided skb or a trimmed, cloned version =
if
+ * the skb frame had data beyond the IP packet. A cloned skb allows us
+ * to leave the original skb and its full frame unchanged (which might=
 be
+ * desirable for layer 2 frame jugglers).
+ *
+ * The caller needs to release a reference count from any returned skb=
_trimmed.
+ */
+int ip_mc_check_igmp(struct sk_buff *skb, struct sk_buff **skb_trimmed=
)
+{
+	int ret =3D ip_mc_check_iphdr(skb);
+
+	if (ret < 0)
+		return ret;
+
+	if (ip_hdr(skb)->protocol !=3D IPPROTO_IGMP)
+		return -ENOMSG;
+
+	return __ip_mc_check_igmp(skb, skb_trimmed);
+}
+EXPORT_SYMBOL(ip_mc_check_igmp);
+
 /*
  *	Resend IGMP JOIN report; used by netdev notifier.
  */
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2e8c061..0f3f199 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -48,4 +48,5 @@ obj-$(subst m,y,$(CONFIG_IPV6)) +=3D inet6_hashtables=
=2Eo
=20
 ifneq ($(CONFIG_IPV6),)
 obj-$(CONFIG_NET_UDP_TUNNEL) +=3D ip6_udp_tunnel.o
+obj-y +=3D mcast_snoop.o
 endif
diff --git a/net/ipv6/mcast_snoop.c b/net/ipv6/mcast_snoop.c
new file mode 100644
index 0000000..1a2cbc1
--- /dev/null
+++ b/net/ipv6/mcast_snoop.c
@@ -0,0 +1,213 @@
+/* Copyright (C) 2010: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ * Copyright (C) 2015: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+ *
+ *
+ * Based on the MLD support added to br_multicast.c by YOSHIFUJI Hidea=
ki.
+ */
+
+#include <linux/skbuff.h>
+#include <net/ipv6.h>
+#include <net/mld.h>
+#include <net/addrconf.h>
+#include <net/ip6_checksum.h>
+
+static int ipv6_mc_check_ip6hdr(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ip6h;
+	unsigned int len;
+	unsigned int offset =3D skb_network_offset(skb) + sizeof(*ip6h);
+
+	if (!pskb_may_pull(skb, offset))
+		return -EINVAL;
+
+	ip6h =3D ipv6_hdr(skb);
+
+	if (ip6h->version !=3D 6)
+		return -EINVAL;
+
+	len =3D offset + ntohs(ip6h->payload_len);
+	if (skb->len < len || len <=3D offset)
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
+	ip6h =3D ipv6_hdr(skb);
+
+	if (ip6h->nexthdr !=3D IPPROTO_HOPOPTS)
+		return -ENOMSG;
+
+	nexthdr =3D ip6h->nexthdr;
+	offset =3D skb_network_offset(skb) + sizeof(*ip6h);
+	offset =3D ipv6_skip_exthdr(skb, offset, &nexthdr, &frag_off);
+
+	if (offset < 0)
+		return -EINVAL;
+
+	if (nexthdr !=3D IPPROTO_ICMPV6)
+		return -ENOMSG;
+
+	skb_set_transport_header(skb, offset);
+
+	return 0;
+}
+
+static int ipv6_mc_check_mld_reportv2(struct sk_buff *skb)
+{
+	unsigned int len =3D skb_transport_offset(skb);
+
+	len +=3D sizeof(struct mld2_report);
+
+	return pskb_may_pull(skb, len) ? 0 : -EINVAL;
+}
+
+static int ipv6_mc_check_mld_query(struct sk_buff *skb)
+{
+	struct mld_msg *mld;
+	unsigned int len =3D skb_transport_offset(skb);
+
+	/* RFC2710+RFC3810 (MLDv1+MLDv2) require link-local source addresses =
*/
+	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL))
+		return -EINVAL;
+
+	len +=3D sizeof(struct mld_msg);
+	if (skb->len < len)
+		return -EINVAL;
+
+	/* MLDv1? */
+	if (skb->len !=3D len) {
+		/* or MLDv2? */
+		len +=3D sizeof(struct mld2_query) - sizeof(struct mld_msg);
+		if (skb->len < len || !pskb_may_pull(skb, len))
+			return -EINVAL;
+	}
+
+	mld =3D (struct mld_msg *)skb_transport_header(skb);
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
+	struct mld_msg *mld =3D (struct mld_msg *)skb_transport_header(skb);
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
+	return skb_checksum_validate(skb, IPPROTO_ICMPV6, ip6_compute_pseudo)=
;
+}
+
+static int __ipv6_mc_check_mld(struct sk_buff *skb,
+			       struct sk_buff **skb_trimmed)
+
+{
+	struct sk_buff *skb_chk =3D NULL;
+	unsigned int transport_len;
+	unsigned int len =3D skb_transport_offset(skb) + sizeof(struct mld_ms=
g);
+	int ret;
+
+	transport_len =3D ntohs(ipv6_hdr(skb)->payload_len);
+	transport_len -=3D skb_transport_offset(skb) - sizeof(struct ipv6hdr)=
;
+
+	skb_get(skb);
+	skb_chk =3D skb_checksum_trimmed(skb, transport_len,
+				       ipv6_mc_validate_checksum);
+	if (!skb_chk)
+		return -EINVAL;
+
+	if (!pskb_may_pull(skb_chk, len)) {
+		kfree_skb(skb_chk);
+		return -EINVAL;
+	}
+
+	ret =3D ipv6_mc_check_mld_msg(skb_chk);
+	if (ret) {
+		kfree_skb(skb_chk);
+		return ret;
+	}
+
+	if (skb_trimmed)
+		*skb_trimmed =3D skb_chk;
+	else
+		kfree_skb(skb_chk);
+
+	return 0;
+}
+
+/**
+ * ipv6_mc_check_mld - checks whether this is a sane MLD packet
+ * @skb: the skb to validate
+ * @skb_trimmed: to store an skb pointer trimmed to IPv6 packet tail (=
optional)
+ *
+ * Checks whether an IPv6 packet is a valid MLD packet. If so sets
+ * skb network and transport headers accordingly and returns zero.
+ *
+ * -EINVAL: A broken packet was detected, i.e. it violates some intern=
et
+ *  standard
+ * -ENOMSG: IP header validation succeeded but it is not an MLD packet=
=2E
+ * -ENOMEM: A memory allocation failure happened.
+ *
+ * Optionally, an skb pointer might be provided via skb_trimmed (or se=
t it
+ * to NULL): After parsing an MLD packet successfully it will point to
+ * an skb which has its tail aligned to the IP packet end. This might
+ * either be the originally provided skb or a trimmed, cloned version =
if
+ * the skb frame had data beyond the IP packet. A cloned skb allows us
+ * to leave the original skb and its full frame unchanged (which might=
 be
+ * desirable for layer 2 frame jugglers).
+ *
+ * The caller needs to release a reference count from any returned skb=
_trimmed.
+ */
+int ipv6_mc_check_mld(struct sk_buff *skb, struct sk_buff **skb_trimme=
d)
+{
+	int ret;
+
+	ret =3D ipv6_mc_check_ip6hdr(skb);
+	if (ret < 0)
+		return ret;
+
+	ret =3D ipv6_mc_check_exthdrs(skb);
+	if (ret < 0)
+		return ret;
+
+	return __ipv6_mc_check_mld(skb, skb_trimmed);
+}
+EXPORT_SYMBOL(ipv6_mc_check_mld);
--=20
1.7.10.4
