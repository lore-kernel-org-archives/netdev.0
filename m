From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netlink: use kfree_rcu() in netlink_release()
Date: Thu, 18 Oct 2012 15:21:55 +0200
Message-ID: <1350566515.26103.1549.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?St=E9phane?= Marchesin <marcheu@google.com>,
	Jonathan Kliegman <kliegs@google.com>,
	Sam Leffler <sleffler@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50058 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458Ab2JRNWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 09:22:00 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so4148369bkc.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 06:21:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

On some suspend/resume operations involving wimax device, we have
noticed some intermittent memory corruptions in netlink code.

St=C3=A9phane Marchesin tracked this corruption in netlink_update_liste=
ners()
and suggested a patch.

It appears netlink_release() should use kfree_rcu() instead of kfree()
for the listeners structure as it may be used by other cpus using RCU
protection.

netlink_release() must set to NULL the listeners pointer when
it is about to be freed.

Also have to protect netlink_update_listeners() and
netlink_has_listeners() if listeners is NULL.

Add a nl_deref_protected() lockdep helper to properly document which
locks protects us.

Reported-by: Jonathan Kliegman <kliegs@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: St=C3=A9phane Marchesin <marcheu@google.com>
Cc: Sam Leffler <sleffler@google.com>
---
 net/netlink/af_netlink.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 01e944a..4da797f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -138,6 +138,8 @@ static int netlink_dump(struct sock *sk);
 static DEFINE_RWLOCK(nl_table_lock);
 static atomic_t nl_table_users =3D ATOMIC_INIT(0);
=20
+#define nl_deref_protected(X) rcu_dereference_protected(X, lockdep_is_=
held(&nl_table_lock));
+
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
=20
 static inline u32 netlink_group_mask(u32 group)
@@ -345,6 +347,11 @@ netlink_update_listeners(struct sock *sk)
 	struct hlist_node *node;
 	unsigned long mask;
 	unsigned int i;
+	struct listeners *listeners;
+
+	listeners =3D nl_deref_protected(tbl->listeners);
+	if (!listeners)
+		return;
=20
 	for (i =3D 0; i < NLGRPLONGS(tbl->groups); i++) {
 		mask =3D 0;
@@ -352,7 +359,7 @@ netlink_update_listeners(struct sock *sk)
 			if (i < NLGRPLONGS(nlk_sk(sk)->ngroups))
 				mask |=3D nlk_sk(sk)->groups[i];
 		}
-		tbl->listeners->masks[i] =3D mask;
+		listeners->masks[i] =3D mask;
 	}
 	/* this function is only called with the netlink table "grabbed", whi=
ch
 	 * makes sure updates are visible before bind or setsockopt return. *=
/
@@ -536,7 +543,11 @@ static int netlink_release(struct socket *sock)
 	if (netlink_is_kernel(sk)) {
 		BUG_ON(nl_table[sk->sk_protocol].registered =3D=3D 0);
 		if (--nl_table[sk->sk_protocol].registered =3D=3D 0) {
-			kfree(nl_table[sk->sk_protocol].listeners);
+			struct listeners *old;
+
+			old =3D nl_deref_protected(nl_table[sk->sk_protocol].listeners);
+			RCU_INIT_POINTER(nl_table[sk->sk_protocol].listeners, NULL);
+			kfree_rcu(old, rcu);
 			nl_table[sk->sk_protocol].module =3D NULL;
 			nl_table[sk->sk_protocol].bind =3D NULL;
 			nl_table[sk->sk_protocol].flags =3D 0;
@@ -982,7 +993,7 @@ int netlink_has_listeners(struct sock *sk, unsigned=
 int group)
 	rcu_read_lock();
 	listeners =3D rcu_dereference(nl_table[sk->sk_protocol].listeners);
=20
-	if (group - 1 < nl_table[sk->sk_protocol].groups)
+	if (listeners && group - 1 < nl_table[sk->sk_protocol].groups)
 		res =3D test_bit(group - 1, listeners->masks);
=20
 	rcu_read_unlock();
@@ -1625,7 +1636,7 @@ int __netlink_change_ngroups(struct sock *sk, uns=
igned int groups)
 		new =3D kzalloc(sizeof(*new) + NLGRPSZ(groups), GFP_ATOMIC);
 		if (!new)
 			return -ENOMEM;
-		old =3D rcu_dereference_protected(tbl->listeners, 1);
+		old =3D nl_deref_protected(tbl->listeners);
 		memcpy(new->masks, old->masks, NLGRPSZ(tbl->groups));
 		rcu_assign_pointer(tbl->listeners, new);
=20
