From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: socket hooks for 2.5.42 (3/7)
Date: Wed, 16 Oct 2002 00:37:14 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210160027370.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN -X dontdiff linux-2.5.42.w0/include/linux/security.h linux-2.5.42.w1/include/linux/security.h
--- linux-2.5.42.w0/include/linux/security.h	Tue Oct 15 20:35:19 2002
+++ linux-2.5.42.w1/include/linux/security.h	Tue Oct 15 20:45:30 2002
@@ -674,6 +674,126 @@
  * manage the lifecycle of security blobs for &sk_buff structures, and are not
  * intended to be used for access decisions.
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
  * @ptrace:
  *	Check permission before allowing the @parent process to trace the
  *	@child process.
@@ -900,6 +1020,30 @@
 	                           unsigned flags);
 	void (*skb_free_security) (struct sk_buff * skb);
 	
+	int (*socket_create) (int family, int type, int protocol);
+	void (*socket_post_create) (struct socket * sock, int family,
+	                            int type, int protocol);
+	int (*socket_bind) (struct socket * sock,
+	                    struct sockaddr * address, int addrlen);
+	int (*socket_connect) (struct socket * sock,
+	                       struct sockaddr * address, int addrlen);
+	int (*socket_listen) (struct socket * sock, int backlog);
+	int (*socket_accept) (struct socket * sock, struct socket * newsock);
+	void (*socket_post_accept) (struct socket * sock,
+	                            struct socket * newsock);
+	int (*socket_sendmsg) (struct socket * sock,
+	                       struct msghdr * msg, int size);
+	int (*socket_recvmsg) (struct socket * sock,
+	                       struct msghdr * msg, int size, int flags);
+	int (*socket_getsockname) (struct socket * sock);
+	int (*socket_getpeername) (struct socket * sock);
+	int (*socket_getsockopt) (struct socket * sock, int level, int optname);
+	int (*socket_setsockopt) (struct socket * sock, int level, int optname);
+	int (*socket_shutdown) (struct socket * sock, int how);
+	int (*socket_sock_alloc_security) (struct sock * sk, int gfp_mask);
+	void (*socket_sock_free_security) (struct sock * sk);
+	int (*socket_sock_rcv_skb) (struct sock * sk, struct sk_buff * skb);
+
 	int (*ipc_permission) (struct kern_ipc_perm * ipcp, short flag);
 
 	int (*msg_queue_alloc_security) (struct msg_queue * msq);
diff -urN -X dontdiff linux-2.5.42.w0/include/net/sock.h linux-2.5.42.w1/include/net/sock.h
--- linux-2.5.42.w0/include/net/sock.h	Tue Oct 15 20:35:19 2002
+++ linux-2.5.42.w1/include/net/sock.h	Tue Oct 15 20:36:51 2002
@@ -194,7 +194,10 @@
 
 	/* RPC layer private data */
 	void			*user_data;
-  
+	
+	/* LSM security field */
+	void                    *security;
+
 	/* Callbacks */
 	void			(*state_change)(struct sock *sk);
 	void			(*data_ready)(struct sock *sk,int bytes);
@@ -675,15 +678,20 @@
 
 static inline int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
+	int err = 0;
+
 	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
 	   number of warnings when compiling with -W --ANK
 	 */
 	if (atomic_read(&sk->rmem_alloc) + skb->truesize >= (unsigned)sk->rcvbuf)
                 return -ENOMEM;
 
+	err = security_ops->socket_sock_rcv_skb(sk, skb);
+	if (err)
+		return err;
+
 #ifdef CONFIG_FILTER
 	if (sk->filter) {
-		int err = 0;
 		struct sk_filter *filter;
 
 		/* It would be deadlock, if sock_queue_rcv_skb is used
diff -urN -X dontdiff linux-2.5.42.w0/net/core/sock.c linux-2.5.42.w1/net/core/sock.c
--- linux-2.5.42.w0/net/core/sock.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/net/core/sock.c	Tue Oct 15 20:36:51 2002
@@ -600,6 +600,11 @@
 			sk->family = family;
 			sock_lock_init(sk);
 		}
+		sk->security = NULL;
+		if (security_ops->socket_sock_alloc_security(sk, priority)) {
+			kmem_cache_free(slab, sk);
+			return NULL;
+		}
 		sk->slab = slab;
 	}
 
@@ -626,6 +631,8 @@
 	if (atomic_read(&sk->omem_alloc))
 		printk(KERN_DEBUG "sk_free: optmem leakage (%d bytes) detected.\n", atomic_read(&sk->omem_alloc));
 
+	security_ops->socket_sock_free_security(sk);
+
 	kmem_cache_free(sk->slab, sk);
 }
 
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/tcp_ipv4.c linux-2.5.42.w1/net/ipv4/tcp_ipv4.c
--- linux-2.5.42.w0/net/ipv4/tcp_ipv4.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/net/ipv4/tcp_ipv4.c	Tue Oct 15 20:36:51 2002
@@ -1771,6 +1771,9 @@
 	if (!ipsec_sk_policy(sk, skb))
 		goto discard_and_relse;
 
+	if (security_ops->socket_sock_rcv_skb(sk, skb))
+		goto discard_and_relse;
+
 	if (sk->state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
diff -urN -X dontdiff linux-2.5.42.w0/net/socket.c linux-2.5.42.w1/net/socket.c
--- linux-2.5.42.w0/net/socket.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/net/socket.c	Tue Oct 15 20:36:51 2002
@@ -522,6 +522,10 @@
 	int err;
 	struct scm_cookie scm;
 
+	err = security_ops->socket_sendmsg(sock, msg, size);
+	if (err)
+		return err;
+
 	err = scm_send(sock, msg, &scm);
 	if (err >= 0) {
 		err = sock->ops->sendmsg(sock, msg, size, &scm);
@@ -533,6 +537,11 @@
 int sock_recvmsg(struct socket *sock, struct msghdr *msg, int size, int flags)
 {
 	struct scm_cookie scm;
+	int err;
+
+	err = security_ops->socket_recvmsg(sock, msg, size, flags);
+	if (err)
+		return err;
 
 	memset(&scm, 0, sizeof(scm));
 
@@ -867,6 +876,7 @@
 int sock_create(int family, int type, int protocol, struct socket **res)
 {
 	int i;
+	int err;
 	struct socket *sock;
 
 	/*
@@ -890,6 +900,10 @@
 		}
 		family = PF_PACKET;
 	}
+
+	err = security_ops->socket_create(family, type, protocol);
+	if (err)
+		return err;
 		
 #if defined(CONFIG_KMOD) && defined(CONFIG_NET)
 	/* Attempt to load a protocol module if the find failed. 
@@ -936,6 +950,8 @@
 
 	*res = sock;
 
+	security_ops->socket_post_create(sock, family, type, protocol);
+
 out:
 	net_family_read_unlock();
 	return i;
@@ -1045,8 +1061,14 @@
 
 	if((sock = sockfd_lookup(fd,&err))!=NULL)
 	{
-		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0)
+		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0) {
+			err = security_ops->socket_bind(sock, (struct sockaddr *)address, addrlen);
+			if (err) {
+				sockfd_put(sock);
+				return err;
+			}
 			err = sock->ops->bind(sock, (struct sockaddr *)address, addrlen);
+		}
 		sockfd_put(sock);
 	}			
 	return err;
@@ -1067,6 +1089,13 @@
 	if ((sock = sockfd_lookup(fd, &err)) != NULL) {
 		if ((unsigned) backlog > SOMAXCONN)
 			backlog = SOMAXCONN;
+
+		err = security_ops->socket_listen(sock, backlog);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		err=sock->ops->listen(sock, backlog);
 		sockfd_put(sock);
 	}
@@ -1103,6 +1132,10 @@
 	newsock->type = sock->type;
 	newsock->ops = sock->ops;
 
+	err = security_ops->socket_accept(sock, newsock);
+	if (err)
+		goto out_release;
+
 	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
 	if (err < 0)
 		goto out_release;
@@ -1122,6 +1155,8 @@
 	if ((err = sock_map_fd(newsock)) < 0)
 		goto out_release;
 
+	security_ops->socket_post_accept(sock, newsock);
+
 out_put:
 	sockfd_put(sock);
 out:
@@ -1157,8 +1192,14 @@
 	err = move_addr_to_kernel(uservaddr, addrlen, address);
 	if (err < 0)
 		goto out_put;
+
+	err = security_ops->socket_connect(sock, (struct sockaddr *)address, addrlen);
+	if (err)
+		goto out_put;
+
 	err = sock->ops->connect(sock, (struct sockaddr *) address, addrlen,
 				 sock->file->f_flags);
+
 out_put:
 	sockfd_put(sock);
 out:
@@ -1179,6 +1220,11 @@
 	sock = sockfd_lookup(fd, &err);
 	if (!sock)
 		goto out;
+
+	err = security_ops->socket_getsockname(sock);
+	if (err)
+		goto out_put;
+
 	err = sock->ops->getname(sock, (struct sockaddr *)address, &len, 0);
 	if (err)
 		goto out_put;
@@ -1203,6 +1249,12 @@
 
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_ops->socket_getpeername(sock);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		err = sock->ops->getname(sock, (struct sockaddr *)address, &len, 1);
 		if (!err)
 			err=move_addr_to_user(address,len, usockaddr, usockaddr_len);
@@ -1331,6 +1383,12 @@
 			
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_ops->socket_setsockopt(sock,level,optname);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		if (level == SOL_SOCKET)
 			err=sock_setsockopt(sock,level,optname,optval,optlen);
 		else
@@ -1352,6 +1410,13 @@
 
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_ops->socket_getsockopt(sock, level, 
+							   optname);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+
 		if (level == SOL_SOCKET)
 			err=sock_getsockopt(sock,level,optname,optval,optlen);
 		else
@@ -1373,6 +1438,12 @@
 
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
+		err = security_ops->socket_shutdown(sock, how);
+		if (err) {
+			sockfd_put(sock);
+			return err;
+		}
+				
 		err=sock->ops->shutdown(sock, how);
 		sockfd_put(sock);
 	}
diff -urN -X dontdiff linux-2.5.42.w0/security/capability.c linux-2.5.42.w1/security/capability.c
--- linux-2.5.42.w0/security/capability.c	Tue Oct 15 20:35:19 2002
+++ linux-2.5.42.w1/security/capability.c	Tue Oct 15 20:40:57 2002
@@ -750,6 +750,97 @@
 	return;
 }
 
+static int cap_socket_create (int family, int type, int protocol)
+{
+	return 0;
+}
+
+static void cap_socket_post_create (struct socket *sock, int family, int type,
+				    int protocol)
+{
+	return;
+}
+
+static int cap_socket_bind (struct socket *sock, struct sockaddr *address,
+			    int addrlen)
+{
+	return 0;
+}
+
+static int cap_socket_connect (struct socket *sock, struct sockaddr *address,
+			       int addrlen)
+{
+	return 0;
+}
+
+static int cap_socket_listen (struct socket *sock, int backlog)
+{
+	return 0;
+}
+
+static int cap_socket_accept (struct socket *sock, struct socket *newsock)
+{
+	return 0;
+}
+
+static void cap_socket_post_accept (struct socket *sock, 
+				    struct socket *newsock)
+{
+	return;
+}
+
+static int cap_socket_sendmsg (struct socket *sock, struct msghdr *msg,
+			       int size)
+{
+	return 0;
+}
+
+static int cap_socket_recvmsg (struct socket *sock, struct msghdr *msg,
+			       int size, int flags)
+{
+	return 0;
+}
+
+static int cap_socket_getsockname (struct socket *sock)
+{
+	return 0;
+}
+
+static int cap_socket_getpeername (struct socket *sock)
+{
+	return 0;
+}
+
+static int cap_socket_setsockopt (struct socket *sock, int level, int optname)
+{
+	return 0;
+}
+
+static int cap_socket_getsockopt (struct socket *sock, int level, int optname)
+{
+	return 0;
+}
+
+static int cap_socket_shutdown (struct socket *sock, int how)
+{
+	return 0;
+}
+
+static int cap_socket_sock_alloc_security(struct sock *sk, int gfp_mask)
+{
+	return 0;
+}
+
+static void cap_socket_sock_free_security(struct sock *sk)
+{
+	return;
+}
+
+static int cap_socket_sock_rcv_skb (struct sock *sk, struct sk_buff *skb)
+{
+	return 0;
+}
+
 static int cap_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -860,6 +951,24 @@
 	.skb_recv_datagram =		cap_skb_recv_datagram,
 	.skb_free_security =		cap_skb_free_security,
 
+	.socket_create =		cap_socket_create,
+	.socket_post_create =		cap_socket_post_create,
+	.socket_bind =			cap_socket_bind,
+	.socket_connect =		cap_socket_connect,
+	.socket_listen =		cap_socket_listen,
+	.socket_accept =		cap_socket_accept,
+	.socket_post_accept =		cap_socket_post_accept,
+	.socket_sendmsg =		cap_socket_sendmsg,
+	.socket_recvmsg =		cap_socket_recvmsg,
+	.socket_getsockname =		cap_socket_getsockname,
+	.socket_getpeername =		cap_socket_getpeername,
+	.socket_getsockopt =		cap_socket_getsockopt,
+	.socket_setsockopt =		cap_socket_setsockopt,
+	.socket_shutdown =		cap_socket_shutdown,
+	.socket_sock_alloc_security =	cap_socket_sock_alloc_security,
+	.socket_sock_free_security =	cap_socket_sock_free_security,
+	.socket_sock_rcv_skb =		cap_socket_sock_rcv_skb,
+
 	.ipc_permission =		cap_ipc_permission,
 
 	.msg_queue_alloc_security =	cap_msg_queue_alloc_security,
diff -urN -X dontdiff linux-2.5.42.w0/security/dummy.c linux-2.5.42.w1/security/dummy.c
--- linux-2.5.42.w0/security/dummy.c	Tue Oct 15 20:35:19 2002
+++ linux-2.5.42.w1/security/dummy.c	Tue Oct 15 20:55:06 2002
@@ -567,6 +567,97 @@
 	return;
 }
 
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
 static int dummy_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -677,6 +768,24 @@
 	.skb_recv_datagram =		dummy_skb_recv_datagram,
 	.skb_free_security =		dummy_skb_free_security,
 
+	.socket_create =		dummy_socket_create,
+	.socket_post_create =		dummy_socket_post_create,
+	.socket_bind =			dummy_socket_bind,
+	.socket_connect =		dummy_socket_connect,
+	.socket_listen =		dummy_socket_listen,
+	.socket_accept =		dummy_socket_accept,
+	.socket_post_accept =		dummy_socket_post_accept,
+	.socket_sendmsg =		dummy_socket_sendmsg,
+	.socket_recvmsg =		dummy_socket_recvmsg,
+	.socket_getsockname =		dummy_socket_getsockname,
+	.socket_getpeername =		dummy_socket_getpeername,
+	.socket_getsockopt =		dummy_socket_getsockopt,
+	.socket_setsockopt =		dummy_socket_setsockopt,
+	.socket_shutdown =		dummy_socket_shutdown,
+	.socket_sock_alloc_security =	dummy_socket_sock_alloc_security,
+	.socket_sock_free_security =	dummy_socket_sock_free_security,
+	.socket_sock_rcv_skb =		dummy_socket_sock_rcv_skb,
+
 	.ipc_permission =		dummy_ipc_permission,
 	
 	.msg_queue_alloc_security =	dummy_msg_queue_alloc_security,
