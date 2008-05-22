From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] cnic: Add CNIC driver.
Date: Thu, 22 May 2008 00:44:22 -0700
Message-ID: <20080522074422.GB11933@linux.vnet.ibm.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com> <1211418386-18203-3-git-send-email-mchan@broadcom.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, michaelc@cs.wisc.edu, anilgv@broadcom.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1211418386-18203-3-git-send-email-mchan@broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2008 at 06:06:25PM -0700, Michael Chan wrote:
> The CNIC driver controls BNX2 hardware rings and resources used by
> iSCSI.  It depends on the BNX2 driver to reset the chip and set up
> the proper link speed.
> 
> All hardware resources for iSCSI are separate from those used for
> ethernet networking.  If MSI-X is used, the CNIC driver will
> register its own MSI-X vector for iSCSI interrupts.  If MSI-X is
> not used, the single interrupt will be shared between the BNX2
> driver and the CNIC driver.

Some questions interspersed below.

							Thanx, Paul

> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/Kconfig     |   10 +
>  drivers/net/Makefile    |    1 +
>  drivers/net/cnic.c      | 2439 +++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/cnic.h      |  221 +++++
>  drivers/net/cnic_defs.h |  553 +++++++++++
>  drivers/net/cnic_drv.h  |  112 +++
>  drivers/net/cnic_if.h   |  171 ++++
>  7 files changed, 3507 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/cnic.c
>  create mode 100644 drivers/net/cnic.h
>  create mode 100644 drivers/net/cnic_defs.h
>  create mode 100644 drivers/net/cnic_drv.h
>  create mode 100644 drivers/net/cnic_if.h
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 9f6cc8a..f7f51f2 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2245,6 +2245,16 @@ config BNX2
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called bnx2.  This is recommended.
> 
> +config CNIC
> +	tristate "Broadcom CNIC support"
> +	depends on BNX2
> +	help
> +	  This driver supports offload features of Broadcom NetXtremeII
> +	  gigabit Ethernet cards.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called cnic.  This is recommended.
> +
>  config SPIDER_NET
>  	tristate "Spider Gigabit Ethernet driver"
>  	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index dcbfe84..39ec0db 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -67,6 +67,7 @@ obj-$(CONFIG_FEALNX) += fealnx.o
>  obj-$(CONFIG_TIGON3) += tg3.o
>  obj-$(CONFIG_BNX2) += bnx2.o
>  obj-$(CONFIG_BNX2X) += bnx2x.o
> +obj-$(CONFIG_CNIC) += cnic.o
>  spidernet-y += spider_net.o spider_net_ethtool.o
>  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
>  obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> new file mode 100644
> index 0000000..fbeb3a8
> --- /dev/null
> +++ b/drivers/net/cnic.c
> @@ -0,0 +1,2439 @@
> +/* cnic.c: Broadcom CNIC core network driver.
> + *
> + * Copyright (c) 2006-2007 Broadcom Corporation
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation.
> + *
> + * Written by: John(Zongxi) Chen (zongxi@broadcom.com)
> + * Modified and maintained by: Michael Chan <mchan@broadcom.com>
> + */
> +
> +#include <linux/module.h>
> +
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +#include <linux/list.h>
> +#include <linux/slab.h>
> +#include <linux/pci.h>
> +#include <linux/init.h>
> +#include <linux/netdevice.h>
> +#include <linux/inetdevice.h>
> +#include <linux/in.h>
> +#include <linux/dma-mapping.h>
> +#include <asm/byteorder.h>
> +#include <linux/delay.h>
> +#include <linux/ethtool.h>
> +#include <linux/if_vlan.h>
> +#define BCM_VLAN 1
> +#include <net/ip.h>
> +#include <net/tcp.h>
> +#include <net/arp.h>
> +#include <net/neighbour.h>
> +#include <net/route.h>
> +#include <net/ipv6.h>
> +#include <net/ip6_route.h>
> +#include <net/addrconf.h>
> +#include <net/netevent.h>
> +
> +#define BCM_CNIC 1
> +#include "cnic_drv.h"
> +#include "bnx2.h"
> +#include "cnic_if.h"
> +#include "cnic.h"
> +#include "cnic_defs.h"
> +
> +#define DRV_MODULE_NAME 	"cnic"
> +#define PFX DRV_MODULE_NAME ": "
> +
> +static char version[] __devinitdata =
> +	"Broadcom NetXtreme II CNIC Driver " DRV_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
> +
> +MODULE_AUTHOR("John(Zongxi) Chen <zongxic@broadcom.com>");
> +MODULE_DESCRIPTION("Broadcom NetXtreme II CNIC Driver");
> +MODULE_LICENSE("GPL");
> +MODULE_VERSION(CNIC_MODULE_VERSION);
> +
> +static LIST_HEAD(cnic_dev_list);
> +static DEFINE_RWLOCK(cnic_dev_lock);
> +static DEFINE_MUTEX(cnic_lock);
> +
> +struct cnic_ulp_ops *cnic_ulp_tbl[MAX_CNIC_ULP_TYPE];
> +
> +static int cnic_service_bnx2(void *, void *);
> +static int cnic_ctl(void *, struct cnic_ctl_info *);
> +
> +static struct cnic_ops cnic_bnx2_ops = {
> +	.cnic_owner	= THIS_MODULE,
> +	.cnic_handler	= cnic_service_bnx2,
> +	.cnic_ctl	= cnic_ctl,
> +};
> +
> +static inline void cnic_hold(struct cnic_dev *dev)
> +{
> +	atomic_inc(&dev->ref_count);
> +}
> +
> +static inline void cnic_put(struct cnic_dev *dev)
> +{
> +	atomic_dec(&dev->ref_count);
> +}
> +
> +static inline void csk_hold(struct cnic_sock *csk)
> +{
> +	atomic_inc(&csk->ref_count);
> +}
> +
> +static inline void csk_put(struct cnic_sock *csk)
> +{
> +	atomic_dec(&csk->ref_count);
> +}
> +
> +static void cnic_bnx2_ctx_wr(struct cnic_dev *dev, u32 cid_addr, u32 off,
> +			     u32 val)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +	struct drv_ctl_info info;
> +	struct drv_ctl_io *io = &info.data.io;
> +
> +	info.cmd = DRV_CTL_CTX_WR_CMD;
> +	io->cid_addr = cid_addr;
> +	io->offset = off;
> +	io->data = val;
> +	ethdev->drv_ctl(dev->netdev, &info);
> +}
> +
> +static void cnic_bnx2_reg_wr_ind(struct cnic_dev *dev, u32 off, u32 val)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +	struct drv_ctl_info info;
> +	struct drv_ctl_io *io = &info.data.io;
> +
> +	info.cmd = DRV_CTL_IO_WR_CMD;
> +	io->offset = off;
> +	io->data = val;
> +	ethdev->drv_ctl(dev->netdev, &info);
> +}
> +
> +static u32 cnic_bnx2_reg_rd_ind(struct cnic_dev *dev, u32 off)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +	struct drv_ctl_info info;
> +	struct drv_ctl_io *io = &info.data.io;
> +
> +	info.cmd = DRV_CTL_IO_WR_CMD;
> +	io->offset = off;
> +	ethdev->drv_ctl(dev->netdev, &info);
> +	return io->data;
> +}
> +
> +static int cnic_in_use(struct cnic_sock *csk)
> +{
> +	return (test_bit(SK_F_INUSE, &csk->flags));
> +}
> +
> +static int cnic_offld_prep(struct cnic_sock *csk)
> +{
> +	if (!test_bit(SK_F_CONNECT_START, &csk->flags))
> +		return 0;
> +
> +	if (test_and_set_bit(SK_F_OFFLD_SCHED, &csk->flags))
> +		return 0;
> +
> +	return 1;
> +}
> +
> +static int cnic_abort_prep(struct cnic_sock *csk)
> +{
> +	while (test_and_set_bit(SK_F_OFFLD_SCHED, &csk->flags))
> +		msleep(1);
> +
> +	if (test_bit(SK_F_OFFLD_COMPLETE, &csk->flags))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static void cnic_abort_done(struct cnic_sock *csk)
> +{
> +	smp_mb__before_clear_bit();
> +	clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
> +}
> +
> +int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
> +{
> +	struct cnic_dev *dev;
> +
> +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +		printk(KERN_ERR PFX "cnic_register_driver: Bad type %d\n",
> +		       ulp_type);
> +		return -EINVAL;
> +	}
> +	mutex_lock(&cnic_lock);
> +	if (cnic_ulp_tbl[ulp_type]) {
> +		printk(KERN_ERR PFX "cnic_register_driver: Type %d has already "
> +				    "been registered\n", ulp_type);
> +		mutex_unlock(&cnic_lock);
> +		return -EBUSY;
> +	}
> +
> +	read_lock(&cnic_dev_lock);
> +	list_for_each_entry(dev, &cnic_dev_list, list) {
> +		struct cnic_local *cp = dev->cnic_priv;
> +
> +		clear_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]);
> +	}
> +	read_unlock(&cnic_dev_lock);
> +
> +	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], ulp_ops);

OK, protected by cnic_lock.

> +	mutex_unlock(&cnic_lock);
> +
> +	/* Prevent race conditions with netdev_event */
> +	rtnl_lock();
> +	read_lock(&cnic_dev_lock);
> +	list_for_each_entry(dev, &cnic_dev_list, list) {
> +		struct cnic_local *cp = dev->cnic_priv;
> +
> +		if (!test_and_set_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]))
> +			ulp_ops->cnic_init(dev);
> +	}
> +	read_unlock(&cnic_dev_lock);
> +	rtnl_unlock();
> +
> +	return 0;
> +}
> +
> +int cnic_unregister_driver(int ulp_type)
> +{
> +	struct cnic_dev *dev;
> +
> +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +		printk(KERN_ERR PFX "cnic_unregister_driver: Bad type %d\n",
> +		       ulp_type);
> +		return -EINVAL;
> +	}
> +	mutex_lock(&cnic_lock);
> +	if (!cnic_ulp_tbl[ulp_type]) {
> +		printk(KERN_ERR PFX "cnic_unregister_driver: Type %d has not "
> +				    "been registered\n", ulp_type);
> +		goto out_unlock;
> +	}
> +	read_lock(&cnic_dev_lock);
> +	list_for_each_entry(dev, &cnic_dev_list, list) {
> +		struct cnic_local *cp = dev->cnic_priv;
> +		
> +		if (rcu_dereference(cp->ulp_ops[ulp_type])) {

The rcu_dereference() is redundant because we hold cnic_lock.
(Which is OK, just wanting to make sure I understand the code.)

> +			printk(KERN_ERR PFX "cnic_unregister_driver: Type %d "
> +			       "still has devices registered\n", ulp_type);
> +			read_unlock(&cnic_dev_lock);
> +			goto out_unlock;
> +		}
> +	}
> +	read_unlock(&cnic_dev_lock);
> +
> +	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], NULL);

OK, protected by cnic_lock.

> +
> +	mutex_unlock(&cnic_lock);
> +	synchronize_rcu();

The caller is responsible for freeing up cnic_ulp_tbl[ulp_type]?  If so,
the caller had better have kept a pointer to it...

But the caller would need to snapshot the pointer before the cnic_lock
was acquired, which means that some other pointer might in fact be
in place by the time this function returns.

So, is this data element statically allocated?  Or is there some other
trick being used?

Or is the whole point of this code simply to ensure that any calls to
the old cnic_ulp_tbl[ulp_type] functions have completed before this
function returns?  If so, please add a comment to this effect.

> +	return 0;
> +
> +out_unlock:
> +	mutex_unlock(&cnic_lock);
> +	return -EINVAL;
> +}
> +
> +EXPORT_SYMBOL(cnic_register_driver);
> +EXPORT_SYMBOL(cnic_unregister_driver);
> +
> +static int cnic_start_hw(struct cnic_dev *);
> +static void cnic_stop_hw(struct cnic_dev *);
> +
> +static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
> +				void *ulp_ctx)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_ulp_ops *ulp_ops;
> +
> +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +		printk(KERN_ERR PFX "cnic_register_device: Bad type %d\n",
> +		       ulp_type);
> +		return -EINVAL;
> +	}
> +	mutex_lock(&cnic_lock);
> +	if (cnic_ulp_tbl[ulp_type] == NULL) {
> +		printk(KERN_ERR PFX "cnic_register_device: Driver with type %d "
> +				    "has not been registered\n", ulp_type);
> +		mutex_unlock(&cnic_lock);
> +		return -EAGAIN;
> +	}
> +	if (rcu_dereference(cp->ulp_ops[ulp_type])) {

Again, the rcu_dereference() is redundant due to the cnic_lock being
held, and again, this is OK, just checking to make sure I understand it.

> +		printk(KERN_ERR PFX "cnic_register_device: Type %d has already "
> +		       "been registered to this device\n", ulp_type);
> +		mutex_unlock(&cnic_lock);
> +		return -EBUSY;
> +	}
> +	if (!try_module_get(cnic_ulp_tbl[ulp_type]->owner)) {
> +		mutex_unlock(&cnic_lock);
> +		return -EBUSY;
> +	}
> +
> +	clear_bit(ULP_F_START, &cp->ulp_flags[ulp_type]);
> +	cp->ulp_handle[ulp_type] = ulp_ctx;
> +	ulp_ops = cnic_ulp_tbl[ulp_type];
> +	rcu_assign_pointer(cp->ulp_ops[ulp_type], ulp_ops);

Good, protected by cnic_lock.

> +	cnic_hold(dev);
> +	if (!dev->use_count) {
> +		if (!test_bit(CNIC_F_IF_GOING_DOWN, &dev->flags)) {
> +			if (dev->netdev->flags & IFF_UP)
> +				set_bit(CNIC_F_IF_UP, &dev->flags);
> +		}
> +	}
> +	dev->use_count++;
> +
> +	if (dev->use_count == 1) {
> +		if (test_bit(CNIC_F_IF_UP, &dev->flags))
> +			cnic_start_hw(dev);
> +	}
> +
> +	if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
> +		if (!test_and_set_bit(ULP_F_START, &cp->ulp_flags[ulp_type]))
> +			ulp_ops->cnic_start(cp->ulp_handle[ulp_type]);
> +
> +	mutex_unlock(&cnic_lock);
> +
> +	return 0;
> +
> +}
> +
> +static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +		printk(KERN_ERR PFX "cnic_unregister_device: Bad type %d\n",
> +		       ulp_type);
> +		return -EINVAL;
> +	}
> +	mutex_lock(&cnic_lock);
> +	if (rcu_dereference(cp->ulp_ops[ulp_type])) {

Ditto...

> +		dev->use_count--;
> +		module_put(cp->ulp_ops[ulp_type]->owner);
> +		rcu_assign_pointer(cp->ulp_ops[ulp_type], NULL);

OK, cnic_lock held...

> +		if (dev->use_count == 0)
> +			cnic_stop_hw(dev);
> +		cnic_put(dev);
> +	} else {
> +		printk(KERN_ERR PFX "cnic_unregister_device: device not "
> +		       "registered to this ulp type %d\n", ulp_type);
> +		mutex_unlock(&cnic_lock);
> +		return -EINVAL;
> +	}
> +	mutex_unlock(&cnic_lock);
> +
> +	synchronize_rcu();

Caller is again responsible for freeing up cp->ulp_ops[ulp_type]?
If so, the caller had better have obtained a reference to it beforehand.
But it might have changed in the meantime.  So, how is this freed?

Or is this statically allocated with the only purpose of the
synchronize_rcu() being to ensure that calls though the old ops vector
have completed before this function returns?  If so, please add a
comment to this effect.

> +
> +	return 0;
> +}
> +
> +static void cnic_free_dma(struct cnic_dev *dev, struct cnic_dma *dma)
> +{
> +	int i;
> +
> +	if (!dma->pg_arr)
> +		return;
> +
> +	for (i = 0; i < dma->num_pages; i++) {
> +		if (dma->pg_arr[i]) {
> +			pci_free_consistent(dev->pcidev, BCM_PAGE_SIZE,
> +					    dma->pg_arr[i], dma->pg_map_arr[i]);
> +			dma->pg_arr[i] = NULL;
> +		}
> +	}
> +	if (dma->pgtbl) {
> +		pci_free_consistent(dev->pcidev, dma->pgtbl_size,
> +				    dma->pgtbl, dma->pgtbl_map);
> +		dma->pgtbl = NULL;
> +	}
> +	kfree(dma->pg_arr);
> +	dma->pg_arr = NULL;
> +	dma->num_pages = 0;
> +}
> +
> +static void cnic_setup_page_tbl(struct cnic_dev *dev, struct cnic_dma *dma)
> +{
> +	int i;
> +	u32 *page_table = dma->pgtbl;
> +
> +	for (i = 0; i < dma->num_pages; i++) {
> +		/* Each entry needs to be in big endian format. */
> +		*page_table = (u32) ((u64) dma->pg_map_arr[i] >> 32);
> +		page_table++;
> +		*page_table = (u32) dma->pg_map_arr[i];
> +		page_table++;
> +	}
> +}
> +
> +static int cnic_alloc_dma(struct cnic_dev *dev, struct cnic_dma *dma,
> +			  int pages, int use_pg_tbl)
> +{
> +	int i, size;
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	size = pages * (sizeof(void *) + sizeof(dma_addr_t));
> +	dma->pg_arr = kzalloc(size, GFP_ATOMIC);
> +	if (dma->pg_arr == NULL)
> +		return -ENOMEM;
> +
> +	dma->pg_map_arr = (dma_addr_t *) (dma->pg_arr + pages);
> +	dma->num_pages = pages;
> +
> +	for (i = 0; i < pages; i++) {
> +		dma->pg_arr[i] = pci_alloc_consistent(dev->pcidev,
> +						      BCM_PAGE_SIZE,
> +						      &dma->pg_map_arr[i]);
> +		if (dma->pg_arr[i] == NULL)
> +			goto error;
> +	}
> +	if (!use_pg_tbl)
> +		return 0;
> +
> +	dma->pgtbl_size = ((pages * 8) + BCM_PAGE_SIZE - 1) &
> +			  (BCM_PAGE_SIZE - 1);
> +	dma->pgtbl = pci_alloc_consistent(dev->pcidev, dma->pgtbl_size,
> +					  &dma->pgtbl_map);
> +	if (dma->pgtbl == NULL)
> +		goto error;
> +
> +	cp->setup_pgtbl(dev, dma);
> +
> +	return 0;
> +
> +error:
> +	cnic_free_dma(dev, dma);
> +	return -ENOMEM;
> +}
> +
> +static void cnic_free_resc(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int i;
> +
> +	for (i = 0; i < cp->ctx_blks; i++) {
> +		if (cp->ctx_arr[i].ctx) {
> +			pci_free_consistent(dev->pcidev, cp->ctx_blk_size,
> +					    cp->ctx_arr[i].ctx,
> +					    cp->ctx_arr[i].mapping);
> +			cp->ctx_arr[i].ctx = NULL;
> +		}
> +	}
> +	kfree(cp->ctx_arr);
> +	cp->ctx_arr = NULL;
> +	cp->ctx_blks = 0;
> +
> +	cnic_free_dma(dev, &cp->kwq_info);
> +	cnic_free_dma(dev, &cp->kcq_info);
> +	return;
> +}
> +
> +static int cnic_alloc_context(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	if (CHIP_NUM(cp) == CHIP_NUM_5709) {
> +		int i, k, arr_size;
> +
> +		cp->ctx_blk_size = BCM_PAGE_SIZE;
> +		cp->cids_per_blk = BCM_PAGE_SIZE / 128;
> +		arr_size = BNX2_MAX_CID / cp->cids_per_blk *
> +			   sizeof(struct cnic_ctx);
> +		cp->ctx_arr = kmalloc(arr_size, GFP_KERNEL);
> +		if (cp->ctx_arr == NULL)
> +			return -ENOMEM;
> +
> +		memset(cp->ctx_arr, 0, arr_size);
> +
> +		k = 0;
> +		for (i = 0; i < 2; i++) {
> +			u32 j, reg, off, lo, hi;
> +
> +			if (i == 0)
> +				off = BNX2_PG_CTX_MAP;
> +			else
> +				off = BNX2_ISCSI_CTX_MAP;
> +
> +			reg = cnic_bnx2_reg_rd_ind(dev, off);
> +			lo = reg >> 16;
> +			hi = reg & 0xffff;
> +			for (j = lo; j < hi; j += cp->cids_per_blk, k++)
> +				cp->ctx_arr[k].cid = j;
> +		}
> +
> +		cp->ctx_blks = k;
> +
> +		for (i = 0; i < cp->ctx_blks; i++) {
> +			cp->ctx_arr[i].ctx =
> +				pci_alloc_consistent(dev->pcidev, BCM_PAGE_SIZE,
> +						     &cp->ctx_arr[i].mapping);
> +			if (cp->ctx_arr[i].ctx == NULL)
> +				return -ENOMEM;
> +		}
> +	}
> +	return 0;
> +}
> +
> +static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int ret;
> +
> +	ret = cnic_alloc_dma(dev, &cp->kwq_info, KWQ_PAGE_CNT, 1);
> +	if (ret)
> +		goto error;
> +	cp->kwq = (struct kwqe **) cp->kwq_info.pg_arr;
> +
> +	ret = cnic_alloc_dma(dev, &cp->kcq_info, KCQ_PAGE_CNT, 1);
> +	if (ret)
> +		goto error;
> +	cp->kcq = (struct kcqe **) cp->kcq_info.pg_arr;
> +
> +	ret = cnic_alloc_context(dev);
> +	if (ret)
> +		goto error;
> +
> +	return 0;
> +	
> +error:
> +	cnic_free_resc(dev);
> +	return ret;
> +}
> +
> +static inline u32 cnic_kwq_avail(struct cnic_local *cp)
> +{
> +	return (cp->max_kwq_idx -
> +		((cp->kwq_prod_idx - cp->kwq_con_idx) & cp->max_kwq_idx));
> +}
> +
> +static int cnic_submit_bnx2_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
> +				  u32 num_wqes)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct kwqe *prod_qe;
> +	u16 prod, sw_prod, i;
> +
> +	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
> +		return -EAGAIN;		/* bnx2 is down */
> +
> +	spin_lock_bh(&cp->cnic_ulp_lock);
> +	if (num_wqes > cnic_kwq_avail(cp) &&
> +	    !(cp->cnic_local_flags & CNIC_LCL_FL_KWQ_INIT)) {
> +		spin_unlock_bh(&cp->cnic_ulp_lock);
> +		return -EAGAIN;
> +	}
> +
> +	cp->cnic_local_flags &= ~CNIC_LCL_FL_KWQ_INIT;
> +
> +	prod = cp->kwq_prod_idx;
> +	sw_prod = prod & MAX_KWQ_IDX;
> +	for (i = 0; i < num_wqes; i++) {
> +		prod_qe = &cp->kwq[KWQ_PG(sw_prod)][KWQ_IDX(sw_prod)];
> +		memcpy(prod_qe, wqes[i], sizeof(struct kwqe));
> +		prod++;
> +		sw_prod = prod & MAX_KWQ_IDX;
> +	}
> +	cp->kwq_prod_idx = prod;
> +
> +	CNIC_WR16(dev, cp->kwq_io_addr, cp->kwq_prod_idx);
> +
> +	spin_unlock_bh(&cp->cnic_ulp_lock);
> +	return 0;
> +}
> +
> +static void service_kcqes(struct cnic_dev *dev, int num_cqes)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int i, j;
> +
> +	i = 0;
> +	j = 1;
> +	while (num_cqes) {
> +		struct cnic_ulp_ops *ulp_ops;
> +		int ulp_type;
> +		u32 kcqe_op_flag = cp->completed_kcq[i]->kcqe_op_flag;
> +		u32 kcqe_layer = kcqe_op_flag & KCQE_FLAGS_LAYER_MASK;
> +
> +		while (j < num_cqes) {
> +			u32 next_op = cp->completed_kcq[i + j]->kcqe_op_flag;
> +
> +			if ((next_op & KCQE_FLAGS_LAYER_MASK) != kcqe_layer)
> +				break;
> +			j++;
> +		}
> +
> +		if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L5_RDMA)
> +			ulp_type = CNIC_ULP_RDMA;
> +		else if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L5_ISCSI)
> +			ulp_type = CNIC_ULP_ISCSI;
> +		else if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L4)
> +			ulp_type = CNIC_ULP_L4;
> +		else {
> +			printk(KERN_ERR PFX "%s: Unknown type of KCQE(0x%x)\n",
> +			       dev->netdev->name, kcqe_op_flag);
> +			goto end;
> +		}
> +
> +		rcu_read_lock();
> +		ulp_ops = rcu_dereference(cp->ulp_ops[ulp_type]);
> +		if (likely(ulp_ops)) {
> +			ulp_ops->indicate_kcqes(cp->ulp_handle[ulp_type],
> +						  cp->completed_kcq + i, j);
> +		}
> +		rcu_read_unlock();
> +end:
> +		num_cqes -= j;
> +		i += j;
> +		j = 1;
> +	}
> +	return;
> +}
> +
> +static int cnic_get_kcqes(struct cnic_dev *dev, u16 hw_prod, u16 sw_prod)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	u16 i, max;
> +	struct kcqe *kcqe;
> +	int kcqe_cnt = 0;
> +
> +	i = sw_prod & MAX_KCQ_IDX;
> +	max = hw_prod & MAX_KCQ_IDX;
> +	while ((i != max) && (kcqe_cnt < MAX_COMPLETED_KCQE)) {
> +		cp->completed_kcq[kcqe_cnt++] = &cp->kcq[KCQ_PG(i)][KCQ_IDX(i)];
> +		i = (i + 1) & MAX_KCQ_IDX;
> +	}
> +
> +	kcqe = cp->completed_kcq[kcqe_cnt - 1];
> +	while (kcqe->kcqe_op_flag & KCQE_FLAGS_NEXT) {
> +		kcqe_cnt--;
> +		if (kcqe_cnt == 0)
> +			goto done;
> +		kcqe = cp->completed_kcq[kcqe_cnt - 1];
> +	}
> +done:
> +	return kcqe_cnt;
> +}
> +
> +static int cnic_service_bnx2(void *data, void *status_blk)
> +{
> +	struct cnic_dev *dev = data;
> +	struct status_block *sblk = status_blk;
> +	struct cnic_local *cp = dev->cnic_priv;
> +	u32 status_idx = sblk->status_idx;
> +	u16 hw_prod, sw_prod;
> +	int kcqe_cnt;
> +
> +	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
> +		return status_idx;
> +
> +	cp->kwq_con_idx = sblk->status_rx_quick_consumer_index15;
> +
> +	hw_prod = sblk->status_completion_producer_index;
> +	sw_prod = cp->kcq_prod_idx;
> +	while (sw_prod != hw_prod) {
> +		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, sw_prod);
> +		if (kcqe_cnt == 0)
> +			goto done;
> +		sw_prod += kcqe_cnt;
> +
> +		service_kcqes(dev, kcqe_cnt);
> +
> +		/* Tell compiler that status_blk fields can change. */
> +		barrier();
> +		if (status_idx != sblk->status_idx) {
> +			status_idx = sblk->status_idx;
> +			cp->kwq_con_idx =
> +				sblk->status_rx_quick_consumer_index15;
> +			hw_prod = sblk->status_completion_producer_index;
> +		} else
> +			break;
> +	}
> +
> +done:
> +	CNIC_WR16(dev, cp->kcq_io_addr, sw_prod);
> +
> +	cp->kcq_prod_idx = sw_prod;
> +	return status_idx;
> +}
> +
> +static void cnic_service_bnx2_msix(unsigned long data)
> +{
> +	struct cnic_dev *dev = (struct cnic_dev *) data;
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct status_block_msix *status_blk = cp->bnx2_status_blk;
> +	u32 status_idx = status_blk->status_idx;
> +	u16 hw_prod, sw_prod;
> +	int kcqe_cnt;
> +
> +	cp->kwq_con_idx = status_blk->status_cmd_consumer_index;
> +
> +	hw_prod = status_blk->status_completion_producer_index;
> +	sw_prod = cp->kcq_prod_idx;
> +	while (sw_prod != hw_prod) {
> +		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, sw_prod);
> +		if (kcqe_cnt == 0)
> +			goto done;
> +		sw_prod += kcqe_cnt;
> +
> +		service_kcqes(dev, kcqe_cnt);
> +
> +		/* Tell compiler that status_blk fields can change. */
> +		barrier();
> +		if (status_idx != status_blk->status_idx) {
> +			status_idx = status_blk->status_idx;
> +			cp->kwq_con_idx = status_blk->status_cmd_consumer_index;
> +			hw_prod = status_blk->status_completion_producer_index;
> +		} else
> +			break;
> +	}
> +
> +done:
> +	CNIC_WR16(dev, cp->kcq_io_addr, sw_prod);
> +
> +	cp->kcq_prod_idx = sw_prod;
> +	cp->last_status_idx = status_idx;
> +	CNIC_WR(dev, BNX2_PCICFG_INT_ACK_CMD, BNX2_CNIC_INT_NUM |
> +		BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | cp->last_status_idx);
> +}
> +
> +static irqreturn_t cnic_irq(int irq, void *dev_instance)
> +{
> +	struct cnic_dev *dev = dev_instance;
> +	struct cnic_local *cp = dev->cnic_priv;
> +	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
> +
> +	if (cp->ack_int)
> +		cp->ack_int(dev);
> +
> +	prefetch(cp->status_blk);
> +	prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
> +
> +	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags)))
> +		tasklet_schedule(&cp->cnic_irq_task);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void cnic_ulp_stop(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int if_type;
> +
> +	rcu_read_lock();
> +	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
> +		struct cnic_ulp_ops *ulp_ops;
> +
> +		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
> +		if (!ulp_ops)
> +			continue;
> +
> +		if (test_and_clear_bit(ULP_F_START, &cp->ulp_flags[if_type]))
> +			ulp_ops->cnic_stop(cp->ulp_handle[if_type]);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static void cnic_ulp_start(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int if_type;
> +
> +	rcu_read_lock();
> +	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
> +		struct cnic_ulp_ops *ulp_ops;
> +
> +		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
> +		if (!ulp_ops)
> +			continue;
> +
> +		if (!test_and_set_bit(ULP_F_START, &cp->ulp_flags[if_type]))
> +			ulp_ops->cnic_start(cp->ulp_handle[if_type]);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static int cnic_ctl(void *data, struct cnic_ctl_info *info)
> +{
> +	struct cnic_dev *dev = data;
> +
> +	switch (info->cmd) {
> +	case CNIC_CTL_STOP_CMD:
> +		cnic_hold(dev);
> +		mutex_lock(&cnic_lock);
> +
> +		clear_bit(CNIC_F_IF_UP, &dev->flags);
> +		cnic_ulp_stop(dev);
> +		cnic_stop_hw(dev);
> +
> +		mutex_unlock(&cnic_lock);
> +		cnic_put(dev);
> +		break;
> +	case CNIC_CTL_START_CMD:
> +		cnic_hold(dev);
> +		mutex_lock(&cnic_lock);
> +
> +		set_bit(CNIC_F_IF_UP, &dev->flags);
> +		if (dev->use_count) {
> +			if (!cnic_start_hw(dev))
> +				cnic_ulp_start(dev);
> +		}
> +		mutex_unlock(&cnic_lock);
> +		cnic_put(dev);
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
> +
> +static void cnic_ulp_init(struct cnic_dev *dev)
> +{
> +	int i;
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	rcu_read_lock();
> +	for (i = 0; i < MAX_CNIC_ULP_TYPE_EXT; i++) {
> +		struct cnic_ulp_ops *ulp_ops;
> +
> +		ulp_ops = rcu_dereference(cnic_ulp_tbl[i]);
> +		if (!ulp_ops || !try_module_get(ulp_ops->owner))
> +			continue;
> +
> +		if (!test_and_set_bit(ULP_F_INIT, &cp->ulp_flags[i]))
> +			ulp_ops->cnic_init(dev);
> +
> +		module_put(ulp_ops->owner);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static void cnic_ulp_exit(struct cnic_dev *dev)
> +{
> +	int i;
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	rcu_read_lock();
> +	for (i = 0; i < MAX_CNIC_ULP_TYPE_EXT; i++) {
> +		struct cnic_ulp_ops *ulp_ops;
> +
> +		ulp_ops = rcu_dereference(cnic_ulp_tbl[i]);
> +		if (!ulp_ops || !try_module_get(ulp_ops->owner))
> +			continue;
> +
> +		if (test_and_clear_bit(ULP_F_INIT, &cp->ulp_flags[i]))
> +			ulp_ops->cnic_exit(dev);
> +
> +		module_put(ulp_ops->owner);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static int cnic_queue_work(struct cnic_local *cp, u32 work_type, void *data)
> +{
> +	struct cnic_work_node *node;
> +	int bytes = sizeof(u32 *);
> +
> +	spin_lock_bh(&cp->wr_lock);
> +
> +	node = &cp->cnic_work_ring[cp->cnic_wr_prod];
> +	node->work_type = work_type;
> +	if (work_type == WORK_TYPE_KCQE)
> +		bytes = sizeof(struct kcqe);
> +	if (work_type == WORK_TYPE_REDIRECT)
> +		bytes = sizeof(struct cnic_redirect_entry);
> +	memcpy(&node->work_data, data, bytes);
> +	cp->cnic_wr_prod++;
> +	cp->cnic_wr_prod &= WORK_RING_SIZE_MASK;
> +
> +	spin_unlock_bh(&cp->wr_lock);
> +	return 0;
> +}
> +
> +static int cnic_cm_offload_pg(struct cnic_sock *csk)
> +{
> +	struct cnic_dev *dev = csk->dev;
> +	struct l4_kwq_offload_pg *l4kwqe;
> +	struct kwqe *wqes[1];
> +	struct neighbour *neigh = csk->dst->neighbour;
> +	struct net_device *netdev = neigh->dev;
> +
> +	l4kwqe = (struct l4_kwq_offload_pg *) &csk->kwqe1;
> +	memset(l4kwqe, 0, sizeof(*l4kwqe));
> +	wqes[0] = (struct kwqe *) l4kwqe;
> +
> +	l4kwqe->op_code = L4_KWQE_OPCODE_VALUE_OFFLOAD_PG;
> +	l4kwqe->flags =
> +		L4_LAYER_CODE << L4_KWQ_OFFLOAD_PG_LAYER_CODE_SHIFT;
> +	l4kwqe->l2hdr_nbytes = ETH_HLEN;
> +	l4kwqe->da0 = neigh->ha[0];
> +	l4kwqe->da1 = neigh->ha[1];
> +	l4kwqe->da2 = neigh->ha[2];
> +	l4kwqe->da3 = neigh->ha[3];
> +	l4kwqe->da4 = neigh->ha[4];
> +	l4kwqe->da5 = neigh->ha[5];
> +
> +	l4kwqe->sa0 = netdev->dev_addr[0];
> +	l4kwqe->sa1 = netdev->dev_addr[1];
> +	l4kwqe->sa2 = netdev->dev_addr[2];
> +	l4kwqe->sa3 = netdev->dev_addr[3];
> +	l4kwqe->sa4 = netdev->dev_addr[4];
> +	l4kwqe->sa5 = netdev->dev_addr[5];
> +
> +	l4kwqe->etype = ETH_P_IP;
> +	l4kwqe->ipid_count = DEF_IPID_COUNT;
> +	l4kwqe->host_opaque = csk->l5_cid;
> +
> +	if (csk->vlan_id) {
> +		l4kwqe->pg_flags |= L4_KWQ_OFFLOAD_PG_VLAN_TAGGING;
> +		l4kwqe->vlan_tag = csk->vlan_id;
> +		l4kwqe->l2hdr_nbytes += 4;
> +	}
> +
> +	return (dev->submit_kwqes(dev, wqes, 1));
> +}
> +
> +static int cnic_cm_update_pg(struct cnic_sock *csk)
> +{
> +	struct cnic_dev *dev = csk->dev;
> +	struct l4_kwq_update_pg *l4kwqe;
> +	struct kwqe *wqes[1];
> +	struct neighbour *neigh = csk->dst->neighbour;
> +
> +	l4kwqe = (struct l4_kwq_update_pg *) &csk->kwqe1;
> +	memset(l4kwqe, 0, sizeof(*l4kwqe));
> +	wqes[0] = (struct kwqe *) l4kwqe;
> +
> +	l4kwqe->opcode = L4_KWQE_OPCODE_VALUE_UPDATE_PG;
> +	l4kwqe->flags =
> +		L4_LAYER_CODE << L4_KWQ_UPDATE_PG_LAYER_CODE_SHIFT;
> +	l4kwqe->pg_cid = csk->pg_cid;
> +	l4kwqe->da0 = neigh->ha[0];
> +	l4kwqe->da1 = neigh->ha[1];
> +	l4kwqe->da2 = neigh->ha[2];
> +	l4kwqe->da3 = neigh->ha[3];
> +	l4kwqe->da4 = neigh->ha[4];
> +	l4kwqe->da5 = neigh->ha[5];
> +
> +	l4kwqe->pg_host_opaque = 0;
> +	l4kwqe->pg_valids = L4_KWQ_UPDATE_PG_VALIDS_DA;
> +
> +	return (dev->submit_kwqes(dev, wqes, 1));
> +}
> +
> +static int cnic_cm_upload_pg(struct cnic_sock *csk)
> +{
> +	struct cnic_dev *dev = csk->dev;
> +	struct l4_kwq_upload *l4kwqe;
> +	struct kwqe *wqes[1];
> +
> +	l4kwqe = (struct l4_kwq_upload *) &csk->kwqe1;
> +	memset(l4kwqe, 0, sizeof(*l4kwqe));
> +	wqes[0] = (struct kwqe *) l4kwqe;
> +
> +	l4kwqe->opcode = L4_KWQE_OPCODE_VALUE_UPLOAD_PG;
> +	l4kwqe->flags =
> +		L4_LAYER_CODE << L4_KWQ_UPLOAD_LAYER_CODE_SHIFT;
> +	l4kwqe->cid = csk->pg_cid;
> +
> +	return (dev->submit_kwqes(dev, wqes, 1));
> +}
> +
> +static void cnic_redirect(struct cnic_local *cp, struct dst_entry *new,
> +			  struct dst_entry *old)
> +{
> +	int i, found = 0;
> +
> +	for (i = 0; i < MAX_CM_SK_TBL_SZ && !found; i++) {
> +		struct cnic_sock *csk;
> +		struct cnic_redirect_entry cnic_redir;
> +
> +		csk = &cp->csk_tbl[i];
> +		csk_hold(csk);
> +		if (cnic_in_use(csk) && csk->dst == old) {
> +			found = 1;
> +			dst_hold(new);
> +			dst_hold(old);
> +
> +			cnic_redir.old_dst = old;
> +			cnic_redir.new_dst = new;
> +			cnic_queue_work(cp, WORK_TYPE_REDIRECT, &cnic_redir);
> +			tasklet_schedule(&cp->cnic_task);
> +		}
> +		csk_put(csk);
> +	}
> +}
> +
> +static void cnic_update_neigh(struct cnic_local *cp, struct neighbour *neigh)
> +{
> +	int i, found = 0;
> +
> +	for (i = 0; i < MAX_CM_SK_TBL_SZ && !found; i++) {
> +		struct cnic_sock *csk;
> +
> +		csk = &cp->csk_tbl[i];
> +		csk_hold(csk);
> +		if (cnic_in_use(csk) && csk->dst) {
> +			if (csk->dst->neighbour == neigh) {
> +				found = 1;
> +				neigh_hold(neigh);
> +
> +				cnic_queue_work(cp, WORK_TYPE_NEIGH_UPDATE,
> +						&neigh);
> +				tasklet_schedule(&cp->cnic_task);
> +			}
> +		}
> +		csk_put(csk);
> +	}
> +}
> +
> +static int cnic_net_callback(struct notifier_block *this, unsigned long event,
> +	void *ptr)
> +{
> +	struct cnic_local *cp = container_of(this, struct cnic_local, cm_nb);
> +
> +	if (event == NETEVENT_NEIGH_UPDATE) {
> +		struct neighbour *neigh = ptr;
> +
> +		cnic_update_neigh(cp, neigh);
> +
> +	} else if (event == NETEVENT_REDIRECT) {
> +		struct netevent_redirect *netevent = ptr;
> +		struct dst_entry *old_dst = netevent->old;
> +		struct dst_entry *new_dst = netevent->new;
> +
> +		cnic_redirect(cp, new_dst, old_dst);
> +	}
> +	return 0;
> +}
> +
> +static int cnic_cm_conn_req(struct cnic_sock *csk)
> +{
> +	struct cnic_dev *dev = csk->dev;
> +	struct l4_kwq_connect_req1 *l4kwqe1;
> +	struct l4_kwq_connect_req2 *l4kwqe2;
> +	struct l4_kwq_connect_req3 *l4kwqe3;
> +	struct kwqe *wqes[3];
> +	u8 tcp_flags = 0;
> +	int num_wqes = 2;
> +
> +	l4kwqe1 = (struct l4_kwq_connect_req1 *) &csk->kwqe1;
> +	l4kwqe2 = (struct l4_kwq_connect_req2 *) &csk->kwqe2;
> +	l4kwqe3 = (struct l4_kwq_connect_req3 *) &csk->kwqe3;
> +	memset(l4kwqe1, 0, sizeof(*l4kwqe1));
> +	memset(l4kwqe2, 0, sizeof(*l4kwqe2));
> +	memset(l4kwqe3, 0, sizeof(*l4kwqe3));
> +
> +	l4kwqe3->op_code = L4_KWQE_OPCODE_VALUE_CONNECT3;
> +	l4kwqe3->flags =
> +		L4_LAYER_CODE << L4_KWQ_CONNECT_REQ3_LAYER_CODE_SHIFT;
> +	l4kwqe3->ka_timeout = csk->ka_timeout;
> +	l4kwqe3->ka_interval = csk->ka_interval;
> +	l4kwqe3->ka_max_probe_count = csk->ka_max_probe_count;
> +	l4kwqe3->tos = csk->tos;
> +	l4kwqe3->ttl = csk->ttl;
> +	l4kwqe3->snd_seq_scale = csk->snd_seq_scale;
> +	l4kwqe3->pmtu = dst_mtu(csk->dst);
> +	l4kwqe3->rcv_buf = csk->rcv_buf;
> +	l4kwqe3->snd_buf = csk->snd_buf;
> +	l4kwqe3->seed = csk->seed;
> +
> +	wqes[0] = (struct kwqe *) l4kwqe1;
> +	if (test_bit(SK_F_IPV6, &csk->flags)) {
> +		wqes[1] = (struct kwqe *) l4kwqe2;
> +		wqes[2] = (struct kwqe *) l4kwqe3;
> +		num_wqes = 3;
> +
> +		l4kwqe1->conn_flags = L4_KWQ_CONNECT_REQ1_IP_V6;
> +		l4kwqe2->op_code = L4_KWQE_OPCODE_VALUE_CONNECT2;
> +		l4kwqe2->flags =
> +			L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT |
> +			L4_LAYER_CODE << L4_KWQ_CONNECT_REQ2_LAYER_CODE_SHIFT;
> +		l4kwqe2->src_ip_v6_2 = be32_to_cpu(csk->src_ip[1]);
> +		l4kwqe2->src_ip_v6_3 = be32_to_cpu(csk->src_ip[2]);
> +		l4kwqe2->src_ip_v6_4 = be32_to_cpu(csk->src_ip[3]);
> +		l4kwqe2->dst_ip_v6_2 = be32_to_cpu(csk->dst_ip[1]);
> +		l4kwqe2->dst_ip_v6_3 = be32_to_cpu(csk->dst_ip[2]);
> +		l4kwqe2->dst_ip_v6_4 = be32_to_cpu(csk->dst_ip[3]);
> +		l4kwqe3->mss = l4kwqe3->pmtu - sizeof(struct ipv6hdr) -
> +			       sizeof(struct tcphdr);
> +	} else {
> +		wqes[1] = (struct kwqe *) l4kwqe3;
> +		l4kwqe3->mss = l4kwqe3->pmtu - sizeof(struct iphdr) -
> +			       sizeof(struct tcphdr);
> +	}
> +
> +	l4kwqe1->op_code = L4_KWQE_OPCODE_VALUE_CONNECT1;
> +	l4kwqe1->flags =
> +		(L4_LAYER_CODE << L4_KWQ_CONNECT_REQ1_LAYER_CODE_SHIFT) |
> +		 L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT;
> +	l4kwqe1->cid = csk->cid;
> +	l4kwqe1->pg_cid = csk->pg_cid;
> +	l4kwqe1->src_ip = be32_to_cpu(csk->src_ip[0]);
> +	l4kwqe1->dst_ip = be32_to_cpu(csk->dst_ip[0]);
> +	l4kwqe1->src_port = be16_to_cpu(csk->src_port);
> +	l4kwqe1->dst_port = be16_to_cpu(csk->dst_port);
> +	if (csk->tcp_flags & SK_TCP_NO_DELAY_ACK)
> +		tcp_flags |= L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK;
> +	if (csk->tcp_flags & SK_TCP_KEEP_ALIVE)
> +		tcp_flags |= L4_KWQ_CONNECT_REQ1_KEEP_ALIVE;
> +	if (csk->tcp_flags & SK_TCP_NAGLE)
> +		tcp_flags |= L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE;
> +	if (csk->tcp_flags & SK_TCP_TIMESTAMP)
> +		tcp_flags |= L4_KWQ_CONNECT_REQ1_TIME_STAMP;
> +	if (csk->tcp_flags & SK_TCP_SACK)
> +		tcp_flags |= L4_KWQ_CONNECT_REQ1_SACK;
> +	if (csk->tcp_flags & SK_TCP_SEG_SCALING)
> +		tcp_flags |= L4_KWQ_CONNECT_REQ1_SEG_SCALING;
> +	
> +	l4kwqe1->tcp_flags = tcp_flags;
> +
> +	return (dev->submit_kwqes(dev, wqes, num_wqes));
> +}
> +
> +static int cnic_cm_close_req(struct cnic_sock *csk)
> +{
> +	struct cnic_dev *dev = csk->dev;
> +	struct l4_kwq_close_req *l4kwqe;
> +	struct kwqe *wqes[1];
> +
> +	l4kwqe = (struct l4_kwq_close_req *) &csk->kwqe2;
> +	memset(l4kwqe, 0, sizeof(*l4kwqe));
> +	wqes[0] = (struct kwqe *) l4kwqe;
> +
> +	l4kwqe->op_code = L4_KWQE_OPCODE_VALUE_CLOSE;
> +	l4kwqe->flags = L4_LAYER_CODE << L4_KWQ_CLOSE_REQ_LAYER_CODE_SHIFT;
> +	l4kwqe->cid = csk->cid;
> +
> +	return (dev->submit_kwqes(dev, wqes, 1));
> +}
> +
> +static int cnic_cm_abort_req(struct cnic_sock *csk)
> +{
> +	struct cnic_dev *dev = csk->dev;
> +	struct l4_kwq_reset_req *l4kwqe;
> +	struct kwqe *wqes[1];
> +
> +	l4kwqe = (struct l4_kwq_reset_req *) &csk->kwqe2;
> +	memset(l4kwqe, 0, sizeof(*l4kwqe));
> +	wqes[0] = (struct kwqe *) l4kwqe;
> +
> +	l4kwqe->op_code = L4_KWQE_OPCODE_VALUE_RESET;
> +	l4kwqe->flags = L4_LAYER_CODE << L4_KWQ_RESET_REQ_LAYER_CODE_SHIFT;
> +	l4kwqe->cid = csk->cid;
> +
> +	return (dev->submit_kwqes(dev, wqes, 1));
> +}
> +
> +static int cnic_cm_create(struct cnic_dev *dev, int ulp_type, u32 cid,
> +			  u32 l5_cid, struct cnic_sock **csk, void *context)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_sock *csk1;
> +
> +	if (l5_cid >= MAX_CM_SK_TBL_SZ)
> +		return -EINVAL;
> +		
> +	csk1 = &cp->csk_tbl[l5_cid];
> +	if (test_and_set_bit(SK_F_INUSE, &csk1->flags))
> +		return -EINVAL;
> +
> +	csk1->dev = dev;
> +	csk1->cid = cid;
> +	csk1->l5_cid = l5_cid;
> +	csk1->ulp_type = ulp_type;
> +	csk1->context = context;
> +
> +	csk1->ka_timeout = DEF_KA_TIMEOUT;
> +	csk1->ka_interval = DEF_KA_INTERVAL;
> +	csk1->ka_max_probe_count = DEF_KA_MAX_PROBE_COUNT;
> +	csk1->tos = DEF_TOS;
> +	csk1->ttl = DEF_TTL;
> +	csk1->snd_seq_scale = DEF_SND_SEQ_SCALE;
> +	csk1->rcv_buf = DEF_RCV_BUF;
> +	csk1->snd_buf = DEF_SND_BUF;
> +	csk1->seed = DEF_SEED;
> +
> +	*csk = csk1;
> +
> +	return 0;
> +}
> +
> +static void cnic_close_conn(struct cnic_sock *csk)
> +{
> +	clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags);
> +	cnic_cm_upload_pg(csk);
> +	clear_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags);
> +	clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
> +}
> +
> +static void cnic_cm_cleanup(struct cnic_sock *csk)
> +{
> +	if (csk->dst) {
> +		if (csk->dst->neighbour)
> +			neigh_release(csk->dst->neighbour);
> +		dst_release(csk->dst);
> +		csk->dst = NULL;
> +	}
> +}
> +
> +static int cnic_cm_destroy(struct cnic_sock *csk)
> +{
> +	if (!cnic_in_use(csk))
> +		return -EINVAL;
> +
> +	clear_bit(SK_F_INUSE, &csk->flags);
> +	smp_mb__after_clear_bit();
> +	while (atomic_read(&csk->ref_count) != 0)
> +		msleep(1);
> +	cnic_cm_cleanup(csk);
> +
> +	csk->flags = 0;
> +	return 0;
> +}
> +
> +static inline u16 cnic_get_vlan(struct net_device *dev,
> +				struct net_device **vlan_dev)
> +{
> +	if (dev->priv_flags & IFF_802_1Q_VLAN) {
> +		*vlan_dev = vlan_dev_info(dev)->real_dev;
> +		return vlan_dev_info(dev)->vlan_id;
> +	}
> +	*vlan_dev = dev;
> +	return 0;
> +}
> +
> +static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
> +			     struct sockaddr_in *src_addr,
> +			     struct dst_entry **dst)
> +{
> +	struct flowi fl;
> +	int err;
> +	struct rtable *rt;
> +
> +	memset(&fl, 0, sizeof(fl));
> +	fl.nl_u.ip4_u.daddr = dst_addr->sin_addr.s_addr;
> +	if (src_addr)
> +		fl.nl_u.ip4_u.saddr = src_addr->sin_addr.s_addr;
> +
> +	err = ip_route_output_key(&init_net, &rt, &fl);
> +	if (!err)
> +		*dst = &rt->u.dst;
> +	return err;
> +}
> +
> +static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
> +			     struct sockaddr_in6 *src_addr,
> +			     struct dst_entry **dst)
> +{
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	struct flowi fl;
> +
> +	memset(&fl, 0, sizeof(fl));
> +	ipv6_addr_copy(&fl.fl6_dst, &dst_addr->sin6_addr);
> +	if (ipv6_addr_type(&fl.fl6_dst) & IPV6_ADDR_LINKLOCAL)
> +		fl.oif = dst_addr->sin6_scope_id;
> +
> +	if (src_addr)
> +		ipv6_addr_copy(&fl.fl6_src, &src_addr->sin6_addr);
> +
> +	*dst = ip6_route_output(NULL, &fl);
> +	if (*dst)
> +		return 0;
> +#endif
> +
> +	return -ENETUNREACH;
> +}
> +
> +static struct cnic_dev *cnic_cm_select_dev(struct sockaddr_in *dst_addr,
> +					   int ulp_type)
> +{
> +	struct cnic_dev *dev = NULL;
> +	struct dst_entry *dst;
> +	struct net_device *netdev = NULL;
> +	int err = -ENETUNREACH, found = 0;
> +
> +	if (dst_addr->sin_family == AF_INET)
> +		err = cnic_get_v4_route(dst_addr, NULL, &dst);
> +	else if (dst_addr->sin_family == AF_INET6) {
> +		struct sockaddr_in6 *dst_addr6 =
> +			(struct sockaddr_in6 *) dst_addr;
> +
> +		err = cnic_get_v6_route(dst_addr6, NULL, &dst);
> +	} else
> +		return NULL;
> +
> +	if (err)
> +		return NULL;
> +
> +	if (!dst->dev)
> +		goto done;
> +
> +	cnic_get_vlan(dst->dev, &netdev);
> +
> +	read_lock(&cnic_dev_lock);
> +	list_for_each_entry(dev, &cnic_dev_list, list) {
> +		if (netdev == dev->netdev) {
> +			found = 1;
> +			break;
> +		}
> +	}
> +	read_unlock(&cnic_dev_lock);
> +
> +done:
> +	dst_release(dst);
> +	if (!found)
> +		dev = NULL;
> +	return dev;
> +}
> +
> +static int cnic_resolve_addr(struct cnic_sock *csk)
> +{
> +	struct neighbour *neigh = csk->dst->neighbour;
> +	int err = 0;
> +
> +	if (neigh->nud_state & NUD_VALID) {
> +		err = -EINVAL;
> +		if (cnic_offld_prep(csk))
> +			err = cnic_cm_offload_pg(csk);
> +		goto done;
> +	}
> +
> +	set_bit(SK_F_NDISC_WAITING, &csk->flags);
> +	neigh_event_send(neigh, NULL);
> +done:
> +	return err;
> +}
> +
> +static int cnic_get_route(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
> +{
> +	struct cnic_dev *dev = csk->dev;
> +	int is_v6, err;
> +	struct dst_entry *dst;
> +	struct net_device *realdev;
> +
> +	if (saddr->local.v6.sin6_family == AF_INET6 &&
> +	    saddr->remote.v6.sin6_family == AF_INET6)
> +		is_v6 = 1;
> +	else if (saddr->local.v4.sin_family == AF_INET &&
> +		 saddr->remote.v4.sin_family == AF_INET)
> +		is_v6 = 0;
> +	else
> +		return -EINVAL;
> +
> +	clear_bit(SK_F_IPV6, &csk->flags);
> +
> +	if (is_v6) {
> +		set_bit(SK_F_IPV6, &csk->flags);
> +		err = cnic_get_v6_route(&saddr->remote.v6,
> +					&saddr->local.v6, &dst);
> +		if (err)
> +			return err;
> +
> +		if (!dst || dst->error || !dst->dev)
> +			goto err_out;
> +
> +		ipv6_get_saddr(dst, &saddr->remote.v6.sin6_addr,
> +			       &saddr->local.v6.sin6_addr);
> +
> +		memcpy(&csk->src_ip[0], &saddr->local.v6.sin6_addr,
> +		       sizeof(struct in6_addr));
> +		memcpy(&csk->dst_ip[0], &saddr->remote.v6.sin6_addr,
> +		       sizeof(struct in6_addr));
> +		csk->src_port = saddr->local.v6.sin6_port;
> +		csk->dst_port = saddr->remote.v6.sin6_port;
> +
> +	} else {
> +		err = cnic_get_v4_route(&saddr->remote.v4, &saddr->local.v4,
> +					&dst);
> +		if (err)
> +			return err;
> +
> +		if (!dst || dst->error || !dst->dev)
> +			goto err_out;
> +
> +		csk->dst_ip[0] = saddr->remote.v4.sin_addr.s_addr;
> +		csk->src_ip[0] = saddr->local.v4.sin_addr.s_addr;
> +		csk->src_port = saddr->local.v4.sin_port;
> +		csk->dst_port = saddr->remote.v4.sin_port;
> +
> +		if (csk->src_ip[0] == 0) {
> +			csk->src_ip[0] =
> +				inet_select_addr(dst->dev, csk->dst_ip[0],
> +						 RT_SCOPE_LINK);
> +		}
> +	}
> +
> +	csk->vlan_id = cnic_get_vlan(dst->dev, &realdev);
> +	if (realdev != dev->netdev)
> +		goto err_out;
> +
> +	csk->dst = dst;
> +	return 0;
> +
> +err_out:
> +	dst_release(dst);
> +	return -ENETUNREACH;
> +}
> +
> +static int cnic_cm_connect(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
> +{
> +	struct neighbour *neigh;
> +	int err = 0;
> +
> +	if (!cnic_in_use(csk))
> +		return -EINVAL;
> +
> +	if (test_and_set_bit(SK_F_CONNECT_START, &csk->flags))
> +		return -EINVAL;
> +
> +	clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
> +
> +	err = cnic_get_route(csk, saddr);
> +	if (err)
> +		goto err_out;
> +
> +	neigh = csk->dst->neighbour;
> +	if (!neigh)
> +		goto err_out;
> +
> +	neigh_hold(neigh);
> +
> +	err = cnic_resolve_addr(csk);
> +	if (!err)
> +		return 0;
> +
> +	neigh_release(neigh);
> +
> +err_out:
> +	if (csk->dst) {
> +		dst_release(csk->dst);
> +		csk->dst = NULL;
> +	}
> +	clear_bit(SK_F_CONNECT_START, &csk->flags);
> +	return err;
> +}
> +
> +static int cnic_cm_abort(struct cnic_sock *csk)
> +{
> +	if (!cnic_in_use(csk))
> +		return -EINVAL;
> +
> +	clear_bit(SK_F_NDISC_WAITING, &csk->flags);
> +	clear_bit(SK_F_CONNECT_START, &csk->flags);
> +	smp_mb__after_clear_bit();
> +	if (cnic_abort_prep(csk))
> +		return (cnic_cm_abort_req(csk));
> +
> +	/* Getting here means that we haven't started connect, or
> +	 * connect was not successful.
> +	 */
> +
> +	if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
> +		cnic_close_conn(csk);
> +
> +	cnic_cm_cleanup(csk);
> +	cnic_abort_done(csk);
> +
> +	return 0;
> +}
> +
> +static int cnic_cm_close(struct cnic_sock *csk)
> +{
> +	if (!cnic_in_use(csk))
> +		return -EINVAL;
> +
> +	if (test_bit(SK_F_OFFLD_COMPLETE, &csk->flags))
> +		return (cnic_cm_close_req(csk));
> +
> +	return -EINVAL;
> +}
> +
> +static void cnic_cm_upcall(struct cnic_local *cp, struct cnic_sock *csk,
> +			   u8 opcode)
> +{
> +	struct cnic_ulp_ops *ulp_ops;
> +	int ulp_type = csk->ulp_type;
> +
> +	rcu_read_lock();
> +	ulp_ops = rcu_dereference(cp->ulp_ops[ulp_type]);
> +	if (ulp_ops) {
> +		if (opcode == L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE)
> +			ulp_ops->cm_connect_complete(csk);
> +		else if (opcode == L4_KCQE_OPCODE_VALUE_CLOSE_COMP)
> +			ulp_ops->cm_close_complete(csk);
> +		else if (opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED)
> +			ulp_ops->cm_remote_abort(csk);
> +		else if (opcode == L4_KCQE_OPCODE_VALUE_RESET_COMP)
> +			ulp_ops->cm_abort_complete(csk);
> +		else if (opcode == L4_KCQE_OPCODE_VALUE_CLOSE_RECEIVED)
> +			ulp_ops->cm_remote_close(csk);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static int cnic_cm_set_pg(struct cnic_sock *csk)
> +{
> +	struct neighbour *neigh = csk->dst->neighbour;
> +	int valid = neigh->nud_state & NUD_VALID;
> +
> +	if (!valid) {
> +		if (test_and_clear_bit(SK_F_NDISC_WAITING, &csk->flags)) {
> +			clear_bit(SK_F_CONNECT_START, &csk->flags);
> +			cnic_cm_cleanup(csk);
> +			return -ETIMEDOUT;
> +		}
> +	}
> +
> +	if (cnic_offld_prep(csk)) {
> +		if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
> +			cnic_cm_update_pg(csk);
> +		else
> +			cnic_cm_offload_pg(csk);
> +	}
> +	clear_bit(SK_F_NDISC_WAITING, &csk->flags);
> +	return 0;
> +}
> +
> +static void cnic_cm_process_neigh(struct cnic_dev *dev, struct neighbour *neigh)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int i;
> +
> +	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
> +		struct cnic_sock *csk;
> +		int abort = 0;
> +
> +		csk = &cp->csk_tbl[i];
> +		csk_hold(csk);
> +		if (cnic_in_use(csk) && csk->dst &&
> +		    csk->dst->neighbour == neigh) {
> +			if (cnic_cm_set_pg(csk))
> +				abort = 1;
> +		}
> +		if (abort)
> +			cnic_cm_upcall(cp, csk,
> +				L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE);
> +		csk_put(csk);
> +	}
> +	neigh_release(neigh);
> +}
> +
> +static void cnic_cm_process_redirect(struct cnic_dev *dev,
> +				     struct cnic_redirect_entry *redir)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int i;
> +
> +	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
> +		struct cnic_sock *csk;
> +		int abort = 0;
> +
> +		csk = &cp->csk_tbl[i];
> +		csk_hold(csk);
> +		if (cnic_in_use(csk) &&
> +		    csk->dst == redir->old_dst) {
> +			csk->dst = redir->new_dst;
> +			dst_hold(csk->dst);
> +			neigh_hold(csk->dst->neighbour);
> +			if (redir->old_dst->neighbour);
> +				neigh_release(redir->old_dst->neighbour);
> +			dst_release(redir->old_dst);
> +			if (cnic_cm_set_pg(csk))
> +				abort = 1;
> +		}
> +		if (abort)
> +			cnic_cm_upcall(cp, csk,
> +				L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE);
> +		csk_put(csk);
> +	}
> +
> +	dst_release(redir->new_dst);
> +	dst_release(redir->old_dst);
> +}
> +
> +static void cnic_cm_process_offld_pg(struct cnic_dev *dev, struct l4_kcq *kcqe)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	u32 l5_cid = kcqe->pg_host_opaque;
> +	u8 opcode = kcqe->op_code;
> +	struct cnic_sock *csk = &cp->csk_tbl[l5_cid];
> +
> +	if (!cnic_in_use(csk))
> +		return;
> +
> +	csk->pg_cid = kcqe->pg_cid;
> +	if (opcode == L4_KCQE_OPCODE_VALUE_UPDATE_PG) {
> +		clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
> +		return;
> +	}
> +	set_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags);
> +	cnic_cm_conn_req(csk);
> +}
> +
> +static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct l4_kcq *l4kcqe = (struct l4_kcq *) kcqe;
> +	u8 opcode = l4kcqe->op_code;
> +	u32 l5_cid;
> +	struct cnic_sock *csk;
> +
> +	if (opcode == L4_KCQE_OPCODE_VALUE_OFFLOAD_PG ||
> +	    opcode == L4_KCQE_OPCODE_VALUE_UPDATE_PG) {
> +		cnic_cm_process_offld_pg(dev, l4kcqe);
> +		return;
> +	}
> +
> +	l5_cid = l4kcqe->conn_id;
> +	if (l5_cid >= MAX_CM_SK_TBL_SZ)
> +		return;
> +
> +	csk = &cp->csk_tbl[l5_cid];
> +
> +	if (!cnic_in_use(csk))
> +		return;
> +
> +	if (opcode == L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE) {
> +
> +		if (l4kcqe->status == 0)
> +			set_bit(SK_F_OFFLD_COMPLETE, &csk->flags);
> +
> +		smp_mb__before_clear_bit();
> +		clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
> +		cnic_cm_upcall(cp, csk, opcode);
> +
> +	} else if (opcode == L4_KCQE_OPCODE_VALUE_CLOSE_COMP ||
> +		   opcode == L4_KCQE_OPCODE_VALUE_RESET_COMP ||
> +		   opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED) {
> +
> +		clear_bit(SK_F_CONNECT_START, &csk->flags);
> +		cnic_close_conn(csk);
> +		cnic_cm_cleanup(csk);
> +		cnic_abort_done(csk);
> +		cnic_cm_upcall(cp, csk, opcode);
> +
> +	} else if (opcode == L4_KCQE_OPCODE_VALUE_CLOSE_RECEIVED) {
> +		cnic_cm_upcall(cp, csk, opcode);
> +	}
> +}
> +
> +static void cnic_cm_indicate_kcqe(void *data, struct kcqe *kcqe[], u32 num_cqe)
> +{
> +	struct cnic_dev *dev = data;
> +	int i;
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	for (i = 0; i < num_cqe; i++)
> +		cnic_queue_work(cp, WORK_TYPE_KCQE, kcqe[i]);
> +
> +	tasklet_schedule(&cp->cnic_task);
> +}
> +
> +static void cnic_cm_indicate_event(void *data, unsigned long event)
> +{
> +}
> +
> +static void cnic_cm_dummy(void *data)
> +{
> +}
> +
> +static struct cnic_ulp_ops cm_ulp_ops = {
> +	.cnic_start		= cnic_cm_dummy,
> +	.cnic_stop		= cnic_cm_dummy,
> +	.indicate_kcqes		= cnic_cm_indicate_kcqe,
> +	.indicate_netevent	= cnic_cm_indicate_event,
> +	.indicate_inetevent	= cnic_cm_indicate_event,
> +};
> +
> +static void cnic_task(unsigned long data)
> +{
> +	struct cnic_local *cp = (struct cnic_local *) data;
> +	struct cnic_dev *dev = cp->dev;
> +	u32 cons = cp->cnic_wr_cons;
> +	u32 prod = cp->cnic_wr_prod;
> +
> +	while (cons != prod) {
> +		struct cnic_work_node *node;
> +
> +		node = &cp->cnic_work_ring[cons];
> +		if (node->work_type == WORK_TYPE_KCQE)
> +			cnic_cm_process_kcqe(dev, &node->work_data.kcqe);
> +		else if (node->work_type == WORK_TYPE_NEIGH_UPDATE)
> +			cnic_cm_process_neigh(dev, node->work_data.neigh);
> +		else if (node->work_type == WORK_TYPE_REDIRECT)
> +			cnic_cm_process_redirect(dev,
> +				&node->work_data.cnic_redir);
> +		cons++;
> +		cons &= WORK_RING_SIZE_MASK;
> +	}
> +	cp->cnic_wr_cons = cons;
> +}
> +
> +static void cnic_free_dev(struct cnic_dev *dev)
> +{
> +	int i = 0;
> +
> +	while ((atomic_read(&dev->ref_count) != 0) && i < 10) {
> +		msleep(100);
> +		i++;
> +	}
> +	if (atomic_read(&dev->ref_count) != 0)
> +		printk(KERN_ERR PFX "%s: Failed waiting for ref count to go"
> +				    " to zero.\n", dev->netdev->name);
> +
> +	printk(KERN_INFO PFX "Removed CNIC device: %s\n", dev->netdev->name);
> +	dev_put(dev->netdev);
> +	kfree(dev);
> +}
> +
> +static void cnic_cm_free_mem(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	kfree(cp->csk_tbl);
> +	cp->csk_tbl = NULL;
> +}
> +
> +static int cnic_cm_alloc_mem(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +
> +	cp->csk_tbl = kmalloc(sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ,
> +			      GFP_KERNEL);
> +	if (!cp->csk_tbl)
> +		return -ENOMEM;
> +	memset(cp->csk_tbl, 0, sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ);
> +	return 0;
> +}
> +
> +static void cnic_cm_stop_bnx2_hw(struct cnic_dev *dev)
> +{
> +}
> +
> +static int cnic_cm_init_bnx2_hw(struct cnic_dev *dev)
> +{
> +	u32 seed;
> +
> +	get_random_bytes(&seed, 4);
> +	cnic_bnx2_ctx_wr(dev, 45, 0, seed);
> +	return 0;
> +}
> +
> +static int cnic_cm_open(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int err;
> +
> +	err = cnic_cm_alloc_mem(dev);
> +	if (err)
> +		return err;
> +
> +	err = cp->start_cm(dev);
> +
> +	if (err)
> +		goto err_out;
> +
> +	spin_lock_init(&cp->wr_lock);
> +
> +	tasklet_init(&cp->cnic_task, &cnic_task, (unsigned long) cp);
> +
> +	cp->cm_nb.notifier_call = cnic_net_callback;
> +	register_netevent_notifier(&cp->cm_nb);
> +
> +	dev->cm_create = cnic_cm_create;
> +	dev->cm_destroy = cnic_cm_destroy;
> +	dev->cm_connect = cnic_cm_connect;
> +	dev->cm_abort = cnic_cm_abort;
> +	dev->cm_close = cnic_cm_close;
> +	dev->cm_select_dev = cnic_cm_select_dev;
> +
> +	cp->ulp_handle[CNIC_ULP_L4] = dev;
> +	rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], &cm_ulp_ops);

The cnic_lock is not held due to this being initialization time, and
that no one else can be messing with this until initialization is
complete?

> +	return 0;
> +
> +err_out:
> +	cnic_cm_free_mem(dev);
> +	return err;
> +}
> +
> +static int cnic_cm_shutdown(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int i;
> +
> +	cp->stop_cm(dev);
> +
> +	unregister_netevent_notifier(&cp->cm_nb);
> +
> +	tasklet_disable(&cp->cnic_task);
> +
> +	if (!cp->csk_tbl)
> +		return 0;
> +
> +	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
> +		struct cnic_sock *csk = &cp->csk_tbl[i];
> +
> +		clear_bit(SK_F_INUSE, &csk->flags);
> +		cnic_cm_cleanup(csk);
> +	}
> +	cnic_cm_free_mem(dev);
> +
> +	return 0;
> +}
> +
> +static void cnic_init_context(struct cnic_dev *dev, u32 cid)
> +{
> +	u32 cid_addr;
> +	int i;
> +
> +	cid_addr = GET_CID_ADDR(cid);
> +
> +	for (i = 0; i < CTX_SIZE; i += 4)
> +		cnic_bnx2_ctx_wr(dev, cid_addr, i, 0);
> +}
> +
> +static int cnic_setup_5709_context(struct cnic_dev *dev, int valid)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	int ret = 0, i;
> +	u32 valid_bit = valid ? BNX2_CTX_HOST_PAGE_TBL_DATA0_VALID : 0;
> +
> +	if (CHIP_NUM(cp) != CHIP_NUM_5709)
> +		return 0;
> +
> +	for (i = 0; i < cp->ctx_blks; i++) {
> +		int j;
> +		u32 idx = cp->ctx_arr[i].cid / cp->cids_per_blk;
> +		u32 val;
> +
> +		memset(cp->ctx_arr[i].ctx, 0, BCM_PAGE_SIZE);
> +
> +		CNIC_WR(dev, BNX2_CTX_HOST_PAGE_TBL_DATA0,
> +			(cp->ctx_arr[i].mapping & 0xffffffff) | valid_bit);
> +		CNIC_WR(dev, BNX2_CTX_HOST_PAGE_TBL_DATA1,
> +			(u64) cp->ctx_arr[i].mapping >> 32);
> +		CNIC_WR(dev, BNX2_CTX_HOST_PAGE_TBL_CTRL, idx |
> +			BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ);
> +		for (j = 0; j < 10; j++) {
> +
> +			val = CNIC_RD(dev, BNX2_CTX_HOST_PAGE_TBL_CTRL);
> +			if (!(val & BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ))
> +				break;
> +			udelay(5);
> +		}
> +		if (val & BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ) {
> +			ret = -EBUSY;
> +			break;
> +		}
> +	}
> +	return ret;
> +}
> +
> +static void cnic_free_irq(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +
> +	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
> +		cp->disable_int_sync(dev);
> +		tasklet_disable(&cp->cnic_irq_task);
> +		free_irq(ethdev->irq_arr[0].vector, dev);
> +	}
> +}
> +
> +static int cnic_init_bnx2_irq(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +
> +	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
> +		int err, i = 0;
> +		int sblk_num = cp->status_blk_num;
> +		u32 base = ((sblk_num - 1) * BNX2_HC_SB_CONFIG_SIZE) +
> +			   BNX2_HC_SB_CONFIG_1;
> +
> +		CNIC_WR(dev, base, BNX2_HC_SB_CONFIG_1_ONE_SHOT);
> +
> +		CNIC_WR(dev, base + BNX2_HC_COMP_PROD_TRIP_OFF, (2 << 16) | 8);
> +		CNIC_WR(dev, base + BNX2_HC_COM_TICKS_OFF, (64 << 16) | 220);
> +		CNIC_WR(dev, base + BNX2_HC_CMD_TICKS_OFF, (64 << 16) | 220);
> +
> +		cp->bnx2_status_blk = cp->status_blk;
> +		cp->last_status_idx = cp->bnx2_status_blk->status_idx;
> +		tasklet_init(&cp->cnic_irq_task, &cnic_service_bnx2_msix,
> +			     (unsigned long) dev);
> +		err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0,
> +				  "cnic", dev);
> +		if (err) {
> +			tasklet_disable(&cp->cnic_irq_task);
> +			return err;
> +		}
> +		while (cp->bnx2_status_blk->status_completion_producer_index &&
> +		       i < 10) {
> +			CNIC_WR(dev, BNX2_HC_COALESCE_NOW,
> +				1 << (11 + sblk_num));
> +			udelay(10);
> +			i++;
> +			barrier();
> +		}
> +		if (cp->bnx2_status_blk->status_completion_producer_index) {
> +			cnic_free_irq(dev);
> +			goto failed;
> +		}
> +
> +	} else {
> +		struct status_block *sblk = cp->status_blk;
> +		u32 hc_cmd = CNIC_RD(dev, BNX2_HC_COMMAND);
> +		int i = 0;
> +
> +		while (sblk->status_completion_producer_index && i < 10) {
> +			CNIC_WR(dev, BNX2_HC_COMMAND,
> +				hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
> +			udelay(10);
> +			i++;
> +			barrier();
> +		}
> +		if (sblk->status_completion_producer_index)
> +			goto failed;
> +
> +	}
> +	return 0;
> +
> +failed:
> +	printk(KERN_ERR PFX "%s: " "KCQ index not resetting to 0.\n",
> +	       dev->netdev->name);
> +	return -EBUSY;
> +}
> +
> +static void cnic_enable_bnx2_int(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +
> +	if (!(ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX))
> +		return;
> +
> +	CNIC_WR(dev, BNX2_PCICFG_INT_ACK_CMD, BNX2_CNIC_INT_NUM |
> +		BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | cp->last_status_idx);
> +}
> +
> +static void cnic_disable_bnx2_int_sync(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +
> +	if (!(ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX))
> +		return;
> +
> +	CNIC_WR(dev, BNX2_PCICFG_INT_ACK_CMD, BNX2_CNIC_INT_NUM |
> +		BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
> +	CNIC_RD(dev, BNX2_PCICFG_INT_ACK_CMD);
> +	synchronize_irq(ethdev->irq_arr[0].vector);
> +}
> +
> +static int cnic_start_bnx2_hw(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +	u32 val;
> +	int err;
> +
> +	val = CNIC_RD(dev, BNX2_MQ_CONFIG);
> +	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
> +	if (BCM_PAGE_BITS > 12)
> +		val |= (12 - 8)  << 4;
> +	else
> +		val |= (BCM_PAGE_BITS - 8)  << 4;
> +
> +	CNIC_WR(dev, BNX2_MQ_CONFIG, val);
> +
> +	CNIC_WR(dev, BNX2_HC_COMP_PROD_TRIP, (2 << 16) | 8);
> +	CNIC_WR(dev, BNX2_HC_COM_TICKS, (64 << 16) | 220);
> +	CNIC_WR(dev, BNX2_HC_CMD_TICKS, (64 << 16) | 220);
> +
> +	err = cnic_setup_5709_context(dev, 1);
> +	if (err)
> +		return err;
> +
> +	cnic_init_context(dev, KWQ_CID);
> +	cnic_init_context(dev, KCQ_CID);
> +
> +	cp->kwq_cid_addr = GET_CID_ADDR(KWQ_CID);
> +	cp->kwq_io_addr = MB_GET_CID_ADDR(KWQ_CID) + L5_KRNLQ_HOST_QIDX;
> +
> +	cp->max_kwq_idx = MAX_KWQ_IDX;
> +	cp->kwq_prod_idx = 0;
> +	cp->kwq_con_idx = 0;
> +	cp->cnic_local_flags |= CNIC_LCL_FL_KWQ_INIT;
> +	
> +	/* Initialize the kernel work queue context. */
> +	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
> +	      (BCM_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
> +	cnic_bnx2_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_TYPE, val);
> +	
> +	val = (BCM_PAGE_SIZE / sizeof(struct kwqe) - 1) << 16;
> +	cnic_bnx2_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
> +	
> +	val = ((BCM_PAGE_SIZE / sizeof(struct kwqe)) << 16) | KWQ_PAGE_CNT;
> +	cnic_bnx2_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
> +	
> +	val = (u32) ((u64) cp->kwq_info.pgtbl_map >> 32);
> +	cnic_bnx2_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
> +	
> +	val = (u32) cp->kwq_info.pgtbl_map;
> +	cnic_bnx2_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
> +
> +	cp->kcq_cid_addr = GET_CID_ADDR(KCQ_CID);
> +	cp->kcq_io_addr = MB_GET_CID_ADDR(KCQ_CID) + L5_KRNLQ_HOST_QIDX;
> +	
> +	cp->kcq_prod_idx = 0;
> +	
> +	/* Initialize the kernel complete queue context. */
> +	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
> +	      (BCM_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
> +	cnic_bnx2_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_TYPE, val);
> +	
> +	val = (BCM_PAGE_SIZE / sizeof(struct kcqe) - 1) << 16;
> +	cnic_bnx2_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
> +	
> +	val = ((BCM_PAGE_SIZE / sizeof(struct kcqe)) << 16) | KCQ_PAGE_CNT;
> +	cnic_bnx2_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
> +	
> +	val = (u32) ((u64) cp->kcq_info.pgtbl_map >> 32);
> +	cnic_bnx2_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
> +	
> +	val = (u32) cp->kcq_info.pgtbl_map;
> +	cnic_bnx2_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
> +
> +	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
> +		u32 sb_id = cp->status_blk_num;
> +		u32 sb = KRNLQ_STATUSB_NUM_CNIC_MSIX(sb_id);
> +
> +		cnic_bnx2_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
> +		cnic_bnx2_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
> +	}
> +
> +	/* Enable Commnad Scheduler notification when we write to the
> +	 * host producer index of the kernel contexts. */
> +	CNIC_WR(dev, BNX2_MQ_KNL_CMD_MASK1, 2);
> +
> +	/* Enable Command Scheduler notification when we write to either
> +	 * the Send Queue or Receive Queue producer indexes of the kernel
> +	 * bypass contexts. */
> +	CNIC_WR(dev, BNX2_MQ_KNL_BYP_CMD_MASK1, 7);
> +	CNIC_WR(dev, BNX2_MQ_KNL_BYP_WRITE_MASK1, 7);
> +
> +	/* Notify COM when the driver post an application buffer. */
> +	CNIC_WR(dev, BNX2_MQ_KNL_RX_V2P_MASK2, 0x2000);
> +
> +	/* Set the CP and COM doorbells.  These two processors polls the
> +	 * doorbell for a non zero value before running.  This must be done
> +	 * after setting up the kernel queue contexts. */
> +	cnic_bnx2_reg_wr_ind(dev, BNX2_CP_SCRATCH + 0x20, 1);
> +	cnic_bnx2_reg_wr_ind(dev, BNX2_COM_SCRATCH + 0x20, 1);
> +
> +	err = cnic_init_bnx2_irq(dev);
> +	if (err) {
> +		printk(KERN_ERR PFX "%s: cnic_init_irq failed\n",
> +		       dev->netdev->name);
> +		cnic_bnx2_reg_wr_ind(dev, BNX2_CP_SCRATCH + 0x20, 0);
> +		cnic_bnx2_reg_wr_ind(dev, BNX2_COM_SCRATCH + 0x20, 0);
> +		return err;
> +	}
> +
> +	return 0;
> +}
> +
> +static int cnic_start_hw(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +	int err;
> +
> +	if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
> +		return -EALREADY;
> +
> +	err = ethdev->drv_register_cnic(dev->netdev, cp->cnic_ops, dev);
> +	if (err) {
> +		printk(KERN_ERR PFX "%s: register_cnic failed\n",
> +		       dev->netdev->name);
> +		return err;
> +	}
> +
> +	dev->regview = ethdev->io_base;
> +	cp->chip_id = ethdev->chip_id;
> +	pci_dev_get(dev->pcidev);
> +	cp->func = PCI_FUNC(dev->pcidev->devfn);
> +	cp->status_blk = ethdev->irq_arr[0].status_blk;
> +	cp->status_blk_num = ethdev->irq_arr[0].status_blk_num;
> +
> +	err = cp->alloc_resc(dev);
> +	if (err) {
> +		printk(KERN_ERR PFX "%s: allocate resource failure\n",
> +		       dev->netdev->name);
> +		goto err1;
> +	}
> +
> +	err = cp->start_hw(dev);
> +	if (err)
> +		goto err1;
> +
> +	err = cnic_cm_open(dev);
> +	if (err)
> +		goto err1;
> +
> +	set_bit(CNIC_F_CNIC_UP, &dev->flags);
> +
> +	cp->enable_int(dev);
> +
> +	return 0;
> +
> +err1:
> +	ethdev->drv_unregister_cnic(dev->netdev);
> +	cp->free_resc(dev);
> +	pci_dev_put(dev->pcidev);
> +	return err;
> +}
> +
> +static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
> +{
> +	struct cnic_local *cp = dev->cnic_priv;
> +	struct cnic_eth_dev *ethdev = cp->ethdev;
> +
> +	cnic_disable_bnx2_int_sync(dev);
> +
> +	cnic_bnx2_reg_wr_ind(dev, BNX2_CP_SCRATCH + 0x20, 0);
> +	cnic_bnx2_reg_wr_ind(dev, BNX2_COM_SCRATCH + 0x20, 0);
> +
> +	cnic_init_context(dev, KWQ_CID);
> +	cnic_init_context(dev, KCQ_CID);
> +
> +	cnic_setup_5709_context(dev, 0);
> +	cnic_free_irq(dev);
> +
> +	ethdev->drv_unregister_cnic(dev->netdev);
> +
> +	cnic_free_resc(dev);
> +}
> +
> +static void cnic_stop_hw(struct cnic_dev *dev)
> +{
> +	if (test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
> +		struct cnic_local *cp = dev->cnic_priv;
> +
> +		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
> +		rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], NULL);

Given that the cnic_lock does not appear to be held, what prevents
other CPUs from manipulating cp->ulp_ops[CNIC_ULP_L4] concurrently
with this function?

> +		synchronize_rcu();
> +		cnic_cm_shutdown(dev);
> +		cp->stop_hw(dev);
> +		pci_dev_put(dev->pcidev);
> +	}
> +}
> +
> +static struct cnic_dev *alloc_cnic(struct net_device *dev)
> +{
> +	struct cnic_dev *cdev;
> +	struct cnic_local *cp;
> +	int alloc_size;
> +
> +	alloc_size = sizeof(struct cnic_dev) + sizeof(struct cnic_local);
> +
> +	cdev = kmalloc(alloc_size , GFP_KERNEL);
> +	if (cdev == NULL) {
> +		printk(KERN_ERR PFX "%s: allocate dev struct failure\n",
> +		       dev->name);
> +		return NULL;
> +	}
> +	memset(cdev, 0, alloc_size);
> +
> +	cdev->netdev = dev;
> +	cdev->cnic_priv = (char *)cdev + sizeof(struct cnic_dev);
> +	cdev->register_device = cnic_register_device;
> +	cdev->unregister_device = cnic_unregister_device;
> +	cp = cdev->cnic_priv;
> +	cp->dev = cdev;
> +
> +	spin_lock_init(&cp->cnic_ulp_lock);
> +	printk(KERN_INFO PFX "Added CNIC device: %s\n", dev->name);
> +
> +	return cdev;
> +}
> +
> +static struct cnic_dev *init_bnx2_cnic(struct net_device *dev)
> +{
> +	struct pci_dev *pdev;
> +	struct cnic_dev *cdev;
> +	struct cnic_local *cp;
> +	struct cnic_eth_dev *ethdev;
> +
> +	ethdev = bnx2_cnic_probe(dev);
> +	if (!ethdev)
> +		return NULL;
> +
> +	pdev = ethdev->pdev;
> +	if (!pdev)
> +		return NULL;
> +
> +	dev_hold(dev);
> +	pci_dev_get(pdev);
> +	if (pdev->device == PCI_DEVICE_ID_NX2_5709 ||
> +	    pdev->device == PCI_DEVICE_ID_NX2_5709S) {
> +		u8 rev;
> +
> +		pci_read_config_byte(pdev, PCI_REVISION_ID, &rev);
> +		if (rev < 0x10) {
> +			pci_dev_put(pdev);
> +			dev_put(dev);
> +			return NULL;
> +		}
> +	}
> +	pci_dev_put(pdev);
> +
> +	cdev = alloc_cnic(dev);
> +	if (cdev == NULL) {
> +		dev_put(dev);
> +		return NULL;
> +	}
> +
> +	set_bit(CNIC_F_BNX2_CLASS, &cdev->flags);
> +	cdev->submit_kwqes = cnic_submit_bnx2_kwqes;
> +
> +	cp = cdev->cnic_priv;
> +	cp->ethdev = ethdev;
> +	cdev->pcidev = pdev;
> +
> +	cp->cnic_ops = &cnic_bnx2_ops;
> +	cp->start_hw = cnic_start_bnx2_hw;
> +	cp->stop_hw = cnic_stop_bnx2_hw;
> +	cp->setup_pgtbl = cnic_setup_page_tbl;
> +	cp->alloc_resc = cnic_alloc_bnx2_resc;
> +	cp->free_resc = cnic_free_resc;
> +	cp->start_cm = cnic_cm_init_bnx2_hw;
> +	cp->stop_cm = cnic_cm_stop_bnx2_hw;
> +	cp->enable_int = cnic_enable_bnx2_int;
> +	cp->disable_int_sync = cnic_disable_bnx2_int_sync;
> +	return cdev;
> +}
> +
> +static struct cnic_dev *is_cnic_dev(struct net_device *dev)
> +{
> +	struct ethtool_drvinfo drvinfo;
> +	struct cnic_dev *cdev = NULL;
> +
> +	if (dev->ethtool_ops && dev->ethtool_ops->get_drvinfo) {
> +		memset(&drvinfo, 0, sizeof(drvinfo));
> +		dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
> +		
> +		if (!strcmp(drvinfo.driver, "bnx2"))
> +			cdev = init_bnx2_cnic(dev);
> +		if (cdev) {
> +			write_lock(&cnic_dev_lock);
> +			list_add(&cdev->list, &cnic_dev_list);
> +			write_unlock(&cnic_dev_lock);
> +		}
> +	}
> +	return cdev;
> +}
> +
> +/**
> + * IP event handler
> + */
> +static int cnic_ip_event(struct notifier_block *this, unsigned long event,
> +						 void *ptr)
> +{
> +	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
> +	struct net_device *netdev = (struct net_device *) ifa->ifa_dev->dev;
> +	struct cnic_dev *dev;
> +	int if_type;
> +	u32 my_dev = 0;
> +
> +	read_lock(&cnic_dev_lock);
> +	list_for_each_entry(dev, &cnic_dev_list, list) {
> +		if (netdev == dev->netdev) {
> +			my_dev = 1;
> +			cnic_hold(dev);
> +			break;
> +		}
> +	}
> +	read_unlock(&cnic_dev_lock);
> +
> +	if (my_dev) {
> +		struct cnic_local *cp = dev->cnic_priv;
> +
> +		rcu_read_lock();
> +		for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
> +			struct cnic_ulp_ops *ulp_ops;
> +
> +			ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
> +			if (ulp_ops) {
> +				void *ctx = cp->ulp_handle[if_type];
> +
> +				ulp_ops->indicate_inetevent(ctx, event);
> +			}
> +		}
> +		rcu_read_unlock();
> +
> +		cnic_put(dev);
> +	}
> +
> +	return NOTIFY_DONE;
> +}
> +
> +/**
> + * netdev event handler
> + */
> +static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
> +							 void *ptr)
> +{
> +	struct net_device *netdev = ptr;
> +	struct cnic_dev *dev;
> +	int if_type;
> +	u32 my_dev = 0;
> +
> +	read_lock(&cnic_dev_lock);
> +	list_for_each_entry(dev, &cnic_dev_list, list) {
> +		if (netdev == dev->netdev) {
> +			my_dev = 1;
> +			cnic_hold(dev);
> +			break;
> +		}
> +	}
> +	read_unlock(&cnic_dev_lock);
> +
> +	if (!my_dev && event == NETDEV_REGISTER) {
> +		/* Check for the hot-plug device */
> +		dev = is_cnic_dev(netdev);
> +		if (dev) {
> +			my_dev = 1;
> +			cnic_hold(dev);
> +		}
> +	}
> +	if (my_dev) {
> +		struct cnic_local *cp = dev->cnic_priv;
> +
> +		if (event == NETDEV_REGISTER)
> +			cnic_ulp_init(dev);
> +		else if (event == NETDEV_UNREGISTER)
> +			cnic_ulp_exit(dev);
> +		else if (event == NETDEV_UP) {
> +			mutex_lock(&cnic_lock);
> +			set_bit(CNIC_F_IF_UP, &dev->flags);
> +			if (dev->use_count) {
> +				if (!cnic_start_hw(dev))
> +					cnic_ulp_start(dev);
> +			}
> +			mutex_unlock(&cnic_lock);
> +		}
> +
> +		rcu_read_lock();
> +		for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
> +			struct cnic_ulp_ops *ulp_ops;
> +			void *ctx;
> +
> +			ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
> +			if (!ulp_ops)
> +				continue;
> +
> +			ctx = cp->ulp_handle[if_type];
> +
> +			ulp_ops->indicate_netevent(ctx, event);
> +		}
> +		rcu_read_unlock();
> +
> +		if (event == NETDEV_GOING_DOWN) {
> +			mutex_lock(&cnic_lock);
> +			clear_bit(CNIC_F_IF_UP, &dev->flags);
> +			set_bit(CNIC_F_IF_GOING_DOWN, &dev->flags);
> +			cnic_ulp_stop(dev);
> +			cnic_stop_hw(dev);
> +			mutex_unlock(&cnic_lock);
> +		} else if (event == NETDEV_DOWN) {
> +			mutex_lock(&cnic_lock);
> +			clear_bit(CNIC_F_IF_GOING_DOWN, &dev->flags);
> +			mutex_unlock(&cnic_lock);
> +		} else if (event == NETDEV_UNREGISTER) {
> +			write_lock(&cnic_dev_lock);
> +			list_del_init(&dev->list);
> +			write_unlock(&cnic_dev_lock);
> +
> +			cnic_put(dev);
> +			cnic_free_dev(dev);
> +			goto done;
> +		}
> +		cnic_put(dev);
> +	}
> +done:
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block cnic_ip_notifier = {
> +	cnic_ip_event,
> +	0
> +};
> +
> +static struct notifier_block cnic_netdev_notifier = {
> +	cnic_netdev_event,
> +	0
> +};
> +
> +static void cnic_release(void)
> +{
> +	struct cnic_dev *dev;
> +
> +	while (!list_empty(&cnic_dev_list)) {
> +		dev = list_entry(cnic_dev_list.next, struct cnic_dev, list);
> +		if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
> +			cnic_stop_hw(dev);
> +
> +		list_del_init(&dev->list);
> +		cnic_free_dev(dev);
> +	}
> +}
> +
> +static int __init cnic_init(void)
> +{
> +	int rc = 0;
> +	struct net_device *dev;
> +
> +	printk(KERN_INFO "%s", version);
> +
> +	rtnl_lock();
> +	/* Find Teton devices */
> +	for_each_netdev(&init_net, dev)
> +		is_cnic_dev(dev);
> +
> +	rtnl_unlock();
> +
> +	rc = register_inetaddr_notifier(&cnic_ip_notifier);
> +	if (rc)
> +		cnic_release();
> +	rc = register_netdevice_notifier(&cnic_netdev_notifier);
> +	if (rc) {
> +		unregister_inetaddr_notifier(&cnic_ip_notifier);
> +		cnic_release();
> +	}
> +	return rc;
> +}
> +
> +static void __exit cnic_exit(void)
> +{
> +	unregister_inetaddr_notifier(&cnic_ip_notifier);
> +	unregister_netdevice_notifier(&cnic_netdev_notifier);
> +	cnic_release();
> +	return;
> +}
> +
> +module_init(cnic_init);
> +module_exit(cnic_exit);
> diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
> new file mode 100644
> index 0000000..e81e895
> --- /dev/null
> +++ b/drivers/net/cnic.h
> @@ -0,0 +1,221 @@
> +/* cnic.h: Broadcom CNIC core network driver.
> + *
> + * Copyright (c) 2006 Broadcom Corporation
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation.
> + *
> + * Written by: John(Zongxi) Chen (zongxic@broadcom.com)
> + */
> +
> +
> +#ifndef CNIC_H
> +#define CNIC_H
> +
> +#if !defined(__LITTLE_ENDIAN) && !defined(__BIG_ENDIAN)
> +	#error "Missing either LITTLE_ENDIAN or BIG_ENDIAN definition."
> +#endif
> +
> +#define KWQ_PAGE_CNT	4
> +#define KCQ_PAGE_CNT	16
> +
> +#define KWQ_CID 		24
> +#define KCQ_CID 		25
> +
> +/*
> + *	krnlq_context definition
> + */
> +#define L5_KRNLQ_FLAGS	0x00000000
> +#define L5_KRNLQ_SIZE	0x00000000
> +#define L5_KRNLQ_TYPE	0x00000000
> +#define KRNLQ_FLAGS_PG_SZ					(0xf<<0)
> +#define KRNLQ_FLAGS_PG_SZ_256					(0<<0)
> +#define KRNLQ_FLAGS_PG_SZ_512					(1<<0)
> +#define KRNLQ_FLAGS_PG_SZ_1K					(2<<0)
> +#define KRNLQ_FLAGS_PG_SZ_2K					(3<<0)
> +#define KRNLQ_FLAGS_PG_SZ_4K					(4<<0)
> +#define KRNLQ_FLAGS_PG_SZ_8K					(5<<0)
> +#define KRNLQ_FLAGS_PG_SZ_16K					(6<<0)
> +#define KRNLQ_FLAGS_PG_SZ_32K					(7<<0)
> +#define KRNLQ_FLAGS_PG_SZ_64K					(8<<0)
> +#define KRNLQ_FLAGS_PG_SZ_128K					(9<<0)
> +#define KRNLQ_FLAGS_PG_SZ_256K					(10<<0)
> +#define KRNLQ_FLAGS_PG_SZ_512K					(11<<0)
> +#define KRNLQ_FLAGS_PG_SZ_1M					(12<<0)
> +#define KRNLQ_FLAGS_PG_SZ_2M					(13<<0)
> +#define KRNLQ_FLAGS_QE_SELF_SEQ					(1<<15)
> +#define KRNLQ_SIZE_TYPE_SIZE	((((0x28 + 0x1f) & ~0x1f) / 0x20) << 16)
> +#define KRNLQ_TYPE_TYPE						(0xf<<28)
> +#define KRNLQ_TYPE_TYPE_EMPTY					(0<<28)
> +#define KRNLQ_TYPE_TYPE_KRNLQ					(6<<28)
> +
> +#define L5_KRNLQ_HOST_QIDX		0x00000004
> +#define KRNLQ_STATUSB_NUM_SHIFT		16
> +#define KRNLQ_STATUSB_NUM_CNIC_MSIX(sb_id)	(((sb_id) + 7) <<	\
> +	KRNLQ_STATUSB_NUM_SHIFT)
> +#define L5_KRNLQ_HOST_FW_QIDX		0x00000008
> +#define L5_KRNLQ_NX_QE_SELF_SEQ 	0x0000000c
> +#define L5_KRNLQ_QE_SELF_SEQ_MAX	0x0000000c
> +#define L5_KRNLQ_NX_QE_HADDR_HI 	0x00000010
> +#define L5_KRNLQ_NX_QE_HADDR_LO 	0x00000014
> +#define L5_KRNLQ_PGTBL_PGIDX		0x00000018
> +#define L5_KRNLQ_NX_PG_QIDX 		0x00000018
> +#define L5_KRNLQ_PGTBL_NPAGES		0x0000001c
> +#define L5_KRNLQ_QIDX_INCR		0x0000001c
> +#define L5_KRNLQ_PGTBL_HADDR_HI 	0x00000020
> +#define L5_KRNLQ_PGTBL_HADDR_LO 	0x00000024
> +
> +#define BNX2_PG_CTX_MAP			0x1a0034
> +#define BNX2_ISCSI_CTX_MAP		0x1a0074
> +
> +struct cnic_redirect_entry {
> +	struct dst_entry *old_dst;
> +	struct dst_entry *new_dst;
> +};
> +
> +struct cnic_work_node {
> +	u32			work_type;
> +#define	WORK_TYPE_KCQE			1
> +#define	WORK_TYPE_NEIGH_UPDATE		2
> +#define	WORK_TYPE_REDIRECT		3
> +	union {
> +		struct kcqe		kcqe;
> +		struct neighbour	*neigh;
> +		struct cnic_redirect_entry cnic_redir;
> +	} work_data;
> +};
> +
> +#define WORK_RING_SIZE		128
> +#define WORK_RING_SIZE_MASK	127
> +#define MAX_CM_SK_TBL_SZ	128
> +#define MAX_COMPLETED_KCQE	64
> +
> +#define KWQE_CNT (BCM_PAGE_SIZE / sizeof(struct kwqe))
> +#define KCQE_CNT (BCM_PAGE_SIZE / sizeof(struct kcqe))
> +#define MAX_KWQE_CNT (KWQE_CNT - 1)
> +#define MAX_KCQE_CNT (KCQE_CNT - 1)
> +
> +#define MAX_KWQ_IDX	((KWQ_PAGE_CNT * KWQE_CNT) - 1)
> +#define MAX_KCQ_IDX	((KCQ_PAGE_CNT * KCQE_CNT) - 1)
> +
> +#define KWQ_PG(x) (((x) & ~MAX_KWQE_CNT) >> (BCM_PAGE_BITS - 5))
> +#define KWQ_IDX(x) ((x) & MAX_KWQE_CNT)
> +
> +#define KCQ_PG(x) (((x) & ~MAX_KCQE_CNT) >> (BCM_PAGE_BITS - 5))
> +#define KCQ_IDX(x) ((x) & MAX_KCQE_CNT)
> +
> +#define DEF_IPID_COUNT		0xc001
> +
> +#define DEF_KA_TIMEOUT		10000
> +#define DEF_KA_INTERVAL		300000
> +#define DEF_KA_MAX_PROBE_COUNT	3
> +#define DEF_TOS			0
> +#define DEF_TTL			0xfe
> +#define DEF_SND_SEQ_SCALE	0
> +#define DEF_RCV_BUF		0xffff
> +#define DEF_SND_BUF		0xffff
> +#define DEF_SEED		0
> +
> +struct cnic_ctx {
> +	u32		cid;
> +	void		*ctx;
> +	dma_addr_t	mapping;
> +};
> +
> +#define BNX2_MAX_CID		0x2000
> +
> +struct cnic_dma {
> +	int		num_pages;
> +	void		**pg_arr;
> +	dma_addr_t	*pg_map_arr;
> +	int		pgtbl_size;
> +	u32		*pgtbl;
> +	dma_addr_t	pgtbl_map;
> +};
> +
> +struct cnic_local {
> +
> +	spinlock_t cnic_ulp_lock;
> +	void *ulp_handle[MAX_CNIC_ULP_TYPE];
> +	unsigned long ulp_flags[MAX_CNIC_ULP_TYPE];
> +#define ULP_F_INIT	0
> +#define ULP_F_START	1
> +	struct cnic_ulp_ops *ulp_ops[MAX_CNIC_ULP_TYPE];
> +
> +	/* protected by ulp_lock */
> +	u32 cnic_local_flags;
> +#define	CNIC_LCL_FL_KWQ_INIT	0x00000001
> +
> +	struct cnic_dev *dev;
> +
> +	struct cnic_eth_dev *ethdev;
> +
> +	u32 kwq_cid_addr;
> +	u32 kcq_cid_addr;
> +
> +	struct cnic_dma		kwq_info;
> +	struct kwqe		**kwq;
> +
> +	u16		max_kwq_idx;
> +
> +	u16		kwq_prod_idx;
> +	u32		kwq_io_addr;
> +
> +	u16		kwq_con_idx;
> +
> +	struct cnic_dma	kcq_info;
> +	struct kcqe	**kcq;
> +
> +	u16		kcq_prod_idx;
> +	u32		kcq_io_addr;
> +
> +	void				*status_blk;
> +	struct status_block_msix	*bnx2_status_blk;
> +
> +	u32				status_blk_num;
> +	u32				last_status_idx;
> +	struct tasklet_struct		cnic_irq_task;
> +
> +	struct kcqe	*completed_kcq[MAX_COMPLETED_KCQE];
> +
> +	struct cnic_sock *csk_tbl;
> +
> +	struct notifier_block cm_nb;
> +
> +	struct cnic_work_node	cnic_work_ring[WORK_RING_SIZE];
> +	int			cnic_wr_cons;
> +	int			cnic_wr_prod;
> +	spinlock_t		wr_lock;
> +
> +	struct tasklet_struct	cnic_task;
> +
> +	struct cnic_ctx		*ctx_arr;
> +	int			ctx_blks;
> +	int			ctx_blk_size;
> +	int			cids_per_blk;
> +
> +	u32			chip_id;
> +	int			func;
> +
> +	struct cnic_ops		*cnic_ops;
> +	int			(*start_hw)(struct cnic_dev *);
> +	void			(*stop_hw)(struct cnic_dev *);
> +	void			(*setup_pgtbl)(struct cnic_dev *,
> +					       struct cnic_dma *);
> +	int			(*alloc_resc)(struct cnic_dev *);
> +	void			(*free_resc)(struct cnic_dev *);
> +	int			(*start_cm)(struct cnic_dev *);
> +	void			(*stop_cm)(struct cnic_dev *);
> +	void			(*enable_int)(struct cnic_dev *);
> +	void			(*disable_int_sync)(struct cnic_dev *);
> +	void			(*ack_int)(struct cnic_dev *);
> +};
> +
> +struct bnx2x_bd_chain_next {
> +	u32	addr_lo;
> +	u32	addr_hi;
> +	u8	reserved[8];
> +};
> +
> +#endif
> diff --git a/drivers/net/cnic_defs.h b/drivers/net/cnic_defs.h
> new file mode 100644
> index 0000000..21cbbaa
> --- /dev/null
> +++ b/drivers/net/cnic_defs.h
> @@ -0,0 +1,553 @@
> +#ifndef __57XX_L5CM_HSI_LINUX_LE__
> +#define __57XX_L5CM_HSI_LINUX_LE__
> +
> +/* KWQ (kernel work queue) request op codes */
> +#define L4_KWQE_OPCODE_VALUE_CONNECT1               (50)
> +#define L4_KWQE_OPCODE_VALUE_CONNECT2               (51)
> +#define L4_KWQE_OPCODE_VALUE_CONNECT3               (52)
> +#define L4_KWQE_OPCODE_VALUE_RESET                  (53)
> +#define L4_KWQE_OPCODE_VALUE_CLOSE                  (54)
> +#define L4_KWQE_OPCODE_VALUE_UPDATE_SECRET          (60)
> +#define L4_KWQE_OPCODE_VALUE_INIT_ULP               (61)
> +
> +#define L4_KWQE_OPCODE_VALUE_OFFLOAD_PG             (1)
> +#define L4_KWQE_OPCODE_VALUE_UPDATE_PG              (9)
> +#define L4_KWQE_OPCODE_VALUE_UPLOAD_PG              (14)
> +
> +/* KCQ (kernel completion queue) response op codes */
> +#define L4_KCQE_OPCODE_VALUE_CLOSE_COMP             (53)
> +#define L4_KCQE_OPCODE_VALUE_RESET_COMP             (54)
> +#define L4_KCQE_OPCODE_VALUE_FW_TCP_UPDATE          (55)
> +#define L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE       (56)
> +#define L4_KCQE_OPCODE_VALUE_RESET_RECEIVED         (57)
> +#define L4_KCQE_OPCODE_VALUE_CLOSE_RECEIVED         (58)
> +#define L4_KCQE_OPCODE_VALUE_INIT_ULP               (61)
> +
> +#define L4_KCQE_OPCODE_VALUE_OFFLOAD_PG             (1)
> +#define L4_KCQE_OPCODE_VALUE_UPDATE_PG              (9)
> +#define L4_KCQE_OPCODE_VALUE_UPLOAD_PG              (14)
> +
> +/* KCQ (kernel completion queue) completion status */
> +#define L4_KCQE_COMPLETION_STATUS_SUCCESS		    (0)
> +#define L4_KCQE_COMPLETION_STATUS_TIMEOUT        (0x93)
> +
> +#define L4_LAYER_CODE (4)
> +
> +/*
> + * L4 KCQ CQE
> + */
> +struct l4_kcq {
> +	u32 cid;
> +	u32 pg_cid;
> +	u32 conn_id;
> +	u32 pg_host_opaque;
> +#if defined(__BIG_ENDIAN)
> +	u16 status;
> +	u16 reserved1;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 reserved1;
> +	u16 status;
> +#endif
> +	u32 reserved2[2];
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KCQ_RESERVED3 (0xF<<0)
> +#define L4_KCQ_RESERVED3_SHIFT 0
> +#define L4_KCQ_LAYER_CODE (0x7<<4)
> +#define L4_KCQ_LAYER_CODE_SHIFT 4
> +#define L4_KCQ_RESERVED4 (0x1<<7)
> +#define L4_KCQ_RESERVED4_SHIFT 7
> +	u8 op_code;
> +	u16 qe_self_seq;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 qe_self_seq;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KCQ_RESERVED3 (0xF<<0)
> +#define L4_KCQ_RESERVED3_SHIFT 0
> +#define L4_KCQ_LAYER_CODE (0x7<<4)
> +#define L4_KCQ_LAYER_CODE_SHIFT 4
> +#define L4_KCQ_RESERVED4 (0x1<<7)
> +#define L4_KCQ_RESERVED4_SHIFT 7
> +#endif
> +};
> +
> +
> +/*
> + * L4 KCQ CQE PG upload
> + */
> +struct l4_kcq_upload_pg {
> +	u32 pg_cid;
> +#if defined(__BIG_ENDIAN)
> +	u16 pg_status;
> +	u16 pg_ipid_count;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 pg_ipid_count;
> +	u16 pg_status;
> +#endif
> +	u32 reserved1[5];
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KCQ_UPLOAD_PG_RESERVED3 (0xF<<0)
> +#define L4_KCQ_UPLOAD_PG_RESERVED3_SHIFT 0
> +#define L4_KCQ_UPLOAD_PG_LAYER_CODE (0x7<<4)
> +#define L4_KCQ_UPLOAD_PG_LAYER_CODE_SHIFT 4
> +#define L4_KCQ_UPLOAD_PG_RESERVED4 (0x1<<7)
> +#define L4_KCQ_UPLOAD_PG_RESERVED4_SHIFT 7
> +	u8 op_code;
> +	u16 qe_self_seq;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 qe_self_seq;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KCQ_UPLOAD_PG_RESERVED3 (0xF<<0)
> +#define L4_KCQ_UPLOAD_PG_RESERVED3_SHIFT 0
> +#define L4_KCQ_UPLOAD_PG_LAYER_CODE (0x7<<4)
> +#define L4_KCQ_UPLOAD_PG_LAYER_CODE_SHIFT 4
> +#define L4_KCQ_UPLOAD_PG_RESERVED4 (0x1<<7)
> +#define L4_KCQ_UPLOAD_PG_RESERVED4_SHIFT 7
> +#endif
> +};
> +
> +
> +/*
> + * Gracefully close the connection request
> + */
> +struct l4_kwq_close_req {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_CLOSE_REQ_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CLOSE_REQ_RESERVED1_SHIFT 0
> +#define L4_KWQ_CLOSE_REQ_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CLOSE_REQ_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT_SHIFT 7
> +	u8 op_code;
> +	u16 reserved0;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 reserved0;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KWQ_CLOSE_REQ_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CLOSE_REQ_RESERVED1_SHIFT 0
> +#define L4_KWQ_CLOSE_REQ_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CLOSE_REQ_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +	u32 cid;
> +	u32 reserved2[6];
> +};
> +
> +
> +/*
> + * The first request to be passed in order to establish connection
> + */
> +struct l4_kwq_connect_req1 {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_CONNECT_REQ1_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CONNECT_REQ1_RESERVED1_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ1_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CONNECT_REQ1_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT_SHIFT 7
> +	u8 op_code;
> +	u8 reserved0;
> +	u8 conn_flags;
> +#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE (0x1<<0)
> +#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ1_IP_V6 (0x1<<1)
> +#define L4_KWQ_CONNECT_REQ1_IP_V6_SHIFT 1
> +#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG (0x1<<2)
> +#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG_SHIFT 2
> +#define L4_KWQ_CONNECT_REQ1_RSRV (0x1F<<3)
> +#define L4_KWQ_CONNECT_REQ1_RSRV_SHIFT 3
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 conn_flags;
> +#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE (0x1<<0)
> +#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ1_IP_V6 (0x1<<1)
> +#define L4_KWQ_CONNECT_REQ1_IP_V6_SHIFT 1
> +#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG (0x1<<2)
> +#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG_SHIFT 2
> +#define L4_KWQ_CONNECT_REQ1_RSRV (0x1F<<3)
> +#define L4_KWQ_CONNECT_REQ1_RSRV_SHIFT 3
> +	u8 reserved0;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KWQ_CONNECT_REQ1_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CONNECT_REQ1_RESERVED1_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ1_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CONNECT_REQ1_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +	u32 cid;
> +	u32 pg_cid;
> +	u32 src_ip;
> +	u32 dst_ip;
> +#if defined(__BIG_ENDIAN)
> +	u16 dst_port;
> +	u16 src_port;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 src_port;
> +	u16 dst_port;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u8 rsrv1[3];
> +	u8 tcp_flags;
> +#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK (0x1<<0)
> +#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE (0x1<<1)
> +#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE_SHIFT 1
> +#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE (0x1<<2)
> +#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE_SHIFT 2
> +#define L4_KWQ_CONNECT_REQ1_TIME_STAMP (0x1<<3)
> +#define L4_KWQ_CONNECT_REQ1_TIME_STAMP_SHIFT 3
> +#define L4_KWQ_CONNECT_REQ1_SACK (0x1<<4)
> +#define L4_KWQ_CONNECT_REQ1_SACK_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ1_SEG_SCALING (0x1<<5)
> +#define L4_KWQ_CONNECT_REQ1_SEG_SCALING_SHIFT 5
> +#define L4_KWQ_CONNECT_REQ1_RESERVED2 (0x3<<6)
> +#define L4_KWQ_CONNECT_REQ1_RESERVED2_SHIFT 6
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 tcp_flags;
> +#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK (0x1<<0)
> +#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE (0x1<<1)
> +#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE_SHIFT 1
> +#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE (0x1<<2)
> +#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE_SHIFT 2
> +#define L4_KWQ_CONNECT_REQ1_TIME_STAMP (0x1<<3)
> +#define L4_KWQ_CONNECT_REQ1_TIME_STAMP_SHIFT 3
> +#define L4_KWQ_CONNECT_REQ1_SACK (0x1<<4)
> +#define L4_KWQ_CONNECT_REQ1_SACK_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ1_SEG_SCALING (0x1<<5)
> +#define L4_KWQ_CONNECT_REQ1_SEG_SCALING_SHIFT 5
> +#define L4_KWQ_CONNECT_REQ1_RESERVED2 (0x3<<6)
> +#define L4_KWQ_CONNECT_REQ1_RESERVED2_SHIFT 6
> +	u8 rsrv1[3];
> +#endif
> +	u32 rsrv2;
> +};
> +
> +
> +/*
> + * The second ( optional )request to be passed in order to establish connection - for IPv6 only
> + */
> +struct l4_kwq_connect_req2 {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_CONNECT_REQ2_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CONNECT_REQ2_RESERVED1_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ2_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CONNECT_REQ2_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT_SHIFT 7
> +	u8 op_code;
> +	u8 reserved0;
> +	u8 rsrv;
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 rsrv;
> +	u8 reserved0;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KWQ_CONNECT_REQ2_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CONNECT_REQ2_RESERVED1_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ2_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CONNECT_REQ2_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +	u32 reserved2;
> +	u32 src_ip_v6_2;
> +	u32 src_ip_v6_3;
> +	u32 src_ip_v6_4;
> +	u32 dst_ip_v6_2;
> +	u32 dst_ip_v6_3;
> +	u32 dst_ip_v6_4;
> +};
> +
> +
> +/*
> + * The third ( and last )request to be passed in order to establish connection
> + */
> +struct l4_kwq_connect_req3 {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_CONNECT_REQ3_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CONNECT_REQ3_RESERVED1_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ3_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CONNECT_REQ3_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT_SHIFT 7
> +	u8 op_code;
> +	u16 reserved0;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 reserved0;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KWQ_CONNECT_REQ3_RESERVED1 (0xF<<0)
> +#define L4_KWQ_CONNECT_REQ3_RESERVED1_SHIFT 0
> +#define L4_KWQ_CONNECT_REQ3_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_CONNECT_REQ3_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +	u32 ka_timeout;
> +	u32 ka_interval ;
> +#if defined(__BIG_ENDIAN)
> +	u8 snd_seq_scale;
> +	u8 ttl;
> +	u8 tos;
> +	u8 ka_max_probe_count;
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 ka_max_probe_count;
> +	u8 tos;
> +	u8 ttl;
> +	u8 snd_seq_scale;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u16 pmtu;
> +	u16 mss;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 mss;
> +	u16 pmtu;
> +#endif
> +	u32 rcv_buf;
> +	u32 snd_buf;
> +	u32 seed;
> +};
> +
> +
> +/*
> + * a KWQE request to offload a PG connection
> + */
> +struct l4_kwq_offload_pg {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_OFFLOAD_PG_RESERVED1 (0xF<<0)
> +#define L4_KWQ_OFFLOAD_PG_RESERVED1_SHIFT 0
> +#define L4_KWQ_OFFLOAD_PG_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_OFFLOAD_PG_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT_SHIFT 7
> +	u8 op_code;
> +	u16 reserved0;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 reserved0;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KWQ_OFFLOAD_PG_RESERVED1 (0xF<<0)
> +#define L4_KWQ_OFFLOAD_PG_RESERVED1_SHIFT 0
> +#define L4_KWQ_OFFLOAD_PG_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_OFFLOAD_PG_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u8 l2hdr_nbytes;
> +	u8 pg_flags;
> +#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP (0x1<<0)
> +#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP_SHIFT 0
> +#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING (0x1<<1)
> +#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING_SHIFT 1
> +#define L4_KWQ_OFFLOAD_PG_RESERVED2 (0x3F<<2)
> +#define L4_KWQ_OFFLOAD_PG_RESERVED2_SHIFT 2
> +	u8 da0;
> +	u8 da1;
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 da1;
> +	u8 da0;
> +	u8 pg_flags;
> +#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP (0x1<<0)
> +#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP_SHIFT 0
> +#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING (0x1<<1)
> +#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING_SHIFT 1
> +#define L4_KWQ_OFFLOAD_PG_RESERVED2 (0x3F<<2)
> +#define L4_KWQ_OFFLOAD_PG_RESERVED2_SHIFT 2
> +	u8 l2hdr_nbytes;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u8 da2;
> +	u8 da3;
> +	u8 da4;
> +	u8 da5;
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 da5;
> +	u8 da4;
> +	u8 da3;
> +	u8 da2;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u8 sa0;
> +	u8 sa1;
> +	u8 sa2;
> +	u8 sa3;
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 sa3;
> +	u8 sa2;
> +	u8 sa1;
> +	u8 sa0;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u8 sa4;
> +	u8 sa5;
> +	u16 etype;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 etype;
> +	u8 sa5;
> +	u8 sa4;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u16 vlan_tag;
> +	u16 ipid_start;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 ipid_start;
> +	u16 vlan_tag;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u16 ipid_count;
> +	u16 reserved3;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 reserved3;
> +	u16 ipid_count;
> +#endif
> +	u32 host_opaque;
> +};
> +
> +
> +/*
> + * Abortively close the connection request
> + */
> +struct l4_kwq_reset_req {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_RESET_REQ_RESERVED1 (0xF<<0)
> +#define L4_KWQ_RESET_REQ_RESERVED1_SHIFT 0
> +#define L4_KWQ_RESET_REQ_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_RESET_REQ_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT_SHIFT 7
> +	u8 op_code;
> +	u16 reserved0;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 reserved0;
> +	u8 op_code;
> +	u8 flags;
> +#define L4_KWQ_RESET_REQ_RESERVED1 (0xF<<0)
> +#define L4_KWQ_RESET_REQ_RESERVED1_SHIFT 0
> +#define L4_KWQ_RESET_REQ_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_RESET_REQ_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +	u32 cid;
> +	u32 reserved2[6];
> +};
> +
> +
> +/*
> + * a KWQE request to update a PG connection
> + */
> +struct l4_kwq_update_pg {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_UPDATE_PG_RESERVED1 (0xF<<0)
> +#define L4_KWQ_UPDATE_PG_RESERVED1_SHIFT 0
> +#define L4_KWQ_UPDATE_PG_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_UPDATE_PG_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT_SHIFT 7
> +	u8 opcode;
> +	u16 oper16;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 oper16;
> +	u8 opcode;
> +	u8 flags;
> +#define L4_KWQ_UPDATE_PG_RESERVED1 (0xF<<0)
> +#define L4_KWQ_UPDATE_PG_RESERVED1_SHIFT 0
> +#define L4_KWQ_UPDATE_PG_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_UPDATE_PG_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +	u32 pg_cid;
> +	u32 pg_host_opaque;
> +#if defined(__BIG_ENDIAN)
> +	u8 pg_valids;
> +#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT (0x1<<0)
> +#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT_SHIFT 0
> +#define L4_KWQ_UPDATE_PG_VALIDS_DA (0x1<<1)
> +#define L4_KWQ_UPDATE_PG_VALIDS_DA_SHIFT 1
> +#define L4_KWQ_UPDATE_PG_RESERVERD2 (0x3F<<2)
> +#define L4_KWQ_UPDATE_PG_RESERVERD2_SHIFT 2
> +	u8 pg_unused_a;
> +	u16 pg_ipid_count;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 pg_ipid_count;
> +	u8 pg_unused_a;
> +	u8 pg_valids;
> +#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT (0x1<<0)
> +#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT_SHIFT 0
> +#define L4_KWQ_UPDATE_PG_VALIDS_DA (0x1<<1)
> +#define L4_KWQ_UPDATE_PG_VALIDS_DA_SHIFT 1
> +#define L4_KWQ_UPDATE_PG_RESERVERD2 (0x3F<<2)
> +#define L4_KWQ_UPDATE_PG_RESERVERD2_SHIFT 2
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u16 reserverd3;
> +	u8 da0;
> +	u8 da1;
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 da1;
> +	u8 da0;
> +	u16 reserverd3;
> +#endif
> +#if defined(__BIG_ENDIAN)
> +	u8 da2;
> +	u8 da3;
> +	u8 da4;
> +	u8 da5;
> +#elif defined(__LITTLE_ENDIAN)
> +	u8 da5;
> +	u8 da4;
> +	u8 da3;
> +	u8 da2;
> +#endif
> +	u32 reserved4;
> +	u32 reserved5;
> +};
> +
> +
> +/*
> + * a KWQE request to upload a PG or L4 context
> + */
> +struct l4_kwq_upload {
> +#if defined(__BIG_ENDIAN)
> +	u8 flags;
> +#define L4_KWQ_UPLOAD_RESERVED1 (0xF<<0)
> +#define L4_KWQ_UPLOAD_RESERVED1_SHIFT 0
> +#define L4_KWQ_UPLOAD_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_UPLOAD_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT_SHIFT 7
> +	u8 opcode;
> +	u16 oper16;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 oper16;
> +	u8 opcode;
> +	u8 flags;
> +#define L4_KWQ_UPLOAD_RESERVED1 (0xF<<0)
> +#define L4_KWQ_UPLOAD_RESERVED1_SHIFT 0
> +#define L4_KWQ_UPLOAD_LAYER_CODE (0x7<<4)
> +#define L4_KWQ_UPLOAD_LAYER_CODE_SHIFT 4
> +#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT (0x1<<7)
> +#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT_SHIFT 7
> +#endif
> +	u32 cid;
> +	u32 reserved2[6];
> +};
> +
> +#endif /* __57XX_L5CM_HSI_LINUX_LE__ */
> diff --git a/drivers/net/cnic_drv.h b/drivers/net/cnic_drv.h
> new file mode 100644
> index 0000000..ab6431f
> --- /dev/null
> +++ b/drivers/net/cnic_drv.h
> @@ -0,0 +1,112 @@
> +/* cnic_drv.h: Broadcom CNIC core network driver.
> + *
> + * Copyright (c) 2008 Broadcom Corporation
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation.
> + *
> + */
> +
> +
> +#ifndef CNIC_DRV_H
> +#define CNIC_DRV_H
> +
> +struct kwqe;
> +struct kcqe;
> +struct kwqe_16;
> +
> +#define MAX_CNIC_CTL_DATA	64
> +#define MAX_DRV_CTL_DATA	64
> +
> +#define CNIC_CTL_STOP_CMD		1
> +#define CNIC_CTL_START_CMD		2
> +#define CNIC_CTL_COMPLETION_CMD		3
> +
> +#define DRV_CTL_IO_WR_CMD		0x101
> +#define DRV_CTL_IO_RD_CMD		0x102
> +#define DRV_CTL_CTX_WR_CMD		0x103
> +#define DRV_CTL_CTXTBL_WR_CMD		0x104
> +#define DRV_CTL_COMPLETION_CMD		0x105
> +
> +struct cnic_ctl_completion {
> +	u32	cid;
> +};
> +
> +struct drv_ctl_completion {
> +	u32	comp_count;
> +};
> +
> +struct cnic_ctl_info {
> +	int	cmd;
> +	union {
> +		struct cnic_ctl_completion comp;
> +		char bytes[MAX_CNIC_CTL_DATA];
> +	} data;
> +};
> +
> +struct drv_ctl_io {
> +	u32		cid_addr;
> +	u32		slot;
> +	u32		offset;
> +	u32		data;
> +	dma_addr_t	dma_addr;
> +};
> +
> +struct drv_ctl_info {
> +	int	cmd;
> +	union {
> +		struct drv_ctl_completion comp;
> +		struct drv_ctl_io io;
> +		char bytes[MAX_DRV_CTL_DATA];
> +	} data;
> +};
> +
> +struct cnic_ops {
> +	struct module	*cnic_owner;
> +	int		(*cnic_handler)(void *, void *);
> +	int		(*cnic_ctl)(void *, struct cnic_ctl_info *);
> +	unsigned long	reserved[2];
> +};
> +
> +#define MAX_CNIC_VEC	8
> +
> +struct cnic_irq {
> +	unsigned int	vector;
> +	void		*status_blk;
> +	u32		status_blk_num;
> +	u32		irq_flags;
> +#define CNIC_IRQ_FL_MSIX		0x00000001
> +};
> +
> +struct cnic_eth_dev {
> +	u32		drv_state;
> +#define CNIC_DRV_STATE_REGD		0x00000001
> +#define CNIC_DRV_STATE_USING_MSIX	0x00000002
> +	u32		chip_id;
> +	u32		max_kwqe_pending;
> +	struct pci_dev	*pdev;
> +	void __iomem	*io_base;
> +
> +	u32		ctx_tbl_offset;
> +	u32		ctx_tbl_len;
> +	int		ctx_blk_size;
> +	u32		starting_cid;
> +
> +	int		num_irq;
> +	struct cnic_irq	irq_arr[MAX_CNIC_VEC];
> +	int		(*drv_register_cnic)(struct net_device *,
> +					     struct cnic_ops *, void *);
> +	int		(*drv_unregister_cnic)(struct net_device *);
> +	int		(*drv_submit_kwqes_32)(struct net_device *,
> +					       struct kwqe *[], u32);
> +	int		(*drv_submit_kwqes_16)(struct net_device *,
> +					       struct kwqe_16 *[], u32);
> +	int		(*drv_ctl)(struct net_device *, struct drv_ctl_info *);
> +	unsigned long	reserved[2];
> +};
> +
> +extern struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *)
> +	__attribute__((weak));
> +
> +#endif
> diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
> new file mode 100644
> index 0000000..e77b6ac
> --- /dev/null
> +++ b/drivers/net/cnic_if.h
> @@ -0,0 +1,171 @@
> +/* cnic_if.h: Broadcom CNIC core network driver.
> + *
> + * Copyright (c) 2006 Broadcom Corporation
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation.
> + *
> + * Written by: John(Zongxi) Chen  (zongxic@broadcom.com)
> + */
> +
> +
> +#ifndef CNIC_IF_H
> +#define CNIC_IF_H
> +
> +#define CNIC_MODULE_VERSION	"1.4.0"
> +#define CNIC_MODULE_RELDATE	"May 14, 2008"
> +
> +#define CNIC_ULP_RDMA		0
> +#define CNIC_ULP_ISCSI		1
> +#define CNIC_ULP_L4		2
> +#define MAX_CNIC_ULP_TYPE_EXT	2
> +#define MAX_CNIC_ULP_TYPE	3
> +
> +struct kwqe {
> +	u32 kwqe_op_flag;
> +
> +	u32 kwqe_info0;
> +	u32 kwqe_info1;
> +	u32 kwqe_info2;
> +	u32 kwqe_info3;
> +	u32 kwqe_info4;
> +	u32 kwqe_info5;
> +	u32 kwqe_info6;
> +};
> +
> +struct kcqe {
> +	u32 kcqe_info0;
> +	u32 kcqe_info1;
> +	u32 kcqe_info2;
> +	u32 kcqe_info3;
> +	u32 kcqe_info4;
> +	u32 kcqe_info5;
> +	u32 kcqe_info6;
> +	u32 kcqe_op_flag;
> +		#define KCQE_FLAGS_LAYER_MASK		(0x7<<28)
> +		#define KCQE_FLAGS_LAYER_MASK_MISC	(0<<28)
> +		#define KCQE_FLAGS_LAYER_MASK_L2	(2<<28)
> +		#define KCQE_FLAGS_LAYER_MASK_L3	(3<<28)
> +		#define KCQE_FLAGS_LAYER_MASK_L4	(4<<28)
> +		#define KCQE_FLAGS_LAYER_MASK_L5_RDMA	(5<<28)
> +		#define KCQE_FLAGS_LAYER_MASK_L5_ISCSI	(6<<28)
> +		#define KCQE_FLAGS_NEXT 		(1<<31)
> +};
> +
> +struct cnic_sockaddr {
> +	union {
> +		struct sockaddr_in	v4;
> +		struct sockaddr_in6	v6;
> +	} local;
> +	union {
> +		struct sockaddr_in	v4;
> +		struct sockaddr_in6	v6;
> +	} remote;
> +};
> +
> +struct cnic_sock {
> +	struct cnic_dev *dev;
> +	void	*context;
> +	u32	src_ip[4];
> +	u32	dst_ip[4];
> +	u16	src_port;
> +	u16	dst_port;
> +	u16	vlan_id;
> +	unsigned char old_ha[6];
> +	struct dst_entry *dst;
> +	u32	cid;
> +	u32	l5_cid;
> +	u32	pg_cid;
> +	int	ulp_type;
> +
> +	u32	ka_timeout;
> +	u32	ka_interval;
> +	u8	ka_max_probe_count;
> +	u8	tos;
> +	u8	ttl;
> +	u8	snd_seq_scale;
> +	u32	rcv_buf;
> +	u32	snd_buf;
> +	u32	seed;
> +
> +	unsigned long	tcp_flags;
> +#define SK_TCP_NO_DELAY_ACK	0
> +#define SK_TCP_KEEP_ALIVE	1
> +#define SK_TCP_NAGLE		2
> +#define SK_TCP_TIMESTAMP	3
> +#define SK_TCP_SACK		4
> +#define SK_TCP_SEG_SCALING	5
> +	unsigned long	flags;
> +#define SK_F_INUSE		0
> +#define SK_F_OFFLD_COMPLETE	1
> +#define SK_F_OFFLD_SCHED	2
> +#define SK_F_PG_OFFLD_COMPLETE	3
> +#define SK_F_CONNECT_START	4
> +#define SK_F_IPV6		5
> +#define SK_F_NDISC_WAITING	6
> +
> +	atomic_t ref_count;
> +
> +	struct kwqe kwqe1;
> +	struct kwqe kwqe2;
> +	struct kwqe kwqe3;
> +};
> +
> +struct cnic_dev {
> +	struct net_device	*netdev;
> +	struct pci_dev		*pcidev;
> +	void __iomem		*regview;
> +	struct list_head	list;
> +
> +	int (*register_device)(struct cnic_dev *dev, int ulp_type,
> +			       void *ulp_ctx);
> +	int (*unregister_device)(struct cnic_dev *dev, int ulp_type);
> +	int (*submit_kwqes)(struct cnic_dev *dev, struct kwqe *wqes[],
> +				u32 num_wqes);
> +
> +	int (*cm_create)(struct cnic_dev *, int, u32, u32, struct cnic_sock **,
> +			 void *);
> +	int (*cm_destroy)(struct cnic_sock *);
> +	int (*cm_connect)(struct cnic_sock *, struct cnic_sockaddr *);
> +	int (*cm_abort)(struct cnic_sock *);
> +	int (*cm_close)(struct cnic_sock *);
> +	struct cnic_dev *(*cm_select_dev)(struct sockaddr_in *, int ulp_type);
> +	unsigned long flags;
> +#define CNIC_F_IF_UP		0
> +#define CNIC_F_CNIC_UP		1
> +#define CNIC_F_IF_GOING_DOWN	2
> +#define CNIC_F_BNX2_CLASS	3
> +#define CNIC_F_BNX2X_CLASS	4
> +	atomic_t ref_count;
> +	int use_count;
> +	void *cnic_priv;
> +};
> +
> +#define CNIC_WR(dev, off, val)		writel(val, dev->regview + off)
> +#define CNIC_WR16(dev, off, val)	writew(val, dev->regview + off)
> +#define CNIC_WR8(dev, off, val)		writeb(val, dev->regview + off)
> +#define CNIC_RD(dev, off)		readl(dev->regview + off)
> +
> +struct cnic_ulp_ops {
> +	void (*cnic_init)(struct cnic_dev *dev);
> +	void (*cnic_exit)(struct cnic_dev *dev);
> +	void (*cnic_start)(void *ulp_ctx);
> +	void (*cnic_stop)(void *ulp_ctx);
> +	void (*indicate_kcqes)(void *ulp_ctx, struct kcqe *cqes[],
> +				u32 num_cqes);
> +	void (*indicate_netevent)(void *ulp_ctx, unsigned long event);
> +	void (*indicate_inetevent)(void *ulp_ctx, unsigned long event);
> +	void (*cm_connect_complete)(struct cnic_sock *);
> +	void (*cm_close_complete)(struct cnic_sock *);
> +	void (*cm_abort_complete)(struct cnic_sock *);
> +	void (*cm_remote_close)(struct cnic_sock *);
> +	void (*cm_remote_abort)(struct cnic_sock *);
> +	struct module *owner;
> +};
> +
> +extern int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops);
> +
> +extern int cnic_unregister_driver(int ulp_type);
> +
> +#endif
> -- 
> 1.5.5.GIT
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
