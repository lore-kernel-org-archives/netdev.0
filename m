From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch net-next 04/11] net: hns: enet specify a reference to
 dsaf by fwnode_handle
Date: Fri, 13 May 2016 16:01:18 +0300
Message-ID: <1463144478.17131.338.camel@linux.intel.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1463127557-90824-5-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, andrew@lunn.ch, geliangtang@163.com,
	ivecera@redhat.com, fengguang.wu@intel.com,
	charles.chenxin@huawei.com, haifeng.wei@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	rjw@rjwysocki.net, lenb@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-5-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
> From: Kejian Yan <yankejian@huawei.com>
>=20
> As device_node is only used by OF case, it is expected to find unifor=
m
> ways. So fwnode_handle is the suitable method.

Yeah, and this is part of conversion to fwnode, see previous comment.

>=20
> Signed-off-by: Kejian Yan <yankejian@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> ---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hnae.c=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0| 18 ++++++++++++------
> =C2=A0drivers/net/ethernet/hisilicon/hns/hnae.h=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0|=C2=A0=C2=A03 ++-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_enet.c | 15 ++++++++----=
---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_enet.h |=C2=A0=C2=A02 +-
> =C2=A04 files changed, 23 insertions(+), 15 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c
> b/drivers/net/ethernet/hisilicon/hns/hnae.c
> index 3bfe36f..b5bf12a 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hnae.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
> @@ -96,16 +96,22 @@ static int __ae_match(struct device *dev, const
> void *data)
> =C2=A0{
> =C2=A0	struct hnae_ae_dev *hdev =3D cls_to_ae_dev(dev);
> =C2=A0
> -	return hdev->dev->of_node =3D=3D data;
> +	if (IS_ENABLED(CONFIG_OF) && hdev->dev->of_node)
> +		return (data =3D=3D &hdev->dev->of_node->fwnode);
> +	else if (ACPI_COMPANION(hdev->dev))
> +		return (data =3D=3D hdev->dev->fwnode);
> +
> +	dev_err(dev, "__ae_match cannot read cfg data from OF or
> acpi\n");
> +	return 0;
> =C2=A0}
> =C2=A0
> -static struct hnae_ae_dev *find_ae(const struct device_node *ae_node=
)
> +static struct hnae_ae_dev *find_ae(const struct fwnode_handle
> *fwnode)
> =C2=A0{
> =C2=A0	struct device *dev;
> =C2=A0
> -	WARN_ON(!ae_node);
> +	WARN_ON(!fwnode);
> =C2=A0
> -	dev =3D class_find_device(hnae_class, NULL, ae_node,
> __ae_match);
> +	dev =3D class_find_device(hnae_class, NULL, fwnode,
> __ae_match);
> =C2=A0
> =C2=A0	return dev ? cls_to_ae_dev(dev) : NULL;
> =C2=A0}
> @@ -312,7 +318,7 @@ EXPORT_SYMBOL(hnae_reinit_handle);
> =C2=A0 * return handle ptr or ERR_PTR
> =C2=A0 */
> =C2=A0struct hnae_handle *hnae_get_handle(struct device *owner_dev,
> -				=C2=A0=C2=A0=C2=A0=C2=A0const struct device_node
> *ae_node,
> +				=C2=A0=C2=A0=C2=A0=C2=A0const struct fwnode_handle=09
> *fwnode,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0u32 port_id,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0struct hnae_buf_ops *bops)
> =C2=A0{
> @@ -321,7 +327,7 @@ struct hnae_handle *hnae_get_handle(struct device
> *owner_dev,
> =C2=A0	int i, j;
> =C2=A0	int ret;
> =C2=A0
> -	dev =3D find_ae(ae_node);
> +	dev =3D find_ae(fwnode);
> =C2=A0	if (!dev)
> =C2=A0		return ERR_PTR(-ENODEV);
> =C2=A0
> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h
> b/drivers/net/ethernet/hisilicon/hns/hnae.h
> index e8d36aa..3ad3e55 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hnae.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
> @@ -27,6 +27,7 @@
> =C2=A0 * "cb" means control block
> =C2=A0 */
> =C2=A0
> +#include <linux/acpi.h>
> =C2=A0#include <linux/delay.h>
> =C2=A0#include <linux/device.h>
> =C2=A0#include <linux/module.h>
> @@ -528,7 +529,7 @@ struct hnae_handle {
> =C2=A0#define ring_to_dev(ring) ((ring)->q->dev->dev)
> =C2=A0
> =C2=A0struct hnae_handle *hnae_get_handle(struct device *owner_dev,
> -				=C2=A0=C2=A0=C2=A0=C2=A0const struct device_node
> *ae_node,
> +				=C2=A0=C2=A0=C2=A0=C2=A0const struct fwnode_handle=09
> *fwnode,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0u32 port_id,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0struct hnae_buf_ops *bops);
> =C2=A0
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> index 8851420..4fa9c21 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> @@ -1807,7 +1807,7 @@ static int hns_nic_try_get_ae(struct net_device
> *ndev)
> =C2=A0	int ret;
> =C2=A0
> =C2=A0	h =3D hnae_get_handle(&priv->netdev->dev,
> -			=C2=A0=C2=A0=C2=A0=C2=A0priv->ae_node, priv->port_id, NULL);
> +			=C2=A0=C2=A0=C2=A0=C2=A0priv->fwnode, priv->port_id, NULL);
> =C2=A0	if (IS_ERR_OR_NULL(h)) {
> =C2=A0		ret =3D -ENODEV;
> =C2=A0		dev_dbg(priv->dev, "has not handle, register
> notifier!\n");
> @@ -1867,7 +1867,7 @@ static int hns_nic_dev_probe(struct
> platform_device *pdev)
> =C2=A0	struct device *dev =3D &pdev->dev;
> =C2=A0	struct net_device *ndev;
> =C2=A0	struct hns_nic_priv *priv;
> -	struct device_node *node =3D dev->of_node;
> +	struct device_node *ae_node;
> =C2=A0	u32 port_id;
> =C2=A0	int ret;
> =C2=A0
> @@ -1881,18 +1881,19 @@ static int hns_nic_dev_probe(struct
> platform_device *pdev)
> =C2=A0	priv->dev =3D dev;
> =C2=A0	priv->netdev =3D ndev;
> =C2=A0
> -	if (of_device_is_compatible(node, "hisilicon,hns-nic-v1"))
> +	if (of_device_is_compatible(dev->of_node, "hisilicon,hns-nic-
> v1"))
> =C2=A0		priv->enet_ver =3D AE_VERSION_1;
> =C2=A0	else
> =C2=A0		priv->enet_ver =3D AE_VERSION_2;
> =C2=A0
> -	priv->ae_node =3D (void *)of_parse_phandle(node, "ae-handle",
> 0);
> -	if (IS_ERR_OR_NULL(priv->ae_node)) {
> -		ret =3D PTR_ERR(priv->ae_node);
> +	ae_node =3D of_parse_phandle(dev->of_node, "ae-handle", 0);
> +	if (IS_ERR_OR_NULL(ae_node)) {
> +		ret =3D PTR_ERR(ae_node);
> =C2=A0		dev_err(dev, "not find ae-handle\n");
> =C2=A0		goto out_read_prop_fail;
> =C2=A0	}
> -	/* try to find port-idx-in-ae first */
> +	priv->fwnode =3D &ae_node->fwnode;
> +
> =C2=A0	ret =3D device_property_read_u32(dev, "port-idx-in-ae",
> &port_id);
> =C2=A0	if (ret) {
> =C2=A0		/* only for old code compatible */
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
> b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
> index 337efa5..44bb301 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
> @@ -54,7 +54,7 @@ struct hns_nic_ops {
> =C2=A0};
> =C2=A0
> =C2=A0struct hns_nic_priv {
> -	const struct device_node *ae_node;
> +	const struct fwnode_handle=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0*fwno=
de;
> =C2=A0	u32 enet_ver;
> =C2=A0	u32 port_id;
> =C2=A0	int phy_mode;

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
