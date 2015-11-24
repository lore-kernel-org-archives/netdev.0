From: Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH V2 1/3] VFIO: Add new ioctl cmd VFIO_GET_PCI_CAP_INFO
Date: Tue, 24 Nov 2015 21:38:16 +0800
Message-ID: <1448372298-28386-2-git-send-email-tianyu.lan@intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
To: a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, agraf-l3A5Bk7waGM@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org,
	emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, weiyang-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448372298-28386-1-git-send-email-tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is to add new ioctl cmd VFIO_GET_PCI_CAP_INFO to get
PCI cap table size and get free PCI config space regs according
pos and size.

Qemu will add faked PCI capability for migration and need such
info.

Signed-off-by: Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/vfio/pci/vfio_pci.c         | 21 ++++++++++++++++++++
 drivers/vfio/pci/vfio_pci_config.c  | 38 +++++++++++++++++++++++++++++++------
 drivers/vfio/pci/vfio_pci_private.h |  5 +++++
 include/uapi/linux/vfio.h           | 12 ++++++++++++
 4 files changed, 70 insertions(+), 6 deletions(-)

diff --git a/drivers/vfio/pci/vfio_pci.c b/drivers/vfio/pci/vfio_pci.c
index 69fab0f..2e42de0 100644
--- a/drivers/vfio/pci/vfio_pci.c
+++ b/drivers/vfio/pci/vfio_pci.c
@@ -784,6 +784,27 @@ hot_reset_release:
 
 		kfree(groups);
 		return ret;
+	} else if (cmd == VFIO_GET_PCI_CAP_INFO) {
+		struct vfio_pci_cap_info info;
+		int offset;
+
+		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
+			return -EFAULT;
+
+		switch (info.index) {
+		case VFIO_PCI_CAP_GET_SIZE:
+			info.size = vfio_get_cap_size(vdev, info.cap, info.offset);
+			break;
+		case VFIO_PCI_CAP_GET_FREE_REGION:
+			offset = vfio_find_free_pci_config_reg(vdev,
+					info.offset, info.size);
+			info.offset = offset;
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		return copy_to_user((void __user *)arg, &info, sizeof(info));
 	}
 
 	return -ENOTTY;
diff --git a/drivers/vfio/pci/vfio_pci_config.c b/drivers/vfio/pci/vfio_pci_config.c
index ff75ca3..8afbda4 100644
--- a/drivers/vfio/pci/vfio_pci_config.c
+++ b/drivers/vfio/pci/vfio_pci_config.c
@@ -841,6 +841,21 @@ static int vfio_find_cap_start(struct vfio_pci_device *vdev, int pos)
 	return pos;
 }
 
+int vfio_find_free_pci_config_reg(struct vfio_pci_device *vdev,
+	int pos, int size)
+{
+	int i, offset = pos;
+
+	for (i = pos; i < PCI_CFG_SPACE_SIZE; i++) {
+		if (vdev->pci_config_map[i] != PCI_CAP_ID_INVALID)
+			offset = i + 1;
+		else if (i - offset + 1 == size)
+			return offset;
+	}
+
+	return 0;
+}
+
 static int vfio_msi_config_read(struct vfio_pci_device *vdev, int pos,
 				int count, struct perm_bits *perm,
 				int offset, __le32 *val)
@@ -1199,6 +1214,20 @@ static int vfio_fill_vconfig_bytes(struct vfio_pci_device *vdev,
 	return ret;
 }
 
+int vfio_get_cap_size(struct vfio_pci_device *vdev, u8 cap, int pos)
+{
+	int len;
+
+	len = pci_cap_length[cap];
+	if (len == 0xFF) { /* Variable length */
+		len = vfio_cap_len(vdev, cap, pos);
+		if (len < 0)
+			return len;
+	}
+
+	return len;
+}
+
 static int vfio_cap_init(struct vfio_pci_device *vdev)
 {
 	struct pci_dev *pdev = vdev->pdev;
@@ -1238,12 +1267,9 @@ static int vfio_cap_init(struct vfio_pci_device *vdev)
 			return ret;
 
 		if (cap <= PCI_CAP_ID_MAX) {
-			len = pci_cap_length[cap];
-			if (len == 0xFF) { /* Variable length */
-				len = vfio_cap_len(vdev, cap, pos);
-				if (len < 0)
-					return len;
-			}
+			len = vfio_get_cap_size(vdev, cap, pos);
+			if (len < 0)
+				return len;
 		}
 
 		if (!len) {
diff --git a/drivers/vfio/pci/vfio_pci_private.h b/drivers/vfio/pci/vfio_pci_private.h
index ae0e1b4..91b4f9b 100644
--- a/drivers/vfio/pci/vfio_pci_private.h
+++ b/drivers/vfio/pci/vfio_pci_private.h
@@ -89,4 +89,9 @@ extern void vfio_pci_uninit_perm_bits(void);
 
 extern int vfio_config_init(struct vfio_pci_device *vdev);
 extern void vfio_config_free(struct vfio_pci_device *vdev);
+extern int vfio_find_free_pci_config_reg(struct vfio_pci_device *vdev,
+		int pos, int size);
+extern int vfio_get_cap_size(struct vfio_pci_device *vdev,
+		u8 cap, int pos);
+
 #endif /* VFIO_PCI_PRIVATE_H */
diff --git a/include/uapi/linux/vfio.h b/include/uapi/linux/vfio.h
index b57b750..dfa7023 100644
--- a/include/uapi/linux/vfio.h
+++ b/include/uapi/linux/vfio.h
@@ -495,6 +495,18 @@ struct vfio_eeh_pe_op {
 
 #define VFIO_EEH_PE_OP			_IO(VFIO_TYPE, VFIO_BASE + 21)
 
+#define VFIO_GET_PCI_CAP_INFO	_IO(VFIO_TYPE, VFIO_BASE + 22)
+struct vfio_pci_cap_info {
+	__u32	argsz;
+	__u32	flags;
+#define VFIO_PCI_CAP_GET_SIZE		(1 << 0)
+#define VFIO_PCI_CAP_GET_FREE_REGION	(1 << 1)
+	__u32	index;
+	__u32	offset;
+	__u32	size;
+	__u8	cap;
+};
+
 /* ***************************************************************** */
 
 #endif /* _UAPIVFIO_H */
-- 
1.8.4.rc0.1.g8f6a3e5.dirty
