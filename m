From: John Heffner <jheffner@psc.edu>
Subject: TSO and MSS
Date: Wed, 29 Sep 2004 18:38:52 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409291830440.3434-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While playing with TSO I noticed that two machines on the same ethernet
with dissimilar MTUs don't work with TSO enabled.  One could argue the
incorrecness of this situation, but I think it's still important.  Looks
like the segment size is only set from the path MTU, and the TCP MSS is
ignored.  Here's the offending code.

net/ipv4/ip_output.c:ip_queue_xmit():

        mtu = dst_pmtu(&rt->u.dst);
        if (skb->len > mtu && (sk->sk_route_caps & NETIF_F_TSO)) {
                unsigned int hlen;

                /* Hack zone: all this must be done by TCP. */
                hlen = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
                skb_shinfo(skb)->tso_size = mtu - hlen;
                skb_shinfo(skb)->tso_segs =
                        (skb->len - hlen + skb_shinfo(skb)->tso_size - 1)/
                                skb_shinfo(skb)->tso_size - 1;
        }

Does the "Hack zone" comment indicate this case has already been
considered?

Thanks,
  -John
