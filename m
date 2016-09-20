From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v2 06/12] qedr: Add support for QP verbs
Date: Tue, 20 Sep 2016 19:30:48 +0300
Message-ID: <20160920163048.GQ26673@leon.nu>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-7-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="nWEzmRaGLXxZdI3i"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1474367764-9555-7-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--nWEzmRaGLXxZdI3i
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 20, 2016 at 01:35:58PM +0300, Ram Amrani wrote:
> From: Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>
> Add support for Queue Pair verbs which adds, deletes,
> modifies and queries Queue Pairs.
>
> Signed-off-by: Rajesh Borundia <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/infiniband/hw/qedr/main.c          |   15 +-
>  drivers/infiniband/hw/qedr/qedr.h          |  126 +++
>  drivers/infiniband/hw/qedr/qedr_cm.h       |   40 +
>  drivers/infiniband/hw/qedr/qedr_hsi_rdma.h |   11 +
>  drivers/infiniband/hw/qedr/verbs.c         | 1095 ++++++++++++++++++++++++-
>  drivers/infiniband/hw/qedr/verbs.h         |    7 +
>  drivers/net/ethernet/qlogic/qed/qed_cxt.h  |    1 +
>  drivers/net/ethernet/qlogic/qed/qed_roce.c | 1211 ++++++++++++++++++++++++++++
>  drivers/net/ethernet/qlogic/qed/qed_roce.h |   71 ++
>  include/linux/qed/qed_roce_if.h            |  144 ++++
>  include/uapi/rdma/providers/qedr-abi.h     |   35 +

Please be aware that the last version for ABI header files doesn't have
"provider" name in directory path (include/uapi/rdma/qedr-abi.h)


>  11 files changed, 2753 insertions(+), 3 deletions(-)
>  create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.h
>
> diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
> index c99dd6a..10ad9ed 100644
> --- a/drivers/infiniband/hw/qedr/main.c
> +++ b/drivers/infiniband/hw/qedr/main.c
> @@ -52,7 +52,7 @@ uint debug;
>  module_param(debug, uint, 0);
>  MODULE_PARM_DESC(debug, "Default debug msglevel");
>
> -static LIST_HEAD(qedr_dev_list);

You are removing code which was added in previous patches, why do you do
it?

> +#define QEDR_WQ_MULTIPLIER_DFT	(3)
>
>  void qedr_ib_dispatch_event(struct qedr_dev *dev, u8 port_num,
>  			    enum ib_event_type type)
> @@ -99,7 +99,11 @@ static int qedr_register_device(struct qedr_dev *dev)
>  				     QEDR_UVERBS(CREATE_CQ) |
>  				     QEDR_UVERBS(RESIZE_CQ) |
>  				     QEDR_UVERBS(DESTROY_CQ) |
> -				     QEDR_UVERBS(REQ_NOTIFY_CQ);
> +				     QEDR_UVERBS(REQ_NOTIFY_CQ) |
> +				     QEDR_UVERBS(CREATE_QP) |
> +				     QEDR_UVERBS(MODIFY_QP) |
> +				     QEDR_UVERBS(QUERY_QP) |
> +				     QEDR_UVERBS(DESTROY_QP);
>
>  	dev->ibdev.phys_port_cnt = 1;
>  	dev->ibdev.num_comp_vectors = dev->num_cnq;
> @@ -124,6 +128,11 @@ static int qedr_register_device(struct qedr_dev *dev)
>  	dev->ibdev.resize_cq = qedr_resize_cq;
>  	dev->ibdev.req_notify_cq = qedr_arm_cq;
>
> +	dev->ibdev.create_qp = qedr_create_qp;
> +	dev->ibdev.modify_qp = qedr_modify_qp;
> +	dev->ibdev.query_qp = qedr_query_qp;
> +	dev->ibdev.destroy_qp = qedr_destroy_qp;
> +
>  	dev->ibdev.query_pkey = qedr_query_pkey;
>
>  	dev->ibdev.dma_device = &dev->pdev->dev;
> @@ -619,6 +628,8 @@ static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
>  		goto init_err;
>  	}
>
> +	dev->wq_multiplier = QEDR_WQ_MULTIPLIER_DFT;
> +
>  	qedr_pci_set_atomic(dev, pdev);
>
>  	rc = qedr_alloc_resources(dev);
> diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
> index dd974d5..05017be 100644
> --- a/drivers/infiniband/hw/qedr/qedr.h
> +++ b/drivers/infiniband/hw/qedr/qedr.h
> @@ -49,6 +49,9 @@
>  enum DP_QEDR_MODULE {
>  	QEDR_MSG_INIT = 0x10000,

We prefer shift notation (1 << 16) instead of 0x10000.

>  	QEDR_MSG_CQ = 0x20000,
> +	QEDR_MSG_RQ = 0x40000,
> +	QEDR_MSG_SQ = 0x80000,
> +	QEDR_MSG_QP = (QEDR_MSG_SQ | QEDR_MSG_RQ),
>  	QEDR_MSG_MR = 0x100000,
>  	QEDR_MSG_MISC = 0x400000,
>  };

--nWEzmRaGLXxZdI3i
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4WQ4AAoJEORje4g2clind6UP/jeGfgIoum6baf+kwQQajJhq
cyjhnajrj0xu+hskjHac9uREIxVXLhEemsLl7mqq9IDrNFpqa9Gh8sFBlm7fyJEb
ozJ6ig4catjqjU1grLuFPWlbnShP2mF3B26viiWHl40S4+A+tj4IsO8SHFQTlr2Z
O06H7fJE6SWyJVMnOixSqsoWPeL/Jgb4GD+7EviNo5d6eiSr4jsgLdcgslzAlPYS
fXhq4OLSgF+eQmAkPEPdd5i/+GY4HJBAGUeLjz1LDY0+cJsmbRSu8QQDMa0Yi7Tw
lcUIxj+PAFgLnq4lMUN1+ewdn7izV5HB6CuxMMjfTz082sKl/CLdwPK8JVhPBC5Z
TvF5+JCakmFbNMQPo93XpTZ/NNUpRS32u0tBrnc8ectEwxw/51hi+92RShrK8UYj
KBvf+LjdHHqmgladqcMQWabZoj1D8i1m2yCjmq7bPhDqJwI4NC/VxaFTafEFoZ2c
W17+rzGP13XB7RJUu5MbvqFvt7K5DTkHuDGjwr9fPX4iwQoc68KkwjttU2hGltV6
qO+euciDkbHIxKfNfRAlTdbvDLDK4QJO1+INE3zlZTyAqoNIhRMr+WtxUVSmphPS
9sCHI+GhvP5953pChNodQpZDYHj/JaTFsnQdBkiJUepR0pnPKF2T988kimlBcWTD
mzzMB3aCIBE+3wdhNRgJ
=ikMp
-----END PGP SIGNATURE-----

--nWEzmRaGLXxZdI3i--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
