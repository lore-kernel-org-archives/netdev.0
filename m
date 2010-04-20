From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v4 10/14] l2tp: Convert rwlock to RCU
Date: Tue, 20 Apr 2010 18:55:53 +0200
Message-ID: <1271782553.7895.62.camel@edumazet-laptop>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>
	 <20100402161916.11367.32252.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44040 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab0DTQ4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 12:56:05 -0400
Received: by bwz19 with SMTP id 19so175445bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 09:56:01 -0700 (PDT)
In-Reply-To: <20100402161916.11367.32252.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 17:19 +0100, James Chapman a =C3=A9cri=
t :
> Reader/write locks are discouraged because they are slower than spin
> locks. So this patch converts the rwlocks used in the per_net structs
> to rcu.
>=20
> Signed-off-by: James Chapman <jchapman@katalix.com>

>  static inline struct l2tp_net *l2tp_pernet(struct net *net)
> @@ -139,14 +140,14 @@ static struct l2tp_session *l2tp_session_find_2=
(struct net *net, u32 session_id)
>  	struct l2tp_session *session;
>  	struct hlist_node *walk;
> =20
> -	read_lock_bh(&pn->l2tp_session_hlist_lock);
> -	hlist_for_each_entry(session, walk, session_list, global_hlist) {
> +	rcu_read_lock_bh();
> +	hlist_for_each_entry_rcu(session, walk, session_list, global_hlist)=
 {
>  		if (session->session_id =3D=3D session_id) {
> -			read_unlock_bh(&pn->l2tp_session_hlist_lock);
> +			rcu_read_unlock_bh();
>  			return session;
>  		}
>  	}
> -	read_unlock_bh(&pn->l2tp_session_hlist_lock);
> +	rcu_read_unlock_bh();
> =20

Hi James

I started a while ago patching l2tp but I wont be able to finish and
test the thing...

There is a fundamental problem with this kind of construct :
(this was wrong even better your RCU conversion)

rcu_read_lock_bh()
hlist_for_each_entry_rcu(session, walk, session_list, global_hlist) {
	if (session->session_id =3D=3D session_id) {
		rcu_read_unlock_bh();
		return session;
	}
}
rcu_read_unlock_bh();


While the lookup _is_ protected, the result is not.

As soon as you call rcu_read_unlock_bh(); and before the "return
session;", current thread could be preempted and an other thread frees
session under first thread. Unexpected things can then happen.

Therefore, you need either to :

1) Take a refcount on session (or tunnel) before the return
2) Or move the rcu_read_lock_bh()/rcu_read_unlock_bh() at callers.
3) Or all callers use a stronger lock. But then, why use RCU ;)

Here is a preliminary patch, obviously not finished, nor compiled, nor
tested, to give possible ways to handle this problem.

(I added the ref parameter to make sure to change function signatures,
maybe its not necessary and we should always take references)

Thanks

 net/l2tp/l2tp_core.c    |   25 ++++++++++++++-----------
 net/l2tp/l2tp_core.h    |    6 +++---
 net/l2tp/l2tp_debugfs.c |    2 +-
 net/l2tp/l2tp_eth.c     |    4 ++--
 net/l2tp/l2tp_ip.c      |    8 +++++---
 net/l2tp/l2tp_netlink.c |   26 +++++++++++++-------------
 6 files changed, 38 insertions(+), 33 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ecc7aea..e662659 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -132,7 +132,7 @@ l2tp_session_id_hash_2(struct l2tp_net *pn, u32 ses=
sion_id)
=20
 /* Lookup a session by id in the global session list
  */
-static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 s=
ession_id)
+static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 s=
ession_id, int ref)
 {
 	struct l2tp_net *pn =3D l2tp_pernet(net);
 	struct hlist_head *session_list =3D
@@ -143,6 +143,8 @@ static struct l2tp_session *l2tp_session_find_2(str=
uct net *net, u32 session_id)
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(session, walk, session_list, global_hlist) {
 		if (session->session_id =3D=3D session_id) {
+			if (ref)
+				l2tp_session_inc_refcount(session);
 			rcu_read_unlock_bh();
 			return session;
 		}
@@ -166,7 +168,7 @@ l2tp_session_id_hash(struct l2tp_tunnel *tunnel, u3=
2 session_id)
=20
 /* Lookup a session by id
  */
-struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tu=
nnel *tunnel, u32 session_id)
+struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tu=
nnel *tunnel, u32 session_id, int ref)
 {
 	struct hlist_head *session_list;
 	struct l2tp_session *session;
@@ -177,12 +179,14 @@ struct l2tp_session *l2tp_session_find(struct net=
 *net, struct l2tp_tunnel *tunn
 	 * tunnel.
 	 */
 	if (tunnel =3D=3D NULL)
-		return l2tp_session_find_2(net, session_id);
+		return l2tp_session_find_2(net, session_id, ref);
=20
 	session_list =3D l2tp_session_id_hash(tunnel, session_id);
 	read_lock_bh(&tunnel->hlist_lock);
 	hlist_for_each_entry(session, walk, session_list, hlist) {
 		if (session->session_id =3D=3D session_id) {
+			if (ref)
+				l2tp_session_inc_refcount(session);
 			read_unlock_bh(&tunnel->hlist_lock);
 			return session;
 		}
@@ -193,7 +197,7 @@ struct l2tp_session *l2tp_session_find(struct net *=
net, struct l2tp_tunnel *tunn
 }
 EXPORT_SYMBOL_GPL(l2tp_session_find);
=20
-struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel,=
 int nth)
+struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel,=
 int nth, int ref)
 {
 	int hash;
 	struct hlist_node *walk;
@@ -204,6 +208,8 @@ struct l2tp_session *l2tp_session_find_nth(struct l=
2tp_tunnel *tunnel, int nth)
 	for (hash =3D 0; hash < L2TP_HASH_SIZE; hash++) {
 		hlist_for_each_entry(session, walk, &tunnel->session_hlist[hash], hl=
ist) {
 			if (++count > nth) {
+				if (ref)
+					l2tp_session_inc_refcount(session);
 				read_unlock_bh(&tunnel->hlist_lock);
 				return session;
 			}
@@ -244,7 +250,7 @@ EXPORT_SYMBOL_GPL(l2tp_session_find_by_ifname);
=20
 /* Lookup a tunnel by id
  */
-struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id)
+struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id, i=
nt ref)
 {
 	struct l2tp_tunnel *tunnel;
 	struct l2tp_net *pn =3D l2tp_pernet(net);
@@ -252,6 +258,8 @@ struct l2tp_tunnel *l2tp_tunnel_find(struct net *ne=
t, u32 tunnel_id)
 	rcu_read_lock_bh();
 	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
 		if (tunnel->tunnel_id =3D=3D tunnel_id) {
+			if (ref)
+				l2tp_tunnel_inc_refcount(tunnel);
 			rcu_read_unlock_bh();
 			return tunnel;
 		}
@@ -500,11 +508,6 @@ void l2tp_recv_common(struct l2tp_session *session=
, struct sk_buff *skb,
 	int offset;
 	u32 ns, nr;
=20
-	/* The ref count is increased since we now hold a pointer to
-	 * the session. Take care to decrement the refcnt when exiting
-	 * this function from now on...
-	 */
-	l2tp_session_inc_refcount(session);
 	if (session->ref)
 		(*session->ref)(session);
=20
@@ -785,7 +788,7 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, =
struct sk_buff *skb,
 	}
=20
 	/* Find the session context */
-	session =3D l2tp_session_find(tunnel->l2tp_net, tunnel, session_id);
+	session =3D l2tp_session_find(tunnel->l2tp_net, tunnel, session_id, 1=
);
 	if (!session || !session->recv_skb) {
 		/* Not found? Pass to userspace to deal with */
 		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index f0f318e..51df82e 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -221,10 +221,10 @@ out:
 	return tunnel;
 }
=20
-extern struct l2tp_session *l2tp_session_find(struct net *net, struct =
l2tp_tunnel *tunnel, u32 session_id);
-extern struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *=
tunnel, int nth);
+extern struct l2tp_session *l2tp_session_find(struct net *net, struct =
l2tp_tunnel *tunnel, u32 session_id, int ref);
+extern struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *=
tunnel, int nth, int ref);
 extern struct l2tp_session *l2tp_session_find_by_ifname(struct net *ne=
t, char *ifname);
-extern struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunne=
l_id);
+extern struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunne=
l_id, int ref);
 extern struct l2tp_tunnel *l2tp_tunnel_find_nth(struct net *net, int n=
th);
=20
 extern int l2tp_tunnel_create(struct net *net, int fd, int version, u3=
2 tunnel_id, u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg, struct l2=
tp_tunnel **tunnelp);
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 104ec3b..a7ecda2 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -51,7 +51,7 @@ static void l2tp_dfs_next_tunnel(struct l2tp_dfs_seq_=
data *pd)
=20
 static void l2tp_dfs_next_session(struct l2tp_dfs_seq_data *pd)
 {
-	pd->session =3D l2tp_session_find_nth(pd->tunnel, pd->session_idx);
+	pd->session =3D l2tp_session_find_nth(pd->tunnel, pd->session_idx, 0)=
;
 	pd->session_idx++;
=20
 	if (pd->session =3D=3D NULL) {
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index ca1164a..b069447 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -194,13 +194,13 @@ static int l2tp_eth_create(struct net *net, u32 t=
unnel_id, u32 session_id, u32 p
 	int rc;
 	struct l2tp_eth_net *pn;
=20
-	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
+	tunnel =3D l2tp_tunnel_find(net, tunnel_id, 0);
 	if (!tunnel) {
 		rc =3D -ENODEV;
 		goto out;
 	}
=20
-	session =3D l2tp_session_find(net, tunnel, session_id);
+	session =3D l2tp_session_find(net, tunnel, session_id, 0);
 	if (session) {
 		rc =3D -EEXIST;
 		goto out;
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 0852512..dbd7b7f 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -126,7 +126,7 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 	u32 session_id;
 	u32 tunnel_id;
 	unsigned char *ptr, *optr;
-	struct l2tp_session *session;
+	struct l2tp_session *session =3D NULL;
 	struct l2tp_tunnel *tunnel =3D NULL;
 	int length;
 	int offset;
@@ -150,7 +150,7 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 	}
=20
 	/* Ok, this is a data packet. Lookup the session. */
-	session =3D l2tp_session_find(&init_net, NULL, session_id);
+	session =3D l2tp_session_find(&init_net, NULL, session_id, 1);
 	if (session =3D=3D NULL)
 		goto discard;
=20
@@ -187,7 +187,7 @@ pass_up:
 		goto discard;
=20
 	tunnel_id =3D ntohl(*(__be32 *) &skb->data[4]);
-	tunnel =3D l2tp_tunnel_find(&init_net, tunnel_id);
+	tunnel =3D l2tp_tunnel_find(&init_net, tunnel_id, 0);
 	if (tunnel !=3D NULL)
 		sk =3D tunnel->sock;
 	else {
@@ -214,6 +214,8 @@ discard_put:
 	sock_put(sk);
=20
 discard:
+	if (session)
+		l2tp_session_dec_refcount(session);
 	kfree_skb(skb);
 	return 0;
 }
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 4c1e540..5f42d48 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -40,7 +40,7 @@ static struct genl_family l2tp_nl_family =3D {
 /* Accessed under genl lock */
 static const struct l2tp_nl_cmd_ops *l2tp_nl_cmd_ops[__L2TP_PWTYPE_MAX=
];
=20
-static struct l2tp_session *l2tp_nl_session_find(struct genl_info *inf=
o)
+static struct l2tp_session *l2tp_nl_session_find(struct genl_info *inf=
o, int ref)
 {
 	u32 tunnel_id;
 	u32 session_id;
@@ -56,9 +56,9 @@ static struct l2tp_session *l2tp_nl_session_find(stru=
ct genl_info *info)
 		   (info->attrs[L2TP_ATTR_CONN_ID])) {
 		tunnel_id =3D nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
 		session_id =3D nla_get_u32(info->attrs[L2TP_ATTR_SESSION_ID]);
-		tunnel =3D l2tp_tunnel_find(net, tunnel_id);
+		tunnel =3D l2tp_tunnel_find(net, tunnel_id, 0);
 		if (tunnel)
-			session =3D l2tp_session_find(net, tunnel, session_id);
+			session =3D l2tp_session_find(net, tunnel, session_id, ref);
 	}
=20
 	return session;
@@ -148,7 +148,7 @@ static int l2tp_nl_cmd_tunnel_create(struct sk_buff=
 *skb, struct genl_info *info
 	if (info->attrs[L2TP_ATTR_DEBUG])
 		cfg.debug =3D nla_get_u32(info->attrs[L2TP_ATTR_DEBUG]);
=20
-	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
+	tunnel =3D l2tp_tunnel_find(net, tunnel_id, 0);
 	if (tunnel !=3D NULL) {
 		ret =3D -EEXIST;
 		goto out;
@@ -180,7 +180,7 @@ static int l2tp_nl_cmd_tunnel_delete(struct sk_buff=
 *skb, struct genl_info *info
 	}
 	tunnel_id =3D nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
=20
-	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
+	tunnel =3D l2tp_tunnel_find(net, tunnel_id, 0);
 	if (tunnel =3D=3D NULL) {
 		ret =3D -ENODEV;
 		goto out;
@@ -205,7 +205,7 @@ static int l2tp_nl_cmd_tunnel_modify(struct sk_buff=
 *skb, struct genl_info *info
 	}
 	tunnel_id =3D nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
=20
-	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
+	tunnel =3D l2tp_tunnel_find(net, tunnel_id, 0);
 	if (tunnel =3D=3D NULL) {
 		ret =3D -ENODEV;
 		goto out;
@@ -292,7 +292,7 @@ static int l2tp_nl_cmd_tunnel_get(struct sk_buff *s=
kb, struct genl_info *info)
=20
 	tunnel_id =3D nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
=20
-	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
+	tunnel =3D l2tp_tunnel_find(net, tunnel_id, 0);
 	if (tunnel =3D=3D NULL) {
 		ret =3D -ENODEV;
 		goto out;
@@ -359,7 +359,7 @@ static int l2tp_nl_cmd_session_create(struct sk_buf=
f *skb, struct genl_info *inf
 		goto out;
 	}
 	tunnel_id =3D nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
-	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
+	tunnel =3D l2tp_tunnel_find(net, tunnel_id, 0);
 	if (!tunnel) {
 		ret =3D -ENODEV;
 		goto out;
@@ -370,7 +370,7 @@ static int l2tp_nl_cmd_session_create(struct sk_buf=
f *skb, struct genl_info *inf
 		goto out;
 	}
 	session_id =3D nla_get_u32(info->attrs[L2TP_ATTR_SESSION_ID]);
-	session =3D l2tp_session_find(net, tunnel, session_id);
+	session =3D l2tp_session_find(net, tunnel, session_id, 0);
 	if (session) {
 		ret =3D -EEXIST;
 		goto out;
@@ -495,7 +495,7 @@ static int l2tp_nl_cmd_session_delete(struct sk_buf=
f *skb, struct genl_info *inf
 	struct l2tp_session *session;
 	u16 pw_type;
=20
-	session =3D l2tp_nl_session_find(info);
+	session =3D l2tp_nl_session_find(info, 0);
 	if (session =3D=3D NULL) {
 		ret =3D -ENODEV;
 		goto out;
@@ -515,7 +515,7 @@ static int l2tp_nl_cmd_session_modify(struct sk_buf=
f *skb, struct genl_info *inf
 	int ret =3D 0;
 	struct l2tp_session *session;
=20
-	session =3D l2tp_nl_session_find(info);
+	session =3D l2tp_nl_session_find(info, 1);
 	if (session =3D=3D NULL) {
 		ret =3D -ENODEV;
 		goto out;
@@ -615,7 +615,7 @@ static int l2tp_nl_cmd_session_get(struct sk_buff *=
skb, struct genl_info *info)
 	struct sk_buff *msg;
 	int ret;
=20
-	session =3D l2tp_nl_session_find(info);
+	session =3D l2tp_nl_session_find(info, 0);
 	if (session =3D=3D NULL) {
 		ret =3D -ENODEV;
 		goto out;
@@ -656,7 +656,7 @@ static int l2tp_nl_cmd_session_dump(struct sk_buff =
*skb, struct netlink_callback
 				goto out;
 		}
=20
-		session =3D l2tp_session_find_nth(tunnel, si);
+		session =3D l2tp_session_find_nth(tunnel, si, 0);
 		if (session =3D=3D NULL) {
 			ti++;
 			tunnel =3D NULL;







