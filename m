From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/3] fix skb_morph to preserve skb->sk and
 skb->destructor pointers
Date: Tue, 5 Nov 2013 15:47:55 +0100
Message-ID: <20131105144755.GA2438@minipsycho.orion>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-4-git-send-email-jiri@resnulli.us>
 <1383660372.4291.134.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org, fw@strlen.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:44237 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab3KEOsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 09:48:01 -0500
Received: by mail-ea0-f173.google.com with SMTP id g10so4246807eak.32
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 06:48:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1383660372.4291.134.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 05, 2013 at 03:06:12PM CET, eric.dumazet@gmail.com wrote:
>On Tue, 2013-11-05 at 12:02 +0100, Jiri Pirko wrote:
>> Currently __skb_clone sets skb->sk and skb->destructor to NULL. This is
>> not right for skb_morph use case because skb->sk may be previously
>> set (e. g. by xt_TPROXY).
>> 
>> Also, during skb_morph the destructor should not be called. It might be
>> previously set, e. g. by xt_TPROXY to sock_edemux, and that would cause
>> put sk while skb is still in flight.
>
>truesize alert. You should add some documentation that skb_morph()
>must not be used in transmit path.
>
>Its not clear to be how this can happen.
>
>skb_morph() being used only from ipv4 defrag (or ipv6 reassembly).

nod

>
>Maybe the problem could be fixed by doing this defrag _before_ setting
>skb->sk ?

skb->sk is set for exmaple in xt_TPROXY that is before reassemly is
done, because reassembly is done after all the netfilter code pass the
skb through. I do not see how this can be changed in the way you are
suggesting.


>
>Also, I would prefer you find a way to put all this logic inside
>skb_morph() instead of adding such complexity in this already complex
>code, I fear the compiler will generate slower code with your patch on
>fast path.
>
>Maybe something as simple as following (untested) patch ?

I had very similar patch prepared. But I did not like it so I chose the
other way. I'm more or less okay with doing this this way though...

>
>Note that the truesize concern might need some care.
>
>diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>index 3735fad5616e..afabfd6ef341 100644
>--- a/net/core/skbuff.c
>+++ b/net/core/skbuff.c
>@@ -793,18 +793,28 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
> 
> /**
>  *	skb_morph	-	morph one skb into another
>- *	@dst: the skb to receive the contents
>+ *	@skb: the skb to receive the contents
>  *	@src: the skb to supply the contents
>  *
>  *	This is identical to skb_clone except that the target skb is
>- *	supplied by the user.
>+ *	supplied by the user, and that we keep target skb destructor in place,
>+ *	meaning this can not be used in transmit path, as skb->truesize might
>+ *	change.
>  *
>  *	The target skb is returned upon exit.
>  */
>-struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
>+struct sk_buff *skb_morph(struct sk_buff *skb, struct sk_buff *src)
> {
>-	skb_release_all(dst);
>-	return __skb_clone(dst, src);
>+	struct sock *save_sk = skb->sk;
>+	void (*save_destructor)(struct sk_buff *) = skb->destructor;
>+
>+	skb->sk = NULL;
>+	skb->destructor = NULL;
>+	skb_release_all(skb);
>+	__skb_clone(skb, src);
>+	skb->sk = save_sk;
>+	skb->destructor = save_destructor;
>+	return skb;
> }
> EXPORT_SYMBOL_GPL(skb_morph);
> 
>
>
