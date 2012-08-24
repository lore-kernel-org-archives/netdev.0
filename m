From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] [v3] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 15:00:32 -0500
Message-ID: <5037DD60.8090206@freescale.com>
References: <1345835453-8611-1-git-send-email-timur@freescale.com> <5037DB43.60704@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <ddaney.cavm@gmail.com>,
	<devicetree-discuss@lists.ozlabs.org>, <netdev@vger.kernel.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:33839
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932254Ab2HXUAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 16:00:54 -0400
In-Reply-To: <5037DB43.60704@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Warren wrote:

>> +This is a special case of a MDIO bus multiplexer.  A memory-mapped device,
>> +like an FPGA, is used to control which child bus is connected.  The mdio-mux
>> +node must be a child of the memory-mapped device.  The driver currently only
>> +supports devices with eight-bit registers.
> 
> That last sentence seems like a property of the driver, not the binding;
> I could easily anticipate allowing the size to be 1 or 2 or 4, and a
> driver adapter to that in the future.

True, but I couldn't think of a better place to mention this.  Adding
support for multi-byte registers also requires handling the endianness of
those registers.  I have that problem with the mdio-mux-gpio driver.  That
driver assumes that the GPIO bits are numbered in little-endian order, so
my device tree on my big-endian CPU (PowerPC) lists the GPIO pins in
reverse order.

> Otherwise, this binding looks great now.

Do you still want me to scrub any references to the register size
requirement from the document?

>> +++ b/drivers/net/phy/mdio-mux-mmioreg.c
> 
>> +static int mdio_mux_mmioreg_switch_fn(int current_child, int desired_child,
>> +				      void *data)
>> +{
>> +	struct mdio_mux_mmioreg_state *s = data;
>> +
>> +	if (current_child ^ desired_child) {
>> +		void *p = ioremap(s->phys, 1);
>> +		uint8_t x, y;
>> +
>> +		if (!p)
>> +			return -ENOMEM;
> 
> Why not map it during probe?

I thought about that, but I generally don't like mappings that exist for
all eternity even though they're rarely used.  Once the interface is up,
we don't expect any bus muxing to occur.

> 
>> +		x = ioread8(p);
>> +		y = (x & ~s->mask) | desired_child;
>> +		if (x != y) {
> 
> Isn't that always true, given if (current_child ^ desired_child) above?

If current_child == -1, but the bus is already muxed properly, then
there's no point in setting it.  Do you want me to remove the test, or add
a comment?

-- 
Timur Tabi
Linux kernel developer at Freescale
