From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 01/10] tun: Remove unnecessary tun_get_by_name
Date: Tue, 20 Jan 2009 12:56:20 -0800
Message-ID: <m1skndlmrv.fsf@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52469 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbZAUCpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:15 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out01.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5o-0007Y7-Ro
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:24 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5d-00054E-Ue
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:14 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jFTM029097
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:15 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jF43029096
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:15 -0800
In-Reply-To: <m1y6x5lmvy.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 12\:53\:53 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently the tun driver keeps a private list of tun devices for what
appears to be a small gain in performance when reconnecting a file
descriptor to an existing tun or tap device.  So simplify the code by
removing it.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |   74 +++++++++++++---------------------------------------
 1 files changed, 19 insertions(+), 55 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index d7b81e4..17923a5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -88,7 +88,6 @@ struct tap_filter {
 };
 
 struct tun_struct {
-	struct list_head        list;
 	unsigned int 		flags;
 	int			attached;
 	uid_t			owner;
@@ -213,11 +212,6 @@ static int check_filter(struct tap_filter *filter, const struct sk_buff *skb)
 
 /* Network device part of the driver */
 
-static int tun_net_id;
-struct tun_net {
-	struct list_head dev_list;
-};
-
 static const struct ethtool_ops tun_ethtool_ops;
 
 /* Net device open. */
@@ -697,30 +691,22 @@ static void tun_setup(struct net_device *dev)
 	dev->features |= NETIF_F_NETNS_LOCAL;
 }
 
-static struct tun_struct *tun_get_by_name(struct tun_net *tn, const char *name)
-{
-	struct tun_struct *tun;
-
-	ASSERT_RTNL();
-	list_for_each_entry(tun, &tn->dev_list, list) {
-		if (!strncmp(tun->dev->name, name, IFNAMSIZ))
-		    return tun;
-	}
-
-	return NULL;
-}
-
 static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 {
-	struct tun_net *tn;
 	struct tun_struct *tun;
 	struct net_device *dev;
 	const struct cred *cred = current_cred();
 	int err;
 
-	tn = net_generic(net, tun_net_id);
-	tun = tun_get_by_name(tn, ifr->ifr_name);
-	if (tun) {
+	dev = __dev_get_by_name(net, ifr->ifr_name);
+	if (dev) {
+		if ((ifr->ifr_flags & IFF_TUN) && dev->netdev_ops == &tun_netdev_ops)
+			tun = netdev_priv(dev);
+		else if ((ifr->ifr_flags & IFF_TAP) && dev->netdev_ops == &tap_netdev_ops)
+			tun = netdev_priv(dev);
+		else
+			return -EINVAL;
+
 		if (tun->attached)
 			return -EBUSY;
 
@@ -733,8 +719,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			return -EPERM;
 		}
 	}
-	else if (__dev_get_by_name(net, ifr->ifr_name))
-		return -EINVAL;
 	else {
 		char *name;
 		unsigned long flags = 0;
@@ -782,8 +766,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_free_dev;
-
-		list_add(&tun->list, &tn->dev_list);
 	}
 
 	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
@@ -1095,10 +1077,8 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 	/* Drop read queue */
 	skb_queue_purge(&tun->readq);
 
-	if (!(tun->flags & TUN_PERSIST)) {
-		list_del(&tun->list);
+	if (!(tun->flags & TUN_PERSIST))
 		unregister_netdevice(tun->dev);
-	}
 
 	rtnl_unlock();
 
@@ -1212,37 +1192,21 @@ static const struct ethtool_ops tun_ethtool_ops = {
 
 static int tun_init_net(struct net *net)
 {
-	struct tun_net *tn;
-
-	tn = kmalloc(sizeof(*tn), GFP_KERNEL);
-	if (tn == NULL)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&tn->dev_list);
-
-	if (net_assign_generic(net, tun_net_id, tn)) {
-		kfree(tn);
-		return -ENOMEM;
-	}
-
 	return 0;
 }
 
 static void tun_exit_net(struct net *net)
 {
-	struct tun_net *tn;
-	struct tun_struct *tun, *nxt;
-
-	tn = net_generic(net, tun_net_id);
+	struct net_device *dev, *next;
 
 	rtnl_lock();
-	list_for_each_entry_safe(tun, nxt, &tn->dev_list, list) {
-		DBG(KERN_INFO "%s cleaned up\n", tun->dev->name);
-		unregister_netdevice(tun->dev);
+	for_each_netdev_safe(net, dev, next) {
+		if (dev->ethtool_ops != &tun_ethtool_ops)
+			continue;
+		DBG(KERN_INFO "%s cleaned up\n", dev->name);
+		unregister_netdevice(dev);
 	}
 	rtnl_unlock();
-
-	kfree(tn);
 }
 
 static struct pernet_operations tun_net_ops = {
@@ -1257,7 +1221,7 @@ static int __init tun_init(void)
 	printk(KERN_INFO "tun: %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	printk(KERN_INFO "tun: %s\n", DRV_COPYRIGHT);
 
-	ret = register_pernet_gen_device(&tun_net_id, &tun_net_ops);
+	ret = register_pernet_device(&tun_net_ops);
 	if (ret) {
 		printk(KERN_ERR "tun: Can't register pernet ops\n");
 		goto err_pernet;
@@ -1271,7 +1235,7 @@ static int __init tun_init(void)
 	return 0;
 
 err_misc:
-	unregister_pernet_gen_device(tun_net_id, &tun_net_ops);
+	unregister_pernet_device(&tun_net_ops);
 err_pernet:
 	return ret;
 }
@@ -1279,7 +1243,7 @@ err_pernet:
 static void tun_cleanup(void)
 {
 	misc_deregister(&tun_miscdev);
-	unregister_pernet_gen_device(tun_net_id, &tun_net_ops);
+	unregister_pernet_device(&tun_net_ops);
 }
 
 module_init(tun_init);
-- 
1.5.6.3
