From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Fri, 20 Apr 2012 15:27:41 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204201327030.735@wel-95.cs.helsinki.fi>
References: <1334653608.6226.11.camel@edumazet-laptop>  <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>  <1334681204.2472.41.camel@edumazet-glaptop>  <1334698722.2472.71.camel@edumazet-glaptop>  <1334764184.2472.299.camel@edumazet-glaptop>
  <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>  <1334776707.2472.316.camel@edumazet-glaptop>  <1334778707.2472.333.camel@edumazet-glaptop>  <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi>  <1334835018.2395.66.camel@edumazet-glaptop>
  <1334835613.2395.71.camel@edumazet-glaptop>  <alpine.DEB.2.00.1204191443040.735@wel-95.cs.helsinki.fi> <1334839490.2395.160.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1764027159-1334917666=:735"
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	"=?ISO-8859-2?Q?Maciej_=AFenczykowski?=" <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39426 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab2DTM1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 08:27:43 -0400
In-Reply-To: <1334839490.2395.160.camel@edumazet-glaptop>
Content-ID: <alpine.DEB.2.00.1204201445200.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1764027159-1334917666=:735
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1204201428032.735@wel-95.cs.helsinki.fi>

On Thu, 19 Apr 2012, Eric Dumazet wrote:

> On Thu, 2012-04-19 at 14:57 +0300, Ilpo Järvinen wrote:
> 
> > I'm not concerned of the output side, that seems to work because 
> > of the in tcp_retransmit_skb getting rid of the extra first.
> > 
> > The ACK input stuff is more interesting, e.g., this one in 
> > tcp_mark_head_lost:
> > 
> > 	err = tcp_fragment(sk, skb, (packets - oldcnt) * mss, mss);
> > 
> > It splits from TCP_SKB_CB(skb)->seq + (packets - oldcnt) * mss whereas
> > I think the desired point would be: TCP_SKB_CB(skb)->seq + offset_ack + 
> > (packets - oldcnt) * mss?
> > 
> > ...There is similar case in sacktag code too while it's aligning to mss 
> > boundaries in tcp_match_skb_to_sack.
> 
> Hmm yes, so maybe its safer to update TCP_SKB_CB(skb)->seq in
> tcp_tso_acked() (as well as offset_ack) and make needed adjustements in
> tcp_fragment() if we find offset_ack being not null.

I suppose that somewhat works, it helps here a lot that you work only with 
the head skb making lot of cases not possible... I once made something 
similar (before I came up the current shift/merge approach) and ended up 
to this:
  http://www.mail-archive.com/netdev@vger.kernel.org/msg56191.html

...But...

There's another can of worms still it seems.... At least tcp_skb_seglen 
that returns weird results when pcount becomes 1!

...Somewhat related to the pcount == 1 problem, I've long wondered if the 
zeroed gso_size with pcount == 1 is worth keeping in the first place?

However, I kind of liked the neatness in the original approach where ->seq 
does not lie. That would have kept most of stuff very localized because 
each skb is still fully valid and consistent with itself, whereas 
introducing lies adds lots of hidden traps (except for the pcount of 
course, but consistency for it has not been there for some years
already :-)). The tcp_match_skb_to_sack code seems to actually work 
exactly because of this consistency (if I now on the second/third read got 
it right).


-- 
 i.
--8323329-1764027159-1334917666=:735--
