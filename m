From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: socket hooks for 2.5.59 (4/8)
Date: Fri, 31 Jan 2003 10:01:34 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301310956530.31382-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0301310952140.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0301310952140.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h |  346 +++++++++++++++++++++++++++++++++++++++++++++++
 include/net/sock.h       |   14 +
 net/core/sock.c          |    6 
 net/ipv4/tcp_ipv4.c      |    4 
 net/socket.c             |   72 +++++++++
 security/dummy.c         |  111 ++++++++++++++-
 6 files changed, 549 insertions(+), 4 deletions(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Thu Jan 30 21:31:15 2003
+++ linux-2.5.59.w1/include/linux/security.h	Thu Jan 30 21:31:32 2003
@@ -65,6 +65,9 @@
 
 /* forward declares to avoid warnings */
 struct sock;
+struct socket;
+struct sockaddr;
+struct msghdr;
 struct sk_buff;
 struct net_device;
 struct nfsctl_arg;
@@ -587,6 +590,126 @@
  * 	is being reparented to the init task.
  *	@p contains the task_struct for the kernel thread.
  *
+ * Security hooks for socket operations.
+ *
+ * @socket_create:
+ *	Check permissions prior to creating a new socket.
+ *	@family contains the requested protocol family.
+ *	@type contains the requested communications type.
+ *	@protocol contains the requested protocol.
+ *	Return 0 if permission is granted.
+ * @socket_post_create:
+ *	This hook allows a module to update or allocate a per-socket security
+ *	structure. Note that the security field was not added directly to the
+ *	socket structure, but rather, the socket security information is stored
+ *	in the associated inode.  Typically, the inode alloc_security hook will
+ *	allocate and and attach security information to
+ *	sock->inode->i_security.  This hook may be used to update the
+ *	sock->inode->i_security field with additional information that wasn't
+ *	available when the inode was allocated.
+ *	@sock contains the newly created socket structure.
+ *	@family contains the requested protocol family.
+ *	@type contains the requested communications type.
+ *	@protocol contains the requested protocol.
+ * @socket_bind:
+ *	Check permission before socket protocol layer bind operation is
+ *	performed and the socket @sock is bound to the address specified in the
+ *	@address parameter.
+ *	@sock contains the socket structure.
+ *	@address contains the address to bind to.
+ *	@addrlen contains the length of address.
+ *	Return 0 if permission is granted.  
+ * @socket_connect:
+ *	Check permission before socket protocol layer connect operation
+ *	attempts to connect socket @sock to a remote address, @address.
+ *	@sock contains the socket structure.
+ *	@address contains the address of remote endpoint.
+ *	@addrlen contains the length of address.
+ *	Return 0 if permission is granted.  
+ * @socket_listen:
+ *	Check permission before socket protocol layer listen operation.
+ *	@sock contains the socket structure.
+ *	@backlog contains the maximum length for the pending connection queue.
+ *	Return 0 if permission is granted.
+ * @socket_accept:
+ *	Check permission before accepting a new connection.  Note that the new
+ *	socket, @newsock, has been created and some information copied to it,
+ *	but the accept operation has not actually been performed.
+ *	@sock contains the listening socket structure.
+ *	@newsock contains the newly created server socket for connection.
+ *	Return 0 if permission is granted.
+ * @socket_post_accept:
+ *	This hook allows a security module to copy security
+ *	information into the newly created socket's inode.
+ *	@sock contains the listening socket structure.
+ *	@newsock contains the newly created server socket for connection.
+ * @socket_sendmsg:
+ *	Check permission before transmitting a message to another socket.
+ *	@sock contains the socket structure.
+ *	@msg contains the message to be transmitted.
+ *	@size contains the size of message.
+ *	Return 0 if permission is granted.
+ * @socket_recvmsg:
+ *	Check permission before receiving a message from a socket.
+ *	@sock contains the socket structure.
+ *	@msg contains the message structure.
+ *	@size contains the size of message structure.
+ *	@flags contains the operational flags.
+ *	Return 0 if permission is granted.  
+ * @socket_getsockname:
+ *	Check permission before the local address (name) of the socket object
+ *	@sock is retrieved.
+ *	@sock contains the socket structure.
+ *	Return 0 if permission is granted.
+ * @socket_getpeername:
+ *	Check permission before the remote address (name) of a socket object
+ *	@sock is retrieved.
+ *	@sock contains the socket structure.
+ *	Return 0 if permission is granted.
+ * @socket_getsockopt:
+ *	Check permissions before retrieving the options associated with socket
+ *	@sock.
+ *	@sock contains the socket structure.
+ *	@level contains the protocol level to retrieve option from.
+ *	@optname contains the name of option to retrieve.
+ *	Return 0 if permission is granted.
+ * @socket_setsockopt:
+ *	Check permissions before setting the options associated with socket
+ *	@sock.
+ *	@sock contains the socket structure.
+ *	@level contains the protocol level to set options for.
+ *	@optname contains the name of the option to set.
+ *	Return 0 if permission is granted.  
+ * @socket_shutdown:
+ *	Checks permission before all or part of a connection on the socket
+ *	@sock is shut down.
+ *	@sock contains the socket structure.
+ *	@how contains the flag indicating how future sends and receives are handled.
+ *	Return 0 if permission is granted.
+ * @socket_sock_alloc_security:
+ *      @sk contains the sock structure.
+ *	@gfp_mask contains the kernel allocation gfp_mask value.
+ *      Allocate and attach a security structure to @sk->security.  The
+ *      security field is initialized to NULL when the sock structure is
+ *      allocated.
+ *      Return 0 if operation was successful.
+ * @socket_sock_free_security:
+ *      @sk contains the sock structure.
+ *      Deallocate and clear the sk->security field.
+ * @socket_sock_rcv_skb:
+ *	Check permissions on incoming network packets.  This hook is distinct
+ *	from the network input hooks of ip_security_ops since it is the first
+ *	time that the incoming sk_buff @skb has been associated with a
+ *	particular socket, @sk.  Security modules should not try to dereference
+ *	@sk->socket if the socket is in a time wait state 
+ *	(@sk->state == TCP_TIME_WAIT), since the @sk refers to a tcp_tw_bucket
+ *	structure in that case.  Also, even if the socket is not in this state,
+ *	@sk->socket may be NULL, e.g. a newly created server socket for a
+ *	connection that has not yet been accepted by a process.
+ *	@sk contains the sock (not socket) associated with the incoming sk_buff.
+ *	@skb contains the incoming network data.
+ * 	Return 0 if permission is granted.
+ *
  * Lifecycle hooks for network buffers.
  *
  * @skb_alloc_security:
@@ -1012,6 +1135,30 @@
 	                            struct security_operations *ops);
 
 #ifdef CONFIG_SECURITY_NETWORK
+	int (*socket_create) (int family, int type, int protocol);
+	void (*socket_post_create) (struct socket * sock, int family,
+				    int type, int protocol);
+	int (*socket_bind) (struct socket * sock,
+			    struct sockaddr * address, int addrlen);
+	int (*socket_connect) (struct socket * sock,
+			       struct sockaddr * address, int addrlen);
+	int (*socket_listen) (struct socket * sock, int backlog);
+	int (*socket_accept) (struct socket * sock, struct socket * newsock);
+	void (*socket_post_accept) (struct socket * sock,
+				    struct socket * newsock);
+	int (*socket_sendmsg) (struct socket * sock,
+			       struct msghdr * msg, int size);
+	int (*socket_recvmsg) (struct socket * sock,
+			       struct msghdr * msg, int size, int flags);
+	int (*socket_getsockname) (struct socket * sock);
+	int (*socket_getpeername) (struct socket * sock);
+	int (*socket_getsockopt) (struct socket * sock, int level, int optname);
+	int (*socket_setsockopt) (struct socket * sock, int level, int optname);
+	int (*socket_shutdown) (struct socket * sock, int how);
+	int (*socket_sock_alloc_security) (struct sock * sk, int gfp_mask);
+	void (*socket_sock_free_security) (struct sock * sk);
+	int (*socket_sock_rcv_skb) (struct sock * sk, struct sk_buff * skb);
+
 	int (*skb_alloc_security) (struct sk_buff * skb, int gfp_mask);
 	int (*skb_clone) (struct sk_buff * newskb,
 			  const struct sk_buff * oldskb);
@@ -2180,6 +2327,107 @@
 
 #ifdef CONFIG_SECURITY_NETWORK
 
+static inline int security_socket_create (int family, int type, int protocol)
+{
+	return security_ops->socket_create(family, type, protocol);
+}
+
+static inline void security_socket_post_create(struct socket * sock, 
+					       int family,
+					       int type, 
+					       int protocol)
+{
+	security_ops->socket_post_create(sock, family, type, protocol);
+}
+
+static inline int security_socket_bind(struct socket * sock, 
+				       struct sockaddr * address, 
+				       int addrlen)
+{
+	return security_ops->socket_bind(sock, address, addrlen);
+}
+
+static inline int security_socket_connect(struct socket * sock, 
+					  struct sockaddr * address, 
+					  int addrlen)
+{
+	return security_ops->socket_connect(sock, address, addrlen);
+}
+
+static inline int security_socket_listen(struct socket * sock, int backlog)
+{
+	return security_ops->socket_listen(sock, backlog);
+}
+
+static inline int security_socket_accept(struct socket * sock, 
+					 struct socket * newsock)
+{
+	return security_ops->socket_accept(sock, newsock);
+}
+
+static inline void security_socket_post_accept(struct socket * sock, 
+					       struct socket * newsock)
+{
+	security_ops->socket_post_accept(sock, newsock);
+}
+
+static inline int security_socket_sendmsg(struct socket * sock, 
+					  struct msghdr * msg, int size)
+{
+	return security_ops->socket_sendmsg(sock, msg, size);
+}
+
+static inline int security_socket_recvmsg(struct socket * sock, 
+					  struct msghdr * msg, int size, 
+					  int flags)
+{
+	return security_ops->socket_recvmsg(sock, msg, size, flags);
+}
+
+static inline int security_socket_getsockname(struct socket * sock)
+{
+	return security_ops->socket_getsockname(sock);
+}
+
+static inline int security_socket_getpeername(struct socket * sock)
+{
+	return security_ops->socket_getpeername(sock);
+}
+
+static inline int security_socket_getsockopt(struct socket * sock, 
+					     int level, int optname)
+{
+	return security_ops->socket_getsockopt(sock, level, optname);
+}
+
+static inline int security_socket_setsockopt(struct socket * sock, 
+					     int level, int optname)
+{
+	return security_ops->socket_setsockopt(sock, level, optname);
+}
+
+static inline int security_socket_shutdown(struct socket * sock, int how)
+{
+	return security_ops->socket_shutdown(sock, how);
+}
+
+static inline int security_sock_alloc(struct sock * sk, 
+				      int gfp_mask)
+{
+	return security_ops->socket_sock_alloc_security(sk, gfp_mask);
+}
+
+static inline void security_sock_free(struct sock * sk)
+{
+	security_ops->socket_sock_free_security(sk);
+}
+
+static inline int security_sock_rcv_skb (struct sock * sk, 
+					 struct sk_buff * skb)
+{
+	return security_ops->socket_sock_rcv_skb (sk, skb);
+}
+
 static inline int security_skb_alloc(struct sk_buff * skb, int gfp_mask)
 {
 	return security_ops->skb_alloc_security(skb, gfp_mask);
@@ -2221,6 +2469,104 @@
 
 #else	/* CONFIG_SECURITY_NETWORK */
 
+static inline int security_socket_create (int family, int type, int protocol)
+{
+	return 0;
+}
+
+static inline void security_socket_post_create(struct socket * sock, 
+					       int family,
+					       int type, 
+					       int protocol)
+{
+}
+
+static inline int security_socket_bind(struct socket * sock, 
+				       struct sockaddr * address, 
+				       int addrlen)
+{
+	return 0;
+}
+
+static inline int security_socket_connect(struct socket * sock, 
+					  struct sockaddr * address, 
+					  int addrlen)
+{
+	return 0;
+}
+
+static inline int security_socket_listen(struct socket * sock, int backlog)
+{
+	return 0;
+}
+
+static inline int security_socket_accept(struct socket * sock, 
+					 struct socket * newsock)
+{
+	return 0;
+}
+
+static inline void security_socket_post_accept(struct socket * sock, 
+					       struct socket * newsock)
+{
+}
+
+static inline int security_socket_sendmsg(struct socket * sock, 
+					  struct msghdr * msg, int size)
+{
+	return 0;
+}
+
+static inline int security_socket_recvmsg(struct socket * sock, 
+					  struct msghdr * msg, int size, 
+					  int flags)
+{
+	return 0;
+}
+
+static inline int security_socket_getsockname(struct socket * sock)
+{
+	return 0;
+}
+
+static inline int security_socket_getpeername(struct socket * sock)
+{
+	return 0;
+}
+
+static inline int security_socket_getsockopt(struct socket * sock, 
+					     int level, int optname)
+{
+	return 0;
+}
+
+static inline int security_socket_setsockopt(struct socket * sock, 
+					     int level, int optname)
+{
+	return 0;
+}
+
+static inline int security_socket_shutdown(struct socket * sock, int how)
+{
+	return 0;
+}
+
+static inline int security_sock_alloc(struct sock * sk, 
+				      int gfp_mask)
+{
+	return 0;
+}
+
+static inline void security_sock_free(struct sock * sk)
+{
+}
+
+static inline int security_sock_rcv_skb (struct sock * sk, 
+					 struct sk_buff * skb)
+{
+	return 0;
+}
+
 static inline int security_skb_alloc(struct sk_buff * skb, int gfp_mask)
 {
 	return 0;
diff -urN -X dontdiff linux-2.5.59.w0/include/net/sock.h linux-2.5.59.w1/include/net/sock.h
--- linux-2.5.59.w0/include/net/sock.h	Thu Jan 30 21:31:15 2003
+++ linux-2.5.59.w1/include/net/sock.h	Thu Jan 30 21:31:32 2003
@@ -197,7 +197,12 @@
 
 	/* RPC layer private data */
 	void			*user_data;
-  
+
+#ifdef CONFIG_SECURITY_NETWORK
+	/* LSM security field */
+	void                    *security;
+#endif 
+
 	/* Callbacks */
 	void			(*state_change)(struct sock *sk);
 	void			(*data_ready)(struct sock *sk,int bytes);
@@ -714,15 +719,20 @@
 
 static inline int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
+	int err = 0;
+
 	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
 	   number of warnings when compiling with -W --ANK
 	 */
 	if (atomic_read(&sk->rmem_alloc) + skb->truesize >= (unsigned)sk->rcvbuf)
                 return -ENOMEM;
 
+	err = security_sock_rcv_skb(sk, skb);
+	if (err)
+		return err;
+
 #ifdef CONFIG_FILTER
 	if (sk->filter) {
-		int err = 0;
 		struct sk_filter *filter;
 
 		/* It would be deadlock, if sock_queue_rcv_skb is used
diff -urN -X dontdiff linux-2.5.59.w0/net/core/sock.c linux-2.5.59.w1/net/core/sock.c
--- linux-2.5.59.w0/net/core/sock.c	Sat Oct 19 19:57:49 2002
+++ linux-2.5.59.w1/net/core/sock.c	Thu Jan 30 21:31:32 2003
@@ -109,6 +109,7 @@
 #include <linux/poll.h>
 #include <linux/tcp.h>
 #include <linux/init.h>
+#include <linux/security.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -600,6 +601,10 @@
 			sk->family = family;
 			sock_lock_init(sk);
 		}
+		if (security_sock_alloc(sk, priority)) {
+			kmem_cache_free(slab, sk);
+			return NULL;
+		}
 		sk->slab = slab;
 	}
 
@@ -626,6 +631,7 @@
 	if (atomic_read(&sk->omem_alloc))
 		printk(KERN_DEBUG "sk_free: optmem leakage (%d bytes) detected.\n", atomic_read(&sk->omem_alloc));
 
+	security_sock_free(sk);
 	kmem_cache_free(sk->slab, sk);
 }
 
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/tcp_ipv4.c linux-2.5.59.w1/net/ipv4/tcp_ipv4.c
--- linux-2.5.59.w0/net/ipv4/tcp_ipv4.c	Thu Jan 16 22:51:35 2003
+++ linux-2.5.59.w1/net/ipv4/tcp_ipv4.c	Thu Jan 30 21:31:32 2003
@@ -71,6 +71,7 @@
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/security.h>
 
 extern int sysctl_ip_dynaddr;
 extern int sysctl_ip_default_ttl;
@@ -1798,6 +1799,9 @@
 		goto no_tcp_socket;
 
 process:
+	if (security_sock_rcv_skb(sk, skb))
+		goto discard_and_relse;
+
 	if (sk->state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
diff -urN -X dontdiff linux-2.5.59.w0/net/socket.c linux-2.5.59.w1/net/socket.c
--- linux-2.5.59.w0/net/socket.c	Thu Jan  9 16:08:27 2003
+++ linux-2.5.59.w1/net/socket.c	Thu Jan 30 21:31:32 2003
@@ -77,6 +77,7 @@
 #include <linux/highmem.h>
 #include <linux/divert.h>
 #include <linux/mount.h>
+#include <linux/security.h>
 
 #if defined(CONFIG_KMOD) && defined(CONFIG_NET)
 #include <linux/kmod.h>
@@ -527,6 +528,10 @@
 	si->msg = msg;
 	si->size = size;
 
+	err = security_socket_sendmsg(sock, msg, size);
+	if (err)
+		return err;
+
 	err = scm_send(sock, msg, si->scm);
 	if (err >= 0) {
 		err = sock->ops->sendmsg(iocb, sock, msg, size, si->scm);
@@ -551,6 +556,7 @@
 
 int __sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size, int flags)
 {
+	int err;
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
 	si->sock = sock;
@@ -560,6 +566,10 @@
 	si->size = size;
 	si->flags = flags;
 
+	err = security_socket_recvmsg(sock, msg, size, flags);
+	if (err)
+		return err;
+
 	memset(si->scm, 0, sizeof(*si->scm));
 
 	size = sock->ops->recvmsg(iocb, sock, msg, size, flags, si->scm);
@@ -963,6 +973,7 @@
 int sock_create(int family, int type, int protocol, struct socket **res)
 {
 	int i;
+	int err;
 	struct socket *sock;
 
 	/*
@@ -986,6 +997,10 @@
 		}
 		family = PF_PACKET;
 	}
+
+	err = security_socket_create(family, type, protocol);
+	if (err)
+		return err;
 		
 #if defined(CONFIG_KMOD) && defined(CONFIG_NET)
 	/* Attempt to load a protocol module if the find failed. 
@@ -1031,6 +1046,7 @@
 	}
 
 	*res = sock;
+	security_socket_post_create(sock, family, type, protocol);
 
 out:
 	net_family_read_unlock();
@@ -1141,8 +1157,14 @@
 
 	if((sock = sockfd_lookup(fd,&err))!=NULL)
 	{
-		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0)
+		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0) {
+			err = security_socket_bind(sock, (struct sockaddr *)address, addrlen);
+			if (err) {
+				sockfd_put(sock);
+				return err;
+			}
 			err = sock->ops->bind(sock, (struct sockaddr *)address, addrlen);
+		}
 		sockfd_put(sock);
 	}			
 	return err;
@@ -1163,6 +1185,13 @@
 	if ((sock = sockfd_lookup(fd, &err)) != NULL) {
 		if ((unsigned) backlog > SOMAXCONN)
 			backlog = SOMAXCONN;
+
+		err = security_socket_listen(sock, backlog);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		err=sock->ops->listen(sock, backlog);
 		sockfd_put(sock);
 	}
@@ -1199,6 +1228,10 @@
 	newsock->type = sock->type;
 	newsock->ops = sock->ops;
 
+	err = security_socket_accept(sock, newsock);
+	if (err)
+		goto out_release;
+
 	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
 	if (err < 0)
 		goto out_release;
@@ -1218,6 +1251,8 @@
 	if ((err = sock_map_fd(newsock)) < 0)
 		goto out_release;
 
+	security_socket_post_accept(sock, newsock);
+
 out_put:
 	sockfd_put(sock);
 out:
@@ -1253,6 +1288,11 @@
 	err = move_addr_to_kernel(uservaddr, addrlen, address);
 	if (err < 0)
 		goto out_put;
+
+	err = security_socket_connect(sock, (struct sockaddr *)address, addrlen);
+	if (err)
+		goto out_put;
+
 	err = sock->ops->connect(sock, (struct sockaddr *) address, addrlen,
 				 sock->file->f_flags);
 out_put:
@@ -1275,6 +1315,11 @@
 	sock = sockfd_lookup(fd, &err);
 	if (!sock)
 		goto out;
+
+	err = security_socket_getsockname(sock);
+	if (err)
+		goto out_put;
+
 	err = sock->ops->getname(sock, (struct sockaddr *)address, &len, 0);
 	if (err)
 		goto out_put;
@@ -1299,6 +1344,12 @@
 
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_socket_getpeername(sock);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		err = sock->ops->getname(sock, (struct sockaddr *)address, &len, 1);
 		if (!err)
 			err=move_addr_to_user(address,len, usockaddr, usockaddr_len);
@@ -1427,6 +1478,12 @@
 			
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_socket_setsockopt(sock,level,optname);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		if (level == SOL_SOCKET)
 			err=sock_setsockopt(sock,level,optname,optval,optlen);
 		else
@@ -1448,6 +1505,13 @@
 
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_socket_getsockopt(sock, level, 
+							   optname);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		if (level == SOL_SOCKET)
 			err=sock_getsockopt(sock,level,optname,optval,optlen);
 		else
@@ -1469,6 +1533,12 @@
 
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_socket_shutdown(sock, how);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+				
 		err=sock->ops->shutdown(sock, how);
 		sockfd_put(sock);
 	}
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Thu Jan 30 21:31:15 2003
+++ linux-2.5.59.w1/security/dummy.c	Thu Jan 30 21:31:32 2003
@@ -20,7 +20,7 @@
 #include <linux/security.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
-
+#include <net/sock.h>
 
 static int dummy_ptrace (struct task_struct *parent, struct task_struct *child)
 {
@@ -599,6 +599,98 @@
 
 #ifdef CONFIG_SECURITY_NETWORK
 
+static int dummy_socket_create (int family, int type, int protocol)
+{
+	return 0;
+}
+
+static void dummy_socket_post_create (struct socket *sock, int family, int type,
+				      int protocol)
+{
+	return;
+}
+
+static int dummy_socket_bind (struct socket *sock, struct sockaddr *address,
+			      int addrlen)
+{
+	return 0;
+}
+
+static int dummy_socket_connect (struct socket *sock, struct sockaddr *address,
+				 int addrlen)
+{
+	return 0;
+}
+
+static int dummy_socket_listen (struct socket *sock, int backlog)
+{
+	return 0;
+}
+
+static int dummy_socket_accept (struct socket *sock, struct socket *newsock)
+{
+	return 0;
+}
+
+static void dummy_socket_post_accept (struct socket *sock, 
+				      struct socket *newsock)
+{
+	return;
+}
+
+static int dummy_socket_sendmsg (struct socket *sock, struct msghdr *msg,
+				 int size)
+{
+	return 0;
+}
+
+static int dummy_socket_recvmsg (struct socket *sock, struct msghdr *msg,
+				 int size, int flags)
+{
+	return 0;
+}
+
+static int dummy_socket_getsockname (struct socket *sock)
+{
+	return 0;
+}
+
+static int dummy_socket_getpeername (struct socket *sock)
+{
+	return 0;
+}
+
+static int dummy_socket_setsockopt (struct socket *sock, int level, int optname)
+{
+	return 0;
+}
+
+static int dummy_socket_getsockopt (struct socket *sock, int level, int optname)
+{
+	return 0;
+}
+
+static int dummy_socket_shutdown (struct socket *sock, int how)
+{
+	return 0;
+}
+
+static int dummy_socket_sock_alloc_security(struct sock *sk, int gfp_mask)
+{
+	sk->security = NULL;
+	return 0;
+}
+
+static void dummy_socket_sock_free_security(struct sock *sk)
+{
+	return;
+}
+
+static int dummy_socket_sock_rcv_skb (struct sock *sk, struct sk_buff *skb)
+{
+	return 0;
+}
+
 static int dummy_skb_alloc_security (struct sk_buff *skb, int gfp_mask)
 {
 	return 0;
@@ -768,6 +860,23 @@
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
 #ifdef CONFIG_SECURITY_NETWORK
+	set_to_dummy_if_null(ops, socket_create);
+	set_to_dummy_if_null(ops, socket_post_create);
+	set_to_dummy_if_null(ops, socket_bind);
+	set_to_dummy_if_null(ops, socket_connect);
+	set_to_dummy_if_null(ops, socket_listen);
+	set_to_dummy_if_null(ops, socket_accept);
+	set_to_dummy_if_null(ops, socket_post_accept);
+	set_to_dummy_if_null(ops, socket_sendmsg);
+	set_to_dummy_if_null(ops, socket_recvmsg);
+	set_to_dummy_if_null(ops, socket_getsockname);
+	set_to_dummy_if_null(ops, socket_getpeername);
+	set_to_dummy_if_null(ops, socket_setsockopt);
+	set_to_dummy_if_null(ops, socket_getsockopt);
+	set_to_dummy_if_null(ops, socket_shutdown);
+	set_to_dummy_if_null(ops, socket_sock_alloc_security);
+	set_to_dummy_if_null(ops, socket_sock_free_security);
+	set_to_dummy_if_null(ops, socket_sock_rcv_skb);
 	set_to_dummy_if_null(ops, skb_alloc_security);
 	set_to_dummy_if_null(ops, skb_clone);
 	set_to_dummy_if_null(ops, skb_copy);
