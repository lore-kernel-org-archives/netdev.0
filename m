From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ibmtr - get rid of MOD_INC/DEC
Date: Wed, 13 Aug 2003 17:46:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813174658.2c5125af.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike Phillips <mikep@linuxtr.net>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With the new module system MOD_INC/MOD_DEC are no longer necessary.
Also changed to new module init/exit macros for function setup.

The module exit code can sleep, so calling schedule_timeout is better
than spinning.

Don't have real hardware, so I tested it by short circuiting the probe().

diff -Nru a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c	Wed Aug 13 17:44:49 2003
+++ b/drivers/net/tokenring/ibmtr.c	Wed Aug 13 17:44:49 2003
@@ -876,7 +876,6 @@
 		if (i==0) break;
 		if (ti->open_status == OPEN && ti->sap_status==OPEN) {
 			netif_start_queue(dev);
-			MOD_INC_USE_COUNT;
 			DPRINTK("Adapter is up and running\n");
 			return 0;
 		}
@@ -1041,7 +1040,6 @@
 
 	netif_stop_queue(dev);
 	DPRINTK("Adapter is closed.\n");
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -1918,7 +1916,7 @@
 MODULE_PARM(irq, "1-" __MODULE_STRING(IBMTR_MAX_ADAPTERS) "i");
 MODULE_PARM(mem, "1-" __MODULE_STRING(IBMTR_MAX_ADAPTERS) "i");
 
-int init_module(void)
+static int __init ibmtr_init(void)
 {
 	int i;
 	int count=0;
@@ -1948,21 +1946,24 @@
 	if (count) return 0;
 	printk("ibmtr: register_netdev() returned non-zero.\n");
 	return -EIO;
-}				/*init_module */
+}
+module_init(ibmtr_init);
 
-void cleanup_module(void)
+static void __exit ibmtr_cleanup(void)
 {
-	int i,j;
+	int i;
 
 	for (i = 0; i < IBMTR_MAX_ADAPTERS; i++){
 		if (!dev_ibmtr[i])
 			continue;
 		if (dev_ibmtr[i]->base_addr) {
 			outb(0,dev_ibmtr[i]->base_addr+ADAPTRESET);
-			for(j=jiffies+TR_RST_TIME;
-				time_before_eq(jiffies,j);) ;
+			
+			schedule_timeout(TR_RST_TIME); /* wait 50ms */
+
                         outb(0,dev_ibmtr[i]->base_addr+ADAPTRESETREL);
                 }
+
 		unregister_netdev(dev_ibmtr[i]);
 		free_irq(dev_ibmtr[i]->irq, dev_ibmtr[i]);
 		release_region(dev_ibmtr[i]->base_addr, IBMTR_IO_EXTENT);
@@ -1978,4 +1979,5 @@
 		dev_ibmtr[i] = NULL;
 	}
 }
-#endif				/* MODULE */
+module_exit(ibmtr_cleanup);
+#endif
