From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Fri, 28 Sep 2007 10:52:39 -0600
Message-ID: <m1hcled960.fsf@ebiederm.dsl.xmission.com>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	<20070920184533.3795.5@janus.isnogud.escape.de>
	<m1hclgm7dr.fsf@ebiederm.dsl.xmission.com>
	<46FCBFC3.7020106@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39825 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbXI1Qxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:53:51 -0400
In-Reply-To: <46FCBFC3.7020106@hartkopp.net> (Oliver Hartkopp's message of
	"Fri, 28 Sep 2007 10:48:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp <oliver@hartkopp.net> writes:

> Eric W. Biederman wrote:
>>
>> Currently IFF_LOOPBACK set in dev->flags means we are dealing
>> with drivers/net/loopback.c. 
>>   
>
> This is a very general view, don't you think? The one is an interface
> flag and the other one is an interface itself. This looks like a risky
> mixture, when there is no clean separation.

The better definition followed that IFF_LOOPBACK means all packets
will loopback.  Currently we only have one such device in the tree.
And the CAN devices do not have that property.

>> So at a first glance the CAN usage of IFF_LOOPBACK looks completely
>> broken, and likely to confuse other networking layers if they see
>> a CAN device.  Say if someone attempts to run IP over CAN or
>> something like that.
>>   
>
> The CAN protocol family is some kind of a closed ecosystem with a
> complete different addressing scheme that uses the bare networking
> functionality of the Linux Kernel as well as DECNET or ARCNET. You would
> never been able to run the IP-stack on a CAN netdev (ARPHDR_CAN,
> ETH_P_CAN) due to several technical differences in addressing, etc.

However when register_netdev is the netdev_notifier chain is called
with NETDEV_REGISTER

So then we enter code paths such as "net/ipv4/inetdev_event()" and
process the network device.  There is some small amount of treatment
given to devices that have IFF_LOOPBACK set.

The core point being that CAN devices as currently constructed are not
in a closed ecosystem.  Other networking layers see them even if they
can not use the properly.

I don't know what all of the implications are but I do know we
need to be careful.


>> Do you think you can remove this incompatible usage of IFF_LOOPBACK
>> from the can code?
>>   
>
> Yes. We might pick another name for it (see below).

Thanks.

>> If I have read your documentation properly the only reason you are
>> doing this is so that the timing of frames to cansniffer more
>> accurately reflects when the frame hits the wire.  If CAN runs over a
>> very slow medium I guess I can see where that can be a concern.

>
> So it's not an issue of having better timings but to reproduce the
> *correct message order* from the CAN bus. One year ago this problem has
> originally been pointed out by Michael Schulze from the University of
> Magdeburg as having a correct message order created by the CSMA/CA
> treatment is a vital requirement for CAN bus users. As you might see now
> the CAN netdriver has to offer additional functionalities due to the
> CSMA/CA treatment in opposite to the 'standard' CSMA/CD behaviour you
> know from Ethernet netdrivers. And this arbitration information of the
> CAN controller is only available on driver level. It is therefore no
> question IF the CAN netdriver supports the CSMA/CA treatment but HOW to
> provide an interface for this functionality on a basis of a standard
> netdriver (which simply only sends and receives frames).

Ok.  So the difference here is that CAN devices provide ordering on
the wire between their transmitted packets and their received packets,
and you need an additional hook so you can properly observe this case.

Hmm. My gut feel says that we just want function your drivers can
call post transmit that will call dev_queue_xmit_nit if someone else
is watching.  Although calling netif_rx seems to work but at least
in the general case with routing I would be concerned that would get
you into packets that would get routed out the incoming interface
and cause a loop.

> As the CAN netdrivers (as described above) are only available and used
> by the PF_CAN core, the use of IFF_LOOPBACK looked like reasonable
> solution to distinguish whether the CAN netdriver is capable to do the
> loopback (e.g. due to the ability of the controller to generate
> TX-interrupts) or not. The usage of IFF_LOOPBACK in CAN netdrivers
> didn't affect or confuse the rest of the Linux networking system up to
> now. Btw. if you state that IFF_LOOPBACK means for a netdriver, that
> "all packets from a device will come right back to the current machine,
> and go nowhere else.", we should think about a new IFF_-flag here.

Yes. IFF_LOOPBACK for a netdriver means that all packets from a device
will come right back to the current machine.   I stated that in a
later message, as that seems a clearer way to express what it means.

Further I still don't see any mechanism that isolates CAN netdrivers
from the other protocol layers.

What makes this problem a little stronger is that I have been
simplifying some of the tests in some of the other networking layers
from being "if (dev == loopback_dev)" to "if (dev->flags &
IFF_LOOPBACK)" So there are fewer special cases I need to deal with.

I believe that if you now use your current CAN patches unless I have
misread something your can devices will now show up with ip 127.0.0.1

> I don't have any concerns creating a new IFF_-flag for this "loopback
> approved by CSMA/CA media access" i just have no idea for a really good
> name for it. But maybe the use of IFF_LOOPBACK for CAN netdrivers
> (ARPHRD_CAN) is also ok for you now?!?

Serial devices tend to call this echo or local echo, so how about
IFF_ECHO.

Eric

