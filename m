From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3] drivers/net/ipg.c: fix horrible mdio_read and
	_write
Date: Tue, 8 Jan 2008 21:47:44 +0100
Message-ID: <20080108204744.GB4450@electric-eye.fr.zoreil.com>
References: <20080108124049.12199.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54119 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbYAHVGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 16:06:20 -0500
Content-Disposition: inline
In-Reply-To: <20080108124049.12199.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux@horizon.com <linux@horizon.com> :
[...]
> diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
> index 3860fcd..b3d3fc8 100644
> --- a/drivers/net/ipg.c
> +++ b/drivers/net/ipg.c
> @@ -202,12 +202,31 @@ static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
>  }
>  
>  /*
> + * Transmit the given bits, MSB-first, through the MgmtData bit (bit 1)
> + * of the PhyCtrl register. 1 <= len <= 32.  "ioaddr" is the register
> + * address, and "otherbits" are the values of the other bits.
> + */
> +static void mdio_write_bits(void __iomem *ioaddr, u8 otherbits, u32 data, unsigned len)
> +{
> +	otherbits |= IPG_PC_MGMTDIR;
> +	do {
> +		/* IPG_PC_MGMTDATA is a power of 2; compiler knows to shift */
> +		u8 d = ((data >> --len) & 1) * IPG_PC_MGMTDATA;
> +		/* + rather than | lets compiler microoptimize better */
> +		ipg_drive_phy_ctl_low_high(ioaddr, d + otherbits);
> +	} while (len);

Imho something is not quite right when the code needs a comment every line
and I am mildly convinced that we really want to honk an "optimizing mdio
methods is ok" signal around.

"while (len--) {" is probably more akpm-ish btw.

[...]
>  static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
>  {
>  	void __iomem *ioaddr = ipg_ioaddr(dev);
> +	u8 const polarity = ipg_r8(PHY_CTRL) &
> +			(IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);

(IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY) appears twice. I would not
mind a #define for it.

> @@ -221,75 +240,30 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
[...]
> -	for (i = 0; i < p[6].len; i++) {
> -		p[6].field |=
> -		    (read_phy_bit(ioaddr, polarity) << (p[6].len - 1 - i));
> -	}
> +	send_three_state(ioaddr, polarity);	/* TA first bit */
> +	(void)read_phy_bit(ioaddr, polarity);		/* TA second bit */
> +
> +	for (i = 0; i < 16; i++)
> +		data += data + read_phy_bit(ioaddr, polarity);
                ^^^^^^^^^^^^
Huh ?

> @@ -299,11 +273,13 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
>  static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
[...]
> +	mdio_write_bits(ioaddr, polarity, GMII_PREAMBLE, 32);
> +	mdio_write_bits(ioaddr, polarity, GMII_ST << 14 | GMII_WRITE << 12 |
> +	                                  phy_id << 7 | phy_reg << 2 |
> +					  0x2, 16);

Use the 80 cols luke:
	                                  phy_id << 7 | phy_reg << 2 | 0x2, 16);

It is a nice improvement otherwise.

-- 
Ueimor
