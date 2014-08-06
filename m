From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH net-next] tcp: md5: check md5 signature without socket
 lock
Date: Wed, 6 Aug 2014 22:49:02 +0400
Message-ID: <20140806224902.180d8bbee02b9f4ce82cbe5c@qrator.net>
References: <20140805025452.1a5bec4ad0d0c5a30a22a589@qrator.net>
	<20140805.162703.362629415553579077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:55574 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756103AbaHFStH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 14:49:07 -0400
Received: by mail-la0-f47.google.com with SMTP id mc6so2676697lab.34
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 11:49:05 -0700 (PDT)
In-Reply-To: <20140805.162703.362629415553579077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Aug 2014 16:27:03 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> > +#ifdef CONFIG_TCP_MD5SIG
> > +	/*
> > +	 * We really want to reject the packet as early as possible
> > +	 * if:
> > +	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
> > +	 *  o There is an MD5 option and we're not expecting one
> > +	 */
> > +	if (tcp_v4_inbound_md5_hash(sk, skb))
> > +		goto discard_and_relse;
> > +#endif

> 
> The original ordering seemed very much intentional, as per the comment.
> 
> You need to either make your locking change without disturbing this
> ordering, or proprosed first and separately that the early check
> should be changed.
> 
> Also, you really shouldn't just move the early md5 check _after_ the
> TCP_ESTABLISHED fast path, and keep the comment there as well.  The
> comment makes no sense any longer if the MD5 check happens after the
> TCP_ESTABLISHED fast path, right?
> 
> I'm not applying this, sorry.
> 

It seems your arguments are based on the assumption that I moved md5 signature
check down the tcp processing chain. But I did exactly the opposite, md5 is
checked earlier in this patch.

I moved tcp_v{4,6}_inbound_md5_hash from tcp_v{4,6}_do_rcv to tcp_v{4,6}_rcv,
and tcp_v{4,6}_do_rcv is always called from tcp_v{4,6}_rcv (either directly or
via sk_backlog). 

For ipv4 it looks something like this (and ipv6 is almost the same):

tcp_v4_rcv(skb):
... /* various checks like pkt size, checksum and so on */
	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
... /* some more checks */
	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
...
+	if (tcp_v4_inbound_md5_hash(sk, skb))
+		goto discard_and_relse;
	nf_reset(skb);

	if (sk_filter(sk, skb))
		goto discard_and_relse;

	sk_mark_napi_id(sk, skb);
	skb->dev = NULL;

	bh_lock_sock_nested(sk);
	if ( /* NET_DMA, sk_backlog and tcp_prequeue checks */ )
        	ret = tcp_v4_do_rcv(sk, skb);
...
        bh_unlock_sock(sk);
	sock_put(sk);
        return ret;

tcp_v4_do_rcv(sk, skb):
-	if (tcp_v4_inbound_md5_hash(sk, skb))
-		goto discard_and_relse;
... /* do further processing */

So, speaking of ordering, only nf_reset, sk_filter, sk_mark_napi_id,
skb->dev=NULL, sk_backlogging, tcp_prequeue and NET_DMA things would be done
after tcp_v4_inbound_md5_hash (instead of before) if this patch is applied. 
I don't see anything bad about that, correct me if I'm wrong.

I could also move tcp_v4_inbound_md5_hash before xfrm4_policy_check or after
sk_filter: I don't have any strong arguments here, so I am ok to resubmit
with other ordering of these calls.
