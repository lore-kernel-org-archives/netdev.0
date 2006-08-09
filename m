From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] sock_register interface changes
Date: Wed, 09 Aug 2006 11:31:43 -0700
Message-ID: <20060809183349.701469780@localhost.localdomain>
References: <20060809183138.332023530@localhost.localdomain>
Cc: Paul McKenney <paulmck@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10944 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751310AbWHISlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 14:41:13 -0400
To: David Miller <davem@davemloft.net>
Cc: akpm@osdl.org
Content-Disposition: inline; filename=sock-create-api.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sock_register() doesn't change the family, so the protocols can
define it read-only.  No caller ever checks return value from sock_unregister()

---
 include/linux/net.h |    4 ++--
 net/socket.c        |   10 ++++------
 2 files changed, 6 insertions(+), 8 deletions(-)

--- net-2.6.orig/include/linux/net.h	2006-08-09 11:19:19.000000000 -0700
+++ net-2.6/include/linux/net.h	2006-08-09 11:19:24.000000000 -0700
@@ -176,8 +176,8 @@
 struct kvec;
 
 extern int	     sock_wake_async(struct socket *sk, int how, int band);
-extern int	     sock_register(struct net_proto_family *fam);
-extern int	     sock_unregister(int family);
+extern int	     sock_register(const struct net_proto_family *fam);
+extern void	     sock_unregister(int family);
 extern int	     sock_create(int family, int type, int proto,
 				 struct socket **res);
 extern int	     sock_create_kern(int family, int type, int proto,
--- net-2.6.orig/net/socket.c	2006-08-09 11:19:22.000000000 -0700
+++ net-2.6/net/socket.c	2006-08-09 11:19:24.000000000 -0700
@@ -147,7 +147,7 @@
  */
 
 static DEFINE_SPINLOCK(net_family_lock);
-static const struct net_proto_family *net_families[NPROTO];
+static const struct net_proto_family *net_families[NPROTO] __read_mostly;
 
 /*
  *	Statistics counters of the socket lists
@@ -2070,7 +2070,7 @@
  *	socket interface. The value ops->family coresponds to the
  *	socket system call protocol family.
  */
-int sock_register(struct net_proto_family *ops)
+int sock_register(const struct net_proto_family *ops)
 {
 	int err;
 
@@ -2106,10 +2106,9 @@
  *	a module then it needs to provide its own protection in
  *	the ops->create routine.
  */
-int sock_unregister(int family)
+void sock_unregister(int family)
 {
-	if (family < 0 || family >= NPROTO)
-		return -EINVAL;
+	BUG_ON(family < 0 || family >= NPROTO);
 
 	spin_lock(&net_family_lock);
 	net_families[family] = NULL;
@@ -2118,7 +2117,6 @@
 	synchronize_rcu();
 
 	printk(KERN_INFO "NET: Unregistered protocol family %d\n", family);
-	return 0;
 }
 
 static int __init sock_init(void)

--

