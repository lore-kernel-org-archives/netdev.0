From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: Mon, 23 Feb 2004 10:26:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223102613.33838132.davem@redhat.com>
References: <20040223105359.GA91938@colin2.muc.de>
	<20040223.200101.39143636.yoshfuji@linux-ipv6.org>
	<20040223111659.GB10681@colin2.muc.de>
	<20040223.203843.04073965.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040223.203843.04073965.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Wait, I have an idea.

I was going to suggest ifdef'ing this change for 64-bit, but there is an even
nicer way to do this and it avoids the magic number argument we're having right
now too.

Let's compute this for _real_, as some kind of function on sizeof(struct sk_buff)
For example, the overhead of N 1-byte packets.

Andi has made a real observation in that various areas of performance are sensitive
to the snd/rcv buffer size, and the values we choose are inherently tied to the
size of struct sk_buff.  So whatever random value we choose today, could be useless
and cause bad performance the next time we change struct sk_buff in some way.

The proposal I make intends to avoid this endless tweaking.

Two more observations while grepping for SK_{R,W}MEM_MAX.

1) IPV4 icmp sents sk_sndbuf of it's sockets to "2 * SK_WMEM_MAX", that's not
   what it really wants.  What it really wants is enough space to hold
   ~2 full sized IPV4 packets, roughly 2 * 64K + struct sk_buff overhead
   and thus that is what it should be using there.

2) IPV6 icmp does the same as ipv4, except this value is even more wrong there
   especially considering jumbograms.  With current code, sending a jumbogram
   ipv6 icmp packet would simply fail, and I wonder if anyone has even tried
   this.

I'll cook something up to address all of this and it's going to go into 2.4.x as
well.
