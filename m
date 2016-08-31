From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6 4/8] thunderbolt: Communication with the ICM (firmware)
Date: Wed, 31 Aug 2016 13:34:05 +0200
Message-ID: <20160831113405.GE17607@kroah.com>
References: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com>
 <1470054233-4309-5-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        thunderbolt-linux@intel.com, mika.westerberg@intel.com,
        tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470054233-4309-5-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 01, 2016 at 03:23:49PM +0300, Amir Levy wrote:
> Firmware-based (a.k.a ICM - Intel Connection Manager) controller is
> used for establishing and maintaining the Thunderbolt Networking
> connection. We need to be able to communicate with it.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/Makefile      |    1 +
>  drivers/thunderbolt/icm/Makefile  |   28 +
>  drivers/thunderbolt/icm/icm_nhi.c | 1324 +++++++++++++++++++++++++++++++++++++
>  drivers/thunderbolt/icm/icm_nhi.h |   93 +++
>  drivers/thunderbolt/icm/net.h     |  227 +++++++
>  5 files changed, 1673 insertions(+)
>  create mode 100644 drivers/thunderbolt/icm/Makefile
>  create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
>  create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
>  create mode 100644 drivers/thunderbolt/icm/net.h
> 
> diff --git a/drivers/thunderbolt/Makefile b/drivers/thunderbolt/Makefile
> index 7a85bd1..b6aa6a3 100644
> --- a/drivers/thunderbolt/Makefile
> +++ b/drivers/thunderbolt/Makefile
> @@ -1,3 +1,4 @@
>  obj-${CONFIG_THUNDERBOLT_APPLE} := thunderbolt.o
>  thunderbolt-objs := nhi.o ctl.o tb.o switch.o cap.o path.o tunnel_pci.o eeprom.o
>  
> +obj-${CONFIG_THUNDERBOLT_ICM} += icm/
> diff --git a/drivers/thunderbolt/icm/Makefile b/drivers/thunderbolt/icm/Makefile
> new file mode 100644
> index 0000000..3adfc35
> --- /dev/null
> +++ b/drivers/thunderbolt/icm/Makefile
> @@ -0,0 +1,28 @@
> +################################################################################
> +#
> +# Intel Thunderbolt(TM) driver
> +# Copyright(c) 2014 - 2016 Intel Corporation.
> +#
> +# This program is free software; you can redistribute it and/or modify it
> +# under the terms and conditions of the GNU General Public License,
> +# version 2, as published by the Free Software Foundation.
> +#
> +# This program is distributed in the hope it will be useful, but WITHOUT
> +# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> +# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> +# more details.
> +#
> +# You should have received a copy of the GNU General Public License along
> +# with this program.  If not, see <http://www.gnu.org/licenses/>.
> +#
> +# The full GNU General Public License is included in this distribution in
> +# the file called "COPYING".

Why are these two paragraphs needed?

> +#
> +# Contact Information:
> +# Intel Thunderbolt Mailing List <thunderbolt-software@lists.01.org>
> +# Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497

We try to stay away from addresses in kernel files as no one wants to
maintain the corporate movements of companies for years to come.  Are
you willing to do this for the next 40 years?

> +#
> +################################################################################
> +
> +obj-${CONFIG_THUNDERBOLT_ICM} += thunderbolt-icm.o
> +thunderbolt-icm-objs := icm_nhi.o

All of that for a simple 2 line Makefile?  Please no, just have a 2 line
Makefile...

And you don't have a Kconfig file that adds this option, right?

What exactly does this driver do?  Why would I want it enabled?  I'm
lost...

> diff --git a/drivers/thunderbolt/icm/icm_nhi.c b/drivers/thunderbolt/icm/icm_nhi.c
> new file mode 100644
> index 0000000..bcb5c1b
> --- /dev/null
> +++ b/drivers/thunderbolt/icm/icm_nhi.c
> @@ -0,0 +1,1324 @@
> +/*******************************************************************************
> + *
> + * Intel Thunderbolt(TM) driver
> + * Copyright(c) 2014 - 2016 Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program.  If not, see <http://www.gnu.org/licenses/>.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".
> + *
> + * Contact Information:
> + * Intel Thunderbolt Mailing List <thunderbolt-software@lists.01.org>
> + * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
> + *
> + ******************************************************************************/
> +
> +#include <linux/printk.h>
> +#include <linux/crc32.h>
> +#include <linux/delay.h>
> +#include <linux/dmi.h>
> +#include "icm_nhi.h"
> +#include "net.h"
> +
> +#define NHI_GENL_VERSION 1
> +#define NHI_GENL_NAME DRV_NAME

Why not just use DRV_NAME?

Why have this at all?  Why even have DRV_NAME?  Seems useless as you are
not going to change it.

thanks,

greg k-h
