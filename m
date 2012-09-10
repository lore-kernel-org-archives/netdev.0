From: Robert Love <robert.w.love@intel.com>
Subject: [RFC PATCH 1/5] libfcoe, fcoe: Allow user to set a ctlr's mode
Date: Mon, 10 Sep 2012 15:59:14 -0700
Message-ID: <20120910225914.13140.22190.stgit@fritz>
References: <20120910225908.13140.97277.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: devel@open-fcoe.org
To: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, bprakash@broadcom.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120910225908.13140.97277.stgit@fritz>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the 'mode' attribute of a
fcoe_ctlr_device writale. This allows the user
to store the mode with with the ctlr will be in.

Possible modes would be 'Fabric', or 'VN2VN'.

The default mode for a fcoe_ctlr{,_device} is 'Fabric'.
Drivers must implement the set_fcoe_ctlr_mode routine
to support this feature.

libfcoe offers an exported routine to set a fcoe_ctlr's
mode.

Signed-off-by: Robert Love <robert.w.love@intel.com>
---
 Documentation/ABI/testing/sysfs-bus-fcoe |    8 ++++
 drivers/scsi/fcoe/fcoe_ctlr.c            |   22 +++++++++++
 drivers/scsi/fcoe/fcoe_sysfs.c           |   61 +++++++++++++++++++++++++++++-
 include/scsi/fcoe_sysfs.h                |    1 
 include/scsi/libfcoe.h                   |    1 
 5 files changed, 91 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-bus-fcoe b/Documentation/ABI/testing/sysfs-bus-fcoe
index 469d09c..1b06ec1 100644
--- a/Documentation/ABI/testing/sysfs-bus-fcoe
+++ b/Documentation/ABI/testing/sysfs-bus-fcoe
@@ -9,6 +9,14 @@ Attributes:
 			  this value will change the dev_loss_tmo for all
 			  FCFs discovered by this controller.
 
+	mode:		  Display or change the FCoE Controller's mode. Possible
+			  modes are 'Fabric' and 'VN2VN'. If a FCoE Controller
+			  is started in 'Fabric' mode then FIP FCF discovery is
+			  initiated and ultimately a fabric login is attempted.
+			  If a FCoE Controller is started in 'VN2VN' mode then
+			  FIP VN2VN discovery and login is performed. A FCoE
+			  Controller only supports one mode at a time.
+
 	lesb_link_fail:   Link Error Status Block (LESB) link failure count.
 
 	lesb_vlink_fail:  Link Error Status Block (LESB) virtual link
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index d68d572..bd899bf 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -2884,3 +2884,25 @@ void fcoe_ctlr_get_fip_mode(struct fcoe_ctlr_device *ctlr_dev)
 	mutex_unlock(&ctlr->ctlr_mutex);
 }
 EXPORT_SYMBOL(fcoe_ctlr_get_fip_mode);
+
+void fcoe_ctlr_set_fip_mode(struct fcoe_ctlr_device *ctlr_dev)
+{
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(ctlr_dev);
+
+	mutex_lock(&ctlr->ctlr_mutex);
+	switch (ctlr_dev->mode) {
+	case FIP_CONN_TYPE_VN2VN:
+		ctlr->mode = FIP_MODE_VN2VN;
+		break;
+	case FIP_CONN_TYPE_FABRIC:
+	default:
+		ctlr->mode = FIP_MODE_FABRIC;
+		break;
+	}
+
+	/* TODO: Probably need to restart the state machine */
+
+	mutex_unlock(&ctlr->ctlr_mutex);
+
+}
+EXPORT_SYMBOL(fcoe_ctlr_set_fip_mode);
diff --git a/drivers/scsi/fcoe/fcoe_sysfs.c b/drivers/scsi/fcoe/fcoe_sysfs.c
index 2bc1631..3fbc556 100644
--- a/drivers/scsi/fcoe/fcoe_sysfs.c
+++ b/drivers/scsi/fcoe/fcoe_sysfs.c
@@ -21,6 +21,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/etherdevice.h>
+#include <linux/ctype.h>
 
 #include <scsi/fcoe_sysfs.h>
 
@@ -40,6 +41,46 @@ MODULE_PARM_DESC(fcf_dev_loss_tmo,
 		 " insulate the loss of a fcf. Once this value is"
 		 " exceeded, the fcf is removed.");
 
+#define FCOE_MAX_MODENAME_LEN 20
+struct fcoe_ctlr_mode_table {
+	char *modename;
+	enum fip_conn_type mode;
+};
+
+const struct fcoe_ctlr_mode_table ctlr_mode_tbl[] = {
+	{       "fabric",           FIP_CONN_TYPE_FABRIC},
+	{       "vn2vn",            FIP_CONN_TYPE_VN2VN},
+	{       NULL,               -1},
+};
+
+static enum fip_conn_type fcoe_parse_mode(const char *buf,
+				  const struct fcoe_ctlr_mode_table *tbl)
+{
+	int modeint = -1, i, rv;
+	char *p, modestr[FCOE_MAX_MODENAME_LEN + 1] = { 0, };
+
+	for (p = (char *)buf; *p; p++)
+		if (!(isdigit(*p) || isspace(*p)))
+			break;
+
+	if (*p)
+		rv = sscanf(buf, "%20s", modestr);
+	else
+		rv = sscanf(buf, "%d", &modeint);
+
+	if (!rv)
+		return FIP_CONN_TYPE_UNKNOWN;
+
+	for (i = 0; tbl[i].modename; i++) {
+		if (modeint == tbl[i].mode)
+			return tbl[i].mode;
+		if (strcmp(modestr, tbl[i].modename) == 0)
+			return tbl[i].mode;
+	}
+
+	return FIP_CONN_TYPE_UNKNOWN;
+}
+
 /*
  * These are used by the fcoe_*_show_function routines, they
  * are intentionally placed in the .c file as they're not intended
@@ -273,8 +314,24 @@ static ssize_t show_ctlr_mode(struct device *dev,
 	return snprintf(buf, FCOE_CTLR_MODE_MAX_NAMELEN,
 			"%s\n", name);
 }
-static FCOE_DEVICE_ATTR(ctlr, mode, S_IRUGO,
-			show_ctlr_mode, NULL);
+
+static ssize_t store_ctlr_mode(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct fcoe_ctlr_device *ctlr = dev_to_ctlr(dev);
+
+	if (!ctlr->f->set_fcoe_ctlr_mode)
+		return -EINVAL;
+
+	ctlr->mode = fcoe_parse_mode(buf, ctlr_mode_tbl);
+	ctlr->f->set_fcoe_ctlr_mode(ctlr);
+
+	return count;
+}
+
+static FCOE_DEVICE_ATTR(ctlr, mode, S_IRUGO | S_IWUSR,
+			show_ctlr_mode, store_ctlr_mode);
 
 static ssize_t
 store_private_fcoe_ctlr_fcf_dev_loss_tmo(struct device *dev,
diff --git a/include/scsi/fcoe_sysfs.h b/include/scsi/fcoe_sysfs.h
index 604cb9b..421ae67 100644
--- a/include/scsi/fcoe_sysfs.h
+++ b/include/scsi/fcoe_sysfs.h
@@ -35,6 +35,7 @@ struct fcoe_sysfs_function_template {
 	void (*get_fcoe_ctlr_err_block)(struct fcoe_ctlr_device *);
 	void (*get_fcoe_ctlr_fcs_error)(struct fcoe_ctlr_device *);
 	void (*get_fcoe_ctlr_mode)(struct fcoe_ctlr_device *);
+	void (*set_fcoe_ctlr_mode)(struct fcoe_ctlr_device *);
 	void (*get_fcoe_fcf_selected)(struct fcoe_fcf_device *);
 	void (*get_fcoe_fcf_vlan_id)(struct fcoe_fcf_device *);
 };
diff --git a/include/scsi/libfcoe.h b/include/scsi/libfcoe.h
index 22b07cc..20533cc 100644
--- a/include/scsi/libfcoe.h
+++ b/include/scsi/libfcoe.h
@@ -359,6 +359,7 @@ int fcoe_get_paged_crc_eof(struct sk_buff *skb, int tlen,
 /* FCoE Sysfs helpers */
 void fcoe_fcf_get_selected(struct fcoe_fcf_device *);
 void fcoe_ctlr_get_fip_mode(struct fcoe_ctlr_device *);
+void fcoe_ctlr_set_fip_mode(struct fcoe_ctlr_device *);
 
 /**
  * struct netdev_list

