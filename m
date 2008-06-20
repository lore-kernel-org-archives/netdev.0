From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Fri, 20 Jun 2008 16:06:12 -0500
Message-ID: <1213995972.9245.202.camel@localhost.localdomain>
References: <48583B37.5070708@candelatech.com>
	 <1213743506.5771.220.camel@localhost.localdomain>
	 <20080618062857.GA3598@2ka.mipt.ru>
	 <1213917029.9245.86.camel@localhost.localdomain>
	 <20080620060219.GA22784@2ka.mipt.ru>
	 <1213981859.9245.133.camel@localhost.localdomain>
	 <20080620172513.GA16673@2ka.mipt.ru>
	 <1213983664.9245.150.camel@localhost.localdomain>
	 <20080620175440.GA12197@2ka.mipt.ru>
	 <1213985826.9245.169.camel@localhost.localdomain>
	 <20080620182333.GA9342@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:54427 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433AbYFTVIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 17:08:31 -0400
In-Reply-To: <20080620182333.GA9342@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-06-20 at 22:23 +0400, Evgeniy Polyakov wrote:
> On Fri, Jun 20, 2008 at 01:17:06PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> > Let me clarify this again... I see the packet being sent at the expected
> > time from the sender on the tcpdump. The packet does not show up in
> > tcpdump or in the application on the receive side. When some other data
> > is received by the receiver (i.e. ARP), the missing packet shows up in
> > the tcpdump and in the application at the same time. So the delay shows
> > up in the tcpdump as well. It seems to me that everything is pointing to
> > the packet being in the DMA buffer but the controller driver not knowing
> > anything about it.
> 
> Argh. Ok, then please check that napi polling is called and rx interrupt
> happen for the driver.

This is what I have been focusing on. I'm still trying to figure out a
good way to see if the interrupt is triggered for a specific packet
because I have no way of determining which packet it will freeze on and
if I put any prints in the interrupt handler or poll function it slows
things down enough that the problem disappears.

In the meantime I was testing why the FIONREAD ioctl made such a big
difference and I found that if I insert a usleep(1) between the two
receive calls, the problem does not occur. During my testing before I
had put a usleep() between the send calls, which fixed the issue for me
and led me to assume that an IRQ was being missed if the packets come in
too close to each other.

The fact that inserting a sleep between the two receive calls fixes the
issue makes this seem less like a driver issue. The only hypothesis that
I have bee able to come up with so far is that calling recv() somehow
masks the interrupts momentarily so that if the packet comes in at
exactly the same time as the recv or poll() is called, the system does
not know anything about it, to the point that it does not even show on
the packet trace. I have no idea how this could happen at this point.

Thanks,

Travis

