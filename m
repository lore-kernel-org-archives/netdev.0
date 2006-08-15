From: Andrey Savochkin <saw@sw.ru>
Subject: [PATCH 3/9] network namespaces: playing and debugging
Date: Tue, 15 Aug 2006 18:48:43 +0400
Message-ID: <20060815184843.A2882@castle.nmd.msu.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:35088 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1751089AbWHPKdf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 06:33:35 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060815182029.A1685@castle.nmd.msu.ru>; from "Andrey Savochkin" on Tue, Aug 15, 2006 at 06:20:29PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Temporary code to play with network namespaces in the simplest way.
Do
        exec 7< /proc/net/net_ns
in your bash shell and you'll get a brand new network namespace.
There you can, for example, do
        ip link set lo up
        ip addr list
        ip addr add 1.2.3.4 dev lo
        ping -n 1.2.3.4

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
---
 dev.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+)

--- ./net/core/dev.c.vensxdbg	Tue Aug 15 13:46:44 2006
+++ ./net/core/dev.c	Tue Aug 15 13:46:44 2006
@@ -3597,6 +3597,8 @@ int net_ns_start(void)
 	if (err)
 		goto out_register;
 	put_net_ns(orig_ns);
+	printk(KERN_DEBUG "NET_NS: created new netcontext %p for %s (pid=%d)\n",
+			ns, task->comm, task->tgid);
 	return 0;
 
 out_register:
@@ -3629,14 +3631,29 @@ static void net_ns_destroy(void *data)
 	ip_fib_struct_cleanup();
 	pop_net_ns(orig_ns);
 	kfree(ns);
+	printk(KERN_DEBUG "NET_NS: netcontext %p freed\n", ns);
 }
 
 void net_ns_stop(struct net_namespace *ns)
 {
+	printk(KERN_DEBUG "NET_NS: netcontext %p scheduled for stop\n", ns);
 	INIT_WORK(&ns->destroy_work, net_ns_destroy, ns);
 	schedule_work(&ns->destroy_work);
 }
 EXPORT_SYMBOL(net_ns_stop);
+
+static int net_ns_open(struct inode *i, struct file *f)
+{
+	return net_ns_start();
+}
+static struct file_operations net_ns_fops = {
+	.open	= net_ns_open,
+};
+static int net_ns_init(void)
+{
+	return proc_net_fops_create("net_ns", S_IRWXU, &net_ns_fops)
+			? 0 : -ENOMEM;
+}
 #endif
 
 /*
@@ -3701,6 +3718,9 @@ static int __init net_dev_init(void)
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
 	dev_mcast_init();
+#ifdef CONFIG_NET_NS
+	net_ns_init();
+#endif
 	rc = 0;
 out:
 	return rc;
