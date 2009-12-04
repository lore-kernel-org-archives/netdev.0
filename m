From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [PATCH 2.6.32 2/3] net: Fix ks8851 snl transmit problem
Date: Thu, 3 Dec 2009 16:57:27 -0800
Message-ID: <14385191E87B904DBD836449AA30269D4F212C@MORGANITE.micrel.com>
References: <14385191E87B904DBD836449AA30269D021A41@MORGANITE.micrel.com> <20091203.160318.62214993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ben@simtec.co.uk>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o144.mxlogic.net ([208.65.144.67]:35971 "EHLO
	p01c11o144.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392AbZLDBBK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 20:01:10 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20091203.160318.62214993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
> Date: Thu, 3 Dec 2009 13:17:48 -0800
> 
>> This fixes a transmit problem of the ks8851 snl network driver.
Under heavy TCP traffic the
>> device will stop transmitting.  Turning off the transmit interrupt
avoids this issue.  A new
>> workqueue was implemented to replace the functionality of the
transmit interrupt processing.  
>> 
>> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
> 
> Please describe why the TX interrupt facility cannot be used.
> You probably have a race condition or similar, have you tried to see
if there is some issue like
> that? 
> 
> This workqueue is going to make performance terrible, at best.

I am a software engineer at Micrel, Inc., which developed the KSZ8851
SNL chips.  This transmit problem is a hardware issue as the same
problem is encountered in different drivers like WinCE.  We have not
pinpointed the hardware bug.  I do not think there is something wrong in
the driver.  Turning off the transmit interrupt is just a workaround.

I know the new workqueue implementation is polling.  But in my
experience, interrupting the system for each packet sent likely degrades
the system performance more.  The workqueue is only called when the
transmit buffer is empty, which happens after 3 or 4 packets are sent
quickly in succession.  The workqueue schedules itself again if the
transmit buffer is still not available, but in practice this case never
happens.

The KSZ8851 chips do not need special transmit interrupt handling
routine to cleanup the registers or socket buffers.  It is better to
turn it off for better performance.  Because the KSZ8851 SNL uses SPI,
its driver has restrictions of when to call SPI host to access
registers.  That is why the original driver implementation uses a
workqueue to check the transmit buffer during transmit interrupt
handling.
