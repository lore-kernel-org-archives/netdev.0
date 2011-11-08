From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] [RFC] net-netlink: fix tos/tclass for dual-stack ipv6 sockets
Date: Mon,  7 Nov 2011 17:46:40 -0800
Message-ID: <1320716800-9151-1-git-send-email-zenczykowski@gmail.com>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:59544 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877Ab1KHBqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 20:46:53 -0500
Received: by qyk27 with SMTP id 27so3115947qyk.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 17:46:52 -0800 (PST)
In-Reply-To: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Something along the following lines would be needed.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 include/net/ipv6.h   |   52 ++++++++++++++++++++++++++++++++++++++++++=
++++++++
 net/ipv4/inet_diag.c |   11 +++++----
 2 files changed, 58 insertions(+), 5 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3b5ac1f..50c7a3b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -465,6 +465,58 @@ static inline int ipv6_addr_diff(const struct in6_=
addr *a1, const struct in6_add
=20
 extern void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *=
rt);
=20
+/* Return true for:
+ *   - an IPv4 socket (listening or connected)
+ *   - an IPv4 connection on a dual-stack IPv6 socket
+ *   - an IPv6 dual-stack listening socket -> can later accept IPv4 co=
nnection
+ */
+static inline bool sk_might_be_ipv4(struct sock *sk) {
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	const struct ipv6_pinfo *np;
+
+	if (!sk) return false;
+	if (sk->sk_family =3D=3D AF_INET) return true;
+	if (sk->sk_family !=3D AF_INET6) return false;
+	np =3D inet6_sk(sk);
+	if (np->ipv6only) return false;
+
+	if (ipv6_addr_v4mapped(&np->rcv_saddr)) return true;
+	if (!ipv6_addr_any(&np->rcv_saddr)) return false;
+
+	if (sk->sk_state =3D=3D TCP_LISTEN) return true;
+
+	if (ipv6_addr_v4mapped(&np->saddr)) return true;
+	return false;
+#else
+	return sk && (sk->sk_family =3D=3D AF_INET);
+#endif
+}
+
+/* Return true for:
+ *   - a native IPv6 connection
+ *   - a listening IPv6 socket
+ */
+static inline bool sk_might_be_ipv6(struct sock *sk) {
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	const struct ipv6_pinfo *np;
+
+	if (!sk) return false;
+	if (sk->sk_family !=3D AF_INET6) return false;
+	np =3D inet6_sk(sk);
+	if (np->ipv6only) return true;
+
+	if (ipv6_addr_v4mapped(&np->rcv_saddr)) return false;
+	if (!ipv6_addr_any(&np->rcv_saddr)) return true;
+
+	if (sk->sk_state =3D=3D TCP_LISTEN) return true;
+
+	if (ipv6_addr_v4mapped(&np->saddr)) return false;
+	return true;
+#else
+	return false;
+#endif
+}
+
 /*
  *	Prototypes exported by ipv6
  */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 68e8ac5..39bc97c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -108,9 +108,6 @@ static int inet_csk_diag_fill(struct sock *sk,
 		       icsk->icsk_ca_ops->name);
 	}
=20
-	if ((ext & (1 << (INET_DIAG_TOS - 1))) && (sk->sk_family !=3D AF_INET=
6))
-		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
-
 	r->idiag_family =3D sk->sk_family;
 	r->idiag_state =3D sk->sk_state;
 	r->idiag_timer =3D 0;
@@ -125,7 +122,13 @@ static int inet_csk_diag_fill(struct sock *sk,
 	r->id.idiag_src[0] =3D inet->inet_rcv_saddr;
 	r->id.idiag_dst[0] =3D inet->inet_daddr;
=20
+	if ((ext & (1 << (INET_DIAG_TOS - 1))) && sk_might_be_ipv4(sk))
+		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
+
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	if ((ext & (1 << (INET_DIAG_TCLASS - 1))) && sk_might_be_ipv6(sk))
+		RTA_PUT_U8(skb, INET_DIAG_TCLASS, inet6_sk(sk)->tclass);
+
 	if (r->idiag_family =3D=3D AF_INET6) {
 		const struct ipv6_pinfo *np =3D inet6_sk(sk);
=20
@@ -133,8 +136,6 @@ static int inet_csk_diag_fill(struct sock *sk,
 			       &np->rcv_saddr);
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
 			       &np->daddr);
-		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
-			RTA_PUT_U8(skb, INET_DIAG_TCLASS, np->tclass);
 	}
 #endif
=20
--=20
1.7.3.1
