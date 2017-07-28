From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V4 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Fri, 28 Jul 2017 07:41:37 +0300
Message-ID: <20170728044137.GF13672@mtr-leonro.local>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-3-salil.mehta@huawei.com>
 <20170723131530.GJ3259@mtr-leonro.local>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B828A12@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="iVCmgExH7+hIHJ1A"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B828A12@FRAEML521-MBX.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--iVCmgExH7+hIHJ1A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 27, 2017 at 11:44:32PM +0000, Salil Mehta wrote:
> Hi Leon
>
> > -----Original Message-----
> > From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> > owner@vger.kernel.org] On Behalf Of Leon Romanovsky
> > Sent: Sunday, July 23, 2017 2:16 PM
> > To: Salil Mehta
> > Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> > mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> > Subject: Re: [PATCH V4 net-next 2/8] net: hns3: Add support of the
> > HNAE3 framework
> >
> > On Sat, Jul 22, 2017 at 11:09:36PM +0100, Salil Mehta wrote:
> > > This patch adds the support of the HNAE3 (Hisilicon Network
> > > Acceleration Engine 3) framework support to the HNS3 driver.
> > >
> > > Framework facilitates clients like ENET(HNS3 Ethernet Driver), RoCE
> > > and user-space Ethernet drivers (like ODP etc.) to register with
> > HNAE3
> > > devices and their associated operations.
> > >
> > > Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> > > Signed-off-by: lipeng <lipeng321@huawei.com>
> > > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > > Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> > > ---
> > > Patch V4: Addressed following comments
> > >   1. Andrew Lunn:
> > >      https://lkml.org/lkml/2017/6/17/233
> > >      https://lkml.org/lkml/2017/6/18/105
> > >   2. Bo Yu:
> > >      https://lkml.org/lkml/2017/6/18/112
> > >   3. Stephen Hamminger:
> > >      https://lkml.org/lkml/2017/6/19/778
> > > Patch V3: Addressed below comments
> > >   1. Andrew Lunn:
> > >      https://lkml.org/lkml/2017/6/13/1025
> > > Patch V2: No change
> > > Patch V1: Initial Submit
> > > ---
> > >  drivers/net/ethernet/hisilicon/hns3/hnae3.c | 319
> > ++++++++++++++++++++
> > >  drivers/net/ethernet/hisilicon/hns3/hnae3.h | 449
> > ++++++++++++++++++++++++++++
> > >  2 files changed, 768 insertions(+)
> > >  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > >  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.h
> > >
> > > diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > b/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > > new file mode 100644
> > > index 000000000000..7a11aaff0a23
> > > --- /dev/null
> > > +++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > > @@ -0,0 +1,319 @@
> > > +/*
> > > + * Copyright (c) 2016-2017 Hisilicon Limited.
> > > + *
> > > + * This program is free software; you can redistribute it and/or
> > modify
> > > + * it under the terms of the GNU General Public License as published
> > by
> > > + * the Free Software Foundation; either version 2 of the License, or
> > > + * (at your option) any later version.
> > > + */
> > > +
> > > +#include <linux/slab.h>
> > > +#include <linux/list.h>
> > > +#include <linux/spinlock.h>
> > > +
> > > +#include "hnae3.h"
> > > +
> > > +static LIST_HEAD(hnae3_ae_algo_list);
> > > +static LIST_HEAD(hnae3_client_list);
> > > +static LIST_HEAD(hnae3_ae_dev_list);
> > > +
> > > +/* we are keeping things simple and using single lock for all the
> > > + * list. This is a non-critical code so other updations, if happen
> > > + * in parallel, can wait.
> > > + */
> > > +static DEFINE_MUTEX(hnae3_common_lock);
> > > +
> > > +static bool hnae3_client_match(enum hnae3_client_type client_type,
> > > +			       enum hnae3_dev_type dev_type)
> > > +{
> > > +	if (dev_type == HNAE3_DEV_KNIC) {
> > > +		switch (client_type) {
> > > +		case HNAE3_CLIENT_KNIC:
> > > +		case HNAE3_CLIENT_ROCE:
> > > +			return true;
> > > +		default:
> > > +			return false;
> > > +		}
> > > +	} else if (dev_type == HNAE3_DEV_UNIC) {
> > > +		switch (client_type) {
> > > +		case HNAE3_CLIENT_UNIC:
> > > +			return true;
> > > +		default:
> > > +			return false;
> > > +		}
> > > +	} else {
> > > +		return false;
> > > +	}
> > > +}
> > > +
> > > +static int hnae3_match_n_instantiate(struct hnae3_client *client,
> > > +				     struct hnae3_ae_dev *ae_dev,
> > > +				     bool is_reg, bool *matched)
> > > +{
> > > +	int ret;
> > > +
> > > +	*matched = false;
> > > +
> > > +	/* check if this client matches the type of ae_dev */
> > > +	if (!(hnae3_client_match(client->type, ae_dev->dev_type) &&
> > > +	      hnae_get_bit(ae_dev->flag, HNAE3_DEV_INITED_B))) {
> > > +		return 0;
> > > +	}
> > > +	/* there is a match of client and dev */
> > > +	*matched = true;
> > > +
> > > +	if (!(ae_dev->ops && ae_dev->ops->init_client_instance &&
> > > +	      ae_dev->ops->uninit_client_instance)) {
> > > +		dev_err(&ae_dev->pdev->dev,
> > > +			"ae_dev or client init/uninit ops are null\n");
> > > +		return -EOPNOTSUPP;
> > > +	}
> > > +
> > > +	/* now, (un-)instantiate client by calling lower layer */
> > > +	if (is_reg) {
> > > +		ret = ae_dev->ops->init_client_instance(client, ae_dev);
> > > +		if (ret)
> > > +			dev_err(&ae_dev->pdev->dev,
> > > +				"fail to instantiate client\n");
> > > +		return ret;
> > > +	}
> > > +
> > > +	ae_dev->ops->uninit_client_instance(client, ae_dev);
> > > +	return 0;
> > > +}
> > > +
> > > +int hnae3_register_client(struct hnae3_client *client)
> > > +{
> > > +	struct hnae3_client *client_tmp;
> > > +	struct hnae3_ae_dev *ae_dev;
> > > +	bool matched;
> > > +	int ret = 0;
> > > +
> > > +	mutex_lock(&hnae3_common_lock);
> > > +	/* one system should only have one client for every type */
> > > +	list_for_each_entry(client_tmp, &hnae3_client_list, node) {
> > > +		if (client_tmp->type == client->type)
> > > +			goto exit;
> > > +	}
> > > +
> > > +	list_add_tail(&client->node, &hnae3_client_list);
> > > +
> > > +	/* initialize the client on every matched port */
> > > +	list_for_each_entry(ae_dev, &hnae3_ae_dev_list, node) {
> > > +		/* if the client could not be initialized on current port,
> > for
> > > +		 * any error reasons, move on to next available port
> > > +		 */
> > > +		ret = hnae3_match_n_instantiate(client, ae_dev, true,
> > &matched);
> > > +		if (ret)
> > > +			dev_err(&ae_dev->pdev->dev,
> > > +				"match and instantiation failed for port\n");
> > > +	}
> > > +
> > > +exit:
> > > +	mutex_unlock(&hnae3_common_lock);
> > > +
> > > +	return ret;
> > > +}
> > > +EXPORT_SYMBOL(hnae3_register_client);
> > > +
> > > +void hnae3_unregister_client(struct hnae3_client *client)
> > > +{
> > > +	struct hnae3_ae_dev *ae_dev;
> > > +	bool matched;
> > > +
> > > +	mutex_lock(&hnae3_common_lock);
> > > +	/* un-initialize the client on every matched port */
> > > +	list_for_each_entry(ae_dev, &hnae3_ae_dev_list, node) {
> > > +		hnae3_match_n_instantiate(client, ae_dev, false, &matched);
> > > +	}
> > > +
> > > +	list_del(&client->node);
> > > +	mutex_unlock(&hnae3_common_lock);
> > > +}
> > > +EXPORT_SYMBOL(hnae3_unregister_client);
> > > +
> > > +/* hnae_ae_register - register a AE engine to hnae framework
> > > + * @hdev: the hnae ae engine device
> > > + * @owner:  the module who provides this dev
> > > + * NOTE: the duplicated name will not be checked
> > > + */
> > > +int hnae3_register_ae_algo(struct hnae3_ae_algo *ae_algo)
> > > +{
> > > +	const struct pci_device_id *id;
> > > +	struct hnae3_ae_dev *ae_dev;
> > > +	struct hnae3_client *client;
> > > +	bool matched;
> > > +	int ret = 0;
> > > +
> > > +	mutex_lock(&hnae3_common_lock);
> > > +
> > > +	list_add_tail(&ae_algo->node, &hnae3_ae_algo_list);
> > > +
> > > +	/* Check if this algo/ops matches the list of ae_devs */
> > > +	list_for_each_entry(ae_dev, &hnae3_ae_dev_list, node) {
> > > +		id = pci_match_id(ae_algo->pdev_id_table, ae_dev->pdev);
> > > +		if (!id)
> > > +			continue;
> > > +
> > > +		/* ae_dev init should set flag */
> > > +		ae_dev->ops = ae_algo->ops;
> > > +		ret = ae_algo->ops->init_ae_dev(ae_dev);
> > > +		if (ret) {
> > > +			dev_err(&ae_dev->pdev->dev, "init ae_dev error.\n");
> > > +			continue;
> > > +		}
> > > +
> > > +		hnae_set_bit(ae_dev->flag, HNAE3_DEV_INITED_B, 1);
> > > +
> > > +		/* check the client list for the match with this ae_dev
> > type and
> > > +		 * initialize the figure out client instance
> > > +		 */
> > > +		list_for_each_entry(client, &hnae3_client_list, node) {
> > > +			ret = hnae3_match_n_instantiate(client, ae_dev, true,
> > > +							&matched);
> > > +			if (ret)
> > > +				dev_err(&ae_dev->pdev->dev,
> > > +					"match and instantiation failed\n");
> > > +			if (matched)
> > > +				break;
> > > +		}
> > > +	}
> > > +
> > > +	mutex_unlock(&hnae3_common_lock);
> > > +
> > > +	return ret;
> > > +}
> > > +EXPORT_SYMBOL(hnae3_register_ae_algo);
> > > +
> > > +/* hnae_ae_unregister - unregisters a HNAE AE engine
> > > + * @cdev: the device to unregister
> > > + */
> > > +void hnae3_unregister_ae_algo(struct hnae3_ae_algo *ae_algo)
> > > +{
> > > +	const struct pci_device_id *id;
> > > +	struct hnae3_ae_dev *ae_dev;
> > > +	struct hnae3_client *client;
> > > +	bool matched;
> > > +
> > > +	mutex_lock(&hnae3_common_lock);
> > > +	/* Check if there are matched ae_dev */
> > > +	list_for_each_entry(ae_dev, &hnae3_ae_dev_list, node) {
> > > +		id = pci_match_id(ae_algo->pdev_id_table, ae_dev->pdev);
> > > +		if (!id)
> > > +			continue;
> > > +
> > > +		/* check the client list for the match with this ae_dev
> > type and
> > > +		 * un-initialize the figure out client instance
> > > +		 */
> > > +		list_for_each_entry(client, &hnae3_client_list, node) {
> > > +			hnae3_match_n_instantiate(client, ae_dev, false,
> > > +						  &matched);
> > > +			if (matched)
> > > +				break;
> > > +		}
> > > +
> > > +		ae_algo->ops->uninit_ae_dev(ae_dev);
> > > +		hnae_set_bit(ae_dev->flag, HNAE3_DEV_INITED_B, 0);
> > > +	}
> > > +
> > > +	list_del(&ae_algo->node);
> > > +	mutex_unlock(&hnae3_common_lock);
> > > +}
> > > +EXPORT_SYMBOL(hnae3_unregister_ae_algo);
> > > +
> > > +/* hnae_ae_register - register a AE engine to hnae framework
> > > + * @hdev: the hnae ae engine device
> > > + * @owner:  the module who provides this dev
> > > + * NOTE: the duplicated name will not be checked
> > > + */
> > > +int hnae3_register_ae_dev(struct hnae3_ae_dev *ae_dev)
> > > +{
> > > +	const struct pci_device_id *id;
> > > +	struct hnae3_ae_algo *ae_algo;
> > > +	struct hnae3_client *client;
> > > +	bool matched;
> > > +	int ret = 0;
> > > +
> > > +	mutex_lock(&hnae3_common_lock);
> > > +	list_add_tail(&ae_dev->node, &hnae3_ae_dev_list);
> > > +
> > > +	/* Check if there are matched ae_algo */
> > > +	list_for_each_entry(ae_algo, &hnae3_ae_algo_list, node) {
> > > +		id = pci_match_id(ae_algo->pdev_id_table, ae_dev->pdev);
> > > +		if (!id)
> > > +			continue;
> > > +
> > > +		ae_dev->ops = ae_algo->ops;
> > > +
> > > +		if (!ae_dev->ops) {
> > > +			dev_err(&ae_dev->pdev->dev, "ae_dev ops are null\n");
> > > +			goto out_err;
> > > +		}
> > > +
> > > +		/* ae_dev init should set flag */
> > > +		ret = ae_dev->ops->init_ae_dev(ae_dev);
> > > +		if (ret) {
> > > +			dev_err(&ae_dev->pdev->dev, "init ae_dev error\n");
> > > +			goto out_err;
> > > +		}
> > > +
> > > +		hnae_set_bit(ae_dev->flag, HNAE3_DEV_INITED_B, 1);
> > > +		break;
> > > +	}
> > > +
> > > +	/* check the client list for the match with this ae_dev type and
> > > +	 * initialize the figure out client instance
> > > +	 */
> > > +	list_for_each_entry(client, &hnae3_client_list, node) {
> > > +		ret = hnae3_match_n_instantiate(client, ae_dev, true,
> > > +						&matched);
> > > +		if (ret)
> > > +			dev_err(&ae_dev->pdev->dev,
> > > +				"match and instantiation failed\n");
> > > +		if (matched)
> > > +			break;
> > > +	}
> > > +
> > > +out_err:
> > > +	mutex_unlock(&hnae3_common_lock);
> > > +
> > > +	return ret;
> > > +}
> > > +EXPORT_SYMBOL(hnae3_register_ae_dev);
> > > +
> > > +/* hnae_ae_unregister - unregisters a HNAE AE engine
> > > + * @cdev: the device to unregister
> > > + */
> > > +void hnae3_unregister_ae_dev(struct hnae3_ae_dev *ae_dev)
> > > +{
> > > +	const struct pci_device_id *id;
> > > +	struct hnae3_ae_algo *ae_algo;
> > > +	struct hnae3_client *client;
> > > +	bool matched;
> > > +
> > > +	mutex_lock(&hnae3_common_lock);
> > > +	/* Check if there are matched ae_algo */
> > > +	list_for_each_entry(ae_algo, &hnae3_ae_algo_list, node) {
> > > +		id = pci_match_id(ae_algo->pdev_id_table, ae_dev->pdev);
> > > +		if (!id)
> > > +			continue;
> > > +
> > > +		list_for_each_entry(client, &hnae3_client_list, node) {
> > > +			hnae3_match_n_instantiate(client, ae_dev, false,
> > > +						  &matched);
> > > +			if (matched)
> > > +				break;
> > > +		}
> > > +
> > > +		ae_algo->ops->uninit_ae_dev(ae_dev);
> > > +		hnae_set_bit(ae_dev->flag, HNAE3_DEV_INITED_B, 0);
> > > +	}
> > > +
> > > +	list_del(&ae_dev->node);
> > > +	mutex_unlock(&hnae3_common_lock);
> > > +}
> > > +EXPORT_SYMBOL(hnae3_unregister_ae_dev);
> > > +
> > > +MODULE_AUTHOR("Huawei Tech. Co., Ltd.");
> > > +MODULE_LICENSE("GPL");
> > > +MODULE_DESCRIPTION("HNAE3(Hisilicon Network Acceleration Engine)
> > Framework");
> > > diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
> > b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
> > > new file mode 100644
> > > index 000000000000..88655c121769
> > > --- /dev/null
> > > +++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
> > > @@ -0,0 +1,449 @@
> > > +/*
> > > + * Copyright (c) 2016-2017 Hisilicon Limited.
> > > + *
> > > + * This program is free software; you can redistribute it and/or
> > modify
> > > + * it under the terms of the GNU General Public License as published
> > by
> > > + * the Free Software Foundation; either version 2 of the License, or
> > > + * (at your option) any later version.
> > > + */
> > > +
> > > +#ifndef __HNAE_H
> > > +#define __HNAE_H
> > > +
> > > +/* Names used in this framework:
> > > + *      ae handle (handle):
> > > + *        a set of queues provided by AE
> > > + *      ring buffer queue (rbq):
> > > + *        the channel between upper layer and the AE, can do tx and
> > rx
> > > + *      ring:
> > > + *        a tx or rx channel within a rbq
> > > + *      ring description (desc):
> > > + *        an element in the ring with packet information
> > > + *      buffer:
> > > + *        a memory region referred by desc with the full packet
> > payload
> > > + *
> > > + * "num" means a static number set as a parameter, "count" mean a
> > dynamic
> > > + *   number set while running
> > > + * "cb" means control block
> > > + */
> > > +
> > > +#include <linux/acpi.h>
> > > +#include <linux/delay.h>
> > > +#include <linux/device.h>
> > > +#include <linux/module.h>
> > > +#include <linux/netdevice.h>
> > > +#include <linux/pci.h>
> > > +#include <linux/types.h>
> > > +
> > > +#define HNAE_DRIVER_VERSION "1.0"
> >
> > Please no driver versions.
> We need this in ethtool. Most of the driver are using it.

So please, stop doing copy/paste and take a look how it was implemented in nfp.

Related discussion about useless of your driver version.
https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2017-June/004441.html
https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2017-June/004428.html

>
> >
> > > +#define HNAE_DRIVER_NAME "hns3"
> > > +#define HNAE_COPYRIGHT "Copyright(c) 2017 Huawei Corporation."
> > > +#define HNAE_DRIVER_STRING "Hisilicon Network Subsystem Driver"
> > > +#define HNAE_DEFAULT_DEVICE_DESCR "Hisilicon Network Subsystem"
> >
> > You are not subsystem yet.
> Hisilicon Network System is the network related hardware within
> Hip08 SoC of Hisilicon. This does not means HNS is Linux network
> subsystem.

I understand it, so remove word "subsystem" and use more appropriate "core", "library", e.t.c

Thanks

--iVCmgExH7+hIHJ1A
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAll6wIEACgkQ5GN7iDZy
WKfBZxAAiLL5OANQQM8sr2hwqyDQzDJSpQzds2MdJtzD9zGOpfixIuO56RCv7Ara
enfjrOrki4PjXHIkFdMDy4Kq24KZM1ebScIO8ZfRaa/O4B/j3vDqi8yRQz0XkmAs
ud7Wb3sP8Z4dDIsNkvv7yJtl2GWGm0DYdXrm2VleRfulBxHMb1gZ+725lV6GOfbA
fE/5e/kofnZYqvk6+KNV304MpmYR2Pb4hjSnqFACUjVl6uGEdnulFVYVAvHNx9lv
ndruonejuiAxOVKyixOlsjJbfzHZwwfkuyO7GZTA2WtTYo20XZ5OLPnzve+RuO+5
cKCAL/GRnMtm6mUKWlyYyB7W/T67PCA6s4bojgTol6PnnK8l9StqyTEkB/y1G0GI
QmRJBu+J1adteOanDfKuSaXXIjfC0rEIdzCCsfWvu2VqvtP5QQzdhSSqHNtIhrXy
DzCPdtrmiIGcjhVgoTxmcbynEqfQsotKsuVmyNN3JsQPI6rMUPA/SQDPDLRAIrwb
YOd5P2l9Z6seq2F3gbuEbKBIYaFmY3K2KLY5Lo/4Y58evi3P1eOPcP8/hpuvabkV
5dauznrlJ9gDpRmISyczD87c5hNuzLaJ7UlVlTvrK5XG5k9gXR+4C3GlZF+STYG6
UM1jq8brTzxnF3A6q+5nGlYu+D+8rowE53xobD11Ks9DjK7p2Ng=
=UTvk
-----END PGP SIGNATURE-----

--iVCmgExH7+hIHJ1A--
