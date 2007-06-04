From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Mon, 04 Jun 2007 18:32:50 +0200
Message-ID: <46643EB2.2060204@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de>	<20070530131204.10843.5@janus.isnogud.escape.de>	<465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net>	<46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net>	<4661CBE7.7040901@hartkopp.net> <46631396.8030004@hartkopp.net> <ygfejkrrk16.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:30407 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757157AbXFDQdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 12:33:04 -0400
In-Reply-To: <ygfejkrrk16.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Oliver Hartkopp <socketcan@hartkopp.net> writes:
>
>   
>> 2. The loopback indication is done by using the unused skb->protocol in
>> the tx path.
>>     
>
> I don't think we should (mis-)use skb->protocol as a loopback flag.
>   

Yep! After reading the comments from Patrick and Urs i definitely agree
to their concerns.

> IMO it would be better to skb->pkt_type.  This is used to indicate
> packet type to rcv functions registered by dev_add_pack().  It is set
> by netdevice drivers to PACKET_{MULTICAST,BROADCAST,HOST,OTHER} for
> received packets.  In the send path it is set to PACKET_OUTGOING on
> the copy of the skbuff that is delivered to the sockets registered on
> ptype_all (typically packet sockets from tcpdump or other sniffers).
> AFAICS, pkt_type is not used otherwise in the send path.
>
> We could set skb->pkt_type = PACKET_LOOPBACK to flag to the CAN
> netdevice driver whether to loop back the packet.
>   

I think, it goes into the right direction to use skb->pkt_type. The flag
should really be somewhere inside the skb as all back references into
the sk would become sticky in the implementation.

But regarding the use of skb->pkt_type i would suggest to take a closer
look on the definitions in include/linux/if_packet.h and how the
pkt_type is to be used inside the kernel. In my opinion we should use ...

* TX-Path:
PACKET_OTHERHOST: send the CAN frame without loopback
PACKET_BROADCAST : send the CAN frame with loopback (aka local broadcast)

See an example of this approach in drivers/net/arcnet/rfc1051.c :
http://www.linux-m32r.org/lxr/http/source/drivers/net/arcnet/rfc1051.c?a=i386#L99

* RX-Path:
PACKET_HOST : just an incoming CAN frame for this host

Any comments? ACKs?

Best regards,
Oliver





