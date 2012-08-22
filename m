From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] netdev/phy: add MDIO bus multiplexer driven by a memory-mapped
 FPGA
Date: Wed, 22 Aug 2012 17:38:37 -0500
Message-ID: <50355F6D.4070002@freescale.com>
References: <1345671954-6398-1-git-send-email-timur@freescale.com> <50355C05.6000407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<david.daney@cavium.com>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:30882
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752177Ab2HVWin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 18:38:43 -0400
In-Reply-To: <50355C05.6000407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Daney wrote:

> I wonder if *fpga is really a good name for this.  It is a general 
> purpose multiplexer with a memory mapped control register.  I would call 
> it something like mdio-mux-mmioreg.

At one point, I thought of using mdio-mux-bitbang, but -mmioreg is better.
 Thanks.

>> +- mdio-mux-device : phandle, points to the FPGA (or similar) node.  This
>> +	must be a memory-mapped device with 8-bit registers.
> 
> You shouldn't need this.  Just make the multiplexer a child of FPGA node 
> to indicate where it lives.

The problem is that we don't normally consider the FPGA node to be a bus,
so its child nodes won't get probed.  That's why I have this:

compatible = "mdio-mux-fpga", "mdio-mux";
                               ^^^^^^^^

This allows me to have multiple mdio-mux parent nodes (which I do, since I
have multiple mdio bus muxes), and they all get registered and probed
properly because I also do this:

static const struct of_device_id of_device_ids[] __devinitconst = {
	{
		.compatible	= "simple-bus"
	},
	{
		.compatible	= "fsl,srio",
	},
...
	{
		.compatible	= "mdio-mux",
	},
	{}
};

The .compatible = "mdio-mux" is what causes all of the mdio-mux nodes to
be registered.  Therefore, it's simpler if all the mdio-mux nodes are root
nodes.

>> +
>> +- mdio-mux-register : integer, contains the offset of the register that
>> +	controls the bus multiplexer.
> 
> This should just be the normal "reg" properly

Ok.

>> +- mdio-mux-mask : integer, contains an 8-bit mask that specifies which
>> +	bits in the register control the actual bus multiplexer.  The
>> +	'reg' property of each child mdio-mux node must be constrained by
>> +	this mask.
>> +
> 
> "reg-mask" ??

Ok.

> 
> Do you need a shift too?

The 'reg' property of the mdio bus child nodes should take the shift into
account.  That's why, in the example, I have mask=0x6 and reg=0 or reg=2.
 There's even code in the driver to make sure that the 'reg' values are
constrained to the mask.

-- 
Timur Tabi
Linux kernel developer at Freescale
