From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: make sure dev is not NULL before call
 ip6_frag_reasm
Date: Tue, 09 May 2017 08:11:48 -0700
Message-ID: <1494342708.7796.81.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1494212964-17861-1-git-send-email-liuhangbin@gmail.com>
         <1494255030.7796.56.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170509134033.GB4649@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35989 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753452AbdEIPL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 11:11:57 -0400
Received: by mail-pg0-f67.google.com with SMTP id 64so278204pgb.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 08:11:57 -0700 (PDT)
In-Reply-To: <20170509134033.GB4649@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 21:40 +0800, Hangbin Liu wrote:

> 
> I saw we checked the dev in this function
> 
> 	dev = skb->dev;
> 	if (dev) {
> 		fq->iif = dev->ifindex;
> 		skb->dev = NULL;
>         }
> 
> and upper caller ipv6_frag_rcv()
> 
> 	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
> 		     skb->dev ? skb->dev->ifindex : 0, ip6_frag_ecn(hdr));
> 
> 
> Apologise that I did not do enough research to make sure whether skb->dev
> could be NULL or not. I will do the check recently and reply when got a
> confirmation.

If really having a NULL dev is possible, I would rather change things
this way, as your fix has side effects.

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e1da5b888cc4901711d573075f8ae4eada7f086e..6c0a2b74ba705cbe13b4e7522d958a9c3d395c29 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -77,7 +77,7 @@ static u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
 static struct inet_frags ip6_frags;
 
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
-			  struct net_device *dev);
+			  struct net_device *dev, struct inet6_dev *idev);
 
 /*
  * callers should be careful not to use the hash value outside the ipfrag_lock
@@ -209,6 +209,7 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src,
 static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			   struct frag_hdr *fhdr, int nhoff)
 {
+	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
 	int offset, end, fragsize;
@@ -223,8 +224,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			((u8 *)(fhdr + 1) - (u8 *)(ipv6_hdr(skb) + 1)));
 
 	if ((unsigned int)end > IPV6_MAXPLEN) {
-		__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-				IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, idev, IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((u8 *)&fhdr->frag_off -
 				   skb_network_header(skb)));
@@ -258,8 +258,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			/* RFC2460 says always send parameter problem in
 			 * this case. -DaveM
 			 */
-			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-					IPSTATS_MIB_INHDRERRORS);
+			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INHDRERRORS);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 					  offsetof(struct ipv6hdr, payload_len));
 			return -1;
@@ -354,7 +353,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		unsigned long orefdst = skb->_skb_refdst;
 
 		skb->_skb_refdst = 0UL;
-		res = ip6_frag_reasm(fq, prev, dev);
+		res = ip6_frag_reasm(fq, prev, dev, idev);
 		skb->_skb_refdst = orefdst;
 		return res;
 	}
@@ -365,8 +364,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 discard_fq:
 	inet_frag_kill(&fq->q, &ip6_frags);
 err:
-	__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-			IPSTATS_MIB_REASMFAILS);
+	__IP6_INC_STATS(net, idev, IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 }
@@ -381,7 +379,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
  *	the last and the first frames arrived and all the bits are here.
  */
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
-			  struct net_device *dev)
+			  struct net_device *dev, struct inet6_dev *idev)
 {
 	struct net *net = container_of(fq->q.net, struct net, ipv6.frags);
 	struct sk_buff *fp, *head = fq->q.fragments;
@@ -505,9 +503,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	skb_postpush_rcsum(head, skb_network_header(head),
 			   skb_network_header_len(head));
 
-	rcu_read_lock();
-	__IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
-	rcu_read_unlock();
+	__IP6_INC_STATS(net, idev, IPSTATS_MIB_REASMOKS);
 	fq->q.fragments = NULL;
 	fq->q.fragments_tail = NULL;
 	return 1;
