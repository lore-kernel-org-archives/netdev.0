From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG] null pointer dereference in tcp_gso_segment()
Date: Sun, 26 Jan 2014 00:54:38 +0100
Message-ID: <87r47v4ny9.fsf@natisbad.org>
References: <87r47z7kqo.fsf@natisbad.org>
	<1390427824.27806.36.camel@edumazet-glaptop2.roam.corp.google.com>
	<8761pb7jzq.fsf@natisbad.org>
	<1390429125.27806.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:45798 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbaAYXzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jan 2014 18:55:12 -0500
Received: from smtp.natisbad.org (unknown [IPv6:2a01:e35:139b:9f90:221:70ff:fe55:8f78])
	by smtp2-g21.free.fr (Postfix) with ESMTP id 294474B007C
	for <netdev@vger.kernel.org>; Sun, 26 Jan 2014 00:54:56 +0100 (CET)
In-Reply-To: <1390429125.27806.40.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 22 Jan 2014 14:18:45 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2014-01-22 at 23:02 +0100, Arnaud Ebalard wrote:
>> Hi Eric,
>> 
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> 
>> >> Unless there is an assumption I missed somewhere in the function, the
>> >> problem may occur during the first round of the loop, because (unlike
>> >> the 'while' condition does at line 21) skb->next is not checked against
>> >> null at lines 17 above before it is passed to tcp_hdr() at line 18.
>> >> 
>> >> To be honest, I am asking because I am not familiar w/ the code and it
>> >> is somewhat old so I wonder why noone got hit before. AFAICT,
>> >> f4c50d990dcf ([NET]: Add software TSOv4) added TSOv4 support in 2006 via
>> >> introduction of tcp_tso_segmen() (with the same kind of deref but
>> >> possibly different assumptions) which was more recently modified via
>> >> 28850dc7c7 (net: tcp: move GRO/GSO functions to tcp_offload) to become
>> >> tcp_gso_segment().
>> >> 
>> >> David, can you confirm the analysis and possibly comment on the
>> >> conditions needed for the bug to manifest?
>> >
>> > A gso packet contains at least 2 segments.
>> 
>> By whom / where is it enforced?
>
> For example, tcp_gso_segment() does the following check :
>
> if (unlikely(skb->len <= mss))
> 	goto out;
>
> If there was one segment, then skb->len should also be smaller than
> mss

Thanks for the explanation and sorry for the delay, I only just found
the time to take a look at the code. For the discussion, a simplified
version of tcp_gso_segment() is:


  th = tcp_hdr(skb);
  thlen = th->doff * 4;

  ...

  __skb_pull(skb, thlen);

  ...

  mss = tcp_skb_mss(skb);
  if (unlikely(skb->len <= mss))
 	goto out;

  ...

  segs = skb_segment(skb, features);
  skb = segs;

  ...

		skb = skb->next;
		th = tcp_hdr(skb);   <- bug occurs here


So the logic seems to be that if we pass the mss test (i.e. skb->len >
mss), then skb_segment() *should* indeed create at least two segments
from the skb. I took a look at skb_segment() but the code is !trivial,
i.e. it is not obvious that there is no way for the function to deliver
a sk_buff skb w/ a NULL skb->next. Eric, I guess you or Herbert are
familiar enough w/ the code to tell. But before checking that, your lead
below is interesting ...

> Since TCP stack seemed to be the provider of the packet in your stack
> trace, check tcp_set_skb_tso_segs()

It is indeed called in tcp_write_xmit() which appears in the
backtrace. That function you point has an interesting property:

 static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
 	/* Make sure we own this skb before messing gso_size/gso_segs */
 	WARN_ON_ONCE(skb_cloned(skb));
 
 	if (skb->len <= mss_now || skb->ip_summed == CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
 		skb_shinfo(skb)->gso_segs = 1;
 		skb_shinfo(skb)->gso_size = 0;
 		skb_shinfo(skb)->gso_type = 0;
 	} else {
 		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
 		skb_shinfo(skb)->gso_size = mss_now;
 		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
 	}
 }
 
If it is called with skb->len <= mss, the resulting skb will be modified
so that you will then have skb_shinfo(skb)->gso_size set to 0,
i.e. skb->len > skb_shinfo(skb)->gso_size.

In tcp_gso_segment(), mss is grabbed using tcp_skb_mss() which simply
returns skb_shinfo(skb)->gso_size. That function comes with a comment
indicating that it provides the mss only when tcp_skb_pcount() > 1,
i.e when skb_shinfo(skb)->gso_segs > 1. Said differently, one should
never call tcp_skb_mss() after tcp_set_skb_tso_segs() has been called on
a skb *unless* she tests explicitly that tcp_skb_pcount() > 1.

This test (tcp_skb_pcount() > 1) is not done in tcp_gso_segment() before
getting the mss value w/ tcp_skb_mss(). I may have missed a test
somewhere in a caller but I do not see why tcp_gso_segment() makes the
assumption it can safely call tcp_skb_mss().

Cheers,

a+


   
