From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Routing loops & TTL tracking with tunnel devices
Date: Mon, 16 Nov 2015 23:25:02 +0100
Message-ID: <1447712702.2096268.441562113.30345320@webmail.messagingengine.com>
References: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Jiri Benc <jbenc@redhat.com>, therbert@google.com,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jason,

On Mon, Nov 16, 2015, at 21:14, Jason A. Donenfeld wrote:
> A few tunnel devices, like geneve or vxlan, are using
> udp_tunnel_xmit_skb, or related functions for transmitting packets,
> and are doing the usual FIB lookup to get the dst entry. I see a lot
> of code like this:
> 
>                 if (rt->dst.dev == dev) {
>                         netdev_dbg(dev, "circular route to %pI4\n",
>                                    &dst->sin.sin_addr.s_addr);
>                         dev->stats.collisions++;
>                         goto rt_tx_error;
>                 }
> 
> This one is from vxlan, but there are other similar blocks elsewhere.
> The basic idea is "am I about to send this packet to my own device?"
> 
> This is a bit crude. For starters, two interfaces could be pointed at
> each other, bouncing the packet back and forth indefinitely, causing
> the feared routing loop. Hopefully as more headers got tacked on,
> allocations would eventually fail, and the queen would be saved.
> 
> But what about in devices for which self-routing might actually be
> useful? For example, let's say that if an incoming skb is headed for
> dst X, it gets encapsulated and sent to dst A, and for dst Y it gets
> encapsulated and sent to dst B, and for dst Z it gets encapsulated and
> sent to dst C. I can imagine situations in which setting A==Y and B==Z
> might be useful to do multiple levels of encapsulation on one device,
> so that skbs headed for dst X get sent to dst C, but with intermediate
> transformations of dst A and dst B.
> 
> This isn't merely theoretical. I'm working on a driver right now that
> could benefit from this.
> 
> So, in implementing this, the question of avoiding routing loops comes
> into play. The most straight forward way to do this is to use a TTL
> value that's decreased. But we have a problem. A packet sent to dst X
> that is encapsulated and sent to dst A will have a ttl calculated for
> its journey to dst A. How do we preserve TTLs across multiple
> traversals of the networking stack? We can't simply stay with the TTL
> of the packet when it comes in, because it's tunnel destination might
> require a different TTL. The best thing would be to have a "tunnel
> TTL" value as part of skb->cb, except the cb gets overwritten when
> traversing the networking stack. The best thing I can think of is some
> other member of sk_buff, but I don't see any that look good for this.
> 
> So perhaps it would be worthwhile to add this to struct sk_buff? David
> - are you interested in this if I submit a patch?
> 
> Or, alternatively, does a fast solution for this already exist that I
> overlooked?

Have a look at __dev_queue_xmit and the per_cpu recursion limits
implemented there:

                        if (__this_cpu_read(xmit_recursion) >
                        RECURSION_LIMIT)
                                goto recursion_alert;

Bye,
Hannes
