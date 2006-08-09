From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] net: socket family using RCU
Date: Wed, 09 Aug 2006 11:31:42 -0700
Message-ID: <20060809183349.528294134@localhost.localdomain>
References: <20060809183138.332023530@localhost.localdomain>
Cc: Paul McKenney <paulmck@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10432 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751307AbWHISlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 14:41:12 -0400
To: David Miller <davem@davemloft.net>
Cc: akpm@osdl.org
Content-Disposition: inline; filename=socket-family-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the gross custom locking done in socket code for net_family[]
with simple RCU usage. Some reordering necessary to avoid sleep
issues with sock_alloc.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/socket.c |  171 +++++++++++++++++++++++++----------------------------------
 1 file changed, 74 insertions(+), 97 deletions(-)

--- net-2.6.orig/net/socket.c	2006-08-09 11:19:08.000000000 -0700
+++ net-2.6/net/socket.c	2006-08-09 11:19:22.000000000 -0700
@@ -59,11 +59,11 @@
  */
 
 #include <linux/mm.h>
-#include <linux/smp_lock.h>
 #include <linux/socket.h>
 #include <linux/file.h>
 #include <linux/net.h>
 #include <linux/interrupt.h>
+#include <linux/rcupdate.h>
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -146,51 +146,8 @@
  *	The protocol list. Each protocol is registered in here.
  */
 
-static struct net_proto_family *net_families[NPROTO];
-
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-static atomic_t net_family_lockct = ATOMIC_INIT(0);
 static DEFINE_SPINLOCK(net_family_lock);
-
-/* The strategy is: modifications net_family vector are short, do not
-   sleep and veeery rare, but read access should be free of any exclusive
-   locks.
- */
-
-static void net_family_write_lock(void)
-{
-	spin_lock(&net_family_lock);
-	while (atomic_read(&net_family_lockct) != 0) {
-		spin_unlock(&net_family_lock);
-
-		yield();
-
-		spin_lock(&net_family_lock);
-	}
-}
-
-static __inline__ void net_family_write_unlock(void)
-{
-	spin_unlock(&net_family_lock);
-}
-
-static __inline__ void net_family_read_lock(void)
-{
-	atomic_inc(&net_family_lockct);
-	spin_unlock_wait(&net_family_lock);
-}
-
-static __inline__ void net_family_read_unlock(void)
-{
-	atomic_dec(&net_family_lockct);
-}
-
-#else
-#define net_family_write_lock() do { } while(0)
-#define net_family_write_unlock() do { } while(0)
-#define net_family_read_lock() do { } while(0)
-#define net_family_read_unlock() do { } while(0)
-#endif
+static const struct net_proto_family *net_families[NPROTO];
 
 /*
  *	Statistics counters of the socket lists
@@ -1131,6 +1088,7 @@
 {
 	int err;
 	struct socket *sock;
+	const struct net_proto_family *pf;
 
 	/*
 	 *      Check protocol is in range
@@ -1159,6 +1117,20 @@
 	if (err)
 		return err;
 
+	/*
+	 *	Allocate the socket and allow the family to set things up. if
+	 *	the protocol is 0, the family is instructed to select an appropriate
+	 *	default.
+	 */
+	sock = sock_alloc();
+	if (!sock) {
+		printk(KERN_WARNING "socket: no more sockets\n");
+		return -ENFILE;	/* Not exactly a match, but its the
+				   closest posix thing */
+	}
+
+	sock->type = type;
+
 #if defined(CONFIG_KMOD)
 	/* Attempt to load a protocol module if the find failed.
 	 *
@@ -1166,70 +1138,59 @@
 	 * requested real, full-featured networking support upon configuration.
 	 * Otherwise module support will break!
 	 */
-	if (net_families[family] == NULL) {
+	if (net_families[family] == NULL)
 		request_module("net-pf-%d", family);
-	}
 #endif
 
-	net_family_read_lock();
-	if (net_families[family] == NULL) {
-		err = -EAFNOSUPPORT;
-		goto out;
-	}
-
-/*
- *	Allocate the socket and allow the family to set things up. if
- *	the protocol is 0, the family is instructed to select an appropriate
- *	default.
- */
-
-	if (!(sock = sock_alloc())) {
-		printk(KERN_WARNING "socket: no more sockets\n");
-		err = -ENFILE;	/* Not exactly a match, but its the
-				   closest posix thing */
-		goto out;
-	}
-
-	sock->type = type;
+	rcu_read_lock();
+	pf = rcu_dereference(net_families[family]);
+	err = -EAFNOSUPPORT;
+	if (!pf)
+		goto out_release;
 
 	/*
 	 * We will call the ->create function, that possibly is in a loadable
 	 * module, so we have to bump that loadable module refcnt first.
 	 */
-	err = -EAFNOSUPPORT;
-	if (!try_module_get(net_families[family]->owner))
+	if (!try_module_get(pf->owner))
 		goto out_release;
 
-	if ((err = net_families[family]->create(sock, protocol)) < 0) {
-		sock->ops = NULL;
+	/* Now protected by module ref count */
+	rcu_read_unlock();
+
+	err = pf->create(sock, protocol);
+	if (err < 0)
 		goto out_module_put;
-	}
 
 	/*
 	 * Now to bump the refcnt of the [loadable] module that owns this
 	 * socket at sock_release time we decrement its refcnt.
 	 */
-	if (!try_module_get(sock->ops->owner)) {
-		err = -EAGAIN;
-		sock->ops = NULL;
-		goto out_module_put;
-	}
+	if (!try_module_get(sock->ops->owner))
+		goto out_module_busy;
+
 	/*
 	 * Now that we're done with the ->create function, the [loadable]
 	 * module can have its refcnt decremented
 	 */
-	module_put(net_families[family]->owner);
+	module_put(pf->owner);
 	*res = sock;
 	security_socket_post_create(sock, family, type, protocol, kern);
 
-out:
-	net_family_read_unlock();
-	return err;
+	return 0;
+
+out_module_busy:
+	err = -EAGAIN;
 out_module_put:
-	module_put(net_families[family]->owner);
-out_release:
+	sock->ops = NULL;
+	module_put(pf->owner);
+out_sock_release:
 	sock_release(sock);
-	goto out;
+	return err;
+
+out_release:
+	rcu_read_unlock();
+	goto out_sock_release;
 }
 
 int sock_create(int family, int type, int protocol, struct socket **res)
@@ -2100,12 +2061,15 @@
 
 #endif				/* __ARCH_WANT_SYS_SOCKETCALL */
 
-/*
+/**
+ *	sock_register - add a socket protocol handler
+ *	@ops: description of protocol
+ *
  *	This function is called by a protocol handler that wants to
  *	advertise its address family, and have it linked into the
- *	SOCKET module.
+ *	socket interface. The value ops->family coresponds to the
+ *	socket system call protocol family.
  */
-
 int sock_register(struct net_proto_family *ops)
 {
 	int err;
@@ -2115,31 +2079,44 @@
 		       NPROTO);
 		return -ENOBUFS;
 	}
-	net_family_write_lock();
-	err = -EEXIST;
-	if (net_families[ops->family] == NULL) {
+
+	spin_lock(&net_family_lock);
+	if (net_families[ops->family])
+		err = -EEXIST;
+	else {
 		net_families[ops->family] = ops;
 		err = 0;
 	}
-	net_family_write_unlock();
+	spin_unlock(&net_family_lock);
+
 	printk(KERN_INFO "NET: Registered protocol family %d\n", ops->family);
 	return err;
 }
 
-/*
+/**
+ *	sock_unregister - remove a protocol handler
+ *	@family: protocol family to remove
+ *
  *	This function is called by a protocol handler that wants to
  *	remove its address family, and have it unlinked from the
- *	SOCKET module.
+ *	new socket creation.
+ *
+ *	If protocol handler is a module, then it can use module reference
+ *	counts to protect against new references. If protocol handler is not
+ *	a module then it needs to provide its own protection in
+ *	the ops->create routine.
  */
-
 int sock_unregister(int family)
 {
 	if (family < 0 || family >= NPROTO)
-		return -1;
+		return -EINVAL;
 
-	net_family_write_lock();
+	spin_lock(&net_family_lock);
 	net_families[family] = NULL;
-	net_family_write_unlock();
+	spin_unlock(&net_family_lock);
+
+	synchronize_rcu();
+
 	printk(KERN_INFO "NET: Unregistered protocol family %d\n", family);
 	return 0;
 }

--

