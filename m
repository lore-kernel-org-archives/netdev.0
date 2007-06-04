From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: 04 Jun 2007 14:44:40 +0200
Message-ID: <ygfabvfrirr.fsf@janus.isnogud.escape.de>
References: <20070530131123.10843.0@janus.isnogud.escape.de>
	<20070530131204.10843.5@janus.isnogud.escape.de>
	<465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net>
	<46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net>
	<4661CBE7.7040901@hartkopp.net> <46631396.8030004@hartkopp.net>
	<4663FD57.3020601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:52399 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404AbXFDMui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 08:50:38 -0400
In-Reply-To: <4663FD57.3020601@trash.net>; from Patrick McHardy on Mon, 04 Jun 2007 13:53:59 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> I was thinking about this, don't CAN frames include the identity
> of the sender? That would be the easiest way to determine whether
> the frame needs to be delivered.

No, CAN is quite a broken networking technology (at least in my view,
coming from tcp/ip).  There is no station addresses and therefore no
sender or receiver addresses.  Everything is broadcast.

> Actually its not unused, it needs to be set on TX frames once the
> packet leaves the protocol specific code.

Oops, yes, this is something still missing in our code.  Needs to be
fixed.

> I don't get why you can't directly check the socket option on the
> TX path.

We have several types of sockets in the PF_CAN family, two of which
are GPL'ed and which are in the patch series.  These are CAN_RAW and
CAN_BCM.  The protocol implementations use can_send() in af_can.c to
send a CAN frame and indicate to can_send() in an int argument,
whether this frame should be looped back.  Only the raw protocol has a
socket option (setsockopt(2)) in struct raw_sock for this, bcm always
sets this to 1 to have the frame looped back.  There is no option in
struct bcm_sock for this.  In can_send() and in the driver we don't
know what type of socket skb->sk points to and can't check that
option.  Changing this would mean we have to add such an option in the
same position in all CAN socket types and set it to fixed values in
some of them (e.g. to 1 for bcm).  While it's doable, I wouldn't like
that very much.

Is there anything that prevents can_send() from using skb->pkt_type to
pass the loopback flag down to the driver?

urs
