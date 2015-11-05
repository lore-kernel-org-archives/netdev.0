From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Thu, 5 Nov 2015 17:28:42 +0100
Message-ID: <CAHmME9ptruMW4MFZ1q3=tgTANro1_CdwnCWS5O_0_WwbFKgUAw@mail.gmail.com>
References: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
	<20151105121501.GA5776@gondor.apana.org.au>
	<CAHmME9pP1E64CCc7+XW8X1duYGQZdYj9s_r8UNq3KMh6xey_Hw@mail.gmail.com>
	<1446738967.4184.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446738967.4184.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 5, 2015 at 4:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> It is a performance benefit only if you use the helpers from
> net/core/tso.c as some drivers already do.
>
> Otherwise, calling the skb_gso_segment() from your driver has no gain
> compared to the one done from core networking stack.

Interesting, okay. It looks like it will be, in fact, useful to be
able to call skb_gso_segment() from my own driver. The reasoning is as
follows:

As mentioned, I receive packets on ndo_start_xmit, "do something to
them with function magic()", and then push them out of a UDP socket
using udp_tunnel_xmit_skb. There appears to be significant overhead
from calling udp_tunnel_xmit_skb over and over. What I'd really like
to do is pass the NETIF_F_GSO_SOFTWARE-provided super packet directly
to udp_tunnel_xmit_skb, but in fact the magic() function mentioned
above needs to work on an entire MTU-sized IP packet, not a a super
packet. So, instead, what it's looking like is:

1. Set NETIF_F_GSO_SOFTWARE to receive super packets.
2. For each super packet, break it down using skb_gso_segment().
     2a. For each segmented packet, "do my magic() function"
3. After having done the magic() to each of the segmented packets, I
*repack the results* into a new super packet. I then pass that super
packet to udp_tunnel_xmit_skb().

Is this approach a real possibility?

If so, it seems like the best way to get GSO-like qualities out of
udp_tunnel_xmit_skb. I've successfully done (1) and (2), following the
example of validate_xmit_skb() from net/core/dev.c. Now I need to
figure out how to do (3). Hopefully I'll find some nice convenience
functions for this...

Jason
