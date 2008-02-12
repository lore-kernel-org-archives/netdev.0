From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopback connections.
Date: Tue, 12 Feb 2008 16:09:29 -0600
Message-ID: <20080212220929.24442.76874.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
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


RDMA/cxgb3: Fail loopback connections.

The cxgb3 HW and driver don't support loopback RDMA connections.  So fail
any connection attempt where the destination address is local.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index e9a08fa..5d82723 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1784,6 +1784,17 @@ err:
 	return err;
 }
=20
+static void is_loopback_dst(struct iw_cm_id *cm_id)
+{
+	struct net_device *dev;
+=09
+	dev =3D ip_dev_find(&init_net, cm_id->remote_addr.sin_addr.s_addr);
+	if (!dev)
+		return 0;
+	dev_put(dev);
+	return 1;
+}
+
 int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_p=
aram)
 {
 	int err =3D 0;
@@ -1791,6 +1802,11 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw=
_cm_conn_param *conn_param)
 	struct iwch_ep *ep;
 	struct rtable *rt;
=20
+	if (is_loopback_dst(cm_id)) {
+		err =3D -ENOSYS;
+		goto out;
+	}
+
 	ep =3D alloc_ep(sizeof(*ep), GFP_KERNEL);
 	if (!ep) {
 		printk(KERN_ERR MOD "%s - cannot alloc ep.\n", __FUNCTION__);
