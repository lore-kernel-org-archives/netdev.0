From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] bnx2: Add support for CNIC driver.
Date: Wed, 21 May 2008 23:45:41 -0700
Message-ID: <20080522064541.GA11933@linux.vnet.ibm.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com> <1211418386-18203-2-git-send-email-mchan@broadcom.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, michaelc@cs.wisc.edu, anilgv@broadcom.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:51142 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbYEVGpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 02:45:51 -0400
Content-Disposition: inline
In-Reply-To: <1211418386-18203-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2008 at 06:06:24PM -0700, Michael Chan wrote:
> Add interface for a separate CNIC driver to drive additional rings
> and other resources for iSCSI.
> 
> A probe function is exported so that the CNIC driver can get
> information about bnx2 devices.  After calling the probe function,
> the CNIC driver can then register with the BNX2 driver before
> initializing the hardware for iSCSI.

Some RCU-related questions interspersed below, for example, how are
updates protected?

							Thanx, Paul

> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c |  202 ++++++++++++++++++++++++++++++++++++++++++++++++++--
>  drivers/net/bnx2.h |   21 ++++++
>  2 files changed, 218 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index b32d227..ba12daf 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -48,6 +48,11 @@
>  #include <linux/cache.h>
>  #include <linux/zlib.h>
> 
> +#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
> +#define BCM_CNIC	1
> +#include "cnic_drv.h"
> +#endif
> +
>  #include "bnx2.h"
>  #include "bnx2_fw.h"
>  #include "bnx2_fw2.h"
> @@ -302,6 +307,170 @@ bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
>  	spin_unlock_bh(&bp->indirect_lock);
>  }
> 
> +#ifdef BCM_CNIC
> +static int
> +bnx2_drv_ctl(struct net_device *dev, struct drv_ctl_info *info)
> +{
> +	struct bnx2 *bp = netdev_priv(dev);
> +	struct drv_ctl_io *io = &info->data.io;
> +
> +	switch (info->cmd) {
> +	case DRV_CTL_IO_WR_CMD:
> +		bnx2_reg_wr_ind(bp, io->offset, io->data);
> +		break;
> +	case DRV_CTL_IO_RD_CMD:
> +		io->data = bnx2_reg_rd_ind(bp, io->offset);
> +		break;
> +	case DRV_CTL_CTX_WR_CMD:
> +		bnx2_ctx_wr(bp, io->cid_addr, io->offset, io->data);
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
> +static void bnx2_setup_cnic_irq_info(struct bnx2 *bp)
> +{
> +	struct cnic_ops *c_ops;
> +	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> +	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
> +	int sb_id;
> +
> +	rcu_read_lock();
> +	c_ops = rcu_dereference(bp->cnic_ops);
> +	if (!c_ops)
> +		goto done;

Given that c_ops is unused below, what is happening here?  What prevents
bp->cnic_ops from becoming NULL immediately after we test it?  And if
it is OK for bp->cnic_ops to become NULL immediately after we test it,
why are we bothering to test it?

> +
> +	if (bp->flags & BNX2_FLAG_USING_MSIX) {
> +		cp->drv_state |= CNIC_DRV_STATE_USING_MSIX;
> +		bnapi->cnic_present = 0;
> +		sb_id = BNX2_CNIC_VEC;
> +		cp->irq_arr[0].irq_flags |= CNIC_IRQ_FL_MSIX;
> +	} else {
> +		cp->drv_state &= ~CNIC_DRV_STATE_USING_MSIX;
> +		bnapi->cnic_tag = bnapi->last_status_idx;
> +		bnapi->cnic_present = 1;
> +		sb_id = 0;
> +		cp->irq_arr[0].irq_flags &= !CNIC_IRQ_FL_MSIX;
> +	}
> +
> +	cp->irq_arr[0].vector = bp->irq_tbl[sb_id].vector;
> +	cp->irq_arr[0].status_blk = (void *) ((unsigned long) bp->status_blk +
> +		(BNX2_SBLK_MSIX_ALIGN_SIZE * sb_id));
> +	cp->irq_arr[0].status_blk_num = sb_id;
> +	cp->num_irq = 1;
> +
> +done:
> +	rcu_read_unlock();
> +}
> +
> +static int bnx2_register_cnic(struct net_device *dev, struct cnic_ops *ops,
> +			      void *data)
> +{
> +	struct bnx2 *bp = netdev_priv(dev);
> +	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> +
> +	if (ops == NULL)
> +		return -EINVAL;
> +
> +	if (!try_module_get(ops->cnic_owner))
> +		return -EBUSY;
> +
> +	bp->cnic_data = data;
> +	rcu_assign_pointer(bp->cnic_ops, ops);

What prevents multiple tasks from doing this assignment concurrently?

> +
> +	cp->num_irq = 0;
> +	cp->drv_state = CNIC_DRV_STATE_REGD;
> +
> +	bnx2_setup_cnic_irq_info(bp);
> +
> +	return 0;
> +}
> +
> +static int bnx2_unregister_cnic(struct net_device *dev)
> +{
> +	struct bnx2 *bp = netdev_priv(dev);
> +	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
> +	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> +
> +	cp->drv_state = 0;
> +	module_put(bp->cnic_ops->cnic_owner);
> +	bnapi->cnic_present = 0;
> +	rcu_assign_pointer(bp->cnic_ops, NULL);

What prevents this from running concurrently with bnx2_register_cnic()?

> +	synchronize_rcu();

The caller is responsible for freeing up the old bp->cnic_ops structure?
Or is this structure statically allocated?

If so, is the idea to delay return until all prior calls through the
old ops structure have completed?

> +	return 0;
> +}
> +
> +struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
> +{
> +	struct bnx2 *bp = netdev_priv(dev);
> +	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> +
> +	cp->chip_id = bp->chip_id;
> +	cp->pdev = bp->pdev;
> +	cp->io_base = bp->regview;
> +	cp->drv_ctl = bnx2_drv_ctl;
> +	cp->drv_register_cnic = bnx2_register_cnic;
> +	cp->drv_unregister_cnic = bnx2_unregister_cnic;
> +
> +	return cp;
> +}
> +EXPORT_SYMBOL(bnx2_cnic_probe);
> +
> +static void
> +bnx2_cnic_stop(struct bnx2 *bp)
> +{
> +	struct cnic_ops *c_ops;
> +	struct cnic_ctl_info info;
> +
> +	rcu_read_lock();
> +	c_ops = rcu_dereference(bp->cnic_ops);
> +	if (c_ops) {
> +		info.cmd = CNIC_CTL_STOP_CMD;
> +		c_ops->cnic_ctl(bp->cnic_data, &info);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static void
> +bnx2_cnic_start(struct bnx2 *bp)
> +{
> +	struct cnic_ops *c_ops;
> +	struct cnic_ctl_info info;
> +
> +	rcu_read_lock();
> +	c_ops = rcu_dereference(bp->cnic_ops);
> +	if (c_ops) {
> +		if (!(bp->flags & BNX2_FLAG_USING_MSIX)) {
> +			struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
> +
> +			bnapi->cnic_tag = bnapi->last_status_idx;
> +		}
> +		info.cmd = CNIC_CTL_START_CMD;
> +		c_ops->cnic_ctl(bp->cnic_data, &info);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +#else
> +
> +static void bnx2_setup_cnic_irq_info(struct bnx2 *bp)
> +{
> +}
> +
> +static void
> +bnx2_cnic_stop(struct bnx2 *bp)
> +{
> +}
> +
> +static void
> +bnx2_cnic_start(struct bnx2 *bp)
> +{
> +}
> +
> +#endif
> +
>  static int
>  bnx2_read_phy(struct bnx2 *bp, u32 reg, u32 *val)
>  {
> @@ -475,6 +644,7 @@ bnx2_napi_enable(struct bnx2 *bp)
>  static void
>  bnx2_netif_stop(struct bnx2 *bp)
>  {
> +	bnx2_cnic_stop(bp);
>  	bnx2_disable_int_sync(bp);
>  	if (netif_running(bp->dev)) {
>  		bnx2_napi_disable(bp);
> @@ -491,6 +661,7 @@ bnx2_netif_start(struct bnx2 *bp)
>  			netif_wake_queue(bp->dev);
>  			bnx2_napi_enable(bp);
>  			bnx2_enable_int(bp);
> +			bnx2_cnic_start(bp);
>  		}
>  	}
>  }
> @@ -3007,6 +3178,9 @@ bnx2_has_work(struct bnx2_napi *bnapi)
>  	    (sblk->status_attn_bits_ack & STATUS_ATTN_EVENTS))
>  		return 1;
> 
> +	if (bnapi->cnic_present && (bnapi->cnic_tag != sblk->status_idx))
> +		return 1;
> +
>  	return 0;
>  }
> 
> @@ -3059,6 +3233,20 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
>  	if (bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons)
>  		work_done += bnx2_rx_int(bp, bnapi, budget - work_done);
> 
> +#ifdef BCM_CNIC
> +	if (bnapi->cnic_present) {
> +		struct cnic_ops *c_ops;
> +
> +		rcu_read_lock();
> +		c_ops = rcu_dereference(bp->cnic_ops);
> +		if (c_ops)
> +			bnapi->cnic_tag =
> +				c_ops->cnic_handler(bp->cnic_data,
> +						    bnapi->status_blk);
> +		rcu_read_unlock();
> +	}
> +#endif
> +
>  	return work_done;
>  }
> 
> @@ -3100,7 +3288,6 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
>  			break;
>  		}
>  	}
> -
>  	return work_done;
>  }
> 
> @@ -5517,19 +5704,19 @@ static void
>  bnx2_enable_msix(struct bnx2 *bp)
>  {
>  	int i, rc;
> -	struct msix_entry msix_ent[BNX2_MAX_MSIX_VEC];
> +	struct msix_entry msix_ent[BNX2_MAX_MSIX_CNIC_VEC];
> 
>  	bnx2_setup_msix_tbl(bp);
>  	REG_WR(bp, BNX2_PCI_MSIX_CONTROL, BNX2_MAX_MSIX_HW_VEC - 1);
>  	REG_WR(bp, BNX2_PCI_MSIX_TBL_OFF_BIR, BNX2_PCI_GRC_WINDOW2_BASE);
>  	REG_WR(bp, BNX2_PCI_MSIX_PBA_OFF_BIT, BNX2_PCI_GRC_WINDOW3_BASE);
> 
> -	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
> +	for (i = 0; i < BNX2_MAX_MSIX_CNIC_VEC; i++) {
>  		msix_ent[i].entry = i;
>  		msix_ent[i].vector = 0;
>  	}
> 
> -	rc = pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_VEC);
> +	rc = pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_CNIC_VEC);
>  	if (rc != 0)
>  		return;
> 
> @@ -5540,10 +5727,14 @@ bnx2_enable_msix(struct bnx2 *bp)
>  	strcat(bp->irq_tbl[BNX2_BASE_VEC].name, "-base");
>  	strcpy(bp->irq_tbl[BNX2_TX_VEC].name, bp->dev->name);
>  	strcat(bp->irq_tbl[BNX2_TX_VEC].name, "-tx");
> +#ifdef BCM_CNIC
> +	strcpy(bp->irq_tbl[BNX2_CNIC_VEC].name, bp->dev->name);
> +	strcat(bp->irq_tbl[BNX2_CNIC_VEC].name, "-cnic");
> +#endif
> 
>  	bp->irq_nvecs = BNX2_MAX_MSIX_VEC;
>  	bp->flags |= BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
> -	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
> +	for (i = 0; i < BNX2_MAX_MSIX_CNIC_VEC; i++)
>  		bp->irq_tbl[i].vector = msix_ent[i].vector;
>  }
> 
> @@ -5571,6 +5762,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
>  			bp->irq_tbl[0].vector = bp->pdev->irq;
>  		}
>  	}
> +	bnx2_setup_cnic_irq_info(bp);
>  }
> 
>  /* Called with rtnl_lock */
> diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
> index 16020a1..a47ee60 100644
> --- a/drivers/net/bnx2.h
> +++ b/drivers/net/bnx2.h
> @@ -6562,6 +6562,15 @@ struct flash_spec {
>  #define BNX2_TX_VEC		1
>  #define BNX2_TX_INT_NUM	(BNX2_TX_VEC << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT)
> 
> +#ifdef BCM_CNIC
> +#define BNX2_MAX_MSIX_CNIC_VEC	(BNX2_MAX_MSIX_VEC + 1)
> +#define BNX2_CNIC_VEC		2
> +#define BNX2_CNIC_INT_NUM	\
> +	(BNX2_CNIC_VEC << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT)
> +#else
> +#define BNX2_MAX_MSIX_CNIC_VEC	BNX2_MAX_MSIX_VEC
> +#endif
> +
>  struct bnx2_irq {
>  	irq_handler_t	handler;
>  	u16		vector;
> @@ -6577,6 +6586,9 @@ struct bnx2_napi {
>  	u32 			last_status_idx;
>  	u32			int_num;
> 
> +	u32			cnic_tag;
> +	int			cnic_present;
> +
>  	u16			tx_cons;
>  	u16			hw_tx_cons;
> 
> @@ -6648,6 +6660,11 @@ struct bnx2 {
>  	int		tx_ring_size;
>  	u32		tx_wake_thresh;
> 
> +#ifdef BCM_CNIC
> +	struct cnic_ops		*cnic_ops;
> +	void			*cnic_data;
> +#endif
> +
>  	/* End of fields used in the performance code paths. */
> 
>  	char			*name;
> @@ -6813,6 +6830,10 @@ struct bnx2 {
> 
>  	struct bnx2_irq		irq_tbl[BNX2_MAX_MSIX_VEC];
>  	int			irq_nvecs;
> +
> +#ifdef BCM_CNIC
> +	struct cnic_eth_dev	cnic_eth_dev;
> +#endif
>  };
> 
>  #define REG_RD(bp, offset)					\
> -- 
> 1.5.5.GIT
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
