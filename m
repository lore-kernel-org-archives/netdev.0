From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 17/22] IB/hns: Add QP operations support
Date: Sat, 2 Jul 2016 17:39:19 +0800
Message-ID: <1467452364-66522-18-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch was implementing for queue pair operations. QP Consists
of a Send Work Queue and a Receive Work Queue. Send and receive
queues are always created as a pair and remain that way throughout
their lifetime. A Queue Pair is identified by its Queue Pair Number.
QP operations as follows:
    1. create QP. When a QP is created, a complete set of initial
       attributes must be specified by the Consumer.
    2. query QP. Returns the attribute list and current values for
       the specified QP.
    3. modify QP. modify QP relative attributes by it.
    4. destroy QP. When a QP is destroyed, any outstanding Work
       Requests are no longer considered to be in the scope of
       the Channel Interface. It is the responsibility of the
       Consumer to be able to clean up any resources
    5. post send request. Builds one or more WQEs for the Send Queue
       in the specified QP.
    6. post receive request. Builds one or more WQEs for the receive
       Queue in the specified QP.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
PATCH v11:
Deletes the explicit values for enums according to the
Leon Romanovsky's the same comments over the [PATCH v10 1/22]:
  Link: https://lkml.org/lkml/2016/6/24/277

Remove the non-essential headers according to the Leon Romanovsky's
the same comments over the [PATCH v10 3/22]:
  Link: https://lkml.org/lkml/2016/6/24/276

PATCH v10/v9/v8:
- No change over the PATCH v7

PATCH v7:
This fixes the moments given by Doug Ledford over the PATCH v6:
  Link: https://lkml.org/lkml/2016/5/13/519

PATCH v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_alloc.c  |  134 +++
 drivers/infiniband/hw/hns/hns_roce_cmd.c    |  249 ++++
 drivers/infiniband/hw/hns/hns_roce_cmd.h    |   33 +
 drivers/infiniband/hw/hns/hns_roce_common.h |   58 +
 drivers/infiniband/hw/hns/hns_roce_device.h |  167 +++
 drivers/infiniband/hw/hns/hns_roce_hem.c    |   55 +
 drivers/infiniband/hw/hns/hns_roce_hem.h    |    9 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 1629 +++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |  626 ++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |   14 +-
 drivers/infiniband/hw/hns/hns_roce_mr.c     |  162 +++
 drivers/infiniband/hw/hns/hns_roce_qp.c     |  764 +++++++++++++
 drivers/infiniband/hw/hns/hns_roce_user.h   |   13 +
 13 files changed, 3912 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c b/drivers/infiniband/hw/hns/hns_roce_alloc.c
index b243d89..863a17a 100644
--- a/drivers/infiniband/hw/hns/hns_roce_alloc.c
+++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
@@ -66,6 +66,45 @@ void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, unsigned long obj)
 	hns_roce_bitmap_free_range(bitmap, obj, 1);
 }
 
+int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
+				int align, unsigned long *obj)
+{
+	int ret = 0;
+	int i;
+
+	if (likely(cnt == 1 && align == 1))
+		return hns_roce_bitmap_alloc(bitmap, obj);
+
+	spin_lock(&bitmap->lock);
+
+	*obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
+					  bitmap->last, cnt, align - 1);
+	if (*obj >= bitmap->max) {
+		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
+			       & bitmap->mask;
+		*obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max, 0,
+						  cnt, align - 1);
+	}
+
+	if (*obj < bitmap->max) {
+		for (i = 0; i < cnt; i++)
+			set_bit(*obj + i, bitmap->table);
+
+		if (*obj == bitmap->last) {
+			bitmap->last = (*obj + cnt);
+			if (bitmap->last >= bitmap->max)
+				bitmap->last = 0;
+		}
+		*obj |= bitmap->top;
+	} else {
+		ret = -1;
+	}
+
+	spin_unlock(&bitmap->lock);
+
+	return ret;
+}
+
 void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
 				unsigned long obj, int cnt)
 {
@@ -113,6 +152,101 @@ void hns_roce_bitmap_cleanup(struct hns_roce_bitmap *bitmap)
 	kfree(bitmap->table);
 }
 
+void hns_roce_buf_free(struct hns_roce_dev *hr_dev, u32 size,
+		       struct hns_roce_buf *buf)
+{
+	int i;
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 bits_per_long = BITS_PER_LONG;
+
+	if (buf->nbufs == 1) {
+		dma_free_coherent(dev, size, buf->direct.buf, buf->direct.map);
+	} else {
+		if (bits_per_long == 64)
+			vunmap(buf->direct.buf);
+
+		for (i = 0; i < buf->nbufs; ++i)
+			if (buf->page_list[i].buf)
+				dma_free_coherent(&hr_dev->pdev->dev, PAGE_SIZE,
+						  buf->page_list[i].buf,
+						  buf->page_list[i].map);
+		kfree(buf->page_list);
+	}
+}
+
+int hns_roce_buf_alloc(struct hns_roce_dev *hr_dev, u32 size, u32 max_direct,
+		       struct hns_roce_buf *buf)
+{
+	int i = 0;
+	dma_addr_t t;
+	struct page **pages;
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 bits_per_long = BITS_PER_LONG;
+
+	/* SQ/RQ buf lease than one page, SQ + RQ = 8K */
+	if (size <= max_direct) {
+		buf->nbufs = 1;
+		/* Npages calculated by page_size */
+		buf->npages = 1 << get_order(size);
+		buf->page_shift = PAGE_SHIFT;
+		/* MTT PA must be recorded in 4k alignment, t is 4k aligned */
+		buf->direct.buf = dma_alloc_coherent(dev, size, &t, GFP_KERNEL);
+		if (!buf->direct.buf)
+			return -ENOMEM;
+
+		buf->direct.map = t;
+
+		while (t & ((1 << buf->page_shift) - 1)) {
+			--buf->page_shift;
+			buf->npages *= 2;
+		}
+
+		memset(buf->direct.buf, 0, size);
+	} else {
+		buf->nbufs = (size + PAGE_SIZE - 1) / PAGE_SIZE;
+		buf->npages = buf->nbufs;
+		buf->page_shift = PAGE_SHIFT;
+		buf->page_list = kcalloc(buf->nbufs, sizeof(*buf->page_list),
+					 GFP_KERNEL);
+
+		if (!buf->page_list)
+			return -ENOMEM;
+
+		for (i = 0; i < buf->nbufs; ++i) {
+			buf->page_list[i].buf = dma_alloc_coherent(dev,
+								  PAGE_SIZE, &t,
+								  GFP_KERNEL);
+
+			if (!buf->page_list[i].buf)
+				goto err_free;
+
+			buf->page_list[i].map = t;
+			memset(buf->page_list[i].buf, 0, PAGE_SIZE);
+		}
+		if (bits_per_long == 64) {
+			pages = kmalloc_array(buf->nbufs, sizeof(*pages),
+					      GFP_KERNEL);
+			if (!pages)
+				goto err_free;
+
+			for (i = 0; i < buf->nbufs; ++i)
+				pages[i] = virt_to_page(buf->page_list[i].buf);
+
+			buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP,
+					       PAGE_KERNEL);
+			kfree(pages);
+			if (!buf->direct.buf)
+				goto err_free;
+		}
+	}
+
+	return 0;
+
+err_free:
+	hns_roce_buf_free(hr_dev, size, buf);
+	return -ENOMEM;
+}
+
 void hns_roce_cleanup_bitmap(struct hns_roce_dev *hr_dev)
 {
 	hns_roce_cleanup_qp_table(hr_dev);
diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.c b/drivers/infiniband/hw/hns/hns_roce_cmd.c
index 7ffb604..ac891a4 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cmd.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.c
@@ -36,9 +36,148 @@
 #include "hns_roce_device.h"
 #include "hns_roce_cmd.h"
 
+#define CMD_POLL_TOKEN		0xffff
 #define CMD_MAX_NUM		32
+#define STATUS_MASK		0xff
 #define CMD_TOKEN_MASK		0x1f
 
+enum {
+	HCR_TOKEN_OFFSET	= 0x14,
+	HCR_STATUS_OFFSET	= 0x18,
+	HCR_GO_BIT		= 15,
+};
+
+enum {
+	GO_BIT_TIMEOUT_MSECS	= 10000,
+};
+
+static int cmd_pending(struct hns_roce_dev *hr_dev)
+{
+	u32 status = readl(hr_dev->cmd.hcr + HCR_TOKEN_OFFSET);
+
+	return (!!(status & (1 << HCR_GO_BIT)));
+}
+
+/* this function should be serialized with "hcr_mutex" */
+static int __hns_roce_cmd_mbox_post_hw(struct hns_roce_dev *hr_dev,
+				       u64 in_param, u64 out_param,
+				       u32 in_modifier, u8 op_modifier, u16 op,
+				       u16 token, int event)
+{
+	struct hns_roce_cmdq *cmd = &hr_dev->cmd;
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 __iomem *hcr = (u32 *)cmd->hcr;
+	int ret = -EAGAIN;
+	unsigned long end;
+	u32 val = 0;
+
+	end = msecs_to_jiffies(GO_BIT_TIMEOUT_MSECS) + jiffies;
+	while (cmd_pending(hr_dev)) {
+		if (time_after(jiffies, end)) {
+			dev_dbg(dev, "jiffies=%d end=%d\n", (int)jiffies,
+				(int)end);
+			goto out;
+		}
+		cond_resched();
+	}
+
+	roce_set_field(val, ROCEE_MB6_ROCEE_MB_CMD_M, ROCEE_MB6_ROCEE_MB_CMD_S,
+		       op);
+	roce_set_field(val, ROCEE_MB6_ROCEE_MB_CMD_MDF_M,
+		       ROCEE_MB6_ROCEE_MB_CMD_MDF_S, op_modifier);
+	roce_set_bit(val, ROCEE_MB6_ROCEE_MB_EVENT_S, event);
+	roce_set_bit(val, ROCEE_MB6_ROCEE_MB_HW_RUN_S, 1);
+	roce_set_field(val, ROCEE_MB6_ROCEE_MB_TOKEN_M,
+		       ROCEE_MB6_ROCEE_MB_TOKEN_S, token);
+
+	__raw_writeq(cpu_to_le64(in_param), hcr + 0);
+	__raw_writeq(cpu_to_le64(out_param), hcr + 2);
+	__raw_writel(cpu_to_le32(in_modifier), hcr + 4);
+	/* Memory barrier */
+	wmb();
+
+	__raw_writel(cpu_to_le32(val), hcr + 5);
+
+	mmiowb();
+	ret = 0;
+
+out:
+	return ret;
+}
+
+static int hns_roce_cmd_mbox_post_hw(struct hns_roce_dev *hr_dev, u64 in_param,
+				     u64 out_param, u32 in_modifier,
+				     u8 op_modifier, u16 op, u16 token,
+				     int event)
+{
+	struct hns_roce_cmdq *cmd = &hr_dev->cmd;
+	int ret = -EAGAIN;
+
+	mutex_lock(&cmd->hcr_mutex);
+	ret = __hns_roce_cmd_mbox_post_hw(hr_dev, in_param, out_param,
+					  in_modifier, op_modifier, op, token,
+					  event);
+	mutex_unlock(&cmd->hcr_mutex);
+
+	return ret;
+}
+
+/* this should be called with "poll_sem" */
+static int __hns_roce_cmd_mbox_poll(struct hns_roce_dev *hr_dev, u64 in_param,
+				    u64 out_param, unsigned long in_modifier,
+				    u8 op_modifier, u16 op,
+				    unsigned long timeout)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u8 __iomem *hcr = hr_dev->cmd.hcr;
+	unsigned long end = 0;
+	u32 status = 0;
+	int ret;
+
+	ret = hns_roce_cmd_mbox_post_hw(hr_dev, in_param, out_param,
+					in_modifier, op_modifier, op,
+					CMD_POLL_TOKEN, 0);
+	if (ret) {
+		dev_err(dev, "[cmd_poll]hns_roce_cmd_mbox_post_hw failed\n");
+		goto out;
+	}
+
+	end = msecs_to_jiffies(timeout) + jiffies;
+	while (cmd_pending(hr_dev) && time_before(jiffies, end))
+		cond_resched();
+
+	if (cmd_pending(hr_dev)) {
+		dev_err(dev, "[cmd_poll]hw run cmd TIMEDOUT!\n");
+		ret = -ETIMEDOUT;
+		goto out;
+	}
+
+	status = le32_to_cpu((__force __be32)
+			      __raw_readl(hcr + HCR_STATUS_OFFSET));
+	if ((status & STATUS_MASK) != 0x1) {
+		dev_err(dev, "mailbox status 0x%x!\n", status);
+		ret = -EBUSY;
+		goto out;
+	}
+
+out:
+	return ret;
+}
+
+static int hns_roce_cmd_mbox_poll(struct hns_roce_dev *hr_dev, u64 in_param,
+				  u64 out_param, unsigned long in_modifier,
+				  u8 op_modifier, u16 op, unsigned long timeout)
+{
+	int ret;
+
+	down(&hr_dev->cmd.poll_sem);
+	ret = __hns_roce_cmd_mbox_poll(hr_dev, in_param, out_param, in_modifier,
+				       op_modifier, op, timeout);
+	up(&hr_dev->cmd.poll_sem);
+
+	return ret;
+}
+
 void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 status,
 			u64 out_param)
 {
@@ -53,6 +192,87 @@ void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 status,
 	complete(&context->done);
 }
 
+/* this should be called with "use_events" */
+static int __hns_roce_cmd_mbox_wait(struct hns_roce_dev *hr_dev, u64 in_param,
+				    u64 out_param, unsigned long in_modifier,
+				    u8 op_modifier, u16 op,
+				    unsigned long timeout)
+{
+	struct hns_roce_cmdq *cmd = &hr_dev->cmd;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_cmd_context *context;
+	int ret = 0;
+
+	spin_lock(&cmd->context_lock);
+	WARN_ON(cmd->free_head < 0);
+	context = &cmd->context[cmd->free_head];
+	context->token += cmd->token_mask + 1;
+	cmd->free_head = context->next;
+	spin_unlock(&cmd->context_lock);
+
+	init_completion(&context->done);
+
+	ret = hns_roce_cmd_mbox_post_hw(hr_dev, in_param, out_param,
+					in_modifier, op_modifier, op,
+					context->token, 1);
+	if (ret)
+		goto out;
+
+	/*
+	* It is timeout when wait_for_completion_timeout return 0
+	* The return value is the time limit set in advance
+	* how many seconds showing
+	*/
+	if (!wait_for_completion_timeout(&context->done,
+					 msecs_to_jiffies(timeout))) {
+		dev_err(dev, "[cmd]wait_for_completion_timeout timeout\n");
+		ret = -EBUSY;
+		goto out;
+	}
+
+	ret = context->result;
+	if (ret) {
+		dev_err(dev, "[cmd]event mod cmd process error!err=%d\n", ret);
+		goto out;
+	}
+
+out:
+	spin_lock(&cmd->context_lock);
+	context->next = cmd->free_head;
+	cmd->free_head = context - cmd->context;
+	spin_unlock(&cmd->context_lock);
+
+	return ret;
+}
+
+static int hns_roce_cmd_mbox_wait(struct hns_roce_dev *hr_dev, u64 in_param,
+				  u64 out_param, unsigned long in_modifier,
+				  u8 op_modifier, u16 op, unsigned long timeout)
+{
+	int ret = 0;
+
+	down(&hr_dev->cmd.event_sem);
+	ret = __hns_roce_cmd_mbox_wait(hr_dev, in_param, out_param,
+				       in_modifier, op_modifier, op, timeout);
+	up(&hr_dev->cmd.event_sem);
+
+	return ret;
+}
+
+int hns_roce_cmd_mbox(struct hns_roce_dev *hr_dev, u64 in_param, u64 out_param,
+		      unsigned long in_modifier, u8 op_modifier, u16 op,
+		      unsigned long timeout)
+{
+	if (hr_dev->cmd.use_events)
+		return hns_roce_cmd_mbox_wait(hr_dev, in_param, out_param,
+					      in_modifier, op_modifier, op,
+					      timeout);
+	else
+		return hns_roce_cmd_mbox_poll(hr_dev, in_param, out_param,
+					      in_modifier, op_modifier, op,
+					      timeout);
+}
+
 int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
 {
 	struct device *dev = &hr_dev->pdev->dev;
@@ -120,3 +340,32 @@ void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev)
 	kfree(hr_cmd->context);
 	up(&hr_cmd->poll_sem);
 }
+
+struct hns_roce_cmd_mailbox
+	*hns_roce_alloc_cmd_mailbox(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cmd_mailbox *mailbox;
+
+	mailbox = kmalloc(sizeof(*mailbox), GFP_KERNEL);
+	if (!mailbox)
+		return ERR_PTR(-ENOMEM);
+
+	mailbox->buf = dma_pool_alloc(hr_dev->cmd.pool, GFP_KERNEL,
+				      &mailbox->dma);
+	if (!mailbox->buf) {
+		kfree(mailbox);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	return mailbox;
+}
+
+void hns_roce_free_cmd_mailbox(struct hns_roce_dev *hr_dev,
+			       struct hns_roce_cmd_mailbox *mailbox)
+{
+	if (!mailbox)
+		return;
+
+	dma_pool_free(hr_dev->cmd.pool, mailbox->buf, mailbox->dma);
+	kfree(mailbox);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.h b/drivers/infiniband/hw/hns/hns_roce_cmd.h
index 88dd045..20f0019 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cmd.h
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.h
@@ -35,4 +35,37 @@
 
 #define HNS_ROCE_MAILBOX_SIZE		4096
 
+enum {
+	/* QP/EE commands */
+	HNS_ROCE_CMD_RST2INIT_QP	= 0x19,
+	HNS_ROCE_CMD_INIT2RTR_QP	= 0x1a,
+	HNS_ROCE_CMD_RTR2RTS_QP		= 0x1b,
+	HNS_ROCE_CMD_RTS2RTS_QP		= 0x1c,
+	HNS_ROCE_CMD_2ERR_QP		= 0x1e,
+	HNS_ROCE_CMD_RTS2SQD_QP		= 0x1f,
+	HNS_ROCE_CMD_SQD2SQD_QP		= 0x38,
+	HNS_ROCE_CMD_SQD2RTS_QP		= 0x20,
+	HNS_ROCE_CMD_2RST_QP		= 0x21,
+	HNS_ROCE_CMD_QUERY_QP		= 0x22,
+};
+
+enum {
+	HNS_ROCE_CMD_TIME_CLASS_A	= 10000,
+	HNS_ROCE_CMD_TIME_CLASS_C	= 10000,
+};
+
+struct hns_roce_cmd_mailbox {
+	void		       *buf;
+	dma_addr_t		dma;
+};
+
+int hns_roce_cmd_mbox(struct hns_roce_dev *hr_dev, u64 in_param, u64 out_param,
+		      unsigned long in_modifier, u8 op_modifier, u16 op,
+		      unsigned long timeout);
+
+struct hns_roce_cmd_mailbox
+	*hns_roce_alloc_cmd_mailbox(struct hns_roce_dev *hr_dev);
+void hns_roce_free_cmd_mailbox(struct hns_roce_dev *hr_dev,
+			       struct hns_roce_cmd_mailbox *mailbox);
+
 #endif /* _HNS_ROCE_CMD_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index ee87689..2970161 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -160,6 +160,44 @@
 
 #define ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S 31
 
+#define ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_S 0
+#define ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_M   \
+	(((1UL << 3) - 1) << ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_S)
+
+#define ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S 0
+#define ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_M   \
+	(((1UL << 15) - 1) << ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S)
+
+#define ROCEE_MB6_ROCEE_MB_CMD_S 0
+#define ROCEE_MB6_ROCEE_MB_CMD_M   \
+	(((1UL << 8) - 1) << ROCEE_MB6_ROCEE_MB_CMD_S)
+
+#define ROCEE_MB6_ROCEE_MB_CMD_MDF_S 8
+#define ROCEE_MB6_ROCEE_MB_CMD_MDF_M   \
+	(((1UL << 4) - 1) << ROCEE_MB6_ROCEE_MB_CMD_MDF_S)
+
+#define ROCEE_MB6_ROCEE_MB_EVENT_S 14
+
+#define ROCEE_MB6_ROCEE_MB_HW_RUN_S 15
+
+#define ROCEE_MB6_ROCEE_MB_TOKEN_S 16
+#define ROCEE_MB6_ROCEE_MB_TOKEN_M   \
+	(((1UL << 16) - 1) << ROCEE_MB6_ROCEE_MB_TOKEN_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S 0
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_M   \
+	(((1UL << 24) - 1) << ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S 24
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_M   \
+	(((1UL << 4) - 1) << ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S 28
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M   \
+	(((1UL << 3) - 1) << ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S)
+
+#define ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S 31
+
 #define ROCEE_SMAC_H_ROCEE_SMAC_H_S 0
 #define ROCEE_SMAC_H_ROCEE_SMAC_H_M   \
 	(((1UL << 16) - 1) << ROCEE_SMAC_H_ROCEE_SMAC_H_S)
@@ -199,6 +237,18 @@
 
 #define ROCEE_CAEP_AE_ST_CAEP_AEQ_ALM_OVF_S 0
 
+#define ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S 0
+#define ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_M   \
+	(((1UL << 28) - 1) << ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S)
+
+#define ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S 0
+#define ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M   \
+	(((1UL << 28) - 1) << ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S)
+
+#define ROCEE_SDB_INV_CNT_SDB_INV_CNT_S 0
+#define ROCEE_SDB_INV_CNT_SDB_INV_CNT_M   \
+	(((1UL << 16) - 1) << ROCEE_SDB_INV_CNT_SDB_INV_CNT_S)
+
 /*************ROCEE_REG DEFINITION****************/
 #define ROCEE_VENDOR_ID_REG			0x0
 #define ROCEE_VENDOR_PART_ID_REG		0x4
@@ -218,6 +268,8 @@
 #define ROCEE_SMAC_L_0_REG			0x240
 #define ROCEE_SMAC_H_0_REG			0x244
 
+#define ROCEE_QP1C_CFG3_0_REG			0x27C
+
 #define ROCEE_CAEP_AEQE_CONS_IDX_REG		0x3AC
 #define ROCEE_CAEP_CEQC_CONS_IDX_0_REG		0x3BC
 
@@ -253,6 +305,9 @@
 #define ROCEE_BT_CMD_L_REG			0x200
 
 #define ROCEE_MB1_REG				0x210
+#define ROCEE_DB_SQ_L_0_REG			0x230
+#define ROCEE_DB_OTHERS_L_0_REG			0x238
+#define ROCEE_QP1C_CFG0_0_REG			0x270
 
 #define ROCEE_CAEP_AEQC_AEQE_SHIFT_REG		0x3A0
 #define ROCEE_CAEP_CEQC_SHIFT_0_REG		0x3B0
@@ -261,6 +316,9 @@
 #define ROCEE_CAEP_AE_MASK_REG			0x6C8
 #define ROCEE_CAEP_AE_ST_REG			0x6CC
 
+#define ROCEE_SDB_ISSUE_PTR_REG			0x758
+#define ROCEE_SDB_SEND_PTR_REG			0x75C
+#define ROCEE_SDB_INV_CNT_REG			0x9A4
 #define ROCEE_ECC_UCERR_ALM0_REG		0xB34
 #define ROCEE_ECC_CERR_ALM0_REG			0xB40
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 46474da..01b4031 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -40,8 +40,15 @@
 #define MAC_ADDR_OCTET_NUM			6
 #define HNS_ROCE_MAX_MSG_LEN			0x80000000
 
+#define HNS_ROCE_ALOGN_UP(a, b) ((((a) + (b) - 1) / (b)) * (b))
+
+#define HNS_ROCE_IB_MIN_SQ_STRIDE		6
+
 #define HNS_ROCE_BA_SIZE			(32 * 4096)
 
+/* Hardware specification only for v1 engine */
+#define HNS_ROCE_MIN_WQE_NUM			0x20
+
 #define HNS_ROCE_MAX_IRQ_NUM			34
 
 #define HNS_ROCE_COMP_VEC_NUM			32
@@ -63,6 +70,16 @@
 
 #define PAGES_SHIFT_16				16
 
+enum hns_roce_qp_state {
+	HNS_ROCE_QP_STATE_RST,
+	HNS_ROCE_QP_STATE_INIT,
+	HNS_ROCE_QP_STATE_RTR,
+	HNS_ROCE_QP_STATE_RTS,
+	HNS_ROCE_QP_STATE_SQD,
+	HNS_ROCE_QP_STATE_ERR,
+	HNS_ROCE_QP_NUM_STATE,
+};
+
 enum hns_roce_event {
 	HNS_ROCE_EVENT_TYPE_PATH_MIG                  = 0x01,
 	HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED           = 0x02,
@@ -121,6 +138,10 @@ enum {
 #define HNS_ROCE_PORT_DOWN			0
 #define HNS_ROCE_PORT_UP			1
 
+#define HNS_ROCE_MTT_ENTRY_PER_SEG		8
+
+#define PAGE_ADDR_SHIFT				12
+
 struct hns_roce_uar {
 	u64		pfn;
 	unsigned long	index;
@@ -178,6 +199,12 @@ struct hns_roce_hem_table {
 	struct hns_roce_hem **hem;
 };
 
+struct hns_roce_mtt {
+	unsigned long	first_seg;
+	int		order;
+	int		page_shift;
+};
+
 struct hns_roce_mr_table {
 	struct hns_roce_bitmap		mtpt_bitmap;
 	struct hns_roce_buddy		mtt_buddy;
@@ -185,19 +212,57 @@ struct hns_roce_mr_table {
 	struct hns_roce_hem_table	mtpt_table;
 };
 
+struct hns_roce_wq {
+	u64		*wrid;     /* Work request ID */
+	spinlock_t	lock;
+	int		wqe_cnt;  /* WQE num */
+	u32		max_post;
+	int		max_gs;
+	int		offset;
+	int		wqe_shift;/* WQE size */
+	u32		head;
+	u32		tail;
+	void __iomem	*db_reg_l;
+};
+
 struct hns_roce_buf_list {
 	void		*buf;
 	dma_addr_t	map;
 };
 
+struct hns_roce_buf {
+	struct hns_roce_buf_list	direct;
+	struct hns_roce_buf_list	*page_list;
+	int				nbufs;
+	u32				npages;
+	int				page_shift;
+};
+
+struct hns_roce_cq_buf {
+	struct hns_roce_buf hr_buf;
+};
+
 struct hns_roce_cq {
+	struct ib_cq			ib_cq;
+	struct hns_roce_cq_buf		hr_buf;
+	/* pointer to store information after resize*/
+	spinlock_t			lock;
 	void (*comp)(struct hns_roce_cq *);
 	void (*event)(struct hns_roce_cq *, enum hns_roce_event);
 
+	u32				cq_depth;
+	u32				cons_index;
+	void __iomem			*cq_db_l;
+	unsigned long			cqn;
 	atomic_t			refcount;
 	struct completion		free;
 };
 
+struct hns_roce_srq {
+	struct ib_srq		ibsrq;
+	int			srqn;
+};
+
 struct hns_roce_uar_table {
 	struct hns_roce_bitmap bitmap;
 };
@@ -276,13 +341,38 @@ struct hns_roce_cmdq {
 struct hns_roce_dev;
 
 struct hns_roce_qp {
+	struct ib_qp		ibqp;
+	struct hns_roce_buf	hr_buf;
+	struct hns_roce_wq	rq;
+	__le64			doorbell_qpn;
+	__le32			sq_signal_bits;
+	u32			sq_next_wqe;
+	int			sq_max_wqes_per_wr;
+	int			sq_spare_wqes;
+	struct hns_roce_wq	sq;
+
+	struct ib_umem		*umem;
+	struct hns_roce_mtt	mtt;
+	u32			buff_size;
+	struct mutex		mutex;
+	u8			port;
+	u8			sl;
+	u8			resp_depth;
+	u8			state;
+	u32			access_flags;
+	u32			pkey_index;
 	void			(*event)(struct hns_roce_qp *,
 					 enum hns_roce_event);
+	unsigned long		qpn;
 
 	atomic_t		refcount;
 	struct completion	free;
 };
 
+struct hns_roce_sqp {
+	struct hns_roce_qp	hr_qp;
+};
+
 struct hns_roce_ib_iboe {
 	spinlock_t		lock;
 	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
@@ -365,6 +455,16 @@ struct hns_roce_hw {
 	void (*set_mac)(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr);
 	void (*set_mtu)(struct hns_roce_dev *hr_dev, u8 phy_port,
 			enum ib_mtu mtu);
+	int (*query_qp)(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
+			int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr);
+	int (*modify_qp)(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
+			 int attr_mask, enum ib_qp_state cur_state,
+			 enum ib_qp_state new_state);
+	int (*destroy_qp)(struct ib_qp *ibqp);
+	int (*post_send)(struct ib_qp *ibqp, struct ib_send_wr *wr,
+			 struct ib_send_wr **bad_wr);
+	int (*post_recv)(struct ib_qp *qp, struct ib_recv_wr *recv_wr,
+			 struct ib_recv_wr **bad_recv_wr);
 	void	*priv;
 };
 
@@ -423,6 +523,26 @@ static inline struct hns_roce_ah *to_hr_ah(struct ib_ah *ibah)
 	return container_of(ibah, struct hns_roce_ah, ibah);
 }
 
+static inline struct hns_roce_qp *to_hr_qp(struct ib_qp *ibqp)
+{
+	return container_of(ibqp, struct hns_roce_qp, ibqp);
+}
+
+static inline struct hns_roce_cq *to_hr_cq(struct ib_cq *ib_cq)
+{
+	return container_of(ib_cq, struct hns_roce_cq, ib_cq);
+}
+
+static inline struct hns_roce_srq *to_hr_srq(struct ib_srq *ibsrq)
+{
+	return container_of(ibsrq, struct hns_roce_srq, ibsrq);
+}
+
+static inline struct hns_roce_sqp *hr_to_hr_sqp(struct hns_roce_qp *hr_qp)
+{
+	return container_of(hr_qp, struct hns_roce_sqp, hr_qp);
+}
+
 static inline void hns_roce_write64_k(__be32 val[2], void __iomem *dest)
 {
 	__raw_writeq(*(u64 *) val, dest);
@@ -435,6 +555,17 @@ static inline struct hns_roce_qp
 				 qpn & (hr_dev->caps.num_qps - 1));
 }
 
+static inline void *hns_roce_buf_offset(struct hns_roce_buf *buf, int offset)
+{
+	u32 bits_per_long_val = BITS_PER_LONG;
+
+	if (bits_per_long_val == 64 || buf->nbufs == 1)
+		return (char *)(buf->direct.buf) + offset;
+	else
+		return (char *)(buf->page_list[offset >> PAGE_SHIFT].buf) +
+		       (offset & (PAGE_SIZE - 1));
+}
+
 int hns_roce_init_uar_table(struct hns_roce_dev *dev);
 int hns_roce_uar_alloc(struct hns_roce_dev *dev, struct hns_roce_uar *uar);
 void hns_roce_uar_free(struct hns_roce_dev *dev, struct hns_roce_uar *uar);
@@ -447,6 +578,13 @@ void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 status,
 int hns_roce_cmd_use_events(struct hns_roce_dev *hr_dev);
 void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev);
 
+int hns_roce_mtt_init(struct hns_roce_dev *hr_dev, int npages, int page_shift,
+		      struct hns_roce_mtt *mtt);
+void hns_roce_mtt_cleanup(struct hns_roce_dev *hr_dev,
+			  struct hns_roce_mtt *mtt);
+int hns_roce_buf_write_mtt(struct hns_roce_dev *hr_dev,
+			   struct hns_roce_mtt *mtt, struct hns_roce_buf *buf);
+
 int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev);
 int hns_roce_init_mr_table(struct hns_roce_dev *hr_dev);
 int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev);
@@ -479,6 +617,35 @@ struct ib_pd *hns_roce_alloc_pd(struct ib_device *ib_dev,
 				struct ib_udata *udata);
 int hns_roce_dealloc_pd(struct ib_pd *pd);
 
+void hns_roce_buf_free(struct hns_roce_dev *hr_dev, u32 size,
+		       struct hns_roce_buf *buf);
+int hns_roce_buf_alloc(struct hns_roce_dev *hr_dev, u32 size, u32 max_direct,
+		       struct hns_roce_buf *buf);
+
+int hns_roce_ib_umem_write_mtt(struct hns_roce_dev *hr_dev,
+			       struct hns_roce_mtt *mtt, struct ib_umem *umem);
+
+struct ib_qp *hns_roce_create_qp(struct ib_pd *ib_pd,
+				 struct ib_qp_init_attr *init_attr,
+				 struct ib_udata *udata);
+int hns_roce_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		       int attr_mask, struct ib_udata *udata);
+void *get_recv_wqe(struct hns_roce_qp *hr_qp, int n);
+void *get_send_wqe(struct hns_roce_qp *hr_qp, int n);
+bool hns_roce_wq_overflow(struct hns_roce_wq *hr_wq, int nreq,
+			  struct ib_cq *ib_cq);
+enum hns_roce_qp_state to_hns_roce_state(enum ib_qp_state state);
+void hns_roce_lock_cqs(struct hns_roce_cq *send_cq,
+		       struct hns_roce_cq *recv_cq);
+void hns_roce_unlock_cqs(struct hns_roce_cq *send_cq,
+			 struct hns_roce_cq *recv_cq);
+void hns_roce_qp_remove(struct hns_roce_dev *hr_dev, struct hns_roce_qp *hr_qp);
+void hns_roce_qp_free(struct hns_roce_dev *hr_dev, struct hns_roce_qp *hr_qp);
+void hns_roce_release_range_qp(struct hns_roce_dev *hr_dev, int base_qpn,
+			       int cnt);
+__be32 send_ieth(struct ib_send_wr *wr);
+int to_hr_qp_type(int qp_type);
+
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
 void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type);
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.c b/drivers/infiniband/hw/hns/hns_roce_hem.c
index a2eeb47..d53d643 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hem.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.c
@@ -343,6 +343,50 @@ void hns_roce_table_put(struct hns_roce_dev *hr_dev,
 	mutex_unlock(&table->mutex);
 }
 
+void *hns_roce_table_find(struct hns_roce_hem_table *table, unsigned long obj,
+			  dma_addr_t *dma_handle)
+{
+	struct hns_roce_hem_chunk *chunk;
+	unsigned long idx;
+	int i;
+	int offset, dma_offset;
+	struct hns_roce_hem *hem;
+	struct page *page = NULL;
+
+	if (!table->lowmem)
+		return NULL;
+
+	mutex_lock(&table->mutex);
+	idx = (obj & (table->num_obj - 1)) * table->obj_size;
+	hem = table->hem[idx / HNS_ROCE_TABLE_CHUNK_SIZE];
+	dma_offset = offset = idx % HNS_ROCE_TABLE_CHUNK_SIZE;
+
+	if (!hem)
+		goto out;
+
+	list_for_each_entry(chunk, &hem->chunk_list, list) {
+		for (i = 0; i < chunk->npages; ++i) {
+			if (dma_handle && dma_offset >= 0) {
+				if (sg_dma_len(&chunk->mem[i]) >
+				    (u32)dma_offset)
+					*dma_handle = sg_dma_address(
+						&chunk->mem[i]) + dma_offset;
+				dma_offset -= sg_dma_len(&chunk->mem[i]);
+			}
+
+			if (chunk->mem[i].length > (u32)offset) {
+				page = sg_page(&chunk->mem[i]);
+				goto out;
+			}
+			offset -= chunk->mem[i].length;
+		}
+	}
+
+out:
+	mutex_unlock(&table->mutex);
+	return page ? lowmem_page_address(page) + offset : NULL;
+}
+
 int hns_roce_table_get_range(struct hns_roce_dev *hr_dev,
 			     struct hns_roce_hem_table *table,
 			     unsigned long start, unsigned long end)
@@ -368,6 +412,17 @@ fail:
 	return ret;
 }
 
+void hns_roce_table_put_range(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_hem_table *table,
+			      unsigned long start, unsigned long end)
+{
+	unsigned long i;
+
+	for (i = start; i <= end;
+		i += HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size)
+		hns_roce_table_put(hr_dev, table, i);
+}
+
 int hns_roce_init_hem_table(struct hns_roce_dev *hr_dev,
 			    struct hns_roce_hem_table *table, u32 type,
 			    unsigned long obj_size, unsigned long nobj,
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.h b/drivers/infiniband/hw/hns/hns_roce_hem.h
index ef7d394..40cacd6 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hem.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.h
@@ -50,6 +50,10 @@ enum {
 	 ((256 - sizeof(struct list_head) - 2 * sizeof(int)) /	 \
 	 (sizeof(struct scatterlist)))
 
+enum {
+	 HNS_ROCE_HEM_PAGE_SHIFT = 12,
+};
+
 struct hns_roce_hem_chunk {
 	struct list_head	 list;
 	int			 npages;
@@ -73,9 +77,14 @@ int hns_roce_table_get(struct hns_roce_dev *hr_dev,
 		       struct hns_roce_hem_table *table, unsigned long obj);
 void hns_roce_table_put(struct hns_roce_dev *hr_dev,
 			struct hns_roce_hem_table *table, unsigned long obj);
+void *hns_roce_table_find(struct hns_roce_hem_table *table, unsigned long obj,
+			  dma_addr_t *dma_handle);
 int hns_roce_table_get_range(struct hns_roce_dev *hr_dev,
 			     struct hns_roce_hem_table *table,
 			     unsigned long start, unsigned long end);
+void hns_roce_table_put_range(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_hem_table *table,
+			      unsigned long start, unsigned long end);
 int hns_roce_init_hem_table(struct hns_roce_dev *hr_dev,
 			    struct hns_roce_hem_table *table, u32 type,
 			    unsigned long obj_size, unsigned long nobj,
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 5ce644e..fb39155 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -34,8 +34,369 @@
 #include <rdma/ib_umem.h>
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_hem.h"
 #include "hns_roce_hw_v1.h"
 
+static void set_data_seg(struct hns_roce_wqe_data_seg *dseg, struct ib_sge *sg)
+{
+	dseg->lkey = cpu_to_le32(sg->lkey);
+	dseg->addr = cpu_to_le64(sg->addr);
+	dseg->len  = cpu_to_le32(sg->length);
+}
+
+static void set_raddr_seg(struct hns_roce_wqe_raddr_seg *rseg, u64 remote_addr,
+			  u32 rkey)
+{
+	rseg->raddr = cpu_to_le64(remote_addr);
+	rseg->rkey  = cpu_to_le32(rkey);
+	rseg->len   = 0;
+}
+
+int hns_roce_v1_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
+			  struct ib_send_wr **bad_wr)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_ah *ah = to_hr_ah(ud_wr(wr)->ah);
+	struct hns_roce_ud_send_wqe *ud_sq_wqe = NULL;
+	struct hns_roce_wqe_ctrl_seg *ctrl = NULL;
+	struct hns_roce_wqe_data_seg *dseg = NULL;
+	struct hns_roce_qp *qp = to_hr_qp(ibqp);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_sq_db sq_db;
+	int ps_opcode = 0, i = 0;
+	unsigned long flags = 0;
+	void *wqe = NULL;
+	u32 doorbell[2];
+	int nreq = 0;
+	u32 ind = 0;
+	int ret = 0;
+
+	spin_lock_irqsave(&qp->sq.lock, flags);
+
+	ind = qp->sq_next_wqe;
+	for (nreq = 0; wr; ++nreq, wr = wr->next) {
+		if (hns_roce_wq_overflow(&qp->sq, nreq, qp->ibqp.send_cq)) {
+			ret = -ENOMEM;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		if (unlikely(wr->num_sge > qp->sq.max_gs)) {
+			dev_err(dev, "num_sge=%d > qp->sq.max_gs=%d\n",
+				wr->num_sge, qp->sq.max_gs);
+			ret = -EINVAL;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		wqe = get_send_wqe(qp, ind & (qp->sq.wqe_cnt - 1));
+		qp->sq.wrid[(qp->sq.head + nreq) & (qp->sq.wqe_cnt - 1)] =
+								      wr->wr_id;
+
+		/* Corresponding to the RC and RD type wqe process separately */
+		if (ibqp->qp_type == IB_QPT_GSI) {
+			ud_sq_wqe = wqe;
+			roce_set_field(ud_sq_wqe->dmac_h,
+				       UD_SEND_WQE_U32_4_DMAC_0_M,
+				       UD_SEND_WQE_U32_4_DMAC_0_S,
+				       ah->av.mac[0]);
+			roce_set_field(ud_sq_wqe->dmac_h,
+				       UD_SEND_WQE_U32_4_DMAC_1_M,
+				       UD_SEND_WQE_U32_4_DMAC_1_S,
+				       ah->av.mac[1]);
+			roce_set_field(ud_sq_wqe->dmac_h,
+				       UD_SEND_WQE_U32_4_DMAC_2_M,
+				       UD_SEND_WQE_U32_4_DMAC_2_S,
+				       ah->av.mac[2]);
+			roce_set_field(ud_sq_wqe->dmac_h,
+				       UD_SEND_WQE_U32_4_DMAC_3_M,
+				       UD_SEND_WQE_U32_4_DMAC_3_S,
+				       ah->av.mac[3]);
+
+			roce_set_field(ud_sq_wqe->u32_8,
+				       UD_SEND_WQE_U32_8_DMAC_4_M,
+				       UD_SEND_WQE_U32_8_DMAC_4_S,
+				       ah->av.mac[4]);
+			roce_set_field(ud_sq_wqe->u32_8,
+				       UD_SEND_WQE_U32_8_DMAC_5_M,
+				       UD_SEND_WQE_U32_8_DMAC_5_S,
+				       ah->av.mac[5]);
+			roce_set_field(ud_sq_wqe->u32_8,
+				       UD_SEND_WQE_U32_8_OPERATION_TYPE_M,
+				       UD_SEND_WQE_U32_8_OPERATION_TYPE_S,
+				       HNS_ROCE_WQE_OPCODE_SEND);
+			roce_set_field(ud_sq_wqe->u32_8,
+				       UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_M,
+				       UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_S,
+				       2);
+			roce_set_bit(ud_sq_wqe->u32_8,
+				UD_SEND_WQE_U32_8_SEND_GL_ROUTING_HDR_FLAG_S,
+				1);
+
+			ud_sq_wqe->u32_8 |= (wr->send_flags & IB_SEND_SIGNALED ?
+				cpu_to_le32(HNS_ROCE_WQE_CQ_NOTIFY) : 0) |
+				(wr->send_flags & IB_SEND_SOLICITED ?
+				cpu_to_le32(HNS_ROCE_WQE_SE) : 0) |
+				((wr->opcode == IB_WR_SEND_WITH_IMM) ?
+				cpu_to_le32(HNS_ROCE_WQE_IMM) : 0);
+
+			roce_set_field(ud_sq_wqe->u32_16,
+				       UD_SEND_WQE_U32_16_DEST_QP_M,
+				       UD_SEND_WQE_U32_16_DEST_QP_S,
+				       ud_wr(wr)->remote_qpn);
+			roce_set_field(ud_sq_wqe->u32_16,
+				       UD_SEND_WQE_U32_16_MAX_STATIC_RATE_M,
+				       UD_SEND_WQE_U32_16_MAX_STATIC_RATE_S,
+				       ah->av.stat_rate);
+
+			roce_set_field(ud_sq_wqe->u32_36,
+				       UD_SEND_WQE_U32_36_FLOW_LABEL_M,
+				       UD_SEND_WQE_U32_36_FLOW_LABEL_S, 0);
+			roce_set_field(ud_sq_wqe->u32_36,
+				       UD_SEND_WQE_U32_36_PRIORITY_M,
+				       UD_SEND_WQE_U32_36_PRIORITY_S,
+				       ah->av.sl_tclass_flowlabel >>
+				       HNS_ROCE_SL_SHIFT);
+			roce_set_field(ud_sq_wqe->u32_36,
+				       UD_SEND_WQE_U32_36_SGID_INDEX_M,
+				       UD_SEND_WQE_U32_36_SGID_INDEX_S,
+				       hns_get_gid_index(hr_dev, qp->port,
+							 ah->av.gid_index));
+
+			roce_set_field(ud_sq_wqe->u32_40,
+				       UD_SEND_WQE_U32_40_HOP_LIMIT_M,
+				       UD_SEND_WQE_U32_40_HOP_LIMIT_S,
+				       ah->av.hop_limit);
+			roce_set_field(ud_sq_wqe->u32_40,
+				       UD_SEND_WQE_U32_40_TRAFFIC_CLASS_M,
+				       UD_SEND_WQE_U32_40_TRAFFIC_CLASS_S, 0);
+
+			memcpy(&ud_sq_wqe->dgid[0], &ah->av.dgid[0], GID_LEN);
+
+			ud_sq_wqe->va0_l = (u32)wr->sg_list[0].addr;
+			ud_sq_wqe->va0_h = (wr->sg_list[0].addr) >> 32;
+			ud_sq_wqe->l_key0 = wr->sg_list[0].lkey;
+
+			ud_sq_wqe->va1_l = (u32)wr->sg_list[1].addr;
+			ud_sq_wqe->va1_h = (wr->sg_list[1].addr) >> 32;
+			ud_sq_wqe->l_key1 = wr->sg_list[1].lkey;
+			ind++;
+		} else if (ibqp->qp_type == IB_QPT_RC) {
+			ctrl = wqe;
+			memset(ctrl, 0, sizeof(struct hns_roce_wqe_ctrl_seg));
+			for (i = 0; i < wr->num_sge; i++)
+				ctrl->msg_length += wr->sg_list[i].length;
+
+			ctrl->sgl_pa_h = 0;
+			ctrl->flag = 0;
+			ctrl->imm_data = send_ieth(wr);
+
+			/*Ctrl field, ctrl set type: sig, solic, imm, fence */
+			/* SO wait for conforming application scenarios */
+			ctrl->flag |= (wr->send_flags & IB_SEND_SIGNALED ?
+				      cpu_to_le32(HNS_ROCE_WQE_CQ_NOTIFY) : 0) |
+				      (wr->send_flags & IB_SEND_SOLICITED ?
+				      cpu_to_le32(HNS_ROCE_WQE_SE) : 0) |
+				      ((wr->opcode == IB_WR_SEND_WITH_IMM ||
+				      wr->opcode == IB_WR_RDMA_WRITE_WITH_IMM) ?
+				      cpu_to_le32(HNS_ROCE_WQE_IMM) : 0) |
+				      (wr->send_flags & IB_SEND_FENCE ?
+				      (cpu_to_le32(HNS_ROCE_WQE_FENCE)) : 0);
+
+			wqe = (struct hns_roce_wqe_ctrl_seg *)wqe +
+			       sizeof(struct hns_roce_wqe_ctrl_seg);
+
+			switch (wr->opcode) {
+			case IB_WR_RDMA_READ:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_RDMA_READ;
+				set_raddr_seg(wqe, atomic_wr(wr)->remote_addr,
+					      atomic_wr(wr)->rkey);
+				break;
+			case IB_WR_RDMA_WRITE:
+			case IB_WR_RDMA_WRITE_WITH_IMM:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_RDMA_WRITE;
+				set_raddr_seg(wqe, atomic_wr(wr)->remote_addr,
+					      atomic_wr(wr)->rkey);
+				break;
+			case IB_WR_SEND:
+			case IB_WR_SEND_WITH_INV:
+			case IB_WR_SEND_WITH_IMM:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_SEND;
+				break;
+			case IB_WR_LOCAL_INV:
+				break;
+			case IB_WR_ATOMIC_CMP_AND_SWP:
+			case IB_WR_ATOMIC_FETCH_AND_ADD:
+			case IB_WR_LSO:
+			default:
+				ps_opcode = HNS_ROCE_WQE_OPCODE_MASK;
+				break;
+			}
+			ctrl->flag |= cpu_to_le32(ps_opcode);
+			wqe = (struct hns_roce_wqe_raddr_seg *)wqe +
+			       sizeof(struct hns_roce_wqe_raddr_seg);
+
+			dseg = wqe;
+			if (wr->send_flags & IB_SEND_INLINE && wr->num_sge) {
+				if (ctrl->msg_length >
+					hr_dev->caps.max_sq_inline) {
+					ret = -EINVAL;
+					*bad_wr = wr;
+					dev_err(dev, "inline len(1-%d)=%d, illegal",
+						ctrl->msg_length,
+						hr_dev->caps.max_sq_inline);
+					goto out;
+				}
+				for (i = 0; i < wr->num_sge; i++) {
+					memcpy(wqe, ((void *) (uintptr_t)
+					       wr->sg_list[i].addr),
+					       wr->sg_list[i].length);
+					wqe = (struct hns_roce_wqe_raddr_seg *)
+					       wqe + wr->sg_list[i].length;
+				}
+				ctrl->flag |= HNS_ROCE_WQE_INLINE;
+			} else {
+				/*sqe num is two */
+				for (i = 0; i < wr->num_sge; i++)
+					set_data_seg(dseg + i, wr->sg_list + i);
+
+				ctrl->flag |= cpu_to_le32(wr->num_sge <<
+					      HNS_ROCE_WQE_SGE_NUM_BIT);
+			}
+			ind++;
+		} else {
+			dev_dbg(dev, "unSupported QP type\n");
+			break;
+		}
+	}
+
+out:
+	/* Set DB return */
+	if (likely(nreq)) {
+		qp->sq.head += nreq;
+		/* Memory barrier */
+		wmb();
+
+		sq_db.u32_4 = 0;
+		sq_db.u32_8 = 0;
+		roce_set_field(sq_db.u32_4, SQ_DOORBELL_U32_4_SQ_HEAD_M,
+			       SQ_DOORBELL_U32_4_SQ_HEAD_S,
+			      (qp->sq.head & ((qp->sq.wqe_cnt << 1) - 1)));
+		roce_set_field(sq_db.u32_4, SQ_DOORBELL_U32_4_PORT_M,
+			       SQ_DOORBELL_U32_4_PORT_S, qp->port);
+		roce_set_field(sq_db.u32_8, SQ_DOORBELL_U32_8_QPN_M,
+			       SQ_DOORBELL_U32_8_QPN_S, qp->doorbell_qpn);
+		roce_set_bit(sq_db.u32_8, SQ_DOORBELL_HW_SYNC_S, 1);
+
+		doorbell[0] = sq_db.u32_4;
+		doorbell[1] = sq_db.u32_8;
+
+		hns_roce_write64_k(doorbell, qp->sq.db_reg_l);
+		qp->sq_next_wqe = ind;
+	}
+
+	spin_unlock_irqrestore(&qp->sq.lock, flags);
+
+	return ret;
+}
+
+int hns_roce_v1_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *wr,
+			  struct ib_recv_wr **bad_wr)
+{
+	int ret = 0;
+	int nreq = 0;
+	int ind = 0;
+	int i = 0;
+	u32 reg_val = 0;
+	unsigned long flags = 0;
+	struct hns_roce_rq_wqe_ctrl *ctrl = NULL;
+	struct hns_roce_wqe_data_seg *scat = NULL;
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_rq_db rq_db;
+	uint32_t doorbell[2] = {0};
+
+	spin_lock_irqsave(&hr_qp->rq.lock, flags);
+	ind = hr_qp->rq.head & (hr_qp->rq.wqe_cnt - 1);
+
+	for (nreq = 0; wr; ++nreq, wr = wr->next) {
+		if (hns_roce_wq_overflow(&hr_qp->rq, nreq,
+			hr_qp->ibqp.recv_cq)) {
+			ret = -ENOMEM;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		if (unlikely(wr->num_sge > hr_qp->rq.max_gs)) {
+			dev_err(dev, "rq:num_sge=%d > qp->sq.max_gs=%d\n",
+				wr->num_sge, hr_qp->rq.max_gs);
+			ret = -EINVAL;
+			*bad_wr = wr;
+			goto out;
+		}
+
+		ctrl = get_recv_wqe(hr_qp, ind);
+
+		roce_set_field(ctrl->rwqe_byte_12,
+			       RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_M,
+			       RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_S,
+			       wr->num_sge);
+
+		scat = (struct hns_roce_wqe_data_seg *)(ctrl + 1);
+
+		for (i = 0; i < wr->num_sge; i++)
+			set_data_seg(scat + i, wr->sg_list + i);
+
+		hr_qp->rq.wrid[ind] = wr->wr_id;
+
+		ind = (ind + 1) & (hr_qp->rq.wqe_cnt - 1);
+	}
+
+out:
+	if (likely(nreq)) {
+		hr_qp->rq.head += nreq;
+		/* Memory barrier */
+		wmb();
+
+		if (ibqp->qp_type == IB_QPT_GSI) {
+			/* SW update GSI rq header */
+			reg_val = roce_read(to_hr_dev(ibqp->device),
+					    ROCEE_QP1C_CFG3_0_REG +
+					    QP1C_CFGN_OFFSET * hr_qp->port);
+			roce_set_field(reg_val,
+				       ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_M,
+				       ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S,
+				       hr_qp->rq.head);
+			roce_write(to_hr_dev(ibqp->device),
+				   ROCEE_QP1C_CFG3_0_REG +
+				   QP1C_CFGN_OFFSET * hr_qp->port, reg_val);
+		} else {
+			rq_db.u32_4 = 0;
+			rq_db.u32_8 = 0;
+
+			roce_set_field(rq_db.u32_4, RQ_DOORBELL_U32_4_RQ_HEAD_M,
+				       RQ_DOORBELL_U32_4_RQ_HEAD_S,
+				       hr_qp->rq.head);
+			roce_set_field(rq_db.u32_8, RQ_DOORBELL_U32_8_QPN_M,
+				       RQ_DOORBELL_U32_8_QPN_S, hr_qp->qpn);
+			roce_set_field(rq_db.u32_8, RQ_DOORBELL_U32_8_CMD_M,
+				       RQ_DOORBELL_U32_8_CMD_S, 1);
+			roce_set_bit(rq_db.u32_8, RQ_DOORBELL_U32_8_HW_SYNC_S,
+				     1);
+
+			doorbell[0] = rq_db.u32_4;
+			doorbell[1] = rq_db.u32_8;
+
+			hns_roce_write64_k(doorbell, hr_qp->rq.db_reg_l);
+		}
+	}
+	spin_unlock_irqrestore(&hr_qp->rq.lock, flags);
+
+	return ret;
+}
+
 static void hns_roce_set_db_event_mode(struct hns_roce_dev *hr_dev,
 				       int sdb_mode, int odb_mode)
 {
@@ -639,6 +1000,1269 @@ void hns_roce_v1_set_mtu(struct hns_roce_dev *hr_dev, u8 phy_port,
 		   val);
 }
 
+static void *get_cqe(struct hns_roce_cq *hr_cq, int n)
+{
+	return hns_roce_buf_offset(&hr_cq->hr_buf.hr_buf,
+				   n * HNS_ROCE_V1_CQE_ENTRY_SIZE);
+}
+
+static void *get_sw_cqe(struct hns_roce_cq *hr_cq, int n)
+{
+	struct hns_roce_cqe *hr_cqe = get_cqe(hr_cq, n & hr_cq->ib_cq.cqe);
+
+	/* Get cqe when Owner bit is Conversely with the MSB of cons_idx */
+	return (roce_get_bit(hr_cqe->cqe_byte_4, CQE_BYTE_4_OWNER_S) ^
+		!!(n & (hr_cq->ib_cq.cqe + 1))) ? hr_cqe : NULL;
+}
+
+void hns_roce_v1_cq_set_ci(struct hns_roce_cq *hr_cq, u32 cons_index,
+			   spinlock_t *doorbell_lock)
+
+{
+	u32 doorbell[2];
+
+	doorbell[0] = cons_index & ((hr_cq->cq_depth << 1) - 1);
+	roce_set_bit(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S, 1);
+	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M,
+		       ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S, 3);
+	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_M,
+		       ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S, 0);
+	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_M,
+		       ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S, hr_cq->cqn);
+
+	hns_roce_write64_k(doorbell, hr_cq->cq_db_l);
+}
+
+static void __hns_roce_v1_cq_clean(struct hns_roce_cq *hr_cq, u32 qpn,
+				   struct hns_roce_srq *srq)
+{
+	struct hns_roce_cqe *cqe, *dest;
+	u32 prod_index;
+	int nfreed = 0;
+	u8 owner_bit;
+
+	for (prod_index = hr_cq->cons_index; get_sw_cqe(hr_cq, prod_index);
+	     ++prod_index) {
+		if (prod_index == hr_cq->cons_index + hr_cq->ib_cq.cqe)
+			break;
+	}
+
+	/*
+	* Now backwards through the CQ, removing CQ entries
+	* that match our QP by overwriting them with next entries.
+	*/
+	while ((int) --prod_index - (int) hr_cq->cons_index >= 0) {
+		cqe = get_cqe(hr_cq, prod_index & hr_cq->ib_cq.cqe);
+		if ((roce_get_field(cqe->cqe_byte_16, CQE_BYTE_16_LOCAL_QPN_M,
+				     CQE_BYTE_16_LOCAL_QPN_S) &
+				     HNS_ROCE_CQE_QPN_MASK) == qpn) {
+			/* In v1 engine, not support SRQ */
+			++nfreed;
+		} else if (nfreed) {
+			dest = get_cqe(hr_cq, (prod_index + nfreed) &
+				       hr_cq->ib_cq.cqe);
+			owner_bit = roce_get_bit(dest->cqe_byte_4,
+						 CQE_BYTE_4_OWNER_S);
+			memcpy(dest, cqe, sizeof(*cqe));
+			roce_set_bit(dest->cqe_byte_4, CQE_BYTE_4_OWNER_S,
+				     owner_bit);
+		}
+	}
+
+	if (nfreed) {
+		hr_cq->cons_index += nfreed;
+		/*
+		* Make sure update of buffer contents is done before
+		* updating consumer index.
+		*/
+		wmb();
+
+		hns_roce_v1_cq_set_ci(hr_cq, hr_cq->cons_index,
+				   &to_hr_dev(hr_cq->ib_cq.device)->cq_db_lock);
+	}
+}
+
+static void hns_roce_v1_cq_clean(struct hns_roce_cq *hr_cq, u32 qpn,
+				 struct hns_roce_srq *srq)
+{
+	spin_lock_irq(&hr_cq->lock);
+	__hns_roce_v1_cq_clean(hr_cq, qpn, srq);
+	spin_unlock_irq(&hr_cq->lock);
+}
+
+static int hns_roce_v1_qp_modify(struct hns_roce_dev *hr_dev,
+				 struct hns_roce_mtt *mtt,
+				 enum hns_roce_qp_state cur_state,
+				 enum hns_roce_qp_state new_state,
+				 struct hns_roce_qp_context *context,
+				 struct hns_roce_qp *hr_qp)
+{
+	static const u16
+	op[HNS_ROCE_QP_NUM_STATE][HNS_ROCE_QP_NUM_STATE] = {
+		[HNS_ROCE_QP_STATE_RST] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_INIT] = HNS_ROCE_CMD_RST2INIT_QP,
+		},
+		[HNS_ROCE_QP_STATE_INIT] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		/* Note: In v1 engine, HW doesn't support RST2INIT.
+		 * We use RST2INIT cmd instead of INIT2INIT.
+		 */
+		[HNS_ROCE_QP_STATE_INIT] = HNS_ROCE_CMD_RST2INIT_QP,
+		[HNS_ROCE_QP_STATE_RTR] = HNS_ROCE_CMD_INIT2RTR_QP,
+		},
+		[HNS_ROCE_QP_STATE_RTR] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_RTS] = HNS_ROCE_CMD_RTR2RTS_QP,
+		},
+		[HNS_ROCE_QP_STATE_RTS] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_RTS] = HNS_ROCE_CMD_RTS2RTS_QP,
+		[HNS_ROCE_QP_STATE_SQD] = HNS_ROCE_CMD_RTS2SQD_QP,
+		},
+		[HNS_ROCE_QP_STATE_SQD] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		[HNS_ROCE_QP_STATE_RTS] = HNS_ROCE_CMD_SQD2RTS_QP,
+		[HNS_ROCE_QP_STATE_SQD] = HNS_ROCE_CMD_SQD2SQD_QP,
+		},
+		[HNS_ROCE_QP_STATE_ERR] = {
+		[HNS_ROCE_QP_STATE_RST] = HNS_ROCE_CMD_2RST_QP,
+		[HNS_ROCE_QP_STATE_ERR] = HNS_ROCE_CMD_2ERR_QP,
+		}
+	};
+
+	struct hns_roce_cmd_mailbox *mailbox;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret = 0;
+
+	if (cur_state >= HNS_ROCE_QP_NUM_STATE ||
+	    new_state >= HNS_ROCE_QP_NUM_STATE ||
+	    !op[cur_state][new_state]) {
+		dev_err(dev, "[modify_qp]not support state %d to %d\n",
+			cur_state, new_state);
+		return -EINVAL;
+	}
+
+	if (op[cur_state][new_state] == HNS_ROCE_CMD_2RST_QP)
+		return hns_roce_cmd_mbox(hr_dev, 0, 0, hr_qp->qpn, 2,
+					 HNS_ROCE_CMD_2RST_QP,
+					 HNS_ROCE_CMD_TIME_CLASS_A);
+
+	if (op[cur_state][new_state] == HNS_ROCE_CMD_2ERR_QP)
+		return hns_roce_cmd_mbox(hr_dev, 0, 0, hr_qp->qpn, 2,
+					 HNS_ROCE_CMD_2ERR_QP,
+					 HNS_ROCE_CMD_TIME_CLASS_A);
+
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	memcpy(mailbox->buf, context, sizeof(*context));
+
+	ret = hns_roce_cmd_mbox(hr_dev, mailbox->dma, 0, hr_qp->qpn, 0,
+				op[cur_state][new_state],
+				HNS_ROCE_CMD_TIME_CLASS_C);
+
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+	return ret;
+}
+
+static int hns_roce_v1_m_sqp(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
+			     int attr_mask, enum ib_qp_state cur_state,
+			     enum ib_qp_state new_state)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct hns_roce_sqp_context *context;
+	struct device *dev = &hr_dev->pdev->dev;
+	dma_addr_t dma_handle = 0;
+	int rq_pa_start;
+	u32 reg_val;
+	u64 *mtts;
+	u32 *addr;
+
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return -ENOMEM;
+
+	/* Search QP buf's MTTs */
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+				   hr_qp->mtt.first_seg, &dma_handle);
+	if (!mtts) {
+		dev_err(dev, "qp buf pa find failed\n");
+		goto out;
+	}
+
+	if (cur_state == IB_QPS_RESET && new_state == IB_QPS_INIT) {
+		roce_set_field(context->qp1c_bytes_4,
+			       QP1C_BYTES_4_SQ_WQE_SHIFT_M,
+			       QP1C_BYTES_4_SQ_WQE_SHIFT_S,
+			       ilog2((unsigned int)hr_qp->sq.wqe_cnt));
+		roce_set_field(context->qp1c_bytes_4,
+			       QP1C_BYTES_4_RQ_WQE_SHIFT_M,
+			       QP1C_BYTES_4_RQ_WQE_SHIFT_S,
+			       ilog2((unsigned int)hr_qp->rq.wqe_cnt));
+		roce_set_field(context->qp1c_bytes_4, QP1C_BYTES_4_PD_M,
+			       QP1C_BYTES_4_PD_S, to_hr_pd(ibqp->pd)->pdn);
+
+		context->sq_rq_bt_l = (u32)(dma_handle);
+		roce_set_field(context->qp1c_bytes_12,
+			       QP1C_BYTES_12_SQ_RQ_BT_H_M,
+			       QP1C_BYTES_12_SQ_RQ_BT_H_S,
+			       ((u32)(dma_handle >> 32)));
+
+		roce_set_field(context->qp1c_bytes_16, QP1C_BYTES_16_RQ_HEAD_M,
+			       QP1C_BYTES_16_RQ_HEAD_S, hr_qp->rq.head);
+		roce_set_field(context->qp1c_bytes_16, QP1C_BYTES_16_PORT_NUM_M,
+			       QP1C_BYTES_16_PORT_NUM_S, hr_qp->port);
+		roce_set_bit(context->qp1c_bytes_16,
+			     QP1C_BYTES_16_SIGNALING_TYPE_S,
+			     hr_qp->sq_signal_bits);
+		roce_set_bit(context->qp1c_bytes_16,
+			     QP1C_BYTES_16_LOCAL_ENABLE_E2E_CREDIT_S,
+			     hr_qp->sq_signal_bits);
+		roce_set_bit(context->qp1c_bytes_16, QP1C_BYTES_16_RQ_BA_FLG_S,
+			     1);
+		roce_set_bit(context->qp1c_bytes_16, QP1C_BYTES_16_SQ_BA_FLG_S,
+			     1);
+		roce_set_bit(context->qp1c_bytes_16, QP1C_BYTES_16_QP1_ERR_S,
+			     0);
+
+		roce_set_field(context->qp1c_bytes_20, QP1C_BYTES_20_SQ_HEAD_M,
+			       QP1C_BYTES_20_SQ_HEAD_S, hr_qp->sq.head);
+		roce_set_field(context->qp1c_bytes_20, QP1C_BYTES_20_PKEY_IDX_M,
+			       QP1C_BYTES_20_PKEY_IDX_S, attr->pkey_index);
+
+		rq_pa_start = (u32)hr_qp->rq.offset / PAGE_SIZE;
+		context->cur_rq_wqe_ba_l = (u32)(mtts[rq_pa_start]);
+
+		roce_set_field(context->qp1c_bytes_28,
+			       QP1C_BYTES_28_CUR_RQ_WQE_BA_H_M,
+			       QP1C_BYTES_28_CUR_RQ_WQE_BA_H_S,
+			       (mtts[rq_pa_start]) >> 32);
+		roce_set_field(context->qp1c_bytes_28,
+			       QP1C_BYTES_28_RQ_CUR_IDX_M,
+			       QP1C_BYTES_28_RQ_CUR_IDX_S, 0);
+
+		roce_set_field(context->qp1c_bytes_32,
+			       QP1C_BYTES_32_RX_CQ_NUM_M,
+			       QP1C_BYTES_32_RX_CQ_NUM_S,
+			       to_hr_cq(ibqp->recv_cq)->cqn);
+		roce_set_field(context->qp1c_bytes_32,
+			       QP1C_BYTES_32_TX_CQ_NUM_M,
+			       QP1C_BYTES_32_TX_CQ_NUM_S,
+			       to_hr_cq(ibqp->send_cq)->cqn);
+
+		context->cur_sq_wqe_ba_l  = (u32)mtts[0];
+
+		roce_set_field(context->qp1c_bytes_40,
+			       QP1C_BYTES_40_CUR_SQ_WQE_BA_H_M,
+			       QP1C_BYTES_40_CUR_SQ_WQE_BA_H_S,
+			       (mtts[0]) >> 32);
+		roce_set_field(context->qp1c_bytes_40,
+			       QP1C_BYTES_40_SQ_CUR_IDX_M,
+			       QP1C_BYTES_40_SQ_CUR_IDX_S, 0);
+
+		/* Copy context to QP1C register */
+		addr = (u32 *)(hr_dev->reg_base + ROCEE_QP1C_CFG0_0_REG +
+			hr_qp->port * sizeof(*context));
+
+		writel(context->qp1c_bytes_4, addr);
+		writel(context->sq_rq_bt_l, addr + 1);
+		writel(context->qp1c_bytes_12, addr + 2);
+		writel(context->qp1c_bytes_16, addr + 3);
+		writel(context->qp1c_bytes_20, addr + 4);
+		writel(context->cur_rq_wqe_ba_l, addr + 5);
+		writel(context->qp1c_bytes_28, addr + 6);
+		writel(context->qp1c_bytes_32, addr + 7);
+		writel(context->cur_sq_wqe_ba_l, addr + 8);
+	}
+
+	/* Modify QP1C status */
+	reg_val = roce_read(hr_dev, ROCEE_QP1C_CFG0_0_REG +
+			    hr_qp->port * sizeof(*context));
+	roce_set_field(reg_val, ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_M,
+		       ROCEE_QP1C_CFG0_0_ROCEE_QP1C_QP_ST_S, new_state);
+	roce_write(hr_dev, ROCEE_QP1C_CFG0_0_REG +
+		    hr_qp->port * sizeof(*context), reg_val);
+
+	hr_qp->state = new_state;
+	if (new_state == IB_QPS_RESET) {
+		hns_roce_v1_cq_clean(to_hr_cq(ibqp->recv_cq), hr_qp->qpn,
+				     ibqp->srq ? to_hr_srq(ibqp->srq) : NULL);
+		if (ibqp->send_cq != ibqp->recv_cq)
+			hns_roce_v1_cq_clean(to_hr_cq(ibqp->send_cq),
+					     hr_qp->qpn, NULL);
+
+		hr_qp->rq.head = 0;
+		hr_qp->rq.tail = 0;
+		hr_qp->sq.head = 0;
+		hr_qp->sq.tail = 0;
+		hr_qp->sq_next_wqe = 0;
+	}
+
+	kfree(context);
+	return 0;
+
+out:
+	kfree(context);
+	return -EINVAL;
+}
+
+static int hns_roce_v1_m_qp(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
+			    int attr_mask, enum ib_qp_state cur_state,
+			    enum ib_qp_state new_state)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_qp_context *context;
+	struct hns_roce_rq_db rq_db;
+	dma_addr_t dma_handle_2 = 0;
+	dma_addr_t dma_handle = 0;
+	uint32_t doorbell[2] = {0};
+	int rq_pa_start = 0;
+	u32 reg_val = 0;
+	u64 *mtts_2 = NULL;
+	int ret = -EINVAL;
+	u64 *mtts = NULL;
+	int port;
+	u8 *dmac;
+	u8 *smac;
+
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return -ENOMEM;
+
+	/* Search qp buf's mtts */
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+				   hr_qp->mtt.first_seg, &dma_handle);
+	if (mtts == NULL) {
+		dev_err(dev, "qp buf pa find failed\n");
+		goto out;
+	}
+
+	/* Search IRRL's mtts */
+	mtts_2 = hns_roce_table_find(&hr_dev->qp_table.irrl_table, hr_qp->qpn,
+				     &dma_handle_2);
+	if (mtts_2 == NULL) {
+		dev_err(dev, "qp irrl_table find failed\n");
+		goto out;
+	}
+
+	/*
+	*Reset to init
+	*	Mandatory param:
+	*	IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_PORT | IB_QP_ACCESS_FLAGS
+	*	Optional param: NA
+	*/
+	if (cur_state == IB_QPS_RESET && new_state == IB_QPS_INIT) {
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_M,
+			       QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S,
+			       to_hr_qp_type(hr_qp->ibqp.qp_type));
+
+		roce_set_bit(context->qpc_bytes_4,
+			     QP_CONTEXT_QPC_BYTE_4_ENABLE_FPMR_S, 0);
+		roce_set_bit(context->qpc_bytes_4,
+			     QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S,
+			     !!(attr->qp_access_flags & IB_ACCESS_REMOTE_READ));
+		roce_set_bit(context->qpc_bytes_4,
+			     QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S,
+			     !!(attr->qp_access_flags & IB_ACCESS_REMOTE_WRITE)
+			     );
+		roce_set_bit(context->qpc_bytes_4,
+			     QP_CONTEXT_QPC_BYTE_4_ATOMIC_OPERATION_ENABLE_S,
+			     !!(attr->qp_access_flags & IB_ACCESS_REMOTE_ATOMIC)
+			     );
+		roce_set_bit(context->qpc_bytes_4,
+			     QP_CONTEXT_QPC_BYTE_4_RDMAR_USE_S, 1);
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_M,
+			       QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S,
+			       ilog2((unsigned int)hr_qp->sq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_M,
+			       QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S,
+			       ilog2((unsigned int)hr_qp->rq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_PD_M,
+			       QP_CONTEXT_QPC_BYTES_4_PD_S,
+			       to_hr_pd(ibqp->pd)->pdn);
+		hr_qp->access_flags = attr->qp_access_flags;
+		roce_set_field(context->qpc_bytes_8,
+			       QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_M,
+			       QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S,
+			       to_hr_cq(ibqp->send_cq)->cqn);
+		roce_set_field(context->qpc_bytes_8,
+			       QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_M,
+			       QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S,
+			       to_hr_cq(ibqp->recv_cq)->cqn);
+
+		if (ibqp->srq)
+			roce_set_field(context->qpc_bytes_12,
+				       QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_M,
+				       QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S,
+				       to_hr_srq(ibqp->srq)->srqn);
+
+		roce_set_field(context->qpc_bytes_12,
+			       QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+			       QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S,
+			       attr->pkey_index);
+		hr_qp->pkey_index = attr->pkey_index;
+		roce_set_field(context->qpc_bytes_16,
+			       QP_CONTEXT_QPC_BYTES_16_QP_NUM_M,
+			       QP_CONTEXT_QPC_BYTES_16_QP_NUM_S, hr_qp->qpn);
+
+	} else if (cur_state == IB_QPS_INIT && new_state == IB_QPS_INIT) {
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_M,
+			       QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S,
+			       to_hr_qp_type(hr_qp->ibqp.qp_type));
+		roce_set_bit(context->qpc_bytes_4,
+			     QP_CONTEXT_QPC_BYTE_4_ENABLE_FPMR_S, 0);
+		if (attr_mask & IB_QP_ACCESS_FLAGS) {
+			roce_set_bit(context->qpc_bytes_4,
+				     QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S,
+				     !!(attr->qp_access_flags &
+				     IB_ACCESS_REMOTE_READ));
+			roce_set_bit(context->qpc_bytes_4,
+				     QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S,
+				     !!(attr->qp_access_flags &
+				     IB_ACCESS_REMOTE_WRITE));
+		} else {
+			roce_set_bit(context->qpc_bytes_4,
+				     QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S,
+				     !!(hr_qp->access_flags &
+				     IB_ACCESS_REMOTE_READ));
+			roce_set_bit(context->qpc_bytes_4,
+				     QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S,
+				     !!(hr_qp->access_flags &
+				     IB_ACCESS_REMOTE_WRITE));
+		}
+
+		roce_set_bit(context->qpc_bytes_4,
+			     QP_CONTEXT_QPC_BYTE_4_RDMAR_USE_S, 1);
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_M,
+			       QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S,
+			       ilog2((unsigned int)hr_qp->sq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_M,
+			       QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S,
+			       ilog2((unsigned int)hr_qp->rq.wqe_cnt));
+		roce_set_field(context->qpc_bytes_4,
+			       QP_CONTEXT_QPC_BYTES_4_PD_M,
+			       QP_CONTEXT_QPC_BYTES_4_PD_S,
+			       to_hr_pd(ibqp->pd)->pdn);
+
+		roce_set_field(context->qpc_bytes_8,
+			       QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_M,
+			       QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S,
+			       to_hr_cq(ibqp->send_cq)->cqn);
+		roce_set_field(context->qpc_bytes_8,
+			       QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_M,
+			       QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S,
+			       to_hr_cq(ibqp->recv_cq)->cqn);
+
+		if (ibqp->srq)
+			roce_set_field(context->qpc_bytes_12,
+				       QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_M,
+				       QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S,
+				       to_hr_srq(ibqp->srq)->srqn);
+		if (attr_mask & IB_QP_PKEY_INDEX)
+			roce_set_field(context->qpc_bytes_12,
+				       QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+				       QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S,
+				       attr->pkey_index);
+		else
+			roce_set_field(context->qpc_bytes_12,
+				       QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+				       QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S,
+				       hr_qp->pkey_index);
+
+		roce_set_field(context->qpc_bytes_16,
+			       QP_CONTEXT_QPC_BYTES_16_QP_NUM_M,
+			       QP_CONTEXT_QPC_BYTES_16_QP_NUM_S, hr_qp->qpn);
+	} else if (cur_state == IB_QPS_INIT && new_state == IB_QPS_RTR) {
+		if ((attr_mask & IB_QP_ALT_PATH) ||
+		    (attr_mask & IB_QP_ACCESS_FLAGS) ||
+		    (attr_mask & IB_QP_PKEY_INDEX) ||
+		    (attr_mask & IB_QP_QKEY)) {
+			dev_err(dev, "INIT2RTR attr_mask error\n");
+			goto out;
+		}
+
+		dmac = (u8 *)attr->ah_attr.dmac;
+
+		context->sq_rq_bt_l = (u32)(dma_handle);
+		roce_set_field(context->qpc_bytes_24,
+			       QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_M,
+			       QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_S,
+			       ((u32)(dma_handle >> 32)));
+		roce_set_bit(context->qpc_bytes_24,
+			     QP_CONTEXT_QPC_BYTE_24_REMOTE_ENABLE_E2E_CREDITS_S,
+			     1);
+		roce_set_field(context->qpc_bytes_24,
+			       QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_M,
+			       QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S,
+			       attr->min_rnr_timer);
+		context->irrl_ba_l = (u32)(dma_handle_2);
+		roce_set_field(context->qpc_bytes_32,
+			       QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_M,
+			       QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_S,
+			       ((u32)(dma_handle_2 >> 32)) &
+				QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_M);
+		roce_set_field(context->qpc_bytes_32,
+			       QP_CONTEXT_QPC_BYTES_32_MIG_STATE_M,
+			       QP_CONTEXT_QPC_BYTES_32_MIG_STATE_S, 0);
+		roce_set_bit(context->qpc_bytes_32,
+			     QP_CONTEXT_QPC_BYTE_32_LOCAL_ENABLE_E2E_CREDITS_S,
+			     1);
+		roce_set_bit(context->qpc_bytes_32,
+			     QP_CONTEXT_QPC_BYTE_32_SIGNALING_TYPE_S,
+			     hr_qp->sq_signal_bits);
+
+		for (port = 0; port < hr_dev->caps.num_ports; port++) {
+			smac = (u8 *)hr_dev->dev_addr[port];
+			dev_dbg(dev, "smac: %2x: %2x: %2x: %2x: %2x: %2x\n",
+				smac[0], smac[1], smac[2], smac[3], smac[4],
+				smac[5]);
+			if ((dmac[0] == smac[0]) && (dmac[1] == smac[1]) &&
+			    (dmac[2] == smac[2]) && (dmac[3] == smac[3]) &&
+			    (dmac[4] == smac[4]) && (dmac[5] == smac[5])) {
+				roce_set_bit(context->qpc_bytes_32,
+				    QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S,
+				    1);
+				break;
+			}
+		}
+
+		if (hr_dev->loop_idc == 0x1)
+			roce_set_bit(context->qpc_bytes_32,
+				QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S, 1);
+
+		roce_set_bit(context->qpc_bytes_32,
+			     QP_CONTEXT_QPC_BYTE_32_GLOBAL_HEADER_S,
+			     attr->ah_attr.ah_flags);
+		roce_set_field(context->qpc_bytes_32,
+			       QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_M,
+			       QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S,
+			       ilog2((unsigned int)attr->max_dest_rd_atomic));
+
+		roce_set_field(context->qpc_bytes_36,
+			       QP_CONTEXT_QPC_BYTES_36_DEST_QP_M,
+			       QP_CONTEXT_QPC_BYTES_36_DEST_QP_S,
+			       attr->dest_qp_num);
+
+		/* Configure GID index */
+		roce_set_field(context->qpc_bytes_36,
+			       QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_M,
+			       QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S,
+			       hns_get_gid_index(hr_dev,
+						 attr->ah_attr.port_num - 1,
+						 attr->ah_attr.grh.sgid_index));
+
+		memcpy(&(context->dmac_l), dmac, 4);
+
+		roce_set_field(context->qpc_bytes_44,
+			       QP_CONTEXT_QPC_BYTES_44_DMAC_H_M,
+			       QP_CONTEXT_QPC_BYTES_44_DMAC_H_S,
+			       *((u16 *)(&dmac[4])));
+		roce_set_field(context->qpc_bytes_44,
+			       QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_M,
+			       QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_S,
+			       attr->ah_attr.static_rate);
+		roce_set_field(context->qpc_bytes_44,
+			       QP_CONTEXT_QPC_BYTES_44_HOPLMT_M,
+			       QP_CONTEXT_QPC_BYTES_44_HOPLMT_S,
+			       attr->ah_attr.grh.hop_limit);
+
+		roce_set_field(context->qpc_bytes_48,
+			       QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_M,
+			       QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S,
+			       attr->ah_attr.grh.flow_label);
+		roce_set_field(context->qpc_bytes_48,
+			       QP_CONTEXT_QPC_BYTES_48_TCLASS_M,
+			       QP_CONTEXT_QPC_BYTES_48_TCLASS_S,
+			       attr->ah_attr.grh.traffic_class);
+		roce_set_field(context->qpc_bytes_48,
+			       QP_CONTEXT_QPC_BYTES_48_MTU_M,
+			       QP_CONTEXT_QPC_BYTES_48_MTU_S, attr->path_mtu);
+
+		memcpy(context->dgid, attr->ah_attr.grh.dgid.raw,
+		       sizeof(attr->ah_attr.grh.dgid.raw));
+
+		dev_dbg(dev, "dmac:%x :%lx\n", context->dmac_l,
+			roce_get_field(context->qpc_bytes_44,
+				       QP_CONTEXT_QPC_BYTES_44_DMAC_H_M,
+				       QP_CONTEXT_QPC_BYTES_44_DMAC_H_S));
+
+		roce_set_field(context->qpc_bytes_68,
+			       QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_M,
+			       QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_S, 0);
+		roce_set_field(context->qpc_bytes_68,
+			       QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_M,
+			       QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_S, 0);
+
+		rq_pa_start = (u32)hr_qp->rq.offset / PAGE_SIZE;
+		context->cur_rq_wqe_ba_l = (u32)(mtts[rq_pa_start]);
+
+		roce_set_field(context->qpc_bytes_76,
+			QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_M,
+			QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_S,
+			mtts[rq_pa_start] >> 32);
+		roce_set_field(context->qpc_bytes_76,
+			       QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_M,
+			       QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_S, 0);
+
+		context->rx_rnr_time = 0;
+
+		roce_set_field(context->qpc_bytes_84,
+			       QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_M,
+			       QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_S,
+			       attr->rq_psn - 1);
+		roce_set_field(context->qpc_bytes_84,
+			       QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_M,
+			       QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_S, 0);
+
+		roce_set_field(context->qpc_bytes_88,
+			       QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_M,
+			       QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S,
+			       attr->rq_psn);
+		roce_set_bit(context->qpc_bytes_88,
+			     QP_CONTEXT_QPC_BYTES_88_RX_REQ_PSN_ERR_FLAG_S, 0);
+		roce_set_bit(context->qpc_bytes_88,
+			     QP_CONTEXT_QPC_BYTES_88_RX_LAST_OPCODE_FLG_S, 0);
+		roce_set_field(context->qpc_bytes_88,
+			QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_M,
+			QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_S,
+			0);
+		roce_set_field(context->qpc_bytes_88,
+			       QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_M,
+			       QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_S,
+			       0);
+
+		context->dma_length = 0;
+		context->r_key = 0;
+		context->va_l = 0;
+		context->va_h = 0;
+
+		roce_set_field(context->qpc_bytes_108,
+			       QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_M,
+			       QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_S, 0);
+		roce_set_bit(context->qpc_bytes_108,
+			     QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_FLG_S, 0);
+		roce_set_bit(context->qpc_bytes_108,
+			     QP_CONTEXT_QPC_BYTES_108_TRRL_TDB_PSN_FLG_S, 0);
+
+		roce_set_field(context->qpc_bytes_112,
+			       QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_M,
+			       QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_S, 0);
+		roce_set_field(context->qpc_bytes_112,
+			       QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_M,
+			       QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_S, 0);
+
+		/* For chip resp ack */
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M,
+			       QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S,
+			       hr_qp->port);
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_SL_M,
+			       QP_CONTEXT_QPC_BYTES_156_SL_S, attr->ah_attr.sl);
+		hr_qp->sl = attr->ah_attr.sl;
+	} else if (cur_state == IB_QPS_RTR &&
+		new_state == IB_QPS_RTS) {
+		/* If exist optional param, return error */
+		if ((attr_mask & IB_QP_ALT_PATH) ||
+		    (attr_mask & IB_QP_ACCESS_FLAGS) ||
+		    (attr_mask & IB_QP_QKEY) ||
+		    (attr_mask & IB_QP_PATH_MIG_STATE) ||
+		    (attr_mask & IB_QP_CUR_STATE) ||
+		    (attr_mask & IB_QP_MIN_RNR_TIMER)) {
+			dev_err(dev, "RTR2RTS attr_mask error\n");
+			goto out;
+		}
+
+		context->rx_cur_sq_wqe_ba_l = (u32)(mtts[0]);
+
+		roce_set_field(context->qpc_bytes_120,
+			       QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_M,
+			       QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_S,
+			       (mtts[0]) >> 32);
+
+		roce_set_field(context->qpc_bytes_124,
+			       QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_M,
+			       QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_S, 0);
+		roce_set_field(context->qpc_bytes_124,
+			       QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_M,
+			       QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_S, 0);
+
+		roce_set_field(context->qpc_bytes_128,
+			       QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_M,
+			       QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_S,
+			       attr->sq_psn);
+		roce_set_bit(context->qpc_bytes_128,
+			     QP_CONTEXT_QPC_BYTES_128_RX_ACK_PSN_ERR_FLG_S, 0);
+		roce_set_field(context->qpc_bytes_128,
+			     QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_M,
+			     QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_S,
+			     0);
+		roce_set_bit(context->qpc_bytes_128,
+			     QP_CONTEXT_QPC_BYTES_128_IRRL_PSN_VLD_FLG_S, 0);
+
+		roce_set_field(context->qpc_bytes_132,
+			       QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_M,
+			       QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_S, 0);
+		roce_set_field(context->qpc_bytes_132,
+			       QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_M,
+			       QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_S, 0);
+
+		roce_set_field(context->qpc_bytes_136,
+			       QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_M,
+			       QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_S,
+			       attr->sq_psn);
+		roce_set_field(context->qpc_bytes_136,
+			       QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_M,
+			       QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_S,
+			       attr->sq_psn);
+
+		roce_set_field(context->qpc_bytes_140,
+			       QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_M,
+			       QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_S,
+			       (attr->sq_psn >> SQ_PSN_SHIFT));
+		roce_set_field(context->qpc_bytes_140,
+			       QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_M,
+			       QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_S, 0);
+		roce_set_bit(context->qpc_bytes_140,
+			     QP_CONTEXT_QPC_BYTES_140_RNR_RETRY_FLG_S, 0);
+
+		roce_set_field(context->qpc_bytes_144,
+			       QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+			       QP_CONTEXT_QPC_BYTES_144_QP_STATE_S,
+			       attr->qp_state);
+
+		roce_set_field(context->qpc_bytes_148,
+			       QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_M,
+			       QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_S, 0);
+		roce_set_field(context->qpc_bytes_148,
+			       QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_M,
+			       QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S, 0);
+		roce_set_field(context->qpc_bytes_148,
+			       QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_M,
+			       QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_S, 0);
+		roce_set_field(context->qpc_bytes_148,
+			       QP_CONTEXT_QPC_BYTES_148_LSN_M,
+			       QP_CONTEXT_QPC_BYTES_148_LSN_S, 0x100);
+
+		context->rnr_retry = 0;
+
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_M,
+			       QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_S,
+			       attr->retry_cnt);
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_M,
+			       QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S,
+			       attr->timeout);
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_M,
+			       QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_S,
+			       attr->rnr_retry);
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M,
+			       QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S,
+			       hr_qp->port);
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_SL_M,
+			       QP_CONTEXT_QPC_BYTES_156_SL_S, attr->ah_attr.sl);
+		hr_qp->sl = attr->ah_attr.sl;
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_M,
+			       QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S,
+			       ilog2((unsigned int)attr->max_rd_atomic));
+		roce_set_field(context->qpc_bytes_156,
+			       QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_M,
+			       QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_S, 0);
+		context->pkt_use_len = 0;
+
+		roce_set_field(context->qpc_bytes_164,
+			       QP_CONTEXT_QPC_BYTES_164_SQ_PSN_M,
+			       QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S, attr->sq_psn);
+		roce_set_field(context->qpc_bytes_164,
+			       QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_M,
+			       QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_S, 0);
+
+		roce_set_field(context->qpc_bytes_168,
+			       QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_M,
+			       QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_S,
+			       attr->sq_psn);
+		roce_set_field(context->qpc_bytes_168,
+			       QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_M,
+			       QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_S, 0);
+		roce_set_field(context->qpc_bytes_168,
+			       QP_CONTEXT_QPC_BYTES_168_DB_TYPE_M,
+			       QP_CONTEXT_QPC_BYTES_168_DB_TYPE_S, 0);
+		roce_set_bit(context->qpc_bytes_168,
+			     QP_CONTEXT_QPC_BYTES_168_MSG_LP_IND_S, 0);
+		roce_set_bit(context->qpc_bytes_168,
+			     QP_CONTEXT_QPC_BYTES_168_CSDB_LP_IND_S, 0);
+		roce_set_bit(context->qpc_bytes_168,
+			     QP_CONTEXT_QPC_BYTES_168_QP_ERR_FLG_S, 0);
+		context->sge_use_len = 0;
+
+		roce_set_field(context->qpc_bytes_176,
+			       QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_M,
+			       QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_S, 0);
+		roce_set_field(context->qpc_bytes_176,
+			       QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_M,
+			       QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_S,
+			       0);
+		roce_set_field(context->qpc_bytes_180,
+			       QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_M,
+			       QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_S, 0);
+		roce_set_field(context->qpc_bytes_180,
+			       QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_M,
+			       QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_S, 0);
+
+		context->tx_cur_sq_wqe_ba_l = (u32)(mtts[0]);
+
+		roce_set_field(context->qpc_bytes_188,
+			       QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_M,
+			       QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_S,
+			       (mtts[0]) >> 32);
+		roce_set_bit(context->qpc_bytes_188,
+			     QP_CONTEXT_QPC_BYTES_188_PKT_RETRY_FLG_S, 0);
+		roce_set_field(context->qpc_bytes_188,
+			       QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_M,
+			       QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_S,
+			       0);
+	} else if ((cur_state == IB_QPS_INIT && new_state == IB_QPS_RESET) ||
+		   (cur_state == IB_QPS_INIT && new_state == IB_QPS_ERR) ||
+		   (cur_state == IB_QPS_RTR && new_state == IB_QPS_RESET) ||
+		   (cur_state == IB_QPS_RTR && new_state == IB_QPS_ERR) ||
+		   (cur_state == IB_QPS_RTS && new_state == IB_QPS_RESET) ||
+		   (cur_state == IB_QPS_RTS && new_state == IB_QPS_ERR) ||
+		   (cur_state == IB_QPS_ERR && new_state == IB_QPS_RESET) ||
+		   (cur_state == IB_QPS_ERR && new_state == IB_QPS_ERR)) {
+		roce_set_field(context->qpc_bytes_144,
+			       QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+			       QP_CONTEXT_QPC_BYTES_144_QP_STATE_S,
+			       attr->qp_state);
+
+	} else {
+		dev_err(dev, "not support this modify\n");
+		goto out;
+	}
+
+	/* Every status migrate must change state */
+	roce_set_field(context->qpc_bytes_144,
+		       QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+		       QP_CONTEXT_QPC_BYTES_144_QP_STATE_S, attr->qp_state);
+
+	/* SW pass context to HW */
+	ret = hns_roce_v1_qp_modify(hr_dev, &hr_qp->mtt,
+				    to_hns_roce_state(cur_state),
+				    to_hns_roce_state(new_state), context,
+				    hr_qp);
+	if (ret) {
+		dev_err(dev, "hns_roce_qp_modify failed\n");
+		goto out;
+	}
+
+	/*
+	* Use rst2init to instead of init2init with drv,
+	* need to hw to flash RQ HEAD by DB again
+	*/
+	if (cur_state == IB_QPS_INIT && new_state == IB_QPS_INIT) {
+		/* Memory barrier */
+		wmb();
+		if (hr_qp->ibqp.qp_type == IB_QPT_GSI) {
+			/* SW update GSI rq header */
+			reg_val = roce_read(hr_dev, ROCEE_QP1C_CFG3_0_REG +
+					    QP1C_CFGN_OFFSET * hr_qp->port);
+			roce_set_field(reg_val,
+				       ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_M,
+				       ROCEE_QP1C_CFG3_0_ROCEE_QP1C_RQ_HEAD_S,
+				       hr_qp->rq.head);
+			roce_write(hr_dev, ROCEE_QP1C_CFG3_0_REG +
+				    QP1C_CFGN_OFFSET * hr_qp->port, reg_val);
+		} else {
+			rq_db.u32_4 = 0;
+			rq_db.u32_8 = 0;
+
+			roce_set_field(rq_db.u32_4, RQ_DOORBELL_U32_4_RQ_HEAD_M,
+				       RQ_DOORBELL_U32_4_RQ_HEAD_S,
+				       hr_qp->rq.head);
+			roce_set_field(rq_db.u32_8, RQ_DOORBELL_U32_8_QPN_M,
+				       RQ_DOORBELL_U32_8_QPN_S, hr_qp->qpn);
+			roce_set_field(rq_db.u32_8, RQ_DOORBELL_U32_8_CMD_M,
+				       RQ_DOORBELL_U32_8_CMD_S, 1);
+			roce_set_bit(rq_db.u32_8, RQ_DOORBELL_U32_8_HW_SYNC_S,
+				     1);
+
+			doorbell[0] = rq_db.u32_4;
+			doorbell[1] = rq_db.u32_8;
+
+			hns_roce_write64_k(doorbell, hr_qp->rq.db_reg_l);
+		}
+	}
+
+	hr_qp->state = new_state;
+
+	if (attr_mask & IB_QP_MAX_DEST_RD_ATOMIC)
+		hr_qp->resp_depth = attr->max_dest_rd_atomic;
+	if (attr_mask & IB_QP_PORT)
+		hr_qp->port = (attr->port_num - 1);
+
+	if (new_state == IB_QPS_RESET && !ibqp->uobject) {
+		hns_roce_v1_cq_clean(to_hr_cq(ibqp->recv_cq), hr_qp->qpn,
+				     ibqp->srq ? to_hr_srq(ibqp->srq) : NULL);
+		if (ibqp->send_cq != ibqp->recv_cq)
+			hns_roce_v1_cq_clean(to_hr_cq(ibqp->send_cq),
+					     hr_qp->qpn, NULL);
+
+		hr_qp->rq.head = 0;
+		hr_qp->rq.tail = 0;
+		hr_qp->sq.head = 0;
+		hr_qp->sq.tail = 0;
+		hr_qp->sq_next_wqe = 0;
+	}
+out:
+	kfree(context);
+	return ret;
+}
+
+int hns_roce_v1_modify_qp(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
+			  int attr_mask, enum ib_qp_state cur_state,
+			  enum ib_qp_state new_state)
+{
+
+	if (ibqp->qp_type == IB_QPT_GSI || ibqp->qp_type == IB_QPT_SMI)
+		return hns_roce_v1_m_sqp(ibqp, attr, attr_mask, cur_state,
+					 new_state);
+	else
+		return hns_roce_v1_m_qp(ibqp, attr, attr_mask, cur_state,
+					new_state);
+}
+
+static enum ib_qp_state to_ib_qp_state(enum hns_roce_qp_state state)
+{
+	switch (state) {
+	case HNS_ROCE_QP_STATE_RST:
+		return IB_QPS_RESET;
+	case HNS_ROCE_QP_STATE_INIT:
+		return IB_QPS_INIT;
+	case HNS_ROCE_QP_STATE_RTR:
+		return IB_QPS_RTR;
+	case HNS_ROCE_QP_STATE_RTS:
+		return IB_QPS_RTS;
+	case HNS_ROCE_QP_STATE_SQD:
+		return IB_QPS_SQD;
+	case HNS_ROCE_QP_STATE_ERR:
+		return IB_QPS_ERR;
+	default:
+		return IB_QPS_ERR;
+	}
+}
+
+static int hns_roce_v1_query_qpc(struct hns_roce_dev *hr_dev,
+				 struct hns_roce_qp *hr_qp,
+				 struct hns_roce_qp_context *hr_context)
+{
+	struct hns_roce_cmd_mailbox *mailbox;
+	int ret;
+
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	ret = hns_roce_cmd_mbox(hr_dev, 0, mailbox->dma, hr_qp->qpn, 0,
+				HNS_ROCE_CMD_QUERY_QP,
+				HNS_ROCE_CMD_TIME_CLASS_A);
+	if (!ret)
+		memcpy(hr_context, mailbox->buf, sizeof(*hr_context));
+	else
+		dev_err(&hr_dev->pdev->dev, "QUERY QP cmd process error\n");
+
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+
+	return ret;
+}
+
+int hns_roce_v1_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
+			 int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_qp_context *context;
+	int tmp_qp_state = 0;
+	int ret = 0;
+	int state;
+
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return -ENOMEM;
+
+	memset(qp_attr, 0, sizeof(*qp_attr));
+	memset(qp_init_attr, 0, sizeof(*qp_init_attr));
+
+	mutex_lock(&hr_qp->mutex);
+
+	if (hr_qp->state == IB_QPS_RESET) {
+		qp_attr->qp_state = IB_QPS_RESET;
+		goto done;
+	}
+
+	ret = hns_roce_v1_query_qpc(hr_dev, hr_qp, context);
+	if (ret) {
+		dev_err(dev, "query qpc error\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	state = roce_get_field(context->qpc_bytes_144,
+			       QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
+			       QP_CONTEXT_QPC_BYTES_144_QP_STATE_S);
+	tmp_qp_state = (int)to_ib_qp_state((enum hns_roce_qp_state)state);
+	if (tmp_qp_state == -1) {
+		dev_err(dev, "to_ib_qp_state error\n");
+		ret = -EINVAL;
+		goto out;
+	}
+	hr_qp->state = (u8)tmp_qp_state;
+	qp_attr->qp_state = (enum ib_qp_state)hr_qp->state;
+	qp_attr->path_mtu = (enum ib_mtu)roce_get_field(context->qpc_bytes_48,
+					       QP_CONTEXT_QPC_BYTES_48_MTU_M,
+					       QP_CONTEXT_QPC_BYTES_48_MTU_S);
+	qp_attr->path_mig_state = IB_MIG_ARMED;
+	if (hr_qp->ibqp.qp_type == IB_QPT_UD)
+		qp_attr->qkey = QKEY_VAL;
+
+	qp_attr->rq_psn = roce_get_field(context->qpc_bytes_88,
+					 QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_M,
+					 QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S);
+	qp_attr->sq_psn = (u32)roce_get_field(context->qpc_bytes_164,
+					     QP_CONTEXT_QPC_BYTES_164_SQ_PSN_M,
+					     QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S);
+	qp_attr->dest_qp_num = (u8)roce_get_field(context->qpc_bytes_36,
+					QP_CONTEXT_QPC_BYTES_36_DEST_QP_M,
+					QP_CONTEXT_QPC_BYTES_36_DEST_QP_S);
+	qp_attr->qp_access_flags = ((roce_get_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S)) << 2) |
+				   ((roce_get_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S)) << 1) |
+				   ((roce_get_bit(context->qpc_bytes_4,
+			QP_CONTEXT_QPC_BYTE_4_ATOMIC_OPERATION_ENABLE_S)) << 3);
+
+	if (hr_qp->ibqp.qp_type == IB_QPT_RC ||
+	    hr_qp->ibqp.qp_type == IB_QPT_UC) {
+		qp_attr->ah_attr.sl = roce_get_field(context->qpc_bytes_156,
+						QP_CONTEXT_QPC_BYTES_156_SL_M,
+						QP_CONTEXT_QPC_BYTES_156_SL_S);
+		qp_attr->ah_attr.grh.flow_label = roce_get_field(
+					context->qpc_bytes_48,
+					QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_M,
+					QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S);
+		qp_attr->ah_attr.grh.sgid_index = roce_get_field(
+					context->qpc_bytes_36,
+					QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_M,
+					QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S);
+		qp_attr->ah_attr.grh.hop_limit = roce_get_field(
+					context->qpc_bytes_44,
+					QP_CONTEXT_QPC_BYTES_44_HOPLMT_M,
+					QP_CONTEXT_QPC_BYTES_44_HOPLMT_S);
+		qp_attr->ah_attr.grh.traffic_class = roce_get_field(
+					context->qpc_bytes_48,
+					QP_CONTEXT_QPC_BYTES_48_TCLASS_M,
+					QP_CONTEXT_QPC_BYTES_48_TCLASS_S);
+
+		memcpy(qp_attr->ah_attr.grh.dgid.raw, context->dgid,
+		       sizeof(qp_attr->ah_attr.grh.dgid.raw));
+	}
+
+	qp_attr->pkey_index = roce_get_field(context->qpc_bytes_12,
+			      QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
+			      QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S);
+	qp_attr->port_num = (u8)roce_get_field(context->qpc_bytes_156,
+			     QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M,
+			     QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S) + 1;
+	qp_attr->sq_draining = 0;
+	qp_attr->max_rd_atomic = roce_get_field(context->qpc_bytes_156,
+				 QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_M,
+				 QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S);
+	qp_attr->max_dest_rd_atomic = roce_get_field(context->qpc_bytes_32,
+				 QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_M,
+				 QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S);
+	qp_attr->min_rnr_timer = (u8)(roce_get_field(context->qpc_bytes_24,
+			QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_M,
+			QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S));
+	qp_attr->timeout = (u8)(roce_get_field(context->qpc_bytes_156,
+			    QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_M,
+			    QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S));
+	qp_attr->retry_cnt = roce_get_field(context->qpc_bytes_148,
+			     QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_M,
+			     QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S);
+	qp_attr->rnr_retry = context->rnr_retry;
+
+done:
+	qp_attr->cur_qp_state = qp_attr->qp_state;
+	qp_attr->cap.max_recv_wr = hr_qp->rq.wqe_cnt;
+	qp_attr->cap.max_recv_sge = hr_qp->rq.max_gs;
+
+	if (!ibqp->uobject) {
+		qp_attr->cap.max_send_wr = hr_qp->sq.wqe_cnt;
+		qp_attr->cap.max_send_sge = hr_qp->sq.max_gs;
+	} else {
+		qp_attr->cap.max_send_wr = 0;
+		qp_attr->cap.max_send_sge = 0;
+	}
+
+	qp_init_attr->cap = qp_attr->cap;
+
+out:
+	mutex_unlock(&hr_qp->mutex);
+	kfree(context);
+	return ret;
+}
+
+static void hns_roce_v1_destroy_qp_common(struct hns_roce_dev *hr_dev,
+					  struct hns_roce_qp *hr_qp,
+					  int is_user)
+{
+	u32 sdbinvcnt;
+	unsigned long end = 0;
+	u32 sdbinvcnt_val;
+	u32 sdbsendptr_val;
+	u32 sdbisusepr_val;
+	struct hns_roce_cq *send_cq, *recv_cq;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	if (hr_qp->ibqp.qp_type == IB_QPT_RC) {
+		if (hr_qp->state != IB_QPS_RESET) {
+			/*
+			* Set qp to ERR,
+			* waiting for hw complete processing all dbs
+			*/
+			if (hns_roce_v1_qp_modify(hr_dev, NULL,
+					to_hns_roce_state(
+						(enum ib_qp_state)hr_qp->state),
+						HNS_ROCE_QP_STATE_ERR, NULL,
+						hr_qp))
+				dev_err(dev, "modify QP %06lx to ERR failed.\n",
+					hr_qp->qpn);
+
+			/* Record issued doorbell */
+			sdbisusepr_val = roce_read(hr_dev,
+					 ROCEE_SDB_ISSUE_PTR_REG);
+			/*
+			* Query db process status,
+			* until hw process completely
+			*/
+			end = msecs_to_jiffies(
+			      HNS_ROCE_QP_DESTROY_TIMEOUT_MSECS) + jiffies;
+			do {
+				sdbsendptr_val = roce_read(hr_dev,
+						 ROCEE_SDB_SEND_PTR_REG);
+				if (!time_before(jiffies, end)) {
+					dev_err(dev, "destroy qp(0x%lx) timeout!!!",
+						hr_qp->qpn);
+					break;
+				}
+			} while ((short)(roce_get_field(sdbsendptr_val,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S) -
+				roce_get_field(sdbisusepr_val,
+					ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_M,
+					ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S)
+				) < 0);
+
+			/* Get list pointer */
+			sdbinvcnt = roce_read(hr_dev, ROCEE_SDB_INV_CNT_REG);
+
+			/* Query db's list status, until hw reversal */
+			do {
+				sdbinvcnt_val = roce_read(hr_dev,
+						ROCEE_SDB_INV_CNT_REG);
+				if (!time_before(jiffies, end)) {
+					dev_err(dev, "destroy qp(0x%lx) timeout!!!",
+						hr_qp->qpn);
+					dev_err(dev, "SdbInvCnt = 0x%x\n",
+						sdbinvcnt_val);
+					break;
+				}
+			} while ((short)(roce_get_field(sdbinvcnt_val,
+				  ROCEE_SDB_INV_CNT_SDB_INV_CNT_M,
+				  ROCEE_SDB_INV_CNT_SDB_INV_CNT_S) -
+				  (sdbinvcnt + SDB_INV_CNT_OFFSET)) < 0);
+
+			/* Modify qp to reset before destroying qp */
+			if (hns_roce_v1_qp_modify(hr_dev, NULL,
+					to_hns_roce_state(
+					(enum ib_qp_state)hr_qp->state),
+					HNS_ROCE_QP_STATE_RST, NULL, hr_qp))
+				dev_err(dev, "modify QP %06lx to RESET failed.\n",
+					hr_qp->qpn);
+		}
+	}
+
+	send_cq = to_hr_cq(hr_qp->ibqp.send_cq);
+	recv_cq = to_hr_cq(hr_qp->ibqp.recv_cq);
+
+	hns_roce_lock_cqs(send_cq, recv_cq);
+
+	if (!is_user) {
+		__hns_roce_v1_cq_clean(recv_cq, hr_qp->qpn, hr_qp->ibqp.srq ?
+				       to_hr_srq(hr_qp->ibqp.srq) : NULL);
+		if (send_cq != recv_cq)
+			__hns_roce_v1_cq_clean(send_cq, hr_qp->qpn, NULL);
+	}
+
+	hns_roce_qp_remove(hr_dev, hr_qp);
+
+	hns_roce_unlock_cqs(send_cq, recv_cq);
+
+	hns_roce_qp_free(hr_dev, hr_qp);
+
+	/* Not special_QP, free their QPN */
+	if ((hr_qp->ibqp.qp_type == IB_QPT_RC) ||
+	    (hr_qp->ibqp.qp_type == IB_QPT_UC) ||
+	    (hr_qp->ibqp.qp_type == IB_QPT_UD))
+		hns_roce_release_range_qp(hr_dev, hr_qp->qpn, 1);
+
+	hns_roce_mtt_cleanup(hr_dev, &hr_qp->mtt);
+
+	if (is_user) {
+		ib_umem_release(hr_qp->umem);
+	} else {
+		kfree(hr_qp->sq.wrid);
+		kfree(hr_qp->rq.wrid);
+		hns_roce_buf_free(hr_dev, hr_qp->buff_size, &hr_qp->hr_buf);
+	}
+}
+
+int hns_roce_v1_destroy_qp(struct ib_qp *ibqp)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+
+	hns_roce_v1_destroy_qp_common(hr_dev, hr_qp, !!ibqp->pd->uobject);
+
+	if (hr_qp->ibqp.qp_type == IB_QPT_GSI)
+		kfree(hr_to_hr_sqp(hr_qp));
+	else
+		kfree(hr_qp);
+
+	return 0;
+}
+
 struct hns_roce_hw hns_roce_hw_v1 = {
 	.reset = hns_roce_v1_reset,
 	.hw_profile = hns_roce_v1_profile,
@@ -647,4 +2271,9 @@ struct hns_roce_hw hns_roce_hw_v1 = {
 	.set_gid = hns_roce_v1_set_gid,
 	.set_mac = hns_roce_v1_set_mac,
 	.set_mtu = hns_roce_v1_set_mtu,
+	.modify_qp = hns_roce_v1_modify_qp,
+	.query_qp = hns_roce_v1_query_qp,
+	.destroy_qp = hns_roce_v1_destroy_qp,
+	.post_send = hns_roce_v1_post_send,
+	.post_recv = hns_roce_v1_post_recv,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 56ccda5..912a727 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -107,10 +107,636 @@
 
 #define HNS_ROCE_ODB_EXTEND_MODE			1
 
+#define HNS_ROCE_CQE_QPN_MASK				0x3ffff
+
+#define QP1C_CFGN_OFFSET				0x28
 #define PHY_PORT_OFFSET					0x8
 #define ALL_PORT_VAL_OPEN				0x3f
 #define POL_TIME_INTERVAL_VAL				0x80
 #define SLEEP_TIME_INTERVAL				20
+#define SQ_PSN_SHIFT					8
+#define QKEY_VAL					0x80010000
+#define SDB_INV_CNT_OFFSET				8
+
+struct hns_roce_cqe {
+	u32 cqe_byte_4;
+	u32 cqe_byte_16;
+};
+
+#define CQE_BYTE_4_OWNER_S 7
+#define CQE_BYTE_4_SQ_RQ_FLAG_S 14
+
+#define CQE_BYTE_16_LOCAL_QPN_S 0
+#define CQE_BYTE_16_LOCAL_QPN_M	(((1UL << 24) - 1) << CQE_BYTE_16_LOCAL_QPN_S)
+
+struct hns_roce_wqe_ctrl_seg {
+	__be32 sgl_pa_h;
+	__be32 flag;
+	__be32 imm_data;
+	__be32 msg_length;
+};
+
+struct hns_roce_wqe_data_seg {
+	__be64    addr;
+	__be32    lkey;
+	__be32    len;
+};
+
+struct hns_roce_wqe_raddr_seg {
+	__be32 rkey;
+	__be32 len;/* reserved */
+	__be64 raddr;
+};
+
+struct hns_roce_rq_wqe_ctrl {
+
+	u32 rwqe_byte_4;
+	u32 rocee_sgl_ba_l;
+	u32 rwqe_byte_12;
+	u32 reserved[5];
+};
+
+#define RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_S 16
+#define RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_M   \
+	(((1UL << 6) - 1) << RQ_WQE_CTRL_RWQE_BYTE_12_RWQE_SGE_NUM_S)
+
+#define HNS_ROCE_QP_DESTROY_TIMEOUT_MSECS	10000
+
+#define GID_LEN					16
+
+struct hns_roce_ud_send_wqe {
+	u32 dmac_h;
+	u32 u32_8;
+	u32 immediate_data;
+
+	u32 u32_16;
+	union {
+		unsigned char dgid[GID_LEN];
+		struct {
+			u32 u32_20;
+			u32 u32_24;
+			u32 u32_28;
+			u32 u32_32;
+		};
+	};
+
+	u32 u32_36;
+	u32 u32_40;
+
+	u32 va0_l;
+	u32 va0_h;
+	u32 l_key0;
+
+	u32 va1_l;
+	u32 va1_h;
+	u32 l_key1;
+};
+
+#define UD_SEND_WQE_U32_4_DMAC_0_S 0
+#define UD_SEND_WQE_U32_4_DMAC_0_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_0_S)
+
+#define UD_SEND_WQE_U32_4_DMAC_1_S 8
+#define UD_SEND_WQE_U32_4_DMAC_1_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_1_S)
+
+#define UD_SEND_WQE_U32_4_DMAC_2_S 16
+#define UD_SEND_WQE_U32_4_DMAC_2_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_2_S)
+
+#define UD_SEND_WQE_U32_4_DMAC_3_S 24
+#define UD_SEND_WQE_U32_4_DMAC_3_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_4_DMAC_3_S)
+
+#define UD_SEND_WQE_U32_8_DMAC_4_S 0
+#define UD_SEND_WQE_U32_8_DMAC_4_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_8_DMAC_4_S)
+
+#define UD_SEND_WQE_U32_8_DMAC_5_S 8
+#define UD_SEND_WQE_U32_8_DMAC_5_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_8_DMAC_5_S)
+
+#define UD_SEND_WQE_U32_8_OPERATION_TYPE_S 16
+#define UD_SEND_WQE_U32_8_OPERATION_TYPE_M   \
+	(((1UL << 4) - 1) << UD_SEND_WQE_U32_8_OPERATION_TYPE_S)
+
+#define UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_S 24
+#define UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_M   \
+	(((1UL << 6) - 1) << UD_SEND_WQE_U32_8_NUMBER_OF_DATA_SEG_S)
+
+#define UD_SEND_WQE_U32_8_SEND_GL_ROUTING_HDR_FLAG_S 31
+
+#define UD_SEND_WQE_U32_16_DEST_QP_S 0
+#define UD_SEND_WQE_U32_16_DEST_QP_M   \
+	(((1UL << 24) - 1) << UD_SEND_WQE_U32_16_DEST_QP_S)
+
+#define UD_SEND_WQE_U32_16_MAX_STATIC_RATE_S 24
+#define UD_SEND_WQE_U32_16_MAX_STATIC_RATE_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_16_MAX_STATIC_RATE_S)
+
+#define UD_SEND_WQE_U32_36_FLOW_LABEL_S 0
+#define UD_SEND_WQE_U32_36_FLOW_LABEL_M   \
+	(((1UL << 20) - 1) << UD_SEND_WQE_U32_36_FLOW_LABEL_S)
+
+#define UD_SEND_WQE_U32_36_PRIORITY_S 20
+#define UD_SEND_WQE_U32_36_PRIORITY_M   \
+	(((1UL << 4) - 1) << UD_SEND_WQE_U32_36_PRIORITY_S)
+
+#define UD_SEND_WQE_U32_36_SGID_INDEX_S 24
+#define UD_SEND_WQE_U32_36_SGID_INDEX_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_36_SGID_INDEX_S)
+
+#define UD_SEND_WQE_U32_40_HOP_LIMIT_S 0
+#define UD_SEND_WQE_U32_40_HOP_LIMIT_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_40_HOP_LIMIT_S)
+
+#define UD_SEND_WQE_U32_40_TRAFFIC_CLASS_S 8
+#define UD_SEND_WQE_U32_40_TRAFFIC_CLASS_M   \
+	(((1UL << 8) - 1) << UD_SEND_WQE_U32_40_TRAFFIC_CLASS_S)
+
+struct hns_roce_sqp_context {
+	u32 qp1c_bytes_4;
+	u32 sq_rq_bt_l;
+	u32 qp1c_bytes_12;
+	u32 qp1c_bytes_16;
+	u32 qp1c_bytes_20;
+	u32 qp1c_bytes_28;
+	u32 cur_rq_wqe_ba_l;
+	u32 qp1c_bytes_32;
+	u32 cur_sq_wqe_ba_l;
+	u32 qp1c_bytes_40;
+};
+
+#define QP1C_BYTES_4_SQ_WQE_SHIFT_S 8
+#define QP1C_BYTES_4_SQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << QP1C_BYTES_4_SQ_WQE_SHIFT_S)
+
+#define QP1C_BYTES_4_RQ_WQE_SHIFT_S 12
+#define QP1C_BYTES_4_RQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << QP1C_BYTES_4_RQ_WQE_SHIFT_S)
+
+#define QP1C_BYTES_4_PD_S 16
+#define QP1C_BYTES_4_PD_M	(((1UL << 16) - 1) << QP1C_BYTES_4_PD_S)
+
+#define QP1C_BYTES_12_SQ_RQ_BT_H_S 0
+#define QP1C_BYTES_12_SQ_RQ_BT_H_M   \
+	(((1UL << 17) - 1) << QP1C_BYTES_12_SQ_RQ_BT_H_S)
+
+#define QP1C_BYTES_16_RQ_HEAD_S 0
+#define QP1C_BYTES_16_RQ_HEAD_M	(((1UL << 15) - 1) << QP1C_BYTES_16_RQ_HEAD_S)
+
+#define QP1C_BYTES_16_PORT_NUM_S 16
+#define QP1C_BYTES_16_PORT_NUM_M   \
+	(((1UL << 3) - 1) << QP1C_BYTES_16_PORT_NUM_S)
+
+#define QP1C_BYTES_16_SIGNALING_TYPE_S 27
+#define QP1C_BYTES_16_LOCAL_ENABLE_E2E_CREDIT_S 28
+#define QP1C_BYTES_16_RQ_BA_FLG_S 29
+#define QP1C_BYTES_16_SQ_BA_FLG_S 30
+#define QP1C_BYTES_16_QP1_ERR_S 31
+
+#define QP1C_BYTES_20_SQ_HEAD_S 0
+#define QP1C_BYTES_20_SQ_HEAD_M	(((1UL << 15) - 1) << QP1C_BYTES_20_SQ_HEAD_S)
+
+#define QP1C_BYTES_20_PKEY_IDX_S 16
+#define QP1C_BYTES_20_PKEY_IDX_M   \
+	(((1UL << 16) - 1) << QP1C_BYTES_20_PKEY_IDX_S)
+
+#define QP1C_BYTES_28_CUR_RQ_WQE_BA_H_S 0
+#define QP1C_BYTES_28_CUR_RQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << QP1C_BYTES_28_CUR_RQ_WQE_BA_H_S)
+
+#define QP1C_BYTES_28_RQ_CUR_IDX_S 16
+#define QP1C_BYTES_28_RQ_CUR_IDX_M   \
+	(((1UL << 15) - 1) << QP1C_BYTES_28_RQ_CUR_IDX_S)
+
+#define QP1C_BYTES_32_TX_CQ_NUM_S 0
+#define QP1C_BYTES_32_TX_CQ_NUM_M   \
+	(((1UL << 16) - 1) << QP1C_BYTES_32_TX_CQ_NUM_S)
+
+#define QP1C_BYTES_32_RX_CQ_NUM_S 16
+#define QP1C_BYTES_32_RX_CQ_NUM_M   \
+	(((1UL << 16) - 1) << QP1C_BYTES_32_RX_CQ_NUM_S)
+
+#define QP1C_BYTES_40_CUR_SQ_WQE_BA_H_S 0
+#define QP1C_BYTES_40_CUR_SQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << QP1C_BYTES_40_CUR_SQ_WQE_BA_H_S)
+
+#define QP1C_BYTES_40_SQ_CUR_IDX_S 16
+#define QP1C_BYTES_40_SQ_CUR_IDX_M   \
+	(((1UL << 15) - 1) << QP1C_BYTES_40_SQ_CUR_IDX_S)
+
+#define HNS_ROCE_WQE_INLINE		(1UL<<31)
+#define HNS_ROCE_WQE_SE			(1UL<<30)
+
+#define HNS_ROCE_WQE_SGE_NUM_BIT	24
+#define HNS_ROCE_WQE_IMM		(1UL<<23)
+#define HNS_ROCE_WQE_FENCE		(1UL<<21)
+#define HNS_ROCE_WQE_CQ_NOTIFY		(1UL<<20)
+
+#define HNS_ROCE_WQE_OPCODE_SEND	(0<<16)
+#define HNS_ROCE_WQE_OPCODE_RDMA_READ	(1<<16)
+#define HNS_ROCE_WQE_OPCODE_RDMA_WRITE	(2<<16)
+#define HNS_ROCE_WQE_OPCODE_MASK	(15<<16)
+
+struct hns_roce_qp_context {
+	u32 qpc_bytes_4;
+	u32 qpc_bytes_8;
+	u32 qpc_bytes_12;
+	u32 qpc_bytes_16;
+	u32 sq_rq_bt_l;
+	u32 qpc_bytes_24;
+	u32 irrl_ba_l;
+	u32 qpc_bytes_32;
+	u32 qpc_bytes_36;
+	u32 dmac_l;
+	u32 qpc_bytes_44;
+	u32 qpc_bytes_48;
+	u8 dgid[16];
+	u32 qpc_bytes_68;
+	u32 cur_rq_wqe_ba_l;
+	u32 qpc_bytes_76;
+	u32 rx_rnr_time;
+	u32 qpc_bytes_84;
+	u32 qpc_bytes_88;
+	union {
+		u32 rx_sge_len;
+		u32 dma_length;
+	};
+	union {
+		u32 rx_sge_num;
+		u32 rx_send_pktn;
+		u32 r_key;
+	};
+	u32 va_l;
+	u32 va_h;
+	u32 qpc_bytes_108;
+	u32 qpc_bytes_112;
+	u32 rx_cur_sq_wqe_ba_l;
+	u32 qpc_bytes_120;
+	u32 qpc_bytes_124;
+	u32 qpc_bytes_128;
+	u32 qpc_bytes_132;
+	u32 qpc_bytes_136;
+	u32 qpc_bytes_140;
+	u32 qpc_bytes_144;
+	u32 qpc_bytes_148;
+	union {
+		u32 rnr_retry;
+		u32 ack_time;
+	};
+	u32 qpc_bytes_156;
+	u32 pkt_use_len;
+	u32 qpc_bytes_164;
+	u32 qpc_bytes_168;
+	union {
+		u32 sge_use_len;
+		u32 pa_use_len;
+	};
+	u32 qpc_bytes_176;
+	u32 qpc_bytes_180;
+	u32 tx_cur_sq_wqe_ba_l;
+	u32 qpc_bytes_188;
+	u32 rvd21;
+};
+
+#define QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S 0
+#define QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTE_4_ENABLE_FPMR_S 3
+#define QP_CONTEXT_QPC_BYTE_4_RDMA_READ_ENABLE_S 4
+#define QP_CONTEXT_QPC_BYTE_4_RDMA_WRITE_ENABLE_S 5
+#define QP_CONTEXT_QPC_BYTE_4_ATOMIC_OPERATION_ENABLE_S 6
+#define QP_CONTEXT_QPC_BYTE_4_RDMAR_USE_S 7
+
+#define QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S 8
+#define QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << QP_CONTEXT_QPC_BYTES_4_SQ_WQE_SHIFT_S)
+
+#define QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S 12
+#define QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_M   \
+	(((1UL << 4) - 1) << QP_CONTEXT_QPC_BYTES_4_RQ_WQE_SHIFT_S)
+
+#define QP_CONTEXT_QPC_BYTES_4_PD_S 16
+#define QP_CONTEXT_QPC_BYTES_4_PD_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_4_PD_S)
+
+#define QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S 0
+#define QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_8_TX_COMPLETION_S)
+
+#define QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S 16
+#define QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_8_RX_COMPLETION_S)
+
+#define QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S 0
+#define QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_12_SRQ_NUMBER_S)
+
+#define QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_16_QP_NUM_S 0
+#define QP_CONTEXT_QPC_BYTES_16_QP_NUM_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_16_QP_NUM_S)
+
+#define QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_S 0
+#define QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_M   \
+	(((1UL << 17) - 1) << QP_CONTEXT_QPC_BYTES_24_SQ_RQ_BT_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S 18
+#define QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_M   \
+	(((1UL << 5) - 1) << QP_CONTEXT_QPC_BYTES_24_MINIMUM_RNR_NAK_TIMER_S)
+
+#define QP_CONTEXT_QPC_BYTE_24_REMOTE_ENABLE_E2E_CREDITS_S 23
+
+#define QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_M   \
+	(((1UL << 17) - 1) << QP_CONTEXT_QPC_BYTES_32_IRRL_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_32_MIG_STATE_S 18
+#define QP_CONTEXT_QPC_BYTES_32_MIG_STATE_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_32_MIG_STATE_S)
+
+#define QP_CONTEXT_QPC_BYTE_32_LOCAL_ENABLE_E2E_CREDITS_S 20
+#define QP_CONTEXT_QPC_BYTE_32_SIGNALING_TYPE_S 21
+#define QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S 22
+#define QP_CONTEXT_QPC_BYTE_32_GLOBAL_HEADER_S 23
+
+#define QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S 24
+#define QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_32_RESPONDER_RESOURCES_S)
+
+#define QP_CONTEXT_QPC_BYTES_36_DEST_QP_S 0
+#define QP_CONTEXT_QPC_BYTES_36_DEST_QP_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_36_DEST_QP_S)
+
+#define QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S 24
+#define QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_36_SGID_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_44_DMAC_H_S 0
+#define QP_CONTEXT_QPC_BYTES_44_DMAC_H_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_44_DMAC_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_S 16
+#define QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_44_MAXIMUM_STATIC_RATE_S)
+
+#define QP_CONTEXT_QPC_BYTES_44_HOPLMT_S 24
+#define QP_CONTEXT_QPC_BYTES_44_HOPLMT_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_44_HOPLMT_S)
+
+#define QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S 0
+#define QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_M   \
+	(((1UL << 20) - 1) << QP_CONTEXT_QPC_BYTES_48_FLOWLABEL_S)
+
+#define QP_CONTEXT_QPC_BYTES_48_TCLASS_S 20
+#define QP_CONTEXT_QPC_BYTES_48_TCLASS_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_48_TCLASS_S)
+
+#define QP_CONTEXT_QPC_BYTES_48_MTU_S 28
+#define QP_CONTEXT_QPC_BYTES_48_MTU_M   \
+	(((1UL << 4) - 1) << QP_CONTEXT_QPC_BYTES_48_MTU_S)
+
+#define QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_S 0
+#define QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_68_RQ_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_68_RQ_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << QP_CONTEXT_QPC_BYTES_76_CUR_RQ_WQE_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_S 8
+#define QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_76_RX_REQ_MSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_84_LAST_ACK_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_S 24
+#define QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_84_TRRL_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S 0
+#define QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_88_RX_REQ_EPSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_88_RX_REQ_PSN_ERR_FLAG_S 24
+#define QP_CONTEXT_QPC_BYTES_88_RX_LAST_OPCODE_FLG_S 25
+
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_S 26
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_M   \
+	(((1UL << 2) - 1) << \
+	QP_CONTEXT_QPC_BYTES_88_RQ_REQ_LAST_OPERATION_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_S 29
+#define QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_88_RQ_REQ_RDMA_WR_FLAG_S)
+
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_SDB_PSN_FLG_S 24
+#define QP_CONTEXT_QPC_BYTES_108_TRRL_TDB_PSN_FLG_S 25
+
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_112_TRRL_TDB_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_S 24
+#define QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_112_TRRL_TAIL_S)
+
+#define QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << QP_CONTEXT_QPC_BYTES_120_RX_CUR_SQ_WQE_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_S 0
+#define QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_124_RX_ACK_MSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_S 16
+#define QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_124_IRRL_MSG_IDX_S)
+
+#define QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_S 0
+#define QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_128_RX_ACK_EPSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_128_RX_ACK_PSN_ERR_FLG_S 24
+
+#define QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_S 25
+#define QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_128_ACK_LAST_OPERATION_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTES_128_IRRL_PSN_VLD_FLG_S 27
+
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_132_IRRL_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_S 24
+#define QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_132_IRRL_TAIL_S)
+
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_S 24
+#define QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_136_RETRY_MSG_FPKT_PSN_L_S)
+
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_S 0
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_FPKT_PSN_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_S 16
+#define QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_140_RETRY_MSG_MSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_140_RNR_RETRY_FLG_S 31
+
+#define QP_CONTEXT_QPC_BYTES_144_QP_STATE_S 0
+#define QP_CONTEXT_QPC_BYTES_144_QP_STATE_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_144_QP_STATE_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_S 0
+#define QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_148_CHECK_FLAG_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S 2
+#define QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_148_RETRY_COUNT_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_S 5
+#define QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_148_RNR_RETRY_COUNT_S)
+
+#define QP_CONTEXT_QPC_BYTES_148_LSN_S 8
+#define QP_CONTEXT_QPC_BYTES_148_LSN_M   \
+	(((1UL << 16) - 1) << QP_CONTEXT_QPC_BYTES_148_LSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_S 0
+#define QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_156_RETRY_COUNT_INIT_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S 3
+#define QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_M   \
+	(((1UL << 5) - 1) << QP_CONTEXT_QPC_BYTES_156_ACK_TIMEOUT_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_S 8
+#define QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_156_RNR_RETRY_COUNT_INIT_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S 11
+#define QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M   \
+	(((1UL << 3) - 1) << QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_SL_S 14
+#define QP_CONTEXT_QPC_BYTES_156_SL_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_156_SL_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S 16
+#define QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_S)
+
+#define QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_S 24
+#define QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_156_ACK_REQ_IND_S)
+
+#define QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_164_SQ_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_164_SQ_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_S 24
+#define QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_M   \
+	(((1UL << 8) - 1) << QP_CONTEXT_QPC_BYTES_164_IRRL_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_S 0
+#define QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_M   \
+	(((1UL << 24) - 1) << QP_CONTEXT_QPC_BYTES_168_RETRY_SQ_PSN_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_S 24
+#define QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_168_SGE_USE_FLA_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_DB_TYPE_S 26
+#define QP_CONTEXT_QPC_BYTES_168_DB_TYPE_M   \
+	(((1UL << 2) - 1) << QP_CONTEXT_QPC_BYTES_168_DB_TYPE_S)
+
+#define QP_CONTEXT_QPC_BYTES_168_MSG_LP_IND_S 28
+#define QP_CONTEXT_QPC_BYTES_168_CSDB_LP_IND_S 29
+#define QP_CONTEXT_QPC_BYTES_168_QP_ERR_FLG_S 30
+
+#define QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_S 0
+#define QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_176_DB_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_176_RETRY_DB_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_S 0
+#define QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_180_SQ_HEAD_S)
+
+#define QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_180_SQ_CUR_INDEX_S)
+
+#define QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_S 0
+#define QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_M   \
+	(((1UL << 5) - 1) << QP_CONTEXT_QPC_BYTES_188_TX_CUR_SQ_WQE_BA_H_S)
+
+#define QP_CONTEXT_QPC_BYTES_188_PKT_RETRY_FLG_S 8
+
+#define QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_S 16
+#define QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_M   \
+	(((1UL << 15) - 1) << QP_CONTEXT_QPC_BYTES_188_TX_RETRY_CUR_INDEX_S)
+
+struct hns_roce_rq_db {
+	u32    u32_4;
+	u32    u32_8;
+};
+
+#define RQ_DOORBELL_U32_4_RQ_HEAD_S 0
+#define RQ_DOORBELL_U32_4_RQ_HEAD_M   \
+	(((1UL << 15) - 1) << RQ_DOORBELL_U32_4_RQ_HEAD_S)
+
+#define RQ_DOORBELL_U32_8_QPN_S 0
+#define RQ_DOORBELL_U32_8_QPN_M   (((1UL << 24) - 1) << RQ_DOORBELL_U32_8_QPN_S)
+
+#define RQ_DOORBELL_U32_8_CMD_S 28
+#define RQ_DOORBELL_U32_8_CMD_M   (((1UL << 3) - 1) << RQ_DOORBELL_U32_8_CMD_S)
+
+#define RQ_DOORBELL_U32_8_HW_SYNC_S 31
+
+struct hns_roce_sq_db {
+	u32    u32_4;
+	u32    u32_8;
+};
+
+#define SQ_DOORBELL_U32_4_SQ_HEAD_S 0
+#define SQ_DOORBELL_U32_4_SQ_HEAD_M   \
+	(((1UL << 15) - 1) << SQ_DOORBELL_U32_4_SQ_HEAD_S)
+
+#define SQ_DOORBELL_U32_4_PORT_S 18
+#define SQ_DOORBELL_U32_4_PORT_M  (((1UL << 3) - 1) << SQ_DOORBELL_U32_4_PORT_S)
+
+#define SQ_DOORBELL_U32_8_QPN_S 0
+#define SQ_DOORBELL_U32_8_QPN_M   (((1UL << 24) - 1) << SQ_DOORBELL_U32_8_QPN_S)
+
+#define SQ_DOORBELL_HW_SYNC_S 31
 
 struct hns_roce_ext_db {
 	int esdb_dep;
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 221af17..2f8140b 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -582,7 +582,11 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 		(1ULL << IB_USER_VERBS_CMD_QUERY_DEVICE) |
 		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
 		(1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
-		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD);
+		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_CREATE_QP) |
+		(1ULL << IB_USER_VERBS_CMD_MODIFY_QP) |
+		(1ULL << IB_USER_VERBS_CMD_QUERY_QP) |
+		(1ULL << IB_USER_VERBS_CMD_DESTROY_QP);
 
 	/* HCA||device||port */
 	ib_dev->modify_device		= hns_roce_modify_device;
@@ -605,6 +609,14 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->query_ah		= hns_roce_query_ah;
 	ib_dev->destroy_ah		= hns_roce_destroy_ah;
 
+	/* QP */
+	ib_dev->create_qp		= hns_roce_create_qp;
+	ib_dev->modify_qp		= hns_roce_modify_qp;
+	ib_dev->query_qp		= hr_dev->hw->query_qp;
+	ib_dev->destroy_qp		= hr_dev->hw->destroy_qp;
+	ib_dev->post_send		= hr_dev->hw->post_send;
+	ib_dev->post_recv		= hr_dev->hw->post_recv;
+
 	ret = ib_register_device(ib_dev, NULL);
 	if (ret) {
 		dev_err(dev, "ib_register_device failed!\n");
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index 132548c..04ae3ed 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -34,6 +34,7 @@
 #include <linux/platform_device.h>
 #include <rdma/ib_umem.h>
 #include "hns_roce_device.h"
+#include "hns_roce_hem.h"
 
 static int hns_roce_buddy_alloc(struct hns_roce_buddy *buddy, int order,
 				unsigned long *seg)
@@ -159,6 +160,128 @@ static int hns_roce_alloc_mtt_range(struct hns_roce_dev *hr_dev, int order,
 	return 0;
 }
 
+int hns_roce_mtt_init(struct hns_roce_dev *hr_dev, int npages, int page_shift,
+		      struct hns_roce_mtt *mtt)
+{
+	int ret = 0;
+	int i;
+
+	/* Page num is zero, correspond to DMA memory register */
+	if (!npages) {
+		mtt->order = -1;
+		mtt->page_shift = HNS_ROCE_HEM_PAGE_SHIFT;
+		return 0;
+	}
+
+	/* Note: if page_shift is zero, FAST memory regsiter */
+	mtt->page_shift = page_shift;
+
+	/* Compute MTT entry necessary */
+	for (mtt->order = 0, i = HNS_ROCE_MTT_ENTRY_PER_SEG; i < npages;
+	     i <<= 1)
+		++mtt->order;
+
+	/* Allocate MTT entry */
+	ret = hns_roce_alloc_mtt_range(hr_dev, mtt->order, &mtt->first_seg);
+	if (ret == -1)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void hns_roce_mtt_cleanup(struct hns_roce_dev *hr_dev, struct hns_roce_mtt *mtt)
+{
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+
+	if (mtt->order < 0)
+		return;
+
+	hns_roce_buddy_free(&mr_table->mtt_buddy, mtt->first_seg, mtt->order);
+	hns_roce_table_put_range(hr_dev, &mr_table->mtt_table, mtt->first_seg,
+				 mtt->first_seg + (1 << mtt->order) - 1);
+}
+
+static int hns_roce_write_mtt_chunk(struct hns_roce_dev *hr_dev,
+				    struct hns_roce_mtt *mtt, u32 start_index,
+				    u32 npages, u64 *page_list)
+{
+	u32 i = 0;
+	__le64 *mtts = NULL;
+	dma_addr_t dma_handle;
+	u32 s = start_index * sizeof(u64);
+
+	/* All MTTs must fit in the same page */
+	if (start_index / (PAGE_SIZE / sizeof(u64)) !=
+		(start_index + npages - 1) / (PAGE_SIZE / sizeof(u64)))
+		return -EINVAL;
+
+	if (start_index & (HNS_ROCE_MTT_ENTRY_PER_SEG - 1))
+		return -EINVAL;
+
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+				mtt->first_seg + s / hr_dev->caps.mtt_entry_sz,
+				&dma_handle);
+	if (!mtts)
+		return -ENOMEM;
+
+	/* Save page addr, low 12 bits : 0 */
+	for (i = 0; i < npages; ++i)
+		mtts[i] = (cpu_to_le64(page_list[i])) >> PAGE_ADDR_SHIFT;
+
+	return 0;
+}
+
+static int hns_roce_write_mtt(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_mtt *mtt, u32 start_index,
+			      u32 npages, u64 *page_list)
+{
+	int chunk;
+	int ret;
+
+	if (mtt->order < 0)
+		return -EINVAL;
+
+	while (npages > 0) {
+		chunk = min_t(int, PAGE_SIZE / sizeof(u64), npages);
+
+		ret = hns_roce_write_mtt_chunk(hr_dev, mtt, start_index, chunk,
+					       page_list);
+		if (ret)
+			return ret;
+
+		npages -= chunk;
+		start_index += chunk;
+		page_list += chunk;
+	}
+
+	return 0;
+}
+
+int hns_roce_buf_write_mtt(struct hns_roce_dev *hr_dev,
+			   struct hns_roce_mtt *mtt, struct hns_roce_buf *buf)
+{
+	u32 i = 0;
+	int ret = 0;
+	u64 *page_list = NULL;
+
+	page_list = kmalloc_array(buf->npages, sizeof(*page_list), GFP_KERNEL);
+	if (!page_list)
+		return -ENOMEM;
+
+	for (i = 0; i < buf->npages; ++i) {
+		if (buf->nbufs == 1)
+			page_list[i] = buf->direct.map + (i << buf->page_shift);
+		else
+			page_list[i] = buf->page_list[i].map;
+
+	}
+	ret = hns_roce_write_mtt(hr_dev, mtt, 0, buf->npages, page_list);
+
+	kfree(page_list);
+
+	return ret;
+}
+
 int hns_roce_init_mr_table(struct hns_roce_dev *hr_dev)
 {
 	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
@@ -190,3 +313,42 @@ void hns_roce_cleanup_mr_table(struct hns_roce_dev *hr_dev)
 	hns_roce_buddy_cleanup(&mr_table->mtt_buddy);
 	hns_roce_bitmap_cleanup(&mr_table->mtpt_bitmap);
 }
+
+int hns_roce_ib_umem_write_mtt(struct hns_roce_dev *hr_dev,
+			       struct hns_roce_mtt *mtt, struct ib_umem *umem)
+{
+	struct scatterlist *sg;
+	int i, k, entry;
+	int ret = 0;
+	u64 *pages;
+	u32 n;
+	int len;
+
+	pages = (u64 *) __get_free_page(GFP_KERNEL);
+	if (!pages)
+		return -ENOMEM;
+
+	i = n = 0;
+
+	for_each_sg(umem->sg_head.sgl, sg, umem->nmap, entry) {
+		len = sg_dma_len(sg) >> mtt->page_shift;
+		for (k = 0; k < len; ++k) {
+			pages[i++] = sg_dma_address(sg) + umem->page_size * k;
+			if (i == PAGE_SIZE / sizeof(u64)) {
+				ret = hns_roce_write_mtt(hr_dev, mtt, n, i,
+							 pages);
+				if (ret)
+					goto out;
+				n += i;
+				i = 0;
+			}
+		}
+	}
+
+	if (i)
+		ret = hns_roce_write_mtt(hr_dev, mtt, n, i, pages);
+
+out:
+	free_page((unsigned long) pages);
+	return ret;
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_qp.c b/drivers/infiniband/hw/hns/hns_roce_qp.c
index d70729d..0c3ad3e 100644
--- a/drivers/infiniband/hw/hns/hns_roce_qp.c
+++ b/drivers/infiniband/hw/hns/hns_roce_qp.c
@@ -33,8 +33,12 @@
 
 #include <linux/platform_device.h>
 #include <rdma/ib_umem.h>
+#include "hns_roce_common.h"
 #include "hns_roce_device.h"
+#include "hns_roce_hem.h"
+#include "hns_roce_user.h"
 
+#define DB_REG_OFFSET			0x1000
 #define SQP_NUM				12
 
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type)
@@ -62,6 +66,766 @@ void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type)
 		complete(&qp->free);
 }
 
+static void hns_roce_ib_qp_event(struct hns_roce_qp *hr_qp,
+				 enum hns_roce_event type)
+{
+	struct ib_event event;
+	struct ib_qp *ibqp = &hr_qp->ibqp;
+
+	if (ibqp->event_handler) {
+		event.device = ibqp->device;
+		event.element.qp = ibqp;
+		switch (type) {
+		case HNS_ROCE_EVENT_TYPE_PATH_MIG:
+			event.event = IB_EVENT_PATH_MIG;
+			break;
+		case HNS_ROCE_EVENT_TYPE_COMM_EST:
+			event.event = IB_EVENT_COMM_EST;
+			break;
+		case HNS_ROCE_EVENT_TYPE_SQ_DRAINED:
+			event.event = IB_EVENT_SQ_DRAINED;
+			break;
+		case HNS_ROCE_EVENT_TYPE_SRQ_LAST_WQE_REACH:
+			event.event = IB_EVENT_QP_LAST_WQE_REACHED;
+			break;
+		case HNS_ROCE_EVENT_TYPE_WQ_CATAS_ERROR:
+			event.event = IB_EVENT_QP_FATAL;
+			break;
+		case HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED:
+			event.event = IB_EVENT_PATH_MIG_ERR;
+			break;
+		case HNS_ROCE_EVENT_TYPE_INV_REQ_LOCAL_WQ_ERROR:
+			event.event = IB_EVENT_QP_REQ_ERR;
+			break;
+		case HNS_ROCE_EVENT_TYPE_LOCAL_WQ_ACCESS_ERROR:
+			event.event = IB_EVENT_QP_ACCESS_ERR;
+			break;
+		default:
+			dev_dbg(ibqp->device->dma_device, "roce_ib: Unexpected event type %d on QP %06lx\n",
+				type, hr_qp->qpn);
+			return;
+		}
+		ibqp->event_handler(&event, ibqp->qp_context);
+	}
+}
+
+static int hns_roce_reserve_range_qp(struct hns_roce_dev *hr_dev, int cnt,
+				     int align, unsigned long *base)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	int ret = 0;
+	unsigned long qpn;
+
+	ret = hns_roce_bitmap_alloc_range(&qp_table->bitmap, cnt, align, &qpn);
+	if (ret == -1)
+		return -ENOMEM;
+
+	*base = qpn;
+
+	return 0;
+}
+
+enum hns_roce_qp_state to_hns_roce_state(enum ib_qp_state state)
+{
+	switch (state) {
+	case IB_QPS_RESET:
+		return HNS_ROCE_QP_STATE_RST;
+	case IB_QPS_INIT:
+		return HNS_ROCE_QP_STATE_INIT;
+	case IB_QPS_RTR:
+		return HNS_ROCE_QP_STATE_RTR;
+	case IB_QPS_RTS:
+		return HNS_ROCE_QP_STATE_RTS;
+	case IB_QPS_SQD:
+		return HNS_ROCE_QP_STATE_SQD;
+	case IB_QPS_ERR:
+		return HNS_ROCE_QP_STATE_ERR;
+	default:
+		return HNS_ROCE_QP_NUM_STATE;
+	}
+}
+
+static int hns_roce_gsi_qp_alloc(struct hns_roce_dev *hr_dev, unsigned long qpn,
+				 struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	int ret;
+
+	if (!qpn)
+		return -EINVAL;
+
+	hr_qp->qpn = qpn;
+
+	spin_lock_irq(&qp_table->lock);
+	ret = radix_tree_insert(&hr_dev->qp_table_tree,
+				hr_qp->qpn & (hr_dev->caps.num_qps - 1), hr_qp);
+	spin_unlock_irq(&qp_table->lock);
+	if (ret) {
+		dev_err(&hr_dev->pdev->dev, "QPC radix_tree_insert failed\n");
+		goto err_put_irrl;
+	}
+
+	atomic_set(&hr_qp->refcount, 1);
+	init_completion(&hr_qp->free);
+
+	return 0;
+
+err_put_irrl:
+
+	return ret;
+}
+
+static int hns_roce_qp_alloc(struct hns_roce_dev *hr_dev, unsigned long qpn,
+			     struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret;
+
+	if (!qpn)
+		return -EINVAL;
+
+	hr_qp->qpn = qpn;
+
+	/* Alloc memory for QPC */
+	ret = hns_roce_table_get(hr_dev, &qp_table->qp_table, hr_qp->qpn);
+	if (ret) {
+		dev_err(dev, "QPC table get failed\n");
+		goto err_out;
+	}
+
+	/* Alloc memory for IRRL */
+	ret = hns_roce_table_get(hr_dev, &qp_table->irrl_table, hr_qp->qpn);
+	if (ret) {
+		dev_err(dev, "IRRL table get failed\n");
+		goto err_put_qp;
+	}
+
+	spin_lock_irq(&qp_table->lock);
+	ret = radix_tree_insert(&hr_dev->qp_table_tree,
+				hr_qp->qpn & (hr_dev->caps.num_qps - 1), hr_qp);
+	spin_unlock_irq(&qp_table->lock);
+	if (ret) {
+		dev_err(dev, "QPC radix_tree_insert failed\n");
+		goto err_put_irrl;
+	}
+
+	atomic_set(&hr_qp->refcount, 1);
+	init_completion(&hr_qp->free);
+
+	return 0;
+
+err_put_irrl:
+	hns_roce_table_put(hr_dev, &qp_table->irrl_table, hr_qp->qpn);
+
+err_put_qp:
+	hns_roce_table_put(hr_dev, &qp_table->qp_table, hr_qp->qpn);
+
+err_out:
+	return ret;
+}
+
+void hns_roce_qp_remove(struct hns_roce_dev *hr_dev, struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	unsigned long flags;
+
+	spin_lock_irqsave(&qp_table->lock, flags);
+	radix_tree_delete(&hr_dev->qp_table_tree,
+			  hr_qp->qpn & (hr_dev->caps.num_qps - 1));
+	spin_unlock_irqrestore(&qp_table->lock, flags);
+}
+
+void hns_roce_qp_free(struct hns_roce_dev *hr_dev, struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+
+	if (atomic_dec_and_test(&hr_qp->refcount))
+		complete(&hr_qp->free);
+	wait_for_completion(&hr_qp->free);
+
+	if ((hr_qp->ibqp.qp_type) != IB_QPT_GSI) {
+		hns_roce_table_put(hr_dev, &qp_table->irrl_table, hr_qp->qpn);
+		hns_roce_table_put(hr_dev, &qp_table->qp_table, hr_qp->qpn);
+	}
+}
+
+void hns_roce_release_range_qp(struct hns_roce_dev *hr_dev, int base_qpn,
+			       int cnt)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+
+	if (base_qpn < (hr_dev->caps.sqp_start + 2 * hr_dev->caps.num_ports))
+		return;
+
+	hns_roce_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt);
+}
+
+static int hns_roce_set_rq_size(struct hns_roce_dev *hr_dev,
+				struct ib_qp_cap *cap, int is_user, int has_srq,
+				struct hns_roce_qp *hr_qp)
+{
+	u32 max_cnt;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* Check the validity of QP support capacity */
+	if (cap->max_recv_wr > hr_dev->caps.max_wqes ||
+	    cap->max_recv_sge > hr_dev->caps.max_rq_sg) {
+		dev_err(dev, "RQ WR or sge error!max_recv_wr=%d max_recv_sge=%d\n",
+			cap->max_recv_wr, cap->max_recv_sge);
+		return -EINVAL;
+	}
+
+	/* If srq exit, set zero for relative number of rq */
+	if (has_srq) {
+		if (cap->max_recv_wr) {
+			dev_dbg(dev, "srq no need config max_recv_wr\n");
+			return -EINVAL;
+		}
+
+		hr_qp->rq.wqe_cnt = hr_qp->rq.max_gs = 0;
+	} else {
+		if (is_user && (!cap->max_recv_wr || !cap->max_recv_sge)) {
+			dev_err(dev, "user space no need config max_recv_wr max_recv_sge\n");
+			return -EINVAL;
+		}
+
+		/* In v1 engine, parameter verification procession */
+		max_cnt = cap->max_recv_wr > HNS_ROCE_MIN_WQE_NUM ?
+			  cap->max_recv_wr : HNS_ROCE_MIN_WQE_NUM;
+		hr_qp->rq.wqe_cnt = roundup_pow_of_two(max_cnt);
+
+		if ((u32)hr_qp->rq.wqe_cnt > hr_dev->caps.max_wqes) {
+			dev_err(dev, "hns_roce_set_rq_size rq.wqe_cnt too large\n");
+			return -EINVAL;
+		}
+
+		max_cnt = max(1U, cap->max_recv_sge);
+		hr_qp->rq.max_gs = roundup_pow_of_two(max_cnt);
+		/* WQE is fixed for 64B */
+		hr_qp->rq.wqe_shift = ilog2(hr_dev->caps.max_rq_desc_sz);
+	}
+
+	cap->max_recv_wr = hr_qp->rq.max_post = hr_qp->rq.wqe_cnt;
+	cap->max_recv_sge = hr_qp->rq.max_gs;
+
+	return 0;
+}
+
+static int hns_roce_set_user_sq_size(struct hns_roce_dev *hr_dev,
+				     struct hns_roce_qp *hr_qp,
+				     struct hns_roce_ib_create_qp *ucmd)
+{
+	u32 roundup_sq_stride = roundup_pow_of_two(hr_dev->caps.max_sq_desc_sz);
+	u8 max_sq_stride = ilog2(roundup_sq_stride);
+
+	/* Sanity check SQ size before proceeding */
+	if ((u32)(1 << ucmd->log_sq_bb_count) > hr_dev->caps.max_wqes ||
+	     ucmd->log_sq_stride > max_sq_stride ||
+	     ucmd->log_sq_stride < HNS_ROCE_IB_MIN_SQ_STRIDE) {
+		dev_err(&hr_dev->pdev->dev, "check SQ size error!\n");
+		return -EINVAL;
+	}
+
+	hr_qp->sq.wqe_cnt = 1 << ucmd->log_sq_bb_count;
+	hr_qp->sq.wqe_shift = ucmd->log_sq_stride;
+
+	/* Get buf size, SQ and RQ  are aligned to page_szie */
+	hr_qp->buff_size = HNS_ROCE_ALOGN_UP((hr_qp->rq.wqe_cnt <<
+					     hr_qp->rq.wqe_shift), PAGE_SIZE) +
+			   HNS_ROCE_ALOGN_UP((hr_qp->sq.wqe_cnt <<
+					     hr_qp->sq.wqe_shift), PAGE_SIZE);
+
+	hr_qp->sq.offset = 0;
+	hr_qp->rq.offset = HNS_ROCE_ALOGN_UP((hr_qp->sq.wqe_cnt <<
+					     hr_qp->sq.wqe_shift), PAGE_SIZE);
+
+	return 0;
+}
+
+static int hns_roce_set_kernel_sq_size(struct hns_roce_dev *hr_dev,
+				       struct ib_qp_cap *cap,
+				       enum ib_qp_type type,
+				       struct hns_roce_qp *hr_qp)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 max_cnt;
+	(void)type;
+
+	if (cap->max_send_wr  > hr_dev->caps.max_wqes  ||
+	    cap->max_send_sge > hr_dev->caps.max_sq_sg ||
+	    cap->max_inline_data > hr_dev->caps.max_sq_inline) {
+		dev_err(dev, "hns_roce_set_kernel_sq_size error1\n");
+		return -EINVAL;
+	}
+
+	hr_qp->sq.wqe_shift = ilog2(hr_dev->caps.max_sq_desc_sz);
+	hr_qp->sq_max_wqes_per_wr = 1;
+	hr_qp->sq_spare_wqes = 0;
+
+	/* In v1 engine, parameter verification procession */
+	max_cnt = cap->max_send_wr > HNS_ROCE_MIN_WQE_NUM ?
+		  cap->max_send_wr : HNS_ROCE_MIN_WQE_NUM;
+	hr_qp->sq.wqe_cnt = roundup_pow_of_two(max_cnt);
+	if ((u32)hr_qp->sq.wqe_cnt > hr_dev->caps.max_wqes) {
+		dev_err(dev, "hns_roce_set_kernel_sq_size sq.wqe_cnt too large\n");
+		return -EINVAL;
+	}
+
+	/* Get data_seg numbers */
+	max_cnt = max(1U, cap->max_send_sge);
+	hr_qp->sq.max_gs = roundup_pow_of_two(max_cnt);
+
+	/* Get buf size, SQ and RQ  are aligned to page_szie */
+	hr_qp->buff_size = HNS_ROCE_ALOGN_UP((hr_qp->rq.wqe_cnt <<
+					     hr_qp->rq.wqe_shift), PAGE_SIZE) +
+			   HNS_ROCE_ALOGN_UP((hr_qp->sq.wqe_cnt <<
+					     hr_qp->sq.wqe_shift), PAGE_SIZE);
+	hr_qp->sq.offset = 0;
+	hr_qp->rq.offset = HNS_ROCE_ALOGN_UP((hr_qp->sq.wqe_cnt <<
+					      hr_qp->sq.wqe_shift), PAGE_SIZE);
+
+	/* Get wr and sge number which send */
+	cap->max_send_wr = hr_qp->sq.max_post = hr_qp->sq.wqe_cnt;
+	cap->max_send_sge = hr_qp->sq.max_gs;
+
+	/* We don't support inline sends for kernel QPs (yet) */
+	cap->max_inline_data = 0;
+
+	return 0;
+}
+
+static int hns_roce_create_qp_common(struct hns_roce_dev *hr_dev,
+				     struct ib_pd *ib_pd,
+				     struct ib_qp_init_attr *init_attr,
+				     struct ib_udata *udata, unsigned long sqpn,
+				     struct hns_roce_qp *hr_qp)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_ib_create_qp ucmd;
+	unsigned long qpn = 0;
+	int ret = 0;
+
+	mutex_init(&hr_qp->mutex);
+	spin_lock_init(&hr_qp->sq.lock);
+	spin_lock_init(&hr_qp->rq.lock);
+
+	hr_qp->state = IB_QPS_RESET;
+
+	if (init_attr->sq_sig_type == IB_SIGNAL_ALL_WR)
+		hr_qp->sq_signal_bits = IB_SIGNAL_ALL_WR;
+	else
+		hr_qp->sq_signal_bits = IB_SIGNAL_REQ_WR;
+
+	ret = hns_roce_set_rq_size(hr_dev, &init_attr->cap, !!ib_pd->uobject,
+				   !!init_attr->srq, hr_qp);
+	if (ret) {
+		dev_err(dev, "hns_roce_set_rq_size failed\n");
+		goto err_out;
+	}
+
+	if (ib_pd->uobject) {
+		if (ib_copy_from_udata(&ucmd, udata, sizeof(ucmd))) {
+			dev_err(dev, "ib_copy_from_udata error for create qp\n");
+			ret = -EFAULT;
+			goto err_out;
+		}
+
+		ret = hns_roce_set_user_sq_size(hr_dev, hr_qp, &ucmd);
+		if (ret) {
+			dev_err(dev, "hns_roce_set_user_sq_size error for create qp\n");
+			goto err_out;
+		}
+
+		hr_qp->umem = ib_umem_get(ib_pd->uobject->context,
+					  ucmd.buf_addr, hr_qp->buff_size, 0,
+					  0);
+		if (IS_ERR(hr_qp->umem)) {
+			dev_err(dev, "ib_umem_get error for create qp\n");
+			ret = PTR_ERR(hr_qp->umem);
+			goto err_out;
+		}
+
+		ret = hns_roce_mtt_init(hr_dev, ib_umem_page_count(hr_qp->umem),
+				    ilog2((unsigned int)hr_qp->umem->page_size),
+				    &hr_qp->mtt);
+		if (ret) {
+			dev_err(dev, "hns_roce_mtt_init error for create qp\n");
+			goto err_buf;
+		}
+
+		ret = hns_roce_ib_umem_write_mtt(hr_dev, &hr_qp->mtt,
+						 hr_qp->umem);
+		if (ret) {
+			dev_err(dev, "hns_roce_ib_umem_write_mtt error for create qp\n");
+			goto err_mtt;
+		}
+	} else {
+		if (init_attr->create_flags &
+		    IB_QP_CREATE_BLOCK_MULTICAST_LOOPBACK) {
+			dev_err(dev, "init_attr->create_flags error!\n");
+			ret = -EINVAL;
+			goto err_out;
+		}
+
+		if (init_attr->create_flags & IB_QP_CREATE_IPOIB_UD_LSO) {
+			dev_err(dev, "init_attr->create_flags error!\n");
+			ret = -EINVAL;
+			goto err_out;
+		}
+
+		/* Set SQ size */
+		ret = hns_roce_set_kernel_sq_size(hr_dev, &init_attr->cap,
+						  init_attr->qp_type, hr_qp);
+		if (ret) {
+			dev_err(dev, "hns_roce_set_kernel_sq_size error!\n");
+			goto err_out;
+		}
+
+		/* QP doorbell register address */
+		hr_qp->sq.db_reg_l = hr_dev->reg_base + ROCEE_DB_SQ_L_0_REG +
+				     DB_REG_OFFSET * hr_dev->priv_uar.index;
+		hr_qp->rq.db_reg_l = hr_dev->reg_base +
+				     ROCEE_DB_OTHERS_L_0_REG +
+				     DB_REG_OFFSET * hr_dev->priv_uar.index;
+
+		/* Allocate QP buf */
+		if (hns_roce_buf_alloc(hr_dev, hr_qp->buff_size, PAGE_SIZE * 2,
+				       &hr_qp->hr_buf)) {
+			dev_err(dev, "hns_roce_buf_alloc error!\n");
+			ret = -ENOMEM;
+			goto err_out;
+		}
+
+		/* Write MTT */
+		ret = hns_roce_mtt_init(hr_dev, hr_qp->hr_buf.npages,
+					hr_qp->hr_buf.page_shift, &hr_qp->mtt);
+		if (ret) {
+			dev_err(dev, "hns_roce_mtt_init error for kernel create qp\n");
+			goto err_buf;
+		}
+
+		ret = hns_roce_buf_write_mtt(hr_dev, &hr_qp->mtt,
+					     &hr_qp->hr_buf);
+		if (ret) {
+			dev_err(dev, "hns_roce_buf_write_mtt error for kernel create qp\n");
+			goto err_mtt;
+		}
+
+		hr_qp->sq.wrid = kmalloc_array(hr_qp->sq.wqe_cnt, sizeof(u64),
+					       GFP_KERNEL);
+		hr_qp->rq.wrid = kmalloc_array(hr_qp->rq.wqe_cnt, sizeof(u64),
+					       GFP_KERNEL);
+		if (!hr_qp->sq.wrid || !hr_qp->rq.wrid) {
+			ret = -ENOMEM;
+			goto err_wrid;
+		}
+	}
+
+	if (sqpn) {
+		qpn = sqpn;
+	} else {
+		/* Get QPN */
+		ret = hns_roce_reserve_range_qp(hr_dev, 1, 1, &qpn);
+		if (ret) {
+			dev_err(dev, "hns_roce_reserve_range_qp alloc qpn error\n");
+			goto err_wrid;
+		}
+	}
+
+	if ((init_attr->qp_type) == IB_QPT_GSI) {
+		ret = hns_roce_gsi_qp_alloc(hr_dev, qpn, hr_qp);
+		if (ret) {
+			dev_err(dev, "hns_roce_qp_alloc failed!\n");
+			goto err_qpn;
+		}
+	} else {
+		ret = hns_roce_qp_alloc(hr_dev, qpn, hr_qp);
+		if (ret) {
+			dev_err(dev, "hns_roce_qp_alloc failed!\n");
+			goto err_qpn;
+		}
+	}
+
+	if (sqpn)
+		hr_qp->doorbell_qpn = 1;
+	else
+		hr_qp->doorbell_qpn = cpu_to_le64(hr_qp->qpn);
+
+	hr_qp->event = hns_roce_ib_qp_event;
+
+	return 0;
+
+err_qpn:
+	if (!sqpn)
+		hns_roce_release_range_qp(hr_dev, qpn, 1);
+
+err_wrid:
+	kfree(hr_qp->sq.wrid);
+	kfree(hr_qp->rq.wrid);
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &hr_qp->mtt);
+
+err_buf:
+	if (ib_pd->uobject)
+		ib_umem_release(hr_qp->umem);
+	else
+		hns_roce_buf_free(hr_dev, hr_qp->buff_size, &hr_qp->hr_buf);
+
+err_out:
+	return ret;
+}
+
+struct ib_qp *hns_roce_create_qp(struct ib_pd *pd,
+				 struct ib_qp_init_attr *init_attr,
+				 struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(pd->device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_sqp *hr_sqp;
+	struct hns_roce_qp *hr_qp;
+	int ret;
+
+	switch (init_attr->qp_type) {
+	case IB_QPT_RC: {
+		hr_qp = kzalloc(sizeof(*hr_qp), GFP_KERNEL);
+		if (!hr_qp)
+			return ERR_PTR(-ENOMEM);
+
+		ret = hns_roce_create_qp_common(hr_dev, pd, init_attr, udata, 0,
+						hr_qp);
+		if (ret) {
+			dev_err(dev, "Create RC QP failed\n");
+			kfree(hr_qp);
+			return ERR_PTR(ret);
+		}
+
+		hr_qp->ibqp.qp_num = hr_qp->qpn;
+
+		break;
+	}
+	case IB_QPT_GSI: {
+		/* Userspace is not allowed to create special QPs: */
+		if (pd->uobject) {
+			dev_err(dev, "not support usr space GSI\n");
+			return ERR_PTR(-EINVAL);
+		}
+
+		hr_sqp = kzalloc(sizeof(*hr_sqp), GFP_KERNEL);
+		if (!hr_sqp)
+			return ERR_PTR(-ENOMEM);
+
+		hr_qp = &hr_sqp->hr_qp;
+
+		ret = hns_roce_create_qp_common(hr_dev, pd, init_attr, udata,
+						hr_dev->caps.sqp_start +
+						hr_dev->caps.num_ports +
+						init_attr->port_num - 1, hr_qp);
+		if (ret) {
+			dev_err(dev, "Create GSI QP failed!\n");
+			kfree(hr_sqp);
+			return ERR_PTR(ret);
+		}
+
+		hr_qp->port = (init_attr->port_num - 1);
+		hr_qp->ibqp.qp_num = hr_dev->caps.sqp_start +
+				     hr_dev->caps.num_ports +
+				     init_attr->port_num - 1;
+		break;
+	}
+	default:{
+		dev_err(dev, "not support QP type %d\n", init_attr->qp_type);
+		return ERR_PTR(-EINVAL);
+	}
+	}
+
+	return &hr_qp->ibqp;
+}
+
+int to_hr_qp_type(int qp_type)
+{
+	int transport_type;
+
+	if (qp_type == IB_QPT_RC)
+		transport_type = SERV_TYPE_RC;
+	else if (qp_type == IB_QPT_UC)
+		transport_type = SERV_TYPE_UC;
+	else if (qp_type == IB_QPT_UD)
+		transport_type = SERV_TYPE_UD;
+	else if (qp_type == IB_QPT_GSI)
+		transport_type = SERV_TYPE_UD;
+	else
+		transport_type = -1;
+
+	return transport_type;
+}
+
+int hns_roce_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		       int attr_mask, struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	enum ib_qp_state cur_state, new_state;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret = -EINVAL;
+	int p;
+
+	mutex_lock(&hr_qp->mutex);
+
+	cur_state = attr_mask & IB_QP_CUR_STATE ?
+		    attr->cur_qp_state : (enum ib_qp_state)hr_qp->state;
+	new_state = attr_mask & IB_QP_STATE ?
+		    attr->qp_state : cur_state;
+
+	if (!ib_modify_qp_is_ok(cur_state, new_state, ibqp->qp_type, attr_mask,
+				IB_LINK_LAYER_ETHERNET)) {
+		dev_err(dev, "ib_modify_qp_is_ok failed\n");
+		goto out;
+	}
+
+	if ((attr_mask & IB_QP_PORT) &&
+	    (attr->port_num == 0 || attr->port_num > hr_dev->caps.num_ports)) {
+		dev_err(dev, "attr port_num invalid.attr->port_num=%d\n",
+			attr->port_num);
+		goto out;
+	}
+
+	if (attr_mask & IB_QP_PKEY_INDEX) {
+		p = attr_mask & IB_QP_PORT ? attr->port_num : (hr_qp->port + 1);
+		if (attr->pkey_index >= hr_dev->caps.pkey_table_len[p]) {
+			dev_dbg(dev, "attr pkey_index invalid.attr->pkey_index=%d\n",
+				attr->pkey_index);
+			goto out;
+		}
+	}
+
+	if (attr_mask & IB_QP_MAX_QP_RD_ATOMIC &&
+	    attr->max_rd_atomic > hr_dev->caps.max_qp_init_rdma) {
+		dev_dbg(dev, "attr max_rd_atomic invalid.attr->max_rd_atomic=%d\n",
+			attr->max_rd_atomic);
+		goto out;
+	}
+
+	if (attr_mask & IB_QP_MAX_DEST_RD_ATOMIC &&
+	    attr->max_dest_rd_atomic > hr_dev->caps.max_qp_dest_rdma) {
+		dev_dbg(dev, "attr max_dest_rd_atomic invalid.attr->max_dest_rd_atomic=%d\n",
+			attr->max_dest_rd_atomic);
+		goto out;
+	}
+
+	if (cur_state == new_state && cur_state == IB_QPS_RESET) {
+		ret = -EPERM;
+		dev_dbg(dev, "cur_state=%d new_state=%d\n", cur_state,
+			new_state);
+		goto out;
+	}
+
+	ret = hr_dev->hw->modify_qp(ibqp, attr, attr_mask, cur_state,
+				    new_state);
+
+out:
+	mutex_unlock(&hr_qp->mutex);
+
+	return ret;
+}
+
+void hns_roce_lock_cqs(struct hns_roce_cq *send_cq, struct hns_roce_cq *recv_cq)
+		       __acquires(&send_cq->lock) __acquires(&recv_cq->lock)
+{
+	if (send_cq == recv_cq) {
+		spin_lock_irq(&send_cq->lock);
+		__acquire(&recv_cq->lock);
+	} else if (send_cq->cqn < recv_cq->cqn) {
+		spin_lock_irq(&send_cq->lock);
+		spin_lock_nested(&recv_cq->lock, SINGLE_DEPTH_NESTING);
+	} else {
+		spin_lock_irq(&recv_cq->lock);
+		spin_lock_nested(&send_cq->lock, SINGLE_DEPTH_NESTING);
+	}
+}
+
+void hns_roce_unlock_cqs(struct hns_roce_cq *send_cq,
+			 struct hns_roce_cq *recv_cq) __releases(&send_cq->lock)
+			 __releases(&recv_cq->lock)
+{
+	if (send_cq == recv_cq) {
+		__release(&recv_cq->lock);
+		spin_unlock_irq(&send_cq->lock);
+	} else if (send_cq->cqn < recv_cq->cqn) {
+		spin_unlock(&recv_cq->lock);
+		spin_unlock_irq(&send_cq->lock);
+	} else {
+		spin_unlock(&send_cq->lock);
+		spin_unlock_irq(&recv_cq->lock);
+	}
+}
+
+__be32 send_ieth(struct ib_send_wr *wr)
+{
+	switch (wr->opcode) {
+	case IB_WR_SEND_WITH_IMM:
+	case IB_WR_RDMA_WRITE_WITH_IMM:
+		return cpu_to_le32(wr->ex.imm_data);
+	case IB_WR_SEND_WITH_INV:
+		return cpu_to_le32(wr->ex.invalidate_rkey);
+	default:
+		return 0;
+	}
+}
+
+static void *get_wqe(struct hns_roce_qp *hr_qp, int offset)
+{
+
+	return hns_roce_buf_offset(&hr_qp->hr_buf, offset);
+}
+
+void *get_recv_wqe(struct hns_roce_qp *hr_qp, int n)
+{
+	struct ib_qp *ibqp = &hr_qp->ibqp;
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+
+	if ((n < 0) || (n > hr_qp->rq.wqe_cnt)) {
+		dev_err(&hr_dev->pdev->dev, "rq wqe index:%d,rq wqe cnt:%d\r\n",
+			n, hr_qp->rq.wqe_cnt);
+		return NULL;
+	}
+
+	return get_wqe(hr_qp, hr_qp->rq.offset + (n << hr_qp->rq.wqe_shift));
+}
+
+void *get_send_wqe(struct hns_roce_qp *hr_qp, int n)
+{
+	struct ib_qp *ibqp = &hr_qp->ibqp;
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+
+	if ((n < 0) || (n > hr_qp->sq.wqe_cnt)) {
+		dev_err(&hr_dev->pdev->dev, "sq wqe index:%d,sq wqe cnt:%d\r\n",
+			n, hr_qp->sq.wqe_cnt);
+		return NULL;
+	}
+
+	return get_wqe(hr_qp, hr_qp->sq.offset + (n << hr_qp->sq.wqe_shift));
+}
+
+bool hns_roce_wq_overflow(struct hns_roce_wq *hr_wq, int nreq,
+			  struct ib_cq *ib_cq)
+{
+	struct hns_roce_cq *hr_cq;
+	u32 cur;
+
+	cur = hr_wq->head - hr_wq->tail;
+	if (likely(cur + nreq < hr_wq->max_post))
+		return 0;
+
+	hr_cq = to_hr_cq(ib_cq);
+	spin_lock(&hr_cq->lock);
+	cur = hr_wq->head - hr_wq->tail;
+	spin_unlock(&hr_cq->lock);
+
+	return cur + nreq >= hr_wq->max_post;
+}
+
 int hns_roce_init_qp_table(struct hns_roce_dev *hr_dev)
 {
 	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
diff --git a/drivers/infiniband/hw/hns/hns_roce_user.h b/drivers/infiniband/hw/hns/hns_roce_user.h
index 3b33ce4..a28f761 100644
--- a/drivers/infiniband/hw/hns/hns_roce_user.h
+++ b/drivers/infiniband/hw/hns/hns_roce_user.h
@@ -33,6 +33,19 @@
 #ifndef _HNS_ROCE_USER_H
 #define _HNS_ROCE_USER_H
 
+struct hns_roce_ib_create_cq {
+	__u64   buf_addr;
+};
+
+struct hns_roce_ib_create_qp {
+	__u64	buf_addr;
+	__u64   db_addr;
+	__u8    log_sq_bb_count;
+	__u8    log_sq_stride;
+	__u8    sq_no_prefetch;
+	__u8    reserved[5];
+};
+
 struct hns_roce_ib_alloc_ucontext_resp {
 	__u32	qp_tab_size;
 };
-- 
1.9.1
