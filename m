From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 2/2] xen/netback: set default upper limit of tx/rx queues to 8
Date: Tue, 10 Jan 2017 14:32:52 +0100
Message-ID: <20170110133252.5346-3-jgross@suse.com>
References: <20170110133252.5346-1-jgross@suse.com>
Cc: boris.ostrovsky@oracle.com, wei.liu2@citrix.com,
        paul.durrant@citrix.com, Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110133252.5346-1-jgross@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The default for the maximum number of tx/rx queues of one interface is
the number of cpus of the system today. As each queue pair reserves 512
grant pages this default consumes a ridiculous number of grants for
large guests.

Limit the queue number to 8 as default. This value can be modified
via a module parameter if required.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 drivers/net/xen-netback/netback.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 47b4810..f9bcf4a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -67,6 +67,7 @@ module_param(rx_drain_timeout_msecs, uint, 0444);
 unsigned int rx_stall_timeout_msecs = 60000;
 module_param(rx_stall_timeout_msecs, uint, 0444);
 
+#define MAX_QUEUES_DEFAULT 8
 unsigned int xenvif_max_queues;
 module_param_named(max_queues, xenvif_max_queues, uint, 0644);
 MODULE_PARM_DESC(max_queues,
@@ -1622,11 +1623,12 @@ static int __init netback_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	/* Allow as many queues as there are CPUs if user has not
+	/* Allow as many queues as there are CPUs but max. 8 if user has not
 	 * specified a value.
 	 */
 	if (xenvif_max_queues == 0)
-		xenvif_max_queues = num_online_cpus();
+		xenvif_max_queues = min_t(unsigned int, MAX_QUEUES_DEFAULT,
+					  num_online_cpus());
 
 	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
 		pr_info("fatal_skb_slots too small (%d), bump it to XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
-- 
2.10.2
