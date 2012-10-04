From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Thu, 04 Oct 2012 19:34:39 +0200
Message-ID: <1349372079.16710.15.camel@sakura.staff.proxad.net>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349369406.16011.82.camel@edumazet-glaptop>
	 <1349370573.2532.25.camel@sakura.staff.proxad.net>
	 <1349371049.16011.90.camel@edumazet-glaptop>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349371049.16011.90.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2012-10-04 at 19:17 +0200, Eric Dumazet wrote:

> > yes, on ipv6 forward path the default NET_SKB_PAD is too small, so each
> > packet forwarded has its headroom expanded, it is then recycled and gets
> > its original default headroom back, then it gets forwarded,
> > expanded, ...
> 
> Hmm, this sounds bad (especially without recycle)
> 
> Might I assume NET_SKB_PAD is 32 on this arch ?

It is, I have a setup with 6to4 tunneling, so needed headroom on tx is
quite big.

I used to be careful about raising this value to avoid drivers using
slab-4096 instead of slab-2048, but since our boards no longer have 16MB
of RAM and with the recent changes in mainline it doesn't seem to be an
issue anymore.

It's not a that big issue in the non recycle case, just lower
performance if the tunable is not set correctly. Though it would be nice
to have a stat/counter so you know when you hit this kind of slow path.

But on the recycle case, skb->head is reallocated to twice the size each
time the packet is recycled and takes the same path again. This stresses
the VM and you eventually get packet loss (and scary printk)

-- 
Maxime
