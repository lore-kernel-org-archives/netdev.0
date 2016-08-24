From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for-next 2/2] IB/hns: Add support of ACPI to the
 Hisilicon RoCE driver
Date: Wed, 24 Aug 2016 16:59:29 +0300
Message-ID: <20160824135929.GU15065@leon.nu>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <1471985090-202472-3-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="nZJAkgcjPzQrJB+u"
Cc: dledford@redhat.com, davem@davemloft.net, xavier.huwei@huawei.com,
        oulijun@huawei.com, yisen.zhuang@huawei.com,
        mehta.salil.lnk@gmail.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471985090-202472-3-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nZJAkgcjPzQrJB+u
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 24, 2016 at 04:44:50AM +0800, Salil Mehta wrote:
> This patch is meant to add support of ACPI to the Hisilicon RoCE
> driver.
>
> Changes done are primarily meant to detect the type and then either
> use DT specific or ACPI spcific functions. Where ever possible,
> this patch tries to make use of Unified Device Property Interface
> APIs to support both DT and ACPI through single interface.
>
> This patch depends upon HNS ethernet driver to Reset RoCE. This
> function within HNS ethernet driver has also been enhanced to
> support ACPI and is part of other accompanying patch with this
> patch-set.
>
> NOTE: The changes in this patch are done over below branch,
> https://github.com/dledford/linux/tree/hns-roce
>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> ---
> Change Log
>
> PATCH V1: Initial version to support ACPI in HNS RoCE driver.
> ---
>  drivers/infiniband/hw/hns/hns_roce_device.h |    2 +-
>  drivers/infiniband/hw/hns/hns_roce_eq.c     |    2 +-
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |   37 ++++++--
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |    2 +-
>  drivers/infiniband/hw/hns/hns_roce_main.c   |  127 ++++++++++++++++++++++-----
>  5 files changed, 136 insertions(+), 34 deletions(-)
>
> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
> index 00f01be..ea73580 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_device.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
> @@ -531,7 +531,7 @@ struct hns_roce_dev {
>  	struct ib_device	ib_dev;
>  	struct platform_device  *pdev;
>  	struct hns_roce_uar     priv_uar;
> -	const char		*irq_names;
> +	const char		*irq_names[HNS_ROCE_MAX_IRQ_NUM];
>  	spinlock_t		sm_lock;
>  	spinlock_t		cq_db_lock;
>  	spinlock_t		bt_cmd_lock;
> diff --git a/drivers/infiniband/hw/hns/hns_roce_eq.c b/drivers/infiniband/hw/hns/hns_roce_eq.c
> index 5febbb4..98af7fe 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_eq.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_eq.c
> @@ -713,7 +713,7 @@ int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev)
>
>  	for (j = 0; j < eq_num; j++) {
>  		ret = request_irq(eq_table->eq[j].irq, hns_roce_msi_x_interrupt,
> -				  0, hr_dev->irq_names, eq_table->eq + j);
> +				  0, hr_dev->irq_names[j], eq_table->eq + j);
>  		if (ret) {
>  			dev_err(dev, "request irq error!\n");
>  			goto err_request_irq_fail;
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> index b52f3ba..399f5de 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> @@ -31,6 +31,7 @@
>   */
>
>  #include <linux/platform_device.h>
> +#include <linux/acpi.h>
>  #include <rdma/ib_umem.h>
>  #include "hns_roce_common.h"
>  #include "hns_roce_device.h"
> @@ -794,29 +795,47 @@ static void hns_roce_port_enable(struct hns_roce_dev *hr_dev, int enable_flag)
>   * @enable: true -- drop reset, false -- reset
>   * return 0 - success , negative --fail
>   */
> -int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool enable)
> +int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool dereset)
>  {
>  	struct device_node *dsaf_node;
>  	struct device *dev = &hr_dev->pdev->dev;
>  	struct device_node *np = dev->of_node;
> +	struct fwnode_handle *fwnode;
>  	int ret;
>
> -	dsaf_node = of_parse_phandle(np, "dsaf-handle", 0);
> -	if (!dsaf_node) {
> -		dev_err(dev, "Unable to get dsaf node by dsaf-handle!\n");
> -		return -EINVAL;
> +	/* check if this is DT/ACPI case */
> +	if (dev_of_node(dev)) {
> +		dsaf_node = of_parse_phandle(np, "dsaf-handle", 0);
> +		if (!dsaf_node) {
> +			dev_err(dev, "could not find dsaf-handle\n");
> +			return -EINVAL;
> +		}
> +		fwnode = &dsaf_node->fwnode;
> +	} else if (is_acpi_device_node(dev->fwnode)) {
> +		struct acpi_reference_args args;
> +
> +		ret = acpi_node_get_property_reference(dev->fwnode,
> +						       "dsaf-handle", 0, &args);
> +		if (ret) {
> +			dev_err(dev, "could not find dsaf-handle\n");
> +			return ret;
> +		}
> +		fwnode = acpi_fwnode_handle(args.adev);
> +	} else {
> +		dev_err(dev, "cannot read data from DT or ACPI\n");
> +		return -ENXIO;
>  	}
>
> -	ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, false);
> +	ret = hns_dsaf_roce_reset(fwnode, false);
>  	if (ret)
>  		return ret;
>
> -	if (enable) {
> +	if (dereset) {
>  		msleep(SLEEP_TIME_INTERVAL);
> -		return hns_dsaf_roce_reset(&dsaf_node->fwnode, true);
> +		ret = hns_dsaf_roce_reset(fwnode, true);
>  	}
>
> -	return 0;
> +	return ret;
>  }
>
>  void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> index 2b3bf21..316b592 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> @@ -976,6 +976,6 @@ struct hns_roce_v1_priv {
>  	struct hns_roce_raq_table raq_table;
>  };
>
> -int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable);
> +int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool dereset);
>
>  #endif
> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
> index 6ead671..f64f0dd 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -30,7 +30,7 @@
>   * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
>   * SOFTWARE.
>   */
> -
> +#include <linux/acpi.h>
>  #include <linux/of_platform.h>
>  #include <rdma/ib_addr.h>
>  #include <rdma/ib_smi.h>
> @@ -694,40 +694,122 @@ error_failed_setup_mtu_gids:
>  	return ret;
>  }
>
> +static const struct of_device_id hns_roce_of_match[] = {
> +	{ .compatible = "hisilicon,hns-roce-v1", .data = &hns_roce_hw_v1, },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, hns_roce_of_match);
> +
> +static const struct acpi_device_id hns_roce_acpi_match[] = {
> +	{ "HISI00D1", (kernel_ulong_t)&hns_roce_hw_v1 },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(acpi, hns_roce_acpi_match);
> +
> +static int hns_roce_node_match(struct device *dev, void *fwnode)
> +{
> +	return dev->fwnode == fwnode;
> +}

It looks like this function should return bool and not int.

--nZJAkgcjPzQrJB+u
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXvahBAAoJEORje4g2clinv1YP/0VDS18cnNPmTKSNexOeZbvk
fquiliWBiH4l/ayRR8a1xsDFrsjcsrLWlcpm4jjtpvcE0kLoqAXe3jXdgMRScJCb
wt2dAIC9akKwnxm23EYCN5pVBm8BImApU7ue5p0ioXAWsVQdhOXcdIbtsxyjogg7
Czg3brw50L7f27BV5K7S8JRMWc46YvLCqUiMDxdHZjuHR1qRtr06y9XyT7iRE2dZ
xXF+m2KAs8yUK5ZwsIYbJvq47liY8/AzN5cKCcokMgVTHuXA15TZBeoccYsRBjqo
lVZcsOSnjDZxAbHPXqj8WZxYnH+I8s1+PmoRZ8Ofxyl+lZxowNZb9Dgxk9ZI+0lD
PFDbNTJXDGCqGccZdWgRylW9wxxpmpzXR+YsZ9chtsCK5RiKflH6agKwbDAmKjDn
tU+oJDiJXUiSKcG1y8efrS86qHL0bqvdDWtP4KByZsoVjZ8ONWB1z+VqlVqmA45z
YNUVsNauxZGG+It3y7+1+Q4CnHSRSgko0GsuMGQjTxF/BkfZYlH8Y/mdD52CYxx5
GMN2LZDMR6e+IKQwfYB+0C4JewQMYe7o08dM1zgD/K71MhZDo1PrW4lpt5WDk0Dc
V9CxM/pUphJGDkaKt56tKdHXXqY3tgcAlmMXT+W7xZXsdEgUtN13tkp0Kbrm9OK5
KYxMTvosusMbgFNmh1SR
=TdKW
-----END PGP SIGNATURE-----

--nZJAkgcjPzQrJB+u--
