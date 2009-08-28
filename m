From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] net-next:can: add TI CAN (HECC) driver
Date: Fri, 28 Aug 2009 14:44:54 +0200
Message-ID: <4A97D146.5050806@hartkopp.net>
References: <1251458282-4674-1-git-send-email-anantgole@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: Anant Gole <anantgole@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:47053 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbZH1Moz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 08:44:55 -0400
In-Reply-To: <1251458282-4674-1-git-send-email-anantgole@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anant Gole wrote:
> TI HECC (High End CAN Controller) module is found on many TI devices. It has
> 32 harwdare mailboxes with full implementation of CAN protocol version 2.0B
> and bus speeds up to 1Mbps. The module specifications are available at TI web
> <http://www.ti.com>.
> 
> This driver is tested on OMAP3517 EVM. Suspend/Resume not tested as yet.
> 

Hello Anant,

some nitpicking first:

> +#include <linux/can/platform/ti_hecc_platform.h>

Please use

linux/can/platform/ti_hecc.c

following the other drivers.

> +
> +#define DRV_NAME "TI HECC"

DRV_NAME "ti_hecc"

like your module is called in various places in the Kernel.

This could be used later in

> +static struct platform_driver ti_hecc_driver = {
> +	.driver = {
> +		.name    = "ti_hecc",
> +		.owner   = THIS_MODULE,
> +	},

also.

And it's better for this:


> +/* CAN Bittiming constants as per HECC specs */
> +static struct can_bittiming_const ti_hecc_bittiming_const = {
> +	.name = DRV_NAME,
> +	.tseg1_min = 1,
> (..)


> +
> +#ifdef CONFIG_DEBUG_FS
> +
> +static struct ti_hecc_priv *debug_priv;
> +
> +#define PRINTMBOXREG(r) seq_printf(s, "%d\t%08X %08X %08X %08X %08X\n", r,\
> +	hecc_read(debug_priv, HECC_CANMID(r)),\
> +	hecc_read(debug_priv, HECC_CANMCF(r)),\
> +	hecc_read(debug_priv, HECC_CANMDH(r)),\
> +	hecc_read(debug_priv, HECC_CANMDL(r)),\
> +	hecc_read(debug_priv, HECC_CANLAM(r)))
> +
> +/* Print mailbox data */
> +static void hecc_print_mbox_regs(struct seq_file *s)
> +{
> +	int cnt = 0;
> +	static struct ti_hecc_priv *priv;
> +	priv = debug_priv;
> +	seq_printf(s, "\n--- %s %s - mailbox regs ---\n\n",
> +		DRV_NAME, HECC_MODULE_VERSION);
> +	seq_printf(s, "MbxNo\tMID\t MCF\t  MDH\t   MDL\t   LAM\n");
> +	seq_printf(s, "-----------------------------------------------\n");
> +	for (cnt = 0; cnt < HECC_MAX_MAILBOXES; cnt++)
> +		PRINTMBOXREG(cnt);
> +}
> +
> +#define PRINTREG(d, r) seq_printf(s, "%s\t%08x\n", d, hecc_read(debug_priv, r))
> +/* Print HECC registers */
> +static void hecc_print_regs(struct seq_file *s)
> +{

I discovered lot's of debug code (>20%).

Is this really needed?



> +static char *hecc_debug_can_state[] = {
> +	"CAN_STATE_ERROR_ACTIVE",
> +	"CAN_STATE_ERROR_WARNING",
> +	"CAN_STATE_ERROR_PASSIVE",
> +	"CAN_STATE_BUS_OFF",
> +	"CAN_STATE_STOPPED",
> +	"CAN_STATE_SLEEPING",
> +	"CAN_STATE_MAX"
> +};

Hm - defining this in a driver looks like a bad idea.

Maybe we could move this to the CAN driver interface depending on

CONFIG_CAN_DEBUG_DEVICES

?!?


> +
> +/* Print status and statistics */
> +static void hecc_print_status(struct seq_file *s)
> +{
> +	seq_printf(s, "\n--- %s %s - status ---\n\n",
> +		DRV_NAME, HECC_MODULE_VERSION);
> +	seq_printf(s, "\n--- ti_hecc status ---\n\n");
> +	seq_printf(s, "CAN state \t\t= %s\n",
> +		hecc_debug_can_state[debug_priv->can.state]);
> +	seq_printf(s, "CAN restart_ms \t\t= %u\n", debug_priv->can.restart_ms);
> +	seq_printf(s, "CAN input clock \t= %u\n", debug_priv->can.clock.freq);
> +	seq_printf(s, "CAN Bittiming\n");
> +	seq_printf(s, "\tbitrate \t= %u\n",
> +			debug_priv->can.bittiming.bitrate);
> +	seq_printf(s, "\tsample_point \t= %u\n",
> +			debug_priv->can.bittiming.sample_point);
> +	seq_printf(s, "\ttq \t\t= %u\n",
> +			debug_priv->can.bittiming.tq);
> +	seq_printf(s, "\tprop_seg \t= %u\n",
> +			debug_priv->can.bittiming.prop_seg);
> +	seq_printf(s, "\tphase_seg1 \t= %u\n",
> +			debug_priv->can.bittiming.phase_seg1);
> +	seq_printf(s, "\tphase_seg2 \t= %u\n",
> +			debug_priv->can.bittiming.phase_seg2);
> +	seq_printf(s, "\tsjw \t\t= %u\n",
> +			debug_priv->can.bittiming.sjw);
> +	seq_printf(s, "\tbrp \t\t= %u\n",
> +			debug_priv->can.bittiming.brp);
> +	seq_printf(s, "CAN Bittiming Constants\n");
> +	seq_printf(s, "\ttseg1 min-max \t= %u-%u\n",
> +			debug_priv->can.bittiming_const->tseg1_min,
> +			debug_priv->can.bittiming_const->tseg1_max);
> +	seq_printf(s, "\ttseg2 min-max \t= %u-%u\n",
> +			debug_priv->can.bittiming_const->tseg2_min,
> +			debug_priv->can.bittiming_const->tseg2_max);
> +	seq_printf(s, "\tsjw_max \t= %u\n",
> +			debug_priv->can.bittiming_const->sjw_max);
> +	seq_printf(s, "\tbrp min-max \t= %u-%u\n",
> +			debug_priv->can.bittiming_const->brp_min,
> +			debug_priv->can.bittiming_const->brp_max);
> +	seq_printf(s, "\tbrp_inc \t= %u\n",
> +			debug_priv->can.bittiming_const->brp_inc);

(..)

And this could be also a candidate to be in the CAN driver interface.

@Wolfgang: Any preferences to this idea?


> +
> +/** Toggle HECC Self-Test i.e loopback bit
> + * INFO: Reading this debug variable toggles the loopback status on the device.
> + * This is done to simplify the debug function to set looback
> + */
> +static int hecc_debug_loopback(struct seq_file *s)
> +{
> +	static int toggle;
> +
> +	/* Put module in self test mode i.e. loopback */
> +	if (toggle) {
> +		seq_printf(s, "In Self Test Mode (loopback)\n");
> +		hecc_set_bit(debug_priv, HECC_CANMC, HECC_CANMC_STM);
> +		toggle = 0;
> +	} else {
> +		seq_printf(s, "Out of Self Test Mode (NO loopback)\n");
> +		hecc_clear_bit(debug_priv, HECC_CANMC, HECC_CANMC_STM);
> +		toggle = 1;
> +	}
> +
> +	return 0;
> +}
> +

Ugh!

No. This should definitely be done by netlink.

I did not take a closer look into the device access and error handling right
now. So this was just my first impression :-)

Thanks,
Oliver
