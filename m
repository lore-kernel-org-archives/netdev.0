From: Ram Amrani <Ram.Amrani@qlogic.com>
Subject: RE: [RFC 03/11] Add support for RoCE HW init
Date: Tue, 13 Sep 2016 08:30:17 +0000
Message-ID: <DM3PR1101MB11815C9932F98947A8A426FEE2FE0@DM3PR1101MB1181.namprd11.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-4-git-send-email-Ram.Amrani@qlogic.com>
 <e5d0951a-0247-4516-1b63-aebf9933fdaa@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Michal Kalderon <Michal.Kalderon@qlogic.com>,
        Rajesh Borundia <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Mark Bloch <markb@mellanox.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0122.outbound.protection.outlook.com ([104.47.36.122]:31712
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752739AbcIMJDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 05:03:16 -0400
In-Reply-To: <e5d0951a-0247-4516-1b63-aebf9933fdaa@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Mark.
This will be fixed in next version.

Ram


-----Original Message-----
From: Mark Bloch [mailto:markb@mellanox.com]=20
Sent: Monday, September 12, 2016 9:58 PM
To: Ram Amrani <Ram.Amrani@qlogic.com>; dledford@redhat.com; David Miller <=
davem@davemloft.net>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>; Ariel Elior <Ariel.Elior@qlogic.c=
om>; Michal Kalderon <Michal.Kalderon@qlogic.com>; Rajesh Borundia <rajesh.=
borundia@qlogic.com>; linux-rdma@vger.kernel.org; netdev <netdev@vger.kerne=
l.org>
Subject: Re: [RFC 03/11] Add support for RoCE HW init



On 12/09/2016 19:07, Ram Amrani wrote:
> Allocate and setup RoCE resources, interrupts and completion queues.
> Adds device attributes.
>=20
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Ram Amrani <Ram.Amrani@qlogic.com>
> ---
>  drivers/infiniband/hw/qedr/main.c              | 408 +++++++++++-
>  drivers/infiniband/hw/qedr/qedr.h              | 118 ++++
>  drivers/infiniband/hw/qedr/qedr_hsi.h          |  56 ++
>  drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  96 +++
>  drivers/net/ethernet/qlogic/qed/Makefile       |   1 +
>  drivers/net/ethernet/qlogic/qed/qed.h          |  26 +-
>  drivers/net/ethernet/qlogic/qed/qed_cxt.c      |   6 +
>  drivers/net/ethernet/qlogic/qed/qed_cxt.h      |   6 +
>  drivers/net/ethernet/qlogic/qed/qed_dev.c      | 155 +++++
>  drivers/net/ethernet/qlogic/qed/qed_main.c     |  44 +-
>  drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   7 +
>  drivers/net/ethernet/qlogic/qed/qed_roce.c     | 887 +++++++++++++++++++=
++++++
>  drivers/net/ethernet/qlogic/qed/qed_roce.h     | 117 ++++
>  drivers/net/ethernet/qlogic/qed/qed_sp.h       |   1 +
>  drivers/net/ethernet/qlogic/qed/qed_spq.c      |   8 +
>  drivers/net/ethernet/qlogic/qede/qede_roce.c   |   2 +-
>  include/linux/qed/qed_if.h                     |   5 +-
>  include/linux/qed/qed_roce_if.h                | 345 ++++++++++
>  18 files changed, 2281 insertions(+), 7 deletions(-)  create mode=20
> 100644 drivers/infiniband/hw/qedr/qedr_hsi.h
>  create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.c
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.h
>  create mode 100644 include/linux/qed/qed_roce_if.h
>=20
> diff --git a/drivers/infiniband/hw/qedr/main.c=20
> b/drivers/infiniband/hw/qedr/main.c
> index 3fe58a3..0b5274a 100644
> --- a/drivers/infiniband/hw/qedr/main.c
> +++ b/drivers/infiniband/hw/qedr/main.c
> @@ -36,6 +36,8 @@
>  #include <linux/iommu.h>
>  #include <net/addrconf.h>
>  #include <linux/qed/qede_roce.h>
> +#include <linux/qed/qed_chain.h>
> +#include <linux/qed/qed_if.h>
>  #include "qedr.h"
> =20
>  MODULE_DESCRIPTION("QLogic 40G/100G ROCE Driver"); @@ -80,6 +82,139=20
> @@ static int qedr_register_device(struct qedr_dev *dev)
>  	return 0;
>  }
> =20
> +/* This function allocates fast-path status block memory */ static=20
> +int qedr_alloc_mem_sb(struct qedr_dev *dev,
> +			     struct qed_sb_info *sb_info, u16 sb_id) {
> +	struct status_block *sb_virt;
> +	dma_addr_t sb_phys;
> +	int rc;
> +
> +	sb_virt =3D dma_alloc_coherent(&dev->pdev->dev,
> +				     sizeof(*sb_virt), &sb_phys, GFP_KERNEL);
> +	if (!sb_virt) {
> +		pr_err("Status block allocation failed\n");
> +		return -ENOMEM;
> +	}
> +
> +	rc =3D dev->ops->common->sb_init(dev->cdev, sb_info,
> +				       sb_virt, sb_phys, sb_id,
> +				       QED_SB_TYPE_CNQ);
> +	if (rc) {
> +		pr_err("Status block initialization failed\n");
> +		dma_free_coherent(&dev->pdev->dev, sizeof(*sb_virt),
> +				  sb_virt, sb_phys);
> +		return rc;
> +	}
> +
> +	return 0;
> +}
> +
> +static void qedr_free_mem_sb(struct qedr_dev *dev,
> +			     struct qed_sb_info *sb_info, int sb_id) {
> +	if (sb_info->sb_virt) {
> +		dev->ops->common->sb_release(dev->cdev, sb_info, sb_id);
> +		dma_free_coherent(&dev->pdev->dev, sizeof(*sb_info->sb_virt),
> +				  (void *)sb_info->sb_virt, sb_info->sb_phys);
> +	}
> +}
> +
> +static void qedr_free_resources(struct qedr_dev *dev) {
> +	int i;
> +
> +	for (i =3D 0; i < dev->num_cnq; i++) {
> +		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +		dev->ops->common->chain_free(dev->cdev, &dev->cnq_array[i].pbl);
> +	}
> +
> +	kfree(dev->cnq_array);
> +	kfree(dev->sb_array);
> +	kfree(dev->sgid_tbl);
> +}
> +
> +static int qedr_alloc_resources(struct qedr_dev *dev) {
> +	struct qedr_cnq *cnq;
> +	__le16 *cons_pi;
> +	u16 n_entries;
> +	int i, rc;
> +
> +	dev->sgid_tbl =3D kzalloc(sizeof(union ib_gid) *
> +				QEDR_MAX_SGID, GFP_KERNEL);
> +	if (!dev->sgid_tbl)
> +		return -ENOMEM;
> +
> +	spin_lock_init(&dev->sgid_lock);
> +
> +	/* Allocate Status blocks for CNQ */
> +	dev->sb_array =3D kcalloc(dev->num_cnq, sizeof(*dev->sb_array),
> +				GFP_KERNEL);
> +	if (!dev->sb_array) {
> +		rc =3D -ENOMEM;
> +		goto err1;
> +	}
> +
> +	dev->cnq_array =3D kcalloc(dev->num_cnq,
> +				 sizeof(*dev->cnq_array), GFP_KERNEL);
> +	if (!dev->cnq_array) {
> +		rc =3D -ENOMEM;
> +		goto err2;
> +	}
> +
> +	dev->sb_start =3D dev->ops->rdma_get_start_sb(dev->cdev);
> +
> +	/* Allocate CNQ PBLs */
> +	n_entries =3D min_t(u32, QED_RDMA_MAX_CNQ_SIZE, QEDR_ROCE_MAX_CNQ_SIZE)=
;
> +	for (i =3D 0; i < dev->num_cnq; i++) {
> +		cnq =3D &dev->cnq_array[i];
> +
> +		rc =3D qedr_alloc_mem_sb(dev, &dev->sb_array[i],
> +				       dev->sb_start + i);
> +		if (rc)
> +			goto err3;
> +
> +		rc =3D dev->ops->common->chain_alloc(dev->cdev,
> +						   QED_CHAIN_USE_TO_CONSUME,
> +						   QED_CHAIN_MODE_PBL,
> +						   QED_CHAIN_CNT_TYPE_U16,
> +						   n_entries,
> +						   sizeof(struct regpair *),
> +						   &cnq->pbl);
> +		if (rc)
> +			goto err4;
> +
> +		cnq->dev =3D dev;
> +		cnq->sb =3D &dev->sb_array[i];
> +		cons_pi =3D dev->sb_array[i].sb_virt->pi_array;
> +		cnq->hw_cons_ptr =3D &cons_pi[QED_ROCE_PROTOCOL_INDEX];
> +		cnq->index =3D i;
> +		sprintf(cnq->name, "qedr%d@pci:%s",
> +			i, pci_name(dev->pdev));
> +
> +		DP_VERBOSE(dev, QEDR_MSG_INIT, "cnq[%d].cons=3D%d\n",
> +			   i, qed_chain_get_cons_idx(&cnq->pbl));
> +	}
> +
> +	return 0;
> +err4:
> +	qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +	for (--i; i >=3D 0; i--) {
> +		dev->ops->common->chain_free(dev->cdev, &dev->cnq_array[i].pbl);
> +		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +	}
> +err3:
> +	for (--i; i >=3D 0; i--)
> +		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +	kfree(dev->cnq_array);
This doesn't seem right, going from err4 to err3 i =3D 0, the for loop in e=
rr3 won't do anything.

> +err2:
> +	kfree(dev->sb_array);
> +err1:
> +	kfree(dev->sgid_tbl);
> +	return rc;
> +}
> +

Mark
