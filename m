From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH V2 2/2] xen-netfront: limit vnic max_queues number to online
 cpus
Date: Fri, 23 Oct 2015 17:19:02 +0800
Message-ID: <5629FB86.7010107@oracle.com>
References: <5629FB31.5060806@oracle.com>
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
Received: from userp1040.oracle.com ([156.151.31.81]:42737 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbbJWJTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:19:18 -0400
In-Reply-To: <5629FB31.5060806@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should not allocate vnic queues number more than online cpus.

Signed-off-by: Joe Jin <joe.jin@oracle.com>
Cc: Jan Beulich <JBeulich@suse.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netfront.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..5cc2f4a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -58,7 +58,9 @@
 
 /* Module parameters */
 static unsigned int xennet_max_queues;
-module_param_named(max_queues, xennet_max_queues, uint, 0644);
+static int xennet_set_max_queues(const char *val, struct kernel_param *kp);
+module_param_call(max_queues, xennet_set_max_queues, param_get_uint,
+		  &xennet_max_queues, 0644);
 MODULE_PARM_DESC(max_queues,
 		 "Maximum number of queues per virtual interface");
 
@@ -164,6 +166,19 @@ struct netfront_rx_info {
 	struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
 };
 
+static int xennet_set_max_queues(const char *val, struct kernel_param *kp)
+{
+	unsigned int cpus = num_online_cpus();
+	unsigned int max_queues = simple_strtoul(val, NULL, 10);
+
+	if (max_queues == 0 || max_queues > cpus) {
+		pr_err("max_queues %u is out of range [0 - %u]!\n", 
+		       max_queues, cpus);
+		return -ERANGE;
+	}
+	return param_set_uint(val, kp);
+}
+
 static void skb_entry_set_link(union skb_entry *list, unsigned short id)
 {
 	list->link = id;
@@ -2126,6 +2141,8 @@ static struct xenbus_driver netfront_driver = {
 
 static int __init netif_init(void)
 {
+	unsigned int cpus = num_online_cpus();
+
 	if (!xen_domain())
 		return -ENODEV;
 
@@ -2134,11 +2151,10 @@ static int __init netif_init(void)
 
 	pr_info("Initialising Xen virtual ethernet driver\n");
 
-	/* Allow as many queues as there are CPUs if user has not
-	 * specified a value.
-	 */
-	if (xennet_max_queues == 0)
-		xennet_max_queues = num_online_cpus();
+	/* Allow at most as many queues as there are CPUs. */
+	if (xennet_max_queues == 0 || xennet_max_queues > cpus)
+		xennet_max_queues = cpus;
+	pr_info("max_queues: %d\n", xennet_max_queues);
 
 	return xenbus_register_frontend(&netfront_driver);
 }
-- 
1.7.1
