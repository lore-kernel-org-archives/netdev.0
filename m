From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netlink: cleanup rntl_af_register
Date: Mon, 30 Dec 2013 10:41:32 -0800
Message-ID: <20131230104132.13a10e3d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33060 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254Ab3L3Sle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:41:34 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so11494787pdj.26
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 10:41:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function __rtnl_af_register is never called outside this
code, and the return value is always 0.

---
 include/net/rtnetlink.h |    3 +--
 net/bridge/br_netlink.c |    5 +----
 net/core/rtnetlink.c    |   22 ++--------------------
 net/ipv6/addrconf.c     |    5 +----
 4 files changed, 5 insertions(+), 30 deletions(-)

--- a/include/net/rtnetlink.h	2013-12-24 15:23:13.903434901 -0800
+++ b/include/net/rtnetlink.h	2013-12-24 15:25:37.329487072 -0800
@@ -115,10 +115,9 @@ struct rtnl_af_ops {
 					       const struct nlattr *attr);
 };
 
-int __rtnl_af_register(struct rtnl_af_ops *ops);
 void __rtnl_af_unregister(struct rtnl_af_ops *ops);
 
-int rtnl_af_register(struct rtnl_af_ops *ops);
+void rtnl_af_register(struct rtnl_af_ops *ops);
 void rtnl_af_unregister(struct rtnl_af_ops *ops);
 
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
--- a/net/core/rtnetlink.c	2013-12-24 15:23:13.903434901 -0800
+++ b/net/core/rtnetlink.c	2013-12-24 15:25:37.329487072 -0800
@@ -403,34 +403,16 @@ static const struct rtnl_af_ops *rtnl_af
 }
 
 /**
- * __rtnl_af_register - Register rtnl_af_ops with rtnetlink.
- * @ops: struct rtnl_af_ops * to register
- *
- * The caller must hold the rtnl_mutex.
- *
- * Returns 0 on success or a negative error code.
- */
-int __rtnl_af_register(struct rtnl_af_ops *ops)
-{
-	list_add_tail(&ops->list, &rtnl_af_ops);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(__rtnl_af_register);
-
-/**
  * rtnl_af_register - Register rtnl_af_ops with rtnetlink.
  * @ops: struct rtnl_af_ops * to register
  *
  * Returns 0 on success or a negative error code.
  */
-int rtnl_af_register(struct rtnl_af_ops *ops)
+void rtnl_af_register(struct rtnl_af_ops *ops)
 {
-	int err;
-
 	rtnl_lock();
-	err = __rtnl_af_register(ops);
+	list_add_tail(&ops->list, &rtnl_af_ops);
 	rtnl_unlock();
-	return err;
 }
 EXPORT_SYMBOL_GPL(rtnl_af_register);
 
--- a/net/bridge/br_netlink.c	2013-12-24 15:23:13.903434901 -0800
+++ b/net/bridge/br_netlink.c	2013-12-24 15:25:37.329487072 -0800
@@ -481,9 +481,7 @@ int __init br_netlink_init(void)
 	int err;
 
 	br_mdb_init();
-	err = rtnl_af_register(&br_af_ops);
-	if (err)
-		goto out;
+	rtnl_af_register(&br_af_ops);
 
 	err = rtnl_link_register(&br_link_ops);
 	if (err)
@@ -493,7 +491,6 @@ int __init br_netlink_init(void)
 
 out_af:
 	rtnl_af_unregister(&br_af_ops);
-out:
 	br_mdb_uninit();
 	return err;
 }
--- a/net/ipv6/addrconf.c	2013-12-24 15:23:13.903434901 -0800
+++ b/net/ipv6/addrconf.c	2013-12-24 15:25:37.329487072 -0800
@@ -5210,9 +5210,7 @@ int __init addrconf_init(void)
 
 	addrconf_verify(0);
 
-	err = rtnl_af_register(&inet6_ops);
-	if (err < 0)
-		goto errout_af;
+	rtnl_af_register(&inet6_ops);
 
 	err = __rtnl_register(PF_INET6, RTM_GETLINK, NULL, inet6_dump_ifinfo,
 			      NULL);
@@ -5236,7 +5234,6 @@ int __init addrconf_init(void)
 	return 0;
 errout:
 	rtnl_af_unregister(&inet6_ops);
-errout_af:
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 errlo:
 	unregister_pernet_subsys(&addrconf_ops);
