From: kxie@chelsio.com
Subject: [PATCH 1/1] cxgb3i: Fix a login over vlan issue
Date: Wed, 09 Dec 2009 21:35:22 -0800
Message-ID: <200912100535.nBA5ZM0L000413@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rakesh@chelsio.com, kxie@chelsio.com,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
	netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 1/1] cxgb3i: Fix a login over vlan issue

From: Karen Xie <kxie@chelsio.com>

Fix a login over vlan issue, when parent interface is vlan and we are using

cxgb3i sepecific private ip address in '/etc/iscsi/ifaces/' iface file.

Acked-by: Karen Xie <kxie@chelsio.com>
Signed-off-by: Rakesh Ranjan <rakesh@chelsio.com>
---

 drivers/scsi/cxgb3i/cxgb3i_offload.c |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)


diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.c b/drivers/scsi/cxgb3i/cxgb3i_offload.c
index 26ffdcd..1aef364 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_offload.c
+++ b/drivers/scsi/cxgb3i/cxgb3i_offload.c
@@ -1440,6 +1440,10 @@ void cxgb3i_c3cn_release(struct s3_conn *c3cn)
 static int is_cxgb3_dev(struct net_device *dev)
 {
 	struct cxgb3i_sdev_data *cdata;
+	struct net_device *ndev = dev;
+
+	if (dev->priv_flags & IFF_802_1Q_VLAN)
+		ndev = vlan_dev_real_dev(dev);
 
 	write_lock(&cdata_rwlock);
 	list_for_each_entry(cdata, &cdata_list, list) {
@@ -1447,7 +1451,7 @@ static int is_cxgb3_dev(struct net_device *dev)
 		int i;
 
 		for (i = 0; i < ports->nports; i++)
-			if (dev == ports->lldevs[i]) {
+			if (ndev == ports->lldevs[i]) {
 				write_unlock(&cdata_rwlock);
 				return 1;
 			}
@@ -1566,6 +1570,25 @@ out_err:
 	return -EINVAL;
 }
 
+/**
+ * cxgb3i_find_dev - find the interface associated with the given address
+ * @ipaddr: ip address
+ */
+static struct net_device *cxgb3i_find_dev(__be32 ipaddr)
+{
+	struct flowi fl;
+	int err;
+	struct rtable *rt;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.nl_u.ip4_u.daddr = ipaddr;
+
+	err = ip_route_output_key(&init_net, &rt, &fl);
+	if (!err)
+		return (&rt->u.dst)->dev;
+
+	return NULL;
+}
 
 /**
  * cxgb3i_c3cn_connect - initiates an iscsi tcp connection to a given address
@@ -1581,6 +1604,7 @@ int cxgb3i_c3cn_connect(struct net_device *dev, struct s3_conn *c3cn,
 	struct cxgb3i_sdev_data *cdata;
 	struct t3cdev *cdev;
 	__be32 sipv4;
+	struct net_device *dstdev;
 	int err;
 
 	c3cn_conn_debug("c3cn 0x%p, dev 0x%p.\n", c3cn, dev);
@@ -1591,6 +1615,13 @@ int cxgb3i_c3cn_connect(struct net_device *dev, struct s3_conn *c3cn,
 	c3cn->daddr.sin_port = usin->sin_port;
 	c3cn->daddr.sin_addr.s_addr = usin->sin_addr.s_addr;
 
+	dstdev = cxgb3i_find_dev(usin->sin_addr.s_addr);
+	if (!dstdev || !is_cxgb3_dev(dstdev))
+		return -ENETUNREACH;
+
+	if (dstdev->priv_flags & IFF_802_1Q_VLAN)
+		dev = dstdev;
+
 	rt = find_route(dev, c3cn->saddr.sin_addr.s_addr,
 			c3cn->daddr.sin_addr.s_addr,
 			c3cn->saddr.sin_port,
