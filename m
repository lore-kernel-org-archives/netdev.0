From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and MSS
Date: Wed, 29 Sep 2004 15:46:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929154645.4e8987d2.davem@davemloft.net>
References: <Pine.NEB.4.33.0409291830440.3434-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409291830440.3434-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 18:38:52 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> net/ipv4/ip_output.c:ip_queue_xmit():
> 
>         mtu = dst_pmtu(&rt->u.dst);
>         if (skb->len > mtu && (sk->sk_route_caps & NETIF_F_TSO)) {
>                 unsigned int hlen;
> 
>                 /* Hack zone: all this must be done by TCP. */
>                 hlen = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
>                 skb_shinfo(skb)->tso_size = mtu - hlen;
>                 skb_shinfo(skb)->tso_segs =
>                         (skb->len - hlen + skb_shinfo(skb)->tso_size - 1)/
>                                 skb_shinfo(skb)->tso_size - 1;
>         }
> 
> Does the "Hack zone" comment indicate this case has already been
> considered?

The "Hack zone" comment is saying that we should be doing this
work in tcp_transmit_skb() but cannot because ip_queue_xmit()
is where a route is hooked up if sk->sk_dst_cache is NULL.

If you are on ethernet using different MTU's, shouldn't you be
getting ICMP messages back when trying to communicate with that
host which will decrease the PMTU of the path?  TCP's MSS is
determined in terms of this, so I can't see what the issue is.

Note I would like to move this "Hack zone" code up into tcp_transmit_skb()
for another reason, it would make the TSO stuff in tcp_skb_cb[] redundant.
