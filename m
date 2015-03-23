From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Sun, 22 Mar 2015 17:22:15 -0700
Message-ID: <20150323002215.GA6074@roeck-us.net>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
 <20150320.163655.474336751434677390.davem@davemloft.net>
 <550C92F3.50302@cumulusnetworks.com>
 <20150320220946.GB31769@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	jiri@resnulli.us, ronen.arad@intel.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:36420 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbbCWAWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 20:22:33 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZq8W-004Ey8-KY
	for netdev@vger.kernel.org; Mon, 23 Mar 2015 00:22:32 +0000
Content-Disposition: inline
In-Reply-To: <20150320220946.GB31769@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 11:09:46PM +0100, Andrew Lunn wrote:
> > since we have discussed this problem multiple times in switchdev meetings,
> > the intent of this RFC is to see get the code out and also see if
> > rocker or any other in-kernel
> > driver can use it.
> 
> The Marvell switches in DSA don't have any way to mark packets why
> they where forwarded towards the host. So i don't see how we could use
> this feature with these chips.
> 

If we (re-)enable unknown address flooding in the Marvell switch chips,
we could simply mark all packets received from the switch as "forwarded
by hardware". Sure, there is no bit in the header, but we would know
from the chip configuration that the packets were forwarded.

There may be a different problem, though: The driver won't know if
the packet still needs to be forwarded by the soft bridge, for
example to a port of a switch on another network interface
which is part of the same bridge group.

		+---+
		|br0|
		+---+
		 | |
	+--------+ +----+
	|		|
      +---+	      +---+
      |sw0|	      |sw1|
      +---+	      +---+
       | +---+	        |
     +--+  +--+       +--+
     |p0|  |p1|	      |p2|
     +--+  +--+	      +--+

In this scenarion, sw0 can only know that it forwarded a packet to ports
on the same switch. It does not know know that the packet needs to be
forwarded to p2 as well. It would forward the packet from p0 to p1, and
thus presumably set the hw_fwded bit, but br0 still needs to forward it.

Maybe the check should be "if the packet was HW forwarded, the destination
is a switch, and the destination is the same switch, don't forward the packet".
This would be expensive, but on the other side it should not affect too
many packets.

Guenter
