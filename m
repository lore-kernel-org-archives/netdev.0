From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NET: Add the helper kernel_sock_shutdown()
Date: Sun, 11 Nov 2007 13:40:14 -0500
Message-ID: <1194806414.11890.2.camel@heimdal.trondhjem.org>
References: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
	 <20071111180341.GP28607@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-d98JpQWI8yKmP/KyxSuQ"
Cc: netdev@vger.kernel.org, Paul Clements <Paul.Clements@steeleye.com>,
	Steve French <sfrench@samba.org>,
	David Howells <dhowells@redhat.com>,
	David S Miller <davem@davemloft.net>
To: Mark Fasheh <mark.fasheh@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39791 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543AbXKKSkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2007 13:40:47 -0500
In-Reply-To: <20071111180341.GP28607@ca-server1.us.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-d98JpQWI8yKmP/KyxSuQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sun, 2007-11-11 at 10:03 -0800, Mark Fasheh wrote:
> On Thu, Nov 08, 2007 at 07:01:36PM -0500, Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > ...and fix a couple of bugs in the NBD, CIFS and OCFS2 socket handlers.
> > 
> > Looking at the sock->op->shutdown() handlers, it looks as if all of them
> > take a SHUT_RD/SHUT_WR/SHUT_RDWR argument instead of the
> > RCV_SHUTDOWN/SEND_SHUTDOWN arguments.
> > Add a helper, and then define the SHUT_* enum to ensure that kernel users
> > of shutdown() don't get confused.
> 
> That looks pretty good - any objection to naming the enum and using that
> name in the prototype for kernel_sock_shutdown() so it's even more obvious
> what type of shutdown argument this expects?
> 	--Mark
> 
> --
> Mark Fasheh
> Senior Software Developer, Oracle
> mark.fasheh@oracle.com

That would be fine by me. How about the attached patch?

Cheers
  Trond


--=-d98JpQWI8yKmP/KyxSuQ
Content-Disposition: inline; filename=linux-2.6.24-002-network_add_kernel_sock_shutdown.dif
Content-Type: message/rfc822; name=linux-2.6.24-002-network_add_kernel_sock_shutdown.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 8 Nov 2007 18:53:09 -0500
Subject: NET: Add the helper kernel_sock_shutdown()
Message-Id: <1194806414.11890.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0

...and fix a couple of bugs in the NBD, CIFS and OCFS2 socket handlers.

Looking at the sock->op->shutdown() handlers, it looks as if all of them
take a SHUT_RD/SHUT_WR/SHUT_RDWR argument instead of the
RCV_SHUTDOWN/SEND_SHUTDOWN arguments.
Add a helper, and then define the SHUT_* enum to ensure that kernel users
of shutdown() don't get confused.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Paul Clements <Paul.Clements@steeleye.com>
Cc: Mark Fasheh <mark.fasheh@oracle.com>
Cc: Steve French <sfrench@samba.org>
Cc: David Howells <dhowells@redhat.com>
Cc: David S Miller <davem@davemloft.net>
---

 drivers/block/nbd.c    |    3 ++-
 fs/cifs/connect.c      |    2 +-
 fs/ocfs2/cluster/tcp.c |    4 ++--
 include/linux/net.h    |    8 ++++++++
 net/rxrpc/ar-local.c   |    4 ++--
 net/socket.c           |    6 ++++++
 6 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 6332aca..b4c0888 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -28,6 +28,7 @@
 #include <linux/err.h>
 #include <linux/kernel.h>
 #include <net/sock.h>
+#include <linux/net.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -126,7 +127,7 @@ static void sock_shutdown(struct nbd_device *lo, int lock)
 	if (lo->sock) {
 		printk(KERN_WARNING "%s: shutting down socket\n",
 			lo->disk->disk_name);
-		lo->sock->ops->shutdown(lo->sock, SEND_SHUTDOWN|RCV_SHUTDOWN);
+		kernel_sock_shutdown(lo->sock, SHUT_RDWR);
 		lo->sock = NULL;
 	}
 	if (lock)
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 19ee11f..bea0d2e 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -160,7 +160,7 @@ cifs_reconnect(struct TCP_Server_Info *server)
 	if (server->ssocket) {
 		cFYI(1, ("State: 0x%x Flags: 0x%lx", server->ssocket->state,
 			server->ssocket->flags));
-		server->ssocket->ops->shutdown(server->ssocket, SEND_SHUTDOWN);
+		kernel_sock_shutdown(server->ssocket, SHUT_WR);
 		cFYI(1, ("Post shutdown state: 0x%x Flags: 0x%lx",
 			server->ssocket->state,
 			server->ssocket->flags));
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index 685c180..d84bd15 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -58,6 +58,7 @@
 #include <linux/slab.h>
 #include <linux/idr.h>
 #include <linux/kref.h>
+#include <linux/net.h>
 #include <net/tcp.h>
 
 #include <asm/uaccess.h>
@@ -616,8 +617,7 @@ static void o2net_shutdown_sc(struct work_struct *work)
 		del_timer_sync(&sc->sc_idle_timeout);
 		o2net_sc_cancel_delayed_work(sc, &sc->sc_keepalive_work);
 		sc_put(sc);
-		sc->sc_sock->ops->shutdown(sc->sc_sock,
-					   RCV_SHUTDOWN|SEND_SHUTDOWN);
+		kernel_sock_shutdown(sc->sc_sock, SHUT_RDWR);
 	}
 
 	/* not fatal so failed connects before the other guy has our
diff --git a/include/linux/net.h b/include/linux/net.h
index dd79cdb..596131e 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -95,6 +95,12 @@ enum sock_type {
 
 #endif /* ARCH_HAS_SOCKET_TYPES */
 
+enum sock_shutdown_cmd {
+	SHUT_RD		= 0,
+	SHUT_WR		= 1,
+	SHUT_RDWR	= 2,
+};
+
 /**
  *  struct socket - general BSD socket
  *  @state: socket state (%SS_CONNECTED, etc)
@@ -223,6 +229,8 @@ extern int kernel_setsockopt(struct socket *sock, int level, int optname,
 extern int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 			   size_t size, int flags);
 extern int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
+extern int kernel_sock_shutdown(struct socket *sock,
+				enum sock_shutdown_cmd how);
 
 #ifndef CONFIG_SMP
 #define SOCKOPS_WRAPPED(name) name
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index fe03f71..f3a2bd7 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -114,7 +114,7 @@ static int rxrpc_create_local(struct rxrpc_local *local)
 	return 0;
 
 error:
-	local->socket->ops->shutdown(local->socket, 2);
+	kernel_sock_shutdown(local->socket, SHUT_RDWR);
 	local->socket->sk->sk_user_data = NULL;
 	sock_release(local->socket);
 	local->socket = NULL;
@@ -267,7 +267,7 @@ static void rxrpc_destroy_local(struct work_struct *work)
 	/* finish cleaning up the local descriptor */
 	rxrpc_purge_queue(&local->accept_queue);
 	rxrpc_purge_queue(&local->reject_queue);
-	local->socket->ops->shutdown(local->socket, 2);
+	kernel_sock_shutdown(local->socket, SHUT_RDWR);
 	sock_release(local->socket);
 
 	up_read(&rxrpc_local_sem);
diff --git a/net/socket.c b/net/socket.c
index 5d879fd..74784df 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2319,6 +2319,11 @@ int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg)
 	return err;
 }
 
+int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
+{
+	return sock->ops->shutdown(sock, how);
+}
+
 /* ABI emulation layers need these two */
 EXPORT_SYMBOL(move_addr_to_kernel);
 EXPORT_SYMBOL(move_addr_to_user);
@@ -2345,3 +2350,4 @@ EXPORT_SYMBOL(kernel_getsockopt);
 EXPORT_SYMBOL(kernel_setsockopt);
 EXPORT_SYMBOL(kernel_sendpage);
 EXPORT_SYMBOL(kernel_sock_ioctl);
+EXPORT_SYMBOL(kernel_sock_shutdown);

--=-d98JpQWI8yKmP/KyxSuQ--
