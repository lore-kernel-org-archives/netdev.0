From: David Miller <davem@davemloft.net>
Subject: Re: pktgen question
Date: Mon, 08 Oct 2007 15:22:34 -0700 (PDT)
Message-ID: <20071008.152234.13748626.davem@davemloft.net>
References: <46F8007A.6000701@candelatech.com>
	<470AA48B.4050005@opengridcomputing.com>
	<470AA7B9.4070703@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, rick.jones2@hp.com, hadi@cyberus.ca,
	johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44889
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbXJHWWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 18:22:35 -0400
In-Reply-To: <470AA7B9.4070703@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 08 Oct 2007 14:57:13 -0700

> This skb recycling can certainly work and has been done several
> times before.  It never gets into the kernel though.

Because it doesn't work.

A socket can hang onto a receive packet essentially forever.

You cannot therefore rely upon the network stack to give you the
packet back in some reasonable finite amount of time.  This is simply
the nature of the beast.

Which means that you either:

1) Starve and stop receiving packets when the recycling ring
   runs out because all of those packets are stuck in socket
   buffers.  This is easily DoS'able by users on your system

2) End up allocating new packets anyways, but then what's the
   point of the recycling ring?  It's just a hack that works
   when everything goes as planned, and in real life that is
   rarely the case.

It also makes the driver locking more complicated.  Packet
input occurs in NAPI drivers via netif_receive_skb() which
would be capable of recycling packets back to the same
driver in a recycling scheme.  But the recycling can occur
from other contexts too.  The netif_receive_skb() caller
already has atomic access to the receive queue, but those
other callback cases do not.

That locking issue is just the tip of the iceberg.  Once you
start discussing solutions, all sorts of new issues begin to
pop up.

SKB recycling, just say no.

