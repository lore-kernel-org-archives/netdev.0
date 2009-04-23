From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 15:31:47 +0300
Message-ID: <1240489907.6554.110.camel@blade.ines.ro>
References: <1239964844.21569.57.camel@blade.ines.ro>
	 <49E905A2.7040402@gmail.com> <200904180321.50281.denys@visp.net.lb>
	 <20090418075637.GA2738@ami.dom.local>
	 <1240408926.6554.57.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904222313080.22266@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:41966 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758197AbZDWMbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 08:31:55 -0400
In-Reply-To: <Pine.LNX.4.64.0904222313080.22266@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-22 at 23:29 +0200, Jesper Dangaard Brouer wrote:
> Its runtime adjustable, so its easy to try out.
> 
>   via /sys/module/sch_htb/parameters/htb_hysteresis

Thanks for the tip! This means I can play around with various values
while the machine is in production and see how it reacts.

> The HTB classify hash has a scalability issue in kernels below 2.6.26. 
> Patrick McHardy fixes that up in 2.6.26.  What kernel version are you 
> using?

I'm using 2.6.26, so I guess the fix is already there :(

> Could you explain how you do classification? And perhaps outline where you 
> possible scalability issue is located?
> 
> If you are interested how I do scalable classification, see my 
> presentation from Netfilter Workshop 2008:
> 
>   http://nfws.inl.fr/en/?p=115
>   http://www.netoptimizer.dk/presentations/nfsw2008/Jesper-Brouer_Large-iptables-rulesets.pdf

I had a look at your presentation and it seems to be focused in dividing
a single iptables rule chain into multiple chains, so that rule lookup
complexity decreases from linear to logarithmic.

Since I only need to do shaping, I don't use iptables at all. Address
matching is all done in on the egress side, using u32. Rule schema is
this:

1. We have two /19 networks that differ pretty much in the first bits:
80.x.y.z and 83.a.b.c; customer address spaces range from /22 nets to
individual /32 addresses.

2. The default ip hash (0x800) is size 1 (only one bucket) and has two
rules that select between two subsequent hash tables (say 0x100 and
0x101) based on the most significant bits in the address.

3. Level 2 hash tables (0x100 and 0x101) are size 256 (256 buckets);
bucket selection is done by bits b10 - b17 (with b0 being the least
significant).

4. Each bucket contains complete cidr match rules (corresponding to real
customer addresses). Since bits b11 - b31 are already checked in upper
levels, this results in a maximum of 2 ^ 10 = 1024 rules, which is the
worst case, if all customer addresses that "fall" into that bucket
are /32 (fortunately this is not the real case).

In conclusion each packet would be matched against at most 1026 rules
(worst case). The real case is actually much better: only one bucket
with 400 rules, all other less than 70 rules and most of them less than
10 rules.

> > I guess htb_hysteresis only affects the actual shaping (which takes 
> > place after the packet is classified).
> 
> Yes, htb_hysteresis basically is a hack to allow extra bursts... we 
> actually considered removing it completely...

It's definitely worth a try at least. Thanks for the tips!

Radu Rendec


