From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Wed, 22 Sep 2010 10:38:01 +0200
Message-ID: <1285144681.2639.102.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
	 <1285064011.2617.238.camel@edumazet-laptop>
	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
	 <1285144306.2639.90.camel@edumazet-laptop>
	 <1285144471.2639.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1285144471.2639.96.camel@edumazet-laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 septembre 2010 =C3=A0 10:34 +0200, Eric Dumazet a =C3=A9=
crit :

> small bug in my patch , please delete the orphan line :
>=20
> >  			af_callback_keys + sk->sk_family,
>=20
>=20
> >  			af_family_clock_key_strings[sk->sk_family]);
> > =20
>=20

Updated and booted/tested patch :

 include/net/sock.h |    1 +
 net/core/sock.c    |    8 ++++++--
 net/ipv4/udp.c     |    3 +++
 net/ipv4/udplite.c |    3 +++
 net/ipv6/udp.c     |    3 +++
 net/ipv6/udplite.c |    3 +++
 6 files changed, 19 insertions(+), 2 deletions(-)


diff --git a/include/net/sock.h b/include/net/sock.h
index adab9dc..c5104bc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -800,6 +800,7 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
+	struct lock_class_key *callback_key;
 };
=20
 extern int proto_register(struct proto *prot, int alloc_slab);
diff --git a/net/core/sock.c b/net/core/sock.c
index b05b9b6..79ef50a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1210,7 +1210,9 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
 		spin_lock_init(&newsk->sk_dst_lock);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
-				af_callback_keys + newsk->sk_family,
+				sk->sk_prot->callback_key ?
+					sk->sk_prot->callback_key :
+					af_callback_keys + newsk->sk_family,
 				af_family_clock_key_strings[newsk->sk_family]);
=20
 		newsk->sk_dst_cache	=3D NULL;
@@ -1965,7 +1967,9 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
 	spin_lock_init(&sk->sk_dst_lock);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
-			af_callback_keys + sk->sk_family,
+			sk->sk_prot->callback_key ?
+				sk->sk_prot->callback_key :
+				af_callback_keys + sk->sk_family,
 			af_family_clock_key_strings[sk->sk_family]);
=20
 	sk->sk_state_change	=3D	sock_def_wakeup;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fb23c2e..c0877b6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1870,6 +1870,8 @@ unsigned int udp_poll(struct file *file, struct s=
ocket *sock, poll_table *wait)
 }
 EXPORT_SYMBOL(udp_poll);
=20
+static struct lock_class_key udp_callback_key;
+
 struct proto udp_prot =3D {
 	.name		   =3D "UDP",
 	.owner		   =3D THIS_MODULE,
@@ -1899,6 +1901,7 @@ struct proto udp_prot =3D {
 	.compat_setsockopt =3D compat_udp_setsockopt,
 	.compat_getsockopt =3D compat_udp_getsockopt,
 #endif
+	.callback_key	   =3D &udp_callback_key,
 };
 EXPORT_SYMBOL(udp_prot);
=20
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index ab76aa9..51b159d 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -32,6 +32,8 @@ static const struct net_protocol udplite_protocol =3D=
 {
 	.netns_ok	=3D 1,
 };
=20
+static struct lock_class_key udplite_callback_key;
+
 struct proto 	udplite_prot =3D {
 	.name		   =3D "UDP-Lite",
 	.owner		   =3D THIS_MODULE,
@@ -57,6 +59,7 @@ struct proto 	udplite_prot =3D {
 	.compat_setsockopt =3D compat_udp_setsockopt,
 	.compat_getsockopt =3D compat_udp_getsockopt,
 #endif
+	.callback_key	   =3D &udplite_callback_key,
 };
 EXPORT_SYMBOL(udplite_prot);
=20
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5acb356..0777934 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1441,6 +1441,8 @@ void udp6_proc_exit(struct net *net) {
=20
 /* -------------------------------------------------------------------=
----- */
=20
+static struct lock_class_key udp6_callback_key;
+
 struct proto udpv6_prot =3D {
 	.name		   =3D "UDPv6",
 	.owner		   =3D THIS_MODULE,
@@ -1469,6 +1471,7 @@ struct proto udpv6_prot =3D {
 	.compat_setsockopt =3D compat_udpv6_setsockopt,
 	.compat_getsockopt =3D compat_udpv6_getsockopt,
 #endif
+	.callback_key	   =3D &udp6_callback_key,
 };
=20
 static struct inet_protosw udpv6_protosw =3D {
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 5f48fad..7bbb627 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -31,6 +31,8 @@ static const struct inet6_protocol udplitev6_protocol=
 =3D {
 	.flags		=3D	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
=20
+static struct lock_class_key udp6lite_callback_key;
+
 struct proto udplitev6_prot =3D {
 	.name		   =3D "UDPLITEv6",
 	.owner		   =3D THIS_MODULE,
@@ -55,6 +57,7 @@ struct proto udplitev6_prot =3D {
 	.compat_setsockopt =3D compat_udpv6_setsockopt,
 	.compat_getsockopt =3D compat_udpv6_getsockopt,
 #endif
+	.callback_key	   =3D &udp6lite_callback_key,
 };
=20
 static struct inet_protosw udplite6_protosw =3D {


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
