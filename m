From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_shift_skb_data uses wrong mss in non-gso case?
Date: Tue, 24 Aug 2010 11:59:07 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1008241008250.31124@melkinpaasi.cs.helsinki.fi>
References: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35219@US01XMB01.org.nasdaqomx.com> <AANLkTi=ygaa_fV4SwaLY2gP9H+Nn54QdXcGXkfGukSCD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696250871-1217264925-1282634067=:31124"
Cc: Robert Evans <robert.evans@nasdaqomx.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41941 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab0HXI7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 04:59:09 -0400
In-Reply-To: <AANLkTi=ygaa_fV4SwaLY2gP9H+Nn54QdXcGXkfGukSCD@mail.gmail.com>
Content-ID: <alpine.DEB.2.00.1008241154540.31318@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-1217264925-1282634067=:31124
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1008241154541.31318@wel-95.cs.helsinki.fi>

On Mon, 23 Aug 2010, Jesse Brandeburg wrote:

> On Tue, Aug 17, 2010 at 3:35 PM, Robert Evans
> <robert.evans@nasdaqomx.com> wrote:
> > Hello all,
> >
> > In reading through the latest SACK code introduced by 832d11c, I have noticed
> > that for the in_sack case tcp_shift_skb will take mss = tcp_skb_seglen(skb).
> > This seems to be wrong since the queue might contain small packets (f.e.
> > TCP_NODELAY). If the collapse succeeds, the resulting skb will have an
> > arbitrarily small gso_size equal to the original skb length.
> 
> yeah, gso_size really should never be == skb->length, because then it
> implies you're offloading a frame to be segmented with no segmentable
> data.

What makes you think we'd get such segments? Point here is verify that the 
segments to be combined into a single skb share segment size, small or 
large doesn't make any difference in that respect as both were counted as 
a packet (or pcount worth of packets) w.r.t. cwnd consumption.

> > 8ed88d4:net/ipv4/tcp_input.c
> >   1506         in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
> >   1507                   !before(end_seq, TCP_SKB_CB(skb)->end_seq);
> >   1508
> >   1509         if (in_sack) {
> >   1510                 len = skb->len;
> >   1511                 pcount = tcp_skb_pcount(skb);
> >   1512                 mss = tcp_skb_seglen(skb);     /* possibly wrong? */
> >   1513
> >   1514                 /* TODO: Fix DSACKs to not fragment already SACKed and w
> >   1514 e can
> >   1515                  * drop this restriction as unnecessary
> >   1516                  */
> >   1517                 if (mss != tcp_skb_seglen(prev))
> >   1518                         goto fallback;
> >   1519         } else {
> >
> > This ends up being troublesome if the segment is later retransmitted and the
> > device driver has trouble with very small gso_size (e1000e seems to be an
> > example).
> 
> I bet lots of other drivers will have issue with this too.
>
> > Is the small gso_size the correct and/or desired behavior?  Or am I missing
> > something else that prevents this from being a problem?
> 
> I believe that this is invalid for the stack to do, Ilpo, Herbert?
> what do you think?

The point of this code is to work with already SACKed segments (or to 
become SACKed from the current ACK), only TCP code is interested in them 
anymore. They should not be sent again to wire unless SACK reneging occurs 
but then retransmission code should deal with this just fine:

        if (skb->len > cur_mss) {
                if (tcp_fragment(sk, skb, cur_mss, cur_mss))
                        return -ENOMEM; /* We'll try again later. */
        } else {
                int oldpcount = tcp_skb_pcount(skb);

                if (unlikely(oldpcount > 1)) {
                        tcp_init_tso_segs(sk, skb, cur_mss);
                        tcp_adjust_pcount(sk, skb, oldpcount - tcp_skb_pcount(skb));
                }
        }


-- 
 i.
---696250871-1217264925-1282634067=:31124--
