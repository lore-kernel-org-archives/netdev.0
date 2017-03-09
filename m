From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] net: Work around lockdep limitation in sockets that use
 sockets
Date: Thu, 09 Mar 2017 08:09:05 +0000
Message-ID: <148904694551.4893.14290556899372744780.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lockdep issues a circular dependency warning when AFS issues an operation
through AF_RXRPC from a context in which the VFS/VM holds the mmap_sem.

The theory lockdep comes up with is as follows:

 (1) If the pagefault handler decides it needs to read pages from AFS, it
     calls AFS with mmap_sem held and AFS begins an AF_RXRPC call, but
     creating a call requires the socket lock:

	mmap_sem must be taken before sk_lock-AF_RXRPC

 (2) afs_open_socket() opens an AF_RXRPC socket and binds it.  rxrpc_bind()
     binds the underlying UDP socket whilst holding its socket lock.
     inet_bind() takes its own socket lock:

	sk_lock-AF_RXRPC must be taken before sk_lock-AF_INET

 (3) Reading from a TCP socket into a userspace buffer might cause a fault
     and thus cause the kernel to take the mmap_sem, but the TCP socket is
     locked whilst doing this:

	sk_lock-AF_INET must be taken before mmap_sem

However, lockdep's theory is wrong in this instance because it deals only
with lock classes and not individual locks.  The AF_INET lock in (2) isn't
really equivalent to the AF_INET lock in (3) as the former deals with a
socket entirely internal to the kernel that never sees userspace.  This is
a limitation in the design of lockdep.

Fix the general case by:

 (1) Double up all the locking keys used in sockets so that one set are
     used if the socket is created by userspace and the other set is used
     if the socket is created by the kernel.

 (2) Store the kern parameter passed to sk_alloc() in a variable in the
     sock struct (sk_kern_sock).  This informs sock_lock_init(),
     sock_init_data() and sk_clone_lock() as to the lock keys to be used.

     Note that the child created by sk_clone_lock() inherits the parent's
     kern setting.

 (3) Add a 'kern' parameter to ->accept() that is analogous to the one
     passed in to ->create() that distinguishes whether kernel_accept() or
     sys_accept4() was the caller and can be passed to sk_alloc().

     Note that a lot of accept functions merely dequeue an already
     allocated socket.  I haven't touched these as the new socket already
     exists before we get the parameter.

     Note also that there are a couple of places where I've made the accepted
     socket unconditionally kernel-based:

	irda_accept()
	rds_rcp_accept_one()
	tcp_accept_from_sock()

     because they follow a sock_create_kern() and accept off of that.

Whilst creating this, I noticed that lustre and ocfs don't create sockets
through sock_create_kern() and thus they aren't marked as for-kernel,
though they appear to be internal.  I wonder if these should do that so
that they use the new set of lock keys.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 crypto/af_alg.c                               |    9 +-
 crypto/algif_hash.c                           |    9 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c |    4 -
 fs/dlm/lowcomms.c                             |    2 
 fs/ocfs2/cluster/tcp.c                        |    2 
 include/crypto/if_alg.h                       |    2 
 include/linux/net.h                           |    2 
 include/net/inet_common.h                     |    3 -
 include/net/inet_connection_sock.h            |    2 
 include/net/sctp/structs.h                    |    3 -
 include/net/sock.h                            |    9 +-
 net/atm/svc.c                                 |    5 +
 net/ax25/af_ax25.c                            |    3 -
 net/bluetooth/l2cap_sock.c                    |    2 
 net/bluetooth/rfcomm/sock.c                   |    3 -
 net/bluetooth/sco.c                           |    2 
 net/core/sock.c                               |  106 +++++++++++++------------
 net/decnet/af_decnet.c                        |    5 +
 net/ipv4/af_inet.c                            |    5 +
 net/ipv4/inet_connection_sock.c               |    2 
 net/irda/af_irda.c                            |    5 +
 net/iucv/af_iucv.c                            |    2 
 net/llc/af_llc.c                              |    4 +
 net/netrom/af_netrom.c                        |    3 -
 net/nfc/llcp_sock.c                           |    2 
 net/phonet/pep.c                              |    6 +
 net/phonet/socket.c                           |    4 -
 net/rds/tcp_listen.c                          |    2 
 net/rose/af_rose.c                            |    3 -
 net/sctp/ipv6.c                               |    5 +
 net/sctp/protocol.c                           |    5 +
 net/sctp/socket.c                             |    4 -
 net/smc/af_smc.c                              |    2 
 net/socket.c                                  |    4 -
 net/tipc/socket.c                             |    8 +-
 net/unix/af_unix.c                            |    5 +
 net/vmw_vsock/af_vsock.c                      |    3 -
 net/x25/af_x25.c                              |    3 -
 38 files changed, 142 insertions(+), 108 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index f5e18c2a4852..690deca17c35 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -266,7 +266,7 @@ static int alg_setsockopt(struct socket *sock, int level, int optname,
 	return err;
 }
 
-int af_alg_accept(struct sock *sk, struct socket *newsock)
+int af_alg_accept(struct sock *sk, struct socket *newsock, bool kern)
 {
 	struct alg_sock *ask = alg_sk(sk);
 	const struct af_alg_type *type;
@@ -281,7 +281,7 @@ int af_alg_accept(struct sock *sk, struct socket *newsock)
 	if (!type)
 		goto unlock;
 
-	sk2 = sk_alloc(sock_net(sk), PF_ALG, GFP_KERNEL, &alg_proto, 0);
+	sk2 = sk_alloc(sock_net(sk), PF_ALG, GFP_KERNEL, &alg_proto, kern);
 	err = -ENOMEM;
 	if (!sk2)
 		goto unlock;
@@ -323,9 +323,10 @@ int af_alg_accept(struct sock *sk, struct socket *newsock)
 }
 EXPORT_SYMBOL_GPL(af_alg_accept);
 
-static int alg_accept(struct socket *sock, struct socket *newsock, int flags)
+static int alg_accept(struct socket *sock, struct socket *newsock, int flags,
+		      bool kern)
 {
-	return af_alg_accept(sock->sk, newsock);
+	return af_alg_accept(sock->sk, newsock, kern);
 }
 
 static const struct proto_ops alg_proto_ops = {
diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 54fc90e8339c..5e92bd275ef3 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -239,7 +239,8 @@ static int hash_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	return err ?: len;
 }
 
-static int hash_accept(struct socket *sock, struct socket *newsock, int flags)
+static int hash_accept(struct socket *sock, struct socket *newsock, int flags,
+		       bool kern)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
@@ -260,7 +261,7 @@ static int hash_accept(struct socket *sock, struct socket *newsock, int flags)
 	if (err)
 		return err;
 
-	err = af_alg_accept(ask->parent, newsock);
+	err = af_alg_accept(ask->parent, newsock, kern);
 	if (err)
 		return err;
 
@@ -378,7 +379,7 @@ static int hash_recvmsg_nokey(struct socket *sock, struct msghdr *msg,
 }
 
 static int hash_accept_nokey(struct socket *sock, struct socket *newsock,
-			     int flags)
+			     int flags, bool kern)
 {
 	int err;
 
@@ -386,7 +387,7 @@ static int hash_accept_nokey(struct socket *sock, struct socket *newsock,
 	if (err)
 		return err;
 
-	return hash_accept(sock, newsock, flags);
+	return hash_accept(sock, newsock, flags, kern);
 }
 
 static struct proto_ops algif_hash_ops_nokey = {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index b7b87ecefcdf..9fca8d225ee0 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -532,7 +532,7 @@ lnet_sock_accept(struct socket **newsockp, struct socket *sock)
 
 	newsock->ops = sock->ops;
 
-	rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
+	rc = sock->ops->accept(sock, newsock, O_NONBLOCK, false);
 	if (rc == -EAGAIN) {
 		/* Nothing ready, so wait for activity */
 		init_waitqueue_entry(&wait, current);
@@ -540,7 +540,7 @@ lnet_sock_accept(struct socket **newsockp, struct socket *sock)
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule();
 		remove_wait_queue(sk_sleep(sock->sk), &wait);
-		rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
+		rc = sock->ops->accept(sock, newsock, O_NONBLOCK, false);
 	}
 
 	if (rc)
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 7d398d300e97..9382db998ec9 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -743,7 +743,7 @@ static int tcp_accept_from_sock(struct connection *con)
 	newsock->type = con->sock->type;
 	newsock->ops = con->sock->ops;
 
-	result = con->sock->ops->accept(con->sock, newsock, O_NONBLOCK);
+	result = con->sock->ops->accept(con->sock, newsock, O_NONBLOCK, true);
 	if (result < 0)
 		goto accept_err;
 
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index 4348027384f5..d0ab7e56d0b4 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -1863,7 +1863,7 @@ static int o2net_accept_one(struct socket *sock, int *more)
 
 	new_sock->type = sock->type;
 	new_sock->ops = sock->ops;
-	ret = sock->ops->accept(sock, new_sock, O_NONBLOCK);
+	ret = sock->ops->accept(sock, new_sock, O_NONBLOCK, false);
 	if (ret < 0)
 		goto out;
 
diff --git a/include/crypto/if_alg.h b/include/crypto/if_alg.h
index a2bfd7843f18..e2b9c6fe2714 100644
--- a/include/crypto/if_alg.h
+++ b/include/crypto/if_alg.h
@@ -73,7 +73,7 @@ int af_alg_unregister_type(const struct af_alg_type *type);
 
 int af_alg_release(struct socket *sock);
 void af_alg_release_parent(struct sock *sk);
-int af_alg_accept(struct sock *sk, struct socket *newsock);
+int af_alg_accept(struct sock *sk, struct socket *newsock, bool kern);
 
 int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len);
 void af_alg_free_sg(struct af_alg_sgl *sgl);
diff --git a/include/linux/net.h b/include/linux/net.h
index cd0c8bd0a1de..0620f5e18c96 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -146,7 +146,7 @@ struct proto_ops {
 	int		(*socketpair)(struct socket *sock1,
 				      struct socket *sock2);
 	int		(*accept)    (struct socket *sock,
-				      struct socket *newsock, int flags);
+				      struct socket *newsock, int flags, bool kern);
 	int		(*getname)   (struct socket *sock,
 				      struct sockaddr *addr,
 				      int *sockaddr_len, int peer);
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index b7952d55b9c0..f39ae697347f 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -20,7 +20,8 @@ int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 			  int addr_len, int flags, int is_sendmsg);
 int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
 		       int addr_len, int flags);
-int inet_accept(struct socket *sock, struct socket *newsock, int flags);
+int inet_accept(struct socket *sock, struct socket *newsock, int flags,
+		bool kern);
 int inet_sendmsg(struct socket *sock, struct msghdr *msg, size_t size);
 ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 		      size_t size, int flags);
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 826f198374f8..c7a577976bec 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -258,7 +258,7 @@ inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
         return (unsigned long)min_t(u64, when, max_when);
 }
 
-struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
+struct sock *inet_csk_accept(struct sock *sk, int flags, int *err, bool kern);
 
 int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index a244db5e5ff7..07a0b128625a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -476,7 +476,8 @@ struct sctp_pf {
 	int  (*send_verify) (struct sctp_sock *, union sctp_addr *);
 	int  (*supported_addrs)(const struct sctp_sock *, __be16 *);
 	struct sock *(*create_accept_sk) (struct sock *sk,
-					  struct sctp_association *asoc);
+					  struct sctp_association *asoc,
+					  bool kern);
 	int (*addr_to_user)(struct sctp_sock *sk, union sctp_addr *addr);
 	void (*to_sk_saddr)(union sctp_addr *, struct sock *sk);
 	void (*to_sk_daddr)(union sctp_addr *, struct sock *sk);
diff --git a/include/net/sock.h b/include/net/sock.h
index 5e5997654db6..03252d53975d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -236,6 +236,7 @@ struct sock_common {
   *	@sk_shutdown: mask of %SEND_SHUTDOWN and/or %RCV_SHUTDOWN
   *	@sk_userlocks: %SO_SNDBUF and %SO_RCVBUF settings
   *	@sk_lock:	synchronizer
+  *	@sk_kern_sock: True if sock is using kernel lock classes
   *	@sk_rcvbuf: size of receive buffer in bytes
   *	@sk_wq: sock wait queue and async head
   *	@sk_rx_dst: receive input route used by early demux
@@ -430,7 +431,8 @@ struct sock {
 #endif
 
 	kmemcheck_bitfield_begin(flags);
-	unsigned int		sk_padding : 2,
+	unsigned int		sk_padding : 1,
+				sk_kern_sock : 1,
 				sk_no_check_tx : 1,
 				sk_no_check_rx : 1,
 				sk_userlocks : 4,
@@ -1015,7 +1017,8 @@ struct proto {
 					int addr_len);
 	int			(*disconnect)(struct sock *sk, int flags);
 
-	struct sock *		(*accept)(struct sock *sk, int flags, int *err);
+	struct sock *		(*accept)(struct sock *sk, int flags, int *err,
+					  bool kern);
 
 	int			(*ioctl)(struct sock *sk, int cmd,
 					 unsigned long arg);
@@ -1573,7 +1576,7 @@ int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 int sock_no_bind(struct socket *, struct sockaddr *, int);
 int sock_no_connect(struct socket *, struct sockaddr *, int, int);
 int sock_no_socketpair(struct socket *, struct socket *);
-int sock_no_accept(struct socket *, struct socket *, int);
+int sock_no_accept(struct socket *, struct socket *, int, bool);
 int sock_no_getname(struct socket *, struct sockaddr *, int *, int);
 unsigned int sock_no_poll(struct file *, struct socket *,
 			  struct poll_table_struct *);
diff --git a/net/atm/svc.c b/net/atm/svc.c
index db9794ec61d8..5589de7086af 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -318,7 +318,8 @@ static int svc_listen(struct socket *sock, int backlog)
 	return error;
 }
 
-static int svc_accept(struct socket *sock, struct socket *newsock, int flags)
+static int svc_accept(struct socket *sock, struct socket *newsock, int flags,
+		      bool kern)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -329,7 +330,7 @@ static int svc_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	lock_sock(sk);
 
-	error = svc_create(sock_net(sk), newsock, 0, 0);
+	error = svc_create(sock_net(sk), newsock, 0, kern);
 	if (error)
 		goto out;
 
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index a8e42cedf1db..b7c486752b3a 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1320,7 +1320,8 @@ static int __must_check ax25_connect(struct socket *sock,
 	return err;
 }
 
-static int ax25_accept(struct socket *sock, struct socket *newsock, int flags)
+static int ax25_accept(struct socket *sock, struct socket *newsock, int flags,
+		       bool kern)
 {
 	struct sk_buff *skb;
 	struct sock *newsk;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index f307b145ea54..507b80d59dec 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -301,7 +301,7 @@ static int l2cap_sock_listen(struct socket *sock, int backlog)
 }
 
 static int l2cap_sock_accept(struct socket *sock, struct socket *newsock,
-			     int flags)
+			     int flags, bool kern)
 {
 	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct sock *sk = sock->sk, *nsk;
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index aa1a814ceddc..ac3c650cb234 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -471,7 +471,8 @@ static int rfcomm_sock_listen(struct socket *sock, int backlog)
 	return err;
 }
 
-static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int flags)
+static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int flags,
+			      bool kern)
 {
 	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct sock *sk = sock->sk, *nsk;
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index e4e9a2da1e7e..728e0c8dc8e7 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -627,7 +627,7 @@ static int sco_sock_listen(struct socket *sock, int backlog)
 }
 
 static int sco_sock_accept(struct socket *sock, struct socket *newsock,
-			   int flags)
+			   int flags, bool kern)
 {
 	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct sock *sk = sock->sk, *ch;
diff --git a/net/core/sock.c b/net/core/sock.c
index f6fd79f33097..a96d5f7a5734 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -197,66 +197,55 @@ EXPORT_SYMBOL(sk_net_capable);
 
 /*
  * Each address family might have different locking rules, so we have
- * one slock key per address family:
+ * one slock key per address family and separate keys for internal and
+ * userspace sockets.
  */
 static struct lock_class_key af_family_keys[AF_MAX];
+static struct lock_class_key af_family_kern_keys[AF_MAX];
 static struct lock_class_key af_family_slock_keys[AF_MAX];
+static struct lock_class_key af_family_kern_slock_keys[AF_MAX];
 
 /*
  * Make lock validator output more readable. (we pre-construct these
  * strings build-time, so that runtime initialization of socket
  * locks is fast):
  */
+
+#define _sock_locks(x)						  \
+  x "AF_UNSPEC",	x "AF_UNIX"     ,	x "AF_INET"     , \
+  x "AF_AX25"  ,	x "AF_IPX"      ,	x "AF_APPLETALK", \
+  x "AF_NETROM",	x "AF_BRIDGE"   ,	x "AF_ATMPVC"   , \
+  x "AF_X25"   ,	x "AF_INET6"    ,	x "AF_ROSE"     , \
+  x "AF_DECnet",	x "AF_NETBEUI"  ,	x "AF_SECURITY" , \
+  x "AF_KEY"   ,	x "AF_NETLINK"  ,	x "AF_PACKET"   , \
+  x "AF_ASH"   ,	x "AF_ECONET"   ,	x "AF_ATMSVC"   , \
+  x "AF_RDS"   ,	x "AF_SNA"      ,	x "AF_IRDA"     , \
+  x "AF_PPPOX" ,	x "AF_WANPIPE"  ,	x "AF_LLC"      , \
+  x "27"       ,	x "28"          ,	x "AF_CAN"      , \
+  x "AF_TIPC"  ,	x "AF_BLUETOOTH",	x "IUCV"        , \
+  x "AF_RXRPC" ,	x "AF_ISDN"     ,	x "AF_PHONET"   , \
+  x "AF_IEEE802154",	x "AF_CAIF"	,	x "AF_ALG"      , \
+  x "AF_NFC"   ,	x "AF_VSOCK"    ,	x "AF_KCM"      , \
+  x "AF_QIPCRTR",	x "AF_SMC"	,	x "AF_MAX"
+
 static const char *const af_family_key_strings[AF_MAX+1] = {
-  "sk_lock-AF_UNSPEC", "sk_lock-AF_UNIX"     , "sk_lock-AF_INET"     ,
-  "sk_lock-AF_AX25"  , "sk_lock-AF_IPX"      , "sk_lock-AF_APPLETALK",
-  "sk_lock-AF_NETROM", "sk_lock-AF_BRIDGE"   , "sk_lock-AF_ATMPVC"   ,
-  "sk_lock-AF_X25"   , "sk_lock-AF_INET6"    , "sk_lock-AF_ROSE"     ,
-  "sk_lock-AF_DECnet", "sk_lock-AF_NETBEUI"  , "sk_lock-AF_SECURITY" ,
-  "sk_lock-AF_KEY"   , "sk_lock-AF_NETLINK"  , "sk_lock-AF_PACKET"   ,
-  "sk_lock-AF_ASH"   , "sk_lock-AF_ECONET"   , "sk_lock-AF_ATMSVC"   ,
-  "sk_lock-AF_RDS"   , "sk_lock-AF_SNA"      , "sk_lock-AF_IRDA"     ,
-  "sk_lock-AF_PPPOX" , "sk_lock-AF_WANPIPE"  , "sk_lock-AF_LLC"      ,
-  "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
-  "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
-  "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
-  "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
-  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_KCM"      ,
-  "sk_lock-AF_QIPCRTR", "sk_lock-AF_SMC"     , "sk_lock-AF_MAX"
+	_sock_locks("sk_lock-")
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
-  "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
-  "slock-AF_AX25"  , "slock-AF_IPX"      , "slock-AF_APPLETALK",
-  "slock-AF_NETROM", "slock-AF_BRIDGE"   , "slock-AF_ATMPVC"   ,
-  "slock-AF_X25"   , "slock-AF_INET6"    , "slock-AF_ROSE"     ,
-  "slock-AF_DECnet", "slock-AF_NETBEUI"  , "slock-AF_SECURITY" ,
-  "slock-AF_KEY"   , "slock-AF_NETLINK"  , "slock-AF_PACKET"   ,
-  "slock-AF_ASH"   , "slock-AF_ECONET"   , "slock-AF_ATMSVC"   ,
-  "slock-AF_RDS"   , "slock-AF_SNA"      , "slock-AF_IRDA"     ,
-  "slock-AF_PPPOX" , "slock-AF_WANPIPE"  , "slock-AF_LLC"      ,
-  "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
-  "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
-  "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
-  "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
-  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_KCM"       ,
-  "slock-AF_QIPCRTR", "slock-AF_SMC"     , "slock-AF_MAX"
+	_sock_locks("slock-")
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
-  "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
-  "clock-AF_AX25"  , "clock-AF_IPX"      , "clock-AF_APPLETALK",
-  "clock-AF_NETROM", "clock-AF_BRIDGE"   , "clock-AF_ATMPVC"   ,
-  "clock-AF_X25"   , "clock-AF_INET6"    , "clock-AF_ROSE"     ,
-  "clock-AF_DECnet", "clock-AF_NETBEUI"  , "clock-AF_SECURITY" ,
-  "clock-AF_KEY"   , "clock-AF_NETLINK"  , "clock-AF_PACKET"   ,
-  "clock-AF_ASH"   , "clock-AF_ECONET"   , "clock-AF_ATMSVC"   ,
-  "clock-AF_RDS"   , "clock-AF_SNA"      , "clock-AF_IRDA"     ,
-  "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
-  "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
-  "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
-  "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
-  "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
-  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
-  "clock-AF_QIPCRTR", "clock-AF_SMC"     , "clock-AF_MAX"
+	_sock_locks("clock-")
+};
+
+static const char *const af_family_kern_key_strings[AF_MAX+1] = {
+	_sock_locks("k-sk_lock-")
+};
+static const char *const af_family_kern_slock_key_strings[AF_MAX+1] = {
+	_sock_locks("k-slock-")
+};
+static const char *const af_family_kern_clock_key_strings[AF_MAX+1] = {
+	_sock_locks("k-clock-")
 };
 
 /*
@@ -264,6 +253,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
  * so split the lock classes by using a per-AF key:
  */
 static struct lock_class_key af_callback_keys[AF_MAX];
+static struct lock_class_key af_kern_callback_keys[AF_MAX];
 
 /* Take into consideration the size of the struct sk_buff overhead in the
  * determination of these values, since that is non-constant across
@@ -1293,7 +1283,16 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
  */
 static inline void sock_lock_init(struct sock *sk)
 {
-	sock_lock_init_class_and_name(sk,
+	if (sk->sk_kern_sock)
+		sock_lock_init_class_and_name(
+			sk,
+			af_family_kern_slock_key_strings[sk->sk_family],
+			af_family_kern_slock_keys + sk->sk_family,
+			af_family_kern_key_strings[sk->sk_family],
+			af_family_kern_keys + sk->sk_family);
+	else
+		sock_lock_init_class_and_name(
+			sk,
 			af_family_slock_key_strings[sk->sk_family],
 			af_family_slock_keys + sk->sk_family,
 			af_family_key_strings[sk->sk_family],
@@ -1399,6 +1398,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		 * why we need sk_prot_creator -acme
 		 */
 		sk->sk_prot = sk->sk_prot_creator = prot;
+		sk->sk_kern_sock = kern;
 		sock_lock_init(sk);
 		sk->sk_net_refcnt = kern ? 0 : 1;
 		if (likely(sk->sk_net_refcnt))
@@ -2277,7 +2277,8 @@ int sock_no_socketpair(struct socket *sock1, struct socket *sock2)
 }
 EXPORT_SYMBOL(sock_no_socketpair);
 
-int sock_no_accept(struct socket *sock, struct socket *newsock, int flags)
+int sock_no_accept(struct socket *sock, struct socket *newsock, int flags,
+		   bool kern)
 {
 	return -EOPNOTSUPP;
 }
@@ -2481,7 +2482,14 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	}
 
 	rwlock_init(&sk->sk_callback_lock);
-	lockdep_set_class_and_name(&sk->sk_callback_lock,
+	if (sk->sk_kern_sock)
+		lockdep_set_class_and_name(
+			&sk->sk_callback_lock,
+			af_kern_callback_keys + sk->sk_family,
+			af_family_kern_clock_key_strings[sk->sk_family]);
+	else
+		lockdep_set_class_and_name(
+			&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,
 			af_family_clock_key_strings[sk->sk_family]);
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index e6e79eda9763..7de5b40a5d0d 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1070,7 +1070,8 @@ static struct sk_buff *dn_wait_for_connect(struct sock *sk, long *timeo)
 	return skb == NULL ? ERR_PTR(err) : skb;
 }
 
-static int dn_accept(struct socket *sock, struct socket *newsock, int flags)
+static int dn_accept(struct socket *sock, struct socket *newsock, int flags,
+		     bool kern)
 {
 	struct sock *sk = sock->sk, *newsk;
 	struct sk_buff *skb = NULL;
@@ -1099,7 +1100,7 @@ static int dn_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	cb = DN_SKB_CB(skb);
 	sk->sk_ack_backlog--;
-	newsk = dn_alloc_sock(sock_net(sk), newsock, sk->sk_allocation, 0);
+	newsk = dn_alloc_sock(sock_net(sk), newsock, sk->sk_allocation, kern);
 	if (newsk == NULL) {
 		release_sock(sk);
 		kfree_skb(skb);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 602d40f43687..25d1f2b71070 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -689,11 +689,12 @@ EXPORT_SYMBOL(inet_stream_connect);
  *	Accept a pending connection. The TCP layer now gives BSD semantics.
  */
 
-int inet_accept(struct socket *sock, struct socket *newsock, int flags)
+int inet_accept(struct socket *sock, struct socket *newsock, int flags,
+		bool kern)
 {
 	struct sock *sk1 = sock->sk;
 	int err = -EINVAL;
-	struct sock *sk2 = sk1->sk_prot->accept(sk1, flags, &err);
+	struct sock *sk2 = sk1->sk_prot->accept(sk1, flags, &err, kern);
 
 	if (!sk2)
 		goto do_err;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index b4d5980ade3b..5e313c1ac94f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -424,7 +424,7 @@ static int inet_csk_wait_for_connect(struct sock *sk, long timeo)
 /*
  * This will accept the next outstanding connection.
  */
-struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
+struct sock *inet_csk_accept(struct sock *sk, int flags, int *err, bool kern)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 81adc29a448d..8d77ad5cadaf 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -828,7 +828,8 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
  *    Wait for incoming connection
  *
  */
-static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
+static int irda_accept(struct socket *sock, struct socket *newsock, int flags,
+		       bool kern)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *new, *self = irda_sk(sk);
@@ -836,7 +837,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sk_buff *skb = NULL;
 	int err;
 
-	err = irda_create(sock_net(sk), newsock, sk->sk_protocol, 0);
+	err = irda_create(sock_net(sk), newsock, sk->sk_protocol, kern);
 	if (err)
 		return err;
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 89bbde1081ce..84de7b6326dc 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -938,7 +938,7 @@ static int iucv_sock_listen(struct socket *sock, int backlog)
 
 /* Accept a pending connection */
 static int iucv_sock_accept(struct socket *sock, struct socket *newsock,
-			    int flags)
+			    int flags, bool kern)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	struct sock *sk = sock->sk, *nsk;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 06186d608a27..cb4fff785cbf 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -641,11 +641,13 @@ static void llc_cmsg_rcv(struct msghdr *msg, struct sk_buff *skb)
  *	@sock: Socket which connections arrive on.
  *	@newsock: Socket to move incoming connection to.
  *	@flags: User specified operational flags.
+ *	@kern: If the socket is kernel internal
  *
  *	Accept a new incoming connection.
  *	Returns 0 upon success, negative otherwise.
  */
-static int llc_ui_accept(struct socket *sock, struct socket *newsock, int flags)
+static int llc_ui_accept(struct socket *sock, struct socket *newsock, int flags,
+			 bool kern)
 {
 	struct sock *sk = sock->sk, *newsk;
 	struct llc_sock *llc, *newllc;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 4bbf4526b885..ebf16f7f9089 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -765,7 +765,8 @@ static int nr_connect(struct socket *sock, struct sockaddr *uaddr,
 	return err;
 }
 
-static int nr_accept(struct socket *sock, struct socket *newsock, int flags)
+static int nr_accept(struct socket *sock, struct socket *newsock, int flags,
+		     bool kern)
 {
 	struct sk_buff *skb;
 	struct sock *newsk;
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 879885b31cce..2ffb18e73df6 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -441,7 +441,7 @@ struct sock *nfc_llcp_accept_dequeue(struct sock *parent,
 }
 
 static int llcp_sock_accept(struct socket *sock, struct socket *newsock,
-			    int flags)
+			    int flags, bool kern)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	struct sock *sk = sock->sk, *new_sk;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 222bedcd9575..e81537991ddf 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -772,7 +772,8 @@ static void pep_sock_close(struct sock *sk, long timeout)
 	sock_put(sk);
 }
 
-static struct sock *pep_sock_accept(struct sock *sk, int flags, int *errp)
+static struct sock *pep_sock_accept(struct sock *sk, int flags, int *errp,
+				    bool kern)
 {
 	struct pep_sock *pn = pep_sk(sk), *newpn;
 	struct sock *newsk = NULL;
@@ -846,7 +847,8 @@ static struct sock *pep_sock_accept(struct sock *sk, int flags, int *errp)
 	}
 
 	/* Create a new to-be-accepted sock */
-	newsk = sk_alloc(sock_net(sk), PF_PHONET, GFP_KERNEL, sk->sk_prot, 0);
+	newsk = sk_alloc(sock_net(sk), PF_PHONET, GFP_KERNEL, sk->sk_prot,
+			 kern);
 	if (!newsk) {
 		pep_reject_conn(sk, skb, PN_PIPE_ERR_OVERLOAD, GFP_KERNEL);
 		err = -ENOBUFS;
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index a6c8da3ee893..64634e3ec2fc 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -305,7 +305,7 @@ static int pn_socket_connect(struct socket *sock, struct sockaddr *addr,
 }
 
 static int pn_socket_accept(struct socket *sock, struct socket *newsock,
-				int flags)
+			    int flags, bool kern)
 {
 	struct sock *sk = sock->sk;
 	struct sock *newsk;
@@ -314,7 +314,7 @@ static int pn_socket_accept(struct socket *sock, struct socket *newsock,
 	if (unlikely(sk->sk_state != TCP_LISTEN))
 		return -EINVAL;
 
-	newsk = sk->sk_prot->accept(sk, flags, &err);
+	newsk = sk->sk_prot->accept(sk, flags, &err, kern);
 	if (!newsk)
 		return err;
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 2c69a508a693..507678853e6c 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -133,7 +133,7 @@ int rds_tcp_accept_one(struct socket *sock)
 
 	new_sock->type = sock->type;
 	new_sock->ops = sock->ops;
-	ret = sock->ops->accept(sock, new_sock, O_NONBLOCK);
+	ret = sock->ops->accept(sock, new_sock, O_NONBLOCK, true);
 	if (ret < 0)
 		goto out;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index b8a1df2c9785..4a9729257023 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -871,7 +871,8 @@ static int rose_connect(struct socket *sock, struct sockaddr *uaddr, int addr_le
 	return err;
 }
 
-static int rose_accept(struct socket *sock, struct socket *newsock, int flags)
+static int rose_accept(struct socket *sock, struct socket *newsock, int flags,
+		       bool kern)
 {
 	struct sk_buff *skb;
 	struct sock *newsk;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 063baac5b9fe..961ee59f696a 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -640,14 +640,15 @@ static sctp_scope_t sctp_v6_scope(union sctp_addr *addr)
 
 /* Create and initialize a new sk for the socket to be returned by accept(). */
 static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
-					     struct sctp_association *asoc)
+					     struct sctp_association *asoc,
+					     bool kern)
 {
 	struct sock *newsk;
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
 	struct ipv6_txoptions *opt;
 
-	newsk = sk_alloc(sock_net(sk), PF_INET6, GFP_KERNEL, sk->sk_prot, 0);
+	newsk = sk_alloc(sock_net(sk), PF_INET6, GFP_KERNEL, sk->sk_prot, kern);
 	if (!newsk)
 		goto out;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 1b6d4574d2b0..989a900383b5 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -575,10 +575,11 @@ static int sctp_v4_is_ce(const struct sk_buff *skb)
 
 /* Create and initialize a new sk for the socket returned by accept(). */
 static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
-					     struct sctp_association *asoc)
+					     struct sctp_association *asoc,
+					     bool kern)
 {
 	struct sock *newsk = sk_alloc(sock_net(sk), PF_INET, GFP_KERNEL,
-			sk->sk_prot, 0);
+			sk->sk_prot, kern);
 	struct inet_sock *newinet;
 
 	if (!newsk)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6f0a9be50f50..0f378ea2ae38 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4116,7 +4116,7 @@ static int sctp_disconnect(struct sock *sk, int flags)
  * descriptor will be returned from accept() to represent the newly
  * formed association.
  */
-static struct sock *sctp_accept(struct sock *sk, int flags, int *err)
+static struct sock *sctp_accept(struct sock *sk, int flags, int *err, bool kern)
 {
 	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
@@ -4151,7 +4151,7 @@ static struct sock *sctp_accept(struct sock *sk, int flags, int *err)
 	 */
 	asoc = list_entry(ep->asocs.next, struct sctp_association, asocs);
 
-	newsk = sp->pf->create_accept_sk(sk, asoc);
+	newsk = sp->pf->create_accept_sk(sk, asoc, kern);
 	if (!newsk) {
 		error = -ENOMEM;
 		goto out;
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 85837ab90e89..093803786eac 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -944,7 +944,7 @@ static int smc_listen(struct socket *sock, int backlog)
 }
 
 static int smc_accept(struct socket *sock, struct socket *new_sock,
-		      int flags)
+		      int flags, bool kern)
 {
 	struct sock *sk = sock->sk, *nsk;
 	DECLARE_WAITQUEUE(wait, current);
diff --git a/net/socket.c b/net/socket.c
index 2c1e8677ff2d..16d7fb1d9951 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1506,7 +1506,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	if (err)
 		goto out_fd;
 
-	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
+	err = sock->ops->accept(sock, newsock, sock->file->f_flags, false);
 	if (err < 0)
 		goto out_fd;
 
@@ -3238,7 +3238,7 @@ int kernel_accept(struct socket *sock, struct socket **newsock, int flags)
 	if (err < 0)
 		goto done;
 
-	err = sock->ops->accept(sock, *newsock, flags);
+	err = sock->ops->accept(sock, *newsock, flags, true);
 	if (err < 0) {
 		sock_release(*newsock);
 		*newsock = NULL;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 43e4045e72bc..7130e73bd42c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -115,7 +115,8 @@ static void tipc_data_ready(struct sock *sk);
 static void tipc_write_space(struct sock *sk);
 static void tipc_sock_destruct(struct sock *sk);
 static int tipc_release(struct socket *sock);
-static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
+static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags,
+		       bool kern);
 static void tipc_sk_timeout(unsigned long data);
 static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 			   struct tipc_name_seq const *seq);
@@ -2029,7 +2030,8 @@ static int tipc_wait_for_accept(struct socket *sock, long timeo)
  *
  * Returns 0 on success, errno otherwise
  */
-static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
+static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags,
+		       bool kern)
 {
 	struct sock *new_sk, *sk = sock->sk;
 	struct sk_buff *buf;
@@ -2051,7 +2053,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	buf = skb_peek(&sk->sk_receive_queue);
 
-	res = tipc_sk_create(sock_net(sock->sk), new_sock, 0, 0);
+	res = tipc_sk_create(sock_net(sock->sk), new_sock, 0, kern);
 	if (res)
 		goto exit;
 	security_sk_clone(sock->sk, new_sock->sk);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ee37b390260a..928691c43408 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -636,7 +636,7 @@ static int unix_bind(struct socket *, struct sockaddr *, int);
 static int unix_stream_connect(struct socket *, struct sockaddr *,
 			       int addr_len, int flags);
 static int unix_socketpair(struct socket *, struct socket *);
-static int unix_accept(struct socket *, struct socket *, int);
+static int unix_accept(struct socket *, struct socket *, int, bool);
 static int unix_getname(struct socket *, struct sockaddr *, int *, int);
 static unsigned int unix_poll(struct file *, struct socket *, poll_table *);
 static unsigned int unix_dgram_poll(struct file *, struct socket *,
@@ -1402,7 +1402,8 @@ static void unix_sock_inherit_flags(const struct socket *old,
 		set_bit(SOCK_PASSSEC, &new->flags);
 }
 
-static int unix_accept(struct socket *sock, struct socket *newsock, int flags)
+static int unix_accept(struct socket *sock, struct socket *newsock, int flags,
+		       bool kern)
 {
 	struct sock *sk = sock->sk;
 	struct sock *tsk;
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 9192ead66751..9f770f33c100 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1250,7 +1250,8 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 	return err;
 }
 
-static int vsock_accept(struct socket *sock, struct socket *newsock, int flags)
+static int vsock_accept(struct socket *sock, struct socket *newsock, int flags,
+			bool kern)
 {
 	struct sock *listener;
 	int err;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index fd28a49dbe8f..8b911c29860e 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -852,7 +852,8 @@ static int x25_wait_for_data(struct sock *sk, long timeout)
 	return rc;
 }
 
-static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
+static int x25_accept(struct socket *sock, struct socket *newsock, int flags,
+		      bool kern)
 {
 	struct sock *sk = sock->sk;
 	struct sock *newsk;
