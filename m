From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v5 13/16] IB/pvrdma: Add the main driver module for PVRDMA
Date: Sun, 25 Sep 2016 22:10:43 -0700
Message-ID: <da4a09fc-bef1-60ea-f9af-7c505a9af6d6@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr@vmware.com>
 <20160925075703.GX4088@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-002.vmware.com ([208.91.0.190]:44258 "EHLO
        EX13-EDG-OU-002.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752301AbcIZFK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 01:10:58 -0400
In-Reply-To: <20160925075703.GX4088@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On sun, Sep 25 2016 at 10:57:03AM +0300, Leon Romanovsky wrote:
> On Sat, Sep 24, 2016 at 04:21:37PM -0700, Adit Ranadive wrote:
> > This patch adds the support to register a RDMA device with the kernel RDMA
> > stack as well as a kernel module. This also initializes the underlying
> > virtual PCI device.
> >
> > Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>
> > Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
> > Reviewed-by: George Zhang <georgezhang@vmware.com>
> > Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
> > Reviewed-by: Bryan Tan <bryantan@vmware.com>
> > Signed-off-by: Adit Ranadive <aditr@vmware.com>

<...>

> > +
> > +#include <linux/errno.h>
> > +#include <linux/inetdevice.h>
> > +#include <linux/init.h>
> > +#include <linux/module.h>
> > +#include <linux/slab.h>
> > +#include <rdma/ib_addr.h>
> > +#include <rdma/ib_smi.h>
> > +#include <rdma/ib_user_verbs.h>
> > +#include <net/addrconf.h>
> > +#include <rdma/pvrdma-abi.h>
> > +
> > +#include "pvrdma.h"
> > +
> > +#define DRV_NAME	"pvrdma"
> > +#define DRV_VERSION	"1.0"
> > +#define DRV_RELDATE	"January 1, 2013"
> > +
> > +static const char pvrdma_version[] =
> > +	DRV_NAME ": PVRDMA InfiniBand driver v"
> > +	DRV_VERSION " (" DRV_RELDATE ")\n";
> 
> This is a good example why driver version and reldate are useless in
> kernel. We are in 2016 and not in 2013. All these data are forgotten to
> update right after the developer copied it from other pre-historic driver
> (very common practice in netdev). It is worth to stop to use this totally
> useless defines.
> 

Sorry, in our case it was the Mellanox mlx4 driver :). Yeah, I can remove
DRV_VERSION and DRV_RELDATE. I'll keep the MODULE_VERSION since we keep
track of our virtual driver versions that way. So when there are any changes
to our driver we typically bump up the version. Not sure if that's a netdev
or misc device practice and if thats followed here.

<...>

> > +static void pvrdma_get_fw_ver_str(struct ib_device *device, char *str,
> > +				  size_t str_len)
> > +{
> > +	struct pvrdma_dev *dev =
> > +		container_of(device, struct pvrdma_dev, ib_dev);
> > +	snprintf(str, str_len, "%d.%d.%d\n",
> > +		 (int) (dev->dsr->caps.fw_ver >> 32),
> > +		 (int) (dev->dsr->caps.fw_ver >> 16) & 0xffff,
> > +		 (int) dev->dsr->caps.fw_ver & 0xffff);
> > +}
> 
> Yuval already pointed it to you.
> Thanks to Ira, we have general function in core to print FW version.
> Please use them.
> 

If you are referring to commit 5fa76c20458518ed6181adddef2e31c5afc0745c
then isnt this is exactly what Ira did for the other providers?
Here, the pvrdma_get_fw_ver_str function is registered as a callback for
the get_dev_fw_str API. Please our pvrdma_register_device function where
we register our callbacks with ib_core:
https://patchwork.kernel.org/patch/9349357/

> > +	dev->ib_dev.get_dev_fw_str = pvrdma_get_fw_ver_str;
