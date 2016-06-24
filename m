From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v10 07/22] IB/hns: Add event queue support
Date: Fri, 24 Jun 2016 18:46:43 +0300
Message-ID: <20160624154643.GG23995@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-8-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Cgrdyab2wu3Akvjd"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50088 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbcFXPrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 11:47:00 -0400
Content-Disposition: inline
In-Reply-To: <1466087730-54856-8-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Cgrdyab2wu3Akvjd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 10:35:15PM +0800, Lijun Ou wrote:
> This patch added event queue support for RoCE driver. It is used
> for RoCE interrupt. RoCE includes 32 synchronous event irqs, 1
> asynchronous event irq and 1 common overflow irq.
>=20
> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> ---
> PATCH v9/v8:
> - No change over the PATCH v7
>=20
> PATCH v7:
> This fixes the comments given by Doug Ledford over the PATCH v6:
>   Link: https://lkml.org/lkml/2016/5/13/510
>=20
> PATCH v6:
> - No change over the PATCH v5
>=20
> PATCH v5:
> - The initial patch which was redesigned based on the second patch
>   in PATCH v4
> ---
> ---
>  drivers/infiniband/hw/hns/hns_roce_cmd.c    |  22 +
>  drivers/infiniband/hw/hns/hns_roce_common.h |  70 +++
>  drivers/infiniband/hw/hns/hns_roce_cq.c     |  77 +++
>  drivers/infiniband/hw/hns/hns_roce_device.h | 135 +++++
>  drivers/infiniband/hw/hns/hns_roce_eq.c     | 750 ++++++++++++++++++++++=
++++++
>  drivers/infiniband/hw/hns/hns_roce_eq.h     | 130 +++++
>  drivers/infiniband/hw/hns/hns_roce_main.c   |  24 +
>  drivers/infiniband/hw/hns/hns_roce_qp.c     |  63 +++
>  8 files changed, 1271 insertions(+)
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_cq.c
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_eq.c
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_eq.h
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_qp.c
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.c b/drivers/infiniban=
d/hw/hns/hns_roce_cmd.c
> index 64e84fe..67b3137 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_cmd.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_cmd.c
> @@ -45,6 +45,28 @@
> =20
>  #define CMD_MAX_NUM		32
> =20
> +static int hns_roce_status_to_errno(u8 orig_status)
> +{
> +	if (orig_status =3D=3D HNS_ROCE_CMD_SUCCESS)
> +		return 0;
> +	else
> +		return -EIO;
> +}

1. Can orig_status be different from SUCCESS? You defined one enum only.
2. return (orig_status =3D=3D HNS_ROCE_CMD_SUCCESS)?0:(-EIO);

> +
> +void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 statu=
s,
> +			u64 out_param)
> +{
> +	struct hns_roce_cmd_context
> +		*context =3D &hr_dev->cmd.context[token & hr_dev->cmd.token_mask];
> +
> +	if (token !=3D context->token)
> +		return;
> +
> +	context->result =3D hns_roce_status_to_errno(status);
> +	context->out_param =3D out_param;
> +	complete(&context->done);
> +}
> +
>  int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
>  {
>  	struct device *dev =3D &hr_dev->pdev->dev;
> diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infini=
band/hw/hns/hns_roce_common.h
> index 595cda9..4805852 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_common.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_common.h
> @@ -33,7 +33,56 @@
>  #ifndef _HNS_ROCE_COMMON_H
>  #define _HNS_ROCE_COMMON_H
> =20
> +#define roce_write(dev, reg, val)	writel((val), (dev)->reg_base + (reg))
>  #define roce_read(dev, reg)		readl((dev)->reg_base + (reg))
> +#define roce_raw_write(value, addr) \
> +	__raw_writel((__force u32)cpu_to_le32(value), (addr))
> +
> +#define roce_get_field(origin, mask, shift) \
> +	(((origin) & (mask)) >> (shift))
> +
> +#define roce_get_bit(origin, shift) \
> +	roce_get_field((origin), (1ul << (shift)), (shift))
> +
> +#define roce_set_field(origin, mask, shift, val) \
> +	do { \
> +		(origin) &=3D (~(mask)); \
> +		(origin) |=3D (((u32)(val) << (shift)) & (mask)); \
> +	} while (0)
> +
> +#define roce_set_bit(origin, shift, val) \
> +	roce_set_field((origin), (1ul << (shift)), (shift), (val))
> +
> +#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S 0
> +#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M   \
> +	(((1UL << 2) - 1) << ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S)
> +
> +#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_S 8
> +#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_M   \
> +	(((1UL << 4) - 1) << ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_S)
> +
> +#define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQ_ALM_OVF_INT_ST_S 17
> +
> +#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_S 0
> +#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_M   \
> +	(((1UL << 5) - 1) << ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_S)
> +
> +#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_S 16
> +#define ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_M   \
> +	(((1UL << 16) - 1) << ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_S)
> +
> +#define ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_S 0
> +#define ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_M   \
> +	(((1UL << 16) - 1) << ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_S)
> +
> +#define ROCEE_CAEP_CEQC_SHIFT_CAEP_CEQ_ALM_OVF_INT_ST_S 16
> +#define ROCEE_CAEP_CE_IRQ_MASK_CAEP_CEQ_ALM_OVF_MASK_S 1
> +#define ROCEE_CAEP_CEQ_ALM_OVF_CAEP_CEQ_ALM_OVF_S 0
> +
> +#define ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S 0
> +#define ROCEE_CAEP_AE_MASK_CAEP_AE_IRQ_MASK_S 1
> +
> +#define ROCEE_CAEP_AE_ST_CAEP_AEQ_ALM_OVF_S 0
> =20
>  /*************ROCEE_REG DEFINITION****************/
>  #define ROCEE_VENDOR_ID_REG			0x0
> @@ -44,8 +93,29 @@
>  #define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
>  #define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
> =20
> +#define ROCEE_CAEP_AEQE_CONS_IDX_REG		0x3AC
> +#define ROCEE_CAEP_CEQC_CONS_IDX_0_REG		0x3BC
> +
> +#define ROCEE_ECC_UCERR_ALM1_REG		0xB38
> +#define ROCEE_ECC_UCERR_ALM2_REG		0xB3C
> +#define ROCEE_ECC_CERR_ALM1_REG			0xB44
> +#define ROCEE_ECC_CERR_ALM2_REG			0xB48
> +
>  #define ROCEE_ACK_DELAY_REG			0x14
> =20
> +#define ROCEE_CAEP_CE_INTERVAL_CFG_REG		0x190
> +#define ROCEE_CAEP_CE_BURST_NUM_CFG_REG		0x194
> +
>  #define ROCEE_MB1_REG				0x210
> =20
> +#define ROCEE_CAEP_AEQC_AEQE_SHIFT_REG		0x3A0
> +#define ROCEE_CAEP_CEQC_SHIFT_0_REG		0x3B0
> +#define ROCEE_CAEP_CE_IRQ_MASK_0_REG		0x3C0
> +#define ROCEE_CAEP_CEQ_ALM_OVF_0_REG		0x3C4
> +#define ROCEE_CAEP_AE_MASK_REG			0x6C8
> +#define ROCEE_CAEP_AE_ST_REG			0x6CC
> +
> +#define ROCEE_ECC_UCERR_ALM0_REG		0xB34
> +#define ROCEE_ECC_CERR_ALM0_REG			0xB40

Indentation

> +
>  #endif /* _HNS_ROCE_COMMON_H */
> diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband=
/hw/hns/hns_roce_cq.c
> new file mode 100644
> index 0000000..42a3c98
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
> @@ -0,0 +1,77 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
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
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include <linux/hardirq.h>
> +#include <linux/log2.h>
> +#include <linux/slab.h>
> +#include "hns_roce_device.h"
> +
> +void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_cq *cq;
> +
> +	cq =3D radix_tree_lookup(&hr_dev->cq_table.tree,
> +			       cqn & (hr_dev->caps.num_cqs - 1));
> +	if (!cq) {
> +		dev_warn(dev, "Completion event for bogus CQ 0x%08x\n", cqn);
> +		return;
> +	}
> +
> +	cq->comp(cq);
> +}
> +
> +void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_t=
ype)
> +{
> +	struct hns_roce_cq_table *cq_table =3D &hr_dev->cq_table;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_cq *cq;
> +
> +	spin_lock(&cq_table->lock);

What exactly do you protect here with lock?
radix_tree_lookup? Why didn't you protect it in hns_roce_cq_completion
function?

> +
> +	cq =3D radix_tree_lookup(&cq_table->tree,
> +			       cqn & (hr_dev->caps.num_cqs - 1));
> +	if (cq)
> +		atomic_inc(&cq->refcount);
> +
> +	spin_unlock(&cq_table->lock);
> +
> +	if (!cq) {
> +		dev_warn(dev, "Async event for bogus CQ %08x\n", cqn);
> +		return;
> +	}
> +
> +	cq->event(cq, (enum hns_roce_event)event_type);
> +
> +	if (atomic_dec_and_test(&cq->refcount))
> +		complete(&cq->free);
> +}
> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infini=
band/hw/hns/hns_roce_device.h
> index 23b7e17..57184ab 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_device.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
> @@ -44,6 +44,8 @@
> =20
>  #define DRV_NAME "hns_roce"
> =20
> +#define HNS_ROCE_BA_SIZE			(32 * 4096)
> +
>  #define HNS_ROCE_MAX_IRQ_NUM			34
> =20
>  #define HNS_ROCE_COMP_VEC_NUM			32
> @@ -53,8 +55,89 @@
> =20
>  #define HNS_ROCE_MAX_PORTS			6
> =20
> +enum hns_roce_event {
> +	HNS_ROCE_EVENT_TYPE_PATH_MIG                  =3D 0x01,
> +	HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED           =3D 0x02,
> +	HNS_ROCE_EVENT_TYPE_COMM_EST                  =3D 0x03,
> +	HNS_ROCE_EVENT_TYPE_SQ_DRAINED                =3D 0x04,
> +	HNS_ROCE_EVENT_TYPE_WQ_CATAS_ERROR            =3D 0x05,
> +	HNS_ROCE_EVENT_TYPE_INV_REQ_LOCAL_WQ_ERROR    =3D 0x06,
> +	HNS_ROCE_EVENT_TYPE_LOCAL_WQ_ACCESS_ERROR     =3D 0x07,
> +	HNS_ROCE_EVENT_TYPE_SRQ_LIMIT_REACH           =3D 0x08,
> +	HNS_ROCE_EVENT_TYPE_SRQ_LAST_WQE_REACH        =3D 0x09,
> +	HNS_ROCE_EVENT_TYPE_SRQ_CATAS_ERROR           =3D 0x0a,
> +	HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR           =3D 0x0b,
> +	HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW               =3D 0x0c,
> +	HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID             =3D 0x0d,
> +	HNS_ROCE_EVENT_TYPE_PORT_CHANGE               =3D 0x0f,

Please add comment here that 0x10 and 0x11 were skipped on purpose.

> +	HNS_ROCE_EVENT_TYPE_DB_OVERFLOW               =3D 0x12,
> +	HNS_ROCE_EVENT_TYPE_MB                        =3D 0x13,
> +	HNS_ROCE_EVENT_TYPE_CEQ_OVERFLOW              =3D 0x14,
> +};
> +
> +/* Local Work Queue Catastrophic Error,SUBTYPE 0x5 */
> +enum {
> +	HNS_ROCE_LWQCE_QPC_ERROR		=3D 1,
> +	HNS_ROCE_LWQCE_MTU_ERROR		=3D 2,
> +	HNS_ROCE_LWQCE_WQE_BA_ADDR_ERROR	=3D 3,
> +	HNS_ROCE_LWQCE_WQE_ADDR_ERROR		=3D 4,
> +	HNS_ROCE_LWQCE_SQ_WQE_SHIFT_ERROR	=3D 5,
> +	HNS_ROCE_LWQCE_SL_ERROR			=3D 6,
> +	HNS_ROCE_LWQCE_PORT_ERROR		=3D 7,
> +};
> +
> +/* Local Access Violation Work Queue Error,SUBTYPE 0x7 */
> +enum {
> +	HNS_ROCE_LAVWQE_R_KEY_VIOLATION		=3D 1,
> +	HNS_ROCE_LAVWQE_LENGTH_ERROR		=3D 2,
> +	HNS_ROCE_LAVWQE_VA_ERROR		=3D 3,
> +	HNS_ROCE_LAVWQE_PD_ERROR		=3D 4,
> +	HNS_ROCE_LAVWQE_RW_ACC_ERROR		=3D 5,
> +	HNS_ROCE_LAVWQE_KEY_STATE_ERROR		=3D 6,
> +	HNS_ROCE_LAVWQE_MR_OPERATION_ERROR	=3D 7,
> +};
> +
> +/* DOORBELL overflow subtype */
> +enum {
> +	HNS_ROCE_DB_SUBTYPE_SDB_OVF		=3D 1,
> +	HNS_ROCE_DB_SUBTYPE_SDB_ALM_OVF		=3D 2,
> +	HNS_ROCE_DB_SUBTYPE_ODB_OVF		=3D 3,
> +	HNS_ROCE_DB_SUBTYPE_ODB_ALM_OVF		=3D 4,
> +	HNS_ROCE_DB_SUBTYPE_SDB_ALM_EMP		=3D 5,
> +	HNS_ROCE_DB_SUBTYPE_ODB_ALM_EMP		=3D 6,
> +};
> +
> +enum {
> +	HNS_ROCE_CMD_SUCCESS			=3D 1,
> +};
> +
> +struct hns_roce_buf_list {
> +	void		*buf;
> +	dma_addr_t	map;
> +};
> +
> +struct hns_roce_cq {
> +	void (*comp)(struct hns_roce_cq *);
> +	void (*event)(struct hns_roce_cq *, enum hns_roce_event);
> +
> +	atomic_t			refcount;
> +	struct completion		free;
> +};
> +
> +struct hns_roce_qp_table {
> +	spinlock_t			lock;
> +};
> +
> +struct hns_roce_cq_table {
> +	spinlock_t			lock;
> +	struct radix_tree_root		tree;
> +};
> +
>  struct hns_roce_cmd_context {
> +	struct completion	done;
> +	int			result;
>  	int			next;
> +	u64			out_param;
>  	u16			token;
>  };
> =20
> @@ -87,11 +170,42 @@ struct hns_roce_cmdq {
>  	u8			toggle;
>  };
> =20
> +struct hns_roce_dev;
> +
> +struct hns_roce_qp {
> +	void			(*event)(struct hns_roce_qp *,
> +					 enum hns_roce_event);
> +
> +	atomic_t		refcount;
> +	struct completion	free;
> +};
> +
>  struct hns_roce_ib_iboe {
>  	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
>  	u8			phy_port[HNS_ROCE_MAX_PORTS];
>  };
> =20
> +struct hns_roce_eq {
> +	struct hns_roce_dev		*hr_dev;
> +	void __iomem			*doorbell;
> +
> +	int				type_flag;/* Aeq:1 ceq:0 */
> +	int				eqn;
> +	u32				entries;
> +	int				log_entries;
> +	int				eqe_size;
> +	int				irq;
> +	u16				have_irq;
> +	int				log_page_size;
> +	int				cons_index;
> +	struct hns_roce_buf_list	*buf_list;
> +};
> +
> +struct hns_roce_eq_table {
> +	struct hns_roce_eq	*eq;
> +	void __iomem		**eqc_base;
> +};
> +
>  struct hns_roce_caps {
>  	u64		fw_ver;
>  	u8		num_ports;
> @@ -150,6 +264,7 @@ struct hns_roce_dev {
>  	int			irq[HNS_ROCE_MAX_IRQ_NUM];
>  	u8 __iomem		*reg_base;
>  	struct hns_roce_caps	caps;
> +	struct radix_tree_root  qp_table_tree;
> =20
>  	u64                     fw_ver;
>  	u64			sys_image_guid;
> @@ -158,17 +273,37 @@ struct hns_roce_dev {
>  	u32                     hw_rev;
> =20
>  	struct hns_roce_cmdq	cmd;
> +	struct hns_roce_cq_table  cq_table;
> +	struct hns_roce_qp_table  qp_table;
> +	struct hns_roce_eq_table  eq_table;
> =20
>  	int			cmd_mod;
>  	int			loop_idc;
>  	struct hns_roce_hw	*hw;
>  };
> =20
> +static inline struct hns_roce_qp
> +	*__hns_roce_qp_lookup(struct hns_roce_dev *hr_dev, u32 qpn)
> +{
> +	return radix_tree_lookup(&hr_dev->qp_table_tree,
> +				 qpn & (hr_dev->caps.num_qps - 1));
> +}
> +
>  int hns_roce_cmd_init(struct hns_roce_dev *hr_dev);
>  void hns_roce_cmd_cleanup(struct hns_roce_dev *hr_dev);
> +void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 statu=
s,
> +			u64 out_param);

Please fix indentation.

>  int hns_roce_cmd_use_events(struct hns_roce_dev *hr_dev);
>  void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev);
> =20
> +int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev);
> +
> +void hns_roce_cleanup_eq_table(struct hns_roce_dev *hr_dev);
> +
> +void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
> +void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_t=
ype);
> +void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_t=
ype);
> +
>  extern struct hns_roce_hw hns_roce_hw_v1;
> =20
>  #endif /* _HNS_ROCE_DEVICE_H */
> diff --git a/drivers/infiniband/hw/hns/hns_roce_eq.c b/drivers/infiniband=
/hw/hns/hns_roce_eq.c
> new file mode 100644
> index 0000000..6600a23
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_eq.c
> @@ -0,0 +1,750 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
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
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include <linux/dma-mapping.h>
> +#include <linux/init.h>
> +#include <linux/interrupt.h>
> +#include <linux/slab.h>
> +#include "hns_roce_common.h"
> +#include "hns_roce_device.h"
> +#include "hns_roce_eq.h"
> +
> +static void eq_set_cons_index(struct hns_roce_eq *eq, int req_not)
> +{
> +	roce_raw_write((eq->cons_index & CONS_INDEX_MASK) |
> +		      (req_not << eq->log_entries), eq->doorbell);
> +	/* Memory barrier */
> +	mb();
> +}
> +
> +static struct hns_roce_aeqe *get_aeqe(struct hns_roce_eq *eq, u32 entry)
> +{
> +	unsigned long off =3D (entry & (eq->entries - 1)) *
> +			     HNS_ROCE_AEQ_ENTRY_SIZE;
> +
> +	return (struct hns_roce_aeqe *)((u8 *)
> +		(eq->buf_list[off / HNS_ROCE_BA_SIZE].buf) +
> +		off % HNS_ROCE_BA_SIZE);
> +}
> +
> +static struct hns_roce_aeqe *next_aeqe_sw(struct hns_roce_eq *eq)
> +{
> +	struct hns_roce_aeqe *aeqe =3D get_aeqe(eq, eq->cons_index);
> +
> +	return (roce_get_bit(aeqe->asyn, HNS_ROCE_AEQE_U32_4_OWNER_S) ^
> +		!!(eq->cons_index & eq->entries)) ? aeqe : NULL;
> +}
> +
> +static int hns_roce_aeq_int(struct hns_roce_dev *hr_dev, struct hns_roce=
_eq *eq)

Please refactor this function. It has switch in switch and it is almost 200=
 LOCs.

> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_aeqe *aeqe;
> +	int aeqes_found =3D 0;
> +	int qpn =3D 0;
> +
> +	while ((aeqe =3D next_aeqe_sw(eq))) {
> +		dev_dbg(dev, "aeqe =3D %p, aeqe->asyn.event_type =3D 0x%lx\n", aeqe,
> +			roce_get_field(aeqe->asyn,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
> +		/* Memory barrier */
> +		rmb();
> +
> +		switch (roce_get_field(aeqe->asyn,
> +			HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +			HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S)) {
> +		case HNS_ROCE_EVENT_TYPE_PATH_MIG:
> +			dev_warn(dev, "PATH MIG not supported\n");
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_COMM_EST:
> +			dev_warn(dev, "COMMUNICATION ESTABLISHED\n");

CAPSLOCK????

> +			break;
> +		case HNS_ROCE_EVENT_TYPE_SQ_DRAINED:
> +			dev_warn(dev, "SQ DRAINED not supported\n");
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED:
> +			dev_warn(dev, "PATH MIG FAILED\n");
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_INV_REQ_LOCAL_WQ_ERROR:
> +			dev_warn(dev, "qpn =3D 0x%lx\n",
> +			roce_get_field(aeqe->event.qp_event.qp,
> +				       HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
> +				       HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S));
> +			hns_roce_qp_event(hr_dev,
> +				roce_get_field(aeqe->event.qp_event.qp,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S),
> +				roce_get_field(aeqe->asyn,
> +					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_WQ_CATAS_ERROR:
> +			qpn =3D roce_get_field(aeqe->event.qp_event.qp,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S);
> +			dev_warn(dev, "Local Work Queue Catastrophic Error.\n");
> +			switch (roce_get_field(aeqe->asyn,
> +					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M,
> +					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)) {
> +			case HNS_ROCE_LWQCE_QPC_ERROR:
> +				dev_warn(dev, "QP %d, QPC error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LWQCE_MTU_ERROR:
> +				dev_warn(dev, "QP %d, MTU error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LWQCE_WQE_BA_ADDR_ERROR:
> +				dev_warn(dev, "QP %d, WQE BA addr error.\n",
> +					 qpn);
> +				break;
> +			case HNS_ROCE_LWQCE_WQE_ADDR_ERROR:
> +				dev_warn(dev, "QP %d, WQE addr error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LWQCE_SQ_WQE_SHIFT_ERROR:
> +				dev_warn(dev, "QP %d, WQE shift error\n", qpn);
> +				break;
> +			case HNS_ROCE_LWQCE_SL_ERROR:
> +				dev_warn(dev, "QP %d, SL error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LWQCE_PORT_ERROR:
> +				dev_warn(dev, "QP %d, port error.\n", qpn);
> +				break;
> +			default:
> +				break;
> +			}
> +
> +			hns_roce_qp_event(hr_dev,
> +				roce_get_field(aeqe->event.qp_event.qp,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S),
> +				roce_get_field(aeqe->asyn,
> +					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_LOCAL_WQ_ACCESS_ERROR:
> +			qpn =3D roce_get_field(aeqe->event.qp_event.qp,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S);
> +			dev_warn(dev, "Local Access Violation Work Queue Error.\n");
> +			switch (roce_get_field(aeqe->asyn,
> +					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M,
> +					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)) {
> +			case HNS_ROCE_LAVWQE_R_KEY_VIOLATION:
> +				dev_warn(dev, "QP %d, R_key violation.\n", qpn);
> +				break;
> +			case HNS_ROCE_LAVWQE_LENGTH_ERROR:
> +				dev_warn(dev, "QP %d, length error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LAVWQE_VA_ERROR:
> +				dev_warn(dev, "QP %d, VA error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LAVWQE_PD_ERROR:
> +				dev_err(dev, "QP %d, PD error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LAVWQE_RW_ACC_ERROR:
> +				dev_warn(dev, "QP %d, rw acc error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LAVWQE_KEY_STATE_ERROR:
> +				dev_warn(dev, "QP %d, key state error.\n", qpn);
> +				break;
> +			case HNS_ROCE_LAVWQE_MR_OPERATION_ERROR:
> +				dev_warn(dev, "QP %d, MR operation error.\n",
> +					 qpn);
> +				break;
> +			default:
> +				break;
> +			}
> +
> +			hns_roce_qp_event(hr_dev,
> +				roce_get_field(aeqe->event.qp_event.qp,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M,
> +					HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S),
> +				roce_get_field(aeqe->asyn,
> +					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +					HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_SRQ_LIMIT_REACH:
> +		case HNS_ROCE_EVENT_TYPE_SRQ_CATAS_ERROR:
> +		case HNS_ROCE_EVENT_TYPE_SRQ_LAST_WQE_REACH:
> +			dev_warn(dev, "SRQ not support!\n");
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR:
> +			dev_warn(dev, "CQ 0x%lx access err.\n",
> +			roce_get_field(aeqe->event.cq_event.cq,
> +				       HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
> +				       HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S));
> +			hns_roce_cq_event(hr_dev,
> +			le32_to_cpu(roce_get_field(aeqe->event.cq_event.cq,
> +				    HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
> +				    HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)),
> +			roce_get_field(aeqe->asyn,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW:
> +			dev_warn(dev, "CQ 0x%lx overflow\n",
> +			roce_get_field(aeqe->event.cq_event.cq,
> +				       HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
> +				       HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S));
> +			hns_roce_cq_event(hr_dev,
> +			le32_to_cpu(roce_get_field(aeqe->event.cq_event.cq,
> +				    HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
> +				    HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)),
> +			roce_get_field(aeqe->asyn,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID:
> +			dev_warn(dev, "CQ ID invalid.\n");
> +			hns_roce_cq_event(hr_dev,
> +			le32_to_cpu(roce_get_field(aeqe->event.cq_event.cq,
> +				    HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M,
> +				    HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)),
> +			roce_get_field(aeqe->asyn,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +				       HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S));
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_PORT_CHANGE:
> +			dev_warn(dev, "port change.\n");
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_MB:
> +			hns_roce_cmd_event(hr_dev,
> +					   le16_to_cpu(aeqe->event.cmd.token),
> +					   aeqe->event.cmd.status,
> +					   le64_to_cpu(aeqe->event.cmd.out_param
> +					   ));
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_DB_OVERFLOW:
> +			switch (roce_get_field(aeqe->asyn,
> +					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M,
> +					HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)) {
> +			case HNS_ROCE_DB_SUBTYPE_SDB_OVF:
> +				dev_warn(dev, "SDB overflow.\n");
> +				break;
> +			case HNS_ROCE_DB_SUBTYPE_SDB_ALM_OVF:
> +				dev_warn(dev, "SDB almost overflow.\n");
> +				break;
> +			case HNS_ROCE_DB_SUBTYPE_SDB_ALM_EMP:
> +				dev_warn(dev, "SDB almost empty.\n");
> +				break;
> +			case HNS_ROCE_DB_SUBTYPE_ODB_OVF:
> +				dev_warn(dev, "ODB overflow.\n");
> +				break;
> +			case HNS_ROCE_DB_SUBTYPE_ODB_ALM_OVF:
> +				dev_warn(dev, "ODB almost overflow.\n");
> +				break;
> +			case HNS_ROCE_DB_SUBTYPE_ODB_ALM_EMP:
> +				dev_warn(dev, "SDB almost empty.\n");
> +				break;
> +			default:
> +				break;
> +			}
> +
> +			break;
> +		case HNS_ROCE_EVENT_TYPE_CEQ_OVERFLOW:
> +			dev_warn(dev, "CEQ 0x%lx OVERFLOW EVENT.\n",
> +			roce_get_field(aeqe->event.ce_event.ceqe,
> +				HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_M,
> +				HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_S));
> +			break;
> +		default:
> +			dev_warn(dev, "Unhandled event 0x%lx on EQ %d at index %u\n",
> +				 roce_get_field(aeqe->asyn,
> +					      HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M,
> +					      HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S),
> +				 eq->eqn, eq->cons_index);
> +			break;
> +		};
> +
> +		eq->cons_index++;
> +		aeqes_found =3D 1;
> +
> +		if (eq->cons_index > 2 * hr_dev->caps.aeqe_depth - 1) {
> +			dev_warn(dev, "cons_index overflow, set back to zero\n"
> +				);
> +			eq->cons_index =3D 0;
> +		}
> +	}
> +
> +	eq_set_cons_index(eq, 0);
> +
> +	return aeqes_found;
> +}
> +
> +static struct hns_roce_ceqe *get_ceqe(struct hns_roce_eq *eq, u32 entry)
> +{
> +	unsigned long off =3D (entry & (eq->entries - 1)) *
> +			     HNS_ROCE_CEQ_ENTRY_SIZE;
> +
> +	return (struct hns_roce_ceqe *)((u8 *)
> +			(eq->buf_list[off / HNS_ROCE_BA_SIZE].buf) +
> +			off % HNS_ROCE_BA_SIZE);
> +}
> +
> +static struct hns_roce_ceqe *next_ceqe_sw(struct hns_roce_eq *eq)
> +{
> +	struct hns_roce_ceqe *ceqe =3D get_ceqe(eq, eq->cons_index);
> +
> +	return (!!(roce_get_bit(ceqe->ceqe.comp,
> +		 HNS_ROCE_CEQE_CEQE_COMP_OWNER_S))) ^
> +		 (!!(eq->cons_index & eq->entries)) ? ceqe : NULL;
> +}
> +
> +static int hns_roce_ceq_int(struct hns_roce_dev *hr_dev, struct hns_roce=
_eq *eq)
> +{
> +	struct hns_roce_ceqe *ceqe;
> +	int ceqes_found =3D 0;
> +	u32 cqn;
> +
> +	while ((ceqe =3D next_ceqe_sw(eq))) {
> +		/* Memory barrier */
> +		rmb();
> +		cqn =3D roce_get_field(ceqe->ceqe.comp,
> +				     HNS_ROCE_CEQE_CEQE_COMP_CQN_M,
> +				     HNS_ROCE_CEQE_CEQE_COMP_CQN_S);
> +		hns_roce_cq_completion(hr_dev, cqn);
> +
> +		++eq->cons_index;
> +		ceqes_found =3D 1;
> +
> +		if (eq->cons_index > 2 * hr_dev->caps.ceqe_depth[eq->eqn] - 1) {
> +			dev_warn(&eq->hr_dev->pdev->dev,
> +				"cons_index overflow, set back to zero\n");
> +			eq->cons_index =3D 0;
> +		}
> +	}
> +
> +	eq_set_cons_index(eq, 0);
> +
> +	return ceqes_found;
> +}
> +
> +static int hns_roce_aeq_ovf_int(struct hns_roce_dev *hr_dev,
> +				struct hns_roce_eq *eq)
> +{
> +	struct device *dev =3D &eq->hr_dev->pdev->dev;
> +	int eqovf_found =3D 0;
> +	u32 caepaemask_val;
> +	u32 cealmovf_val;
> +	u32 caepaest_val;
> +	u32 aeshift_val;
> +	u32 ceshift_val;
> +	u32 cemask_val;
> +	int i =3D 0;
> +
> +	/**
> +	* AEQ overflow ECC mult bit err CEQ overflow alarm
> +	* must clear interrupt, mask irq, clear irq, cancel mask operation
> +	*/
> +	aeshift_val =3D roce_read(hr_dev, ROCEE_CAEP_AEQC_AEQE_SHIFT_REG);
> +
> +	if (roce_get_bit(aeshift_val,
> +		ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQ_ALM_OVF_INT_ST_S) =3D=3D 1) {
> +		dev_warn(dev, "AEQ overflow!\n");
> +
> +		/* Set mask */
> +		caepaemask_val =3D roce_read(hr_dev, ROCEE_CAEP_AE_MASK_REG);
> +		roce_set_bit(caepaemask_val,
> +			     ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S,
> +			     HNS_ROCE_INT_MASK_ENABLE);
> +		roce_write(hr_dev, ROCEE_CAEP_AE_MASK_REG, caepaemask_val);
> +
> +		/* Clear int state(INT_WC : write 1 clear) */
> +		caepaest_val =3D roce_read(hr_dev, ROCEE_CAEP_AE_ST_REG);
> +		roce_set_bit(caepaest_val,
> +			     ROCEE_CAEP_AE_ST_CAEP_AEQ_ALM_OVF_S, 1);
> +		roce_write(hr_dev, ROCEE_CAEP_AE_ST_REG, caepaest_val);
> +
> +		/* Clear mask */
> +		caepaemask_val =3D roce_read(hr_dev, ROCEE_CAEP_AE_MASK_REG);
> +		roce_set_bit(caepaemask_val,
> +			     ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S,
> +			     HNS_ROCE_INT_MASK_DISABLE);
> +		roce_write(hr_dev, ROCEE_CAEP_AE_MASK_REG, caepaemask_val);
> +	}
> +
> +	/* CEQ almost overflow */
> +	for (i =3D 0; i < hr_dev->caps.num_comp_vectors; i++) {
> +		ceshift_val =3D roce_read(hr_dev, ROCEE_CAEP_CEQC_SHIFT_0_REG +
> +					i * CEQ_REG_OFFSET);
> +
> +		if (roce_get_bit(ceshift_val,
> +		ROCEE_CAEP_CEQC_SHIFT_CAEP_CEQ_ALM_OVF_INT_ST_S) =3D=3D 1) {
> +			dev_warn(dev, "CEQ[%d] almost overflow!\n", i);
> +			eqovf_found++;
> +
> +			/* Set mask */
> +			cemask_val =3D roce_read(hr_dev,
> +					       ROCEE_CAEP_CE_IRQ_MASK_0_REG +
> +					       i * CEQ_REG_OFFSET);
> +			roce_set_bit(cemask_val,
> +				ROCEE_CAEP_CE_IRQ_MASK_CAEP_CEQ_ALM_OVF_MASK_S,
> +				HNS_ROCE_INT_MASK_ENABLE);
> +			roce_write(hr_dev, ROCEE_CAEP_CE_IRQ_MASK_0_REG +
> +				   i * CEQ_REG_OFFSET, cemask_val);
> +
> +			/* Clear int state(INT_WC : write 1 clear) */
> +			cealmovf_val =3D roce_read(hr_dev,
> +				       ROCEE_CAEP_CEQ_ALM_OVF_0_REG +
> +				       i * CEQ_REG_OFFSET);
> +			roce_set_bit(cealmovf_val,
> +				     ROCEE_CAEP_CEQ_ALM_OVF_CAEP_CEQ_ALM_OVF_S,
> +				     1);
> +			roce_write(hr_dev, ROCEE_CAEP_CEQ_ALM_OVF_0_REG +
> +				    i * CEQ_REG_OFFSET, cealmovf_val);
> +
> +			/* Clear mask */
> +			cemask_val =3D roce_read(hr_dev,
> +				     ROCEE_CAEP_CE_IRQ_MASK_0_REG +
> +				     i * CEQ_REG_OFFSET);
> +			roce_set_bit(cemask_val,
> +			       ROCEE_CAEP_CE_IRQ_MASK_CAEP_CEQ_ALM_OVF_MASK_S,
> +			       HNS_ROCE_INT_MASK_DISABLE);
> +			roce_write(hr_dev, ROCEE_CAEP_CE_IRQ_MASK_0_REG +
> +				   i * CEQ_REG_OFFSET, cemask_val);
> +		}
> +	}
> +
> +	/* ECC multi-bit error alarm */
> +	dev_warn(dev, "ECC UCERR ALARM: 0x%x, 0x%x, 0x%x\n",
> +		 roce_read(hr_dev, ROCEE_ECC_UCERR_ALM0_REG),
> +		 roce_read(hr_dev, ROCEE_ECC_UCERR_ALM1_REG),
> +		 roce_read(hr_dev, ROCEE_ECC_UCERR_ALM2_REG));
> +
> +	dev_warn(dev, "ECC CERR ALARM: 0x%x, 0x%x, 0x%x\n",
> +		 roce_read(hr_dev, ROCEE_ECC_CERR_ALM0_REG),
> +		 roce_read(hr_dev, ROCEE_ECC_CERR_ALM1_REG),
> +		 roce_read(hr_dev, ROCEE_ECC_CERR_ALM2_REG));
> +
> +	return eqovf_found;
> +}
> +
> +static int hns_roce_eq_int(struct hns_roce_dev *hr_dev, struct hns_roce_=
eq *eq)
> +{
> +	int eqes_found =3D 0;
> +
> +	if (likely(eq->type_flag =3D=3D HNS_ROCE_CEQ))
> +		/* CEQ irq routine, CEQ is pulse irq, not clear */
> +		eqes_found =3D hns_roce_ceq_int(hr_dev, eq);
> +	else if (likely(eq->type_flag =3D=3D HNS_ROCE_AEQ))
> +		/* AEQ irq routine, AEQ is pulse irq, not clear */
> +		eqes_found =3D hns_roce_aeq_int(hr_dev, eq);
> +	else
> +		/* AEQ queue overflow irq */
> +		eqes_found =3D hns_roce_aeq_ovf_int(hr_dev, eq);
> +
> +	return eqes_found;
> +}
> +
> +static irqreturn_t hns_roce_msi_x_interrupt(int irq, void *eq_ptr)
> +{
> +	int int_work =3D 0;
> +	struct hns_roce_eq  *eq  =3D eq_ptr;
> +	struct hns_roce_dev *hr_dev =3D eq->hr_dev;
> +
> +	int_work =3D hns_roce_eq_int(hr_dev, eq);
> +
> +	return IRQ_RETVAL(int_work);
> +}
> +
> +static void hns_roce_enable_eq(struct hns_roce_dev *hr_dev, int eq_num,
> +			       int enable_flag)
> +{
> +	void __iomem *eqc =3D hr_dev->eq_table.eqc_base[eq_num];
> +	u32 val;
> +
> +	val =3D readl(eqc);
> +
> +	if (enable_flag)
> +		roce_set_field(val,
> +			       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M,
> +			       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S,
> +			       HNS_ROCE_EQ_STAT_VALID);
> +	else
> +		roce_set_field(val,
> +			       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M,
> +			       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S,
> +			       HNS_ROCE_EQ_STAT_INVALID);
> +	writel(val, eqc);
> +}
> +
> +static int hns_roce_create_eq(struct hns_roce_dev *hr_dev,
> +			      struct hns_roce_eq *eq)
> +{
> +	void __iomem *eqc =3D hr_dev->eq_table.eqc_base[eq->eqn];
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	dma_addr_t tmp_dma_addr;
> +	u32 eqconsindx_val =3D 0;
> +	u32 eqcuridx_val =3D 0;
> +	u32 eqshift_val =3D 0;
> +	int num_bas =3D 0;
> +	int ret;
> +	int i;
> +
> +	num_bas =3D (PAGE_ALIGN(eq->entries * eq->eqe_size) +
> +		   HNS_ROCE_BA_SIZE - 1) / HNS_ROCE_BA_SIZE;
> +
> +	if ((eq->entries * eq->eqe_size) > HNS_ROCE_BA_SIZE) {
> +		dev_err(dev, "[error]eq buf %d gt ba size(%d) need bas=3D%d\n",
> +			(eq->entries * eq->eqe_size), HNS_ROCE_BA_SIZE,
> +			num_bas);
> +		return -EINVAL;
> +	}
> +
> +	eq->buf_list =3D kcalloc(num_bas, sizeof(*eq->buf_list), GFP_KERNEL);
> +	if (!eq->buf_list)
> +		return -ENOMEM;
> +
> +	for (i =3D 0; i < num_bas; ++i) {
> +		eq->buf_list[i].buf =3D dma_alloc_coherent(dev, HNS_ROCE_BA_SIZE,
> +							 &tmp_dma_addr,
> +							 GFP_KERNEL);
> +		if (!eq->buf_list[i].buf) {
> +			ret =3D -ENOMEM;
> +			goto err_out_free_pages;
> +		}
> +
> +		eq->buf_list[i].map =3D tmp_dma_addr;
> +		memset(eq->buf_list[i].buf, 0, HNS_ROCE_BA_SIZE);
> +	}
> +	eq->cons_index =3D 0;
> +	roce_set_field(eqshift_val,
> +		       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M,
> +		       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S,
> +		       HNS_ROCE_EQ_STAT_INVALID);
> +	roce_set_field(eqshift_val,
> +		       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_M,
> +		       ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_AEQE_SHIFT_S,
> +		       eq->log_entries);
> +	writel(eqshift_val, eqc);
> +
> +	/* Configure eq extended address 12~44bit */
> +	writel((u32)(eq->buf_list[0].map >> 12), (u8 *)eqc + 4);
> +
> +	/*
> +	 * Configure eq extended address 45~49 bit.
> +	 * 44 =3D 32 + 12, When evaluating addr to hardware, shift 12 because of
> +	 * using 4K page, and shift more 32 because of
> +	 * caculating the high 32 bit value evaluated to hardware.
> +	 */
> +	roce_set_field(eqcuridx_val, ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_M,
> +		       ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQ_BT_H_S,
> +		       eq->buf_list[0].map >> 44);
> +	roce_set_field(eqcuridx_val,
> +		       ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_M,
> +		       ROCEE_CAEP_AEQE_CUR_IDX_CAEP_AEQE_CUR_IDX_S, 0);
> +	writel(eqcuridx_val, (u8 *)eqc + 8);
> +
> +	/* Configure eq consumer index */
> +	roce_set_field(eqconsindx_val,
> +		       ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_M,
> +		       ROCEE_CAEP_AEQE_CONS_IDX_CAEP_AEQE_CONS_IDX_S, 0);
> +	writel(eqconsindx_val, (u8 *)eqc + 0xc);
> +
> +	return 0;
> +
> +err_out_free_pages:
> +	for (i =3D 0; i < num_bas; ++i)
> +		if (eq->buf_list[i].buf)

The two lines above can be replaced to something like this:

for ( i =3D i-1 ; i >=3D 0: i--) {

> +			dma_free_coherent(dev, HNS_ROCE_BA_SIZE,
> +					  eq->buf_list[i].buf,
> +					  eq->buf_list[i].map);
> +	kfree(eq->buf_list);
> +	return ret;
> +}
> +
> +static void hns_roce_free_eq(struct hns_roce_dev *hr_dev,
> +			     struct hns_roce_eq *eq)
> +{
> +	int i =3D 0;
> +	int npages =3D (PAGE_ALIGN(eq->eqe_size * eq->entries) +
> +		      HNS_ROCE_BA_SIZE - 1) / HNS_ROCE_BA_SIZE;
> +
> +	if (!eq->buf_list)
> +		return;
> +
> +	for (i =3D 0; i < npages; ++i)
> +		if (eq->buf_list[i].buf)

Is it possible situation to have eq->buf_list[i].buf =3D=3D NULL at the
middle of iteration?

> +			dma_free_coherent(&hr_dev->pdev->dev, HNS_ROCE_BA_SIZE,
> +					  eq->buf_list[i].buf,
> +					  eq->buf_list[i].map);
> +	kfree(eq->buf_list);
> +}
> +
> +static void hns_roce_int_mask_en(struct hns_roce_dev *hr_dev)
> +{
> +	int i =3D 0;
> +	u32 aemask_val;
> +	int masken =3D 0;
> +
> +	/* AEQ INT */
> +	aemask_val =3D roce_read(hr_dev, ROCEE_CAEP_AE_MASK_REG);
> +	roce_set_bit(aemask_val, ROCEE_CAEP_AE_MASK_CAEP_AEQ_ALM_OVF_MASK_S,
> +		     masken);
> +	roce_set_bit(aemask_val, ROCEE_CAEP_AE_MASK_CAEP_AE_IRQ_MASK_S, masken);
> +	roce_write(hr_dev, ROCEE_CAEP_AE_MASK_REG, aemask_val);
> +
> +	/* CEQ INT */
> +	for (i =3D 0; i < hr_dev->caps.num_comp_vectors; i++) {
> +		/* IRQ mask */
> +		roce_write(hr_dev, ROCEE_CAEP_CE_IRQ_MASK_0_REG +
> +			   i * CEQ_REG_OFFSET, masken);
> +	}
> +}
> +
> +static void hns_roce_ce_int_default_cfg(struct hns_roce_dev *hr_dev)
> +{
> +	/* Configure ce int interval */
> +	roce_write(hr_dev, ROCEE_CAEP_CE_INTERVAL_CFG_REG,
> +		   HNS_ROCE_CEQ_DEFAULT_INTERVAL);
> +
> +	/* Configure ce int burst num */
> +	roce_write(hr_dev, ROCEE_CAEP_CE_BURST_NUM_CFG_REG,
> +		   HNS_ROCE_CEQ_DEFAULT_BURST_NUM);
> +}
> +
> +int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev)
> +{
> +	struct hns_roce_eq_table *eq_table =3D &hr_dev->eq_table;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_eq *eq =3D NULL;
> +	int eq_num =3D 0;
> +	int ret =3D 0;
> +	int i =3D 0;
> +
> +	eq_num =3D hr_dev->caps.num_comp_vectors + hr_dev->caps.num_aeq_vectors;
> +	eq_table->eq =3D kcalloc(eq_num, sizeof(*eq_table->eq), GFP_KERNEL);
> +	if (!eq_table->eq)
> +		return -ENOMEM;
> +
> +	eq_table->eqc_base =3D kcalloc(eq_num, sizeof(*eq_table->eqc_base),
> +				     GFP_KERNEL);
> +	if (!eq_table->eqc_base) {
> +		ret =3D -ENOMEM;
> +		goto err_eqc_base_alloc_fail;
> +	}
> +
> +	for (i =3D 0; i < eq_num; i++) {
> +		eq =3D &eq_table->eq[i];
> +		eq->hr_dev =3D hr_dev;
> +		eq->eqn =3D i;
> +		eq->irq =3D hr_dev->irq[i];
> +		eq->log_page_size =3D PAGE_SHIFT;
> +
> +		if (i < hr_dev->caps.num_comp_vectors) {
> +			/* CEQ */
> +			eq_table->eqc_base[i] =3D hr_dev->reg_base +
> +						ROCEE_CAEP_CEQC_SHIFT_0_REG +
> +						HNS_ROCE_CEQC_REG_OFFSET * i;
> +			eq->type_flag =3D HNS_ROCE_CEQ;
> +			eq->doorbell =3D hr_dev->reg_base +
> +				       ROCEE_CAEP_CEQC_CONS_IDX_0_REG +
> +				       HNS_ROCE_CEQC_REG_OFFSET * i;
> +			eq->entries =3D hr_dev->caps.ceqe_depth[i];
> +			eq->log_entries =3D ilog2(eq->entries);
> +			eq->eqe_size =3D sizeof(struct hns_roce_ceqe);
> +		} else {
> +			/* AEQ */
> +			eq_table->eqc_base[i] =3D hr_dev->reg_base +
> +						ROCEE_CAEP_AEQC_AEQE_SHIFT_REG;
> +			eq->type_flag =3D HNS_ROCE_AEQ;
> +			eq->doorbell =3D hr_dev->reg_base +
> +				       ROCEE_CAEP_AEQE_CONS_IDX_REG;
> +			eq->entries =3D hr_dev->caps.aeqe_depth;
> +			eq->log_entries =3D ilog2(eq->entries);
> +			eq->eqe_size =3D sizeof(struct hns_roce_aeqe);
> +		}
> +	}
> +
> +	/* Disable irq */
> +	hns_roce_int_mask_en(hr_dev);
> +
> +	/* Configure CE irq interval and burst num */
> +	hns_roce_ce_int_default_cfg(hr_dev);
> +
> +	for (i =3D 0; i < eq_num; i++) {
> +		ret =3D hns_roce_create_eq(hr_dev, &eq_table->eq[i]);
> +		if (ret) {
> +			dev_err(dev, "eq create failed\n");
> +			goto err_create_eq_fail;
> +		}
> +
> +		ret =3D request_irq(eq_table->eq[i].irq, hns_roce_msi_x_interrupt,
> +				  0, hr_dev->irq_names, eq_table->eq + i);
> +		if (ret) {
> +			dev_err(dev, "request irq error!\n");
> +			goto err_create_eq_fail;
> +		}
> +
> +		eq_table->eq[i].have_irq =3D 1;
> +
> +		hns_roce_enable_eq(hr_dev, i, EQ_ENABLE);
> +	}
> +
> +	return 0;
> +
> +err_create_eq_fail:
> +	for (i =3D 0; i < eq_num; i++) {
> +		/* Disable EQ */
> +		hns_roce_enable_eq(hr_dev, i, EQ_DISABLE);
> +
> +		if (eq_table->eq[i].have_irq)
> +			free_irq(eq_table->eq[i].irq, eq_table->eq + i);
> +
> +		hns_roce_free_eq(hr_dev, &eq_table->eq[i]);
> +	}
> +	kfree(eq_table->eqc_base);
> +
> +err_eqc_base_alloc_fail:
> +	kfree(eq_table->eq);
> +	return ret;
> +}
> +
> +void hns_roce_cleanup_eq_table(struct hns_roce_dev *hr_dev)
> +{
> +	int i;
> +	int eq_num;
> +	struct hns_roce_eq_table *eq_table =3D &hr_dev->eq_table;
> +
> +	eq_num =3D hr_dev->caps.num_comp_vectors + hr_dev->caps.num_aeq_vectors;
> +	for (i =3D 0; i < eq_num; i++) {
> +		/* Disable EQ */
> +		hns_roce_enable_eq(hr_dev, i, EQ_DISABLE);
> +
> +		if (eq_table->eq[i].have_irq)
> +			free_irq(eq_table->eq[i].irq, eq_table->eq + i);
> +
> +		hns_roce_free_eq(hr_dev, &eq_table->eq[i]);
> +	}
> +
> +	kfree(eq_table->eqc_base);
> +	kfree(eq_table->eq);
> +}
> diff --git a/drivers/infiniband/hw/hns/hns_roce_eq.h b/drivers/infiniband=
/hw/hns/hns_roce_eq.h
> new file mode 100644
> index 0000000..99906e3
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_eq.h
> @@ -0,0 +1,130 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
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
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#ifndef _HNS_ROCE_EQ_H
> +#define _HNS_ROCE_EQ_H
> +
> +#define HNS_ROCE_CEQ			1
> +#define HNS_ROCE_AEQ			2
> +
> +#define	HNS_ROCE_CEQ_ENTRY_SIZE		0x4
> +#define	HNS_ROCE_AEQ_ENTRY_SIZE		0x10
> +#define	HNS_ROCE_CEQC_REG_OFFSET	0x18

Indentation

> +
> +#define HNS_ROCE_CEQ_DEFAULT_INTERVAL	0x10
> +#define HNS_ROCE_CEQ_DEFAULT_BURST_NUM	0x10
> +
> +#define	HNS_ROCE_INT_MASK_DISABLE	0
> +#define	HNS_ROCE_INT_MASK_ENABLE	1

Indentation

> +
> +#define EQ_ENABLE			1
> +#define EQ_DISABLE			0
> +#define CONS_INDEX_MASK			0xffff
> +
> +#define CEQ_REG_OFFSET			0x18
> +
> +enum {
> +	HNS_ROCE_EQ_STAT_INVALID  =3D 0,
> +	HNS_ROCE_EQ_STAT_VALID    =3D 2,
> +};
> +
> +struct hns_roce_aeqe {
> +	u32 asyn;
> +	union {
> +		struct {
> +			u32 qp;
> +			u32 rsv0;
> +			u32 rsv1;
> +		} qp_event;
> +
> +		struct {
> +			u32 cq;
> +			u32 rsv0;
> +			u32 rsv1;
> +		} cq_event;
> +
> +		struct {
> +			u32 port;
> +			u32 rsv0;
> +			u32 rsv1;
> +		} port_event;
> +
> +		struct {
> +			u32 ceqe;
> +			u32 rsv0;
> +			u32 rsv1;
> +		} ce_event;
> +
> +		struct {
> +			__le64  out_param;
> +			__le16  token;
> +			u8	status;
> +			u8	rsv0;
> +		} __packed cmd;
> +	 } event;
> +};
> +
> +#define HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S 16
> +#define HNS_ROCE_AEQE_U32_4_EVENT_TYPE_M   \
> +	(((1UL << 8) - 1) << HNS_ROCE_AEQE_U32_4_EVENT_TYPE_S)
> +
> +#define HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S 24
> +#define HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_M   \
> +	(((1UL << 7) - 1) << HNS_ROCE_AEQE_U32_4_EVENT_SUB_TYPE_S)
> +
> +#define HNS_ROCE_AEQE_U32_4_OWNER_S 31
> +
> +#define HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S 0
> +#define HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_M   \
> +	(((1UL << 24) - 1) << HNS_ROCE_AEQE_EVENT_QP_EVENT_QP_QPN_S)
> +
> +#define HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S 0
> +#define HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_M   \
> +	(((1UL << 16) - 1) << HNS_ROCE_AEQE_EVENT_CQ_EVENT_CQ_CQN_S)
> +
> +#define HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_S 0
> +#define HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_M   \
> +	(((1UL << 5) - 1) << HNS_ROCE_AEQE_EVENT_CE_EVENT_CEQE_CEQN_S)
> +
> +struct hns_roce_ceqe {
> +	union {
> +		int		comp;
> +	} ceqe;
> +};
> +
> +#define HNS_ROCE_CEQE_CEQE_COMP_OWNER_S	0
> +
> +#define HNS_ROCE_CEQE_CEQE_COMP_CQN_S 16
> +#define HNS_ROCE_CEQE_CEQE_COMP_CQN_M   \
> +	(((1UL << 16) - 1) << HNS_ROCE_CEQE_CEQE_COMP_CQN_S)
> +
> +#endif /* _HNS_ROCE_EQ_H */
> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniba=
nd/hw/hns/hns_roce_main.c
> index c9e6d37..0b9cee7 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -183,6 +183,26 @@ static int hns_roce_probe(struct platform_device *pd=
ev)
>  		goto error_failed_cmd_init;
>  	}
> =20
> +	ret =3D hns_roce_init_eq_table(hr_dev);
> +	if (ret) {
> +		dev_err(dev, "eq init failed!\n");
> +		goto error_failed_eq_table;
> +	}
> +
> +	if (hr_dev->cmd_mod) {
> +		ret =3D hns_roce_cmd_use_events(hr_dev);
> +		if (ret) {
> +			dev_err(dev, "Switch to event-driven cmd failed!\n");
> +			goto error_failed_use_event;
> +		}
> +	}
> +
> +error_failed_use_event:
> +	hns_roce_cleanup_eq_table(hr_dev);
> +
> +error_failed_eq_table:
> +	hns_roce_cmd_cleanup(hr_dev);
> +
>  error_failed_cmd_init:
>  	ret =3D hns_roce_engine_reset(hr_dev, false);
>  	if (ret)
> @@ -202,6 +222,10 @@ static int hns_roce_remove(struct platform_device *p=
dev)
>  {
>  	struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
> =20
> +	if (hr_dev->cmd_mod)
> +		hns_roce_cmd_use_polling(hr_dev);
> +
> +	hns_roce_cleanup_eq_table(hr_dev);
>  	hns_roce_cmd_cleanup(hr_dev);
>  	(void)hns_roce_engine_reset(hr_dev, false);
> =20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_qp.c b/drivers/infiniband=
/hw/hns/hns_roce_qp.c
> new file mode 100644
> index 0000000..a826c11
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_qp.c
> @@ -0,0 +1,63 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + * Copyright (c) 2007, 2008 Mellanox Technologies. All rights reserved.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
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
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include <linux/log2.h>
> +#include <linux/slab.h>
> +#include <rdma/ib_cache.h>
> +#include <rdma/ib_pack.h>
> +#include "hns_roce_device.h"
> +
> +void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_t=
ype)
> +{
> +	struct hns_roce_qp_table *qp_table =3D &hr_dev->qp_table;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_qp *qp;
> +
> +	spin_lock(&qp_table->lock);
> +
> +	qp =3D __hns_roce_qp_lookup(hr_dev, qpn);
> +	if (qp)
> +		atomic_inc(&qp->refcount);
> +
> +	spin_unlock(&qp_table->lock);
> +
> +	if (!qp) {
> +		dev_warn(dev, "Async event for bogus QP %08x\n", qpn);
> +		return;
> +	}
> +
> +	qp->event(qp, (enum hns_roce_event)event_type);
> +
> +	if (atomic_dec_and_test(&qp->refcount))
> +		complete(&qp->free);
> +}
> --=20
> 1.9.1
>=20

--Cgrdyab2wu3Akvjd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXbVXjAAoJEORje4g2clinakgQAMSrAFt4f+gbnWd9cLkx5tNy
cU2mUr/rC0Ku/xTcQRzVpqvV3BnGeBQ/fclgLbUKnfI0OOsdlQrZkIjA9zUSH57/
JFHjR88DkUJg6fEMdrXXtd3XKRxhI6tquMGCGl8nG1zOIvjDMt6JR8AKUrtJhQxf
I1Aa4EVVlqaKTMO2LsNo5E98dldgA1BXZEWOe0fR4ouUaCZka2XhoYUTHn7E12zn
7YiYBLmxLEZbthjXU5QXdnbDjCkP/a1zNxkbLY5ngsSX5qdrWKpZP1eMak6kMKMD
k3d3gxyaKzA3mfjJYKqTroDaCc1Zhi8c6ih8ofzB5q3Mvw9a7QyGBlZz+bINEtXM
ezFke0kL3K6opFBtnvCkLxkY7RHvcyYEsJtfeEuy3c0qIBAJpRXoqP0aSlDM3Z10
CIHdfFeocLXifls7ZlVisMBp83j6mN5UbiYhreeYO8DgeWWbhOt9lJFabUghco7l
T3H2PZwcVVnk5YpQiL2BScwHznun77gOyAM+565IrKDWrKnfipldL33WlzzVTeI0
hj7mlfaUNn0m+gYW6x+30hdxFFVlTNdTW7zdo+tRWZz06YXjMuUa/ah+/sQYlEod
AnNGjNVOY7f51Il8Xes05Bz+5Nf9kDaqEVFI7+u1JgreoemWVjMhRpCY4t+vZPzW
Uln7YcUjsGuVF/wE4Obf
=GNAQ
-----END PGP SIGNATURE-----

--Cgrdyab2wu3Akvjd--
