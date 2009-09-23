From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 5/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 15:24:27 -0700
Message-ID: <4ABAA01B.8030102@oracle.com>
References: <1253727086-10353-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kim.xx.Lilliestierna@ericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:37022 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbZIWWXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 18:23:33 -0400
In-Reply-To: <1253727086-10353-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>
> 
> Signed-off-by: sjur.brandeland@stericsson.com
> 
> ---
>  net/caif/Kconfig            |   61 +++
>  net/caif/Makefile           |   62 +++
>  net/caif/caif_chnlif.c      |  219 ++++++++
>  net/caif/caif_chr.c         |  378 ++++++++++++++
>  net/caif/caif_config_util.c |  167 +++++++
>  net/caif/chnl_chr.c         | 1161 +++++++++++++++++++++++++++++++++++++++++++
>  net/caif/chnl_net.c         |  464 +++++++++++++++++
>  7 files changed, 2512 insertions(+), 0 deletions(-)
>  create mode 100644 net/caif/Kconfig
>  create mode 100644 net/caif/Makefile
>  create mode 100644 net/caif/caif_chnlif.c
>  create mode 100644 net/caif/caif_chr.c
>  create mode 100644 net/caif/caif_config_util.c
>  create mode 100644 net/caif/chnl_chr.c
>  create mode 100644 net/caif/chnl_net.c
> 
> diff --git a/net/caif/Kconfig b/net/caif/Kconfig
> new file mode 100644
> index 0000000..24151c1
> --- /dev/null
> +++ b/net/caif/Kconfig
> @@ -0,0 +1,61 @@
> +#
> +# CAIF net configurations
> +#
> +
> +#menu "Caif Support"
> +comment "CAIF Support"
> +
> +menuconfig CAIF
> +	tristate "Enable Caif support"
> +	default m

Does having CONFIG_CAIF=m only control kconfig menus or does it
cause some code to be built?  If the latter, then it should default
to N.

> +	---help---
> +	Say Y here if you need to a phone modem that uses CAIF as transport

	                       to use (?)                      as transport.

> +	You will also need to say yes to anny caif physical devices that your platform

	                                 any

> +	supports.
> +	This can be built as either built in or as a module, if you select to build it as module

	This can be either built-in or as a loadable module. If you ...

> +	the other CAIF parts also needs to built as modules

	                     also need to be built as modules.

> +	See Documentation/CAIF for a further explanation on how to use and configure.
> +
> +if CAIF
> +
> +config CAIF_CHARDEV
> +	tristate "CAIF character device"
> +	default CAIF
> +	---help---
> +	Say Y if you will be using the CAIF character devices,

	                                              devices.

> +	This is needed for AT type channels

	                           channels.

> +	If you select to build it as a built in then the main caif device must also be a builtin

	<end above with period>
 
> +	If unsure say Y

	<end above with period>

> +
> +config CAIF_NETDEV
> +	tristate "CAIF Network device"
> +	default CAIF
> +	---help---
> +	If you select to build it as a built in then the main caif device must also be a builtin
> +	Say Y if you will be using the CAIF based network device
> +	If unsure say Y

Please end all of those sentences with a period ('.').

> +
> +
> +config  CAIF_USE_PLAIN
> +	bool  "Use plain buffers instead of SKB in caif"
> +	default n
> +	---help---
> +	Use plain buffer to transport data
> +	Select what type of internal buffering CAIF should use,
> +	skb or plain,
> +	If unsure say y

ditto.

> +
> +config  CAIF_DEBUG
> +	bool "Enable Debug"
> +	default n
> +	--- help ---
> +	Enable the inclusion of debug code in the caif stack
> +	be aware that doing this will impact performance

ditto.

> +	If unsure say n here.
> +
> +# Include physical drivers
> +# should be broken out into its own config file
> +# source "drivers/net/caif/Kconfig"
> +source "drivers/net/caif/Kconfig"
> +endif
> +#endmenu
> diff --git a/net/caif/Makefile b/net/caif/Makefile
> new file mode 100644
> index 0000000..49696ab
> --- /dev/null
> +++ b/net/caif/Makefile
> @@ -0,0 +1,62 @@
> +ifeq ($(CONFIG_CAIF_USE_PLAIN),1)
> +CFPKT:=plain
> +else
> +CFPKT:=skbuff
> +CAIF_FLAGS+=-DCAIF_USE_SKB
> +endif
> +
> +ifeq ($(CONFIG_CAIF_DEBUG),1)
> +CAIF_FLAGS+=-DCAIF_DEBUG_ON
> +endif
> +
> +
> +ccflags-y := -DCAIF_KERNEL $(CAIF_FLAGS) -Iinclude/net/caif/ -Iinclude/net/caif/generic/ -Iinclude/linux/caif/
> +
> +
> +caif-objs :=  caif_chr.o caif_chnlif.o  caif_config_util.o \
> +	generic/cfcnfg.o generic/cfmuxl.o generic/cfctrl.o \
> +	generic/cffrml.o generic/cfveil.o generic/cflist.o  \
> +	generic/fcs.o    generic/cfserl.o generic/cfdgml.o \
> +	generic/cfspil.o generic/cfrfml.o generic/cfvidl.o \
> +	generic/cfmsll.o generic/cfutill.o  generic/cfshml.o \
> +	generic/cfloopcfg.o  generic/cflooplayer.o generic/cfsrvl.o \
> +	generic/cfpkt_$(CFPKT).o
> +
> +
> +clean-dirs:= .tmp_versions
> +
> +clean-files:= Module.symvers modules.order *.cmd *~ \
> +	generic/loopback/Module.symvers \
> +	generic/loopback/modules.order \
> +	generic/loopback/*.cmd \
> +	generic/loopback/*.o \
> +	generic/loopback/*~ \
> +	generic/Module.symvers \
> +	generic/modules.order \
> +	generic/*.cmd \
> +	generic/*.o \
> +	generic/*~
> +
> +
> +# Main caif module
> +obj-$(CONFIG_CAIF) += caif.o
> +
> +# Character device
> +obj-$(CAIF_CHRDEV) += chnl_chr.o
> +
> +# Net device
> +obj-$(CAIF_NETDEV) += chnl_net.o
> +
> +export-objs := caif_chr.o
> +
> +## Indent..  to remove all DOS cruft like CRLF and trailing spaces, and to standardize the indenting style

This should be done one time only, before it is merged into the kernel source tree.

> +indent:
> +	${MAKE} -C generic indent
> +	sh -c 'for F in *.[ch]; do cat $$F | tr -d "\r" |tr -c '\015'| sed "s/[ \t]*$$//;" > $$F.tmp; mv $$F.tmp $$F; done'
> +	${INDENT} -kr -i8 *.[ch]
> +
> +clean:
> +	${MAKE} -C generic clean
> +	rm generic/modules.order  generic/Module.symvers generic/*.cmd generic/*~ \
> +	generic/modules.order generic/Module.symvers \
> +	generic/*.o generic/loopback/*.o
> diff --git a/net/caif/caif_chnlif.c b/net/caif/caif_chnlif.c
> new file mode 100644
> index 0000000..e53ca7a
> --- /dev/null
> +++ b/net/caif/caif_chnlif.c
> @@ -0,0 +1,219 @@
> +/*
> +*      Copyright (C) ST-Ericsson AB 2009
> +*
> +*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
> +*
> +*      License terms: GNU General Public License (GPL), version 2.
> +*
> +*/
> +
> +#include <linux/skbuff.h>
> +#include "caif_kernel.h"
> +#include "caif_layer.h"
> +#include "caif_config_util.h"
> +#include "caif_log.h"
> +#include "cfpkt.h"
> +#include "cfcnfg.h"
> +#include "cfglue.h"
> +
> +
> +
> +struct caif_kernelif {
> +	layer_t layer;
> +	struct caif_device *dev;
> +	cfctrl_link_param_t param;
> +};
> +static cfcnfg_t *cnfg;
> +/**
> + * func chnlif_set_cnfg - Set the global config
> + * @cfg:	Config structure to set
> +*/
> +
> +void chnlif_set_cnfg(cfcnfg_t *cfg)
> +{
> +	cnfg = cfg;
> +}
> +EXPORT_SYMBOL(chnlif_set_cnfg);
> +
> +/**
> + * func caif_create_skb - Creates a caif skb buffer
> + * @data:	data to add to buffer
> + * @data_length: lenht of data

                    length

---
~Randy
