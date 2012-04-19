From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Thu, 19 Apr 2012 14:57:08 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204191443040.735@wel-95.cs.helsinki.fi>
References: <1334653608.6226.11.camel@edumazet-laptop>  <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>  <1334681204.2472.41.camel@edumazet-glaptop>  <1334698722.2472.71.camel@edumazet-glaptop>  <1334764184.2472.299.camel@edumazet-glaptop>
  <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>  <1334776707.2472.316.camel@edumazet-glaptop>  <1334778707.2472.333.camel@edumazet-glaptop>  <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi>  <1334835018.2395.66.camel@edumazet-glaptop>
 <1334835613.2395.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-28474088-1334836628=:735"
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	"=?ISO-8859-2?Q?Maciej_=AFenczykowski?=" <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50876 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab2DSL5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 07:57:09 -0400
In-Reply-To: <1334835613.2395.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-28474088-1334836628=:735
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Thu, 19 Apr 2012, Eric Dumazet wrote:

> On Thu, 2012-04-19 at 13:30 +0200, Eric Dumazet wrote:
> > On Thu, 2012-04-19 at 14:10 +0300, Ilpo Järvinen wrote:
> > 
> > > Now that you have non-zero offset_ack, are the tcp_fragment() callsites 
> > > safe and working? ...I'm mostly worried about tcp_mark_head_lost which 
> > > does some assumptions about tp->snd_una and TCP_SKB_CB(skb)->seq, however, 
> > > also other fragmenting does not preserve offset_ack properly (which might 
> > > not be end of world though)?
> > 
> > Good point, I'll take a look.
> 
> Hmm, the only point this could matter is if a packet is retransmitted.
>
> For other packets, offset_ack = 0 (default value on skb allocation)
> 
> And tcp_retransmit_skb() first call tcp_trim_head(sk, skb) if needed so
> tcp_fragment() is called with == 0
> 
>         if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
>                 if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
>                         BUG();
>                 if (tcp_trim_head(sk, skb))
>                         return -ENOMEM;
>         }
> 
> ...
> if (skb->len > cur_mss) {
> 	if (tcp_fragment(sk, skb, cur_mss, cur_mss))
> 
> 
> 
> I could add a BUG_ON(offset_ack == 0) to make sure this assertion is
> true.

If you end up putting something like that make sure you use WARN_ON 
instead as this surely isn't fatal enough to warrant full stop of the
box :-).

> What do you think ?

I'm not concerned of the output side, that seems to work because 
of the in tcp_retransmit_skb getting rid of the extra first.

The ACK input stuff is more interesting, e.g., this one in 
tcp_mark_head_lost:

	err = tcp_fragment(sk, skb, (packets - oldcnt) * mss, mss);

It splits from TCP_SKB_CB(skb)->seq + (packets - oldcnt) * mss whereas
I think the desired point would be: TCP_SKB_CB(skb)->seq + offset_ack + 
(packets - oldcnt) * mss?

...There is similar case in sacktag code too while it's aligning to mss 
boundaries in tcp_match_skb_to_sack.

-- 
 i.
--8323329-28474088-1334836628=:735--
