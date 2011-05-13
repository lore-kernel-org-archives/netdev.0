From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 06/10] caif: Protected in-flight packets using dev or sock refcont.
Date: Fri, 13 May 2011 14:44:04 +0200
Message-ID: <1305290648-9613-7-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:54041 "EHLO
	slow2.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758948Ab1EMNCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:02:37 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow2.isp.as2116.net (Postfix) with ESMTP id 7E87340B3F
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:20 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAIF Socket Layer and ip-interface registers reference counters
in CAIF service layer. The functions sock_hold, sock_put and
dev_hold, dev_put are used by CAIF Stack to protect from freeing
memory while packets are in-flight.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h |   29 +++++++++++++++++++++++++++++
 net/caif/caif_socket.c      |   19 +++++++++++++++++--
 net/caif/chnl_net.c         |   28 ++++++++++++++++++++++++++--
 3 files changed, 72 insertions(+), 4 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index 7e3f7a6..6638435 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -74,6 +74,23 @@ int caif_connect_client(struct caif_connect_request =
*conn_req,
 int caif_disconnect_client(struct cflayer *client_layer);
=20
 /**
+ * caif_client_register_refcnt - register ref-count functions provided=
 by client.
+ *
+ * @adapt_layer: Client layer using CAIF Stack.
+ * @hold:	Function provided by client layer increasing ref-count
+ * @put:	Function provided by client layer decreasing ref-count
+ *
+ * Client of the CAIF Stack must register functions for reference coun=
ting.
+ * These functions are called by the CAIF Stack for every upstream pac=
ket,
+ * and must therefore be implemented efficiently.
+ *
+ * Client should call caif_free_client when reference count degrease t=
o zero.
+ */
+
+void caif_client_register_refcnt(struct cflayer *adapt_layer,
+					void (*hold)(struct cflayer *lyr),
+					void (*put)(struct cflayer *lyr));
+/**
  * caif_connect_req_to_link_param - Translate configuration parameters
  *				    from socket format to internal format.
  * @cnfg:	Pointer to configuration handler
@@ -83,8 +100,20 @@ int caif_disconnect_client(struct cflayer *client_l=
ayer);
  *			 setting up channels.
  *
  */
+
 int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
 				   struct caif_connect_request *con_req,
 				   struct cfctrl_link_param *setup_param);
=20
+/**
+ * caif_free_client - Free memory used to manage the client in the CAI=
=46 Stack.
+ *
+ * @client_layer: Client layer to be removed.
+ *
+ * This function must be called from client layer in order to free mem=
ory.
+ * Caller must guarantee that no packets are in flight upstream when c=
alling
+ * this function.
+ */
+void caif_free_client(struct cflayer *adap_layer);
+
 #endif /* CAIF_DEV_H_ */
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 2021242..01f612d 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -209,6 +209,18 @@ static int caif_sktrecv_cb(struct cflayer *layr, s=
truct cfpkt *pkt)
 	return 0;
 }
=20
+static void cfsk_hold(struct cflayer *layr)
+{
+	struct caifsock *cf_sk =3D container_of(layr, struct caifsock, layer)=
;
+	sock_hold(&cf_sk->sk);
+}
+
+static void cfsk_put(struct cflayer *layr)
+{
+	struct caifsock *cf_sk =3D container_of(layr, struct caifsock, layer)=
;
+	sock_put(&cf_sk->sk);
+}
+
 /* Packet Control Callback function called from CAIF */
 static void caif_ctrl_cb(struct cflayer *layr,
 				enum caif_ctrlcmd flow,
@@ -232,6 +244,8 @@ static void caif_ctrl_cb(struct cflayer *layr,
=20
 	case CAIF_CTRLCMD_INIT_RSP:
 		/* We're now connected */
+		caif_client_register_refcnt(&cf_sk->layer,
+						cfsk_hold, cfsk_put);
 		dbfs_atomic_inc(&cnt.num_connect_resp);
 		cf_sk->sk.sk_state =3D CAIF_CONNECTED;
 		set_tx_flow_on(cf_sk);
@@ -242,7 +256,6 @@ static void caif_ctrl_cb(struct cflayer *layr,
 		/* We're now disconnected */
 		cf_sk->sk.sk_state =3D CAIF_DISCONNECTED;
 		cf_sk->sk.sk_state_change(&cf_sk->sk);
-		cfcnfg_release_adap_layer(&cf_sk->layer);
 		break;
=20
 	case CAIF_CTRLCMD_INIT_FAIL_RSP:
@@ -837,8 +850,10 @@ static int caif_connect(struct socket *sock, struc=
t sockaddr *uaddr,
=20
 	dbfs_atomic_inc(&cnt.num_connect_req);
 	cf_sk->layer.receive =3D caif_sktrecv_cb;
+
 	err =3D caif_connect_client(&cf_sk->conn_req,
 				&cf_sk->layer, &ifindex, &headroom, &tailroom);
+
 	if (err < 0) {
 		cf_sk->sk.sk_socket->state =3D SS_UNCONNECTED;
 		cf_sk->sk.sk_state =3D CAIF_DISCONNECTED;
@@ -940,7 +955,6 @@ static int caif_release(struct socket *sock)
 	wake_up_interruptible_poll(sk_sleep(sk), POLLERR|POLLHUP);
=20
 	sock_orphan(sk);
-	cf_sk->layer.dn =3D NULL;
 	sk_stream_kill_queues(&cf_sk->sk);
 	release_sock(sk);
 	sock_put(sk);
@@ -1036,6 +1050,7 @@ static void caif_sock_destructor(struct sock *sk)
 	}
 	sk_stream_kill_queues(&cf_sk->sk);
 	dbfs_atomic_dec(&cnt.caif_nr_socks);
+	caif_free_client(&cf_sk->layer);
 }
=20
 static int caif_create(struct net *net, struct socket *sock, int proto=
col,
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 6008d6d..9ef8f16 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -153,6 +153,18 @@ static void close_work(struct work_struct *work)
 }
 static DECLARE_WORK(close_worker, close_work);
=20
+static void chnl_hold(struct cflayer *lyr)
+{
+	struct chnl_net *priv =3D container_of(lyr, struct chnl_net, chnl);
+	dev_hold(priv->netdev);
+}
+
+static void chnl_put(struct cflayer *lyr)
+{
+	struct chnl_net *priv =3D container_of(lyr, struct chnl_net, chnl);
+	dev_put(priv->netdev);
+}
+
 static void chnl_flowctrl_cb(struct cflayer *layr, enum caif_ctrlcmd f=
low,
 				int phyid)
 {
@@ -190,6 +202,7 @@ static void chnl_flowctrl_cb(struct cflayer *layr, =
enum caif_ctrlcmd flow,
 		netif_wake_queue(priv->netdev);
 		break;
 	case CAIF_CTRLCMD_INIT_RSP:
+		caif_client_register_refcnt(&priv->chnl, chnl_hold, chnl_put);
 		priv->state =3D CAIF_CONNECTED;
 		priv->flowenabled =3D true;
 		netif_wake_queue(priv->netdev);
@@ -373,11 +386,18 @@ static const struct net_device_ops netdev_ops =3D=
 {
 	.ndo_start_xmit =3D chnl_net_start_xmit,
 };
=20
+static void chnl_net_destructor(struct net_device *dev)
+{
+	struct chnl_net *priv =3D netdev_priv(dev);
+	caif_free_client(&priv->chnl);
+	free_netdev(dev);
+}
+
 static void ipcaif_net_setup(struct net_device *dev)
 {
 	struct chnl_net *priv;
 	dev->netdev_ops =3D &netdev_ops;
-	dev->destructor =3D free_netdev;
+	dev->destructor =3D chnl_net_destructor;
 	dev->flags |=3D IFF_NOARP;
 	dev->flags |=3D IFF_POINTOPOINT;
 	dev->mtu =3D GPRS_PDP_MTU;
@@ -391,7 +411,7 @@ static void ipcaif_net_setup(struct net_device *dev=
)
 	priv->conn_req.link_selector =3D CAIF_LINK_HIGH_BANDW;
 	priv->conn_req.priority =3D CAIF_PRIO_LOW;
 	/* Insert illegal value */
-	priv->conn_req.sockaddr.u.dgm.connection_id =3D -1;
+	priv->conn_req.sockaddr.u.dgm.connection_id =3D 0;
 	priv->flowenabled =3D false;
=20
 	init_waitqueue_head(&priv->netmgmt_wq);
@@ -453,6 +473,10 @@ static int ipcaif_newlink(struct net *src_net, str=
uct net_device *dev,
 		pr_warn("device rtml registration failed\n");
 	else
 		list_add(&caifdev->list_field, &chnl_net_list);
+
+	/* Take ifindex as connection-id if null */
+	if (caifdev->conn_req.sockaddr.u.dgm.connection_id =3D=3D 0)
+		caifdev->conn_req.sockaddr.u.dgm.connection_id =3D dev->ifindex;
 	return ret;
 }
=20
--=20
1.7.1

