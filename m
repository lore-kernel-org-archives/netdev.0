From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 0/7] CAN: Add new PF_CAN protocol family, try #3
Date: Fri, 22 Jun 2007 17:57:56 +0200
Message-ID: <467BF184.8040109@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de> <467BC1E9.6030201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:60078 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755671AbXFVP6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 11:58:34 -0400
In-Reply-To: <467BC1E9.6030201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Urs Thuermann wrote:
>   
>> * Use skb->iif instead of skb->cb to pass receiving interface from
>>   raw_rcv() and bcm_rcv() up to raw_recvmsg() and bcm_recvmsg().
>>     
>
>
> skb->iif doesn't necessarily point to the incoming network device
> as seen seen by netif_receive_skb, for layered devices it currently
> always points to the first interface that received a packet.
>   

This is exactly the intention.

> Its so far also only used for traffic classification, please explain
> how you're using it and what values it is set to on which paths.
>   

As you might have seen in Documentation/networking/can.txt (hint, hint,
hint!) the CAN has no routing, no ARP, no MAC adressing and is a
broadcast only medium. So if there is (at least) any reasonable
addressing on CAN it consists of the CAN-frame's "CAN-Identifier" and
the CAN-bus this CAN-frame is sent/received on.

For this reason the information about the interface the CAN-frame has
been received on has to be made available to the user-application if it
needs this information. Until your hint about our skb->cb missusage, we
(successfully) transported this information inside skb->cb to
socket-level. But indeed skb->iif is the better (and in our opinion the
right) place to transport this information inside the skb to the
socket-level.

In both cases (receiving real CAN-frames from the CAN-netdev /
performing the loopback of CAN-frames) we set skb->iif to zero to let
netif_receive_skb() set the iif-value to the current skb->dev index. So
skb->iif is set to the first interface the CAN-frame is received on,
which is what we need & intended here.

Is it the right approach to let netif_receive_skb() set the iif-value or
should we better set this value on our own before invoking netif_rx()?

Best regards,
Oliver


