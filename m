From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Fri, 28 Sep 2007 20:33:21 +0200
Message-ID: <46FD48F1.2000302@hartkopp.net>
References: <20070920184323.3795.0@janus.isnogud.escape.de>	<20070920184533.3795.5@janus.isnogud.escape.de>	<m1hclgm7dr.fsf@ebiederm.dsl.xmission.com>	<46FCBFC3.7020106@hartkopp.net> <m1hcled960.fsf@ebiederm.dsl.xmission.com>
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
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:17778 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757542AbXI1SeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 14:34:04 -0400
In-Reply-To: <m1hcled960.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Oliver Hartkopp <oliver@hartkopp.net> writes:  
>   
>> The CAN protocol family is some kind of a closed ecosystem with a
>> complete different addressing scheme that uses the bare networking
>> functionality of the Linux Kernel as well as DECNET or ARCNET. You would
>> never been able to run the IP-stack on a CAN netdev (ARPHDR_CAN,
>> ETH_P_CAN) due to several technical differences in addressing, etc.
>>     
>
> However when register_netdev is the netdev_notifier chain is called
> with NETDEV_REGISTER
>
> So then we enter code paths such as "net/ipv4/inetdev_event()" and
> process the network device.  There is some small amount of treatment
> given to devices that have IFF_LOOPBACK set.
>   

Yes. That's a good point. In the IPv4 NETDEV_REGISTER case the treatment
ends at the point, when (dev->mtu < 68) is checked as the CAN MTU is 16.
But we also had a problem with the IPv6 NETDEV_REGISTER in addr_conf
(fixed in 2.6.21) that complained about an interface with a too small MTU.

> The core point being that CAN devices as currently constructed are not
> in a closed ecosystem.  Other networking layers see them even if they
> can not use the properly.
>
> I don't know what all of the implications are but I do know we
> need to be careful.
>   

ACK.

>
> Hmm. My gut feel says that we just want function your drivers can
> call post transmit that will call dev_queue_xmit_nit if someone else
> is watching.  Although calling netif_rx seems to work but at least
> in the general case with routing I would be concerned that would get
> you into packets that would get routed out the incoming interface
> and cause a loop.
>   

All incoming (and even the 'echoed') CAN frames are processed in
can_rcv() to check the various CAN filters the users may have registered
through their different open AF_CAN sockets. This is a one way receive
path, that leads to simple a kfree_skb() if there's no subscriber for
the received frame. So there is no way to send CAN frames to a CAN
interface when is is not explicitly triggered from the user. CAN has no
routing by design. After looking into dev_queue_xmit_nit() it looks like
netif_rx() was a good choice.

>
> Further I still don't see any mechanism that isolates CAN netdrivers
> from the other protocol layers.
>
> What makes this problem a little stronger is that I have been
> simplifying some of the tests in some of the other networking layers
> from being "if (dev == loopback_dev)" to "if (dev->flags &
> IFF_LOOPBACK)" So there are fewer special cases I need to deal with.
>
> I believe that if you now use your current CAN patches unless I have
> misread something your can devices will now show up with ip 127.0.0.1
>   

No they don't due to the described mtu size verification. BUT i now get
an idea, why IFF_LOOPBACK was not that good approach ;-)

>   
>> I don't have any concerns creating a new IFF_-flag for this "loopback
>> approved by CSMA/CA media access" i just have no idea for a really good
>> name for it. But maybe the use of IFF_LOOPBACK for CAN netdrivers
>> (ARPHRD_CAN) is also ok for you now?!?
>>     
>
> Serial devices tend to call this echo or local echo, so how about
> IFF_ECHO.
>   

Excellent suggestion! If there are no remarks from other people, we can
change this in our next posting and add a new IFF_ECHO to if.h. Indeed
it's worth to look on the currently defined CAN RAW sockopts, the CAN
source and the docs to globally replace the 'loopback' with 'echo'. The
'local echo' hits the point really much better than to describe the
'loopback'-mechanic that's behind.

Thanks very much for your feedback & your time to review our stuff!

Oliver

