From: Joao Martins <joao.martins@neclab.eu>
Subject: [RFC PATCH 02/13] xen-netback: xenbus feature
	persistent support
Date: Tue, 12 May 2015 19:18:26 +0200
Message-ID: <1431451117-70051-3-git-send-email-joao.martins@neclab.eu>
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

Checks for "feature-persistent" that indicates persistent grants
support. Adds max_persistent_grants module param that specifies the max
number of persistent grants, which if set to zero disables persistent
grants.

Signed-off-by: Joao Martins <joao.martins@neclab.eu>
---
 drivers/net/xen-netback/common.h  |  1 +
 drivers/net/xen-netback/netback.c |  5 +++++
 drivers/net/xen-netback/xenbus.c  | 13 +++++++++++++
 3 files changed, 19 insertions(+)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index dd02386..e70ace7 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -378,6 +378,7 @@ extern bool separate_tx_rx_irq;
 extern unsigned int rx_drain_timeout_msecs;
 extern unsigned int rx_stall_timeout_msecs;
 extern unsigned int xenvif_max_queues;
+extern unsigned int xenvif_max_pgrants;
 
 #ifdef CONFIG_DEBUG_FS
 extern struct dentry *xen_netback_dbg_root;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 8df0a73..332e489 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -72,6 +72,11 @@ module_param_named(max_queues, xenvif_max_queues, uint, 0644);
 MODULE_PARM_DESC(max_queues,
 		 "Maximum number of queues per virtual interface");
 
+unsigned int xenvif_max_pgrants = XEN_NETIF_RX_RING_SIZE;
+module_param_named(max_persistent_grants, xenvif_max_pgrants, int, 0644);
+MODULE_PARM_DESC(max_persistent_grants,
+		 "Maximum number of grants to map persistently");
+
 /*
  * This is the maximum slots a skb can have. If a guest sends a skb
  * which exceeds this limit it is considered malicious.
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 3d8dbf5..766f7e5 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -331,6 +331,14 @@ static int netback_probe(struct xenbus_device *dev,
 		goto fail;
 	}
 
+	/* Persistent grants support. This is an optional feature. */
+	err = xenbus_printf(XBT_NIL, dev->nodename,
+			    "feature-persistent", "%d", xenvif_max_pgrants > 0);
+	if (err) {
+		message = "writing feature-persistent";
+		goto abort_transaction;
+	}
+
 	/*
 	 * Split event channels support, this is optional so it is not
 	 * put inside the above loop.
@@ -961,6 +969,11 @@ static int read_xenbus_vif_flags(struct backend_info *be)
 		val = 0;
 	vif->can_sg = !!val;
 
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-persistent",
+			 "%d", &val) < 0)
+		val = 0;
+	vif->persistent_grants = (xenvif_max_pgrants && !!val);
+
 	vif->gso_mask = 0;
 	vif->gso_prefix_mask = 0;
 
-- 
2.1.3
