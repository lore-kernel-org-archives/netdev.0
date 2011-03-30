From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/4] enic: Add wrapper routines for new fw
	devcmds for port profile handling
Date: Tue, 29 Mar 2011 23:35:56 -0700
Message-ID: <20110330063556.7187.91578.stgit@savbu-pc100.cisco.com>
References: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:20341 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298Ab1C3Gf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 02:35:57 -0400
In-Reply-To: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds wrapper routines to new port profile related fw devcmds and
removes the old ones

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic_dev.c |   62 ++++++++++++++++++++++++++++++++++++++++---
 drivers/net/enic/enic_dev.h |    7 +++--
 2 files changed, 63 insertions(+), 6 deletions(-)


diff --git a/drivers/net/enic/enic_dev.c b/drivers/net/enic/enic_dev.c
index 37ad3a1..90687b1 100644
--- a/drivers/net/enic/enic_dev.c
+++ b/drivers/net/enic/enic_dev.c
@@ -177,24 +177,24 @@ int enic_vnic_dev_deinit(struct enic *enic)
 	return err;
 }
 
-int enic_dev_init_prov(struct enic *enic, struct vic_provinfo *vp)
+int enic_dev_init_prov2(struct enic *enic, struct vic_provinfo *vp)
 {
 	int err;
 
 	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_init_prov(enic->vdev,
+	err = vnic_dev_init_prov2(enic->vdev,
 		(u8 *)vp, vic_provinfo_size(vp));
 	spin_unlock(&enic->devcmd_lock);
 
 	return err;
 }
 
-int enic_dev_init_done(struct enic *enic, int *done, int *error)
+int enic_dev_deinit_done(struct enic *enic, int *status)
 {
 	int err;
 
 	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_init_done(enic->vdev, done, error);
+	err = vnic_dev_deinit_done(enic->vdev, status);
 	spin_unlock(&enic->devcmd_lock);
 
 	return err;
@@ -219,3 +219,57 @@ void enic_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	enic_del_vlan(enic, vid);
 	spin_unlock(&enic->devcmd_lock);
 }
+
+int enic_dev_enable2(struct enic *enic, int active)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_enable2(enic->vdev, active);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_enable2_done(struct enic *enic, int *status)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_enable2_done(enic->vdev, status);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_status_to_errno(int devcmd_status)
+{
+	switch (devcmd_status) {
+	case ERR_SUCCESS:
+		return 0;
+	case ERR_EINVAL:
+		return -EINVAL;
+	case ERR_EFAULT:
+		return -EFAULT;
+	case ERR_EPERM:
+		return -EPERM;
+	case ERR_EBUSY:
+		return -EBUSY;
+	case ERR_ECMDUNKNOWN:
+	case ERR_ENOTSUPPORTED:
+		return -EOPNOTSUPP;
+	case ERR_EBADSTATE:
+		return -EINVAL;
+	case ERR_ENOMEM:
+		return -ENOMEM;
+	case ERR_ETIMEDOUT:
+		return -ETIMEDOUT;
+	case ERR_ELINKDOWN:
+		return -ENETDOWN;
+	case ERR_EINPROGRESS:
+		return -EINPROGRESS;
+	case ERR_EMAXRES:
+	default:
+		return (devcmd_status < 0) ? devcmd_status : -1;
+	}
+}
diff --git a/drivers/net/enic/enic_dev.h b/drivers/net/enic/enic_dev.h
index 495f57f..d5f6813 100644
--- a/drivers/net/enic/enic_dev.h
+++ b/drivers/net/enic/enic_dev.h
@@ -35,7 +35,10 @@ int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic);
 int enic_dev_enable(struct enic *enic);
 int enic_dev_disable(struct enic *enic);
 int enic_vnic_dev_deinit(struct enic *enic);
-int enic_dev_init_prov(struct enic *enic, struct vic_provinfo *vp);
-int enic_dev_init_done(struct enic *enic, int *done, int *error);
+int enic_dev_init_prov2(struct enic *enic, struct vic_provinfo *vp);
+int enic_dev_deinit_done(struct enic *enic, int *status);
+int enic_dev_enable2(struct enic *enic, int arg);
+int enic_dev_enable2_done(struct enic *enic, int *status);
+int enic_dev_status_to_errno(int devcmd_status);
 
 #endif /* _ENIC_DEV_H_ */

