From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/20] igb: add a character device to support AVB
Date: Tue, 23 Feb 2016 20:26:11 -0800
Message-ID: <1456287984-10459-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Gangfeng Huang <gangfeng.huang@ni.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757357AbcBXE0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:30 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gangfeng Huang <gangfeng.huang@ni.com>

This patch create a character device for Intel I210 Ethernet controller,
it can be used for developing Audio/Video Bridging applications,Industrial
Ethernet applications which require precise timing control over frame
transmission, or test harnesses for measuring system latencies and sampling
events.

As the AVB queues (0,1) are mapped to a  user-space application, typical
LAN traffic must be steered away from these queues. For transmit, this
driver implements one method registering an ndo_select_queue handler to
map traffic to queue[3] and set the register MRQC to receive all BE
traffic to Rx queue[3].

This patch is reference to the Intel Open-AVB project:
http://github.com/AVnu/Open-AVB/tree/master/kmod/igb

Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/Makefile        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |   1 +
 drivers/net/ethernet/intel/igb/igb.h           |  14 +-
 drivers/net/ethernet/intel/igb/igb_cdev.c      | 511 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_cdev.h      |  45 +++
 drivers/net/ethernet/intel/igb/igb_main.c      | 103 ++++-
 6 files changed, 663 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_cdev.c
 create mode 100644 drivers/net/ethernet/intel/igb/igb_cdev.h

diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
index 5bcb2de..3fee429 100644
--- a/drivers/net/ethernet/intel/igb/Makefile
+++ b/drivers/net/ethernet/intel/igb/Makefile
@@ -33,4 +33,4 @@ obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
 	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o \
-	    e1000_i210.o igb_ptp.o igb_hwmon.o
+	    e1000_i210.o igb_ptp.o igb_hwmon.o igb_cdev.o
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index c8b10d2..5686a2c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -112,6 +112,7 @@
 #define E1000_MRQC_RSS_FIELD_IPV6              0x00100000
 #define E1000_MRQC_RSS_FIELD_IPV6_TCP          0x00200000
 
+#define E1000_MRQC_DEF_QUEUE_OFFSET            0x3
 
 /* Management Control */
 #define E1000_MANC_SMBUS_EN      0x00000001 /* SMBus Enabled - RO */
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 3ad5517..3fa3a85 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -38,6 +38,8 @@
 #include <linux/i2c-algo-bit.h>
 #include <linux/pci.h>
 #include <linux/mdio.h>
+#include <linux/types.h>
+#include <linux/cdev.h>
 
 struct igb_adapter;
 
@@ -50,12 +52,12 @@ struct igb_adapter;
 #define IGB_70K_ITR		56
 
 /* TX/RX descriptor defines */
-#define IGB_DEFAULT_TXD		256
+#define IGB_DEFAULT_TXD		1024
 #define IGB_DEFAULT_TX_WORK	128
 #define IGB_MIN_TXD		80
 #define IGB_MAX_TXD		4096
 
-#define IGB_DEFAULT_RXD		256
+#define IGB_DEFAULT_RXD		1024
 #define IGB_MIN_RXD		80
 #define IGB_MAX_RXD		4096
 
@@ -469,6 +471,14 @@ struct igb_adapter {
 	u16 eee_advert;
 
 	bool qav_mode;
+	struct cdev char_dev;
+	struct list_head user_page_list;
+	struct mutex user_page_mutex; /* protect user_page_list */
+	unsigned long tx_uring_init;
+	unsigned long rx_uring_init;
+	struct mutex user_ring_mutex; /* protect tx/rx_uring_init */
+	bool cdev_in_use;
+	struct mutex cdev_mutex; /* protect cdev_in_use */
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_cdev.c b/drivers/net/ethernet/intel/igb/igb_cdev.c
new file mode 100644
index 0000000..df237c6
--- /dev/null
+++ b/drivers/net/ethernet/intel/igb/igb_cdev.c
@@ -0,0 +1,511 @@
+#include "igb.h"
+#include "igb_cdev.h"
+
+#include <linux/pagemap.h>
+#include <linux/bitops.h>
+#include <linux/types.h>
+#include <linux/cdev.h>
+
+/* TSN char dev */
+static DECLARE_BITMAP(cdev_minors, IGB_MAX_DEV_NUM);
+
+static int igb_major;
+static struct class *igb_class;
+static const char * const igb_class_name = "igb_tsn";
+static const char * const igb_dev_name = "igb_tsn_%s";
+
+/* user-mode API forward definitions */
+static int igb_open_file(struct inode *inode, struct file *file);
+static int igb_close_file(struct inode *inode, struct file *file);
+static int igb_mmap(struct file *file, struct vm_area_struct *vma);
+static long igb_ioctl_file(struct file *file, unsigned int cmd,
+			   unsigned long arg);
+
+/* user-mode IO API registrations */
+static const struct file_operations igb_fops = {
+		.owner   = THIS_MODULE,
+		.llseek  = no_llseek,
+		.open	= igb_open_file,
+		.release = igb_close_file,
+		.mmap	= igb_mmap,
+		.unlocked_ioctl = igb_ioctl_file,
+};
+
+int igb_tsn_setup_all_tx_resources(struct igb_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	int i, err = 0;
+
+	for (i = 0; i < IGB_USER_TX_QUEUES; i++) {
+		err = igb_setup_tx_resources(adapter->tx_ring[i]);
+		if (err) {
+			dev_err(&pdev->dev,
+				"Allocation for Tx Queue %u failed\n", i);
+			for (i--; i >= 0; i--)
+				igb_free_tx_resources(adapter->tx_ring[i]);
+			break;
+		}
+	}
+
+	return err;
+}
+
+int igb_tsn_setup_all_rx_resources(struct igb_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	int i, err = 0;
+
+	for (i = 0; i < IGB_USER_RX_QUEUES; i++) {
+		err = igb_setup_rx_resources(adapter->rx_ring[i]);
+		if (err) {
+			dev_err(&pdev->dev,
+				"Allocation for Rx Queue %u failed\n", i);
+			for (i--; i >= 0; i--)
+				igb_free_rx_resources(adapter->rx_ring[i]);
+			break;
+		}
+	}
+
+	return err;
+}
+
+void igb_tsn_free_all_tx_resources(struct igb_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < IGB_USER_TX_QUEUES; i++)
+		igb_free_tx_resources(adapter->tx_ring[i]);
+}
+
+void igb_tsn_free_all_rx_resources(struct igb_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < IGB_USER_RX_QUEUES; i++)
+		igb_free_rx_resources(adapter->rx_ring[i]);
+}
+
+static int igb_bind(struct file *file, void __user *argp)
+{
+	struct igb_adapter *adapter;
+	u32 mmap_size;
+
+	adapter = (struct igb_adapter *)file->private_data;
+
+	if (NULL == adapter)
+		return -ENOENT;
+
+	mmap_size = pci_resource_len(adapter->pdev, 0);
+
+	if (copy_to_user(argp, &mmap_size, sizeof(mmap_size)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static long igb_mapring(struct file *file, void __user *arg)
+{
+	struct igb_adapter *adapter;
+	struct igb_buf_cmd req;
+	int queue_size;
+	unsigned long *uring_init;
+	struct igb_ring *ring;
+	int err;
+
+	if (copy_from_user(&req, arg, sizeof(req)))
+		return -EFAULT;
+
+	if (req.flags != 0 && req.flags != 1)
+		return -EINVAL;
+
+	adapter = file->private_data;
+	if (NULL == adapter) {
+		dev_err(&adapter->pdev->dev, "map to unbound device!\n");
+		return -ENOENT;
+	}
+
+	/* Req flags, Tx: 0, Rx: 1 */
+	if (req.flags == 0) {
+		queue_size = IGB_USER_TX_QUEUES;
+		uring_init =  &adapter->tx_uring_init;
+		ring = adapter->tx_ring[req.queue];
+	} else {
+		queue_size = IGB_USER_RX_QUEUES;
+		uring_init =  &adapter->rx_uring_init;
+		ring = adapter->rx_ring[req.queue];
+	}
+
+	mutex_lock(&adapter->user_ring_mutex);
+	if (test_bit(req.queue, uring_init)) {
+		dev_err(&adapter->pdev->dev, "the queue is in using\n");
+		err = -EBUSY;
+		goto failed;
+	}
+
+	if (req.queue >= queue_size) {
+		err = -EINVAL;
+		goto failed;
+	}
+
+	set_pages_uc(virt_to_page(ring->desc), ring->size >> PAGE_SHIFT);
+	set_bit(req.queue, uring_init);
+	mutex_unlock(&adapter->user_ring_mutex);
+
+	req.physaddr = ring->dma;
+	req.mmap_size = ring->size;
+
+	if (copy_to_user(arg, &req, sizeof(req))) {
+		dev_err(&adapter->pdev->dev, "copyout to user failed\n");
+		return -EFAULT;
+	}
+
+	return 0;
+failed:
+	mutex_unlock(&adapter->user_ring_mutex);
+	return err;
+}
+
+static long igb_mapbuf(struct file *file, void __user *arg)
+{
+	struct igb_adapter *adapter;
+	struct igb_buf_cmd req;
+	struct page *page;
+	dma_addr_t page_dma;
+	struct igb_user_page *userpage;
+	int err = 0;
+	int direction;
+
+	if (copy_from_user(&req, arg, sizeof(req)))
+		return -EFAULT;
+
+	if (req.flags != 0 && req.flags != 1)
+		return -EINVAL;
+
+	adapter = file->private_data;
+	if (NULL == adapter) {
+		dev_err(&adapter->pdev->dev, "map to unbound device!\n");
+		return -ENOENT;
+	}
+
+	userpage = kzalloc(sizeof(*userpage), GFP_KERNEL);
+	if (unlikely(!userpage))
+		return -ENOMEM;
+
+	page = alloc_page(GFP_KERNEL | __GFP_COLD);
+	if (unlikely(!page)) {
+		err = -ENOMEM;
+		goto failed;
+	}
+
+	direction = req.flags ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
+	page_dma = dma_map_page(&adapter->pdev->dev, page,
+				0, PAGE_SIZE, direction);
+
+	if (dma_mapping_error(&adapter->pdev->dev, page_dma)) {
+		put_page(page);
+		err = -ENOMEM;
+		goto failed;
+	}
+
+	set_pages_uc(page, 1);
+	userpage->page = page;
+	userpage->page_dma = page_dma;
+	userpage->flags = req.flags;
+
+	mutex_lock(&adapter->user_page_mutex);
+	list_add_tail(&userpage->page_node, &adapter->user_page_list);
+	mutex_unlock(&adapter->user_page_mutex);
+
+	req.physaddr = page_dma;
+	req.mmap_size = PAGE_SIZE;
+
+	if (copy_to_user(arg, &req, sizeof(req))) {
+		dev_err(&adapter->pdev->dev, "copyout to user failed\n");
+		return -EFAULT;
+	}
+	return 0;
+
+failed:
+	kfree(userpage);
+	return err;
+}
+
+static long igb_unmapring(struct file *file, void __user *arg)
+{
+	struct igb_adapter *adapter;
+	struct igb_buf_cmd req;
+	struct igb_ring *ring;
+	int queue_size;
+	unsigned long *uring_init;
+	int err;
+
+	if (copy_from_user(&req, arg, sizeof(req)))
+		return -EFAULT;
+
+	if (req.flags != 0 && req.flags != 1)
+		return -EINVAL;
+
+	adapter = file->private_data;
+	if (NULL == adapter) {
+		dev_err(&adapter->pdev->dev, "map to unbound device!\n");
+		return -ENOENT;
+	}
+
+	if (req.flags == 0) {
+		queue_size = IGB_USER_TX_QUEUES;
+		uring_init =  &adapter->tx_uring_init;
+		ring = adapter->tx_ring[req.queue];
+	} else {
+		queue_size = IGB_USER_RX_QUEUES;
+		uring_init =  &adapter->rx_uring_init;
+		ring = adapter->rx_ring[req.queue];
+	}
+
+	if (req.queue >= queue_size)
+		return -EINVAL;
+
+	mutex_lock(&adapter->user_ring_mutex);
+	if (!test_bit(req.queue, uring_init)) {
+		dev_err(&adapter->pdev->dev,
+			"the ring is already unmap\n");
+		err = -EINVAL;
+		goto failed;
+	}
+
+	set_pages_wb(virt_to_page(ring->desc), ring->size >> PAGE_SHIFT);
+	clear_bit(req.queue, uring_init);
+	mutex_unlock(&adapter->user_ring_mutex);
+
+	return 0;
+failed:
+	mutex_unlock(&adapter->user_ring_mutex);
+	return err;
+}
+
+static void igb_free_page(struct igb_adapter *adapter,
+			  struct igb_user_page *userpage)
+{
+	int direction = userpage->flags ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
+
+	set_pages_wb(userpage->page, 1);
+	dma_unmap_page(&adapter->pdev->dev,
+		       userpage->page_dma,
+		       PAGE_SIZE,
+		       direction);
+
+	put_page(userpage->page);
+	list_del(&userpage->page_node);
+	kfree(userpage);
+	userpage = NULL;
+}
+
+static long igb_unmapbuf(struct file *file, void __user *arg)
+{
+	int err = 0;
+	struct igb_adapter *adapter;
+	struct igb_buf_cmd req;
+	struct igb_user_page *userpage, *tmp;
+
+	if (copy_from_user(&req, arg, sizeof(req)))
+		return -EFAULT;
+
+	adapter = file->private_data;
+	if (NULL == adapter) {
+		dev_err(&adapter->pdev->dev, "map to unbound device!\n");
+		return -ENOENT;
+	}
+
+	mutex_lock(&adapter->user_page_mutex);
+	if (list_empty(&adapter->user_page_list)) {
+		err = -EINVAL;
+		goto failed;
+	}
+
+	list_for_each_entry_safe(userpage, tmp, &adapter->user_page_list,
+				 page_node) {
+		if (req.physaddr == userpage->page_dma) {
+			igb_free_page(adapter, userpage);
+			break;
+		}
+	}
+	mutex_unlock(&adapter->user_page_mutex);
+
+	return 0;
+failed:
+	mutex_unlock(&adapter->user_page_mutex);
+	return err;
+}
+
+static long igb_ioctl_file(struct file *file, unsigned int cmd,
+			   unsigned long arg)
+{
+	void __user *argp = (void __user *)arg;
+	int err;
+
+	switch (cmd) {
+	case IGB_BIND:
+		err = igb_bind(file, argp);
+		break;
+	case IGB_MAPRING:
+		err = igb_mapring(file, argp);
+		break;
+	case IGB_MAPBUF:
+		err = igb_mapbuf(file, argp);
+		break;
+	case IGB_UNMAPRING:
+		err = igb_unmapring(file, argp);
+		break;
+	case IGB_UNMAPBUF:
+		err = igb_unmapbuf(file, argp);
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	};
+
+	return err;
+}
+
+static int igb_open_file(struct inode *inode, struct file *file)
+{
+	struct igb_adapter *adapter;
+	int err = 0;
+
+	adapter = container_of(inode->i_cdev, struct igb_adapter, char_dev);
+	if (!adapter)
+		return -ENOENT;
+
+	if (!adapter->qav_mode)
+		return -EPERM;
+
+	mutex_lock(&adapter->cdev_mutex);
+	if (adapter->cdev_in_use) {
+		err = -EBUSY;
+		goto failed;
+	}
+
+	file->private_data = adapter;
+	adapter->cdev_in_use = true;
+	mutex_unlock(&adapter->cdev_mutex);
+
+	return 0;
+failed:
+	mutex_unlock(&adapter->cdev_mutex);
+	return err;
+}
+
+static int igb_close_file(struct inode *inode, struct file *file)
+{
+	struct igb_adapter *adapter = file->private_data;
+
+	if (NULL == adapter)
+		return 0;
+
+	mutex_lock(&adapter->cdev_mutex);
+	if (!adapter->cdev_in_use)
+		goto out;
+
+	mutex_lock(&adapter->user_page_mutex);
+	if (!list_empty(&adapter->user_page_list)) {
+		struct igb_user_page *userpage, *tmp;
+
+		list_for_each_entry_safe(userpage, tmp,
+					 &adapter->user_page_list, page_node) {
+			if (userpage)
+				igb_free_page(adapter, userpage);
+		}
+	}
+	mutex_unlock(&adapter->user_page_mutex);
+
+	file->private_data = NULL;
+	adapter->cdev_in_use = false;
+	adapter->tx_uring_init = 0;
+	adapter->rx_uring_init = 0;
+
+out:
+	mutex_unlock(&adapter->cdev_mutex);
+	return 0;
+}
+
+static int igb_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct igb_adapter *adapter = file->private_data;
+	unsigned long size  = vma->vm_end - vma->vm_start;
+	dma_addr_t pgoff = vma->vm_pgoff;
+	dma_addr_t physaddr;
+
+	if (NULL == adapter)
+		return -ENODEV;
+
+	if (pgoff == 0)
+		physaddr = pci_resource_start(adapter->pdev, 0) >> PAGE_SHIFT;
+	else
+		physaddr = pgoff;
+
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+
+	if (remap_pfn_range(vma, vma->vm_start,
+			    physaddr, size, vma->vm_page_prot))
+		return -EAGAIN;
+
+	return 0;
+}
+
+int igb_add_cdev(struct igb_adapter *adapter)
+{
+	int result = 0;
+	dev_t dev_num;
+	int igb_minor;
+
+	igb_minor = find_first_zero_bit(cdev_minors, IGB_MAX_DEV_NUM);
+	if (igb_minor >= IGB_MAX_DEV_NUM)
+		return -EBUSY;
+	set_bit(igb_minor, cdev_minors);
+
+	dev_num = MKDEV(igb_major, igb_minor);
+	cdev_init(&adapter->char_dev, &igb_fops);
+	adapter->char_dev.owner = THIS_MODULE;
+	adapter->char_dev.ops = &igb_fops;
+	result = cdev_add(&adapter->char_dev, dev_num, 1);
+
+	if (result) {
+		dev_err(&adapter->pdev->dev,
+			"igb_tsn: add character device failed\n");
+		return result;
+	}
+
+	device_create(igb_class, NULL, dev_num, NULL, igb_dev_name,
+		      adapter->netdev->name);
+
+	return 0;
+}
+
+void igb_remove_cdev(struct igb_adapter *adapter)
+{
+	device_destroy(igb_class, adapter->char_dev.dev);
+	cdev_del(&adapter->char_dev);
+}
+
+int igb_cdev_init(char *igb_driver_name)
+{
+	dev_t dev_num;
+	int ret;
+
+	ret = alloc_chrdev_region(&dev_num, 0, IGB_MAX_DEV_NUM,
+				  igb_driver_name);
+	if (ret)
+		return ret;
+	igb_major = MAJOR(dev_num);
+
+	igb_class = class_create(THIS_MODULE, igb_class_name);
+	if (IS_ERR(igb_class))
+		pr_info("igb_tsn: create device class failed\n");
+
+	return ret;
+}
+
+void igb_cdev_destroy(void)
+{
+	class_destroy(igb_class);
+	unregister_chrdev_region(MKDEV(igb_major, 0), IGB_MAX_DEV_NUM);
+}
diff --git a/drivers/net/ethernet/intel/igb/igb_cdev.h b/drivers/net/ethernet/intel/igb/igb_cdev.h
new file mode 100644
index 0000000..a07b208
--- /dev/null
+++ b/drivers/net/ethernet/intel/igb/igb_cdev.h
@@ -0,0 +1,45 @@
+#ifndef _IGB_CDEV_H_
+#define _IGB_CDEV_H_
+
+#include <asm/page.h>
+#include <asm/ioctl.h>
+
+struct igb_adapter;
+/* queues reserved for user mode */
+#define IGB_USER_TX_QUEUES	2
+#define IGB_USER_RX_QUEUES	2
+#define IGB_MAX_DEV_NUM	64
+
+/* TSN char dev ioctls */
+#define IGB_BIND       _IOW('E', 200, int)
+#define IGB_MAPRING    _IOW('E', 201, int)
+#define IGB_UNMAPRING  _IOW('E', 202, int)
+#define IGB_MAPBUF     _IOW('E', 203, int)
+#define IGB_UNMAPBUF   _IOW('E', 204, int)
+
+/* Used with both map/unmap ring & buf ioctls */
+struct igb_buf_cmd {
+	u64		physaddr;
+	u32		queue;
+	u32		mmap_size;
+	u32		flags;
+};
+
+struct igb_user_page {
+	struct list_head page_node;
+	struct page *page;
+	dma_addr_t page_dma;
+	u32 flags;
+};
+
+int igb_tsn_setup_all_tx_resources(struct igb_adapter *);
+int igb_tsn_setup_all_rx_resources(struct igb_adapter *);
+void igb_tsn_free_all_tx_resources(struct igb_adapter *);
+void igb_tsn_free_all_rx_resources(struct igb_adapter *);
+
+int igb_add_cdev(struct igb_adapter *adapter);
+void igb_remove_cdev(struct igb_adapter *adapter);
+int igb_cdev_init(char *igb_driver_name);
+void igb_cdev_destroy(void);
+
+#endif
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 362d579..0d501a8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -55,6 +55,7 @@
 #endif
 #include <linux/i2c.h>
 #include "igb.h"
+#include "igb_cdev.h"
 
 #define MAJ 5
 #define MIN 3
@@ -690,6 +691,11 @@ static int __init igb_init_module(void)
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
+
+	ret = igb_cdev_init(igb_driver_name);
+	if (ret)
+		return ret;
+
 	ret = pci_register_driver(&igb_driver);
 	return ret;
 }
@@ -708,6 +714,8 @@ static void __exit igb_exit_module(void)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&igb_driver);
+
+	igb_cdev_destroy();
 }
 
 module_exit(igb_exit_module);
@@ -1635,7 +1643,8 @@ static void igb_configure(struct igb_adapter *adapter)
 	 * at least 1 descriptor unused to make sure
 	 * next_to_use != next_to_clean
 	 */
-	for (i = 0; i < adapter->num_rx_queues; i++) {
+	i = adapter->qav_mode ? IGB_USER_RX_QUEUES : 0;
+	for (; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = adapter->rx_ring[i];
 		igb_alloc_rx_buffers(ring, igb_desc_unused(ring));
 	}
@@ -2104,10 +2113,24 @@ static int igb_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return ndo_dflt_fdb_add(ndm, tb, dev, addr, vid, flags);
 }
 
+static u16 igb_select_queue(struct net_device *netdev,
+			    struct sk_buff *skb,
+			    void *accel_priv,
+			    select_queue_fallback_t fallback)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	if (adapter->qav_mode)
+		return adapter->num_tx_queues - 1;
+	else
+		return fallback(netdev, skb);
+}
+
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
 	.ndo_start_xmit		= igb_xmit_frame,
+	.ndo_select_queue	= igb_select_queue,
 	.ndo_get_stats64	= igb_get_stats64,
 	.ndo_set_rx_mode	= igb_set_rx_mode,
 	.ndo_set_mac_address	= igb_set_mac,
@@ -2334,6 +2357,10 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 	adapter->qav_mode = false;
 
+	adapter->tx_uring_init = 0;
+	adapter->rx_uring_init = 0;
+	adapter->cdev_in_use = false;
+
 	err = -EIO;
 	adapter->io_addr = pci_iomap(pdev, 0, 0);
 	if (!adapter->io_addr)
@@ -2589,6 +2616,10 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
+	err = igb_add_cdev(adapter);
+	if (err)
+		goto err_register;
+
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
@@ -2837,6 +2868,8 @@ static void igb_remove(struct pci_dev *pdev)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	igb_remove_cdev(adapter);
+
 	pm_runtime_get_noresume(&pdev->dev);
 #ifdef CONFIG_IGB_HWMON
 	igb_sysfs_exit(adapter);
@@ -3028,6 +3061,12 @@ static int igb_sw_init(struct igb_adapter *adapter)
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	spin_lock_init(&adapter->stats64_lock);
+
+	INIT_LIST_HEAD(&adapter->user_page_list);
+	mutex_init(&adapter->user_page_mutex);
+	mutex_init(&adapter->user_ring_mutex);
+	mutex_init(&adapter->cdev_mutex);
+
 #ifdef CONFIG_PCI_IOV
 	switch (hw->mac.type) {
 	case e1000_82576:
@@ -3277,7 +3316,8 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int i, err = 0;
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
+	i = adapter->qav_mode ? IGB_USER_TX_QUEUES : 0;
+	for (; i < adapter->num_tx_queues; i++) {
 		err = igb_setup_tx_resources(adapter->tx_ring[i]);
 		if (err) {
 			dev_err(&pdev->dev,
@@ -3365,7 +3405,8 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 {
 	int i;
 
-	for (i = 0; i < adapter->num_tx_queues; i++)
+	i = adapter->qav_mode ? IGB_USER_TX_QUEUES : 0;
+	for (; i < adapter->num_tx_queues; i++)
 		igb_configure_tx_ring(adapter, adapter->tx_ring[i]);
 }
 
@@ -3420,7 +3461,8 @@ static int igb_setup_all_rx_resources(struct igb_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int i, err = 0;
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
+	i = adapter->qav_mode ? IGB_USER_RX_QUEUES : 0;
+	for (; i < adapter->num_rx_queues; i++) {
 		err = igb_setup_rx_resources(adapter->rx_ring[i]);
 		if (err) {
 			dev_err(&pdev->dev,
@@ -3445,6 +3487,15 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	u32 j, num_rx_queues;
 	u32 rss_key[10];
 
+	/* For TSN, kernel driver only create buffer for queue 2 and queue 3,
+	 * by default receive all BE packets from queue 3.
+	 */
+	if (adapter->qav_mode) {
+		wr32(E1000_MRQC, (adapter->num_rx_queues - 1)
+		     << E1000_MRQC_DEF_QUEUE_OFFSET);
+		return;
+	}
+
 	netdev_rss_key_fill(rss_key, sizeof(rss_key));
 	for (j = 0; j < 10; j++)
 		wr32(E1000_RSSRK(j), rss_key[j]);
@@ -3520,6 +3571,7 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 		if (hw->mac.type != e1000_i211)
 			mrqc |= E1000_MRQC_ENABLE_RSS_4Q;
 	}
+
 	igb_vmm_control(adapter);
 
 	wr32(E1000_MRQC, mrqc);
@@ -3713,7 +3765,8 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
-	for (i = 0; i < adapter->num_rx_queues; i++)
+	i = adapter->qav_mode ? IGB_USER_RX_QUEUES : 0;
+	for (; i < adapter->num_rx_queues; i++)
 		igb_configure_rx_ring(adapter, adapter->rx_ring[i]);
 }
 
@@ -3749,8 +3802,8 @@ void igb_free_tx_resources(struct igb_ring *tx_ring)
 static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 {
 	int i;
-
-	for (i = 0; i < adapter->num_tx_queues; i++)
+	i = adapter->qav_mode ? IGB_USER_TX_QUEUES : 0;
+	for (; i < adapter->num_tx_queues; i++)
 		if (adapter->tx_ring[i])
 			igb_free_tx_resources(adapter->tx_ring[i]);
 }
@@ -3816,7 +3869,8 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
 {
 	int i;
 
-	for (i = 0; i < adapter->num_tx_queues; i++)
+	i = adapter->qav_mode ? IGB_USER_TX_QUEUES : 0;
+	for (; i < adapter->num_tx_queues; i++)
 		if (adapter->tx_ring[i])
 			igb_clean_tx_ring(adapter->tx_ring[i]);
 }
@@ -3854,7 +3908,8 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
 {
 	int i;
 
-	for (i = 0; i < adapter->num_rx_queues; i++)
+	i = adapter->qav_mode ? IGB_USER_RX_QUEUES : 0;
+	for (; i < adapter->num_rx_queues; i++)
 		if (adapter->rx_ring[i])
 			igb_free_rx_resources(adapter->rx_ring[i]);
 }
@@ -3910,7 +3965,8 @@ static void igb_clean_all_rx_rings(struct igb_adapter *adapter)
 {
 	int i;
 
-	for (i = 0; i < adapter->num_rx_queues; i++)
+	i = adapter->qav_mode ? IGB_USER_TX_QUEUES : 0;
+	for (; i < adapter->num_rx_queues; i++)
 		if (adapter->rx_ring[i])
 			igb_clean_rx_ring(adapter->rx_ring[i]);
 }
@@ -7055,6 +7111,11 @@ static int igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 	struct sk_buff *skb = rx_ring->skb;
 	unsigned int total_bytes = 0, total_packets = 0;
 	u16 cleaned_count = igb_desc_unused(rx_ring);
+	struct igb_adapter *adapter = netdev_priv(rx_ring->netdev);
+
+	/* Don't service user (AVB) queues */
+	if (adapter->qav_mode && rx_ring->queue_index < IGB_USER_RX_QUEUES)
+		return true;
 
 	while (likely(total_packets < budget)) {
 		union e1000_adv_rx_desc *rx_desc;
@@ -7254,6 +7315,9 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return 0;
 }
 
+#define SIOSTXQUEUESELECT SIOCDEVPRIVATE
+#define SIOSRXQUEUESELECT (SIOCDEVPRIVATE + 1)
+
 /**
  * igb_ioctl -
  * @netdev:
@@ -8305,6 +8369,9 @@ static int igb_change_mode(struct igb_adapter *adapter, int request_mode)
 	if (request_mode == current_mode)
 		return 0;
 
+	if (adapter->cdev_in_use)
+		return -EBUSY;
+
 	netdev = adapter->netdev;
 
 	rtnl_lock();
@@ -8314,6 +8381,11 @@ static int igb_change_mode(struct igb_adapter *adapter, int request_mode)
 	else
 		igb_reset(adapter);
 
+	if (current_mode) {
+		igb_tsn_free_all_rx_resources(adapter);
+		igb_tsn_free_all_tx_resources(adapter);
+	}
+
 	igb_clear_interrupt_scheme(adapter);
 
 	adapter->qav_mode = request_mode;
@@ -8327,12 +8399,23 @@ static int igb_change_mode(struct igb_adapter *adapter, int request_mode)
 		goto err_out;
 	}
 
+	if (request_mode) {
+		err = igb_tsn_setup_all_tx_resources(adapter);
+		if (err)
+			goto err_out;
+		err = igb_tsn_setup_all_rx_resources(adapter);
+		if (err)
+			goto err_tsn_setup_rx;
+	}
+
 	if (netif_running(netdev))
 		igb_open(netdev);
 
 	rtnl_unlock();
 
 	return err;
+err_tsn_setup_rx:
+	igb_tsn_free_all_tx_resources(adapter);
 err_out:
 	rtnl_unlock();
 	return err;
-- 
2.5.0
