From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopbackconnections.
Date: Wed, 13 Feb 2008 07:49:16 -0800
Message-ID: <adaodakua9v.fsf@cisco.com>
References: <20080212220929.24442.76874.stgit@dell3.ogc.int>
	<adafxvxvgz3.fsf@cisco.com> <015c01c86e21$75317210$05c8a8c0@DIEGO>
	<adaskzwuaeu.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaskzwuaeu.fsf@cisco.com> (Roland Dreier's message of "Wed,
	13 Feb 2008 07:46:17 -0800")
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

Steve, I had to update the patch adding an include and fixing the
function declaration (as below)... but how much testing have you done
with this??

commit 8704e9a8790cc9e394198663c1c9150c899fb9a2
Author: Steve Wise <swise@opengridcomputing.com>
Date:   Tue Feb 12 16:09:29 2008 -0600

    RDMA/cxgb3: Fail loopback connections
    
    The cxgb3 HW and driver don't support loopback RDMA connections.  So
    fail any connection attempt where the destination address is local.
    
    Signed-off-by: Steve Wise <swise@opengridcomputing.com>
    Signed-off-by: Roland Dreier <rolandd@cisco.com>

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index e9a08fa..320f2b6 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -35,6 +35,7 @@
 #include <linux/skbuff.h>
 #include <linux/timer.h>
 #include <linux/notifier.h>
+#include <linux/inetdevice.h>
 
 #include <net/neighbour.h>
 #include <net/netevent.h>
@@ -1784,6 +1785,17 @@ err:
 	return err;
 }
 
+static int is_loopback_dst(struct iw_cm_id *cm_id)
+{
+	struct net_device *dev;
+
+	dev = ip_dev_find(&init_net, cm_id->remote_addr.sin_addr.s_addr);
+	if (!dev)
+		return 0;
+	dev_put(dev);
+	return 1;
+}
+
 int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 {
 	int err = 0;
@@ -1791,6 +1803,11 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	struct iwch_ep *ep;
 	struct rtable *rt;
 
+	if (is_loopback_dst(cm_id)) {
+		err = -ENOSYS;
+		goto out;
+	}
+
 	ep = alloc_ep(sizeof(*ep), GFP_KERNEL);
 	if (!ep) {
 		printk(KERN_ERR MOD "%s - cannot alloc ep.\n", __FUNCTION__);
