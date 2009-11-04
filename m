From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 2/3] net: pass kern to net_proto_family create function
Date: Wed, 04 Nov 2009 11:32:17 -0500
Message-ID: <20091104163217.27133.6899.stgit@paris.rdu.redhat.com>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, acme@redhat.com, dwalsh@redhat.com,
	davem@davemloft.net, linux-security-module@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757220AbZKDQcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 11:32:14 -0500
In-Reply-To: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The generic __sock_create function has a kern argument which allows the
security system to make decisions based on if a socket is being created by
the kernel or by userspace.  This patch passes that flag to the
net_proto_family specific create function, so it can do the same thing.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 drivers/isdn/mISDN/socket.c    |    2 +-
 drivers/net/pppox.c            |    3 ++-
 include/linux/net.h            |    3 ++-
 net/appletalk/ddp.c            |    3 ++-
 net/atm/pvc.c                  |    3 ++-
 net/atm/svc.c                  |    3 ++-
 net/ax25/af_ax25.c             |    3 ++-
 net/bluetooth/af_bluetooth.c   |    3 ++-
 net/bluetooth/bnep/sock.c      |    3 ++-
 net/bluetooth/cmtp/sock.c      |    3 ++-
 net/bluetooth/hci_sock.c       |    3 ++-
 net/bluetooth/hidp/sock.c      |    3 ++-
 net/bluetooth/l2cap.c          |    3 ++-
 net/bluetooth/rfcomm/sock.c    |    3 ++-
 net/bluetooth/sco.c            |    3 ++-
 net/can/af_can.c               |    3 ++-
 net/decnet/af_decnet.c         |    3 ++-
 net/econet/af_econet.c         |    3 ++-
 net/ieee802154/af_ieee802154.c |    2 +-
 net/ipv4/af_inet.c             |    3 ++-
 net/ipv6/af_inet6.c            |    3 ++-
 net/ipx/af_ipx.c               |    3 ++-
 net/irda/af_irda.c             |    3 ++-
 net/iucv/af_iucv.c             |    3 ++-
 net/key/af_key.c               |    3 ++-
 net/llc/af_llc.c               |    5 ++++-
 net/netlink/af_netlink.c       |    3 ++-
 net/netrom/af_netrom.c         |    3 ++-
 net/packet/af_packet.c         |    3 ++-
 net/phonet/af_phonet.c         |    3 ++-
 net/rds/af_rds.c               |    3 ++-
 net/rose/af_rose.c             |    3 ++-
 net/rxrpc/af_rxrpc.c           |    3 ++-
 net/socket.c                   |    2 +-
 net/tipc/socket.c              |    4 +++-
 net/unix/af_unix.c             |    3 ++-
 net/x25/af_x25.c               |    3 ++-
 37 files changed, 74 insertions(+), 37 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 28182ed..fcfe17a 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -779,7 +779,7 @@ base_sock_create(struct net *net, struct socket *sock, int protocol)
 }
 
 static int
-mISDN_sock_create(struct net *net, struct socket *sock, int proto)
+mISDN_sock_create(struct net *net, struct socket *sock, int proto, int kern)
 {
 	int err = -EPROTONOSUPPORT;
 
diff --git a/drivers/net/pppox.c b/drivers/net/pppox.c
index c14ee24..ac806b2 100644
--- a/drivers/net/pppox.c
+++ b/drivers/net/pppox.c
@@ -104,7 +104,8 @@ int pppox_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 EXPORT_SYMBOL(pppox_ioctl);
 
-static int pppox_create(struct net *net, struct socket *sock, int protocol)
+static int pppox_create(struct net *net, struct socket *sock, int protocol,
+			int kern)
 {
 	int rc = -EPROTOTYPE;
 
diff --git a/include/linux/net.h b/include/linux/net.h
index 2158a87..2d0fb22 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -204,7 +204,8 @@ struct proto_ops {
 
 struct net_proto_family {
 	int		family;
-	int		(*create)(struct net *net, struct socket *sock, int protocol);
+	int		(*create)(struct net *net, struct socket *sock,
+				  int protocol, int kern);
 	struct module	*owner;
 };
 
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index abe3801..4b0ce2e 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1021,7 +1021,8 @@ static struct proto ddp_proto = {
  * Create a socket. Initialise the socket, blank the addresses
  * set the state.
  */
-static int atalk_create(struct net *net, struct socket *sock, int protocol)
+static int atalk_create(struct net *net, struct socket *sock, int protocol,
+			int kern)
 {
 	struct sock *sk;
 	int rc = -ESOCKTNOSUPPORT;
diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index a6e1fdb..8d74e62 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -127,7 +127,8 @@ static const struct proto_ops pvc_proto_ops = {
 };
 
 
-static int pvc_create(struct net *net, struct socket *sock,int protocol)
+static int pvc_create(struct net *net, struct socket *sock, int protocol,
+		      int kern)
 {
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 8193542..0438e13 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -650,7 +650,8 @@ static const struct proto_ops svc_proto_ops = {
 };
 
 
-static int svc_create(struct net *net, struct socket *sock,int protocol)
+static int svc_create(struct net *net, struct socket *sock, int protocol
+		      int kern)
 {
 	int error;
 
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index f1e998b..d6ddfa4 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -799,7 +799,8 @@ static struct proto ax25_proto = {
 	.obj_size = sizeof(struct sock),
 };
 
-static int ax25_create(struct net *net, struct socket *sock, int protocol)
+static int ax25_create(struct net *net, struct socket *sock, int protocol,
+		       int kern)
 {
 	struct sock *sk;
 	ax25_cb *ax25;
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 399e59c..62cbe0d 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -126,7 +126,8 @@ int bt_sock_unregister(int proto)
 }
 EXPORT_SYMBOL(bt_sock_unregister);
 
-static int bt_sock_create(struct net *net, struct socket *sock, int proto)
+static int bt_sock_create(struct net *net, struct socket *sock, int proto,
+			  int kern)
 {
 	int err;
 
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index 0a2c546..2ff6ac7 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -195,7 +195,8 @@ static struct proto bnep_proto = {
 	.obj_size	= sizeof(struct bt_sock)
 };
 
-static int bnep_sock_create(struct net *net, struct socket *sock, int protocol)
+static int bnep_sock_create(struct net *net, struct socket *sock, int protocol,
+			    int kern)
 {
 	struct sock *sk;
 
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index de7c804..978cc3a 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -190,7 +190,8 @@ static struct proto cmtp_proto = {
 	.obj_size	= sizeof(struct bt_sock)
 };
 
-static int cmtp_sock_create(struct net *net, struct socket *sock, int protocol)
+static int cmtp_sock_create(struct net *net, struct socket *sock, int protocol,
+			    int kern)
 {
 	struct sock *sk;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index e7395f2..1ca5c7c 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -621,7 +621,8 @@ static struct proto hci_sk_proto = {
 	.obj_size	= sizeof(struct hci_pinfo)
 };
 
-static int hci_sock_create(struct net *net, struct socket *sock, int protocol)
+static int hci_sock_create(struct net *net, struct socket *sock, int protocol,
+			   int kern)
 {
 	struct sock *sk;
 
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 4beb6a7..9cfef68 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -241,7 +241,8 @@ static struct proto hidp_proto = {
 	.obj_size	= sizeof(struct bt_sock)
 };
 
-static int hidp_sock_create(struct net *net, struct socket *sock, int protocol)
+static int hidp_sock_create(struct net *net, struct socket *sock, int protocol,
+			    int kern)
 {
 	struct sock *sk;
 
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index d65101d..365ae16 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -819,7 +819,8 @@ static struct sock *l2cap_sock_alloc(struct net *net, struct socket *sock, int p
 	return sk;
 }
 
-static int l2cap_sock_create(struct net *net, struct socket *sock, int protocol)
+static int l2cap_sock_create(struct net *net, struct socket *sock, int protocol,
+			     int kern)
 {
 	struct sock *sk;
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index d3bfc1b..4b5968d 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -323,7 +323,8 @@ static struct sock *rfcomm_sock_alloc(struct net *net, struct socket *sock, int
 	return sk;
 }
 
-static int rfcomm_sock_create(struct net *net, struct socket *sock, int protocol)
+static int rfcomm_sock_create(struct net *net, struct socket *sock,
+			      int protocol, int kern)
 {
 	struct sock *sk;
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 694a655..dd8f6ec 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -430,7 +430,8 @@ static struct sock *sco_sock_alloc(struct net *net, struct socket *sock, int pro
 	return sk;
 }
 
-static int sco_sock_create(struct net *net, struct socket *sock, int protocol)
+static int sco_sock_create(struct net *net, struct socket *sock, int protocol,
+			   int kern)
 {
 	struct sock *sk;
 
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 9c0426d..833bd83 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -114,7 +114,8 @@ static void can_sock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 }
 
-static int can_create(struct net *net, struct socket *sock, int protocol)
+static int can_create(struct net *net, struct socket *sock, int protocol,
+		      int kern)
 {
 	struct sock *sk;
 	struct can_proto *cp;
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 664965c..037299d 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -675,7 +675,8 @@ char *dn_addr2asc(__u16 addr, char *buf)
 
 
 
-static int dn_create(struct net *net, struct socket *sock, int protocol)
+static int dn_create(struct net *net, struct socket *sock, int protocol,
+		     int kern)
 {
 	struct sock *sk;
 
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 5e9426a..5966798 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -605,7 +605,8 @@ static struct proto econet_proto = {
  *	Create an Econet socket
  */
 
-static int econet_create(struct net *net, struct socket *sock, int protocol)
+static int econet_create(struct net *net, struct socket *sock, int protocol,
+			 int kern)
 {
 	struct sock *sk;
 	struct econet_sock *eo;
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 309348f..de6e34d 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -234,7 +234,7 @@ static const struct proto_ops ieee802154_dgram_ops = {
  * set the state.
  */
 static int ieee802154_create(struct net *net, struct socket *sock,
-		int protocol)
+			     int protocol, int kern)
 {
 	struct sock *sk;
 	int rc;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 180ec4c..5c7e42c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -262,7 +262,8 @@ static inline int inet_netns_ok(struct net *net, int protocol)
  *	Create an inet socket.
  */
 
-static int inet_create(struct net *net, struct socket *sock, int protocol)
+static int inet_create(struct net *net, struct socket *sock, int protocol,
+		       int kern)
 {
 	struct sock *sk;
 	struct inet_protosw *answer;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 1b38893..45ed5e0 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -95,7 +95,8 @@ static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 	return (struct ipv6_pinfo *)(((u8 *)sk) + offset);
 }
 
-static int inet6_create(struct net *net, struct socket *sock, int protocol)
+static int inet6_create(struct net *net, struct socket *sock, int protocol,
+			int kern)
 {
 	struct inet_sock *inet;
 	struct ipv6_pinfo *np;
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 6481ee4..96d193a 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1352,7 +1352,8 @@ static struct proto ipx_proto = {
 	.obj_size = sizeof(struct ipx_sock),
 };
 
-static int ipx_create(struct net *net, struct socket *sock, int protocol)
+static int ipx_create(struct net *net, struct socket *sock, int protocol,
+		      int kern)
 {
 	int rc = -ESOCKTNOSUPPORT;
 	struct sock *sk;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 9429e40..f304b3b 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1062,7 +1062,8 @@ static struct proto irda_proto = {
  *    Create IrDA socket
  *
  */
-static int irda_create(struct net *net, struct socket *sock, int protocol)
+static int irda_create(struct net *net, struct socket *sock, int protocol,
+		       int kern)
 {
 	struct sock *sk;
 	struct irda_sock *self;
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 3aebabb..1e42886 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -481,7 +481,8 @@ static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio)
 }
 
 /* Create an IUCV socket */
-static int iucv_sock_create(struct net *net, struct socket *sock, int protocol)
+static int iucv_sock_create(struct net *net, struct socket *sock, int protocol,
+			    int kern)
 {
 	struct sock *sk;
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 472f659..86b2c22 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -177,7 +177,8 @@ static struct proto key_proto = {
 	.obj_size = sizeof(struct pfkey_sock),
 };
 
-static int pfkey_create(struct net *net, struct socket *sock, int protocol)
+static int pfkey_create(struct net *net, struct socket *sock, int protocol,
+			int kern)
 {
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 	struct sock *sk;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 4866b4f..5266c28 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -140,14 +140,17 @@ static struct proto llc_proto = {
 
 /**
  *	llc_ui_create - alloc and init a new llc_ui socket
+ *	@net: network namespace (must be default network)
  *	@sock: Socket to initialize and attach allocated sk to.
  *	@protocol: Unused.
+ *	@kern: on behalf of kernel or userspace
  *
  *	Allocate and initialize a new llc_ui socket, validate the user wants a
  *	socket type we have available.
  *	Returns 0 upon success, negative upon failure.
  */
-static int llc_ui_create(struct net *net, struct socket *sock, int protocol)
+static int llc_ui_create(struct net *net, struct socket *sock, int protocol,
+			 int kern)
 {
 	struct sock *sk;
 	int rc = -ESOCKTNOSUPPORT;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0cd2d88..aea805c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -428,7 +428,8 @@ static int __netlink_create(struct net *net, struct socket *sock,
 	return 0;
 }
 
-static int netlink_create(struct net *net, struct socket *sock, int protocol)
+static int netlink_create(struct net *net, struct socket *sock, int protocol,
+			  int kern)
 {
 	struct module *module = NULL;
 	struct mutex *cb_mutex;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 281fa59..4bdd569 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -425,7 +425,8 @@ static struct proto nr_proto = {
 	.obj_size = sizeof(struct nr_sock),
 };
 
-static int nr_create(struct net *net, struct socket *sock, int protocol)
+static int nr_create(struct net *net, struct socket *sock, int protocol,
+		     int kern)
 {
 	struct sock *sk;
 	struct nr_sock *nr;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 91d246d..3304caa 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1344,7 +1344,8 @@ static struct proto packet_proto = {
  *	Create a packet of type SOCK_PACKET.
  */
 
-static int packet_create(struct net *net, struct socket *sock, int protocol)
+static int packet_create(struct net *net, struct socket *sock, int protocol,
+			 int kern)
 {
 	struct sock *sk;
 	struct packet_sock *po;
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 66737aa..3bd1be6 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -60,7 +60,8 @@ static inline void phonet_proto_put(struct phonet_protocol *pp)
 
 /* protocol family functions */
 
-static int pn_socket_create(struct net *net, struct socket *sock, int protocol)
+static int pn_socket_create(struct net *net, struct socket *sock, int protocol,
+			    int kern)
 {
 	struct sock *sk;
 	struct pn_sock *pn;
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 2b978dc..e25d8d5 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -410,7 +410,8 @@ static int __rds_create(struct socket *sock, struct sock *sk, int protocol)
 	return 0;
 }
 
-static int rds_create(struct net *net, struct socket *sock, int protocol)
+static int rds_create(struct net *net, struct socket *sock, int protocol,
+		      int kern)
 {
 	struct sock *sk;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index c17734c..4de4287 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -512,7 +512,8 @@ static struct proto rose_proto = {
 	.obj_size = sizeof(struct rose_sock),
 };
 
-static int rose_create(struct net *net, struct socket *sock, int protocol)
+static int rose_create(struct net *net, struct socket *sock, int protocol,
+		       int kern)
 {
 	struct sock *sk;
 	struct rose_sock *rose;
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 6817c97..f978d02 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -608,7 +608,8 @@ static unsigned int rxrpc_poll(struct file *file, struct socket *sock,
 /*
  * create an RxRPC socket
  */
-static int rxrpc_create(struct net *net, struct socket *sock, int protocol)
+static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
+			int kern)
 {
 	struct rxrpc_sock *rx;
 	struct sock *sk;
diff --git a/net/socket.c b/net/socket.c
index 9dff31c..4f3e0f0 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1252,7 +1252,7 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
 	/* Now protected by module ref count */
 	rcu_read_unlock();
 
-	err = pf->create(net, sock, protocol);
+	err = pf->create(net, sock, protocol, kern);
 	if (err < 0)
 		goto out_module_put;
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e6d9abf..9da8698 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -177,6 +177,7 @@ static void reject_rx_queue(struct sock *sk)
  * @net: network namespace (must be default network)
  * @sock: pre-allocated socket structure
  * @protocol: protocol indicator (must be 0)
+ * @kern: caused by kernel or by userspace?
  *
  * This routine creates additional data structures used by the TIPC socket,
  * initializes them, and links them together.
@@ -184,7 +185,8 @@ static void reject_rx_queue(struct sock *sk)
  * Returns 0 on success, errno otherwise
  */
 
-static int tipc_create(struct net *net, struct socket *sock, int protocol)
+static int tipc_create(struct net *net, struct socket *sock, int protocol,
+		       int kern)
 {
 	const struct proto_ops *ops;
 	socket_state state;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3291902..178d3af 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -621,7 +621,8 @@ out:
 	return sk;
 }
 
-static int unix_create(struct net *net, struct socket *sock, int protocol)
+static int unix_create(struct net *net, struct socket *sock, int protocol,
+		       int kern)
 {
 	if (protocol && protocol != PF_UNIX)
 		return -EPROTONOSUPPORT;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index e19d811..38e235f 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -501,7 +501,8 @@ out:
 	return sk;
 }
 
-static int x25_create(struct net *net, struct socket *sock, int protocol)
+static int x25_create(struct net *net, struct socket *sock, int protocol,
+		      int kern)
 {
 	struct sock *sk;
 	struct x25_sock *x25;

