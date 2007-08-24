From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 15:42:44 -0500
Message-ID: <20070824204243.GI4282@austin.ibm.com>
References: <8VHRR-45R-17@gated-at.bofh.it> <8VKwj-8ke-27@gated-at.bofh.it> <E1IOeSm-0000bm-Jo@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:49144 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbXHXUmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 16:42:55 -0400
Content-Disposition: inline
In-Reply-To: <E1IOeSm-0000bm-Jo@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 09:04:56PM +0200, Bodo Eggert wrote:
> Linas Vepstas <linas@austin.ibm.com> wrote:
> > On Fri, Aug 24, 2007 at 03:59:16PM +0200, Jan-Bernd Themann wrote:
> >> 3) On modern systems the incoming packets are processed very fast. Especially
> >> on SMP systems when we use multiple queues we process only a few packets
> >> per napi poll cycle. So NAPI does not work very well here and the interrupt
> >> rate is still high.
> > 
> > worst-case network ping-pong app: send one
> > packet, wait for reply, send one packet, etc.
> 
> Possible solution / possible brainfart:
> 
> Introduce a timer, but don't start to use it to combine packets unless you
> receive n packets within the timeframe. If you receive less than m packets
> within one timeframe, stop using the timer. The system should now have a
> decent response time when the network is idle, and when the network is
> busy, nobody will complain about the latency.-)

Ohh, that was inspirational. Let me free-associate some wild ideas.

Suppose we keep a running average of the recent packet arrival rate,
Lets say its 10 per millisecond ("typical" for a gigabit eth runnning
flat-out).  If we could poll the driver at a rate of 10-20 per
millisecond (i.e. letting the OS do other useful work for 0.05 millisec),
then we could potentially service the card without ever having to enable 
interrupts on the card, and without hurting latency.

If the packet arrival rate becomes slow enough, we go back to an
interrupt-driven scheme (to keep latency down).

The main problem here is that, even for HZ=1000 machines, this amounts 
to 10-20 polls per jiffy.  Which, if implemented in kernel, requires 
using the high-resolution timers. And, umm, don't the HR timers require
a cpu timer interrupt to make them go? So its not clear that this is much
of a win.

The eHEA is a 10 gigabit device, so it can expect 80-100 packets per
millisecond for large packets, and even more, say 1K packets per
millisec, for small packets. (Even the spec for my 1Gb spidernet card
claims its internal rate is 1M packets/sec.) 

Another possiblity is to set HZ to 5000 or 20000 or something humongous
... after all cpu's are now faster! But, since this might be wasteful,
maybe we could make HZ be dynamically variable: have high HZ rates when
there's lots of network/disk activity, and low HZ rates when not. That
means a non-constant jiffy.

If all drivers used interrupt mitigation, then the variable-high
frequency jiffy could take thier place, and be more "fair" to everyone.
Most drivers would be polled most of the time when they're busy, and 
only use interrupts when they're not.
 
--linas
