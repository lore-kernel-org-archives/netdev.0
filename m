From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net-next:can: add TI CAN (HECC) driver
Date: Sat, 29 Aug 2009 09:06:22 +0200
Message-ID: <4A98D36E.9070903@grandegger.com>
References: <2A3DCF3DA181AD40BDE86A3150B27B6B02F621106B@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Socketcan-core@lists.berlios.de
To: "Gole, Anant" <anantgole@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:45278 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbZH2HGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:06:25 -0400
In-Reply-To: <2A3DCF3DA181AD40BDE86A3150B27B6B02F621106B@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> TI HECC (High End CAN Controller) module is found on many TI devices. It has
> 32 harwdare mailboxes with full implementation of CAN protocol version 2.0B
> and bus speeds up to 1Mbps. The module specifications are available at TI web
> <http://www.ti.com>.
> 
> This driver is tested on OMAP3517 EVM. Suspend/Resume not tested as yet.

Nice driver, even using the NAPI interface. First some general comments.
Please remove debugging code mainly useful for development, e.g. the
CONFIG_DEBUG_FS block, many dev_info calls and special statistics
counters. Also use dev_dbg for the remaining debug messages useful for
the normal user, like state changes. More comments inline.

> 
> Signed-off-by: Anant Gole <anantgole@ti.com>
> ---
>  drivers/net/can/Kconfig                       |    9 +
>  drivers/net/can/Makefile                      |    2 +
>  drivers/net/can/ti_hecc.c                     | 1352 +++++++++++++++++++++++++
>  include/linux/can/platform/ti_hecc_platform.h |   40 +
>  4 files changed, 1403 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/ti_hecc.c
>  create mode 100644 include/linux/can/platform/ti_hecc_platform.h
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 30ae55d..fae62df 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -75,6 +75,15 @@ config CAN_KVASER_PCI
>           This driver is for the the PCIcanx and PCIcan cards (1, 2 or
>           4 channel) from Kvaser (http://www.kvaser.com).
> 
> +config CAN_TI_HECC
> +        depends on CAN_DEV
> +        tristate "TI High End CAN Controller (HECC)"
> +        default N
> +        ---help---
> +         This driver adds support for TI High End CAN Controller module
> +         found on many TI devices. The specifications of this module are
> +         are available from TI web (http://www.ti.com)
> +
>  config CAN_DEBUG_DEVICES
>         bool "CAN devices debugging messages"
>         depends on CAN
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 523a941..d923512 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -9,4 +9,6 @@ can-dev-y                       := dev.o
> 
>  obj-$(CONFIG_CAN_SJA1000)      += sja1000/
> 
> +obj-$(CONFIG_CAN_TI_HECC)      += ti_hecc.o
> +
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> new file mode 100644
> index 0000000..4741b4a
> --- /dev/null
> +++ b/drivers/net/can/ti_hecc.c
> @@ -0,0 +1,1352 @@
> +/*
> + * TI HECC (CAN) device driver
> + *
> + * This driver supports TI's HECC (High End CAN Controller module) and the
> + * specs for the same is available at <http://www.ti.com>
> + *
> + * Copyright (C) 2009 Texas Instruments Incorporated - http://www.ti.com/
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed as is WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *

It would be nice if you could mention the related platform data here,
similar to the mcp251x.c driver.

> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/types.h>
> +#include <linux/fcntl.h>
> +#include <linux/interrupt.h>
> +#include <linux/ptrace.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/skbuff.h>
> +#include <linux/delay.h>
> +#include <linux/platform_device.h>
> +#include <linux/clk.h>
> +#include <linux/io.h>
> +#include <linux/debugfs.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +#include <linux/can/platform/ti_hecc_platform.h>
> +
> +#define DRV_NAME "TI HECC"

#define DRV_NAME "ti_hecc"

Other drivers also use the file name here.

> +#define HECC_MODULE_VERSION     "0.2"

A version number is will usually not maintained. May drivers have it but
it's never changed.

> +MODULE_VERSION(HECC_MODULE_VERSION);
> +#define DRV_DESC "TI High End CAN Controller Driver " HECC_MODULE_VERSION
> +
> +#define HECC_MAX_MAILBOXES     32      /* hardware mboxes - do not change */
> +
> +#if (CAN_ECHO_SKB_MAX > 16)
> +#define TI_HECC_MAX_TX_MBOX    16
> +#else
> +#define TI_HECC_MAX_TX_MBOX    CAN_ECHO_SKB_MAX
> +#endif
> +#define TI_HECC_MAX_RX_MBOX    (HECC_MAX_MAILBOXES - TI_HECC_MAX_TX_MBOX)
> +
> +#define TI_HECC_DEF_NAPI_WEIGHT        TI_HECC_MAX_RX_MBOX
> +
> +/* TI HECC module registers */
> +
> +#define HECC_CANME             0x0     /* Mailbox enable */
> +#define HECC_CANMD             0x4     /* Mailbox direction */
> +#define HECC_CANTRS            0x8     /* Transmit request set */
> +#define HECC_CANTRR            0xC     /* Transmit request */
> +#define HECC_CANTA             0x10    /* Transmission acknowledge */
> +#define HECC_CANAA             0x14    /* Abort acknowledge */
> +#define HECC_CANRMP            0x18    /* Receive message pending */
> +#define HECC_CANRML            0x1C    /* Remote message lost */
> +#define HECC_CANRFP            0x20    /* Remote frame pending */
> +#define HECC_CANGAM            0x24    /* SECC only:Global acceptance mask */
> +#define HECC_CANMC             0x28    /* Master control */
> +#define HECC_CANBTC            0x2C    /* Bit timing configuration */
> +#define HECC_CANES             0x30    /* Error and status */
> +#define HECC_CANTEC            0x34    /* Transmit error counter */
> +#define HECC_CANREC            0x38    /* Receive error counter */
> +#define HECC_CANGIF0           0x3C    /* Global interrupt flag 0 */
> +#define HECC_CANGIM            0x40    /* Global interrupt mask */
> +#define HECC_CANGIF1           0x44    /* Global interrupt flag 1 */
> +#define HECC_CANMIM            0x48    /* Mailbox interrupt mask */
> +#define HECC_CANMIL            0x4C    /* Mailbox interrupt level */
> +#define HECC_CANOPC            0x50    /* Overwrite protection control */
> +#define HECC_CANTIOC           0x54    /* Transmit I/O control */
> +#define HECC_CANRIOC           0x58    /* Receive I/O control */
> +#define HECC_CANLNT            0x5C    /* HECC only: Local network time */
> +#define HECC_CANTOC            0x60    /* HECC only: Time-out control */
> +#define HECC_CANTOS            0x64    /* HECC only: Time-out status */
> +#define HECC_CANTIOCE          0x68    /* SCC only:Enhanced TX I/O control */
> +#define HECC_CANRIOCE          0x6C    /* SCC only:Enhanced RX I/O control */
> +
> +/* SCC only:Local acceptance registers */
> +#define HECC_CANLAM0           (priv->scc_ram_offset + 0x0)
> +#define HECC_CANLAM3           (priv->scc_ram_offset + 0xC)
> +
> +/* HECC only */
> +#define HECC_CANLAM(mbxno)     (priv->hecc_ram_offset + ((mbxno) * 4))
> +#define HECC_CANMOTS(mbxno)    (priv->hecc_ram_offset + ((mbxno) * 4) + 0x80)
> +#define HECC_CANMOTO(mbxno)    (priv->hecc_ram_offset + ((mbxno) * 4) + 0x100)
> +
> +/* Mailbox registers */
> +#define HECC_CANMID(mbxno)     (priv->mbox_offset + ((mbxno) * 0x10))
> +#define HECC_CANMCF(mbxno)     (priv->mbox_offset + ((mbxno) * 0x10) + 0x4)
> +#define HECC_CANMDL(mbxno)     (priv->mbox_offset + ((mbxno) * 0x10) + 0x8)
> +#define HECC_CANMDH(mbxno)     (priv->mbox_offset + ((mbxno) * 0x10) + 0xC)
> +
> +#define HECC_SET_REG           0xFFFFFFFF
> +#define HECC_CANID_MASK                0x3FF   /* 18 bits mask for extended id's */
> +
> +#define HECC_CANMC_SCM         BIT(13) /* SCC compat mode */
> +#define HECC_CANMC_CCR         BIT(12) /* Change config request */
> +#define HECC_CANMC_PDR         BIT(11) /* Local Power down - for sleep mode */
> +#define HECC_CANMC_ABO         BIT(7)  /* Auto Bus On */
> +#define HECC_CANMC_STM         BIT(6)  /* Self test mode - loopback */
> +#define HECC_CANMC_SRES                BIT(5)  /* Software reset */
> +
> +#define HECC_CANTIOC_EN                BIT(3)  /* Enable CAN TX I/O pin */
> +#define HECC_CANRIOC_EN                BIT(3)  /* Enable CAN RX I/O pin */
> +
> +#define HECC_CANMID_IDE                BIT(31) /* Extended frame format */
> +#define HECC_CANMID_AME                BIT(30) /* Acceptance mask enable */
> +#define HECC_CANMID_AAM                BIT(29) /* Auto answer mode */
> +
> +#define HECC_CANES_FE          BIT(24) /* form error */
> +#define HECC_CANES_BE          BIT(23) /* bit error */
> +#define HECC_CANES_SA1         BIT(22) /* stuck at dominant error */
> +#define HECC_CANES_CRCE                BIT(21) /* CRC error */
> +#define HECC_CANES_SE          BIT(20) /* stuff bit error */
> +#define HECC_CANES_ACKE                BIT(19) /* ack error */
> +#define HECC_CANES_BO          BIT(18) /* Bus off status */
> +#define HECC_CANES_EP          BIT(17) /* Error passive status */
> +#define HECC_CANES_EW          BIT(16) /* Error warning status */
> +#define HECC_CANES_SMA         BIT(5)  /* suspend mode ack */
> +#define HECC_CANES_CCE         BIT(4)  /* Change config enabled */
> +#define HECC_CANES_PDA         BIT(3)  /* Power down mode ack */
> +
> +#define HECC_CANBTC_SAM                BIT(7)  /* sample points */
> +
> +#define HECC_BUS_ERROR         (HECC_CANES_FE | HECC_CANES_BE |\
> +                               HECC_CANES_CRCE | HECC_CANES_SE |\
> +                               HECC_CANES_ACKE)
> +
> +#define HECC_CANMCF_RTR                BIT(4)  /* Remote xmit request */
> +
> +#define HECC_CANGIF_MAIF       BIT(17) /* Message alarm interrupt */
> +#define HECC_CANGIF_TCOIF      BIT(16) /* Timer counter overflow int */
> +#define HECC_CANGIF_GMIF       BIT(15) /* Global mailbox interrupt */
> +#define HECC_CANGIF_AAIF       BIT(14) /* Abort ack interrupt */
> +#define HECC_CANGIF_WDIF       BIT(13) /* Write denied interrupt */
> +#define HECC_CANGIF_WUIF       BIT(12) /* Wake up interrupt */
> +#define HECC_CANGIF_RMLIF      BIT(11) /* Receive message lost interrupt */
> +#define HECC_CANGIF_BOIF       BIT(10) /* Bus off interrupt */
> +#define HECC_CANGIF_EPIF       BIT(9)  /* Error passive interrupt */
> +#define HECC_CANGIF_WLIF       BIT(8)  /* Warning level interrupt */
> +#define HECC_CANGIF_MBOX_MASK  0x1F    /* Mailbox number mask */
> +#define HECC_CANGIM_I1EN       BIT(1)  /* Int line 1 enable */
> +#define HECC_CANGIM_I0EN       BIT(0)  /* Int line 0 enable */
> +#define HECC_CANGIM_DEF_MASK   0xFF00  /* all except maif and tcoif */
> +#define HECC_CANGIM_SIL                BIT(2)  /* system interrupts to int line 1 */
> +
> +/* CAN Bittiming constants as per HECC specs */
> +static struct can_bittiming_const ti_hecc_bittiming_const = {
> +       .name = DRV_NAME,
> +       .tseg1_min = 1,
> +       .tseg1_max = 16,
> +       .tseg2_min = 1,

Please check if tseg2_min is a valid value. Usually it's larger.

> +       .tseg2_max = 8,
> +       .sjw_max = 4,
> +       .brp_min = 1,
> +       .brp_max = 256,
> +       .brp_inc = 1,
> +};
> +
> +struct ti_hecc_priv {
> +       struct can_priv can;

Please add "must be the first member/field".

> +       struct napi_struct napi;
> +       struct net_device *ndev;
> +       struct clk *clk;
> +       void __iomem *base;
> +       unsigned int scc_ram_offset;
> +       unsigned int hecc_ram_offset;
> +       unsigned int mbox_offset;
> +       unsigned int int_line;
> +       DECLARE_BITMAP(tx_free_mbx, TI_HECC_MAX_TX_MBOX);
> +       spinlock_t tx_lock;

Please document the spinlock tx_lock. What is it used for.

> +
> +       /* Statistics */
> +       unsigned out_of_tx_mbox;
> +       unsigned write_denied_cnt;
> +       unsigned message_lost_cnt;
> +       unsigned wake_up_cnt;
> +       unsigned message_alarm_cnt;
> +       unsigned timer_overflow_cnt;#

Debugging!? Should be removed. There is no interface to list these fields.

> +};
> +
> +static inline
> +void hecc_write(struct ti_hecc_priv *priv, int reg, unsigned int val)
> +{
> +       __raw_writel(val, priv->base + reg);
> +}
> +
> +static inline unsigned int hecc_read(struct ti_hecc_priv *priv, int reg)
> +{
> +       return __raw_readl(priv->base + reg);
> +}
> +
> +static inline
> +void hecc_set_bit(struct ti_hecc_priv *priv, int reg, unsigned bit)
> +{
> +       hecc_write(priv, reg, (hecc_read(priv, reg) | bit));
> +}
> +
> +static inline
> +void hecc_clear_bit(struct ti_hecc_priv *priv, int reg, unsigned bit)
> +{
> +       hecc_write(priv, reg, (hecc_read(priv, reg) & ~bit));
> +}
> +
> +static inline
> +unsigned int hecc_get_bit(struct ti_hecc_priv *priv, int reg, int bit)
> +{
> +       return (hecc_read(priv, reg) & bit) ? 1 : 0;
> +}
> +
[snip]
> +
> +static int ti_hecc_get_state(const struct net_device *ndev,
> +       enum can_state *state)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       *state = priv->can.state;
> +       return 0;
> +}
> +
> +static int ti_hecc_set_bittiming(struct net_device *ndev)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       struct can_bittiming *bit_timing = &priv->can.bittiming;
> +       unsigned int can_btc = 0;
> +
> +       can_btc = ((bit_timing->phase_seg2 - 1) & 0x7);
> +       can_btc |= (((bit_timing->phase_seg1 + bit_timing->prop_seg - 1)
> +                       & 0xF) << 3);
> +       if (bit_timing->brp > 4)
> +               can_btc |= HECC_CANBTC_SAM;

Please use:

	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
	          can_btc |= HECC_CANBTC_SAM;

CAN controller modes can be set via "ip" utility. Note that also
loopback and listen-only is supported.

> +       can_btc |= (((bit_timing->sjw - 1) & 0x3) << 8);
> +       can_btc |= (((bit_timing->brp - 1) & 0xFF) << 16);
> +
> +       /* ERM being set to 0 by default meaning resync at falling edge */
> +
> +       hecc_write(priv, HECC_CANBTC, can_btc);

Other drivers use dev_info here:

	dev_info(ND2D(dev), "setting CANBTC=%#x\n", can_btc);


> +       return 0;
> +}
> +
> +/**
> + * ti_hecc_reset: Reset HECC module and set bit timings
> + *
> + * Resets HECC by writing to change config request bit and then sets
> + * bit-timing registers in the module to enable the module for operation
> + */
> +static void ti_hecc_reset(struct net_device *ndev)
> +{
> +#define HECC_CCE_WAIT_COUNT    1000
> +       unsigned int cnt;
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +       dev_dbg(ndev->dev.parent, "resetting hecc ...\n");
> +
> +       hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_SRES);
> +
> +       /* if change control request not enabled */
> +       if (!hecc_get_bit(priv, HECC_CANES, HECC_CANES_CCE)) {
> +               /* Set change control request and wait till enabled */
> +               hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +
> +               /* INFO: It has been observed that at times CCE bit may not be
> +                * set and hw seems to be ok even if this bit is not set so
> +                * timing out with a large counter to respect the specs
> +                */
> +               cnt = HECC_CCE_WAIT_COUNT;
> +               while (!hecc_get_bit(priv, HECC_CANES, HECC_CANES_CCE)) {
> +                       --cnt;
> +                       if (0 == cnt) {
> +                               dev_info(ndev->dev.parent,
> +                                       "timing out on CCE after reset\n");
> +                               break;
> +                       }
> +                       if (printk_ratelimit())
> +                               dev_dbg(ndev->dev.parent,
> +                                       "waiting CCE after reset\n");

I think you don't need the ratelimit if you check after the while loop.

> +               }

The while loop above does not use any defined delay and therefore the
timing depends on the processor speed. Adding udelay(1|10) would solve
the issue.

> +       }
> +



> +       /* Set bit timing on the device */
> +       ti_hecc_set_bittiming(priv->ndev);

Hm, you re-set the bittiming here!? It is alread done via netlink
interface before the device is opened/started.

> +
> +       /* Clear CCR (and CANMC register) and wait for CCE = 0 enable */
> +       hecc_write(priv, HECC_CANMC, 0);
> +
> +       /* INFO: CAN net stack handles bus off and hence disabling auto bus on
> +       hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_ABO);
> +       */

Right, automatic bus-off recovery should be disabled. To make that clear:

           hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_ABO);


> +       /* Wait till CCE bit clears */
> +       /* INFO: It has been observed that at times CCE bit may not be
> +        * set and hw seems to be ok even if this bit is not set so
> +        * timing out with a large counter to respect the specs
> +        */
> +       cnt = HECC_CCE_WAIT_COUNT;
> +       while (hecc_get_bit(priv, HECC_CANES, HECC_CANES_CCE)) {
> +               --cnt;
> +               if (0 == cnt) {
> +                       dev_info(ndev->dev.parent,
> +                               "timing out on CCE after bittiming\n");
> +                       break;
> +               }
> +               if (printk_ratelimit())
> +                       dev_dbg(ndev->dev.parent,
> +                               "waiting CCE after bittiming\n");
> +       }

Consider adding a udelay(1|10) as mentioned above.

> +       /* Enable TX and RX I/O Control pins */
> +       hecc_write(priv, HECC_CANTIOC, HECC_CANTIOC_EN);
> +       hecc_write(priv, HECC_CANRIOC, HECC_CANRIOC_EN);
> +
> +       /* Clear registers for clean operation */
> +       hecc_write(priv, HECC_CANTA, HECC_SET_REG);
> +       hecc_write(priv, HECC_CANRMP, HECC_SET_REG);
> +       hecc_write(priv, HECC_CANGIF0, HECC_SET_REG);
> +       hecc_write(priv, HECC_CANGIF1, HECC_SET_REG);
> +       hecc_write(priv, HECC_CANME, 0);
> +       hecc_write(priv, HECC_CANMD, 0);
> +
> +       /* SCC compat mode NOT supported (and not needed too) */
> +       hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_SCM);
> +}
> +
> +/**
> + * ti_hecc_start: Starts HECC module
> + *
> + * If CAN state is not stopped, reset the module, init bit timings
> + * and start the device for operation
> + */
> +static void ti_hecc_start(struct net_device *ndev)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       int cnt, mbxno;
> +
> +       ti_hecc_reset(ndev);
> +
> +       bitmap_zero(priv->tx_free_mbx, TI_HECC_MAX_TX_MBOX);
> +
> +       /* Enable local and global acceptance mask registers */
> +       hecc_write(priv, HECC_CANGAM, HECC_SET_REG);
> +       hecc_write(priv, HECC_CANLAM0, HECC_SET_REG);
> +       hecc_write(priv, HECC_CANLAM3, HECC_SET_REG);
> +
> +       /* Prepare configured mailboxes to receive messages */
> +       for (cnt = 0; cnt < TI_HECC_MAX_RX_MBOX; cnt++) {
> +               mbxno = (HECC_MAX_MAILBOXES - 1 - cnt);
> +               hecc_clear_bit(priv, HECC_CANME, (1 << mbxno));
> +               hecc_write(priv, HECC_CANMID(mbxno), HECC_CANMID_AME);
> +               hecc_write(priv, HECC_CANLAM(mbxno), HECC_SET_REG);
> +               hecc_set_bit(priv, HECC_CANMD, (1 << mbxno));
> +               hecc_set_bit(priv, HECC_CANME, (1 << mbxno));
> +               hecc_set_bit(priv, HECC_CANMIM, (1 << mbxno));
> +       }
> +
> +       /* Prevent message over-write & Enable interrupts */
> +       hecc_write(priv, HECC_CANTRS, 0);
> +       hecc_write(priv, HECC_CANOPC, HECC_SET_REG);
> +       if (priv->int_line) {
> +               hecc_write(priv, HECC_CANMIL, HECC_SET_REG);
> +               hecc_write(priv, HECC_CANGIM, (HECC_CANGIM_DEF_MASK |
> +                       HECC_CANGIM_I1EN | HECC_CANGIM_SIL));
> +       } else {
> +               hecc_write(priv, HECC_CANMIL, 0);
> +               hecc_write(priv, HECC_CANGIM,
> +                       (HECC_CANGIM_DEF_MASK | HECC_CANGIM_I0EN));
> +       }
> +       priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +}
> +
> +static void ti_hecc_stop(struct net_device *ndev)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +       /* Disable interrupts and disable mailboxes */
> +       hecc_write(priv, HECC_CANGIM, 0);
> +       hecc_write(priv, HECC_CANMIM, 0);
> +       hecc_write(priv, HECC_CANME, 0);
> +       priv->can.state = CAN_STATE_STOPPED;
> +}
> +
> +static int ti_hecc_do_set_mode(struct net_device *ndev, enum can_mode mode)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       int ret = 0;
> +
> +       switch (mode) {
> +       case CAN_MODE_SLEEP:
> +               dev_info(priv->ndev->dev.parent, "device going to sleep\n");
> +               if (netif_running(ndev)) {
> +                       netif_stop_queue(ndev);
> +                       netif_device_detach(ndev);
> +                       /* Put HECC in low power mode */
> +                       hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
> +               }
> +               priv->can.state = CAN_STATE_SLEEPING;
> +               break;

Has sleeping been tested? Actually, we do not have an interface yet to
enter sleep mode. Please remove. If there is a need for it, we should
work togehter to refine the interface and to provide a solution.

> +       case CAN_MODE_STOP:
> +               dev_info(priv->ndev->dev.parent, "device stopping\n");
> +               ti_hecc_stop(ndev);
> +               break;

Only CAN_MODE_START is used by the CAN devicde interface for bus-off
recovery.

> +       case CAN_MODE_START:
> +               dev_info(priv->ndev->dev.parent, "device (re)starting\n");
> +               ++priv->can.can_stats.restarts;
> +               ti_hecc_start(ndev);
> +               if (netif_queue_stopped(ndev))
> +                       netif_wake_queue(ndev);
> +               break;
> +       default:
> +               ret = -EOPNOTSUPP;
> +               break;
> +       }
> +
> +       return ret;
> +}
> +
> +static int ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       struct net_device_stats *stats = &ndev->stats;
> +       struct can_frame *cf = (struct can_frame *)skb->data;
> +       u32 mbxno = 0;
> +       u32 data;
> +       unsigned long flags;
> +
> +       /* Find the first mailbox that is free for xmit */
> +       spin_lock_irqsave(&priv->tx_lock, flags);
> +       mbxno = find_first_zero_bit(priv->tx_free_mbx, TI_HECC_MAX_TX_MBOX);
> +       if (mbxno == TI_HECC_MAX_TX_MBOX) {
> +               netif_stop_queue(ndev);
> +               if (printk_ratelimit())
> +                       dev_err(priv->ndev->dev.parent,
> +                               "Out of TX buffers ...\n");
> +               spin_unlock_irqrestore(&priv->tx_lock, flags);
> +               return NETDEV_TX_BUSY;

Could'nt the NETDEV_TX_BUSY be avoided by stopping the queue earlier?

> +
> +       }
> +       set_bit(mbxno, priv->tx_free_mbx);
> +       spin_unlock_irqrestore(&priv->tx_lock, flags);

Hm, I wonder how the driver ensures that packages go out in order. How
does the CAN hardware schedule pending TX message objects? Vladislav
posted a test programs recently to check message ordering. See:

https://lists.berlios.de/pipermail/socketcan-core/2009-August/002871.html

> +
> +       /* Prepare mailbox for transmission */
> +       hecc_clear_bit(priv, HECC_CANME, (1 << mbxno));
> +       data = cf->can_dlc & 0xF;
> +       if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
> +               data |= HECC_CANMCF_RTR;
> +       hecc_write(priv, HECC_CANMCF(mbxno), data);
> +       if (cf->can_id & CAN_EFF_FLAG) { /* Extended frame format */
> +               data = ((cf->can_id & CAN_EFF_MASK) | HECC_CANMID_IDE);
> +       } else { /* Standard frame format */
> +               data = ((cf->can_id & CAN_SFF_MASK) << 18);
> +       }
> +       hecc_write(priv, HECC_CANMID(mbxno), data);
> +       data = (cf->data[0] << 24) | (cf->data[1] << 16) |
> +                       (cf->data[2] << 8) | cf->data[3];
> +       hecc_write(priv, HECC_CANMDL(mbxno), data);
> +       if (cf->can_dlc > 4) {
> +               data = (cf->data[4] << 24) | (cf->data[5] << 16) |
> +                       (cf->data[6] << 8) | cf->data[7];
> +               hecc_write(priv, HECC_CANMDH(mbxno), data);
> +       }
> +
[slip]
> +
> +       /* Enable interrupt for mbox and start transmission */
> +       hecc_clear_bit(priv, HECC_CANMD, (1 << mbxno));
> +       hecc_set_bit(priv, HECC_CANME, (1 << mbxno));
> +       hecc_set_bit(priv, HECC_CANMIM, (1 << mbxno));
> +       hecc_set_bit(priv, HECC_CANTRS, (1 << mbxno));
> +
> +       stats->tx_bytes += cf->can_dlc;

Should be done when the TX done interrupr is handled.

> +       ndev->trans_start = jiffies;
> +       can_put_echo_skb(skb, ndev, mbxno);

Please call can_put_echo_skb() before starting transmission.

> +
> +       return NETDEV_TX_OK;
> +}
> +
> +static int ti_hecc_rx_pkt(struct ti_hecc_priv *priv, int mbxno)
> +{
> +       struct net_device_stats *stats = &priv->ndev->stats;
> +       struct can_frame *cf;
> +       struct sk_buff *skb;
> +       u32 data;
> +
> +       skb = dev_alloc_skb(sizeof(struct can_frame));
> +       if (!skb) {
> +               if (printk_ratelimit())
> +                       dev_err(priv->ndev->dev.parent,
> +                               "dev_alloc_skb() failed\n");
> +               return -ENOMEM;
> +       }
> +       skb->dev = priv->ndev;
> +       skb->protocol = htons(ETH_P_CAN);
> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
> +       cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
> +       memset(cf, 0, sizeof(struct can_frame));
> +       data = hecc_read(priv, HECC_CANMID(mbxno));
> +       if (data & HECC_CANMID_IDE)
> +               cf->can_id = (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +       else
> +               cf->can_id = ((data >> 18) & CAN_SFF_MASK);
> +       data = hecc_read(priv, HECC_CANMCF(mbxno));
> +       if (data & HECC_CANMCF_RTR)
> +               cf->can_id |= CAN_RTR_FLAG;
> +       cf->can_dlc = data & 0xF;
> +       data = hecc_read(priv, HECC_CANMDL(mbxno));
> +       /* The below statements are for readability sake */
> +       cf->data[0] = ((data & 0xFF000000) >> 24);
> +       cf->data[1] = ((data & 0xFF0000) >> 16);
> +       cf->data[2] = ((data & 0xFF00) >> 8);
> +       cf->data[3] = (data & 0xFF);
> +       if (cf->can_dlc > 4) {
> +               data = hecc_read(priv, HECC_CANMDH(mbxno));
> +               cf->data[4] = ((data & 0xFF000000) >> 24);
> +               cf->data[5] = ((data & 0xFF0000) >> 16);
> +               cf->data[6] = ((data & 0xFF00) >> 8);
> +               cf->data[7] = (data & 0xFF);
> +       }
> +
[snip]
> +
> +       /* prepare mailbox for next receive */
> +       hecc_clear_bit(priv, HECC_CANME, (1 << mbxno));
> +       hecc_write(priv, HECC_CANMID(mbxno), HECC_CANMID_AME);
> +       hecc_write(priv, HECC_CANLAM(mbxno), HECC_SET_REG);
> +       hecc_set_bit(priv, HECC_CANMD, (1 << mbxno));
> +       hecc_set_bit(priv, HECC_CANME, (1 << mbxno));
> +
> +       stats->rx_bytes += cf->can_dlc;
> +       netif_rx(skb);

Hm, IIRC, netif_receive_skb(skb) should be used with NAPI.

> +       stats->rx_packets++;
> +       priv->ndev->last_rx = jiffies;
> +
> +       return 0;
> +}
> +
> +static int ti_hecc_rx_poll(struct napi_struct *napi, int quota)
> +{
> +       struct net_device *ndev = napi->dev;
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       int num_pkts = 0;
> +       unsigned long pending_pkts;
> +       int mbxno;
> +
> +       if (!netif_running(ndev))
> +               return 0;
> +
> +       pending_pkts = hecc_read(priv, HECC_CANRMP);
> +       while (pending_pkts && (num_pkts < quota)) {
> +               mbxno = find_first_bit(&pending_pkts, HECC_MAX_MAILBOXES);

Here I also wonder if the messages are handled in the correct order.

> +               if (mbxno == HECC_MAX_MAILBOXES) {
> +                       dev_info(priv->ndev->dev.parent,
> +                               "Reached max mailboxes. No rx pkts\n");
> +                       return num_pkts;
> +               }
> +
> +               if (ti_hecc_rx_pkt(priv, mbxno) < 0)
> +                       return num_pkts;
> +
> +               clear_bit(mbxno, &pending_pkts);
> +               hecc_set_bit(priv, HECC_CANRMP, (1 << mbxno));
> +               ++num_pkts;
> +       }
> +
> +       /* Enable packet interrupt if all pkts are handled */
> +       if (0 == hecc_read(priv, HECC_CANRMP)) {
> +               napi_complete(napi);
> +               /* Re-enable RX mailbox interrupts */
> +               mbxno = hecc_read(priv, HECC_CANMIM);
> +               mbxno |= (~((1 << TI_HECC_MAX_TX_MBOX) - 1));
> +               hecc_write(priv, HECC_CANMIM, mbxno);
> +       }
> +
> +       return num_pkts;
> +}
> +
> +/**
> + * ti_hecc_error: TI HECC error routine
> + *
> + * Handles HECC error - handles error condition and send a packet up the stack
> + */
> +static int
> +ti_hecc_error(struct net_device *ndev, int int_status, int err_status)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       struct net_device_stats *stats = &ndev->stats;
> +       struct can_frame *cf;
> +       struct sk_buff *skb;
> +       int data;
> +
> +       /* propogate the error condition to the can stack */
> +       skb = dev_alloc_skb(sizeof(struct can_frame));
> +       if (!skb) {
> +               if (printk_ratelimit())
> +                       dev_err(priv->ndev->dev.parent,
> +                               "dev_alloc_skb() failed in err processing\n");
> +               return -ENOMEM;
> +       }
> +       skb->dev = ndev;
> +       skb->protocol = htons(ETH_P_CAN);
> +       cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
> +       memset(cf, 0, sizeof(struct can_frame));
> +       cf->can_id = CAN_ERR_FLAG;
> +       cf->can_dlc = CAN_ERR_DLC;
> +
> +       if (int_status & HECC_CANGIF_RMLIF) { /* Message lost interrupt */
> +               data = hecc_read(priv, HECC_CANRML);
> +               hecc_write(priv, HECC_CANRML, data);
> +               ++priv->message_lost_cnt;

Debugging!?

> +               cf->can_id |= CAN_ERR_CRTL;
> +               cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
> +               stats->rx_over_errors++;
> +               stats->rx_errors++;
> +               dev_info(priv->ndev->dev.parent, "Message lost interrupt\n");

Debugging!?

> +       }
> +
> +       if (int_status & HECC_CANGIF_WLIF) { /* warning level int */
> +               if (0 == (int_status & HECC_CANGIF_BOIF)) {
> +                       priv->can.state = CAN_STATE_ERROR_WARNING;
> +                       ++priv->can.can_stats.error_warning;
> +                       cf->can_id |= CAN_ERR_CRTL;
> +                       if (hecc_read(priv, HECC_CANTEC) > 96)
> +                               cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
> +                       if (hecc_read(priv, HECC_CANREC) > 96)
> +                               cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
> +               }
> +               hecc_set_bit(priv, HECC_CANES, HECC_CANES_EW);
> +               dev_info(priv->ndev->dev.parent, "Error Warning interrupt\n");
> +               hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +       }
> +
> +       if (int_status & HECC_CANGIF_EPIF) { /* error passive int */
> +               if (0 == (int_status & HECC_CANGIF_BOIF)) {
> +                       priv->can.state = CAN_STATE_ERROR_PASSIVE;
> +                       ++priv->can.can_stats.error_passive;
> +                       cf->can_id |= CAN_ERR_CRTL;
> +                       if (hecc_read(priv, HECC_CANTEC) > 127)
> +                               cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
> +                       if (hecc_read(priv, HECC_CANREC) > 127)
> +                               cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
> +               }
> +               hecc_set_bit(priv, HECC_CANES, HECC_CANES_EP);
> +               dev_info(priv->ndev->dev.parent, "Error passive interrupt\n");

Please use dev_dbg.

> +               hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +       }
> +
> +       /* Need to check busoff condition in error status register too to
> +        * ensure warning interrupts don't hog the system
> +        */
> +       if (int_status & HECC_CANGIF_BOIF) {
> +               priv->can.state = CAN_STATE_BUS_OFF;
> +               cf->can_id |= CAN_ERR_BUSOFF;
> +               hecc_set_bit(priv, HECC_CANES, HECC_CANES_BO);
> +               dev_info(priv->ndev->dev.parent, "Bus Off interrupt\n");

can_bus_off() already calls dev_dbg("bus-off").


> +               hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +               can_bus_off(ndev);
> +               /* Disable all interrupts in bus-off to avoid int hog */
> +               hecc_write(priv, HECC_CANGIM, 0);
> +       }
> +
> +       if (err_status & HECC_CANES_BO) {
> +               priv->can.state = CAN_STATE_BUS_OFF;
> +               cf->can_id |= CAN_ERR_BUSOFF;
> +               hecc_set_bit(priv, HECC_CANES, HECC_CANES_BO);
> +               dev_info(priv->ndev->dev.parent, "Bus Off condition\n");
> +               hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +               can_bus_off(ndev);
> +               /* Disable all interrupts in bus-off to avoid int hog */
> +               hecc_write(priv, HECC_CANGIM, 0);
> +       }

I think the two if blocks above use idendical code. What is the
difference. Using if (a || b) would be more appropriate.

> +
> +       if (err_status & HECC_BUS_ERROR) {
> +               ++priv->can.can_stats.bus_error;
> +               cf->can_id |= (CAN_ERR_BUSERROR | CAN_ERR_PROT);
> +               cf->data[2] |= CAN_ERR_PROT_UNSPEC;
> +               if (err_status & HECC_CANES_FE) {
> +                       hecc_set_bit(priv, HECC_CANES, HECC_CANES_FE);
> +                       cf->data[2] |= CAN_ERR_PROT_FORM;
> +               }
> +               if (err_status & HECC_CANES_BE) {
> +                       hecc_set_bit(priv, HECC_CANES, HECC_CANES_BE);
> +                       cf->data[2] |= CAN_ERR_PROT_BIT;
> +               }
> +               if (err_status & HECC_CANES_SE) {
> +                       hecc_set_bit(priv, HECC_CANES, HECC_CANES_SE);
> +                       cf->data[2] |= CAN_ERR_PROT_STUFF;
> +               }
> +               if (err_status & HECC_CANES_CRCE) {
> +                       hecc_set_bit(priv, HECC_CANES, HECC_CANES_CRCE);
> +                       cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> +                                       CAN_ERR_PROT_LOC_CRC_DEL);
> +               }
> +               if (err_status & HECC_CANES_ACKE) {
> +                       hecc_set_bit(priv, HECC_CANES, HECC_CANES_ACKE);
> +                       cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
> +                                       CAN_ERR_PROT_LOC_ACK_DEL);
> +               }
> +       }
> +
> +       netif_receive_skb(skb);

OK, here you use netif_receive_skb().

> +       ndev->last_rx = jiffies;
> +       stats->rx_packets++;
> +       stats->rx_bytes += cf->can_dlc;
> +       return 0;
> +}

At a first glance, error message creation looks good. I will have a
closer look some time later.

> +
> +/**
> + * ti_hecc_interrupt: TI HECC interrupt routine
> + *
> + * Handles HECC interrupts - disables interrupt if receive pkts that will
> + * be enabled when rx pkts are compelte (napi_complete is done)
> + */
> +static irqreturn_t ti_hecc_interrupt(int irq, void *dev_id)
> +{
> +       struct net_device *ndev = (struct net_device *)dev_id;
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       struct net_device_stats *stats = &ndev->stats;
> +       struct sk_buff *skb;
> +       struct can_frame *cf;
> +       unsigned int int_status;
> +       unsigned long ack;
> +       int mbxno;
> +       unsigned long flags;
> +
> +       if (priv->int_line)
> +               int_status = hecc_read(priv, HECC_CANGIF1);
> +       else
> +               int_status = hecc_read(priv, HECC_CANGIF0);
> +
> +       if (0 == int_status)
> +               return IRQ_NONE;
> +
> +       /* Handle message alarm interrupt */
> +       if (int_status & HECC_CANGIF_MAIF) {
> +               ++priv->message_alarm_cnt;
> +               dev_info(priv->ndev->dev.parent, "Message alarm interrupt\n");
> +       }
> +
> +       /* Handle local network timer counter overflow interrupt */
> +       if (int_status & HECC_CANGIF_TCOIF) {
> +               ++priv->timer_overflow_cnt;
> +               dev_info(priv->ndev->dev.parent,
> +                       "Local network timer counter overflow interrupt\n");
> +       }
> +
> +       /* Handle write denied interrupt */
> +       if (int_status & HECC_CANGIF_WDIF) {
> +               ++priv->write_denied_cnt;
> +               dev_info(priv->ndev->dev.parent, "Write denied interrupt\n");
> +       }
> +
> +       /* Handle wake up interrupt */
> +       if (int_status & HECC_CANGIF_WUIF) {
> +               ++priv->wake_up_cnt;
> +               dev_info(priv->ndev->dev.parent, "Wake up interrupt\n");
> +       }

Do the interrupt sources above occur. Does it harm or even signal a
malfunctioning? If yes, use dev_err and dev_dbg otherwise. And as
mentioned above, the statistic counters are most likely for debugging
purposes only.

> +
> +       ti_hecc_error(ndev, int_status, hecc_read(priv, HECC_CANES));

Hm, you create an error frame for each interrupt!? What do you see with:

 # candump any,0:0,#FFFFFFFF

> +
> +       /* Handle Abort acknowledge interrupt */
> +       if (int_status & HECC_CANGIF_AAIF) {
> +               ack = hecc_read(priv, HECC_CANAA);
> +               while (ack) {
> +                       mbxno = find_first_bit(&ack, HECC_MAX_MAILBOXES);
> +                       if (mbxno == HECC_MAX_MAILBOXES) {
> +                               break;
> +                       } else {
> +                               clear_bit(mbxno, &ack);
> +                               /* release echo pkt & update counters */
> +                               hecc_set_bit(priv, HECC_CANAA, (1 << mbxno));
> +                               hecc_clear_bit(priv, HECC_CANME, (1 << mbxno));
> +                               /* FIXME: since net-next tree's dev.h does not
> +                                * include can_free_echo_skb() doing equivalent
> +                                * of can_free_echo_skb(ndev, mbxno);
> +                                */
> +                               if (priv->can.echo_skb[mbxno]) {
> +                                       kfree_skb(priv->can.echo_skb[mbxno]);
> +                                       priv->can.echo_skb[mbxno] = NULL;
> +                               }
> +                               if (netif_queue_stopped(ndev))
> +                                       netif_wake_queue(ndev);
> +                               spin_lock_irqsave(&priv->tx_lock, flags);
> +                               clear_bit(mbxno, priv->tx_free_mbx);
> +                               spin_unlock_irqrestore(&priv->tx_lock, flags);
> +                       }
> +               }
> +       }

Can that interrupt happen? I have not found any code aborting messages.

> +
> +       /* Handle mailbox interrupt */
> +       if (int_status & HECC_CANGIF_GMIF) {
> +               ack = hecc_read(priv, HECC_CANTA);
> +               while (ack) {
> +                       mbxno = find_first_bit(&ack, HECC_MAX_MAILBOXES);
> +                       if (mbxno == HECC_MAX_MAILBOXES) {
> +                               break;
> +                       } else {
> +                               clear_bit(mbxno, &ack);
> +                               hecc_clear_bit(priv, HECC_CANME, (1 << mbxno));
> +                               hecc_set_bit(priv, HECC_CANTA, (1 << mbxno));
> +                               skb = priv->can.echo_skb[mbxno];
> +                               cf = (struct can_frame *) (skb->data);

Please don't access the echo skb's directly. Try to get the dlc from the
hardware.

> +                               can_get_echo_skb(ndev, mbxno);
> +                               stats->tx_bytes += cf->can_dlc;
> +                               spin_lock_irqsave(&priv->tx_lock, flags);
> +                               clear_bit(mbxno, priv->tx_free_mbx);
> +                               spin_unlock_irqrestore(&priv->tx_lock, flags);
> +                               stats->tx_packets++;
> +                       }
> +               }
> +               if (netif_queue_stopped(ndev))
> +                       netif_wake_queue(ndev);
> +
> +               /* Disable RX mailbox interrupts and let NAPI reenable them */
> +               ack = hecc_read(priv, HECC_CANMIM);
> +               ack &= ((1 << TI_HECC_MAX_TX_MBOX) - 1);
> +               hecc_write(priv, HECC_CANMIM, ack);
> +               napi_schedule(&priv->napi);

You schedule an RX event even if no RX message is pending? This does not
look very efficient to me.

> +       }
> +
> +       /* clear all interrupt conditions - read back to avoid spurious ints */
> +       if (priv->int_line) {
> +               hecc_write(priv, HECC_CANGIF1, HECC_SET_REG);
> +               int_status = hecc_read(priv, HECC_CANGIF1);
> +       } else {
> +               hecc_write(priv, HECC_CANGIF0, HECC_SET_REG);
> +               int_status = hecc_read(priv, HECC_CANGIF0);
> +       }
> +
> +       return IRQ_HANDLED;
> +}
> +
> +/* NOTE: yet to test suspend/resume */

Please remove suspend/resume code if it's not tested.

> +static int ti_hecc_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +       struct net_device *ndev = platform_get_drvdata(pdev);
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +       if (netif_running(ndev)) {
> +               netif_stop_queue(ndev);
> +               netif_device_detach(ndev);
> +       }
> +
> +       hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
> +       priv->can.state = CAN_STATE_SLEEPING;
> +       clk_disable(priv->clk);
> +
> +       return 0;
> +}
> +
> +/* NOTE: yet to test suspend/resume */
> +static int ti_hecc_resume(struct platform_device *pdev)
> +{
> +       struct net_device *ndev = platform_get_drvdata(pdev);
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +       clk_enable(priv->clk);
> +       hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
> +       priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +       if (netif_running(ndev)) {
> +               netif_device_attach(ndev);
> +               netif_start_queue(ndev);
> +       }
> +
> +       return 0;
> +}
> +
> +static int ti_hecc_open(struct net_device *ndev)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +       int err;
> +
> +       dev_info(ndev->dev.parent, "opening device\n");
> +
> +       if (request_irq(ndev->irq, ti_hecc_interrupt, IRQF_DISABLED,
> +                               ndev->name, ndev)) {
> +               dev_err(ndev->dev.parent, "error requesting interrupt\n");
> +               return -EAGAIN;

Please return the error returned by request_irq.

> +       }
> +
> +       /* Open common can device */
> +       err = open_candev(ndev);
> +       if (err) {
> +               dev_err(ndev->dev.parent, "open_candev() failed %08X\n", err);

free_irq?

> +               return err;
> +       }
> +
> +       /* Initialize device and start net queue */
> +       spin_lock_init(&priv->tx_lock);
> +
> +       clk_enable(priv->clk);
> +       ti_hecc_start(ndev);
> +       napi_enable(&priv->napi);
> +       netif_start_queue(ndev);
> +
> +       return 0;
> +}
> +
> +static int ti_hecc_close(struct net_device *ndev)
> +{
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +       dev_info(ndev->dev.parent, "closing device\n");
> +       napi_disable(&priv->napi);
> +       netif_stop_queue(ndev);
> +       ti_hecc_stop(ndev);
> +       free_irq(ndev->irq, ndev);
> +       clk_disable(priv->clk);
> +       close_candev(ndev);
> +
> +       return 0;
> +}
> +
> +static const struct net_device_ops ti_hecc_netdev_ops = {
> +       .ndo_open               = ti_hecc_open,
> +       .ndo_stop               = ti_hecc_close,
> +       .ndo_start_xmit         = ti_hecc_xmit,
> +};
> +
> +static int ti_hecc_probe(struct platform_device *pdev)
> +{
> +       struct net_device *ndev = (struct net_device *)0;
> +       struct ti_hecc_priv *priv;
> +       struct ti_hecc_platform_data *pdata;
> +       struct resource *mem, *irq;
> +       void __iomem *addr;
> +       int err;
> +
> +       printk(KERN_INFO DRV_NAME " probing devices...\n");
> +       pdata = pdev->dev.platform_data;
> +       if (!pdata) {
> +               printk(KERN_ERR "No platform data available - exiting\n");

dev_err here and below.is more appropriate.

> +               return -ENODEV;
> +       }
> +
> +       mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       if (!mem) {
> +               printk(KERN_ERR "no mem resource?\n");
> +               err = -ENODEV;
> +               goto probe_exit;
> +       }
> +       irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +       if (!irq) {
> +               printk(KERN_ERR "no irq resource?\n");
> +               err = -ENODEV;
> +               goto probe_exit;
> +       }
> +       if (!request_mem_region(mem->start, (mem->end - mem->start) + 1,
> +               pdev->name)) {
> +               printk(KERN_ERR "HECC region already claimed\n");
> +               err = -EBUSY;
> +               goto probe_exit;
> +       }
> +       addr = ioremap(mem->start, mem->end - mem->start + 1);
> +       if (!addr) {
> +               printk(KERN_ERR "ioremap failed\n");
> +               err = -ENOMEM;
> +               goto probe_exit_free_region;
> +       }
> +
> +       ndev = alloc_candev(sizeof(struct ti_hecc_priv));
> +       if (!ndev) {
> +               printk(KERN_ERR "alloc_candev failed\n");
> +               err = -ENOMEM;
> +               goto probe_exit_iounmap;
> +       }
> +
> +       priv = netdev_priv(ndev);
> +       priv->ndev = ndev;
> +       priv->base = addr;
> +       priv->scc_ram_offset = pdata->scc_ram_offset;
> +       priv->hecc_ram_offset = pdata->hecc_ram_offset;
> +       priv->mbox_offset = pdata->mbox_offset;
> +       priv->int_line = pdata->int_line;
> +
> +       priv->can.bittiming_const       = &ti_hecc_bittiming_const;
> +       priv->can.do_set_bittiming      = ti_hecc_set_bittiming;
> +       priv->can.do_set_mode           = ti_hecc_do_set_mode;
> +       priv->can.do_get_state          = ti_hecc_get_state;

Coding style!?

> +       ndev->irq = irq->start;
> +       ndev->flags |= IFF_ECHO;
> +       platform_set_drvdata(pdev, ndev);
> +       SET_NETDEV_DEV(ndev, &pdev->dev);
> +       ndev->netdev_ops = &ti_hecc_netdev_ops;
> +
> +       /* Note: clk name would change using hecc_vbusp_ck temporarily */
> +       priv->clk = clk_get(&pdev->dev, "hecc_vbusp_ck");
> +       if (IS_ERR(priv->clk)) {
> +               dev_err(ndev->dev.parent, "no clock available\n");
> +               err = PTR_ERR(priv->clk);
> +               priv->clk = NULL;
> +               goto probe_exit_candev;
> +       }
> +       priv->can.clock.freq = clk_get_rate(priv->clk);
> +       netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
> +                       TI_HECC_DEF_NAPI_WEIGHT);
> +
> +       err = register_candev(ndev);
> +       if (err) {
> +               dev_err(ndev->dev.parent, "register_candev() failed\n");
> +               err = -ENODEV;
> +               goto probe_exit_clk;
> +       }
> +       dev_info(ndev->dev.parent, "regs=%p, irq=%d\n",
> +               priv->base, (unsigned int) ndev->irq);

Please use a more meaningful message, e.g.:

	dev_info(&pdev->dev,
	         "device registered (reg_base=%#p, irq=%d)\n",
		 priv->reg_base, dev->irq);


> +
> +#ifdef CONFIG_DEBUG_FS
> +       hecc_debug_init(priv);
> +#endif
> +       return 0;
> +
> +probe_exit_clk:
> +       clk_put(priv->clk);
> +probe_exit_candev:
> +       free_candev(ndev);
> +probe_exit_iounmap:
> +       iounmap(addr);
> +probe_exit_free_region:
> +       release_mem_region(mem->start, mem->end - mem->start + 1);
> +probe_exit:
> +       dev_err(ndev->dev.parent, "probe error = %08X\n", err);
> +       return err;
> +}
> +
> +static int __devexit ti_hecc_remove(struct platform_device *pdev)
> +{
> +       struct resource *res;
> +       struct net_device *ndev = platform_get_drvdata(pdev);
> +       struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +#ifdef CONFIG_DEBUG_FS
> +       hecc_debug_exit();
> +#endif /* CONFIG_DEBUG_FS */
> +
> +       clk_put(priv->clk);
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       iounmap(priv->base);
> +       release_mem_region(res->start, res->end - res->start + 1);
> +       unregister_candev(ndev);
> +       free_candev(ndev);
> +       platform_set_drvdata(pdev, NULL);
> +       dev_info(ndev->dev.parent, "driver removed\n");
> +
> +       return 0;
> +}
> +
> +/* TI HECC netdevice driver: platform driver structure */
> +static struct platform_driver ti_hecc_driver = {
> +       .driver = {
> +               .name    = "ti_hecc",

Maybe:
                  .name    = DRV_NAME,


> +               .owner   = THIS_MODULE,
> +       },
> +       .probe = ti_hecc_probe,
> +       .remove = __devexit_p(ti_hecc_remove),
> +       .suspend = ti_hecc_suspend,
> +       .resume = ti_hecc_resume,
> +};
> +
> +static int __init ti_hecc_init_driver(void)
> +{
> +       printk(KERN_INFO DRV_DESC "\n");
> +       return platform_driver_register(&ti_hecc_driver);
> +}
> +module_init(ti_hecc_init_driver);
> +
> +static void __exit ti_hecc_exit_driver(void)
> +{
> +       printk(KERN_INFO DRV_DESC " :Exit\n");
> +       platform_driver_unregister(&ti_hecc_driver);
> +}
> +module_exit(ti_hecc_exit_driver);
> +
> +MODULE_AUTHOR("Anant Gole <anantgole@ti.com>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION(DRV_DESC);
> diff --git a/include/linux/can/platform/ti_hecc_platform.h b/include/linux/can/platform/ti_hecc_platform.h
> new file mode 100644
> index 0000000..4a57daf
> --- /dev/null
> +++ b/include/linux/can/platform/ti_hecc_platform.h
> @@ -0,0 +1,40 @@
> +/*
> + * TI HECC (High End CAN Controller) driver platform header
> + *
> + * Copyright (C) 2009 Texas Instruments Incorporated - http://www.ti.com/
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed as is WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + */
> +
> +/**
> + * struct hecc_platform_data - HECC Platform Data
> + *
> + * @scc_hecc_offset:   mostly 0 - should really never change
> + * @scc_ram_offset:    SCC RAM offset
> + * @hecc_ram_offset:   HECC RAM offset
> + * @mbox_offset:       Mailbox RAM offset
> + * @int_line:          Interrupt line to use - 0 or 1
> + * @version:           version for future use
> + *
> + * Platform data structure to get all platform specific settings.
> + * this structure also accounts the fact that the IP may have different
> + * RAM and mailbox offsets for different SOC's
> + */
> +struct ti_hecc_platform_data {
> +       unsigned int scc_hecc_offset;
> +       unsigned int scc_ram_offset;
> +       unsigned int hecc_ram_offset;
> +       unsigned int mbox_offset;
> +       unsigned int int_line;
> +       unsigned int version;
> +};

Thanks for your contribution.

Wolfgang.

