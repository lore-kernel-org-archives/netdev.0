From: "V. Lavrov" <lve@guap.ru>
Subject: [PATCH] return the devices dummyX to the initial network namespace
 after container closure.
Date: Thu, 13 Dec 2012 13:13:34 +0400
Message-ID: <50C99C3E.4000907@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.guap.ru ([91.151.188.3]:11335 "EHLO mail.guap.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843Ab2LMJhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 04:37:21 -0500
Received: from [10.52.210.96] (cdr.local [10.52.210.96])
	(user=lve mech=CRAM-MD5 bits=0)
	by mail.guap.ru (8.14.4/8.14.4) with ESMTP id qBD9DYpu009183
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 13:13:34 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If container has a network device dummyX (with lxc.network.type = phys), then it disappears from the system after you close the container.
The patch returns the device dummyX to the initial network namespace after container is closed.

Signed-off-by: Vitaly Lavrov <lve@guap.ru>
---
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index bab0158..efa990c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -160,6 +160,41 @@ static struct rtnl_link_ops dummy_link_ops __read_mostly = {
  module_param(numdummies, int, 0);
  MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");

+
+static void __net_exit dummy_net_exit(struct net *net) {
+       struct net_device *dev, *aux;
+       int err;
+
+       if(net == &init_net) return;
+
+       rtnl_lock();
+       for_each_netdev_safe(net, dev, aux) {
+               if(dev->rtnl_link_ops == &dummy_link_ops) {
+                       err = dev_change_net_namespace(dev, &init_net, dev->name);
+                       if(err) {
+                               char fb_name[IFNAMSIZ];
+                               printk (KERN_INFO "%s: dev_change_net_namespace(init_net,%s) err: %d\n",
+                                       __func__,dev->name,err);
+                               snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
+                               err = dev_change_net_namespace(dev, &init_net, dev->name);
+                               if(err)
+                                       printk (KERN_INFO "%s: dev_change_net_namespace(%s,init_net,%s) err: %d\n",
+                                               __func__,dev->name,fb_name,err);
+                               else
+                                       printk (KERN_INFO "%s: %s rename to %s\n",
+                                               __func__,dev->name,fb_name);
+
+                       }
+               }
+       }
+       rtnl_unlock();
+}
+
+static struct pernet_operations __net_initdata dummy_net_ops = {
+       .exit = dummy_net_exit,
+};
+
+
  static int __init dummy_init_one(void)
  {
         struct net_device *dev_dummy;
@@ -184,6 +219,10 @@ static int __init dummy_init_module(void)
  {
         int i, err = 0;

+       err = register_pernet_device(&dummy_net_ops);
+       if(err)
+               return err;
+
         rtnl_lock();
         err = __rtnl_link_register(&dummy_link_ops);

@@ -191,8 +230,10 @@ static int __init dummy_init_module(void)
                 err = dummy_init_one();
                 cond_resched();
         }
-       if (err < 0)
+       if (err < 0) {
                 __rtnl_link_unregister(&dummy_link_ops);
+               unregister_pernet_device(&dummy_net_ops);
+       }
         rtnl_unlock();

         return err;
@@ -201,6 +242,7 @@ static int __init dummy_init_module(void)
  static void __exit dummy_cleanup_module(void)
  {
         rtnl_link_unregister(&dummy_link_ops);
+       unregister_pernet_device(&dummy_net_ops);
  }

  module_init(dummy_init_module);
--
