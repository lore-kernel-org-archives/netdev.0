From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Fri, 18 Feb 2011 16:07:20 +0100
Message-ID: <201102181607.20787.arnd@arndb.de>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com> <1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Subhasish Ghosh <subhasish@mistralsolutions.com>,
	davinci-linux-open-source@linux.davincidsp.com,
	sachi@mistralsolutions.com, nsekhar@ti.com,
	open list <linux-kernel@vger.kernel.org>,
	"open list:CAN NETWORK DRIVERS" <socketcan-core@lists.berlios.de>,
	"open list:CAN NETWORK DRIVERS" <netdev@vger.kernel.org>,
	m-watkins@ti.com, Wolfgang Grandegger <wg@grandegger.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:51405 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab1BRPHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 10:07:34 -0500
In-Reply-To: <1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 February 2011, Subhasish Ghosh wrote:
> This patch adds support for the CAN device emulated on PRUSS.

Hi Subhasish,

This is a detailed walk through the can driver. The pruss_can.c
file mostly looks good, there are very tiny changes that I'm
suggesting to improve the code. I assume that you wrote that file.

The pruss_can_api.c is a bit of a mess and looks like it was copied
from some other code base and just barely changed to follow Linux
coding style. I can tell from the main driver file that you can do
better than that.

My recommendation for that would be to throw it away and reimplement
the few parts that you actually need, in proper coding style.
You can also try to fix the file according to the comments I give
you below, but I assume that would be signficantly more work.

Moving everything into one file also makes things easier to read
here and lets you identifer more quickly what is unused.

	Arnd

> +#ifdef __CAN_DEBUG
> +#define __can_debug(fmt, args...) printk(KERN_DEBUG "can_debug: " fmt, ## args)
> +#else
> +#define __can_debug(fmt, args...)
> +#endif
> +#define __can_err(fmt, args...) printk(KERN_ERR "can_err: " fmt, ## args)

Better use the existing dev_dbg() and dev_err() macros that provide the
same functionality in a more standard way. You already use them in
some places, as I noticed.

If you don't have a way to pass a meaningful device, you can use
pr_debug/pr_err.

> +void omapl_pru_can_rx_wQ(struct work_struct *work)
> +{

This is only used in the same file, so better make it static.

> +	if (-1 == pru_can_get_intr_status(priv->dev, &priv->can_rx_hndl))
> +		return;

Don't make up your own return values, just use the standard error codes,
e.g. -EIO or -EAGAIN, whatever fits.

The more common way to write the comparison would be the other way round,

	if (pru_can_get_intr_status(priv->dev, &priv->can_rx_hndl) == -EAGAIN)
		return;

or, simpler

	if (pru_can_get_intr_status(priv->dev, &priv->can_rx_hndl))
		return;

> +irqreturn_t omapl_tx_can_intr(int irq, void *dev_id)
> +{

This also should be static

> +		for (bit_set = 0; ((priv->can_tx_hndl.u32interruptstatus & 0xFF)
> +						>> bit_set != 0); bit_set++)
> +		;

	bit_set = fls(priv->can_tx_hndl.u32interruptstatus & 0xFF); ?

> +irqreturn_t omapl_rx_can_intr(int irq, void *dev_id)

static

> diff --git a/drivers/net/can/da8xx_pruss/pruss_can_api.c b/drivers/net/can/da8xx_pruss/pruss_can_api.c
> new file mode 100644
> index 0000000..2f7438a
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/pruss_can_api.c

A lot of code in this file seems to be unused. Is that right?
I would suggest adding only the code that is actually being
used. If you add more functionality later, you can always
add back the low-level functions, but dead code usually
turns into broken code quickly.

> +static can_emu_drv_inst gstr_can_inst[ecanmaxinst];

This is global data and probably needs some for of locking

> +/*
> + * pru_can_set_brp()	Updates the  BRP register of PRU0
> + * and PRU1 of OMAP L138. This API will be called by the
> + * Application to updtae the BRP register of PRU0 and PRU1
> + *
> + * param	u16bitrateprescaler		The can bus bitrate
> + * prescaler value be set
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_set_brp(struct device *dev, u16 u16bitrateprescaler)
> +{

unused.

> +	u32 u32offset;
> +
> +	if (u16bitrateprescaler > 255) {
> +		return -1;
> +	}

non-standard error code. It also doesn't match the comment, which
claims it is SUCCESS or FAILURE, both of which are (rightfully)
not defined.

> +	u32offset = (PRU_CAN_RX_CLOCK_BRP_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u16bitrateprescaler, 1);
> +
> +	u32offset = (PRU_CAN_TX_CLOCK_BRP_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u16bitrateprescaler, 1);

You pass a 32 bit pointer to a 16 bit local variable here.
This has an undefined effect, and if you build this code on
a big-endian platform, it cannot possibly do anything good.

pruss_writel() is defined in a funny way if it takes a thirty-two bit
input argument by reference, rather than by value. What is going
on there?

> +s16 pru_can_set_bit_timing(struct device *dev,
> +		can_bit_timing_consts *pstrbittiming)

unused.

> +	u32 u32offset;
> +	u32 u32serregister;

It's a bit silly to put the name of the type into the name
of a variable. You already spell it out in the definition.

> +s16 pru_can_write_data_to_mailbox(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl)
> +{
> +	s16 s16subrtnretval;
> +	u32 u32offset;
> +
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}

nonstandard error code. Also, why the heck is type function
return type s16 when the only possible return values are 0
and -1? Just make this an int.

> +	switch ((u8) pstremuapphndl->ecanmailboxnumber) {
> +	case 0:
> +		u32offset = (PRU_CAN_TX_MAILBOX0);
> +		break;
> +	case 1:
> +		u32offset = (PRU_CAN_TX_MAILBOX1);
> +		break;
> +	case 2:
> +		u32offset = (PRU_CAN_TX_MAILBOX2);
> +		break;
> +	case 3:
> +		u32offset = (PRU_CAN_TX_MAILBOX3);
> +		break;
> +	case 4:
> +		u32offset = (PRU_CAN_TX_MAILBOX4);
> +		break;
> +	case 5:
> +		u32offset = (PRU_CAN_TX_MAILBOX5);
> +		break;
> +	case 6:
> +		u32offset = (PRU_CAN_TX_MAILBOX6);
> +		break;
> +	case 7:
> +		u32offset = (PRU_CAN_TX_MAILBOX7);
> +		break;
> +	default:
> +		return -1;
> +	}

Lovely switch statement. I'm sure you find a better way to express this ;-)

> +	s16subrtnretval = pruss_writel(dev, u32offset,
> +		(u32 *) &(pstremuapphndl->strcanmailbox), 4);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	return 0;
> +}

return pruss_writel(...) ?

> +
> +/*
> + * pru_can_get_intr_status()
> + * Gets the interrupts status register value.
> + * This API will be called by the Application
> + * to get the interrupts status register value
> + *
> + * param  u8prunumber	PRU number for which IntStatusReg
> + * has to be read
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_get_intr_status(struct device *dev,
> +		can_emu_app_hndl *pstremuapphndl)
> +{
> +	u32 u32offset;
> +	s16 s16subrtnretval = -1;
> +
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}

In every function you check that pstremuapphndl is present. This seems
rather pointless. How about just making sure you never pass a NULL
value to these functions? That should not be hard at all from the
high-level driver.

> +	if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_1) {
> +		u32offset = (PRU_CAN_TX_INTERRUPT_STATUS_REGISTER);
> +	} else if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_0) {
> +		u32offset = (PRU_CAN_RX_INTERRUPT_STATUS_REGISTER);
> +	} else {
> +		return -1;
> +	}
> +
> +	s16subrtnretval = pruss_readl(dev, u32offset,
> +		(u32 *) &pstremuapphndl->u32interruptstatus, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}

You can also get rid of all these {} braces around one-line statements.

> +/*
> + * pru_can_get_mailbox_status()		Gets the mailbox status
> + * register value. This API will be called by the Application
> + * to get the mailbox status register value
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_get_mailbox_status(struct device *dev,
> +		can_emu_app_hndl *pstremuapphndl)

unused.

> +/*
> + * pru_can_config_mode_set()		Sets the timing value
> + * for data transfer. This API will be called by the Application
> + * to set timing valus for data transfer
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_config_mode_set(struct device *dev, bool bconfigmodeflag)

unused.

> +	u32offset = (PRU_CAN_TX_GLOBAL_CONTROL_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000040;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	u32offset = (PRU_CAN_RX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000040;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}

<skipping 50 (!) more of these>

After the third time of writing the same code, you should have noticed that
there is some duplication involved that can trivially be reduced. A good
way to express the same would be a table with the contents:

static struct pru_can_register_init {
	u16 offset;
	u32 value;
} = {
	{ PRU_CAN_TX_GLOBAL_CONTROL_REGISTER, 0, },
	{ PRU_CAN_TX_GLOBAL_STATUS_REGISTER, 0x40, },
	{ PRU_CAN_RX_GLOBAL_STATUS_REGISTER, 0x40, },
	...
};


> +
> +
> +/*
> + * pru_can_emu_open()		Opens the can emu for
> + * application to use. This API will be called by the Application
> + * to Open the can emu for application to use.
> + *
> + * param	pstremuapphndl	Pointer to application handler
> + * structure
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_emu_open(struct device *dev, can_emu_app_hndl *pstremuapphndl)

unused.

> +/*
> + * brief    pru_can_emu_close()	Closes the can emu for other
> + * applications to use. This API will be called by the Application to Close
> + * the can emu for other applications to use
> + *
> + * param	pstremuapphndl	Pointer to application handler structure
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_emu_close(struct device *dev, can_emu_app_hndl *pstremuapphndl)

unused

> +s16 pru_can_emu_sreset(struct device *dev)
> +{
> +	return 0;
> +}

pointless.

> +s16 pru_can_tx(struct device *dev, u8 u8mailboxnumber, u8 u8prunumber)
> +{
> +	u32 u32offset = 0;
> +	u32 u32value = 0;
> +	s16 s16subrtnretval = -1;
> +
> +	if (DA8XX_PRUCORE_1 == u8prunumber) {
> +		switch (u8mailboxnumber) {
> +		case 0:
> +			u32offset = (PRU_CAN_TX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 1:
> +			u32offset = (PRU_CAN_TX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 2:
> +			u32offset = (PRU_CAN_TX_MAILBOX2_STATUS_REGISTER & 0xFFFF);

Another pointless switch statement.

> +s16 pru_can_mask_ints(struct device *dev, u32 int_mask)
> +{
> +	return 0;
> +}
> +
> +int pru_can_get_error_cnt(struct device *dev, u8 u8prunumber)
> +{
> +	return 0;
> +}

useless.

> +int pru_can_get_intc_status(struct device *dev)
> +{
> +	u32 u32offset = 0;
> +	u32 u32getvalue = 0;
> +	u32 u32clrvalue = 0;
> +
> +	u32offset = (PRUSS_INTC_STATCLRINT1 & 0xFFFF);
> +	pruss_readl(dev, u32offset, (u32 *) &u32getvalue, 1);
> +
> +	if (u32getvalue & 4)
> +		u32clrvalue = 34;	/* CLR Event 34 */
> +
> +	if (u32getvalue & 2)
> +		u32clrvalue = 33;	/* CLR Event 33  */
> +
> +	if (u32clrvalue) {
> +		u32offset = (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +		pruss_writel(dev, u32offset, &u32clrvalue, 1);
> +	} else
> +		return -1;

Could the controller signal both event 34 and 33 simultaneously?
The only user of this function looks at the individual bits
of the return value again, which looks wrong for all possible
return values here.

> +#ifndef _PRU_CAN_API_H_
> +#define CAN_BIT_TIMINGS			(0x273)
> +
> +/* Timer Clock is sourced from DDR freq (PLL1 SYS CLK 2) */
> +#define	TIMER_CLK_FREQ			132000000
> +
> +#define TIMER_SETUP_DELAY		14
> +#define GPIO_SETUP_DELAY		150
> +
> +#define CAN_RX_PRU_0			PRUSS_NUM0
> +#define CAN_TX_PRU_1			PRUSS_NUM1
> +
> +/* Number of Instruction in the Delay loop */
> +#define DELAY_LOOP_LENGTH		2
> +
> +#define PRU1_BASE_ADDR			0x2000
> +
> +#define PRU_CAN_TX_GLOBAL_CONTROL_REGISTER		(PRU1_BASE_ADDR)
> +#define PRU_CAN_TX_GLOBAL_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x04)
> +#define PRU_CAN_TX_INTERRUPT_MASK_REGISTER		(PRU1_BASE_ADDR	+ 0x08)
> +#define PRU_CAN_TX_INTERRUPT_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x0C)
> +#define PRU_CAN_TX_MAILBOX0_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x10)
> +#define PRU_CAN_TX_MAILBOX1_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x14)

The header file should be used for interfaces between the two .c files,
don't mix that with hardware specific definitions. Sometimes you may want
to have register number lists in a header, if that list is going to be
used in multiple places. In this case, there is just one user, so better
move all those definitions over there.

> +typedef enum {
> +	ecaninst0 = 0,
> +	ecaninst1,
> +	ecanmaxinst
> +} can_instance_enum;
> +
> +typedef enum {
> +	ecanmailbox0 = 0,
> +	ecanmailbox1,
> +	ecanmailbox2,
> +	ecanmailbox3,
> +	ecanmailbox4,
> +	ecanmailbox5,
> +	ecanmailbox6,
> +	ecanmailbox7
> +} can_mailbox_number;
> +
> +typedef enum {
> +	ecandirectioninit = 0,
> +	ecantransmit,
> +	ecanreceive
> +} can_transfer_direction;

The values are all unused, you only use the typedefs.
IMHO it would be more sensible to just pass these as unsigned int
or u32 values, but if you prefer, there is no reason to just do 

typedef u32 can_mailbox_number;

etc.

> +typedef struct {
> +	u16 u16extendedidentifier;
> +	u16 u16baseidentifier;
> +	u8 u8data7;
> +	u8 u8data6;
> +	u8 u8data5;
> +	u8 u8data4;
> +	u8 u8data3;
> +	u8 u8data2;
> +	u8 u8data1;
> +	u8 u8data0;
> +	u16 u16datalength;
> +	u16 u16crc;
> +} can_mail_box_structure;

Please don't use typedef for complex data structures, and learn about
better naming of identifiers. I would suggest writing this as

struct pru_can_mailbox {
	u16	ext_id;
	u16	base_id;
	u8	data[8]; /* note: reverse order */
	u16	len;
	u16	crc;
};

Sames rules apply to the other structures.

	Arnd
