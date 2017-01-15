From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for bnxt_re V3 03/21] bnxt_re: register with the NIC
 driver
Date: Sun, 15 Jan 2017 21:41:43 +0200
Message-ID: <20170115194143.GE20392@mtr-leonro.local>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
 <1482225211-22423-4-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="sTC4Ri5uc2u6z9Yo"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, michael.chan@broadcom.com,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44860 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751206AbdAOTlo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 14:41:44 -0500
Content-Disposition: inline
In-Reply-To: <1482225211-22423-4-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sTC4Ri5uc2u6z9Yo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 20, 2016 at 01:13:13AM -0800, Selvin Xavier wrote:
> This patch handles the registration with the bnxt_en driver.
> The bnxt_re driver first registers with netdev notifier chain and upon
> receiving the NETDEV_REGISTER event, it registers with bnxt_en driver.
>
> 	1. bnxt_en's ulp_probe function returns a structure that contains
> 	   information 	about the device and additional entry points.
> 	2. bnxt_en driver returns 'struct bnxt_eth_dev' that contains set
> 	   of operation  vectors that bnxt_re driver invokes later.
> 	3. bnxt_request_msix() allows the bnxt_re driver to specify the
> 	   number of MSI-X vectors that are needed.
> 	4. bnxt_send_fw_msg () is used to send messages to the FW
> 	5. bnxt_register_async_events() is used to register for async
> 	   event callbacks.
>
> v2: Remove some sparse warning. Also, remove some unused code from unreg
>     path.
> v3: Removed condition checks for rdev reported during static code analysis.
>     Check the return value of try_module_get while getting bnxt_en
>     reference.
>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---
>  drivers/infiniband/hw/bnxtre/bnxt_re.h      |  51 ++++
>  drivers/infiniband/hw/bnxtre/bnxt_re_main.c | 448 ++++++++++++++++++++++++++++
>  2 files changed, 499 insertions(+)
>
> diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
> index f9b8542..8b73e3d 100644
> --- a/drivers/infiniband/hw/bnxtre/bnxt_re.h
> +++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
> @@ -42,5 +42,56 @@
>  #define ROCE_DRV_MODULE_NAME		"bnxt_re"
>  #define ROCE_DRV_MODULE_VERSION		"1.0.0"
>
> +#define BNXT_RE_REF_WAIT_COUNT		10
>  #define BNXT_RE_DESC	"Broadcom NetXtreme-C/E RoCE Driver"
> +
> +struct bnxt_re_work {
> +	struct work_struct	work;
> +	unsigned long		event;
> +	struct bnxt_re_dev      *rdev;
> +	struct net_device	*vlan_dev;
> +};
> +
> +#define BNXT_RE_MIN_MSIX		2
> +#define BNXT_RE_MAX_MSIX		16
> +struct bnxt_re_dev {
> +	struct ib_device		ibdev;
> +	struct list_head		list;
> +	atomic_t			ref_count;
> +	unsigned long			flags;
> +#define BNXT_RE_FLAG_NETDEV_REGISTERED	0
> +#define BNXT_RE_FLAG_IBDEV_REGISTERED	1
> +#define BNXT_RE_FLAG_GOT_MSIX		2
> +#define BNXT_RE_FLAG_RCFW_CHANNEL_EN	8
> +#define BNXT_RE_FLAG_QOS_WORK_REG	16
> +	struct net_device		*netdev;
> +	unsigned int			version, major, minor;
> +	struct bnxt_en_dev		*en_dev;
> +	struct bnxt_msix_entry		msix_entries[BNXT_RE_MAX_MSIX];
> +	int				num_msix;
> +
> +	int				id;
> +
> +	atomic_t			qp_count;
> +	struct mutex			qp_lock;	/* protect qp list */
> +	struct list_head		qp_list;
> +
> +	atomic_t			cq_count;
> +	atomic_t			srq_count;
> +	atomic_t			mr_count;
> +	atomic_t			mw_count;
> +	/* Max of 2 lossless traffic class supported per port */
> +	u16				cosq[2];
> +};
> +
> +#define to_bnxt_re_dev(ptr, member)	\
> +	container_of((ptr), struct bnxt_re_dev, member)
> +
> +static inline struct device *rdev_to_dev(struct bnxt_re_dev *rdev)
> +{
> +	if (rdev)
> +		return  &rdev->ibdev.dev;
> +	return NULL;
> +}
> +
>  #endif
> diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
> index 6c22d51..fbd2ad3 100644
> --- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
> +++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
> @@ -38,10 +38,24 @@
>
>  #include <linux/module.h>
>  #include <linux/netdevice.h>
> +#include <linux/ethtool.h>
>  #include <linux/mutex.h>
>  #include <linux/list.h>
>  #include <linux/rculist.h>
> +#include <linux/spinlock.h>
> +#include <linux/pci.h>
> +#include <net/ipv6.h>
> +#include <net/addrconf.h>
> +
> +#include <rdma/ib_verbs.h>
> +#include <rdma/ib_user_verbs.h>
> +#include <rdma/ib_umem.h>
> +#include <rdma/ib_addr.h>
> +
> +#include "bnxt_ulp.h"
> +#include "bnxt_re_hsi.h"
>  #include "bnxt_re.h"
> +#include "bnxt.h"
>  static char version[] =
>  		BNXT_RE_DESC " v" ROCE_DRV_MODULE_VERSION "\n";
>
> @@ -55,6 +69,384 @@ static struct list_head bnxt_re_dev_list = LIST_HEAD_INIT(bnxt_re_dev_list);
>  /* Mutex to protect the list of bnxt_re devices added */
>  static DEFINE_MUTEX(bnxt_re_dev_lock);
>  static struct workqueue_struct *bnxt_re_wq;
> +
> +/* for handling bnxt_en callbacks later */
> +static void bnxt_re_stop(void *p)
> +{
> +}
> +
> +static void bnxt_re_start(void *p)
> +{
> +}
> +
> +static void bnxt_re_sriov_config(void *p, int num_vfs)
> +{
> +}
> +
> +static struct bnxt_ulp_ops bnxt_re_ulp_ops = {
> +	.ulp_async_notifier = NULL,
> +	.ulp_stop = bnxt_re_stop,
> +	.ulp_start = bnxt_re_start,
> +	.ulp_sriov_config = bnxt_re_sriov_config
> +};
> +
> +/* The rdev ref_count is to protect immature removal of the device */
> +static inline void bnxt_re_hold(struct bnxt_re_dev *rdev)
> +{
> +	atomic_inc(&rdev->ref_count);
> +}
> +
> +static inline void bnxt_re_put(struct bnxt_re_dev *rdev)
> +{
> +	atomic_dec(&rdev->ref_count);
> +}

Recently, in one of our submission to netdev and rdma, we got
a reminder that inline functions shouldn't be in *.c. Let for
the compiler to decide.

IMHO, it should be open-coded without wrappers and honestly I failed to
understand why do you need so many wrappers for one line standard kernel
functions.

Thanks

--sTC4Ri5uc2u6z9Yo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh70HcACgkQ5GN7iDZy
WKfnjRAAicPgZUHGJVToaYEjAy9cW76o1UH3UOidDSvgDZykTJIIn3DYeiGX3AZH
UGdn9ZtBPBkFAwBdtiIfpiPA2AiybUZMXNODr4EilQfRTbf7vO//lDEYBPBLDEyb
NI+CeUMceaLTcJDpycrrpSemEkkWWzti8pAtVACL6uR8YQxSucIE+ktkos6j1i0s
tWUpK9PrdzVrvIWTMYi2idw+K7FKhUlwGlsYyvbyXuoyVtT1WYMl2njaPriivFLR
ip0sTOo+jNB2ERMGLO766s2jswQjRiRdQgSTU21gcDuga2eu7RPmxD12kqNgLtsz
Seso+0yNDM1PAXS6HeiEWUfVNjQpSH4sxO/gU/WTDPUdTm0zqPNs4zHRimnr0zaN
F/z/IDVtG8ZxBWRbeComhf12XKe6nS0kdu7gdpRRePSdxCK7InENpcQAraxpo4Du
CCQHjZk9m3+2rnXETTBpyP3mbHx/twdODAG1lSOILJlmxXBN/4Dzm7fB+SG+lWVm
6SGOW5WQVG2aWh/9BxQOoG7hEkyoDcUNQRtI9uJtgfk2LVwDazDXR1pPJG4AR6KZ
Jxpio0u6tYg11xA04v5qVtyAqmi9GidKTk1G6DMYJFz5n4xKUbt798JysJ3r4A6z
GF5DHTODfBRy5h6vtQ6zVft71JED7BVusdtxubjGDPyOJVDWkfM=
=0hmv
-----END PGP SIGNATURE-----

--sTC4Ri5uc2u6z9Yo--
