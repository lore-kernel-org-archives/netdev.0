From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.28] RDMA/cxgb3: deadlock in iw_cxgb3 can
	cause hang when configuring interface.
Date: Thu, 06 Nov 2008 17:06:42 -0600
Message-ID: <20081106230642.28808.66765.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	wenxiong@us.ibm.com
To: rdreier@cisco.com,jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>

When the iw_cxgb3 module's cxgb3_client "add" func gets called by the
cxgb3 module, the iwarp driver ends up calling the ethtool ops get_drvinf=
o
function in cxgb3 to get the fw version and other info.  Currently the
iwarp driver grabs the rtnl lock around this down call to serialize.
As of 2.6.27 or so, things changed such that the rtnl lock is held around
the call to the netdev driver open function.  Also the cxgb3_client "add"
function doesn't get called if the device is down. =20

So, if you load cxgb3, then load iw_cxgb3, then ifconfig up the device,
the iw_cxgb3 add func gets called with the rtnl_lock held.   If you
load cxgb3, ifconfig up the device, then load iw_cxgb3, the add func
gets called without the rtnl_lock held.  The former causes the deadlock,
the latter does not.

In addition, there are iw_cxgb3 sysfs handlers that also can call
down into cxgb3 to gather the fw and hw versions.  These can be called
concurrently on different processors and at any time.  Thus we need to
push this serialization down in the cxgb3 driver get_drvinfo func.

The fix is to remove rtnl lock usage, and use a per-device lock in cxgb3.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_provider.c |    6 ------
 drivers/net/cxgb3/cxgb3_main.c              |    2 ++
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infini=
band/hw/cxgb3/iwch_provider.c
index ecff980..160ef48 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -1102,9 +1102,7 @@ static u64 fw_vers_string_to_u64(struct iwch_dev *i=
wch_dev)
 	char *cp, *next;
 	unsigned fw_maj, fw_min, fw_mic;
=20
-	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
-	rtnl_unlock();
=20
 	next =3D info.fw_version + 1;
 	cp =3D strsep(&next, ".");
@@ -1192,9 +1190,7 @@ static ssize_t show_fw_ver(struct device *dev, stru=
ct device_attribute *attr, ch
 	struct net_device *lldev =3D iwch_dev->rdev.t3cdev_p->lldev;
=20
 	PDBG("%s dev 0x%p\n", __func__, dev);
-	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
-	rtnl_unlock();
 	return sprintf(buf, "%s\n", info.fw_version);
 }
=20
@@ -1207,9 +1203,7 @@ static ssize_t show_hca(struct device *dev, struct =
device_attribute *attr,
 	struct net_device *lldev =3D iwch_dev->rdev.t3cdev_p->lldev;
=20
 	PDBG("%s dev 0x%p\n", __func__, dev);
-	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
-	rtnl_unlock();
 	return sprintf(buf, "%s\n", info.driver);
 }
=20
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_mai=
n.c
index 1ace41a..5e663cc 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1307,8 +1307,10 @@ static void get_drvinfo(struct net_device *dev, st=
ruct ethtool_drvinfo *info)
 	u32 fw_vers =3D 0;
 	u32 tp_vers =3D 0;
=20
+	spin_lock(&adapter->stats_lock);
 	t3_get_fw_version(adapter, &fw_vers);
 	t3_get_tp_version(adapter, &tp_vers);
+	spin_unlock(&adapter->stats_lock);
=20
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
