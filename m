From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [patch 01/13] KS8851: Fix ks8851 snl transmit problem
Date: Mon, 3 May 2010 14:11:41 -0700
Message-ID: <14385191E87B904DBD836449AA30269D6DE671@MORGANITE.micrel.com>
References: <20100429231739.509103394@fluff.org.uk><20100502.223852.219748077.davem@davemloft.net><14385191E87B904DBD836449AA30269D6DE63A@MORGANITE.micrel.com> <20100503.130316.56362236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ben@simtec.co.uk>, <netdev@vger.kernel.org>,
	<support@tincantools.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o149.mxlogic.net ([208.65.144.72]:55964 "EHLO
	p01c11o149.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744Ab0ECVMK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 17:12:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100503.130316.56362236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
> Date: Mon, 3 May 2010 12:06:21 -0700
> 
>> The transmit done interrupt in the KSZ8851 chips is not required for
>> normal operation.  Turning it off actually will improve transmit
>> performance because the system will not be interrupted every time a
>> packet is sent.
> 
> But you only trigger this workqueue when you notice in
->ndo_start_xmit() that you're out of
> space. 
> 
> This makes the chip sit idle with no packets to send until the
workqueue executes asynchronously
> to the initial transmit path which noticed the queue was full. 
> 
> That doesn't make any sense to me.  If anything you should at least
try to purge the TX queue
> and make space directly in the ->ndo_start_xmit() handler.  And if
that fails trigger an hrtimer
> to poll the TX state.  
> 
> Without some kind of timer based polling mechanism, if the workqueue
finds the TX queue is still
> full, what's going to do more checks later?  You will no longer get
->ndo_start_xmit() calls
> because the queue has been marked full, so nothing will trigger the
workqueue to run any more.  

I thought the transmit check workqueue reschedules itself when the
buffer available is still not enough, and this is the part you objected.

The buffer has about 8K.  Suppose 5 1514-byte packets are sent and the
buffer is not enough to hold the next packet and so the transmit queue
is stopped.  A workqueue is scheduled to read the buffer available
register.  As previous packets should have been sent the buffer size
read is big enough and so the transmit queue is restarted.  This happens
very often as the network bandwidth is only 10 Mbps but the CPU speed is
very fast.

I should also read the buffer available register during receive
interrupt processing so that this situation does not trigger in slow
traffic.

This roundabout way of using workqueue is because the register cannot be
read directly inside ndo_start_xmit().

Actually in other driver with similar transmit buffer available
operation I just return NETDEV_TX_BUSY and let the kernel stack calls
ndo_start_xmit again and again.  Supposedly it is bad for the whole
system but the overall transmit throughput is much better than when the
transmit done interrupt is enabled.

There should be a way to trigger the transmit interrupt after certain
number of packets are sent.  That will improve the performance and allay
your concern.  As I am not the engineer who worked on the Micrel KSZ8851
chip during its development, I am not quite aware of its functions and
limitations.  I will try the new code and submit a better patch if
possible.
