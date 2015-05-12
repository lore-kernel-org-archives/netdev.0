From: Joao Martins <joao.martins@neclab.eu>
Subject: [RFC PATCH 11/13] xen-netfront: feature-persistent
	xenbus support
Date: Tue, 12 May 2015 19:18:35 +0200
Message-ID: <1431451117-70051-12-git-send-email-joao.martins@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	Joao Martins <joao.martins@neclab.eu>, david.vrabel@citrix.com,
	boris.ostrovsky@oracle.com
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

"feature-persistent" check on xenbus for persistent grants
support on the backend.

Signed-off-by: Joao Martins <joao.martins@neclab.eu>
---
 drivers/net/xen-netfront.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 99c17c9..7f44cc7 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -162,6 +162,8 @@ struct netfront_info {
 	struct netfront_stats __percpu *tx_stats;
 
 	atomic_t rx_gso_checksum_fixup;
+
+	unsigned int feature_persistent:1;
 };
 
 struct netfront_rx_info {
@@ -1919,6 +1921,12 @@ again:
 		goto abort_transaction;
 	}
 
+	err = xenbus_write(xbt, dev->nodename, "feature-persistent", "1");
+	if (err) {
+		message = "writing feature-persistent";
+		goto abort_transaction;
+	}
+
 	err = xenbus_transaction_end(xbt, 0);
 	if (err) {
 		if (err == -EAGAIN)
@@ -1950,6 +1958,7 @@ static int xennet_connect(struct net_device *dev)
 	unsigned int num_queues = 0;
 	int err;
 	unsigned int feature_rx_copy;
+	unsigned int feature_persistent;
 	unsigned int j = 0;
 	struct netfront_queue *queue = NULL;
 
@@ -1964,6 +1973,13 @@ static int xennet_connect(struct net_device *dev)
 		return -ENODEV;
 	}
 
+	err = xenbus_gather(XBT_NIL, np->xbdev->otherend,
+			    "feature-persistent", "%u", &feature_persistent,
+			    NULL);
+	if (err)
+		feature_persistent = 0;
+	np->feature_persistent = !!feature_persistent;
+
 	err = talk_to_netback(np->xbdev, np);
 	if (err)
 		return err;
-- 
2.1.3
