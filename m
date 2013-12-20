From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 2/4] misc: xgene: Add base driver for APM X-Gene SoC
 Queue Manager/Traffic Manager
Date: Thu, 19 Dec 2013 19:20:02 -0800
Message-ID: <20131220032002.GA32310@kroah.com>
References: <1387507503-7565-1-git-send-email-rapatel@apm.com>
 <1387507503-7565-3-git-send-email-rapatel@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd-r2nGTMty4D4@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1387507503-7565-3-git-send-email-rapatel-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 19, 2013 at 06:45:01PM -0800, Ravi Patel wrote:
> --- /dev/null
> +++ b/drivers/misc/xgene/qmtm/Kconfig
> @@ -0,0 +1,8 @@
> +config XGENE_QMTM
> +	tristate "APM X-Gene QMTM driver"
> +	depends on ARCH_XGENE

What does it need from this arch in order to build?  What would be
needed to get it to build on other arches so that it gets some actualy
build testing?


> --- /dev/null
> +++ b/drivers/misc/xgene/qmtm/xgene_qmtm_main.c
> @@ -0,0 +1,765 @@
> +/*
> + * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
> + *
> + * Copyright (c) 2013 Applied Micro Circuits Corporation.
> + * Author: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
> + *         Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
> + *
> + * This program is free software; you can redistribute  it and/or modify it
> + * under  the terms of  the GNU General  Public License as published by the
> + * Free Software Foundation;  either version 2 of the  License, or (at your
> + * option) any later version.

Are you _sure_ about "any later version"?  I have to ask.

> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.

No need for this paragraph, the kernel has a copy of the GPL in it
already.

> +/* CSR Address Macros */
> +#define CSR_QM_CONFIG_ADDR                                           0x00000004
> +#define  QM_ENABLE_WR(src)                      (((u32)(src)<<31) & 0x80000000)
> +
> +#define CSR_PBM_ADDR                                                 0x00000008
> +#define  OVERWRITE_WR(src)                      (((u32)(src)<<31) & 0x80000000)
> +#define  SLVID_PBN_WR(src)                          (((u32)(src)) & 0x000003ff)
> +#define  SLAVE_ID_SHIFT                                                       6

Interesting way to align #defines, that's going to break badly over
time, please just left align them like the rest of the kernel, using
tabs.

> +EXPORT_SYMBOL(xgene_qmtm_set_qinfo);

EXPORT_SYMBOL_GPL() for this and the other exports perhaps?  (sorry, I
have to ask.)

> +/*
> + * Physical or free pool queue state (pq or fp)
> + */
> +struct storm_qmtm_pq_fp_qstate {
> +	/* word 0 31:0 */
> +	u32 resize_qid:10;
> +	u32 resize_start:1;
> +	u32 resize_done:1;
> +	u32 cfgtmvqen:1;	/* enable pq to belong to vq */
> +	u32 cfgtmvq:10;		/* parent vq */
> +	u32 cfgsaben:1;		/* enable SAB broadcasting */
> +	u32 cpu_notify:8;	/* cfgcpusab */
> +
> +	/* word 1 63:32 */
> +	u32 cfgnotifyqne:1;	/* enable queue not empty interrupt */
> +	u32 nummsg:16;
> +	u32 headptr:15;
> +
> +	/* word 2 95:64 */
> +	u32 cfgcrid:1;
> +	u32 rid:3;
> +	u32 qcoherent:1;
> +	u64 cfgstartaddr:34;	/* 27/7 split */
> +
> +	/* word 3 127:96 */
> +	u32 vc_chanctl:2;
> +	u32 vc_chanid:2;
> +	u32 slot_pending:6;
> +	u32 stashing:1;
> +	u32 reserved_0:1;
> +	u32 cfgacceptlerr:1;
> +	u32 fp_mode:3;		/* free pool mode */
> +	u32 cfgqsize:3;		/* queue size, see xgene_qmtm_qsize */
> +	u32 qstatelock:1;
> +	u32 cfgRecombBuf:1;
> +	u32 cfgRecombBufTimeoutL:4;	/* 4/3 split */
> +
> +	/* word 4 159:128 */
> +	u32 cfgRecombBufTimeoutH:3;	/* 4/3 split */
> +	u32 cfgselthrsh:3;	/* associated threshold set */
> +	u32 resv2:13;
> +	u32 cfgqtype:2;		/* queue type, refer xgene_qmtm_qtype */
> +	u32 resv1:11;
> +} __packed;

u64 for a bitfield?  Is that even valid C?  This is pretty scary from a
bitfield perspective, what about different endian and addressing modes?

Any chance to just use shifts to access the fields properly, like most
drivers do, in a endian-neutral way to get the data out and into the
structures?

Same goes for the other structures in this file.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
