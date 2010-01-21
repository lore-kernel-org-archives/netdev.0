From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Thu, 21 Jan 2010 21:15:05 +0100
Message-ID: <4B58B5C9.3050707@grandegger.com>
References: <1264039999-25731-1-git-send-email-agust@denx.de> <1264039999-25731-3-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dzu@denx.de, wd@denx.de,
	John Rigby <jcrigby@gmail.com>,
	Piotr Ziecik <kosmo@semihalf.com>, linuxppc-dev@ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:52776 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab0AUUQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 15:16:14 -0500
In-Reply-To: <1264039999-25731-3-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anatolij,

I had a close look...

Anatolij Gustschin wrote:
>     drivers/net/fs_enet/*
>         Enable fs_enet driver to work 5121 FEC
>         Enable it with CONFIG_FS_ENET_MPC5121_FEC
> 
> Signed-off-by: John Rigby <jcrigby@gmail.com>
> Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> Cc: <linuxppc-dev@ozlabs.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> ---
> Changes since previous submited version:
> 
> - explicit type usage in register tables.
> - don't use same variable name "fecp" for variables of
>   different types.
> - avoid re-checking the compatible by passing data pointer
>   in the match struct.
> 
>  drivers/net/fs_enet/Kconfig        |   10 +-
>  drivers/net/fs_enet/fs_enet-main.c |    4 +
>  drivers/net/fs_enet/fs_enet.h      |   40 +++++++-
>  drivers/net/fs_enet/mac-fec.c      |  212 +++++++++++++++++++++++++-----------
>  drivers/net/fs_enet/mii-fec.c      |   76 ++++++++++---
>  drivers/net/fs_enet/mpc5121_fec.h  |   64 +++++++++++
>  drivers/net/fs_enet/mpc8xx_fec.h   |   37 ++++++
>  7 files changed, 356 insertions(+), 87 deletions(-)
>  create mode 100644 drivers/net/fs_enet/mpc5121_fec.h
>  create mode 100644 drivers/net/fs_enet/mpc8xx_fec.h
> 
> diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
> index 562ea68..fc073b5 100644
> --- a/drivers/net/fs_enet/Kconfig
> +++ b/drivers/net/fs_enet/Kconfig
> @@ -1,9 +1,13 @@
>  config FS_ENET
>         tristate "Freescale Ethernet Driver"
> -       depends on CPM1 || CPM2
> +       depends on CPM1 || CPM2 || PPC_MPC512x
>         select MII
>         select PHYLIB
>  
> +config FS_ENET_MPC5121_FEC
> +	def_bool y if (FS_ENET && PPC_MPC512x)
> +	select FS_ENET_HAS_FEC
> +
>  config FS_ENET_HAS_SCC
>  	bool "Chip has an SCC usable for ethernet"
>  	depends on FS_ENET && (CPM1 || CPM2)
> @@ -16,13 +20,13 @@ config FS_ENET_HAS_FCC
>  
>  config FS_ENET_HAS_FEC
>  	bool "Chip has an FEC usable for ethernet"
> -	depends on FS_ENET && CPM1
> +	depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
>  	select FS_ENET_MDIO_FEC
>  	default y
>  
>  config FS_ENET_MDIO_FEC
>  	tristate "MDIO driver for FEC"
> -	depends on FS_ENET && CPM1
> +	depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
>  
>  config FS_ENET_MDIO_FCC
>  	tristate "MDIO driver for FCC"
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
> index c34a7e0..6bce5c8 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -1095,6 +1095,10 @@ static struct of_device_id fs_enet_match[] = {
>  #endif
>  #ifdef CONFIG_FS_ENET_HAS_FEC
>  	{
> +		.compatible = "fsl,mpc5121-fec",
> +		.data = (void *)&fs_fec_ops,
> +	},
> +	{
>  		.compatible = "fsl,pq1-fec-enet",
>  		.data = (void *)&fs_fec_ops,
>  	},
> diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
> index ef01e09..df935e8 100644
> --- a/drivers/net/fs_enet/fs_enet.h
> +++ b/drivers/net/fs_enet/fs_enet.h
> @@ -13,11 +13,47 @@
>  
>  #ifdef CONFIG_CPM1
>  #include <asm/cpm1.h>
> +#endif
> +
> +#if defined(CONFIG_FS_ENET_HAS_FEC)
> +#include <asm/cpm.h>
> +#include "mpc8xx_fec.h"
> +#include "mpc5121_fec.h"

Do we really need the new header files? Why not adding the struct
definitions here or use "struct fec" from 8xx_immap.h. See below.

>  struct fec_info {
> -	fec_t __iomem *fecp;
> +	void __iomem *fecp;

A name like fec_base or base_addr would help to avoid confusion with a
pointer to the old fec struct.

> +	u32 __iomem *fec_r_cntrl;
> +	u32 __iomem *fec_ecntrl;
> +	u32 __iomem *fec_ievent;
> +	u32 __iomem *fec_mii_data;
> +	u32 __iomem *fec_mii_speed;
>  	u32 mii_speed;
>  };
> +
> +struct reg_tbl {

A more specific name would be nice, e.g. "fec_reg_tbl" or "fec_regs".

> +	u32 __iomem *fec_ievent;
> +	u32 __iomem *fec_imask;
> +	u32 __iomem *fec_r_des_active;
> +	u32 __iomem *fec_x_des_active;
> +	u32 __iomem *fec_r_des_start;
> +	u32 __iomem *fec_x_des_start;
> +	u32 __iomem *fec_r_cntrl;
> +	u32 __iomem *fec_ecntrl;
> +	u32 __iomem *fec_ivec;
> +	u32 __iomem *fec_mii_speed;
> +	u32 __iomem *fec_addr_low;
> +	u32 __iomem *fec_addr_high;
> +	u32 __iomem *fec_hash_table_high;
> +	u32 __iomem *fec_hash_table_low;
> +	u32 __iomem *fec_r_buff_size;
> +	u32 __iomem *fec_r_bound;
> +	u32 __iomem *fec_r_fstart;
> +	u32 __iomem *fec_x_fstart;
> +	u32 __iomem *fec_fun_code;
> +	u32 __iomem *fec_r_hash;
> +	u32 __iomem *fec_x_cntrl;
> +	u32 __iomem *fec_dma_control;
> +};
>  #endif
>  
>  #ifdef CONFIG_CPM2
> @@ -113,7 +149,9 @@ struct fs_enet_private {
>  		struct {
>  			int idx;		/* FEC1 = 0, FEC2 = 1  */
>  			void __iomem *fecp;	/* hw registers        */

See above.

> +			struct reg_tbl *rtbl;	/* used registers table */
>  			u32 hthi, htlo;		/* state for multicast */
> +			u32 fec_id;
>  		} fec;
>  
>  		struct {
> diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
> index a664aa1..fe9e368 100644
> --- a/drivers/net/fs_enet/mac-fec.c
> +++ b/drivers/net/fs_enet/mac-fec.c
> @@ -64,29 +64,40 @@
>  #endif
>  
>  /* write */
> -#define FW(_fecp, _reg, _v) __fs_out32(&(_fecp)->fec_ ## _reg, (_v))
> +#define FW(_regp, _reg, _v) __fs_out32((_regp)->fec_ ## _reg, (_v))
>  
>  /* read */
> -#define FR(_fecp, _reg)	__fs_in32(&(_fecp)->fec_ ## _reg)
> +#define FR(_regp, _reg)	__fs_in32((_regp)->fec_ ## _reg)
>  
>  /* set bits */
> -#define FS(_fecp, _reg, _v) FW(_fecp, _reg, FR(_fecp, _reg) | (_v))
> +#define FS(_regp, _reg, _v) FW(_regp, _reg, FR(_regp, _reg) | (_v))
>  
>  /* clear bits */
> -#define FC(_fecp, _reg, _v) FW(_fecp, _reg, FR(_fecp, _reg) & ~(_v))
> +#define FC(_regp, _reg, _v) FW(_regp, _reg, FR(_regp, _reg) & ~(_v))
> +
> +/* register address macros */
> +#define fec_reg_addr(_type, _reg) \
> +	(fep->fec.rtbl->fec_##_reg = (u32 __iomem *)((u32)fep->fec.fecp + \
> +				(u32)&((__typeof__(_type) *)NULL)->fec_##_reg))

I think you don't need the cast in the first line and using "offsetof"
would simplify the macro further. I would also use _fep as first
argument to make this macro function more transparent.

> +#define fec_reg_mpc8xx(_reg) \
> +	fec_reg_addr(struct mpc8xx_fec, _reg)
> +
> +#define fec_reg_mpc5121(_reg) \
> +	fec_reg_addr(struct mpc5121_fec, _reg)

Also, s/fec_reg_addr/fec_set_reg_addr/ would give the three macros above
a more appropriate name.

>  /*
>   * Delay to wait for FEC reset command to complete (in us)
>   */
>  #define FEC_RESET_DELAY		50
>  
> -static int whack_reset(fec_t __iomem *fecp)
> +static int whack_reset(struct reg_tbl *regp)
>  {
>  	int i;
>  
> -	FW(fecp, ecntrl, FEC_ECNTRL_PINMUX | FEC_ECNTRL_RESET);
> +	FW(regp, ecntrl, FEC_ECNTRL_PINMUX | FEC_ECNTRL_RESET);
>  	for (i = 0; i < FEC_RESET_DELAY; i++) {
> -		if ((FR(fecp, ecntrl) & FEC_ECNTRL_RESET) == 0)
> +		if ((FR(regp, ecntrl) & FEC_ECNTRL_RESET) == 0)
>  			return 0;	/* OK */
>  		udelay(1);
>  	}
> @@ -106,6 +117,50 @@ static int do_pd_setup(struct fs_enet_private *fep)
>  	if (!fep->fcc.fccp)
>  		return -EINVAL;
>  
> +	fep->fec.rtbl = kzalloc(sizeof(*fep->fec.rtbl), GFP_KERNEL);
> +	if (!fep->fec.rtbl) {
> +		iounmap(fep->fec.fecp);
> +		return -ENOMEM;
> +	}

Any reason why not adding the struct directly to fep->fec? It would save
some code for alloc/free and the addresses would be "closer" (cache wise).

> +	if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec")) {
> +		fep->fec.fec_id = FS_ENET_MPC5121_FEC;
> +		fec_reg_mpc5121(ievent);
> +		fec_reg_mpc5121(imask);
> +		fec_reg_mpc5121(r_cntrl);
> +		fec_reg_mpc5121(ecntrl);
> +		fec_reg_mpc5121(r_des_active);
> +		fec_reg_mpc5121(x_des_active);
> +		fec_reg_mpc5121(r_des_start);
> +		fec_reg_mpc5121(x_des_start);
> +		fec_reg_mpc5121(addr_low);
> +		fec_reg_mpc5121(addr_high);
> +		fec_reg_mpc5121(hash_table_high);
> +		fec_reg_mpc5121(hash_table_low);
> +		fec_reg_mpc5121(r_buff_size);
> +		fec_reg_mpc5121(mii_speed);
> +		fec_reg_mpc5121(x_cntrl);
> +		fec_reg_mpc5121(dma_control);
> +	} else {
> +		fec_reg_mpc8xx(ievent);
> +		fec_reg_mpc8xx(imask);
> +		fec_reg_mpc8xx(r_cntrl);
> +		fec_reg_mpc8xx(ecntrl);
> +		fec_reg_mpc8xx(mii_speed);
> +		fec_reg_mpc8xx(r_des_active);
> +		fec_reg_mpc8xx(x_des_active);
> +		fec_reg_mpc8xx(r_des_start);
> +		fec_reg_mpc8xx(x_des_start);
> +		fec_reg_mpc8xx(ivec);
> +		fec_reg_mpc8xx(addr_low);
> +		fec_reg_mpc8xx(addr_high);
> +		fec_reg_mpc8xx(hash_table_high);
> +		fec_reg_mpc8xx(hash_table_low);
> +		fec_reg_mpc8xx(r_buff_size);
> +		fec_reg_mpc8xx(x_fstart);
> +		fec_reg_mpc8xx(r_hash);
> +		fec_reg_mpc8xx(x_cntrl);
> +	}
>  	return 0;
>  }
>  
> @@ -162,15 +217,17 @@ static void free_bd(struct net_device *dev)
>  
>  static void cleanup_data(struct net_device *dev)
>  {
> -	/* nothing */
> +	struct fs_enet_private *fep = netdev_priv(dev);
> +
> +	kfree(fep->fec.rtbl);
>  }

See above.

[snip]
> +++ b/drivers/net/fs_enet/mpc5121_fec.h
> @@ -0,0 +1,64 @@
> +/*
> + * Copyright (C) 2007,2008 Freescale Semiconductor, Inc. All rights reserved.
> + *
> + * Author: John Rigby, <jrigby@freescale.com>
> + *
> + * Modified version of drivers/net/fec.h:
> + *
> + *	fec.h  --  Fast Ethernet Controller for Motorola ColdFire SoC
> + *		   processors.
> + *
> + *	(C) Copyright 2000-2005, Greg Ungerer (gerg@snapgear.com)
> + *	(C) Copyright 2000-2001, Lineo (www.lineo.com)
> + *
> + * This is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +#ifndef MPC5121_FEC_H
> +#define MPC5121_FEC_H
> +
> +struct mpc5121_fec {
> +	u32 fec_reserved0;
> +	u32 fec_ievent;			/* Interrupt event reg */
> +	u32 fec_imask;			/* Interrupt mask reg */
> +	u32 fec_reserved1;
> +	u32 fec_r_des_active;		/* Receive descriptor reg */
> +	u32 fec_x_des_active;		/* Transmit descriptor reg */
> +	u32 fec_reserved2[3];
> +	u32 fec_ecntrl;			/* Ethernet control reg */
> +	u32 fec_reserved3[6];
> +	u32 fec_mii_data;		/* MII manage frame reg */
> +	u32 fec_mii_speed;		/* MII speed control reg */
> +	u32 fec_reserved4[7];
> +	u32 fec_mib_ctrlstat;		/* MIB control/status reg */
> +	u32 fec_reserved5[7];
> +	u32 fec_r_cntrl;		/* Receive control reg */
> +	u32 fec_reserved6[15];
> +	u32 fec_x_cntrl;		/* Transmit Control reg */
> +	u32 fec_reserved7[7];
> +	u32 fec_addr_low;		/* Low 32bits MAC address */
> +	u32 fec_addr_high;		/* High 16bits MAC address */
> +	u32 fec_opd;			/* Opcode + Pause duration */
> +	u32 fec_reserved8[10];
> +	u32 fec_hash_table_high;	/* High 32bits hash table */
> +	u32 fec_hash_table_low;		/* Low 32bits hash table */
> +	u32 fec_grp_hash_table_high;	/* High 32bits hash table */
> +	u32 fec_grp_hash_table_low;	/* Low 32bits hash table */
> +	u32 fec_reserved9[7];
> +	u32 fec_x_wmrk;			/* FIFO transmit water mark */
> +	u32 fec_reserved10;
> +	u32 fec_r_bound;		/* FIFO receive bound reg */
> +	u32 fec_r_fstart;		/* FIFO receive start reg */
> +	u32 fec_reserved11[11];
> +	u32 fec_r_des_start;		/* Receive descriptor ring */
> +	u32 fec_x_des_start;		/* Transmit descriptor ring */
> +	u32 fec_r_buff_size;		/* Maximum receive buff size */
> +	u32 fec_reserved12[26];
> +	u32 fec_dma_control;		/* DMA Endian and other ctrl */
> +};
> +
> +#define FS_ENET_MPC5121_FEC	0x1
> +
> +#endif /* MPC5121_FEC_H */
> diff --git a/drivers/net/fs_enet/mpc8xx_fec.h b/drivers/net/fs_enet/mpc8xx_fec.h
> new file mode 100644
> index 0000000..aa78445
> --- /dev/null
> +++ b/drivers/net/fs_enet/mpc8xx_fec.h
> @@ -0,0 +1,37 @@
> +/* MPC860T Fast Ethernet Controller.  It isn't part of the CPM, but
> + * it fits within the address space.
> + */
> +

The usual "#ifndef" stuff is missing, in case you keep it.

> +struct mpc8xx_fec {
> +	uint	fec_addr_low;		/* lower 32 bits of station address */
> +	ushort	fec_addr_high;		/* upper 16 bits of station address */
> +	ushort	res1;			/* reserved			    */
> +	uint	fec_hash_table_high;	/* upper 32-bits of hash table	    */
> +	uint	fec_hash_table_low;	/* lower 32-bits of hash table	    */
> +	uint	fec_r_des_start;	/* beginning of Rx descriptor ring  */
> +	uint	fec_x_des_start;	/* beginning of Tx descriptor ring  */
> +	uint	fec_r_buff_size;	/* Rx buffer size		    */
> +	uint	res2[9];		/* reserved			    */
> +	uint	fec_ecntrl;		/* ethernet control register	    */
> +	uint	fec_ievent;		/* interrupt event register	    */
> +	uint	fec_imask;		/* interrupt mask register	    */
> +	uint	fec_ivec;		/* interrupt level and vector status */
> +	uint	fec_r_des_active;	/* Rx ring updated flag		    */
> +	uint	fec_x_des_active;	/* Tx ring updated flag		    */
> +	uint	res3[10];		/* reserved			    */
> +	uint	fec_mii_data;		/* MII data register		    */
> +	uint	fec_mii_speed;		/* MII speed control register	    */
> +	uint	res4[17];		/* reserved			    */
> +	uint	fec_r_bound;		/* end of RAM (read-only)	    */
> +	uint	fec_r_fstart;		/* Rx FIFO start address	    */
> +	uint	res5[6];		/* reserved			    */
> +	uint	fec_x_fstart;		/* Tx FIFO start address	    */
> +	uint	res6[17];		/* reserved			    */
> +	uint	fec_fun_code;		/* fec SDMA function code	    */
> +	uint	res7[3];		/* reserved			    */
> +	uint	fec_r_cntrl;		/* Rx control register		    */
> +	uint	fec_r_hash;		/* Rx hash register		    */
> +	uint	res8[14];		/* reserved			    */
> +	uint	fec_x_cntrl;		/* Tx control register		    */
> +	uint	res9[0x1e];		/* reserved			    */
> +};

As mentioned above, I do not see a need for two extra header files. The
struct(s) could be added to fec.h. Also a similar "struct fec" is
already defined in "arch/powerpc/include/asm/8xx_immap.h", which could
be used instead of "struct mpc8xx_fec" above.

Wolfgang.
