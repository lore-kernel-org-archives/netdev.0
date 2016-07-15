From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [net-next 1/6] libcxgb: add library module for Chelsio drivers
Date: Fri, 15 Jul 2016 09:02:46 -0500
Message-ID: <099101d1dea1$904de520$b0e9af60$@opengridcomputing.com>
References: <cover.1467998292.git.varun@chelsio.com> <594492b4038d92cf80ce1bd54f55c4adb5bc1da5.1467998292.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<target-devel@vger.kernel.org>, <nab@linux-iscsi.org>,
	<gerlitz.or@gmail.com>, <james.bottomley@hansenpartnership.com>,
	<indranil@chelsio.com>
To: "'Varun Prakash'" <varun@chelsio.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:56555 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751811AbcGOOCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 10:02:42 -0400
In-Reply-To: <594492b4038d92cf80ce1bd54f55c4adb5bc1da5.1467998292.git.varun@chelsio.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Add common library module(libcxgb.ko) for
> Chelsio drivers to remove duplicate code.
> 
> Code for iSCSI DDP Page Pod Manager is moved
> from cxgb4.ko to libcxgb.ko. Earlier only cxgbit.ko
> was using this code, now cxgb3i and cxgb4i will
> also use common Page Pod manager code.
> 
> In future this module will have common connection
> management and hardware specific code that can be
> shared by multiple Chelsio drivers.
> 
> Signed-off-by: Varun Prakash <varun@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/Kconfig               | 18 ++++++----------
>  drivers/net/ethernet/chelsio/Makefile              |  1 +
>  drivers/net/ethernet/chelsio/cxgb4/Makefile        |  1 -
>  drivers/net/ethernet/chelsio/libcxgb/Makefile      |  3 +++
>  .../{cxgb4/cxgb4_ppm.c => libcxgb/libcxgb_ppm.c}   | 25
++++++++++++++++++++--
>  .../{cxgb4/cxgb4_ppm.h => libcxgb/libcxgb_ppm.h}   |  8 +++----
>  drivers/target/iscsi/cxgbit/Kconfig                |  2 +-
>  drivers/target/iscsi/cxgbit/Makefile               |  1 +
>  drivers/target/iscsi/cxgbit/cxgbit.h               |  2 +-
>  9 files changed, 41 insertions(+), 20 deletions(-)
>  create mode 100644 drivers/net/ethernet/chelsio/libcxgb/Makefile
>  rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.c =>
> libcxgb/libcxgb_ppm.c} (95%)
>  rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.h =>
> libcxgb/libcxgb_ppm.h} (98%)
> 
> diff --git a/drivers/net/ethernet/chelsio/Kconfig
> b/drivers/net/ethernet/chelsio/Kconfig
> index 4686a85..1a5ce1e 100644
> --- a/drivers/net/ethernet/chelsio/Kconfig
> +++ b/drivers/net/ethernet/chelsio/Kconfig
> @@ -96,17 +96,6 @@ config CHELSIO_T4_DCB
> 
>  	  If unsure, say N.
> 
> -config CHELSIO_T4_UWIRE
> -	bool "Unified Wire Support for Chelsio T5 cards"
> -	default n
> -	depends on CHELSIO_T4
> -	---help---
> -	  Enable unified-wire offload features.
> -	  Say Y here if you want to enable unified-wire over Ethernet
> -	  in the driver.
> -
> -	  If unsure, say N.
> -
>  config CHELSIO_T4_FCOE
>  	bool "Fibre Channel over Ethernet (FCoE) Support for Chelsio T5 cards"
>  	default n
> @@ -137,4 +126,11 @@ config CHELSIO_T4VF
>  	  To compile this driver as a module choose M here; the module
>  	  will be called cxgb4vf.
> 
> +config CHELSIO_LIB
> +	tristate "Chelsio common library"
> +	default n
> +	---help---
> +	  This is common library module for Chelsio T3/T4/T5/T6
> +	  drivers.
> +
>  endif # NET_VENDOR_CHELSIO
> diff --git a/drivers/net/ethernet/chelsio/Makefile
> b/drivers/net/ethernet/chelsio/Makefile
> index 390510b..b6a5eec 100644
> --- a/drivers/net/ethernet/chelsio/Makefile
> +++ b/drivers/net/ethernet/chelsio/Makefile
> @@ -6,3 +6,4 @@ obj-$(CONFIG_CHELSIO_T1) += cxgb/
>  obj-$(CONFIG_CHELSIO_T3) += cxgb3/
>  obj-$(CONFIG_CHELSIO_T4) += cxgb4/
>  obj-$(CONFIG_CHELSIO_T4VF) += cxgb4vf/
> +obj-$(CONFIG_CHELSIO_LIB) += libcxgb/
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile
> b/drivers/net/ethernet/chelsio/cxgb4/Makefile
> index 85c9282..ace0ab9 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
> +++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
> @@ -7,5 +7,4 @@ obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
>  cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o
>  cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
>  cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
> -cxgb4-$(CONFIG_CHELSIO_T4_UWIRE) +=  cxgb4_ppm.o
>  cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
> diff --git a/drivers/net/ethernet/chelsio/libcxgb/Makefile
> b/drivers/net/ethernet/chelsio/libcxgb/Makefile
> new file mode 100644
> index 0000000..2362230
> --- /dev/null
> +++ b/drivers/net/ethernet/chelsio/libcxgb/Makefile
> @@ -0,0 +1,3 @@
> +obj-$(CONFIG_CHELSIO_LIB) += libcxgb.o
> +
> +libcxgb-y := libcxgb_ppm.o
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
> b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
> similarity index 95%
> rename from drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
> rename to drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
> index d88a7a7..aa9a9bb 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
> +++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
> @@ -1,5 +1,5 @@
>  /*
> - * cxgb4_ppm.c: Chelsio common library for T4/T5 iSCSI PagePod Manager
> + * libcxgb_ppm.c: Chelsio common library for T3/T4/T5 iSCSI PagePod Manager
>   *
>   * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
>   *
> @@ -10,6 +10,10 @@
>   * Written by: Karen Xie (kxie@chelsio.com)
>   */
> 
> +#define DRV_NAME "libcxgb"
> +#define DRV_VERSION "1.0.0-ko"
> +#define pr_fmt(fmt) DRV_NAME ": " fmt
> +
>  #include <linux/kernel.h>
>  #include <linux/version.h>
>  #include <linux/module.h>
> @@ -22,7 +26,7 @@
>  #include <linux/pci.h>
>  #include <linux/scatterlist.h>
> 
> -#include "cxgb4_ppm.h"
> +#include "libcxgb_ppm.h"
> 
>  /* Direct Data Placement -
>   * Directly place the iSCSI Data-In or Data-Out PDU's payload into
> @@ -462,3 +466,20 @@ unsigned int cxgbi_tagmask_set(unsigned int ppmax)
> 
>  	return 1 << (bits + PPOD_IDX_SHIFT);
>  }
> +
> +static int __init libcxgb_init(void)
> +{
> +	return 0;
> +}
> +
> +static void __exit libcxgb_exit(void)
> +{
> +}
> +
> +module_init(libcxgb_init);
> +module_exit(libcxgb_exit);
> +
> +MODULE_AUTHOR("Chelsio Communications");
> +MODULE_DESCRIPTION("Chelsio common library");
> +MODULE_VERSION(DRV_VERSION);
> +MODULE_LICENSE("GPL");

This should be "Dual BSD/GPL" I think.

Other than this and the kconfig issue Dave raised, this patch looks good.

Reviewed-by: Steve Wise <swise@opengridcomputing.com>
