From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH net-next] ipv6: Queue fragments per interface for multicast/link-local
 addresses.
Date: Sat, 16 Feb 2013 14:03:28 +0900
Message-ID: <511F1320.6090309@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58540 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750710Ab3BPFDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 00:03:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should queue fragments for the same link-local address on
different interfaces (e.g. fe80::1%eth0 and fe80::1%eth1) to the
different queue, because of nature of addressing architecture.

Similarly, we should queue fragments for multicast on different
interface to the different queue.  This is okay because
application joins group on speicific interface, and multicast
traffic is expected only on that interface.

CC: Ben Greear <greearb@candelatech.com>
CC: Vlad Yasevich <vyasevic@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h    |    1 +
 net/ipv6/reassembly.c |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 851d541..1af98aa 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -463,6 +463,7 @@ enum ip6_defrag_users {
 struct ip6_create_arg {
 	__be32 id;
 	u32 user;
+	int ifindex;
 	const struct in6_addr *src;
 	const struct in6_addr *dst;
 };
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index bab2c27..83f02f5 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -113,6 +113,7 @@ bool ip6_frag_match(struct inet_frag_queue *q, void *a)
 
 	fq = container_of(q, struct frag_queue, q);
 	return	fq->id == arg->id &&
+		(!arg->ifindex || fq->iif == arg->ifindex) &&
 		fq->user == arg->user &&
 		ipv6_addr_equal(&fq->saddr, arg->src) &&
 		ipv6_addr_equal(&fq->daddr, arg->dst);
@@ -182,13 +183,18 @@ static void ip6_frag_expire(unsigned long data)
 }
 
 static __inline__ struct frag_queue *
-fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6_addr *dst)
+fq_find(struct net *net, __be32 id, int ifindex, const struct in6_addr *src, const struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
 	unsigned int hash;
+	int addr_type = ipv6_addr_type(dst);
 
 	arg.id = id;
+	if (addr_type & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL))
+		arg.ifindex = ifindex;
+	else
+		arg.ifindex = 0;
 	arg.user = IP6_DEFRAG_LOCAL_DELIVER;
 	arg.src = src;
 	arg.dst = dst;
@@ -534,7 +540,8 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_REASMFAILS, evicted);
 
-	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr);
+	fq = fq_find(net, fhdr->identification, skb->dev->ifindex,
+		     &hdr->saddr, &hdr->daddr);
 	if (fq != NULL) {
 		int ret;
 
-- 
1.7.9.5
