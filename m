From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run softirq
 network code on SMP
Date: Thu, 20 Sep 2007 11:11:50 -0700
Message-ID: <20070920111150.0e4a4914@freepuppy.rosehill>
References: <003501c7fb86$c04f7250$d6ddfea9@JOHNYE1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
	"John Ye" <johny@asimco.com.cn>
To: "john ye" <johny@asimco.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35851 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755740AbXITSNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 14:13:22 -0400
In-Reply-To: <003501c7fb86$c04f7250$d6ddfea9@JOHNYE1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2007 21:04:16 +0800
"john ye" <johny@asimco.com.cn> wrote:

> Bottom Softirq Implementation. John Ye, 2007.08.27
> 
> Why this patch:
> Make kernel be able to concurrently execute softirq's net code on SMP 
> system.
> Takes full advantages of SMP to handle more packets and greatly raises NIC 
> throughput.
> The current kernel's net packet processing logic is:
> 1) The CPU which handles a hardirq must be executing its related softirq.
> 2) One softirq instance(irqs handled by 1 CPU) can't be executed on more 
> than 2 CPUs
> at the same time.
> The limitation make kernel network be hard to take the advantages of SMP.
> 
> How this patch:
> It splits the current softirq code into 2 parts: the cpu-sensitive top half,
> and the cpu-insensitive bottom half, then make bottom half(calld BS) be
> executed on SMP concurrently.
> The two parts are not equal in terms of size and load. Top part has constant 
> code
> size(mainly, in net/core/dev.c and NIC drivers), while bottom part involves
> netfilter(iptables) whose load varies very much. An iptalbes with 1000 rules 
> to match
> will make the bottom part's load be very high. So, if the bottom part 
> softirq
> can be randomly distributed to processors and run concurrently on them, the 
> network will
> gain much more packet handling capacity, network throughput will be be 
> increased
> remarkably.
> 
> Where useful:
> It's useful on SMP machines that meet the following 2 conditions:
> 1) have high kernel network load, for example, running iptables with 
> thousands of rules, etc).
> 2) have more CPUs than active NICs, e.g. a 4 CPUs machine with 2 NICs).
> On these system, with the increase of softirq load, some CPUs will be idle
> while others(number is equal to # of NIC) keeps busy.
> IRQBALANCE will help, but it only shifts IRQ among CPUS, makes no softirq 
> concurrency.
> Balancing the load of each cpus will not remarkably increase network speed.
> 
> Where NOT useful:
> If the bottom half of softirq is too small(without running iptables), or the 
> network
> is too idle, BS patch will not be seen to have visible effect. But It has no
> negative affect either.
> User can turn on/off BS functionality by /proc/sys/net/bs_enable switch.
> 


If I read this correctly. You basically changed network processing from softirq
to workqueue (which is pretty much what -rt does). Perhaps optimizing and/or 
rearchitecting netfilter rule processing would get more benefit.

But you are ignoring the issue of all the locking assumptions that get changed.
Any performance gain from getting SMP will probably be lost by the additional
locking required.

Also patch is formatted badly, has multiple style issues (indentation etc).
If you want to have it seriously considered, follow the Documentation/CodingStyle guidelines.
There is even a perl script to check it scripts/checkpatch.pl

