From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Mon, 16 Jul 2007 18:00:27 +0200
Message-ID: <469B961B.70309@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de>	<467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net>	<467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>	<467D4965.40601@trash.net> <467D4D65.2080806@hartkopp.net>	<467D54AB.5010407@trash.net> <ygfzm2ciemk.fsf@janus.isnogud.escape.de>	<468BA83A.7070500@trash.net> <ygfodil7qpi.fsf@janus.isnogud.escape.de> <469243D3.3090208@trash.net> <469253CE.8040004@hartkopp.net> <469B6D8D.1030809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	j.hadi123@gmail.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:32028 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758595AbXGPQAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 12:00:39 -0400
In-Reply-To: <469B6D8D.1030809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Oliver Hartkopp wrote:
>   
>> the people get the loopback functionality in ANY case. There is indeed
>> no difference from the view of the users, if you change this switch.
>>
>> The possibility to enable the loopback on vcan driver level is only to ...
>>
>> 1. Test the loopback fallback code in af_can.c
>> 2. Show, how a correct loopback handling is to be implemented
>>
>> ... nothing more.
>>     
>
>
> So its the "correct" handling and the other one is only fallback? That
> still sounds like it wants proper configuration. How does loopback work
> without this driver?
>   

As the addressing in CAN consist of a CAN-identifier and a CAN-interface
you always have at least one available CAN-interface you are working on.
In our case we may have several virtual CAN-interfaces.

On the CAN bus there is a CSMA/CA access with arbitration by the
CAN-identifier.
Due to the arbitration on the CAN bus the _transmission_ of a low prio
CAN-ID
may be delayed from the _receipition_ of a high prio CAN frame. To
reflect the correct traffic on the node the loopback of the sent
data has to be performed right _after_ a successful transmission. If
the CAN network interface is not capable to perform the loopback for
some reason the PF_CAN core can do this task as a fallback solution.

There are low cost adapters that are connected via some kind of ASCII
protocol on a serial line. These low cost adapters do not provide any TX
acknowledge that may be used to initiate the loopback receiption for the
sent CAN-frame . They are really dumb.

So you can divide the CAN controller drivers into two classes:

1. With an ACK (e.g. a valid TX interrupt) to trigger the loopback of
the sent frame
2. Without any feedback (the dumb one)

The intelligent ones (1.) do set dev->flags = (IFF_NOARP | IFF_LOOPBACK);
The dumb ones (2.) only set dev->flags = IFF_NOARP;

If a CAN-frame has to be looped back (the default), the function
can_send() in af_can.c looks whether the interface is capable to perform
the loopback or not (by checking the IFF_LOOPBACK flag in dev->flags).
In the case of a dumb interface the CAN-frame is looped back
immediately. In the case of an intelligent interface the CAN core keeps
it's hands off and lets the interface do the loopback. This should be
the usual case.

The loopback module parameter in the vcan driver enables or disables the
loopback on driver level, to test whether the fallback functionality for
'dumb interfaces' in af_can.c is working properly or not. Maybe it
should therefore be renamed to 'testloopback' or it should be removed
completely.

>From the functional side the user is not able to feel any difference
whether the loopback test is enabled in the vcan driver or not.

Thanks very much for your feedback!

Best regards,
Oliver



