From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 11 Apr 2013 10:53:24 -0700
Message-ID: <1365702804.3887.180.camel@edumazet-glaptop>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
	 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
	 <1362696444.15793.220.camel@edumazet-glaptop>
	 <20130307.181527.390191009324148471.davem@davemloft.net>
	 <20130313232743.GA3686@raven> <1363223884.29475.0.camel@edumazet-glaptop>
	 <20130314144550.GB2512@raven> <1363273531.29475.21.camel@edumazet-glaptop>
	 <1363274946.29475.24.camel@edumazet-glaptop>
	 <1365697961.3887.176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:41139 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964847Ab3DKRx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:53:26 -0400
Received: by mail-pb0-f42.google.com with SMTP id up7so977180pbc.15
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 10:53:26 -0700 (PDT)
In-Reply-To: <1365697961.3887.176.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 09:32 -0700, Eric Dumazet wrote:

> Short update : I do not understand yet why this patch is not working.
> 
> Normally, the reassembled packet should get the dst from the last skb
> (the one completing the packet)...
> 
> I have to make more experiments.

OK I think I've nailed it, please try following patch (I tried it on
net-next, but it should apply on previous kernels)

Thanks !

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9385206..f8f1a87 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -494,9 +494,16 @@ found:
 		qp->q.max_size = skb->len + ihl;
 
 	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
-	    qp->q.meat == qp->q.len)
-		return ip_frag_reasm(qp, prev, dev);
+	    qp->q.meat == qp->q.len) {
+		unsigned long dst_save = skb->_skb_refdst;
 
+		skb->_skb_refdst = 0;
+		err = ip_frag_reasm(qp, prev, dev);
+		skb->_skb_refdst = dst_save;
+		return err;
+	}
+
+	skb_dst_drop(skb);
 	inet_frag_lru_move(&qp->q);
 	return -EINPROGRESS;
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e6e44ce..aac7fa5 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -342,9 +342,17 @@ found:
 	}
 
 	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
-	    fq->q.meat == fq->q.len)
-		return ip6_frag_reasm(fq, prev, dev);
+	    fq->q.meat == fq->q.len) {
+		int err;
+		unsigned long dstsave = skb->_skb_refdst;
+
+		skb->_skb_refdst = 0;
+		err = ip6_frag_reasm(fq, prev, dev);
+		skb->_skb_refdst = dstsave;
+		return err;
+	}
 
+	skb_dst_drop(skb);
 	inet_frag_lru_move(&fq->q);
 	return -1;
 
