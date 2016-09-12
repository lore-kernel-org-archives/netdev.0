From: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC 03/11] Add support for RoCE HW init
Date: Mon, 12 Sep 2016 21:57:38 +0300
Message-ID: <e5d0951a-0247-4516-1b63-aebf9933fdaa@mellanox.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-4-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473696465-27986-4-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 12/09/2016 19:07, Ram Amrani wrote:
> Allocate and setup RoCE resources, interrupts and completion queues.
> Adds device attributes.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
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
>  drivers/net/ethernet/qlogic/qed/qed_roce.c     | 887 +++++++++++++++++++++++++
>  drivers/net/ethernet/qlogic/qed/qed_roce.h     | 117 ++++
>  drivers/net/ethernet/qlogic/qed/qed_sp.h       |   1 +
>  drivers/net/ethernet/qlogic/qed/qed_spq.c      |   8 +
>  drivers/net/ethernet/qlogic/qede/qede_roce.c   |   2 +-
>  include/linux/qed/qed_if.h                     |   5 +-
>  include/linux/qed/qed_roce_if.h                | 345 ++++++++++
>  18 files changed, 2281 insertions(+), 7 deletions(-)
>  create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi.h
>  create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.c
>  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.h
>  create mode 100644 include/linux/qed/qed_roce_if.h
> 
> diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
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
>  
>  MODULE_DESCRIPTION("QLogic 40G/100G ROCE Driver");
> @@ -80,6 +82,139 @@ static int qedr_register_device(struct qedr_dev *dev)
>  	return 0;
>  }
>  
> +/* This function allocates fast-path status block memory */
> +static int qedr_alloc_mem_sb(struct qedr_dev *dev,
> +			     struct qed_sb_info *sb_info, u16 sb_id)
> +{
> +	struct status_block *sb_virt;
> +	dma_addr_t sb_phys;
> +	int rc;
> +
> +	sb_virt = dma_alloc_coherent(&dev->pdev->dev,
> +				     sizeof(*sb_virt), &sb_phys, GFP_KERNEL);
> +	if (!sb_virt) {
> +		pr_err("Status block allocation failed\n");
> +		return -ENOMEM;
> +	}
> +
> +	rc = dev->ops->common->sb_init(dev->cdev, sb_info,
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
> +			     struct qed_sb_info *sb_info, int sb_id)
> +{
> +	if (sb_info->sb_virt) {
> +		dev->ops->common->sb_release(dev->cdev, sb_info, sb_id);
> +		dma_free_coherent(&dev->pdev->dev, sizeof(*sb_info->sb_virt),
> +				  (void *)sb_info->sb_virt, sb_info->sb_phys);
> +	}
> +}
> +
> +static void qedr_free_resources(struct qedr_dev *dev)
> +{
> +	int i;
> +
> +	for (i = 0; i < dev->num_cnq; i++) {
> +		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +		dev->ops->common->chain_free(dev->cdev, &dev->cnq_array[i].pbl);
> +	}
> +
> +	kfree(dev->cnq_array);
> +	kfree(dev->sb_array);
> +	kfree(dev->sgid_tbl);
> +}
> +
> +static int qedr_alloc_resources(struct qedr_dev *dev)
> +{
> +	struct qedr_cnq *cnq;
> +	__le16 *cons_pi;
> +	u16 n_entries;
> +	int i, rc;
> +
> +	dev->sgid_tbl = kzalloc(sizeof(union ib_gid) *
> +				QEDR_MAX_SGID, GFP_KERNEL);
> +	if (!dev->sgid_tbl)
> +		return -ENOMEM;
> +
> +	spin_lock_init(&dev->sgid_lock);
> +
> +	/* Allocate Status blocks for CNQ */
> +	dev->sb_array = kcalloc(dev->num_cnq, sizeof(*dev->sb_array),
> +				GFP_KERNEL);
> +	if (!dev->sb_array) {
> +		rc = -ENOMEM;
> +		goto err1;
> +	}
> +
> +	dev->cnq_array = kcalloc(dev->num_cnq,
> +				 sizeof(*dev->cnq_array), GFP_KERNEL);
> +	if (!dev->cnq_array) {
> +		rc = -ENOMEM;
> +		goto err2;
> +	}
> +
> +	dev->sb_start = dev->ops->rdma_get_start_sb(dev->cdev);
> +
> +	/* Allocate CNQ PBLs */
> +	n_entries = min_t(u32, QED_RDMA_MAX_CNQ_SIZE, QEDR_ROCE_MAX_CNQ_SIZE);
> +	for (i = 0; i < dev->num_cnq; i++) {
> +		cnq = &dev->cnq_array[i];
> +
> +		rc = qedr_alloc_mem_sb(dev, &dev->sb_array[i],
> +				       dev->sb_start + i);
> +		if (rc)
> +			goto err3;
> +
> +		rc = dev->ops->common->chain_alloc(dev->cdev,
> +						   QED_CHAIN_USE_TO_CONSUME,
> +						   QED_CHAIN_MODE_PBL,
> +						   QED_CHAIN_CNT_TYPE_U16,
> +						   n_entries,
> +						   sizeof(struct regpair *),
> +						   &cnq->pbl);
> +		if (rc)
> +			goto err4;
> +
> +		cnq->dev = dev;
> +		cnq->sb = &dev->sb_array[i];
> +		cons_pi = dev->sb_array[i].sb_virt->pi_array;
> +		cnq->hw_cons_ptr = &cons_pi[QED_ROCE_PROTOCOL_INDEX];
> +		cnq->index = i;
> +		sprintf(cnq->name, "qedr%d@pci:%s",
> +			i, pci_name(dev->pdev));
> +
> +		DP_VERBOSE(dev, QEDR_MSG_INIT, "cnq[%d].cons=%d\n",
> +			   i, qed_chain_get_cons_idx(&cnq->pbl));
> +	}
> +
> +	return 0;
> +err4:
> +	qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +	for (--i; i >= 0; i--) {
> +		dev->ops->common->chain_free(dev->cdev, &dev->cnq_array[i].pbl);
> +		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +	}
> +err3:
> +	for (--i; i >= 0; i--)
> +		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
> +	kfree(dev->cnq_array);
This doesn't seem right, going from err4 to err3 i = 0, the for loop in err3
won't do anything.

> +err2:
> +	kfree(dev->sb_array);
> +err1:
> +	kfree(dev->sgid_tbl);
> +	return rc;
> +}
> +

Mark
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
