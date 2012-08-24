From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH] [v3] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 14:04:51 -0600
Message-ID: <5037DE63.5010701@wwwdotorg.org>
References: <1345835453-8611-1-git-send-email-timur@freescale.com> <5037DB43.60704@wwwdotorg.org> <5037DD60.8090206@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, ddaney.cavm@gmail.com,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:39391 "EHLO
	avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab2HXUEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 16:04:54 -0400
In-Reply-To: <5037DD60.8090206@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2012 02:00 PM, Timur Tabi wrote:
> Stephen Warren wrote:
> 
>>> +This is a special case of a MDIO bus multiplexer.  A memory-mapped device,
>>> +like an FPGA, is used to control which child bus is connected.  The mdio-mux
>>> +node must be a child of the memory-mapped device.  The driver currently only
>>> +supports devices with eight-bit registers.
>>
>> That last sentence seems like a property of the driver, not the binding;
>> I could easily anticipate allowing the size to be 1 or 2 or 4, and a
>> driver adapter to that in the future.
> 
> True, but I couldn't think of a better place to mention this.  Adding
> support for multi-byte registers also requires handling the endianness of
> those registers.  I have that problem with the mdio-mux-gpio driver.  That
> driver assumes that the GPIO bits are numbered in little-endian order, so
> my device tree on my big-endian CPU (PowerPC) lists the GPIO pins in
> reverse order.

True. One could always simply assume that the registers are native
endian by default, and then if ever they need not to be, add optional
properties to the binding.

>> Otherwise, this binding looks great now.
> 
> Do you still want me to scrub any references to the register size
> requirement from the document?

I don't feel too strongly about it. It seems cleaner to, but not a big deal.

>>> +++ b/drivers/net/phy/mdio-mux-mmioreg.c
>>
>>> +static int mdio_mux_mmioreg_switch_fn(int current_child, int desired_child,
>>> +				      void *data)
>>> +{
>>> +	struct mdio_mux_mmioreg_state *s = data;
>>> +
>>> +	if (current_child ^ desired_child) {
>>> +		void *p = ioremap(s->phys, 1);
>>> +		uint8_t x, y;
>>> +
>>> +		if (!p)
>>> +			return -ENOMEM;
>>
>> Why not map it during probe?
> 
> I thought about that, but I generally don't like mappings that exist for
> all eternity even though they're rarely used.  Once the interface is up,
> we don't expect any bus muxing to occur.
> 
>>
>>> +		x = ioread8(p);
>>> +		y = (x & ~s->mask) | desired_child;
>>> +		if (x != y) {
>>
>> Isn't that always true, given if (current_child ^ desired_child) above?
> 
> If current_child == -1, but the bus is already muxed properly, then
> there's no point in setting it.  Do you want me to remove the test, or add
> a comment?

Ah right, I suppose that is true. It almost doesn't seem worth writing
the code to ignore that special case, since presumably the register
write is idempotent, but since it's already there you can feel free not
to rip it out!
