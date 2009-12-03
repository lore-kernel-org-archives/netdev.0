From: David Miller <davem@davemloft.net>
Subject: Re: problem with 'net: Partially allow skb destructors to be used
 on receive path'
Date: Wed, 02 Dec 2009 16:00:09 -0800 (PST)
Message-ID: <20091202.160009.232607094.davem@davemloft.net>
References: <20090622145642.GA31280@gondor.apana.org.au>
	<20090623.163743.98163763.davem@davemloft.net>
	<4B16DA68.3040209@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, matthias.fuchs@esd.eu,
	netdev@vger.kernel.org, mma@objectxp.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755745AbZLCAAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 19:00:03 -0500
In-Reply-To: <4B16DA68.3040209@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 02 Dec 2009 22:21:44 +0100

> after a request from Matthias Fuchs regarding the status of this patch in
> 2.6.30-stable, i discovered a problem with the commit in 2.6.30-stable:
> 
> Patch discussion/history: http://patchwork.ozlabs.org/patch/28993/
> 
> The commit in mainline is correct:
 ...
> But the commit in the 2.6.30-stable tree
> 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=172570a224fe66d560c097e48fca15b620c76e72
> 
> has a problem in patching include/net/sock.h:
 ...
> The skb_orphan(skb) in skb_set_owner_w() is missing here.
> 
> Is there any chance to fix that in 2.6.30-stable?

Thanks for catching this.  I hate patch :-/

I'll send a fixup patch to the -stable folks right now.

Thanks again!

net: Fix thinko in backport of skb destructor fix.

As noticed by Oliver Hartkopp, the backport of the
'net: Partially allow skb destructors to be used on receive path'
(2.6.30.y commit: 172570a224fe66d560c097e48fca15b620c76e72,
 upstream commit: d55d87fdff8252d0e2f7c28c2d443aee17e9d70f)
was buggy.

It should have added an skb_orphan() call to both skb_set_owner_w()
and skb_set_owner_r().  Instead it added two calls to skb_set_owner_r().

This fixed it up.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/sock.h b/include/net/sock.h
index 9bc2c83..cda3801 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1223,6 +1223,7 @@ static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 
 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 {
+	skb_orphan(skb);
 	sock_hold(sk);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
@@ -1232,7 +1233,6 @@ static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 {
 	skb_orphan(skb);
-	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sock_rfree;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
