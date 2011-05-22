From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 2/5] caif: Fixes freeze on Link layer removal.
Date: Sun, 22 May 2011 23:18:51 +0200
Message-ID: <1306099134-12989-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:43516 "EHLO pmx.vmail.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755337Ab1EVVTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 17:19:07 -0400
In-Reply-To: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAIF Socket layer - caif_socket.c:
- Plug mem-leak at reconnect.
- Always call disconnect to cleanup CAIF stack.
- Disconnect will always report success.

CAIF configuration layer - cfcnfg.c
- Disconnect must dismantle the caif stack correctly
- Protect against faulty removals (check on id zero)

CAIF mux layer - cfmuxl.c
- When inserting new service layer in the MUX remove
  any old entries with the same ID.
- When removing CAIF Link layer, remove the associated
  service layers before notifying service layers.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   13 ++++-------
 net/caif/cfcnfg.c      |   44 ++++++++++++++++++----------------------=
--
 net/caif/cfmuxl.c      |   49 +++++++++++++++++++++++++++++++++++++---=
-------
 3 files changed, 62 insertions(+), 44 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index b840395..a986280 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -19,7 +19,7 @@
 #include <linux/uaccess.h>
 #include <linux/debugfs.h>
 #include <linux/caif/caif_socket.h>
-#include <asm/atomic.h>
+#include <linux/atomic.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <net/caif/caif_layer.h>
@@ -816,6 +816,7 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uaddr,
 		if (sk->sk_shutdown & SHUTDOWN_MASK) {
 			/* Allow re-connect after SHUTDOWN_IND */
 			caif_disconnect_client(sock_net(sk), &cf_sk->layer);
+			caif_free_client(&cf_sk->layer);
 			break;
 		}
 		/* No reconnect on a seqpacket socket */
@@ -926,7 +927,6 @@ static int caif_release(struct socket *sock)
 {
 	struct sock *sk =3D sock->sk;
 	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
-	int res =3D 0;
=20
 	if (!sk)
 		return 0;
@@ -953,10 +953,7 @@ static int caif_release(struct socket *sock)
 	sk->sk_state =3D CAIF_DISCONNECTED;
 	sk->sk_shutdown =3D SHUTDOWN_MASK;
=20
-	if (cf_sk->sk.sk_socket->state =3D=3D SS_CONNECTED ||
-		cf_sk->sk.sk_socket->state =3D=3D SS_CONNECTING)
-		res =3D caif_disconnect_client(sock_net(sk), &cf_sk->layer);
-
+	caif_disconnect_client(sock_net(sk), &cf_sk->layer);
 	cf_sk->sk.sk_socket->state =3D SS_DISCONNECTING;
 	wake_up_interruptible_poll(sk_sleep(sk), POLLERR|POLLHUP);
=20
@@ -964,7 +961,7 @@ static int caif_release(struct socket *sock)
 	sk_stream_kill_queues(&cf_sk->sk);
 	release_sock(sk);
 	sock_put(sk);
-	return res;
+	return 0;
 }
=20
 /* Copied from af_unix.c:unix_poll(), added CAIF tx_flow handling */
@@ -1120,7 +1117,7 @@ static int caif_create(struct net *net, struct so=
cket *sock, int protocol,
 	set_rx_flow_on(cf_sk);
=20
 	/* Set default options on configuration */
-	cf_sk->sk.sk_priority=3D CAIF_PRIO_NORMAL;
+	cf_sk->sk.sk_priority =3D CAIF_PRIO_NORMAL;
 	cf_sk->conn_req.link_selector =3D CAIF_LINK_LOW_LATENCY;
 	cf_sk->conn_req.protocol =3D protocol;
 	/* Increase the number of sockets created. */
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 351c2ca..52fe33b 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -182,39 +182,26 @@ static int cfcnfg_get_id_from_ifi(struct cfcnfg *=
cnfg, int ifi)
=20
 int caif_disconnect_client(struct net *net, struct cflayer *adap_layer=
)
 {
-	u8 channel_id =3D 0;
-	int ret =3D 0;
-	struct cflayer *servl =3D NULL;
+	u8 channel_id;
 	struct cfcnfg *cfg =3D get_cfcnfg(net);
=20
 	caif_assert(adap_layer !=3D NULL);
-
-	channel_id =3D adap_layer->id;
-	if (adap_layer->dn =3D=3D NULL || channel_id =3D=3D 0) {
-		pr_err("adap_layer->dn =3D=3D NULL or adap_layer->id is 0\n");
-		ret =3D -ENOTCONN;
-		goto end;
-	}
-
-	servl =3D cfmuxl_remove_uplayer(cfg->mux, channel_id);
-	if (servl =3D=3D NULL) {
-		pr_err("PROTOCOL ERROR - "
-				"Error removing service_layer Channel_Id(%d)",
-				channel_id);
-		ret =3D -EINVAL;
-		goto end;
-	}
-
-	ret =3D cfctrl_linkdown_req(cfg->ctrl, channel_id, adap_layer);
-
-end:
 	cfctrl_cancel_req(cfg->ctrl, adap_layer);
+	channel_id =3D adap_layer->id;
+	if (channel_id !=3D 0) {
+		struct cflayer *servl;
+		servl =3D cfmuxl_remove_uplayer(cfg->mux, channel_id);
+		if (servl !=3D NULL)
+			layer_set_up(servl, NULL);
+	} else
+		pr_debug("nothing to disconnect\n");
+	cfctrl_linkdown_req(cfg->ctrl, channel_id, adap_layer);
=20
 	/* Do RCU sync before initiating cleanup */
 	synchronize_rcu();
 	if (adap_layer->ctrlcmd !=3D NULL)
 		adap_layer->ctrlcmd(adap_layer, CAIF_CTRLCMD_DEINIT_RSP, 0);
-	return ret;
+	return 0;
=20
 }
 EXPORT_SYMBOL(caif_disconnect_client);
@@ -400,6 +387,14 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channe=
l_id, enum cfctrl_srv serv,
 	struct cfcnfg_phyinfo *phyinfo;
 	struct net_device *netdev;
=20
+	if (channel_id =3D=3D 0) {
+		pr_warn("received channel_id zero\n");
+		if (adapt_layer !=3D NULL && adapt_layer->ctrlcmd !=3D NULL)
+			adapt_layer->ctrlcmd(adapt_layer,
+						CAIF_CTRLCMD_INIT_FAIL_RSP, 0);
+		return;
+	}
+
 	rcu_read_lock();
=20
 	if (adapt_layer =3D=3D NULL) {
@@ -523,7 +518,6 @@ got_phyid:
 	phyinfo->use_stx =3D stx;
 	phyinfo->use_fcs =3D fcs;
=20
-	phy_layer->type =3D phy_type;
 	frml =3D cffrml_create(phyid, fcs);
=20
 	if (!frml) {
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 2a56df7..3a66b8c 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -62,16 +62,6 @@ struct cflayer *cfmuxl_create(void)
 	return &this->layer;
 }
=20
-int cfmuxl_set_uplayer(struct cflayer *layr, struct cflayer *up, u8 li=
nkid)
-{
-	struct cfmuxl *muxl =3D container_obj(layr);
-
-	spin_lock_bh(&muxl->receive_lock);
-	list_add_rcu(&up->node, &muxl->srvl_list);
-	spin_unlock_bh(&muxl->receive_lock);
-	return 0;
-}
-
 int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *dn, u8 ph=
yid)
 {
 	struct cfmuxl *muxl =3D (struct cfmuxl *) layr;
@@ -93,6 +83,24 @@ static struct cflayer *get_from_id(struct list_head =
*list, u16 id)
 	return NULL;
 }
=20
+int cfmuxl_set_uplayer(struct cflayer *layr, struct cflayer *up, u8 li=
nkid)
+{
+	struct cfmuxl *muxl =3D container_obj(layr);
+	struct cflayer *old;
+
+	spin_lock_bh(&muxl->receive_lock);
+
+	/* Two entries with same id is wrong, so remove old layer from mux */
+	old =3D get_from_id(&muxl->srvl_list, linkid);
+	if (old !=3D NULL)
+		list_del_rcu(&old->node);
+
+	list_add_rcu(&up->node, &muxl->srvl_list);
+	spin_unlock_bh(&muxl->receive_lock);
+
+	return 0;
+}
+
 struct cflayer *cfmuxl_remove_dnlayer(struct cflayer *layr, u8 phyid)
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
@@ -146,6 +154,11 @@ struct cflayer *cfmuxl_remove_uplayer(struct cflay=
er *layr, u8 id)
 	struct cfmuxl *muxl =3D container_obj(layr);
 	int idx =3D id % UP_CACHE_SIZE;
=20
+	if (id =3D=3D 0) {
+		pr_warn("Trying to remove control layer\n");
+		return NULL;
+	}
+
 	spin_lock_bh(&muxl->receive_lock);
 	up =3D get_from_id(&muxl->srvl_list, id);
 	if (up =3D=3D NULL)
@@ -235,12 +248,26 @@ static void cfmuxl_ctrlcmd(struct cflayer *layr, =
enum caif_ctrlcmd ctrl,
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
 	struct cflayer *layer;
+	int idx;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(layer, &muxl->srvl_list, node) {
-		if (cfsrvl_phyid_match(layer, phyid) && layer->ctrlcmd)
+
+		if (cfsrvl_phyid_match(layer, phyid) && layer->ctrlcmd) {
+
+			if ((ctrl =3D=3D _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND ||
+				ctrl =3D=3D CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND) &&
+					layer->id !=3D 0) {
+
+				idx =3D layer->id % UP_CACHE_SIZE;
+				spin_lock_bh(&muxl->receive_lock);
+				rcu_assign_pointer(muxl->up_cache[idx], NULL);
+				list_del_rcu(&layer->node);
+				spin_unlock_bh(&muxl->receive_lock);
+			}
 			/* NOTE: ctrlcmd is not allowed to block */
 			layer->ctrlcmd(layer, ctrl, phyid);
+		}
 	}
 	rcu_read_unlock();
 }
--=20
1.7.0.4

