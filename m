From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: problem with 'net: Partially allow skb destructors to be used
 on receive path'
Date: Wed, 02 Dec 2009 22:21:44 +0100
Message-ID: <4B16DA68.3040209@hartkopp.net>
References: <20090622122525.GA24481@gondor.apana.org.au>	<4A3F8AC6.2070803@hartkopp.net>	<20090622145642.GA31280@gondor.apana.org.au> <20090623.163743.98163763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au,
	Matthias Fuchs <matthias.fuchs@esd.eu>, netdev@vger.kernel.org,
	Michel Marti <mma@objectxp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:44215 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbZLBVVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 16:21:41 -0500
In-Reply-To: <20090623.163743.98163763.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 22 Jun 2009 22:56:42 +0800
> 
>> On Mon, Jun 22, 2009 at 03:44:38PM +0200, Oliver Hartkopp wrote:
>>> I tried to apply the patch on 2.6.30 also and only got some offsets (as expected).
>> Thanks for testing!
>>
>>> Do you think, it's a good idea to queue this up for 2.6.30-stable?
>> If it's OK with Dave then it's OK with me.
> 
> I've applied Herbert's patch, thanks everyone!
> 
> I'll queue it up for -stable too.

Hello Dave,

after a request from Matthias Fuchs regarding the status of this patch in
2.6.30-stable, i discovered a problem with the commit in 2.6.30-stable:

Patch discussion/history: http://patchwork.ozlabs.org/patch/28993/

The commit in mainline is correct:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=d55d87fdff8252d0e2f7c28c2d443aee17e9d70f

--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1250,6 +1250,7 @@ static inline int sk_has_allocations(const struct sock *sk)

 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 {
+       skb_orphan(skb);
        skb->sk = sk;
        skb->destructor = sock_wfree;
        /*
@@ -1262,6 +1263,7 @@ static inline void skb_set_owner_w(struct sk_buff *skb,
struct sock *sk)

 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 {
+       skb_orphan(skb);
        skb->sk = sk;
        skb->destructor = sock_rfree;
        atomic_add(skb->truesize, &sk->sk_rmem_alloc);



But the commit in the 2.6.30-stable tree

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=172570a224fe66d560c097e48fca15b620c76e72

has a problem in patching include/net/sock.h:


--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1231,6 +1231,8 @@ static inline void skb_set_owner_w(struct sk_buff *skb,
struct sock *sk)

 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 {
+       skb_orphan(skb);
+       skb_orphan(skb);
        skb->sk = sk;
        skb->destructor = sock_rfree;
        atomic_add(skb->truesize, &sk->sk_rmem_alloc);


The skb_orphan(skb) in skb_set_owner_w() is missing here.

Is there any chance to fix that in 2.6.30-stable?

Thanks,
Oliver

