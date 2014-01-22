From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] null pointer dereference in tcp_gso_segment()
Date: Wed, 22 Jan 2014 14:18:45 -0800
Message-ID: <1390429125.27806.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87r47z7kqo.fsf@natisbad.org>
	 <1390427824.27806.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8761pb7jzq.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f170.google.com ([209.85.161.170]:43961 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbaAVWSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 17:18:48 -0500
Received: by mail-gg0-f170.google.com with SMTP id l4so64739ggi.29
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 14:18:48 -0800 (PST)
In-Reply-To: <8761pb7jzq.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-22 at 23:02 +0100, Arnaud Ebalard wrote:
> Hi Eric,
> 
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> >> Unless there is an assumption I missed somewhere in the function, the
> >> problem may occur during the first round of the loop, because (unlike
> >> the 'while' condition does at line 21) skb->next is not checked against
> >> null at lines 17 above before it is passed to tcp_hdr() at line 18.
> >> 
> >> To be honest, I am asking because I am not familiar w/ the code and it
> >> is somewhat old so I wonder why noone got hit before. AFAICT,
> >> f4c50d990dcf ([NET]: Add software TSOv4) added TSOv4 support in 2006 via
> >> introduction of tcp_tso_segmen() (with the same kind of deref but
> >> possibly different assumptions) which was more recently modified via
> >> 28850dc7c7 (net: tcp: move GRO/GSO functions to tcp_offload) to become
> >> tcp_gso_segment().
> >> 
> >> David, can you confirm the analysis and possibly comment on the
> >> conditions needed for the bug to manifest?
> >
> > A gso packet contains at least 2 segments.
> 
> By whom / where is it enforced?

For example, tcp_gso_segment() does the following check :

if (unlikely(skb->len <= mss))
	goto out;

If there was one segment, then skb->len should also be smaller than mss

Since TCP stack seemed to be the provider of the packet in your stack
trace, check tcp_set_skb_tso_segs()
