From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Fri, 28 Sep 2007 10:48:03 +0200
Message-ID: <46FCBFC3.7020106@hartkopp.net>
References: <20070920184323.3795.0@janus.isnogud.escape.de>	<20070920184533.3795.5@janus.isnogud.escape.de> <m1hclgm7dr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:26041 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107AbXI1ItX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 04:49:23 -0400
In-Reply-To: <m1hclgm7dr.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
>
> Currently IFF_LOOPBACK set in dev->flags means we are dealing
> with drivers/net/loopback.c. 
>   

This is a very general view, don't you think? The one is an interface
flag and the other one is an interface itself. This looks like a risky
mixture, when there is no clean separation.

> In other networking layers loopback functionality (i.e. for broadcast)
> is never expected to be provided by the drivers and is instead 
> always provided by the networking layer.  Keeping the drivers
> simpler.  Further you already have this functionality in the
> generic CAN layer for doing loopback without driver support.
>   

ACK & Yes.

> So at a first glance the CAN usage of IFF_LOOPBACK looks completely
> broken, and likely to confuse other networking layers if they see
> a CAN device.  Say if someone attempts to run IP over CAN or
> something like that.
>   

The CAN protocol family is some kind of a closed ecosystem with a
complete different addressing scheme that uses the bare networking
functionality of the Linux Kernel as well as DECNET or ARCNET. You would
never been able to run the IP-stack on a CAN netdev (ARPHDR_CAN,
ETH_P_CAN) due to several technical differences in addressing, etc.

> Do you think you can remove this incompatible usage of IFF_LOOPBACK
> from the can code?
>   

Yes. We might pick another name for it (see below).

> If I have read your documentation properly the only reason you are
> doing this is so that the timing of frames to cansniffer more
> accurately reflects when the frame hits the wire.  If CAN runs over a
> very slow medium I guess I can see where that can be a concern.

It's not really a (more accurate) timing problem but a media access
issue that occurs on the CAN bus itself:

The CAN bus is in opposite to an Ethernet a CSMA/CA (collision
*avoidance*) medium with an arbitration that's controlled with the so
called CAN-Identifier. The lower the CAN-Id value the higher is it's
priority. E.g. a CAN frame with an CAN-Id of 0x100 can squeeze out a CAN
frame with a CAN-Id of 0x400 on the bus, so that the CAN frame with the
CAN-Id of 0x400 is to be sent again (_automatically_ by the CAN
controller chip).

An example:
You want to send CAN-Id 0x700 on the bus, and put all the data into your
local CAN controller chip and start the transmission. When your local
controller wants to send it's frame it looses it's arbitration due to a
reception of a CAN-Id 0x100 and generates a RX-interrupt for this
received frame. After that your local controller tries to resend his
frame but it looses it's arbitration again due to a reception of a
CAN-Id 0x400 and generates a RX-interrupt for this received frame.
Finally your local controller tries to resend his frame, has success,
and generates a TX-interrupt for his successfully sent frame.

When you use the network layer loopback functionality the other
applications on your local host would see CAN-Id 0x700, CAN-Id 0x100,
CAN-Id 0x400. When you use the loopback on driver level you would see
the _correct_ message order CAN-Id 0x100, CAN-Id 0x400, CAN-Id 0x700.

So it's not an issue of having better timings but to reproduce the
*correct message order* from the CAN bus. One year ago this problem has
originally been pointed out by Michael Schulze from the University of
Magdeburg as having a correct message order created by the CSMA/CA
treatment is a vital requirement for CAN bus users. As you might see now
the CAN netdriver has to offer additional functionalities due to the
CSMA/CA treatment in opposite to the 'standard' CSMA/CD behaviour you
know from Ethernet netdrivers. And this arbitration information of the
CAN controller is only available on driver level. It is therefore no
question IF the CAN netdriver supports the CSMA/CA treatment but HOW to
provide an interface for this functionality on a basis of a standard
netdriver (which simply only sends and receives frames).

As the CAN netdrivers (as described above) are only available and used
by the PF_CAN core, the use of IFF_LOOPBACK looked like reasonable
solution to distinguish whether the CAN netdriver is capable to do the
loopback (e.g. due to the ability of the controller to generate
TX-interrupts) or not. The usage of IFF_LOOPBACK in CAN netdrivers
didn't affect or confuse the rest of the Linux networking system up to
now. Btw. if you state that IFF_LOOPBACK means for a netdriver, that
"all packets from a device will come right back to the current machine,
and go nowhere else.", we should think about a new IFF_-flag here.

I don't have any concerns creating a new IFF_-flag for this "loopback
approved by CSMA/CA media access" i just have no idea for a really good
name for it. But maybe the use of IFF_LOOPBACK for CAN netdrivers
(ARPHRD_CAN) is also ok for you now?!?

Oliver






