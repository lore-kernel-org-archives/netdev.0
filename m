From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 10/11] net: frags: Add VRF device index to cache and lookup
Date: Thu, 13 Aug 2015 14:59:09 -0600
Message-ID: <1439499551-90231-11-git-send-email-dsa@cumulusnetworks.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33575 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbbHMVAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:00:12 -0400
Received: by iods203 with SMTP id s203so65585267iod.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 14:00:12 -0700 (PDT)
In-Reply-To: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fragmentation cache uses information from the IP header to reassemble
packets. That information can be duplicated across VRFs -- same source
and destination addresses, protocol and id. Handle fragmentation with
VRFs by adding the VRF device index to entries in the cache and the
lookup arg.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/ip_fragment.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index d96722ae8979..15762e758861 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -48,6 +48,7 @@
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/inet_ecn.h>
+#include <net/vrf.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -77,6 +78,7 @@ struct ipq {
 	u8		ecn; /* RFC3168 support */
 	u16		max_df_size; /* largest frag with DF set seen */
 	int             iif;
+	int             vif;   /* VRF device index */
 	unsigned int    rid;
 	struct inet_peer *peer;
 };
@@ -99,6 +101,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 struct ip4_create_arg {
 	struct iphdr *iph;
 	u32 user;
+	int vif;
 };
 
 static unsigned int ipqhashfn(__be16 id, __be32 saddr, __be32 daddr, u8 prot)
@@ -127,7 +130,8 @@ static bool ip4_frag_match(const struct inet_frag_queue *q, const void *a)
 		qp->saddr == arg->iph->saddr &&
 		qp->daddr == arg->iph->daddr &&
 		qp->protocol == arg->iph->protocol &&
-		qp->user == arg->user;
+		qp->user == arg->user &&
+		qp->vif == arg->vif;
 }
 
 static void ip4_frag_init(struct inet_frag_queue *q, const void *a)
@@ -144,6 +148,7 @@ static void ip4_frag_init(struct inet_frag_queue *q, const void *a)
 	qp->ecn = ip4_frag_ecn(arg->iph->tos);
 	qp->saddr = arg->iph->saddr;
 	qp->daddr = arg->iph->daddr;
+	qp->vif = arg->vif;
 	qp->user = arg->user;
 	qp->peer = sysctl_ipfrag_max_dist ?
 		inet_getpeer_v4(net->ipv4.peers, arg->iph->saddr, 1) : NULL;
@@ -244,7 +249,8 @@ static void ip_expire(unsigned long arg)
 /* Find the correct entry in the "incomplete datagrams" queue for
  * this IP datagram, and create new one, if nothing is found.
  */
-static struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
+static struct ipq *ip_find(struct net *net, struct iphdr *iph,
+			   u32 user, int vif)
 {
 	struct inet_frag_queue *q;
 	struct ip4_create_arg arg;
@@ -252,6 +258,7 @@ static struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 
 	arg.iph = iph;
 	arg.user = user;
+	arg.vif = vif;
 
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
@@ -648,14 +655,15 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 /* Process an incoming IP datagram fragment. */
 int ip_defrag(struct sk_buff *skb, u32 user)
 {
+	struct net_device *dev = skb->dev ? : skb_dst(skb)->dev;
+	int vif = vrf_master_ifindex_rcu(dev);
+	struct net *net = dev_net(dev);
 	struct ipq *qp;
-	struct net *net;
 
-	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
 	/* Lookup (or create) queue header */
-	qp = ip_find(net, ip_hdr(skb), user);
+	qp = ip_find(net, ip_hdr(skb), user, vif);
 	if (qp) {
 		int ret;
 
-- 
2.3.2 (Apple Git-55)
