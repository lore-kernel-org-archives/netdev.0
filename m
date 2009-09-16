From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFCv4 PATCH 2/2] net: Allow protocols to provide an
	unlocked_recvmsg socket method
Date: Wed, 16 Sep 2009 14:07:45 -0300
Message-ID: <20090916170745.GD7699@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nir Tzachar <nir.tzachar@gmail.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbZIPRIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 13:08:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So thar recvmmsg can use it. With this patch recvmmsg actually _require=
s_ that
socket->ops->unlocked_recvmsg exists, and that socket->sk->sk_prot->unl=
ocked_recvmsg
is non NULL.

We may well switch back to the previous scheme where sys_recvmmsg check=
s if
the underlying protocol provides an unlocked version and uses it, falli=
ng
back to the locked version if there is none.

But first lets see if this works with recvmmsg alone and what kinds of =
gains we
get with the unlocked_recvmmsg implementation in UDP. Followup patches =
can
restore that behaviour if we want to use it with, say, DCCP and SCTP wi=
thout an
specific unlocked version.

This should address the concerns raised by R=E9mi about the MSG_UNLOCKE=
D problem.

Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
Cc: Chris Van Hoof <vanhoof@redhat.com>
Cc: Clark Williams <williams@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Nir Tzachar <nir.tzachar@gmail.com>
Cc: Nivedita Singhvi <niv@us.ibm.com>
Cc: Paul Moore <paul.moore@hp.com>
Cc: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Cc: Steven Whitehouse <steve@chygwyn.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/isdn/mISDN/socket.c    |    2 +
 drivers/net/pppoe.c            |    1 +
 drivers/net/pppol2tp.c         |    1 +
 include/linux/net.h            |    7 +++
 include/net/sock.h             |   13 +++++
 net/appletalk/ddp.c            |    1 +
 net/atm/pvc.c                  |    1 +
 net/atm/svc.c                  |    1 +
 net/ax25/af_ax25.c             |    1 +
 net/bluetooth/bnep/sock.c      |    1 +
 net/bluetooth/cmtp/sock.c      |    1 +
 net/bluetooth/hci_sock.c       |    1 +
 net/bluetooth/hidp/sock.c      |    1 +
 net/bluetooth/l2cap.c          |    1 +
 net/bluetooth/rfcomm/sock.c    |    1 +
 net/bluetooth/sco.c            |    1 +
 net/can/bcm.c                  |    1 +
 net/can/raw.c                  |    1 +
 net/core/sock.c                |   26 +++++++++
 net/dccp/ipv4.c                |    1 +
 net/dccp/ipv6.c                |    1 +
 net/decnet/af_decnet.c         |    1 +
 net/econet/af_econet.c         |    1 +
 net/ieee802154/af_ieee802154.c |    2 +
 net/ipv4/af_inet.c             |    3 +
 net/ipv4/udp.c                 |   52 +++++++++++++++---
 net/ipv6/af_inet6.c            |    2 +
 net/ipv6/raw.c                 |    1 +
 net/ipx/af_ipx.c               |    1 +
 net/irda/af_irda.c             |    4 ++
 net/iucv/af_iucv.c             |    1 +
 net/key/af_key.c               |    1 +
 net/llc/af_llc.c               |    1 +
 net/netlink/af_netlink.c       |    1 +
 net/netrom/af_netrom.c         |    1 +
 net/packet/af_packet.c         |    2 +
 net/phonet/socket.c            |    2 +
 net/rds/af_rds.c               |    1 +
 net/rose/af_rose.c             |    1 +
 net/rxrpc/af_rxrpc.c           |    1 +
 net/sctp/ipv6.c                |    1 +
 net/sctp/protocol.c            |    1 +
 net/socket.c                   |  112 ++++++++++++++++++++++++++++++++=
+++----
 net/tipc/socket.c              |    3 +
 net/unix/af_unix.c             |    3 +
 net/x25/af_x25.c               |    1 +
 46 files changed, 244 insertions(+), 21 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index c36f521..6da3a71 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -590,6 +590,7 @@ static const struct proto_ops data_sock_ops =3D {
 	.getname	=3D data_sock_getname,
 	.sendmsg	=3D mISDN_sock_sendmsg,
 	.recvmsg	=3D mISDN_sock_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D datagram_poll,
 	.listen		=3D sock_no_listen,
 	.shutdown	=3D sock_no_shutdown,
@@ -743,6 +744,7 @@ static const struct proto_ops base_sock_ops =3D {
 	.getname	=3D sock_no_getname,
 	.sendmsg	=3D sock_no_sendmsg,
 	.recvmsg	=3D sock_no_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D sock_no_poll,
 	.listen		=3D sock_no_listen,
 	.shutdown	=3D sock_no_shutdown,
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 7cbf6f9..cbcd3d5 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1121,6 +1121,7 @@ static const struct proto_ops pppoe_ops =3D {
 	.getsockopt	=3D sock_no_getsockopt,
 	.sendmsg	=3D pppoe_sendmsg,
 	.recvmsg	=3D pppoe_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.ioctl		=3D pppox_ioctl,
 };
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index e0f9219..af6160c 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2590,6 +2590,7 @@ static struct proto_ops pppol2tp_ops =3D {
 	.getsockopt	=3D pppol2tp_getsockopt,
 	.sendmsg	=3D pppol2tp_sendmsg,
 	.recvmsg	=3D pppol2tp_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.ioctl		=3D pppox_ioctl,
 };
diff --git a/include/linux/net.h b/include/linux/net.h
index d67587a..8b852de 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -186,6 +186,10 @@ struct proto_ops {
 	int		(*recvmsg)   (struct kiocb *iocb, struct socket *sock,
 				      struct msghdr *m, size_t total_len,
 				      int flags);
+	int		(*unlocked_recvmsg)(struct kiocb *iocb,
+					    struct socket *sock,
+					    struct msghdr *m,
+					    size_t total_len, int flags);
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
@@ -316,6 +320,8 @@ SOCKCALL_WRAP(name, sendmsg, (struct kiocb *iocb, s=
truct socket *sock, struct ms
 	      (iocb, sock, m, len)) \
 SOCKCALL_WRAP(name, recvmsg, (struct kiocb *iocb, struct socket *sock,=
 struct msghdr *m, size_t len, int flags), \
 	      (iocb, sock, m, len, flags)) \
+SOCKCALL_WRAP(name, unlocked_recvmsg, (struct kiocb *iocb, struct sock=
et *sock, struct msghdr *m, size_t len, int flags), \
+	      (iocb, sock, m, len, flags)) \
 SOCKCALL_WRAP(name, mmap, (struct file *file, struct socket *sock, str=
uct vm_area_struct *vma), \
 	      (file, sock, vma)) \
 	      \
@@ -337,6 +343,7 @@ static const struct proto_ops name##_ops =3D {			\
 	.getsockopt	=3D __lock_##name##_getsockopt,	\
 	.sendmsg	=3D __lock_##name##_sendmsg,	\
 	.recvmsg	=3D __lock_##name##_recvmsg,	\
+	.unlocked_recvmsg =3D __lock_##name##_unlocked_recvmsg,	\
 	.mmap		=3D __lock_##name##_mmap,		\
 };
=20
diff --git a/include/net/sock.h b/include/net/sock.h
index 950409d..7c62428 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -644,6 +644,11 @@ struct proto {
 					   struct msghdr *msg,
 					size_t len, int noblock, int flags,=20
 					int *addr_len);
+	int			(*unlocked_recvmsg)(struct kiocb *iocb,
+						    struct sock *sk,
+						    struct msghdr *msg,
+						    size_t len, int noblock,
+						    int flags, int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk,=20
@@ -998,6 +1003,11 @@ extern int                      sock_no_sendmsg(s=
truct kiocb *, struct socket *,
 						struct msghdr *, size_t);
 extern int                      sock_no_recvmsg(struct kiocb *, struct=
 socket *,
 						struct msghdr *, size_t, int);
+extern int			sock_no_unlocked_recvmsg(struct kiocb *iocb,
+							 struct socket *sock,
+							 struct msghdr *msg,
+							 size_t size,
+							 int flags);
 extern int			sock_no_mmap(struct file *file,
 					     struct socket *sock,
 					     struct vm_area_struct *vma);
@@ -1014,6 +1024,9 @@ extern int sock_common_getsockopt(struct socket *=
sock, int level, int optname,
 				  char __user *optval, int __user *optlen);
 extern int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock=
,
 			       struct msghdr *msg, size_t size, int flags);
+extern int sock_common_unlocked_recvmsg(struct kiocb *iocb, struct soc=
ket *sock,
+					struct msghdr *msg, size_t size,
+					int flags);
 extern int sock_common_setsockopt(struct socket *sock, int level, int =
optname,
 				  char __user *optval, int optlen);
 extern int compat_sock_common_getsockopt(struct socket *sock, int leve=
l,
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 4a6ff2b..bb2e1bb 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1847,6 +1847,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ata=
lk_dgram_ops) =3D {
 	.getsockopt	=3D sock_no_getsockopt,
 	.sendmsg	=3D atalk_sendmsg,
 	.recvmsg	=3D atalk_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage,
 };
diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index e1d22d9..5c03749 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -122,6 +122,7 @@ static const struct proto_ops pvc_proto_ops =3D {
 	.getsockopt =3D	pvc_getsockopt,
 	.sendmsg =3D	vcc_sendmsg,
 	.recvmsg =3D	vcc_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 7b831b5..6c66ae9 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -644,6 +644,7 @@ static const struct proto_ops svc_proto_ops =3D {
 	.setsockopt =3D	svc_setsockopt,
 	.getsockopt =3D	svc_getsockopt,
 	.sendmsg =3D	vcc_sendmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.recvmsg =3D	vcc_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index da0f64f..43f4f57 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1976,6 +1976,7 @@ static const struct proto_ops ax25_proto_ops =3D =
{
 	.getsockopt	=3D ax25_getsockopt,
 	.sendmsg	=3D ax25_sendmsg,
 	.recvmsg	=3D ax25_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage,
 };
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index e857628..0b26b3c 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -178,6 +178,7 @@ static const struct proto_ops bnep_sock_ops =3D {
 	.getname	=3D sock_no_getname,
 	.sendmsg	=3D sock_no_sendmsg,
 	.recvmsg	=3D sock_no_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D sock_no_poll,
 	.listen		=3D sock_no_listen,
 	.shutdown	=3D sock_no_shutdown,
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index 16b0fad..72a4b5d 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -173,6 +173,7 @@ static const struct proto_ops cmtp_sock_ops =3D {
 	.getname	=3D sock_no_getname,
 	.sendmsg	=3D sock_no_sendmsg,
 	.recvmsg	=3D sock_no_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D sock_no_poll,
 	.listen		=3D sock_no_listen,
 	.shutdown	=3D sock_no_shutdown,
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 4f9621f..bd0aace 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -603,6 +603,7 @@ static const struct proto_ops hci_sock_ops =3D {
 	.getname	=3D hci_sock_getname,
 	.sendmsg	=3D hci_sock_sendmsg,
 	.recvmsg	=3D hci_sock_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.ioctl		=3D hci_sock_ioctl,
 	.poll		=3D datagram_poll,
 	.listen		=3D sock_no_listen,
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 37c9d7d..90b40e2 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -224,6 +224,7 @@ static const struct proto_ops hidp_sock_ops =3D {
 	.getname	=3D sock_no_getname,
 	.sendmsg	=3D sock_no_sendmsg,
 	.recvmsg	=3D sock_no_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D sock_no_poll,
 	.listen		=3D sock_no_listen,
 	.shutdown	=3D sock_no_shutdown,
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index b030125..dc73bd4 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3907,6 +3907,7 @@ static const struct proto_ops l2cap_sock_ops =3D =
{
 	.getname	=3D l2cap_sock_getname,
 	.sendmsg	=3D l2cap_sock_sendmsg,
 	.recvmsg	=3D l2cap_sock_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D bt_sock_poll,
 	.ioctl		=3D bt_sock_ioctl,
 	.mmap		=3D sock_no_mmap,
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 0b85e81..00b1a41 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -1092,6 +1092,7 @@ static const struct proto_ops rfcomm_sock_ops =3D=
 {
 	.getname	=3D rfcomm_sock_getname,
 	.sendmsg	=3D rfcomm_sock_sendmsg,
 	.recvmsg	=3D rfcomm_sock_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.shutdown	=3D rfcomm_sock_shutdown,
 	.setsockopt	=3D rfcomm_sock_setsockopt,
 	.getsockopt	=3D rfcomm_sock_getsockopt,
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 13c27f1..fda79b8 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -984,6 +984,7 @@ static const struct proto_ops sco_sock_ops =3D {
 	.getname	=3D sco_sock_getname,
 	.sendmsg	=3D sco_sock_sendmsg,
 	.recvmsg	=3D bt_sock_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D bt_sock_poll,
 	.ioctl		=3D bt_sock_ioctl,
 	.mmap		=3D sock_no_mmap,
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 597da4f..e0aff9e 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1562,6 +1562,7 @@ static struct proto_ops bcm_ops __read_mostly =3D=
 {
 	.getsockopt    =3D sock_no_getsockopt,
 	.sendmsg       =3D bcm_sendmsg,
 	.recvmsg       =3D bcm_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap          =3D sock_no_mmap,
 	.sendpage      =3D sock_no_sendpage,
 };
diff --git a/net/can/raw.c b/net/can/raw.c
index db3152d..b8fa610 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -730,6 +730,7 @@ static struct proto_ops raw_ops __read_mostly =3D {
 	.getsockopt    =3D raw_getsockopt,
 	.sendmsg       =3D raw_sendmsg,
 	.recvmsg       =3D raw_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap          =3D sock_no_mmap,
 	.sendpage      =3D sock_no_sendpage,
 };
diff --git a/net/core/sock.c b/net/core/sock.c
index 30d5446..6ac86d4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1653,6 +1653,13 @@ int sock_no_connect(struct socket *sock, struct =
sockaddr *saddr,
 }
 EXPORT_SYMBOL(sock_no_connect);
=20
+int sock_no_unlocked_recvmsg(struct kiocb *iocb, struct socket *sock,
+			     struct msghdr *msg, size_t size, int flags)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL(sock_no_unlocked_recvmsg);
+
 int sock_no_socketpair(struct socket *sock1, struct socket *sock2)
 {
 	return -EOPNOTSUPP;
@@ -2014,6 +2021,25 @@ int sock_common_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
 }
 EXPORT_SYMBOL(sock_common_recvmsg);
=20
+int sock_common_unlocked_recvmsg(struct kiocb *iocb, struct socket *so=
ck,
+				 struct msghdr *msg, size_t size, int flags)
+{
+	struct sock *sk =3D sock->sk;
+	int addr_len =3D 0;
+	int err;
+
+	if (sk->sk_prot->unlocked_recvmsg =3D=3D NULL)
+		return -EOPNOTSUPP;
+
+	err =3D sk->sk_prot->unlocked_recvmsg(iocb, sk, msg, size,
+					    flags & MSG_DONTWAIT,
+					    flags & ~MSG_DONTWAIT, &addr_len);
+	if (err >=3D 0)
+		msg->msg_namelen =3D addr_len;
+	return err;
+}
+EXPORT_SYMBOL(sock_common_unlocked_recvmsg);
+
 /*
  *	Set socket options on an inet socket.
  */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d01c00d..e781f01 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -974,6 +974,7 @@ static const struct proto_ops inet_dccp_ops =3D {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D inet_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 64f011c..f530e37 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1175,6 +1175,7 @@ static struct proto_ops inet6_dccp_ops =3D {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D inet_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 77d4028..aa1af0b 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2348,6 +2348,7 @@ static const struct proto_ops dn_proto_ops =3D {
 	.getsockopt =3D	dn_getsockopt,
 	.sendmsg =3D	dn_sendmsg,
 	.recvmsg =3D	dn_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 0e0254f..7891aad 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -765,6 +765,7 @@ static const struct proto_ops econet_ops =3D {
 	.getsockopt =3D	sock_no_getsockopt,
 	.sendmsg =3D	econet_sendmsg,
 	.recvmsg =3D	econet_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802=
154.c
index cd949d5..98cf2be 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -195,6 +195,7 @@ static const struct proto_ops ieee802154_raw_ops =3D=
 {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D ieee802154_sock_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D sock_no_sendpage,
 #ifdef CONFIG_COMPAT
@@ -220,6 +221,7 @@ static const struct proto_ops ieee802154_dgram_ops =
=3D {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D ieee802154_sock_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6c30a73..4981d8e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -866,6 +866,7 @@ const struct proto_ops inet_stream_ops =3D {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D tcp_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D tcp_sendpage,
 	.splice_read	   =3D tcp_splice_read,
@@ -893,6 +894,7 @@ const struct proto_ops inet_dgram_ops =3D {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D inet_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_common_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D inet_sendpage,
 #ifdef CONFIG_COMPAT
@@ -923,6 +925,7 @@ static const struct proto_ops inet_sockraw_ops =3D =
{
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D inet_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D inet_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ebaaa7f..fcb34bd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -882,13 +882,34 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned =
long arg)
 }
 EXPORT_SYMBOL(udp_ioctl);
=20
+static void skb_free_datagram_locked(struct sock *sk, struct sk_buff *=
skb)
+{
+	lock_sock(sk);
+	skb_free_datagram(sk, skb);
+	release_sock(sk);
+}
+
+static int skb_kill_datagram_locked(struct sock *sk, struct sk_buff *s=
kb,
+                                   unsigned int flags)
+{
+	int ret;
+	lock_sock(sk);
+	ret =3D skb_kill_datagram(sk, skb, flags);
+	release_sock(sk);
+	return ret;
+}
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
  */
-
-int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *ms=
g,
-		size_t len, int noblock, int flags, int *addr_len)
+static int __udp_recvmsg(struct kiocb *iocb, struct sock *sk,
+			 struct msghdr *msg, size_t len, int noblock,
+			 int flags, int *addr_len,
+			 void (*free_datagram)(struct sock *,
+					       struct sk_buff *),
+			 int  (*kill_datagram)(struct sock *,
+					       struct sk_buff *, unsigned int))
 {
 	struct inet_sock *inet =3D inet_sk(sk);
 	struct sockaddr_in *sin =3D (struct sockaddr_in *)msg->msg_name;
@@ -967,23 +988,35 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	free_datagram(sk, skb);
 out:
 	return err;
=20
 csum_copy_err:
-	lock_sock(sk);
-	if (!skb_kill_datagram(sk, skb, flags))
+	if (!kill_datagram(sk, skb, flags))
 		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	release_sock(sk);
=20
 	if (noblock)
 		return -EAGAIN;
 	goto try_again;
 }
=20
+int udp_recvmsg(struct kiocb *iocb, struct sock *sk,
+		struct msghdr *msg, size_t len, int noblock,
+		int flags, int *addr_len)
+{
+	return __udp_recvmsg(iocb, sk, msg, len, noblock, flags, addr_len,
+			     skb_free_datagram_locked,
+			     skb_kill_datagram_locked);
+}
+
+int udp_unlocked_recvmsg(struct kiocb *iocb, struct sock *sk,
+			 struct msghdr *msg, size_t len, int noblock,
+			 int flags, int *addr_len)
+{
+	return __udp_recvmsg(iocb, sk, msg, len, noblock, flags, addr_len,
+			     skb_free_datagram, skb_kill_datagram);
+}
=20
 int udp_disconnect(struct sock *sk, int flags)
 {
@@ -1580,6 +1613,7 @@ struct proto udp_prot =3D {
 	.getsockopt	   =3D udp_getsockopt,
 	.sendmsg	   =3D udp_sendmsg,
 	.recvmsg	   =3D udp_recvmsg,
+	.unlocked_recvmsg  =3D udp_unlocked_recvmsg,
 	.sendpage	   =3D udp_sendpage,
 	.backlog_rcv	   =3D __udp_queue_rcv_skb,
 	.hash		   =3D udp_lib_hash,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a123a32..b72c518 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -518,6 +518,7 @@ const struct proto_ops inet6_stream_ops =3D {
 	.getsockopt	   =3D sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   =3D tcp_sendmsg,		/* ok		*/
 	.recvmsg	   =3D sock_common_recvmsg,	/* ok		*/
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D tcp_sendpage,
 	.splice_read	   =3D tcp_splice_read,
@@ -544,6 +545,7 @@ const struct proto_ops inet6_dgram_ops =3D {
 	.getsockopt	   =3D sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   =3D inet_sendmsg,		/* ok		*/
 	.recvmsg	   =3D sock_common_recvmsg,	/* ok		*/
+	.unlocked_recvmsg  =3D sock_common_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 7d675b8..d17db28 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1325,6 +1325,7 @@ static const struct proto_ops inet6_sockraw_ops =3D=
 {
 	.getsockopt	   =3D sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   =3D inet_sendmsg,		/* ok		*/
 	.recvmsg	   =3D sock_common_recvmsg,	/* ok		*/
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index f1118d9..45048a0 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1953,6 +1953,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ipx=
_dgram_ops) =3D {
 	.getsockopt	=3D ipx_getsockopt,
 	.sendmsg	=3D ipx_sendmsg,
 	.recvmsg	=3D ipx_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage,
 };
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 50b43c5..7e97581 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2489,6 +2489,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ird=
a_stream_ops) =3D {
 	.getsockopt =3D	irda_getsockopt,
 	.sendmsg =3D	irda_sendmsg,
 	.recvmsg =3D	irda_recvmsg_stream,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
@@ -2513,6 +2514,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ird=
a_seqpacket_ops) =3D {
 	.getsockopt =3D	irda_getsockopt,
 	.sendmsg =3D	irda_sendmsg,
 	.recvmsg =3D	irda_recvmsg_dgram,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
@@ -2537,6 +2539,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ird=
a_dgram_ops) =3D {
 	.getsockopt =3D	irda_getsockopt,
 	.sendmsg =3D	irda_sendmsg_dgram,
 	.recvmsg =3D	irda_recvmsg_dgram,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
@@ -2562,6 +2565,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ird=
a_ultra_ops) =3D {
 	.getsockopt =3D	irda_getsockopt,
 	.sendmsg =3D	irda_sendmsg_ultra,
 	.recvmsg =3D	irda_recvmsg_dgram,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 49c15b4..c208622 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1693,6 +1693,7 @@ static struct proto_ops iucv_sock_ops =3D {
 	.getname	=3D iucv_sock_getname,
 	.sendmsg	=3D iucv_sock_sendmsg,
 	.recvmsg	=3D iucv_sock_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.poll		=3D iucv_sock_poll,
 	.ioctl		=3D sock_no_ioctl,
 	.mmap		=3D sock_no_mmap,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 4e98193..3ef1f26 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3636,6 +3636,7 @@ static const struct proto_ops pfkey_ops =3D {
 	.getsockopt	=3D	sock_no_getsockopt,
 	.mmap		=3D	sock_no_mmap,
 	.sendpage	=3D	sock_no_sendpage,
+	.unlocked_recvmsg =3D	sock_no_unlocked_recvmsg,
=20
 	/* Now the operations that really occur. */
 	.release	=3D	pfkey_release,
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c45eee1..d948caf 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -1115,6 +1115,7 @@ static const struct proto_ops llc_ui_ops =3D {
 	.getsockopt  =3D llc_ui_getsockopt,
 	.sendmsg     =3D llc_ui_sendmsg,
 	.recvmsg     =3D llc_ui_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap	     =3D sock_no_mmap,
 	.sendpage    =3D sock_no_sendpage,
 };
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d0ff382..0d1b446 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2036,6 +2036,7 @@ static const struct proto_ops netlink_ops =3D {
 	.getsockopt =3D	netlink_getsockopt,
 	.sendmsg =3D	netlink_sendmsg,
 	.recvmsg =3D	netlink_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ce1a34b..3550d34 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1395,6 +1395,7 @@ static const struct proto_ops nr_proto_ops =3D {
 	.getsockopt	=3D	nr_getsockopt,
 	.sendmsg	=3D	nr_sendmsg,
 	.recvmsg	=3D	nr_recvmsg,
+	.unlocked_recvmsg =3D	sock_no_unlocked_recvmsg,
 	.mmap		=3D	sock_no_mmap,
 	.sendpage	=3D	sock_no_sendpage,
 };
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d3d52c6..d987e23 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2338,6 +2338,7 @@ static const struct proto_ops packet_ops_spkt =3D=
 {
 	.getsockopt =3D	sock_no_getsockopt,
 	.sendmsg =3D	packet_sendmsg_spkt,
 	.recvmsg =3D	packet_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
@@ -2359,6 +2360,7 @@ static const struct proto_ops packet_ops =3D {
 	.getsockopt =3D	packet_getsockopt,
 	.sendmsg =3D	packet_sendmsg,
 	.recvmsg =3D	packet_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		packet_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 7a4ee39..248e8b2 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -327,6 +327,7 @@ const struct proto_ops phonet_dgram_ops =3D {
 #endif
 	.sendmsg	=3D pn_socket_sendmsg,
 	.recvmsg	=3D sock_common_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage,
 };
@@ -352,6 +353,7 @@ const struct proto_ops phonet_stream_ops =3D {
 #endif
 	.sendmsg	=3D pn_socket_sendmsg,
 	.recvmsg	=3D sock_common_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage,
 };
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 108ed2e..1f2e8db 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -376,6 +376,7 @@ static struct proto_ops rds_proto_ops =3D {
 	.getsockopt =3D	rds_getsockopt,
 	.sendmsg =3D	rds_sendmsg,
 	.recvmsg =3D	rds_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index e5f478c..a64c623 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1532,6 +1532,7 @@ static struct proto_ops rose_proto_ops =3D {
 	.getsockopt	=3D	rose_getsockopt,
 	.sendmsg	=3D	rose_sendmsg,
 	.recvmsg	=3D	rose_recvmsg,
+	.unlocked_recvmsg =3D	sock_no_unlocked_recvmsg,
 	.mmap		=3D	sock_no_mmap,
 	.sendpage	=3D	sock_no_sendpage,
 };
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index bfe493e..bf4c38a 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -766,6 +766,7 @@ static const struct proto_ops rxrpc_rpc_ops =3D {
 	.getsockopt	=3D sock_no_getsockopt,
 	.sendmsg	=3D rxrpc_sendmsg,
 	.recvmsg	=3D rxrpc_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage,
 };
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 6a4b190..b68d9f9 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -918,6 +918,7 @@ static const struct proto_ops inet6_seqpacket_ops =3D=
 {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D inet_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt =3D compat_sock_common_setsockopt,
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 60093be..8caedcb 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -895,6 +895,7 @@ static const struct proto_ops inet_seqpacket_ops =3D=
 {
 	.getsockopt	   =3D sock_common_getsockopt,
 	.sendmsg	   =3D inet_sendmsg,
 	.recvmsg	   =3D sock_common_recvmsg,
+	.unlocked_recvmsg  =3D sock_no_unlocked_recvmsg,
 	.mmap		   =3D sock_no_mmap,
 	.sendpage	   =3D sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/socket.c b/net/socket.c
index 32db56a..dc5b976 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -690,6 +690,32 @@ static inline int __sock_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
 	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
 }
=20
+static inline int __sock_unlocked_recvmsg_nosec(struct kiocb *iocb,
+						struct socket *sock,
+						struct msghdr *msg,
+						size_t size, int flags)
+{
+	struct sock_iocb *si =3D kiocb_to_siocb(iocb);
+
+	si->sock =3D sock;
+	si->scm =3D NULL;
+	si->msg =3D msg;
+	si->size =3D size;
+	si->flags =3D flags;
+
+	return sock->ops->unlocked_recvmsg(iocb, sock, msg, size, flags);
+}
+
+static inline int __sock_unlocked_recvmsg(struct kiocb *iocb,
+					  struct socket *sock,
+					  struct msghdr *msg, size_t size,
+					  int flags)
+{
+	int err =3D security_socket_recvmsg(sock, msg, size, flags);
+
+	return err ?: __sock_unlocked_recvmsg_nosec(iocb, sock, msg, size, fl=
ags);
+}
+
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
 {
@@ -720,6 +746,58 @@ static int sock_recvmsg_nosec(struct socket *sock,=
 struct msghdr *msg,
 	return ret;
 }
=20
+static int sock_unlocked_recvmsg(struct socket *sock, struct msghdr *m=
sg,
+				 size_t size, int flags)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private =3D &siocb;
+	ret =3D __sock_unlocked_recvmsg(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED =3D=3D ret)
+		ret =3D wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
+static int sock_unlocked_recvmsg_nosec(struct socket *sock, struct msg=
hdr *msg,
+				       size_t size, int flags)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private =3D &siocb;
+	ret =3D __sock_unlocked_recvmsg_nosec(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED =3D=3D ret)
+		ret =3D wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
+enum sock_recvmsg_security {
+	SOCK_RECVMSG_SEC =3D 0,
+	SOCK_RECVMSG_NOSEC,
+};
+
+enum sock_recvmsg_locking {
+	SOCK_LOCKED_RECVMSG =3D 0,
+	SOCK_UNLOCKED_RECVMSG,
+};
+
+static int (*sock_recvmsg_table[2][2])(struct socket *sock, struct msg=
hdr *msg,
+				       size_t size, int flags) =3D {
+	[SOCK_RECVMSG_SEC] =3D {
+		[SOCK_LOCKED_RECVMSG]	=3D sock_recvmsg, /* The old one */
+		[SOCK_UNLOCKED_RECVMSG] =3D sock_unlocked_recvmsg,
+	},
+	[SOCK_RECVMSG_NOSEC] =3D {
+		[SOCK_LOCKED_RECVMSG]	=3D sock_recvmsg_nosec,
+		[SOCK_UNLOCKED_RECVMSG] =3D sock_unlocked_recvmsg_nosec,
+	},
+};
+
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size, int flags)
 {
@@ -1984,7 +2062,9 @@ out:
 }
=20
 static int __sys_recvmsg(struct socket *sock, struct msghdr __user *ms=
g,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+			 struct msghdr *msg_sys, unsigned flags,
+			 enum sock_recvmsg_security security,
+			 enum sock_recvmsg_locking locking)
 {
 	struct compat_msghdr __user *msg_compat =3D
 	    (struct compat_msghdr __user *)msg;
@@ -2044,8 +2124,8 @@ static int __sys_recvmsg(struct socket *sock, str=
uct msghdr __user *msg,
=20
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |=3D MSG_DONTWAIT;
-	err =3D (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
-							  total_len, flags);
+	err =3D sock_recvmsg_table[security][locking](sock, msg_sys,
+						    total_len, flags);
 	if (err < 0)
 		goto out_freeiov;
 	len =3D err;
@@ -2092,7 +2172,8 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr _=
_user *, msg,
 	if (!sock)
 		goto out;
=20
-	err =3D __sys_recvmsg(sock, msg, &msg_sys, flags, 0);
+	err =3D __sys_recvmsg(sock, msg, &msg_sys, flags,
+			    SOCK_RECVMSG_SEC, SOCK_LOCKED_RECVMSG);
=20
 	fput_light(sock->file, fput_needed);
 out:
@@ -2111,6 +2192,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user =
*mmsg, unsigned int vlen,
 	struct mmsghdr __user *entry;
 	struct msghdr msg_sys;
 	struct timespec end_time;
+	enum sock_recvmsg_security security;
=20
 	if (timeout &&
 	    poll_select_set_timeout(&end_time, timeout->tv_sec,
@@ -2123,20 +2205,25 @@ int __sys_recvmmsg(int fd, struct mmsghdr __use=
r *mmsg, unsigned int vlen,
 	if (!sock)
 		return err;
=20
+	lock_sock(sock->sk);
+
 	err =3D sock_error(sock->sk);
 	if (err)
 		goto out_put;
=20
 	entry =3D mmsg;
=20
+	security =3D SOCK_RECVMSG_SEC;
 	while (datagrams < vlen) {
-		/*
-		 * No need to ask LSM for more than the first datagram.
-		 */
 		err =3D __sys_recvmsg(sock, (struct msghdr __user *)entry,
-				    &msg_sys, flags, datagrams);
+				    &msg_sys, flags, security,
+				    SOCK_UNLOCKED_RECVMSG);
 		if (err < 0)
 			break;
+		/*
+		 * No need to ask LSM for more than the first datagram.
+		 */
+		security =3D SOCK_RECVMSG_NOSEC;
 		err =3D put_user(err, &entry->msg_len);
 		if (err)
 			break;
@@ -2165,9 +2252,8 @@ out_put:
 	fput_light(sock->file, fput_needed);
=20
 	if (err =3D=3D 0)
-		return datagrams;
-
-	if (datagrams !=3D 0) {
+		err =3D datagrams;
+	else if (datagrams !=3D 0) {
 		/*
 		 * We may return less entries than requested (vlen) if the
 		 * sock is non block and there aren't enough datagrams...
@@ -2182,9 +2268,11 @@ out_put:
 			sock->sk->sk_err =3D -err;
 		}
=20
-		return datagrams;
+		err =3D datagrams;
 	}
=20
+	release_sock(sock->sk);
+
 	return err;
 }
=20
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e8254e8..97b3f05 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1797,6 +1797,7 @@ static const struct proto_ops msg_ops =3D {
 	.getsockopt	=3D getsockopt,
 	.sendmsg	=3D send_msg,
 	.recvmsg	=3D recv_msg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage
 };
@@ -1818,6 +1819,7 @@ static const struct proto_ops packet_ops =3D {
 	.getsockopt	=3D getsockopt,
 	.sendmsg	=3D send_packet,
 	.recvmsg	=3D recv_msg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage
 };
@@ -1839,6 +1841,7 @@ static const struct proto_ops stream_ops =3D {
 	.getsockopt	=3D getsockopt,
 	.sendmsg	=3D send_stream,
 	.recvmsg	=3D recv_stream,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap		=3D sock_no_mmap,
 	.sendpage	=3D sock_no_sendpage
 };
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51ab497..9e7aa9a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -521,6 +521,7 @@ static const struct proto_ops unix_stream_ops =3D {
 	.getsockopt =3D	sock_no_getsockopt,
 	.sendmsg =3D	unix_stream_sendmsg,
 	.recvmsg =3D	unix_stream_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
@@ -542,6 +543,7 @@ static const struct proto_ops unix_dgram_ops =3D {
 	.getsockopt =3D	sock_no_getsockopt,
 	.sendmsg =3D	unix_dgram_sendmsg,
 	.recvmsg =3D	unix_dgram_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
@@ -563,6 +565,7 @@ static const struct proto_ops unix_seqpacket_ops =3D=
 {
 	.getsockopt =3D	sock_no_getsockopt,
 	.sendmsg =3D	unix_seqpacket_sendmsg,
 	.recvmsg =3D	unix_dgram_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 5e6c072..7c20b26 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1620,6 +1620,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(x25=
_proto_ops) =3D {
 	.getsockopt =3D	x25_getsockopt,
 	.sendmsg =3D	x25_sendmsg,
 	.recvmsg =3D	x25_recvmsg,
+	.unlocked_recvmsg =3D sock_no_unlocked_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
--=20
1.5.5.1

