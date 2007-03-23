From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Established connections hash function
Date: Fri, 23 Mar 2007 00:11:26 -0700 (PDT)
Message-ID: <20070323.001126.40983698.davem@davemloft.net>
References: <1199CE22A40740D28833A585014BE559@XEON>
	<20070322.135834.74723088.davem@davemloft.net>
	<4602FD18.7060902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nikb@webmaster.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48478
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933900AbXCWHL0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 03:11:26 -0400
In-Reply-To: <4602FD18.7060902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 22 Mar 2007 23:03:04 +0100

> David Miller a =E9crit :
> > From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
> > Date: Thu, 22 Mar 2007 12:44:09 -0700
> >=20
> >>     People _have_ had problems. _I_ have had problems. And when
> >> someone with a few thousand drones under his control hoses your
> >> servers because he can do math and he leaves you with 20000-item
> >> long chains, _you_ will have problems.
> >=20
> > No need to further argue this point, the people that matter
> > (ie. me :-) understand it, don't worry..
>=20
> Yes, I recall having one big server hit two years ago by an attack on=
 tcp hash=20
> function. David sent me the patch to use jhash. It's performing well =
:)
>=20
> Welcome to the club :)

Ok, how about we put something like the following into 2.6.21?

I'm not looking for the hash perfectionist analysis, please bug the
heck off if that's what your reply is going to be about, don't bother
hitting the reply button I will ignore you.

I want to hear instead if this makes attackability markedly _HARDER_
than what we have now and I am sure beyond a shadow of a doubt that it
does.

The secret is inialized when the first ehash-using socket is created,
that's not perfect (bug off!) but it's better than doing the
initialization in inet_init() or {tcp,dccp}_init() as we'll have a
chance of at least some entropy when that first such socket is
created.  We definitely can't do it for the first AF_INET socket
creation, because icmp creates a bunch of SOCK_RAW inet sockets at
init time which would defeat the whole purpose of deferring this. :)

Thanks.

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtab=
les.h
index c28e424..668056b 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -19,6 +19,9 @@
 #include <linux/in6.h>
 #include <linux/ipv6.h>
 #include <linux/types.h>
+#include <linux/jhash.h>
+
+#include <net/inet_sock.h>
=20
 #include <net/ipv6.h>
=20
@@ -28,12 +31,11 @@ struct inet_hashinfo;
 static inline unsigned int inet6_ehashfn(const struct in6_addr *laddr,=
 const u16 lport,
 				const struct in6_addr *faddr, const __be16 fport)
 {
-	unsigned int hashent =3D (lport ^ (__force u16)fport);
+	u32 ports =3D (lport ^ (__force u16)fport);
=20
-	hashent ^=3D (__force u32)(laddr->s6_addr32[3] ^ faddr->s6_addr32[3])=
;
-	hashent ^=3D hashent >> 16;
-	hashent ^=3D hashent >> 8;
-	return hashent;
+	return jhash_3words((__force u32)laddr->s6_addr32[3],
+			    (__force u32)faddr->s6_addr32[3],
+			    ports, inet_ehash_secret);
 }
=20
 static inline int inet6_sk_ehashfn(const struct sock *sk)
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ce6da97..62daf21 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -19,6 +19,7 @@
=20
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/jhash.h>
=20
 #include <net/flow.h>
 #include <net/sock.h>
@@ -167,13 +168,15 @@ static inline void inet_sk_copy_descendant(struct=
 sock *sk_to,
=20
 extern int inet_sk_rebuild_header(struct sock *sk);
=20
+extern u32 inet_ehash_secret;
+extern void build_ehash_secret(void);
+
 static inline unsigned int inet_ehashfn(const __be32 laddr, const __u1=
6 lport,
 					const __be32 faddr, const __be16 fport)
 {
-	unsigned int h =3D ((__force __u32)laddr ^ lport) ^ ((__force __u32)f=
addr ^ (__force __u32)fport);
-	h ^=3D h >> 16;
-	h ^=3D h >> 8;
-	return h;
+	return jhash_2words((__force __u32) laddr ^ (__force __u32) faddr,
+			    ((__u32) lport) << 16 | (__force __u32)fport,
+			    inet_ehash_secret);
 }
=20
 static inline int inet_sk_ehashfn(const struct sock *sk)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cf358c8..308318a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -87,6 +87,7 @@
 #include <linux/init.h>
 #include <linux/poll.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/random.h>
=20
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -217,6 +218,16 @@ out:
 	return err;
 }
=20
+u32 inet_ehash_secret;
+EXPORT_SYMBOL(inet_ehash_secret);
+
+void build_ehash_secret(void)
+{
+	while (!inet_ehash_secret)
+		get_random_bytes(&inet_ehash_secret, 4);
+}
+EXPORT_SYMBOL(build_ehash_secret);
+
 /*
  *	Create an inet socket.
  */
@@ -233,6 +244,11 @@ static int inet_create(struct socket *sock, int pr=
otocol)
 	int try_loading_module =3D 0;
 	int err;
=20
+	if (sock->type !=3D SOCK_RAW &&
+	    sock->type !=3D SOCK_DGRAM &&
+	    !inet_ehash_secret)
+		build_ehash_secret();
+
 	sock->state =3D SS_UNCONNECTED;
=20
 	/* Look for the requested type/protocol pair. */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 5cac14a..0de723f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -98,6 +98,11 @@ static int inet6_create(struct socket *sock, int pro=
tocol)
 	int try_loading_module =3D 0;
 	int err;
=20
+	if (sock->type !=3D SOCK_RAW &&
+	    sock->type !=3D SOCK_DGRAM &&
+	    !inet_ehash_secret)
+		build_ehash_secret();
+
 	/* Look for the requested type/protocol pair. */
 	answer =3D NULL;
 lookup_protocol:
