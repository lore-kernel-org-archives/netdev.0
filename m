From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 2/3] bridge: fix module startup error handling
Date: Wed, 24 May 2006 10:12:18 -0700
Message-ID: <20060524171347.790409000@localhost.localdomain>
References: <20060524171216.706750000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49847 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932419AbWEXRPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 13:15:20 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=bridge-startup-errorhandle.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return address in use, if some other kernel code has the SAP.
Propogate out error codes from netfilter registration and unwind.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br.orig/net/bridge/br.c
+++ br/net/bridge/br.c
@@ -30,36 +30,44 @@ static struct llc_sap *br_stp_sap;
 
 static int __init br_init(void)
 {
+	int err;
+
 	br_stp_sap = llc_sap_open(LLC_SAP_BSPAN, br_stp_rcv);
 	if (!br_stp_sap) {
 		printk(KERN_ERR "bridge: can't register sap for STP\n");
-		return -EBUSY;
+		return -EADDRINUSE;
 	}
 
 	br_fdb_init();
 
-#ifdef CONFIG_BRIDGE_NETFILTER
-	if (br_netfilter_init())
-		return 1;
-#endif
+	err = br_netfilter_init();
+	if (err)
+		goto err_out1;
+
+	err = register_netdevice_notifier(&br_device_notifier);
+	if (err)
+		goto err_out2;
+
 	brioctl_set(br_ioctl_deviceless_stub);
 	br_handle_frame_hook = br_handle_frame;
 
 	br_fdb_get_hook = br_fdb_get;
 	br_fdb_put_hook = br_fdb_put;
 
-	register_netdevice_notifier(&br_device_notifier);
-
 	return 0;
+
+err_out2:
+	br_netfilter_fini();
+err_out1:
+	llc_sap_put(br_stp_sap);
+	return err;
 }
 
 static void __exit br_deinit(void)
 {
 	rcu_assign_pointer(br_stp_sap->rcv_func, NULL);
 
-#ifdef CONFIG_BRIDGE_NETFILTER
 	br_netfilter_fini();
-#endif
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
 
--- br.orig/net/bridge/br_private.h
+++ br/net/bridge/br_private.h
@@ -192,8 +192,13 @@ extern int br_dev_ioctl(struct net_devic
 extern int br_ioctl_deviceless_stub(unsigned int cmd, void __user *arg);
 
 /* br_netfilter.c */
+#ifdef CONFIG_BRIDGE_NETFILTER
 extern int br_netfilter_init(void);
 extern void br_netfilter_fini(void);
+#else
+#define br_netfilter_init()	(0)
+#define br_netfilter_fini()	do { } while(0)
+#endif
 
 /* br_stp.c */
 extern void br_log_state(const struct net_bridge_port *p);

--

