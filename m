From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix TCP early demux
Date: Fri, 27 Jul 2012 23:34:33 +0200
Message-ID: <1343424873.2626.13112.camel@edumazet-glaptop>
References: <1343406220.2626.13092.camel@edumazet-glaptop>
	 <20120727.134713.1437322148321890583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:60473 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab2G0Vei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 17:34:38 -0400
Received: by wgbfm10 with SMTP id fm10so958291wgb.1
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 14:34:37 -0700 (PDT)
In-Reply-To: <20120727.134713.1437322148321890583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-27 at 13:47 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 27 Jul 2012 18:23:40 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > commit 92101b3b2e317 (ipv4: Prepare for change of rt->rt_iif encoding.)
> > invalidated TCP early demux, because rx_dst_ifindex is not properly
> > initialized and checked.
> > 
> > Also remove the use of inet_iif(skb) in favor or skb->skb_iif
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

Thanks David

IPv6 part is screwed because of the bogus dst_check(dst, 0)

(and missing code that was moved out from tcp_rcv_established() to
tcp_v4_do_rcv() : I was wondering if we could make it generic to move it
back to tcp_rcv_established()) :

                if (sk->sk_rx_dst) {
                        struct dst_entry *dst = sk->sk_rx_dst;
                        if (dst->ops->check(dst, 0) == NULL) {
                                dst_release(dst);
                                sk->sk_rx_dst = NULL;
                        }
                }
                if (unlikely(sk->sk_rx_dst == NULL)) {
                        sk->sk_rx_dst = dst_clone(skb_dst(skb));
                        inet_sk(sk)->rx_dst_ifindex = inet_iif(skb);
                }


IPv6 wants a cookie here, not 0

I wonder why cookie is not stored in dst, and must be stored outside of
it ?

We could then use :
                if (sk->sk_rx_dst) {
                        struct dst_entry *dst = sk->sk_rx_dst;
                        if (dst->ops->check(dst) == NULL) {
                                dst_release(dst);
                                sk->sk_rx_dst = NULL;
                        }
                }
