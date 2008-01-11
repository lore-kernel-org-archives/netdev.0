From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: RE: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 14:20:44 -0200
Message-ID: <1200068444.9349.20.camel@cafe>
References: <1199981839.8931.35.camel@cafe>
	 <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:35500 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759672AbYAKQUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 11:20:49 -0500
Received: from mailhub1.br.ibm.com (unknown [9.18.232.109])
	by igw3.br.ibm.com (Postfix) with ESMTP id 4A2BC3900BD
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 14:12:50 -0200 (BRDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BGKl3h4141146
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 14:20:47 -0200
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BGKlN5004646
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 14:20:47 -0200
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-01-10 at 12:52 -0800, Brandeburg, Jesse wrote:
> Breno Leitao wrote:
> > When I run netperf in just one interface, I get 940.95 * 10^6 bits/sec
> > of transfer rate. If I run 4 netperf against 4 different interfaces, I
> > get around 720 * 10^6 bits/sec.
> 
> I hope this explanation makes sense, but what it comes down to is that
> combining hardware round robin balancing with NAPI is a BAD IDEA.  In
> general the behavior of hardware round robin balancing is bad and I'm
> sure it is causing all sorts of other performance issues that you may
> not even be aware of.
I've made another test removing the ppc IRQ Round Robin scheme, bonded
each interface (eth6, eth7, eth16 and eth17) to different CPUs (CPU1,
CPU2, CPU3 and CPU4) and I also get around around 720 * 10^6 bits/s in
average.

Take a look at the interrupt table this time: 

io-dolphins:~/leitao # cat /proc/interrupts  | grep eth[1]*[67]
277:         15    1362450         13         14         13         14         15         18   XICS      Level     eth6
278:         12         13    1348681         19         13         15         10         11   XICS      Level     eth7
323:         11         18         17    1348426         18         11         11         13   XICS      Level     eth16
324:         12         16         11         19    1402709         13         14         11   XICS      Level     eth17


I also tried to bound all the 4 interface IRQ to a single CPU (CPU0)
using the noirqdistrib boot paramenter, and the performance was a little
worse.

Rick, 
  The 2 interface test that I showed in my first email, was run in two
different NIC. Also, I am running netperf with the following command
"netperf -H <hostname> -T 0,8" while netserver is running without any
argument at all. Also, running vmstat in parallel shows that there is no
bottleneck in the CPU. Take a look: 

procs -----------memory---------- ---swap-- -----io---- -system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0      0 6714732  16168 227440    0    0     8     2  203   21  0  1 98  0  0
 0  0      0 6715120  16176 227440    0    0     0    28 16234  505  0 16 83  0  1
 0  0      0 6715516  16176 227440    0    0     0     0 16251  518  0 16 83  0  1
 1  0      0 6715252  16176 227440    0    0     0     1 16316  497  0 15 84  0  1
 0  0      0 6716092  16176 227440    0    0     0     0 16300  520  0 16 83  0  1
 0  0      0 6716320  16180 227440    0    0     0     1 16354  486  0 15 84  0  1
 

Thanks!

-- 
Breno Leitao <leitao@linux.vnet.ibm.com>

