From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: data received but not detected
Date: Tue, 8 Jul 2008 01:25:32 +0400
Message-ID: <20080707212531.GA15288@2ka.mipt.ru>
References: <20080620060219.GA22784@2ka.mipt.ru> <1213981859.9245.133.camel@localhost.localdomain> <20080620172513.GA16673@2ka.mipt.ru> <1213983664.9245.150.camel@localhost.localdomain> <20080620175440.GA12197@2ka.mipt.ru> <1213985826.9245.169.camel@localhost.localdomain> <20080620182333.GA9342@2ka.mipt.ru> <1213995972.9245.202.camel@localhost.localdomain> <20080621071253.GA17557@2ka.mipt.ru> <1215465030.14023.105.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:55272 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755876AbYGGVZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 17:25:44 -0400
Content-Disposition: inline
In-Reply-To: <1215465030.14023.105.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2008 at 04:10:30PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> I have not been able to work on this recently but I have some time to
> look at it again now. Before I stopped working on it, I implemented a
> workaround using a private ioctl() that was able to correct the issue
> after a hangup and (I believe) illustrates that a missed interrupt is
> causing the problem.
> 
> I added a private ioctl call to the macb driver that does the following:
> 1. read rx status register
> 2. if rx status is true, schedule poll (same block of code as in
> interrupt handler)
> 3. return
> 
> Then, in my userspace code, I called poll() with a timeout and called
> the ioctl() if poll timed out with no data. What I found was that the rx
> status register always reported a packet present but not acknowledged
> when poll timed out (on the board that missed the packet). Scheduling a
> poll in the driver forced it to read this new packet and the userspace
> code was able to continue from there.

Can it be missed acknowledge when ->poll() hits the quota limit?

> If the macb poll is executed, the receive status register will be
> cleared, so somewhere along the way an interrupt is being missed (or
> like you suggested some type of coalescing is happening).
> 
> Below is a patch of the changes that I have made to the driver including
> my rewrite of the poll() function and additional private ioctl()
> workaround. This patch is against 2.6.20 with some of the patches from
> http://maxim.org.za/sam9.html , most of which have been added to the
> vanilla kernel in the more current versions that I have tested (i.e.
> 2.6.25). This shows the changes that I have made more easily, but I can
> provide the full patch from vanilla if it would be more helpful (i.e.
> this one will not apply cleanly to a vanilla kernel). I wasn't sure
> which would be the best to post.

It is quite clear patch, but please provide needed part on top of .25
tree.
-- 
	Evgeniy Polyakov
