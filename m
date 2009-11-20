From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 22:35:40 +0100
Message-ID: <4B070BAC.1090406@gmail.com>
References: <4B05D8DC.7020907@gmail.com> <4B0701E2.1070806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38187 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550AbZKTVfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 16:35:43 -0500
In-Reply-To: <4B0701E2.1070806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
>=20
> There is one more problem: this will break things like act_mirred + i=
fb,
> and other cases using skb->iif e.g. for filtering on virtual devices =
at
> the xmit path.
>=20

=46ollowing patch might help us to locate real uses of this obscure fie=
ld :)

[PATCH net-next-2.6] net: rename skb->iif to skb->skb_iif

To help grep games, rename iif to skb_iif

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ifb.c                 |    6 +++---
 include/linux/skbuff.h            |    4 ++--
 include/net/pkt_cls.h             |    4 ++--
 net/core/dev.c                    |    6 +++---
 net/core/skbuff.c                 |    2 +-
 net/netlabel/netlabel_unlabeled.c |    2 +-
 net/sched/act_mirred.c            |    2 +-
 net/sched/cls_flow.c              |    2 +-
 security/selinux/hooks.c          |    6 +++---
 security/smack/smack_lsm.c        |    4 ++--
 10 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 69c2566..f4081c0 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -99,7 +99,7 @@ static void ri_tasklet(unsigned long dev)
 		stats->tx_bytes +=3Dskb->len;
=20
 		rcu_read_lock();
-		skb->dev =3D dev_get_by_index_rcu(&init_net, skb->iif);
+		skb->dev =3D dev_get_by_index_rcu(&init_net, skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
@@ -107,7 +107,7 @@ static void ri_tasklet(unsigned long dev)
 			break;
 		}
 		rcu_read_unlock();
-		skb->iif =3D _dev->ifindex;
+		skb->skb_iif =3D _dev->ifindex;
=20
 		if (from & AT_EGRESS) {
 			dp->st_rx_frm_egr++;
@@ -172,7 +172,7 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
 	stats->rx_packets++;
 	stats->rx_bytes+=3Dskb->len;
=20
-	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->iif) {
+	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
 		dev_kfree_skb(skb);
 		stats->rx_dropped++;
 		return NETDEV_TX_OK;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 63f4742..89eed8c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -299,7 +299,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@nfctinfo: Relationship of this skb to the connection
  *	@nfct_reasm: netfilter conntrack re-assembly pointer
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
- *	@iif: ifindex of device we arrived on
+ *	@skb_iif: ifindex of device we arrived on
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
@@ -366,7 +366,7 @@ struct sk_buff {
 	struct nf_bridge_info	*nf_bridge;
 #endif
=20
-	int			iif;
+	int			skb_iif;
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 3dd210d..dd3031a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -343,9 +343,9 @@ tcf_match_indev(struct sk_buff *skb, char *indev)
 	struct net_device *dev;
=20
 	if (indev[0]) {
-		if  (!skb->iif)
+		if  (!skb->skb_iif)
 			return 0;
-		dev =3D __dev_get_by_index(dev_net(skb->dev), skb->iif);
+		dev =3D __dev_get_by_index(dev_net(skb->dev), skb->skb_iif);
 		if (!dev || strcmp(indev, dev->name))
 			return 0;
 	}
diff --git a/net/core/dev.c b/net/core/dev.c
index 9977288..09f3d6b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2287,7 +2287,7 @@ static int ing_filter(struct sk_buff *skb)
 	if (MAX_RED_LOOP < ttl++) {
 		printk(KERN_WARNING
 		       "Redir loop detected Dropping packet (%d->%d)\n",
-		       skb->iif, dev->ifindex);
+		       skb->skb_iif, dev->ifindex);
 		return TC_ACT_SHOT;
 	}
=20
@@ -2395,8 +2395,8 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (netpoll_receive_skb(skb))
 		return NET_RX_DROP;
=20
-	if (!skb->iif)
-		skb->iif =3D skb->dev->ifindex;
+	if (!skb->skb_iif)
+		skb->skb_iif =3D skb->dev->ifindex;
=20
 	null_or_orig =3D NULL;
 	orig_dev =3D skb->dev;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 739b8f4..bfa3e78 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -549,7 +549,7 @@ static void __copy_skb_header(struct sk_buff *new, =
const struct sk_buff *old)
 #endif
 	new->protocol		=3D old->protocol;
 	new->mark		=3D old->mark;
-	new->iif		=3D old->iif;
+	new->skb_iif		=3D old->skb_iif;
 	__nf_copy(new, old);
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_=
unlabeled.c
index 3dfe2ba..98ed22e 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1550,7 +1550,7 @@ int netlbl_unlabel_getattr(const struct sk_buff *=
skb,
 	struct netlbl_unlhsh_iface *iface;
=20
 	rcu_read_lock();
-	iface =3D netlbl_unlhsh_search_iface_def(skb->iif);
+	iface =3D netlbl_unlhsh_search_iface_def(skb->skb_iif);
 	if (iface =3D=3D NULL)
 		goto unlabel_getattr_nolabel;
 	switch (family) {
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 7974793..d329170 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -185,7 +185,7 @@ static int tcf_mirred(struct sk_buff *skb, struct t=
c_action *a,
 		skb2->tc_verd =3D SET_TC_FROM(skb2->tc_verd, at);
=20
 	skb2->dev =3D dev;
-	skb2->iif =3D skb->dev->ifindex;
+	skb2->skb_iif =3D skb->dev->ifindex;
 	dev_queue_xmit(skb2);
 	err =3D 0;
=20
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 9402a7f..e054c62 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -171,7 +171,7 @@ static u32 flow_get_proto_dst(const struct sk_buff =
*skb)
=20
 static u32 flow_get_iif(const struct sk_buff *skb)
 {
-	return skb->iif;
+	return skb->skb_iif;
 }
=20
 static u32 flow_get_priority(const struct sk_buff *skb)
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index bb230d5..83a4aad 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4085,7 +4085,7 @@ static int selinux_sock_rcv_skb_compat(struct soc=
k *sk, struct sk_buff *skb,
 	char *addrp;
=20
 	COMMON_AUDIT_DATA_INIT(&ad, NET);
-	ad.u.net.netif =3D skb->iif;
+	ad.u.net.netif =3D skb->skb_iif;
 	ad.u.net.family =3D family;
 	err =3D selinux_parse_skb(skb, &ad, &addrp, 1, NULL);
 	if (err)
@@ -4147,7 +4147,7 @@ static int selinux_socket_sock_rcv_skb(struct soc=
k *sk, struct sk_buff *skb)
 		return 0;
=20
 	COMMON_AUDIT_DATA_INIT(&ad, NET);
-	ad.u.net.netif =3D skb->iif;
+	ad.u.net.netif =3D skb->skb_iif;
 	ad.u.net.family =3D family;
 	err =3D selinux_parse_skb(skb, &ad, &addrp, 1, NULL);
 	if (err)
@@ -4159,7 +4159,7 @@ static int selinux_socket_sock_rcv_skb(struct soc=
k *sk, struct sk_buff *skb)
 		err =3D selinux_skb_peerlbl_sid(skb, family, &peer_sid);
 		if (err)
 			return err;
-		err =3D selinux_inet_sys_rcv_skb(skb->iif, addrp, family,
+		err =3D selinux_inet_sys_rcv_skb(skb->skb_iif, addrp, family,
 					       peer_sid, &ad);
 		if (err) {
 			selinux_netlbl_err(skb, err, 0);
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index c33b6bb..529c9ca 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -2602,7 +2602,7 @@ static int smack_socket_sock_rcv_skb(struct sock =
*sk, struct sk_buff *skb)
 #ifdef CONFIG_AUDIT
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_NET);
 	ad.a.u.net.family =3D sk->sk_family;
-	ad.a.u.net.netif =3D skb->iif;
+	ad.a.u.net.netif =3D skb->skb_iif;
 	ipv4_skb_to_auditdata(skb, &ad.a, NULL);
 #endif
 	/*
@@ -2757,7 +2757,7 @@ static int smack_inet_conn_request(struct sock *s=
k, struct sk_buff *skb,
 #ifdef CONFIG_AUDIT
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_NET);
 	ad.a.u.net.family =3D family;
-	ad.a.u.net.netif =3D skb->iif;
+	ad.a.u.net.netif =3D skb->skb_iif;
 	ipv4_skb_to_auditdata(skb, &ad.a, NULL);
 #endif
 	/*
