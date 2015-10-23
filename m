From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH V3 1/2] xen-netback: limit xen vif max queues number to online
 cpus
Date: Fri, 23 Oct 2015 17:44:44 +0800
Message-ID: <562A018C.9060708@oracle.com>
References: <562A0108.3070501@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: wei.liu2@citrix.com, Ian Campbell <ian.campbell@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48448 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbbJWJo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:44:56 -0400
In-Reply-To: <562A0108.3070501@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should not allocate xen vif queues number more than online cpus.

Signed-off-by: Joe Jin <joe.jin@oracle.com>
Cc: Jan Beulich <JBeulich@suse.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netback/netback.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index ec98d43..021dcb0 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -68,7 +68,9 @@ unsigned int rx_stall_timeout_msecs = 60000;
 module_param(rx_stall_timeout_msecs, uint, 0444);
 
 unsigned int xenvif_max_queues;
-module_param_named(max_queues, xenvif_max_queues, uint, 0644);
+static int xennet_set_max_queues(const char *val, struct kernel_param *kp);
+module_param_call(max_queues, xennet_set_max_queues, param_get_uint,
+		  &xenvif_max_queues, 0644);
 MODULE_PARM_DESC(max_queues,
 		 "Maximum number of queues per virtual interface");
 
@@ -107,6 +109,20 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue
 					     u16      size,
 					     u16      flags);
 
+static int xennet_set_max_queues(const char *val, struct kernel_param *kp)
+{
+	unsigned int cpus = num_online_cpus();
+	unsigned int max_queues = simple_strtoul(val, NULL, 10);
+
+	if (max_queues == 0 || max_queues > cpus) {
+		pr_info("max_queues %u is out of range [1 - %u]!\n", 
+			max_queues, cpus);
+		return -ERANGE;
+	}
+
+	return param_set_uint(val, kp);
+}
+
 static inline unsigned long idx_to_pfn(struct xenvif_queue *queue,
 				       u16 idx)
 {
@@ -2110,15 +2126,15 @@ int xenvif_dealloc_kthread(void *data)
 static int __init netback_init(void)
 {
 	int rc = 0;
+	unsigned int cpus = num_online_cpus();
 
 	if (!xen_domain())
 		return -ENODEV;
 
-	/* Allow as many queues as there are CPUs if user has not
-	 * specified a value.
-	 */
-	if (xenvif_max_queues == 0)
-		xenvif_max_queues = num_online_cpus();
+	/* Allow at most as many queues as CPUs. */
+	if (xenvif_max_queues == 0 || xenvif_max_queues > cpus)
+		xenvif_max_queues = cpus;
+	pr_info("vif max_queues: %u\n", xenvif_max_queues);
 
 	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
 		pr_info("fatal_skb_slots too small (%d), bump it to XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
-- 
1.7.1
