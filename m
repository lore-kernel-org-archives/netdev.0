From: Jean-Louis Dupond <info@dupondje.be>
Subject: tg3 driver not advertising 1000mbit
Date: Fri, 12 Jun 2009 16:05:46 +0200
Message-ID: <7e14b58794647ea1b1b0a644e14a11f6@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.dupie.be ([85.17.239.130]:39406 "EHLO apollo.dupie.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756816AbZFLOew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2009 10:34:52 -0400
Received: from roundcube.dupie.be (apollo.dupie.be [127.0.0.1])
	by apollo.dupie.be (Postfix) with ESMTP id 657CE1E50752
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 16:05:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm experiencing a problem with my "Broadcom Corporation NetXtreme
BCM5722 Gigabit Ethernet PCI Express" network card in my Dell R300
servers. When booting the server, the network card sometimes doesn't
advertise gigabit speeds, and so it auto-negotiates @ 10mbit. The speed
can then be set to gigabit with mii-tool, but its not a good solution!
On the other hand, sometimes when it boots, it just works perfectly, and
advertises gigabit speeds & auto-negotiates on gigabit!

I tried to debug the driver a bit, and found some strange behavior
:) Only 2 values were different in the writephy function when it booted
@ 10mbit & gigabit.

I found something obvious in the tg3_readphy & tg3_writephy methods.

> 807         while (loops != 0) {
> 808                 udelay(10);
> 809                 frame_val = tr32(MAC_MI_COM);
> 810                 if ((frame_val & MI_COM_BUSY) == 0) {
> 811                         udelay(5);
> 812                         frame_val = tr32(MAC_MI_COM);
> 813                         break;
> 814                 }
> 815                 loops -= 1;
> 816         }

On line 809 frame_val is filled with a read (tr32) from the device.
On line 810 we check if its not 'MI_COM_BUSY'
If not then we have a delay of 5, and then we read it again ?!
I don't know why the value is read twice! I checked with some other
drivers (also broadcom) and there the read command was given some other
argument when reading the BUSY state, and then in the if, it was really
fetching the data. But in this case, we only have 2 times the same
argument!

With the original code the server booted into 10mbit the half of the
boots! When I removed line 811 & 812, then it booted into 10mbit only
1/20 times ! Which is way better ! But its still not fully fixed!

---------------------------------------------------------------------------

Today I found the programmers documentation on the Broadcom website and it
mentions the following:

> // Write value to MI communication register
> Mi_Communication_Register = Value32
> // Now read back MI Communication register until the start bit
> // has been cleared or we have timed out (>5000 reads)
> Loopcount = 5000
> While (LoopCount > 0)
> Begin
> Value32 = Mi_Communication_Register
> If (!(Value32 | 0x20000000)) then BREAK loop
> Else Loopcount--
> End

Here u can see its NOT needed to read the value twice.
Also there is no delay mentioned, so I removed it, and rebooted 20 times
without 1 time on 10mbit !


Feel free to give any other solutions / comments !

Sincerely,
Jean-Louis Dupond
