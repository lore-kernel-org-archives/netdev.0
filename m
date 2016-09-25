From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v5 13/16] IB/pvrdma: Add the main driver module for PVRDMA
Date: Sun, 25 Sep 2016 10:57:03 +0300
Message-ID: <20160925075703.GX4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
 <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="QHp3Wr1K3N9pKO2V"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org,
        georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org
To: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--QHp3Wr1K3N9pKO2V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Sep 24, 2016 at 04:21:37PM -0700, Adit Ranadive wrote:
> This patch adds the support to register a RDMA device with the kernel RDMA
> stack as well as a kernel module. This also initializes the underlying
> virtual PCI device.
>
> Reviewed-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Jorgen Hansen <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> Reviewed-by: George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> ---
> Changes v4->v5:
>  - Removed two unnecessary lines.
>  - Updated include for headers in UAPI folder.
>  - Update to pvrdma_cmd_post for add/delete GIDs.
>  - Add error code in dev_warn if pvrdma_cmd_post failed.
>
> Changes v3->v4:
>  - Fixed some checkpatch warnings.
>  - Added support for new get_dev_fw_str API.
>  - Added event workqueue for netdevice events.
>  - Restructured the pvrdma_pci_remove function a little bit.
>
> Changes v2->v3:
>  - Removed boolean in pvrdma_cmd_post.
>
> Changes v1->v2:
>  - Addressed 32-bit build errors
>  - Cosmetic change to avoid if else in intr0_handler
>  - Removed unnecessary return assignment.
> ---
>  drivers/infiniband/hw/pvrdma/pvrdma_main.c | 1220 ++++++++++++++++++++++++++++
>  1 file changed, 1220 insertions(+)
>  create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_main.c
>
> diff --git a/drivers/infiniband/hw/pvrdma/pvrdma_main.c b/drivers/infiniband/hw/pvrdma/pvrdma_main.c
> new file mode 100644
> index 0000000..94cbbb9
> --- /dev/null
> +++ b/drivers/infiniband/hw/pvrdma/pvrdma_main.c
> @@ -0,0 +1,1220 @@
> +/*
> + * Copyright (c) 2012-2016 VMware, Inc.  All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of EITHER the GNU General Public License
> + * version 2 as published by the Free Software Foundation or the BSD
> + * 2-Clause License. This program is distributed in the hope that it
> + * will be useful, but WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED
> + * WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
> + * See the GNU General Public License version 2 for more details at
> + * http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program available in the file COPYING in the main
> + * directory of this source tree.
> + *
> + * The BSD 2-Clause License
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
> + * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
> + * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
> + * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
> + * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
> + * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
> + * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
> + * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
> + * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
> + * OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +
> +#include <linux/errno.h>
> +#include <linux/inetdevice.h>
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/slab.h>
> +#include <rdma/ib_addr.h>
> +#include <rdma/ib_smi.h>
> +#include <rdma/ib_user_verbs.h>
> +#include <net/addrconf.h>
> +#include <rdma/pvrdma-abi.h>
> +
> +#include "pvrdma.h"
> +
> +#define DRV_NAME	"pvrdma"
> +#define DRV_VERSION	"1.0"
> +#define DRV_RELDATE	"January 1, 2013"
> +
> +static const char pvrdma_version[] =
> +	DRV_NAME ": PVRDMA InfiniBand driver v"
> +	DRV_VERSION " (" DRV_RELDATE ")\n";

This is a good example why driver version and reldate are useless in
kernel. We are in 2016 and not in 2013. All these data are forgotten to
update right after the developer copied it from other pre-historic driver
(very common practice in netdev). It is worth to stop to use this totally
useless defines.

> +
> +static DEFINE_MUTEX(pvrdma_device_list_lock);
> +static LIST_HEAD(pvrdma_device_list);
> +static struct workqueue_struct *event_wq;
> +
> +static int pvrdma_add_gid(struct ib_device *ibdev,
> +			  u8 port_num,
> +			  unsigned int index,
> +			  const union ib_gid *gid,
> +			  const struct ib_gid_attr *attr,
> +			  void **context);
> +static int pvrdma_del_gid(struct ib_device *ibdev,
> +			  u8 port_num,
> +			  unsigned int index,
> +			  void **context);
> +
> +
> +static ssize_t show_hca(struct device *device, struct device_attribute *attr,
> +			char *buf)
> +{
> +	return sprintf(buf, "PVRDMA%s\n", DRV_VERSION);
> +}
> +
> +static ssize_t show_rev(struct device *device, struct device_attribute *attr,
> +			char *buf)
> +{
> +	return sprintf(buf, "%d\n", PVRDMA_REV_ID);
> +}
> +
> +static ssize_t show_board(struct device *device, struct device_attribute *attr,
> +			  char *buf)
> +{
> +	return sprintf(buf, "%d\n", PVRDMA_BOARD_ID);
> +}
> +
> +static DEVICE_ATTR(hw_rev,   S_IRUGO, show_rev,	   NULL);
> +static DEVICE_ATTR(hca_type, S_IRUGO, show_hca,	   NULL);
> +static DEVICE_ATTR(board_id, S_IRUGO, show_board,  NULL);
> +
> +static struct device_attribute *pvrdma_class_attributes[] = {
> +	&dev_attr_hw_rev,
> +	&dev_attr_hca_type,
> +	&dev_attr_board_id
> +};
> +
> +static void pvrdma_get_fw_ver_str(struct ib_device *device, char *str,
> +				  size_t str_len)
> +{
> +	struct pvrdma_dev *dev =
> +		container_of(device, struct pvrdma_dev, ib_dev);
> +	snprintf(str, str_len, "%d.%d.%d\n",
> +		 (int) (dev->dsr->caps.fw_ver >> 32),
> +		 (int) (dev->dsr->caps.fw_ver >> 16) & 0xffff,
> +		 (int) dev->dsr->caps.fw_ver & 0xffff);
> +}

Yuval already pointed it to you.
Thanks to Ira, we have general function in core to print FW version.
Please use them.

--QHp3Wr1K3N9pKO2V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX54NPAAoJEORje4g2clinU7cP/1KOeN+b1y6D+Brb5U+xjYkd
JiMQzYG/ue5QXhggt1BIPo1A8grtyL3Ga210GK+kYperTXxZ/MJ9383CExahyfzO
IXa5R4Knw6Au3BJ+KafBu5aNSzvtj3yaMxoTj0yCyojjLiSi7UKd+bJ+C1uBjKE/
2oCRLUlGta2DvyUMpC3Ol7q9WFWfhL4/0bRPAcg+vw67rEMUd9yUWGa+XlpFri71
AixiqeyEnBkgKuEAAHu9v7vrmy0JRgQgRmSY/gr2oQUExO30hlSnYGw3uk94sWvV
BCno8KIyxMvK0FPoQrwIgojqjg5TfBAd1ef+HwGnDooFSvVatPOxIoRysQj6VdC1
GciV0C5AvghNQcdq+Hg8baZIbjkSVh/14JChrvfURXPTWf0Q6kkduLYAa9szzIBQ
ncXAT9FY91FH62Zkj/vLAw/bHNrdFUBU4g0b4+zw7PYI3aJ33/Id40RW4Ne9T1G8
eAOAkWIyPYjj0dY1dTJdBKL0LVE9SR1ioPxWWMQcbl6floOZpCclEQwx3hGeP7Pk
6X9LF7gGO2VnStcdKd6zUk2a3B2i9r6u475pPmuWwtKPvMgF9N6Nw/o2wDqxsEZK
Y7GvrPwgfEaa6epN/mJfH4cyPBJwOpPyVahesppNwScAIABjoU25RlfsMXyjAk9P
wmEA7nfUvg/OPyQidjdQ
=JWlG
-----END PGP SIGNATURE-----

--QHp3Wr1K3N9pKO2V--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
