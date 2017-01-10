From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 1/2] xen/netfront: set default upper limit of tx/rx queues to 8
Date: Tue, 10 Jan 2017 14:32:51 +0100
Message-ID: <20170110133252.5346-2-jgross@suse.com>
References: <20170110133252.5346-1-jgross@suse.com>
Cc: boris.ostrovsky@oracle.com, wei.liu2@citrix.com,
        paul.durrant@citrix.com, Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110133252.5346-1-jgross@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The default for the number of tx/rx queues of one interface is the
number of vcpus of the system today. As each queue pair reserves 512
grant pages this default consumes a ridiculous number of grants for
large guests.

Limit the queue number to 8 as default. This value can be modified
via a module parameter if required.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 drivers/net/xen-netfront.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a479cd9..490c865 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -57,6 +57,7 @@
 #include <xen/interface/grant_table.h>
 
 /* Module parameters */
+#define MAX_QUEUES_DEFAULT 8
 static unsigned int xennet_max_queues;
 module_param_named(max_queues, xennet_max_queues, uint, 0644);
 MODULE_PARM_DESC(max_queues,
@@ -2164,11 +2165,12 @@ static int __init netif_init(void)
 
 	pr_info("Initialising Xen virtual ethernet driver\n");
 
-	/* Allow as many queues as there are CPUs if user has not
+	/* Allow as many queues as there are CPUs inut max. 8 if user has not
 	 * specified a value.
 	 */
 	if (xennet_max_queues == 0)
-		xennet_max_queues = num_online_cpus();
+		xennet_max_queues = min_t(unsigned int, MAX_QUEUES_DEFAULT,
+					  num_online_cpus());
 
 	return xenbus_register_frontend(&netfront_driver);
 }
-- 
2.10.2
