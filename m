From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2 net-next] ip: introduce ip_is_fragment helper inline function
Date: Tue, 21 Jun 2011 14:25:02 -0400
Message-ID: <1308680702-2212-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62523 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab1FUSZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 14:25:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are enough instances of this:

    iph->frag_off & htons(IP_MF | IP_OFFSET)

that a helper function is probably warranted.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
v2: fix pre-existing ==0 style issues; change new fcn from int to bool

 drivers/net/bonding/bond_main.c        |    2 +-
 drivers/net/ioc3-eth.c                 |    2 +-
 drivers/net/myri10ge/myri10ge.c        |    2 +-
 drivers/net/s2io.c                     |    2 +-
 drivers/net/sfc/filter.c               |    2 +-
 drivers/net/vxge/vxge-main.c           |    2 +-
 include/net/ip.h                       |    5 +++++
 net/core/dev.c                         |    2 +-
 net/ipv4/ip_input.c                    |    4 ++--
 net/ipv4/ip_output.c                   |    2 +-
 net/ipv4/ipconfig.c                    |    2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c    |    2 +-
 net/ipv4/netfilter/nf_nat_standalone.c |    2 +-
 net/ipv4/xfrm4_policy.c                |    2 +-
 net/netfilter/ipvs/ip_vs_core.c        |    7 +++----
 net/sched/cls_flow.c                   |    4 ++--
 net/sched/cls_rsvp.h                   |    2 +-
 net/sched/sch_choke.c                  |    2 +-
 net/sched/sch_sfq.c                    |    2 +-
 19 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07e866d..5baeb6e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3432,7 +3432,7 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 	int layer4_xor = 0;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
-		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
+		if (!ip_is_fragment(iph) &&
 		    (iph->protocol == IPPROTO_TCP ||
 		     iph->protocol == IPPROTO_UDP)) {
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 32f07f8..318a25a 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -532,7 +532,7 @@ static void ioc3_tcpudp_checksum(struct sk_buff *skb, uint32_t hwsum, int len)
 		return;
 
 	ih = (struct iphdr *) ((char *)eh + ETH_HLEN);
-	if (ih->frag_off & htons(IP_MF | IP_OFFSET))
+	if (ip_is_fragment(ih))
 		return;
 
 	proto = ih->protocol;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 04e10f4..110b61a 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2257,7 +2257,7 @@ myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
 	*ip_hdr = iph;
 	if (iph->protocol != IPPROTO_TCP)
 		return -1;
-	if (iph->frag_off & htons(IP_MF | IP_OFFSET))
+	if (ip_is_fragment(iph))
 		return -1;
 	*hdr_flags |= LRO_TCP;
 	*tcpudp_hdr = (u8 *) (*ip_hdr) + (iph->ihl << 2);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index df0d2c8..5e9d644 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4111,7 +4111,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 			struct tcphdr *th;
 			ip = ip_hdr(skb);
 
-			if ((ip->frag_off & htons(IP_OFFSET|IP_MF)) == 0) {
+			if (!ip_is_fragment(ip)) {
 				th = (struct tcphdr *)(((unsigned char *)ip) +
 						       ip->ihl*4);
 
diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 95a980f..f2fc258 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -652,7 +652,7 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	/* RFS must validate the IP header length before calling us */
 	EFX_BUG_ON_PARANOID(!pskb_may_pull(skb, nhoff + sizeof(*ip)));
 	ip = (const struct iphdr *)(skb->data + nhoff);
-	if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+	if (ip_is_fragment(ip))
 		return -EPROTONOSUPPORT;
 	EFX_BUG_ON_PARANOID(!pskb_may_pull(skb, nhoff + 4 * ip->ihl + 4));
 	ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index e658edd..a018ad8 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -629,7 +629,7 @@ static u32 vxge_get_vpath_no(struct vxgedev *vdev, struct sk_buff *skb)
 
 		ip = ip_hdr(skb);
 
-		if ((ip->frag_off & htons(IP_OFFSET|IP_MF)) == 0) {
+		if (!ip_is_fragment(ip)) {
 			th = (struct tcphdr *)(((unsigned char *)ip) +
 					ip->ihl*4);
 
diff --git a/include/net/ip.h b/include/net/ip.h
index e9ea7c7..d603cd3 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -250,6 +250,11 @@ int ip_decrease_ttl(struct iphdr *iph)
 	return --iph->ttl;
 }
 
+static inline bool ip_is_fragment(const struct iphdr *iph)
+{
+	return (iph->frag_off & htons(IP_MF | IP_OFFSET)) != 0;
+}
+
 static inline
 int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index b3f52d2..5bb00d5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2532,7 +2532,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 			goto done;
 
 		ip = (const struct iphdr *) (skb->data + nhoff);
-		if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+		if (ip_is_fragment(ip))
 			ip_proto = 0;
 		else
 			ip_proto = ip->protocol;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index c8f48ef..073a9b0 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -165,7 +165,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == dev->ifindex) &&
 		    net_eq(sock_net(sk), dev_net(dev))) {
-			if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
+			if (ip_is_fragment(ip_hdr(skb))) {
 				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
 					return 1;
 			}
@@ -256,7 +256,7 @@ int ip_local_deliver(struct sk_buff *skb)
 	 *	Reassemble IP fragments.
 	 */
 
-	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
+	if (ip_is_fragment(ip_hdr(skb))) {
 		if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER))
 			return 0;
 	}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 98af369..529a6f6 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -489,7 +489,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
-		    (iph->frag_off & htons(IP_MF|IP_OFFSET)) ||
+		    ip_is_fragment(iph) ||
 		    skb_cloned(skb))
 			goto slow_path;
 
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ab7e554..ae93dd5 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -932,7 +932,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 		goto drop;
 
 	/* Fragments are not supported */
-	if (h->frag_off & htons(IP_OFFSET | IP_MF)) {
+	if (ip_is_fragment(h)) {
 		if (net_ratelimit())
 			printk(KERN_ERR "DHCP/BOOTP: Ignoring fragmented "
 			       "reply.\n");
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index f3a9b42..9bb1b8a 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -82,7 +82,7 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 #endif
 #endif
 	/* Gather fragments. */
-	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
+	if (ip_is_fragment(ip_hdr(skb))) {
 		enum ip_defrag_users user = nf_ct_defrag_user(hooknum, skb);
 		if (nf_ct_ipv4_gather_frags(skb, user))
 			return NF_STOLEN;
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 7317bdf..42c0e45 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -88,7 +88,7 @@ nf_nat_fn(unsigned int hooknum,
 
 	/* We never see fragments: conntrack defrags on pre-routing
 	   and local-out, and nf_nat_out protects post-routing. */
-	NF_CT_ASSERT(!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)));
+	NF_CT_ASSERT(!ip_is_fragment(ip_hdr(skb)));
 
 	ct = nf_ct_get(skb, &ctinfo);
 	/* Can't track?  It's not due to stress, or conntrack would
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 981e43e..fc5368a 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -117,7 +117,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
 
-	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET))) {
+	if (!ip_is_fragment(iph)) {
 		switch (iph->protocol) {
 		case IPPROTO_UDP:
 		case IPPROTO_UDPLITE:
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index bfa808f..c965428 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -852,7 +852,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	*related = 1;
 
 	/* reassemble IP fragments */
-	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
+	if (ip_is_fragment(ip_hdr(skb))) {
 		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
@@ -1156,8 +1156,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 	} else
 #endif
-		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_MF|IP_OFFSET) &&
-			     !pp->dont_defrag)) {
+		if (unlikely(ip_is_fragment(ip_hdr(skb)) && !pp->dont_defrag)) {
 			if (ip_vs_gather_frags(skb,
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
@@ -1310,7 +1309,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	*related = 1;
 
 	/* reassemble IP fragments */
-	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
+	if (ip_is_fragment(ip_hdr(skb))) {
 		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 8ec0139..34533a5 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -121,7 +121,7 @@ static u32 flow_get_proto_src(struct sk_buff *skb)
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ip_hdr(skb);
-		if (iph->frag_off & htons(IP_MF | IP_OFFSET))
+		if (ip_is_fragment(iph))
 			break;
 		poff = proto_ports_offset(iph->protocol);
 		if (poff >= 0 &&
@@ -163,7 +163,7 @@ static u32 flow_get_proto_dst(struct sk_buff *skb)
 		if (!pskb_network_may_pull(skb, sizeof(*iph)))
 			break;
 		iph = ip_hdr(skb);
-		if (iph->frag_off & htons(IP_MF | IP_OFFSET))
+		if (ip_is_fragment(iph))
 			break;
 		poff = proto_ports_offset(iph->protocol);
 		if (poff >= 0 &&
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 402c44b..ed691b1 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -167,7 +167,7 @@ restart:
 	dst = &nhptr->daddr;
 	protocol = nhptr->protocol;
 	xprt = ((u8 *)nhptr) + (nhptr->ihl<<2);
-	if (nhptr->frag_off & htons(IP_MF | IP_OFFSET))
+	if (ip_is_fragment(nhptr))
 		return -1;
 #endif
 
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 06afbae..3422b25 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -181,7 +181,7 @@ static bool choke_match_flow(struct sk_buff *skb1,
 		    ip1->saddr != ip2->saddr || ip1->daddr != ip2->daddr)
 			return false;
 
-		if ((ip1->frag_off | ip2->frag_off) & htons(IP_MF | IP_OFFSET))
+		if (ip_is_fragment(ip1) | ip_is_fragment(ip2))
 			ip_proto = 0;
 		off1 += ip1->ihl * 4;
 		off2 += ip2->ihl * 4;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b6ea6af..4536ee6 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -157,7 +157,7 @@ static unsigned int sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 		iph = ip_hdr(skb);
 		h = (__force u32)iph->daddr;
 		h2 = (__force u32)iph->saddr ^ iph->protocol;
-		if (iph->frag_off & htons(IP_MF | IP_OFFSET))
+		if (ip_is_fragment(iph))
 			break;
 		poff = proto_ports_offset(iph->protocol);
 		if (poff >= 0 &&
-- 
1.7.4.4

