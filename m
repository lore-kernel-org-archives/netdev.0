From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Routing loops & TTL tracking with tunnel devices
Date: Mon, 16 Nov 2015 21:14:51 +0100
Message-ID: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>, therbert@google.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:53117 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbbKPUOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 15:14:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

A few tunnel devices, like geneve or vxlan, are using
udp_tunnel_xmit_skb, or related functions for transmitting packets,
and are doing the usual FIB lookup to get the dst entry. I see a lot
of code like this:

                if (rt->dst.dev == dev) {
                        netdev_dbg(dev, "circular route to %pI4\n",
                                   &dst->sin.sin_addr.s_addr);
                        dev->stats.collisions++;
                        goto rt_tx_error;
                }

This one is from vxlan, but there are other similar blocks elsewhere.
The basic idea is "am I about to send this packet to my own device?"

This is a bit crude. For starters, two interfaces could be pointed at
each other, bouncing the packet back and forth indefinitely, causing
the feared routing loop. Hopefully as more headers got tacked on,
allocations would eventually fail, and the queen would be saved.

But what about in devices for which self-routing might actually be
useful? For example, let's say that if an incoming skb is headed for
dst X, it gets encapsulated and sent to dst A, and for dst Y it gets
encapsulated and sent to dst B, and for dst Z it gets encapsulated and
sent to dst C. I can imagine situations in which setting A==Y and B==Z
might be useful to do multiple levels of encapsulation on one device,
so that skbs headed for dst X get sent to dst C, but with intermediate
transformations of dst A and dst B.

This isn't merely theoretical. I'm working on a driver right now that
could benefit from this.

So, in implementing this, the question of avoiding routing loops comes
into play. The most straight forward way to do this is to use a TTL
value that's decreased. But we have a problem. A packet sent to dst X
that is encapsulated and sent to dst A will have a ttl calculated for
its journey to dst A. How do we preserve TTLs across multiple
traversals of the networking stack? We can't simply stay with the TTL
of the packet when it comes in, because it's tunnel destination might
require a different TTL. The best thing would be to have a "tunnel
TTL" value as part of skb->cb, except the cb gets overwritten when
traversing the networking stack. The best thing I can think of is some
other member of sk_buff, but I don't see any that look good for this.

So perhaps it would be worthwhile to add this to struct sk_buff? David
- are you interested in this if I submit a patch?

Or, alternatively, does a fast solution for this already exist that I
overlooked?

Thanks,
Jason
