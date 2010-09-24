From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] ipv6: add a missing unregister_pernet_subsys call
Date: Fri, 24 Sep 2010 15:55:52 -0400
Message-ID: <20100924195552.GA8477@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45144 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab0IXT71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 15:59:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up a missing exit path in the ipv6 module init routines.  In
addrconf_init we call ipv6_addr_label_init which calls register_pernet_subsys
for the ipv6_addr_label_ops structure.  But if module loading fails, or if the
ipv6 module is removed, there is no corresponding unregister_pernet_subsys call,
which leaves a now-bogus address on the pernet_list, leading to oopses in
subsequent registrations.  This patch cleans up both the failed load path and
the unload path.  Tested by myself with good results.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/net/addrconf.h |    1 +
 net/ipv6/addrconf.c    |   11 ++++++++---
 net/ipv6/addrlabel.c   |    5 +++++
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 7d178a7..958d274 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -121,6 +121,7 @@ static inline int addrconf_finite_timeout(unsigned long timeout)
  *	IPv6 Address Label subsystem (addrlabel.c)
  */
 extern int			ipv6_addr_label_init(void);
+extern void			ipv6_addr_label_cleanup(void);
 extern void			ipv6_addr_label_rtnl_register(void);
 extern u32			ipv6_addr_label(struct net *net,
 						const struct in6_addr *addr,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5bc893e..58e8871 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4638,10 +4638,12 @@ int __init addrconf_init(void)
 	if (err < 0) {
 		printk(KERN_CRIT "IPv6 Addrconf:"
 		       " cannot initialize default policy table: %d.\n", err);
-		return err;
+		goto out;
 	}
 
-	register_pernet_subsys(&addrconf_ops);
+	err = register_pernet_subsys(&addrconf_ops);
+	if (err < 0)
+		goto out_addrlabel;
 
 	/* The addrconf netdev notifier requires that loopback_dev
 	 * has it's ipv6 private information allocated and setup
@@ -4693,7 +4695,9 @@ errout:
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 errlo:
 	unregister_pernet_subsys(&addrconf_ops);
-
+out_addrlabel:
+	ipv6_addr_label_cleanup();
+out:
 	return err;
 }
 
@@ -4704,6 +4708,7 @@ void addrconf_cleanup(void)
 
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 	unregister_pernet_subsys(&addrconf_ops);
+	ipv6_addr_label_cleanup();
 
 	rtnl_lock();
 
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index f0e774c..8175f80 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -393,6 +393,11 @@ int __init ipv6_addr_label_init(void)
 	return register_pernet_subsys(&ipv6_addr_label_ops);
 }
 
+void ipv6_addr_label_cleanup(void)
+{
+	unregister_pernet_subsys(&ipv6_addr_label_ops);
+}
+
 static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
 	[IFAL_ADDRESS]		= { .len = sizeof(struct in6_addr), },
 	[IFAL_LABEL]		= { .len = sizeof(u32), },
