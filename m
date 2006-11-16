From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] netdev do down on suspend and up on resume
Date: Wed, 15 Nov 2006 16:32:00 -0800
Message-ID: <20061115163200.64578a95@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40908 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162115AbWKPAcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 19:32:50 -0500
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a demo only. IMHO the network device code should take care of bringing
down network devices and restoring them on resume. Some distro's do this with scripts
and many devices do it themselves in the suspend code. But doing it in the main
netdevice code is best, and means that many network devices would need no special
suspend/resume code, since the default suspend for pci devices does a save/restore
state and power control.

It is compatiable with older devices (and distro's like Ubuntu) that do the same
thing already, because luckily calling dev_close on a down device does nothing, and
calling dev_open on an up device does nothing.

It is not possible to use the class interface (net_class) for a couple of reasons,
first the classes are called in registration order so the interesting ones like pci
have already suspended the device. Second, the class interface is based off hardware
not pseudo-devices like netdevice objects.



--- linux-2.6.19-rc5.orig/include/linux/netdevice.h	2006-11-15 11:27:54.000000000 -0800
+++ linux-2.6.19-rc5/include/linux/netdevice.h	2006-11-15 11:40:50.000000000 -0800
@@ -351,6 +351,7 @@
 
 
 	unsigned int		flags;	/* interface flags (a la BSD)	*/
+	unsigned int		save_flags; /* during suspend/resume */
 	unsigned short		gflags;
         unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
 	unsigned short		padded;	/* How much padding added by alloc_netdev() */
@@ -988,6 +989,14 @@
 extern void		net_enable_timestamp(void);
 extern void		net_disable_timestamp(void);
 
+#ifdef CONFIG_NET
+extern void		netdev_suspend(void);
+extern void		netdev_resume(void);
+#else
+#define netdev_suspend()	do { } while(0)
+#define netdev_resume()		do { } while(0)
+#endif
+
 #ifdef CONFIG_PROC_FS
 extern void *dev_seq_start(struct seq_file *seq, loff_t *pos);
 extern void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
--- sky2.orig/kernel/power/main.c	2006-11-15 11:35:42.000000000 -0800
+++ sky2/kernel/power/main.c	2006-11-15 11:37:24.000000000 -0800
@@ -18,6 +18,7 @@
 #include <linux/console.h>
 #include <linux/cpu.h>
 #include <linux/resume-trace.h>
+#include <linux/netdevice.h>
 
 #include "power.h"
 
@@ -61,6 +62,8 @@
 
 	pm_prepare_console();
 
+	netdev_suspend();
+
 	error = disable_nonboot_cpus();
 	if (error)
 		goto Enable_cpu;
@@ -98,6 +101,7 @@
 	thaw_processes();
  Enable_cpu:
 	enable_nonboot_cpus();
+	netdev_resume();
 	pm_restore_console();
 	return error;
 }
@@ -139,6 +143,7 @@
 	if (pm_ops && pm_ops->finish)
 		pm_ops->finish(state);
 	pm_restore_console();
+	netdev_resume();
 }
 
 
--- sky2.orig/net/core/dev.c	2006-11-15 11:28:00.000000000 -0800
+++ sky2/net/core/dev.c	2006-11-15 11:33:53.000000000 -0800
@@ -949,6 +949,45 @@
 	return 0;
 }
 
+#ifdef CONFIG_PM
+/*
+ *	netdev_suspend - close all network devices
+ *	During suspend, bring down all network interfaces and save state.
+ */
+void netdev_suspend(void)
+{
+	struct net_device *d;
+
+	rtnl_lock();
+	for (d = dev_base; d; d = d->next) {
+		d->save_flags = d->flags;
+		dev_close(d);
+	}
+	rtnl_unlock();
+}
+
+
+/*
+ *	netdev_resume - restore all network devices
+ *	During resume, bring up all network interfaces that were up before suspend.
+ */
+void netdev_resume(void)
+{
+	struct net_device *d;
+
+	rtnl_lock();
+	for (d = dev_base; d; d = d->next)
+		if (d->save_flags & IFF_UP) {
+			err = dev_open(d);
+			if (err) {
+				printk(KERN_INFO "%s: failed to come back up (%d)\n",
+				       d->name, err);
+			}
+		}
+
+	rtnl_unlock();
+}
+#endif
 
 /*
  *	Device change register/unregister. These are not inline or static
