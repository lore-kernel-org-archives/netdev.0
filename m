From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: htb parallelism on multi-core platforms
Date: Tue, 28 Apr 2009 12:15:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
References: <20090423082052.GA4243@ff.dom.local>  <1240495002.6554.155.camel@blade.ines.ro>
  <20090423181936.GA2756@ami.dom.local>  <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
 <1240566136.6554.220.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:47815 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932245AbZD1KPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 06:15:12 -0400
In-Reply-To: <1240566136.6554.220.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Apr 2009, Radu Rendec wrote:

> On Thu, 2009-04-23 at 22:19 +0200, Jesper Dangaard Brouer wrote:
>>>> It also proves that most of the packet processing work is actually in
>>>> htb.
>>
>> I'm not sure that statement is true.
>> Can you run Oprofile on the system?  That will tell us exactly where time
>> is spend...
>
> I've never used oprofile, but it looks very powerful and simple to use.
> I'll compile a 2.6.29 (so that I also benefit from the htb patch you
> told me about) then put oprofile on top of it. I'll get back to you by
> evening (or maybe Monday noon) with real facts :)

Remember to keep/copy the file "vmlinux".

Here is the steps I usually use:

  opcontrol --vmlinux=/boot/vmlinux-`uname -r`

  opcontrol --stop
  opcontrol --reset
  opcontrol --start

  <perform stuff that needs profiling>

  opcontrol --stop

"Normal" report
  opreport --symbols --image-path=/lib/modules/`uname -r`/kernel/ | less

Looking at specific module "sch_htb"

  opreport --symbols -cl sch_htb.ko --image-path=/lib/modules/`uname 
-r`/kernel/


>>> ...
>>> I thought about using some trick with virtual devs instead, but maybe
>>> I'm totally wrong.
>>
>> I like the idea with virtual devices, as each virtual device could be
>> bound to a hardware tx-queue.
>
> Is there any current support for this or do you talk about it as an
> approach to use in future development?

This is definitly only ideas for future development...


> The idea looks interesting indeed. If there's current support for it,
> I'd like to try it out. If not, perhaps I can help at least with testing
> (or even some coding as well).
>
>> Then you just have to construct your HTB trees on each virtual
>> device, and assign customers accordingly.
>
> I don't think it's that easy. Let's say we have the same HTB trees on
> both virtual devices A and B (each of them is bound to a different
> hardware tx queue). If packets for a specific destination ip address
> (pseudo)randomly arrive at both A and B, tokens will be extracted from
> both A and B trees, resulting in an erroneus overall bandwidth (at worst
> double the ceil, if packets reach the ceil on both A and B).
>
> I have to make sure packets belonging to a certain customer (or ip
> address) always come through a specific virtual device. Then HTB trees
> don't even need to be identical.

Correct...


> However, this is not trivial at all. A single customer can have
> different subnets (even from different class-B networks) but share a
> single HTB bucket for all of them. Using a simple hash function on the
> ip address to determine which virtual device to send through doesn't
> seem to be an option since it does not guarantee all packets for a
> certain customer will go together.

Well I know the problem, our customers IP's are also allocated adhoc and 
not grouped nicely :-(


>...
>
>> I just realized, you don't use a multi-queue capably NIC right?
>> Then it would be difficult to use the hardware tx-queue idea.
>> Have you though of using several physical NICs?
>
> The machine we are preparing for production has this:
>
> 2 x Intel Corporation 82571EB Gigabit Ethernet Controller
> 2 x Intel Corporation 80003ES2LAN Gigabit Ethernet Controller
>
> All 4 NICs use the e1000e driver and I think they are multi-queue
> capable. So in theory I can use several NICs and/or multi-queue.

I'm note sure that the driver e1000e has multiqueue for your devices.  The 
82571EB chip should have 2-rx and 2-tx queues [1].

Looking through the code, the multiqueue capable IRQ MSI-X code first got 
in in kernel version v2.6.28-rc1.  BUT the driver still uses 
alloc_etherdev() and not alloc_etherdev_mq().

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------

[1]: 
http://www.intel.com/products/ethernet/index.htm?iid=embnav1+eth#s1=Gigabit%20Ethernet&s2=82571EB&s3=all

