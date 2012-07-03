From: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Subject: RFC: (now non Base64) replace packets already in queue
Date: Tue, 3 Jul 2012 10:02:05 +0000
Message-ID: <FB112703C4930F4ABEBB5B763F96491139379ECF@MAILSERV2A.lorien.fkie.fgan.de>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FEC854E.8080603@hp.com>
	 <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
	 <1340960817.15719.6.camel@edumazet-glaptop>
	 <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de>
	 <1341214310.5269.27.camel@edumazet-glaptop>
	 <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FF20557.4090501@gmail.com> <1341266168.22621.466.camel@edumazet-glaptop>
 <FB112703C4930F4ABEBB5B763F96491139379DC7@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?iso-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, "Rick Jones" <rick.jones2@hp.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailguard.fkie.fraunhofer.de ([128.7.3.5]:37630 "EHLO
	a.mx.fkie.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab2GCKCJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 06:02:09 -0400
In-Reply-To: <FB112703C4930F4ABEBB5B763F96491139379DC7@MAILSERV2A.lorien.fkie.fgan.de>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I found, that my eMail program send the eMail as UTF-8 / Base64. I'm sorry for the circumstances. I hope it's OK for you, that I'm repeating the content, so that everyone can follow it. But I will compress the whole discussion (Thanks to Eric Dumazet, Rick Jones and Nicolas de Peslouan):

-

I'm writing a kernel module (net/sched) which replaces packets in the queue. I'm glad hearing your option.

Background:
We are working with a property wireless network (no 802.11). The specifications: 
 Range: Kilometers.
 Speed: <=9,600 bps (no Megs, Gigs or Kilo!) (*).
 RTT (standard ping): idle-network: 1,5 *seconds*; network with load: minutes
 Other: shared.
 Connection: loosely to a Linux box, but without Linux driver. 
 Driver: a user-space program, which opens a virtual network device and sends 
         the packet from the virtual network device to the device.
 Queue: The device has no queue nor the user-space program. The program waits 
         for the ACK from the device before sending the next packet. This is 
         possible, because the wireless is so lame...

(*you remember the good ol' times with modems over telephone lines? When the 
internet was called BBS? And how it suddenly feels, when the BBS starts using
ANSI? This was comfortable compared to our problem..)

With such a very low bandwidth network its hard (rather: impossible) to get all 
packets sent. (TCP isn't possible, so we are sending everything as UDP.)
Some of the packets contain information, which gets obsolete over time. E.g. 
(GPS) positions, which will be sent periodically. If the application sends a new 
packet while an old position packet is still in the queue, the old packet is 
obsolete. This can be dropped. But just dropping the old packet and queuing the 
new packet will result in never sending a packet of this type.

So I've written a tc-qdisc scheduler module, which replaces packets in the queue 
on enqueuing, when this properties are given:
- UDPv4
- not fragmented
- (TOS & bitmask) = givenCompare; (bitmask and compare are adjustable)
- same source IP
- same destination IP
- same destination port
- same TOS
So, the packet got sent over the time - but with the actual information.
 (The code is tiny - just a file (and Kconfig, etc.))

Why not using "codel"? Because codel will drop "randomly" ("random" not for the 
protocol, but for the application) packets. It's made to reduce the flow speed.
But we haven't a flow, only periodic sensor data.
My qdisc won't drop random packets. It will reduce the traffic by intelligently 
replacing packets in the queue. Surely - the application must handle this. But 
in such a network a administrator have to configure the queues and he knows the 
applications.

Why not adding a tun/tap interface and do everything in the user space? 
As mentioned, the device "driver" is a user space program, which creates a tun/tap
interface. We CAN mix the code there in, but separating the work has a few benefits:
- separating the work with clear interfaces is always a good idea.
- having a qdisc will allow complex TC rules using this qdisc - it's fully compatible.
  (In fact - we have guidelines given. We can handle all of the guidelines with the 
   given TC classes - except the replace thing.)
- administrators knowing TC can work with this qdisc without any problems

My question is: Should I do the work to create and release a kernel patch and make 
it perfect over the time, or is this just our internal code, which I can leave at 
the current state? I know our module won't be used widely (too special), but I'm 
sure, there are a few people out there, which would be thankful for this.

Have you any other comments?

Greetings
Ralph Erdt 
