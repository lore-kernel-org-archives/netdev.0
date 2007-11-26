From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.25 1/2] RDMA/cxgb3: Hold rtnl_lock() around
	ethtool get_drvinfo call.
Date: Mon, 26 Nov 2007 11:28:44 -0600
Message-ID: <20071126172844.22792.46023.stgit@dell3.ogc.int>
References: <20071126172457.22792.62583.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071126172457.22792.62583.stgit@dell3.ogc.int>
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


RDMA/cxgb3: Hold rtnl_lock() around ethtool get_drvinfo call.

Currently the call into cxgb3 to get the driver info is not serialized.
The iw_cxgb3 module needs to hold the rtnl_lock around the ethtool ops
call like dev_ioctl() does.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_provider.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infini=
band/hw/cxgb3/iwch_provider.c
index b5436ca..69b1204 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -39,6 +39,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
+#include <linux/rtnetlink.h>
=20
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -1053,7 +1054,9 @@ static ssize_t show_fw_ver(struct class_device *cde=
v, char *buf)
 	struct net_device *lldev =3D dev->rdev.t3cdev_p->lldev;
=20
 	PDBG("%s class dev 0x%p\n", __FUNCTION__, cdev);
+	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
+	rtnl_unlock();
 	return sprintf(buf, "%s\n", info.fw_version);
 }
=20
@@ -1065,7 +1068,9 @@ static ssize_t show_hca(struct class_device *cdev, =
char *buf)
 	struct net_device *lldev =3D dev->rdev.t3cdev_p->lldev;
=20
 	PDBG("%s class dev 0x%p\n", __FUNCTION__, cdev);
+	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
+	rtnl_unlock();
 	return sprintf(buf, "%s\n", info.driver);
 }
=20
