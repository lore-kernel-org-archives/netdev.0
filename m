From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [PATCH 2.6.32 2/3] net: Fix ks8851 snl transmit problem
Date: Mon, 21 Dec 2009 13:51:23 -0800
Message-ID: <14385191E87B904DBD836449AA30269D538A4D@MORGANITE.micrel.com>
References: <14385191E87B904DBD836449AA30269D021A41@MORGANITE.micrel.com> <20091203.160318.62214993.davem@davemloft.net> <14385191E87B904DBD836449AA30269D4F212C@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ben@simtec.co.uk>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o148.mxlogic.net ([208.65.145.71]:48684 "EHLO
	p01c12o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757353AbZLUVvy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 16:51:54 -0500
Content-class: urn:content-classes:message
In-Reply-To: <14385191E87B904DBD836449AA30269D4F212C@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ha, Tristram wrote:
> David Miller wrote:
>> 
>> Please describe why the TX interrupt facility cannot be used.
>> You probably have a race condition or similar, have you tried to see
>> if there is some issue like that?
>> 
>> This workqueue is going to make performance terrible, at best.
> 
> I am a software engineer at Micrel, Inc., which developed the KSZ8851
SNL chips.  This transmit
> problem is a hardware issue as the same problem is encountered in
different drivers like WinCE. 
> We have not pinpointed the hardware bug.  I do not think there is
something wrong in the driver.
> Turning off the transmit interrupt is just a workaround.   
> 
> I know the new workqueue implementation is polling.  But in my
experience, interrupting the
> system for each packet sent likely degrades the system performance
more.  The workqueue is only
> called when the transmit buffer is empty, which happens after 3 or 4
packets are sent quickly in
> succession.  The workqueue schedules itself again if the transmit
buffer is still not available,
> but in practice this case never happens.    
> 
> The KSZ8851 chips do not need special transmit interrupt handling
routine to cleanup the
> registers or socket buffers.  It is better to turn it off for better
performance.  Because the
> KSZ8851 SNL uses SPI, its driver has restrictions of when to call SPI
host to access registers. 
> That is why the original driver implementation uses a workqueue to
check the transmit buffer
> during transmit interrupt handling.    

Upon investigation, I found the ks8851 snl TCP transmit problem is not
related to the transmit side, which is fine, but to the receive side.
The "[PATCH 2.6.33] net: Fix ks8851 snl receive problem" patch I just
submitted should avoid the problem, so this patch is not required to
workaround the problem.

However, I still recommend this patch for performance consideration.  I
did a nuttcp benchmark using the Beagle Zippy combo board.

The original code using transmit done interrupt:

TCP RX	 9.6 Mbps	TCP TX	10.9 Mbps

The new code with transmit interrupt enabled:

TCP RX	 9.7 Mbps	TCP TX	11.5 Mbps

The new code with transmit interrupt disabled:

TCP RX	 9.8 Mbps	TCP TX	11.8 Mbps

The improvement is not much, but as the ks8851 snl device is targeted on
embedded systems that may not have powerful CPUs, the performance gain
is important to those ks8851 snl users.
