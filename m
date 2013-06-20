From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Thu, 20 Jun 2013 23:40:38 +0200
Message-ID: <1371764438.8333.20.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, Johannes Stezenbach <js@sig21.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49072 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965663Ab3FTVkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 17:40:42 -0400
In-Reply-To: <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(+Johannes, I have a question for you almost at the end of this email)

On Tue, 2013-06-18 at 02:18 +0100, Ben Hutchings wrote:

> > +config ALX
> > +	tristate "Qualcomm Atheros AR816x/AR817x support"
> > +	depends on PCI
> > +	select CRC32
> > +	select NET_CORE
> 
> Why NET_CORE?  It looks like a lot of drivers are selecting it because
> MII depends on it, but this doesn't select MII.  (Actually, it's
> ridiculous that MII depends on NET_CORE.  I'll see what I can do about
> that.)

Yeah, no idea, just copy/paste. Lots of drivers seem to do this, for no
particular reason it seems?

What I actually need is MDIO, which is also selected.

> > +	struct {
> > +		dma_addr_t dma;
> > +		void *virt;
> > +		int size;
> > +	} descmem;
...
> > +	int tx_ringsz;
> > +	int rx_ringsz;
> > +	int rxbuf_size;
> 
> Sizes could all be unsigned?

Yeah, not that it really matters in terms of exceeding, but still.

> If Asym_Pause can be advertised then it should be in the supported mask
> too...

Ok I'm totally not familiar with ethtool and will admit to copying it
from QCA's driver, I just tidied it up a bit ... Makes sense though,
I'll add it.

> > +	if (hw->link_speed != SPEED_UNKNOWN) {
> > +		ethtool_cmd_speed_set(ecmd,
> > +				      hw->link_speed - hw->link_speed % 10);
> > +		ecmd->duplex = hw->link_speed % 10;
> 
> Please use separate fields for speed and duplex.

Heh, ok. I actually played with this a bit and didn't like it much
either way ... There doesn't seem to be any combined enum, and if you
use separate fields then one is valid only if the other has a certain
value, etc... Anyway, I'll change it.

> > +	if (ecmd->autoneg == AUTONEG_ENABLE) {
> > +		if (ecmd->advertising & ADVERTISED_1000baseT_Half)
> > +			return -EINVAL;
> 
> Now what about 10000, 40000, etc...  

Indeed, that's broken.

> You should break out the code that
> sets ecmd->supported from alx_get_settings() and then do something like:
> 
> 	if (ecmd->advertising & ~alx_get_supported_mask())
> 		return -EINVAL;
> 
> here.

That... seems strange? It would rely on ADVERTISED_* and SUPPORTED_*
having the same value, which is probably true, but it still seems
confusing?

Not a big problem to list the 5 values here though.

> > +	alx_write_mem32(hw, ALX_STAD0, val);
> > +	val = be16_to_cpu(*(__be16 *)addr);
> > +	alx_write_mem32(hw, ALX_STAD1, val);
> > +}
> [...]
> > +void alx_add_mc_addr(struct alx_hw *hw, const u8 *addr)
> > +{
> > +	u32 crc32, bit, reg;
> > +
> > +	crc32 = ether_crc(ETH_ALEN, addr);
> > +
> > +	/* The HASH Table  is a register array of 2 32-bit registers.
> > +	 * It is treated like an array of 64 bits.  We want to set
> > +	 * bit BitArray[hash_value]. So we figure out what register
> > +	 * the bit is in, read it, OR in the new bit, then write
> > +	 * back the new value.  The register is determined by the
> > +	 * upper 7 bits of the hash value and the bit within that
> 
> Just bit 5, not the upper 7 bits!

I'd actually removed the comment already ... the few lines below seemed
really obvious to me.

> > +	/* Workaround for PCI problem when BIOS sets MMRBC incorrectly. */
> > +	pci_read_config_word(hw->pdev, PCI_COMMAND, &val16);
> > +	if (!(val16 & ALX_PCI_CMD) || (val16 & PCI_COMMAND_INTX_DISABLE)) {
> > +		val16 = (val16 | ALX_PCI_CMD) & ~PCI_COMMAND_INTX_DISABLE;
> > +		pci_write_config_word(hw->pdev, PCI_COMMAND, val16);
> > +	}
> [...]
> 
> I don't understand what this is trying to work around but it looks
> extremely dodgy.  The driver already appears to be doing
> pci_{save,restore}_state() in suspend/resume which is the right thing to
> do.

I have no idea, but ~PCI_COMMAND_INTX_DISABLE seems really just like
what we do with PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG... maybe this was
some sort of workaround for that.

Johannes, can you try to remove this chunk of code and see if your
device still works? If so I'd just kill it.

> I haven't looked at main.c but might spend some time on that later.

Thanks.

> I couldn't find where auto-negotiated flow control is programmed after
> the link comes up.  Maybe it isn't?

No idea, sorry. I clearly have a lot to learn about how ethernet devices
typically work, should it be programmed?

Thanks,
johannes
