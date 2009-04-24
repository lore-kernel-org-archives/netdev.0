From: Calin Velea <calin.velea@gemenii.ro>
Subject: Re[2]: htb parallelism on multi-core platforms
Date: Fri, 24 Apr 2009 14:35:38 +0300
Message-ID: <1548458745.20090424143538@gemenii.ro>
References: <1239964844.21569.57.camel@blade.ines.ro> <49E905A2.7040402@gmail.com> <200904180321.50281.denys@visp.net.lb> <20090418075637.GA2738@ami.dom.local> <1240408926.6554.57.camel@blade.ines.ro> <Pine.LNX.4.64.0904222313080.22266@ask.diku.dk> <1240489907.6554.110.camel@blade.ines.ro>
Reply-To: Calin Velea <vcalinus@gemenii.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gemenii.ro ([195.28.184.8]:52033 "EHLO newmail.gemenii.ro"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750890AbZDXLgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 07:36:08 -0400
Received: from calin.gemenii.ro (195-28-185-136-broadband.gemenii.ro [195.28.185.136] (may be forged))
	by newmail.gemenii.ro (8.13.8/8.13.8) with ESMTP id n3OBa4Cb005095
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 14:36:04 +0300
In-Reply-To: <1240489907.6554.110.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  Maybe some actual results I got some time ago could help you and others who had the same problems:

Hardware: quad-core Xeon X3210 (2.13GHz, 8M  L2 cache), 2 Intel PCI Express Gigabit NICs
Kernel: 2.6.20

  I did some udp flood tests in the following configurations - the machine was configured as a
traffic shaping bridge, about 10k htb rules loaded, using hashing (see below):

A) napi on,  irqs for each card statically allocated to 2 CPU cores

when flooding, the same CPU went 100% softirq always (seems logical,
since it is statically bound to the irq)

B) napi on, CONFIG_IRQBALANCE=y

when flooding, a random CPU went 100% softirq always. (here,
at high interrupt rates, NAPI kicks in and starts using polling
rather than irqs, so no more balancing takes place since there are 
no more interrupts - checked this with /proc/interrupts - at high packet 
rates the irq counters for the network cards stalled)

C) napi off, CONFIG_IRQBALANCE=y

this is the setup I used in the end since all CPU cores were used. All of them
went to 100%, and the pps rate I could pass through was higher than in 
case A or B.


  Also, your worst case hashing setup could be improved - I suggest you take a look at 
http://vcalinus.gemenii.ro/?p=9 (see the generated filters example). The hashing method 
described there will take a constant CPU time (4 checks) for each packet, regardless of how many 
filter rules you have (provided you only filter by IP address). A tree of hashtables
is constructed which matches each of the four bytes from the IP address in succesion.

  Using this hashing method, the hardware above, 2.6.20 with napi off and irq balancing on, I got 
troughputs of 1.3Gbps / 250.000 pps  aggregated in+out in normal usage. CPU utilization 
averages varied between 25 - 50 % for every core, so there was still room to grow. 
  I expect much higher pps rates with better hardware (higher freq/larger cache Xeons).



Thursday, April 23, 2009, 3:31:47 PM, you wrote:

> On Wed, 2009-04-22 at 23:29 +0200, Jesper Dangaard Brouer wrote:
>> Its runtime adjustable, so its easy to try out.

>>   via /sys/module/sch_htb/parameters/htb_hysteresis

> Thanks for the tip! This means I can play around with various values
> while the machine is in production and see how it reacts.

>> The HTB classify hash has a scalability issue in kernels below 2.6.26. 
>> Patrick McHardy fixes that up in 2.6.26.  What kernel version are you 
>> using?

> I'm using 2.6.26, so I guess the fix is already there :(

>> Could you explain how you do classification? And perhaps outline where you 
>> possible scalability issue is located?

>> If you are interested how I do scalable classification, see my 
>> presentation from Netfilter Workshop 2008:

>>   http://nfws.inl.fr/en/?p=115
>>   http://www.netoptimizer.dk/presentations/nfsw2008/Jesper-Brouer_Large-iptables-rulesets.pdf

> I had a look at your presentation and it seems to be focused in dividing
> a single iptables rule chain into multiple chains, so that rule lookup
> complexity decreases from linear to logarithmic.

> Since I only need to do shaping, I don't use iptables at all. Address
> matching is all done in on the egress side, using u32. Rule schema is
> this:

> 1. We have two /19 networks that differ pretty much in the first bits:
> 80.x.y.z and 83.a.b.c; customer address spaces range from /22 nets to
> individual /32 addresses.

> 2. The default ip hash (0x800) is size 1 (only one bucket) and has two
> rules that select between two subsequent hash tables (say 0x100 and
> 0x101) based on the most significant bits in the address.

> 3. Level 2 hash tables (0x100 and 0x101) are size 256 (256 buckets);
> bucket selection is done by bits b10 - b17 (with b0 being the least
> significant).

> 4. Each bucket contains complete cidr match rules (corresponding to real
> customer addresses). Since bits b11 - b31 are already checked in upper
> levels, this results in a maximum of 2 ^ 10 = 1024 rules, which is the
> worst case, if all customer addresses that "fall" into that bucket
> are /32 (fortunately this is not the real case).

> In conclusion each packet would be matched against at most 1026 rules
> (worst case). The real case is actually much better: only one bucket
> with 400 rules, all other less than 70 rules and most of them less than
> 10 rules.

>> > I guess htb_hysteresis only affects the actual shaping (which takes 
>> > place after the packet is classified).

>> Yes, htb_hysteresis basically is a hack to allow extra bursts... we 
>> actually considered removing it completely...

> It's definitely worth a try at least. Thanks for the tips!

> Radu Rendec


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Best regards,
 Calin                            mailto:calin.velea@gemenii.ro

