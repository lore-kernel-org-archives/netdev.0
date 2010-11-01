From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [PATCH 1/2] caif: Bugfix for socket priority, bindtodev and dbg channel.
Date: Mon,  1 Nov 2010 22:52:47 +0100
Message-ID: <1288648368-9062-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Andr=C3=A9=20Carvalho=20de=20Matos?=
	<andre.carvalho.matos@stericsson.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53297 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab0KAVwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:52:53 -0400
Received: by eye27 with SMTP id 27so3559902eye.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 14:52:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andr=C3=A9 Carvalho de Matos <andre.carvalho.matos@stericsson.c=
om>

Changes:
o Bugfix: SO_PRIORITY for SOL_SOCKET could not be handled
  in caif's setsockopt,  using the struct sock attribute priority inste=
ad.

o Bugfix: SO_BINDTODEVICE for SOL_SOCKET could not be handled
  in caif's setsockopt,  using the struct sock attribute ifindex instea=
d.

o Wrong assert statement for RFM layer segmentation.

o CAIF Debug channels was not working over SPI, caif_payload_info
  containing padding info must be initialized.

o Check on pointer before dereferencing when unregister dev in caif_dev=
=2Ec

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h |    4 +-
 include/net/caif/cfcnfg.h   |    8 +++---
 net/caif/caif_config_util.c |   13 +++++++++--
 net/caif/caif_dev.c         |    2 +
 net/caif/caif_socket.c      |   45 ++++++++++++++---------------------=
-------
 net/caif/cfcnfg.c           |   17 ++++++---------
 net/caif/cfdbgl.c           |   14 +++++++++++++
 net/caif/cfrfml.c           |    2 +-
 8 files changed, 55 insertions(+), 50 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index 6da573c..8eff83b 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -28,7 +28,7 @@ struct caif_param {
  * @sockaddr:		Socket address to connect.
  * @priority:		Priority of the connection.
  * @link_selector:	Link selector (high bandwidth or low latency)
- * @link_name:		Name of the CAIF Link Layer to use.
+ * @ifindex:		kernel index of the interface.
  * @param:		Connect Request parameters (CAIF_SO_REQ_PARAM).
  *
  * This struct is used when connecting a CAIF channel.
@@ -39,7 +39,7 @@ struct caif_connect_request {
 	struct sockaddr_caif sockaddr;
 	enum caif_channel_priority priority;
 	enum caif_link_selector link_selector;
-	char link_name[16];
+	int ifindex;
 	struct caif_param param;
 };
=20
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index bd646fa..f688478 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -139,10 +139,10 @@ struct dev_info *cfcnfg_get_phyid(struct cfcnfg *=
cnfg,
 		     enum cfcnfg_phy_preference phy_pref);
=20
 /**
- * cfcnfg_get_named() - Get the Physical Identifier of CAIF Link Layer
+ * cfcnfg_get_id_from_ifi() - Get the Physical Identifier of ifindex,
+ * 			it matches caif physical id with the kernel interface id.
  * @cnfg:	Configuration object
- * @name:	Name of the Physical Layer (Caif Link Layer)
+ * @ifi:	ifindex obtained from socket.c bindtodevice.
  */
-int cfcnfg_get_named(struct cfcnfg *cnfg, char *name);
-
+int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, int ifi);
 #endif				/* CFCNFG_H_ */
diff --git a/net/caif/caif_config_util.c b/net/caif/caif_config_util.c
index 76ae683..d522d8c 100644
--- a/net/caif/caif_config_util.c
+++ b/net/caif/caif_config_util.c
@@ -16,11 +16,18 @@ int connect_req_to_link_param(struct cfcnfg *cnfg,
 {
 	struct dev_info *dev_info;
 	enum cfcnfg_phy_preference pref;
+	int res;
+
 	memset(l, 0, sizeof(*l));
-	l->priority =3D s->priority;
+	/* In caif protocol low value is high priority */
+	l->priority =3D CAIF_PRIO_MAX - s->priority + 1;
=20
-	if (s->link_name[0] !=3D '\0')
-		l->phyid =3D cfcnfg_get_named(cnfg, s->link_name);
+	if (s->ifindex !=3D 0){
+		res =3D cfcnfg_get_id_from_ifi(cnfg, s->ifindex);
+		if (res < 0)
+			return res;
+		l->phyid =3D res;
+	}
 	else {
 		switch (s->link_selector) {
 		case CAIF_LINK_HIGH_BANDW:
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index b99369a..a42a408 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -307,6 +307,8 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
=20
 	case NETDEV_UNREGISTER:
 		caifd =3D caif_get(dev);
+		if (caifd =3D=3D NULL)
+			break;
 		netdev_info(dev, "unregister\n");
 		atomic_set(&caifd->state, what);
 		caif_device_destroy(dev);
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 2eca2dd..1bf0cf5 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -716,8 +716,7 @@ static int setsockopt(struct socket *sock,
 {
 	struct sock *sk =3D sock->sk;
 	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
-	int prio, linksel;
-	struct ifreq ifreq;
+	int linksel;
=20
 	if (cf_sk->sk.sk_socket->state !=3D SS_UNCONNECTED)
 		return -ENOPROTOOPT;
@@ -735,33 +734,6 @@ static int setsockopt(struct socket *sock,
 		release_sock(&cf_sk->sk);
 		return 0;
=20
-	case SO_PRIORITY:
-		if (lvl !=3D SOL_SOCKET)
-			goto bad_sol;
-		if (ol < sizeof(int))
-			return -EINVAL;
-		if (copy_from_user(&prio, ov, sizeof(int)))
-			return -EINVAL;
-		lock_sock(&(cf_sk->sk));
-		cf_sk->conn_req.priority =3D prio;
-		release_sock(&cf_sk->sk);
-		return 0;
-
-	case SO_BINDTODEVICE:
-		if (lvl !=3D SOL_SOCKET)
-			goto bad_sol;
-		if (ol < sizeof(struct ifreq))
-			return -EINVAL;
-		if (copy_from_user(&ifreq, ov, sizeof(ifreq)))
-			return -EFAULT;
-		lock_sock(&(cf_sk->sk));
-		strncpy(cf_sk->conn_req.link_name, ifreq.ifr_name,
-			sizeof(cf_sk->conn_req.link_name));
-		cf_sk->conn_req.link_name
-			[sizeof(cf_sk->conn_req.link_name)-1] =3D 0;
-		release_sock(&cf_sk->sk);
-		return 0;
-
 	case CAIFSO_REQ_PARAM:
 		if (lvl !=3D SOL_CAIF)
 			goto bad_sol;
@@ -880,6 +852,18 @@ static int caif_connect(struct socket *sock, struc=
t sockaddr *uaddr,
 	sock->state =3D SS_CONNECTING;
 	sk->sk_state =3D CAIF_CONNECTING;
=20
+	/* Check priority value comming from socket */
+	/* if priority value is out of range it will be ajusted */
+	if (cf_sk->sk.sk_priority > CAIF_PRIO_MAX)
+		cf_sk->conn_req.priority =3D CAIF_PRIO_MAX;
+	else if (cf_sk->sk.sk_priority < CAIF_PRIO_MIN)
+		cf_sk->conn_req.priority =3D CAIF_PRIO_MIN;
+	else
+		cf_sk->conn_req.priority =3D cf_sk->sk.sk_priority;
+
+	/*ifindex =3D id of the interface.*/
+	cf_sk->conn_req.ifindex =3D cf_sk->sk.sk_bound_dev_if;
+
 	dbfs_atomic_inc(&cnt.num_connect_req);
 	cf_sk->layer.receive =3D caif_sktrecv_cb;
 	err =3D caif_connect_client(&cf_sk->conn_req,
@@ -905,6 +889,7 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uaddr,
 	cf_sk->maxframe =3D mtu - (headroom + tailroom);
 	if (cf_sk->maxframe < 1) {
 		pr_warn("CAIF Interface MTU too small (%d)\n", dev->mtu);
+		err =3D -ENODEV;
 		goto out;
 	}
=20
@@ -1142,7 +1127,7 @@ static int caif_create(struct net *net, struct so=
cket *sock, int protocol,
 	set_rx_flow_on(cf_sk);
=20
 	/* Set default options on configuration */
-	cf_sk->conn_req.priority =3D CAIF_PRIO_NORMAL;
+	cf_sk->sk.sk_priority=3D CAIF_PRIO_NORMAL;
 	cf_sk->conn_req.link_selector =3D CAIF_LINK_LOW_LATENCY;
 	cf_sk->conn_req.protocol =3D protocol;
 	/* Increase the number of sockets created. */
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 41adafd..21ede14 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -173,18 +173,15 @@ static struct cfcnfg_phyinfo *cfcnfg_get_phyinfo(=
struct cfcnfg *cnfg,
 	return NULL;
 }
=20
-int cfcnfg_get_named(struct cfcnfg *cnfg, char *name)
+
+int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, int ifi)
 {
 	int i;
-
-	/* Try to match with specified name */
-	for (i =3D 0; i < MAX_PHY_LAYERS; i++) {
-		if (cnfg->phy_layers[i].frm_layer !=3D NULL
-		    && strcmp(cnfg->phy_layers[i].phy_layer->name,
-			      name) =3D=3D 0)
-			return cnfg->phy_layers[i].frm_layer->id;
-	}
-	return 0;
+	for (i =3D 0; i < MAX_PHY_LAYERS; i++)
+		if (cnfg->phy_layers[i].frm_layer !=3D NULL &&
+				cnfg->phy_layers[i].ifindex =3D=3D ifi)
+			return i;
+	return -ENODEV;
 }
=20
 int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *ad=
ap_layer)
diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
index 496fda9..11a2af4 100644
--- a/net/caif/cfdbgl.c
+++ b/net/caif/cfdbgl.c
@@ -12,6 +12,8 @@
 #include <net/caif/cfsrvl.h>
 #include <net/caif/cfpkt.h>
=20
+#define container_obj(layr) ((struct cfsrvl *) layr)
+
 static int cfdbgl_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfdbgl_transmit(struct cflayer *layr, struct cfpkt *pkt);
=20
@@ -38,5 +40,17 @@ static int cfdbgl_receive(struct cflayer *layr, stru=
ct cfpkt *pkt)
=20
 static int cfdbgl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 {
+	struct cfsrvl *service =3D container_obj(layr);
+	struct caif_payload_info *info;
+	int ret;
+
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+
+	/* Add info for MUX-layer to route the packet out */
+	info =3D cfpkt_info(pkt);
+	info->channel_id =3D service->layer.id;
+	info->dev_info =3D &service->dev_info;
+
 	return layr->dn->transmit(layr->dn, pkt);
 }
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index bde8481..e2fb5fa 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -193,7 +193,7 @@ out:
=20
 static int cfrfml_transmit_segment(struct cfrfml *rfml, struct cfpkt *=
pkt)
 {
-	caif_assert(cfpkt_getlen(pkt) >=3D rfml->fragment_size);
+	caif_assert(cfpkt_getlen(pkt) < rfml->fragment_size);
=20
 	/* Add info for MUX-layer to route the packet out. */
 	cfpkt_info(pkt)->channel_id =3D rfml->serv.layer.id;
--=20
1.7.0.4

