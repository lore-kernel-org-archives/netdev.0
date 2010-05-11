From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 2/4 v2] ks8851: Low level functions for read/write to
	companion eeprom
Date: Tue, 11 May 2010 02:16:38 +0100
Message-ID: <20100511011638.GI2589@trinity.fluff.org>
References: <1273085155-1260-1-git-send-email-s-jan@ti.com> <1273085155-1260-3-git-send-email-s-jan@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Abraham Arce <x0066660@ti.com>,
	Ben Dooks <ben-linux@fluff.org>, Tristram.Ha@micrel.com
To: Sebastien Jan <s-jan@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1273085155-1260-3-git-send-email-s-jan@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 05, 2010 at 08:45:53PM +0200, Sebastien Jan wrote:
> Low-level functions provide 16bits words read and write capability
> to ks8851 companion eeprom.

Please use the eeprom interface that was added already
 
> Signed-off-by: Sebastien Jan <s-jan@ti.com>
> ---
>  drivers/net/ks8851.c |  228 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ks8851.h |   14 +++-
>  2 files changed, 241 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
> index a84e500..787f9df 100644
> --- a/drivers/net/ks8851.c
> +++ b/drivers/net/ks8851.c
> @@ -1044,6 +1044,234 @@ static const struct net_device_ops ks8851_netdev_ops = {
>  	.ndo_validate_addr	= eth_validate_addr,
>  };
>  
> +/* Companion eeprom access */
> +
> +enum {	/* EEPROM programming states */
> +	EEPROM_CONTROL,
> +	EEPROM_ADDRESS,
> +	EEPROM_DATA,
> +	EEPROM_COMPLETE
> +};
> +
> +/**
> + * ks8851_eeprom_read - read a 16bits word in ks8851 companion EEPROM
> + * @dev: The network device the PHY is on.
> + * @addr: EEPROM address to read
> + *
> + * eeprom_size: used to define the data coding length. Can be changed
> + * through debug-fs.
> + *
> + * Programs a read on the EEPROM using ks8851 EEPROM SW access feature.
> + * Warning: The READ feature is not supported on ks8851 revision 0.
> + *
> + * Rough programming model:
> + *  - on period start: set clock high and read value on bus
> + *  - on period / 2: set clock low and program value on bus
> + *  - start on period / 2
> + */
> +unsigned int ks8851_eeprom_read(struct net_device *dev, unsigned int addr)
> +{
> +	struct ks8851_net *ks = netdev_priv(dev);
> +	int eepcr;
> +	int ctrl = EEPROM_OP_READ;
> +	int state = EEPROM_CONTROL;
> +	int bit_count = EEPROM_OP_LEN - 1;
> +	unsigned int data = 0;
> +	int dummy;
> +	unsigned int addr_len;
> +
> +	addr_len = (ks->eeprom_size == 128) ? 6 : 8;
> +
> +	/* start transaction: chip select high, authorize write */
> +	mutex_lock(&ks->lock);
> +	eepcr = EEPCR_EESA | EEPCR_EESRWA;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	eepcr |= EEPCR_EECS;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	mutex_unlock(&ks->lock);
> +
> +	while (state != EEPROM_COMPLETE) {
> +		/* falling clock period starts... */
> +		/* set EED_IO pin for control and address */
> +		eepcr &= ~EEPCR_EEDO;
> +		switch (state) {
> +		case EEPROM_CONTROL:
> +			eepcr |= ((ctrl >> bit_count) & 1) << 2;
> +			if (bit_count-- <= 0) {
> +				bit_count = addr_len - 1;
> +				state = EEPROM_ADDRESS;
> +			}
> +			break;
> +		case EEPROM_ADDRESS:
> +			eepcr |= ((addr >> bit_count) & 1) << 2;
> +			bit_count--;
> +			break;
> +		case EEPROM_DATA:
> +			/* Change to receive mode */
> +			eepcr &= ~EEPCR_EESRWA;
> +			break;
> +		}
> +
> +		/* lower clock  */
> +		eepcr &= ~EEPCR_EESCK;
> +
> +		mutex_lock(&ks->lock);
> +		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +		mutex_unlock(&ks->lock);
> +
> +		/* waitread period / 2 */
> +		udelay(EEPROM_SK_PERIOD / 2);
> +
> +		/* rising clock period starts... */
> +
> +		/* raise clock */
> +		mutex_lock(&ks->lock);
> +		eepcr |= EEPCR_EESCK;
> +		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +		mutex_unlock(&ks->lock);
> +
> +		/* Manage read */
> +		switch (state) {
> +		case EEPROM_ADDRESS:
> +			if (bit_count < 0) {
> +				bit_count = EEPROM_DATA_LEN - 1;
> +				state = EEPROM_DATA;
> +			}
> +			break;
> +		case EEPROM_DATA:
> +			mutex_lock(&ks->lock);
> +			dummy = ks8851_rdreg16(ks, KS_EEPCR);
> +			mutex_unlock(&ks->lock);
> +			data |= ((dummy >> EEPCR_EESB_OFFSET) & 1) << bit_count;
> +			if (bit_count-- <= 0)
> +				state = EEPROM_COMPLETE;
> +			break;
> +		}
> +
> +		/* wait period / 2 */
> +		udelay(EEPROM_SK_PERIOD / 2);
> +	}
> +
> +	/* close transaction */
> +	mutex_lock(&ks->lock);
> +	eepcr &= ~EEPCR_EECS;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	eepcr = 0;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	mutex_unlock(&ks->lock);
> +
> +	return data;
> +}
> +
> +/**
> + * ks8851_eeprom_write - write a 16bits word in ks8851 companion EEPROM
> + * @dev: The network device the PHY is on.
> + * @op: operand (can be WRITE, EWEN, EWDS)
> + * @addr: EEPROM address to write
> + * @data: data to write
> + *
> + * eeprom_size: used to define the data coding length. Can be changed
> + * through debug-fs.
> + *
> + * Programs a write on the EEPROM using ks8851 EEPROM SW access feature.
> + *
> + * Note that a write enable is required before writing data.
> + *
> + * Rough programming model:
> + *  - on period start: set clock high
> + *  - on period / 2: set clock low and program value on bus
> + *  - start on period / 2
> + */
> +void ks8851_eeprom_write(struct net_device *dev, unsigned int op,
> +					unsigned int addr, unsigned int data)
> +{
> +	struct ks8851_net *ks = netdev_priv(dev);
> +	int eepcr;
> +	int state = EEPROM_CONTROL;
> +	int bit_count = EEPROM_OP_LEN - 1;
> +	unsigned int addr_len;
> +
> +	addr_len = (ks->eeprom_size == 128) ? 6 : 8;
> +
> +	switch (op) {
> +	case EEPROM_OP_EWEN:
> +		addr = 0x30;
> +	break;
> +	case EEPROM_OP_EWDS:
> +		addr = 0;
> +		break;
> +	}
> +
> +	/* start transaction: chip select high, authorize write */
> +	mutex_lock(&ks->lock);
> +	eepcr = EEPCR_EESA | EEPCR_EESRWA;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	eepcr |= EEPCR_EECS;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	mutex_unlock(&ks->lock);
> +
> +	while (state != EEPROM_COMPLETE) {
> +		/* falling clock period starts... */
> +		/* set EED_IO pin for control and address */
> +		eepcr &= ~EEPCR_EEDO;
> +		switch (state) {
> +		case EEPROM_CONTROL:
> +			eepcr |= ((op >> bit_count) & 1) << 2;
> +			if (bit_count-- <= 0) {
> +				bit_count = addr_len - 1;
> +				state = EEPROM_ADDRESS;
> +			}
> +			break;
> +		case EEPROM_ADDRESS:
> +			eepcr |= ((addr >> bit_count) & 1) << 2;
> +			if (bit_count-- <= 0) {
> +				if (op == EEPROM_OP_WRITE) {
> +					bit_count = EEPROM_DATA_LEN - 1;
> +					state = EEPROM_DATA;
> +				} else {
> +					state = EEPROM_COMPLETE;
> +				}
> +			}
> +			break;
> +		case EEPROM_DATA:
> +			eepcr |= ((data >> bit_count) & 1) << 2;
> +			if (bit_count-- <= 0)
> +				state = EEPROM_COMPLETE;
> +			break;
> +		}
> +
> +		/* lower clock  */
> +		eepcr &= ~EEPCR_EESCK;
> +
> +		mutex_lock(&ks->lock);
> +		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +		mutex_unlock(&ks->lock);
> +
> +		/* wait period / 2 */
> +		udelay(EEPROM_SK_PERIOD / 2);
> +
> +		/* rising clock period starts... */
> +
> +		/* raise clock */
> +		eepcr |= EEPCR_EESCK;
> +		mutex_lock(&ks->lock);
> +		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +		mutex_unlock(&ks->lock);
> +
> +		/* wait period / 2 */
> +		udelay(EEPROM_SK_PERIOD / 2);
> +	}
> +
> +	/* close transaction */
> +	mutex_lock(&ks->lock);
> +	eepcr &= ~EEPCR_EECS;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	eepcr = 0;
> +	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
> +	mutex_unlock(&ks->lock);
> +
> +}
> +
>  /* ethtool support */
>  
>  static void ks8851_get_drvinfo(struct net_device *dev,
> diff --git a/drivers/net/ks8851.h b/drivers/net/ks8851.h
> index f52c312..537fb06 100644
> --- a/drivers/net/ks8851.h
> +++ b/drivers/net/ks8851.h
> @@ -25,12 +25,24 @@
>  #define OBCR_ODS_16mA				(1 << 6)
>  
>  #define KS_EEPCR				0x22
> +#define EEPCR_EESRWA				(1 << 5)
>  #define EEPCR_EESA				(1 << 4)
> -#define EEPCR_EESB				(1 << 3)
> +#define EEPCR_EESB_OFFSET			3
> +#define EEPCR_EESB				(1 << EEPCR_EESB_OFFSET)
>  #define EEPCR_EEDO				(1 << 2)
>  #define EEPCR_EESCK				(1 << 1)
>  #define EEPCR_EECS				(1 << 0)
>  
> +#define EEPROM_OP_LEN				3	/* bits:*/
> +#define EEPROM_OP_READ				0x06
> +#define EEPROM_OP_EWEN				0x04
> +#define EEPROM_OP_WRITE				0x05
> +#define EEPROM_OP_EWDS				0x14
> +
> +#define EEPROM_DATA_LEN				16	/* 16 bits EEPROM */
> +#define EEPROM_WRITE_TIME			4	/* wrt ack time in ms */
> +#define EEPROM_SK_PERIOD			400	/* in us */
> +
>  #define KS_MBIR					0x24
>  #define MBIR_TXMBF				(1 << 12)
>  #define MBIR_TXMBFA				(1 << 11)
> -- 
> 1.6.3.3
> 

-- 
-- 
Ben

Q:      What's a light-year?
A:      One-third less calories than a regular year.

