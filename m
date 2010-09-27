From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] net: sk_{detach|attach}_filter() rcu fixes
Date: Mon, 27 Sep 2010 18:07:30 +0200
Message-ID: <1285603650.3017.57.camel@edumazet-laptop>
References: <1285603064.3017.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37877 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756812Ab0I0QIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 12:08:32 -0400
Received: by eyb6 with SMTP id 6so1419711eyb.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 09:08:31 -0700 (PDT)
In-Reply-To: <1285603064.3017.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 septembre 2010 =C3=A0 17:57 +0200, Eric Dumazet a =C3=A9cri=
t :
> sk_attach_filter() is run with socket locked.
>=20
> Use the appropriate rcu_dereference_protected() instead of blocking B=
H,
> and rcu_dereference_bh().
> There is no point adding BH prevention and memory barrier.

Hmm, same thing can be done in sk_detach_filter, here is a v2.

Thanks

[PATCH net-next-2.6 v2] net: sk_{detach|attach}_filter() rcu fixes

sk_attach_filter() and sk_detach_filter() are run with socket locked.

Use the appropriate rcu_dereference_protected() instead of blocking BH,
and rcu_dereference_bh().
There is no point adding BH prevention and memory barrier.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/filter.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 52b051f..7adf503 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -638,10 +638,9 @@ int sk_attach_filter(struct sock_fprog *fprog, str=
uct sock *sk)
 		return err;
 	}
=20
-	rcu_read_lock_bh();
-	old_fp =3D rcu_dereference_bh(sk->sk_filter);
+	old_fp =3D rcu_dereference_protected(sk->sk_filter,
+					   sock_owned_by_user(sk));
 	rcu_assign_pointer(sk->sk_filter, fp);
-	rcu_read_unlock_bh();
=20
 	if (old_fp)
 		sk_filter_delayed_uncharge(sk, old_fp);
@@ -654,14 +653,13 @@ int sk_detach_filter(struct sock *sk)
 	int ret =3D -ENOENT;
 	struct sk_filter *filter;
=20
-	rcu_read_lock_bh();
-	filter =3D rcu_dereference_bh(sk->sk_filter);
+	filter =3D rcu_dereference_protected(sk->sk_filter,
+					   sock_owned_by_user(sk));
 	if (filter) {
 		rcu_assign_pointer(sk->sk_filter, NULL);
 		sk_filter_delayed_uncharge(sk, filter);
 		ret =3D 0;
 	}
-	rcu_read_unlock_bh();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(sk_detach_filter);


