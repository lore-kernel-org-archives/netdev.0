From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] ipv6: Fix inet6_csk_bind_conflict so it builds with user namespaces enabled
Date: Tue, 29 Jan 2013 04:16:18 -0800
Message-ID: <871ud4chgt.fsf@xmission.com>
References: <alpine.DEB.2.00.1301201542470.2060@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netdev@markandruth.co.uk,
	eric.dumazet@gmail.com, Tom Herbert <therbert@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36166 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab3A2MQd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 07:16:33 -0500
In-Reply-To: <alpine.DEB.2.00.1301201542470.2060@pokey.mtv.corp.google.com>
	(Tom Herbert's message of "Sun, 20 Jan 2013 16:07:48 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When attempting to build linux-next with user namespaces enabled I ran
into this fun build error.

  CC      net/ipv6/inet6_connection_sock.o
=2E../net/ipv6/inet6_connection_sock.c: In function =E2=80=98inet6_csk_=
bind_conflict=E2=80=99:
=2E../net/ipv6/inet6_connection_sock.c:37:12: error: incompatible types=
 when initializing type =E2=80=98int=E2=80=99 using
 type =E2=80=98kuid_t=E2=80=99
=2E../net/ipv6/inet6_connection_sock.c:54:30: error: incompatible type =
for argument 1 of =E2=80=98uid_eq=E2=80=99
=2E../include/linux/uidgid.h:48:20: note: expected =E2=80=98kuid_t=E2=80=
=99 but argument is of type =E2=80=98int=E2=80=99
make[3]: *** [net/ipv6/inet6_connection_sock.o] Error 1
make[2]: *** [net/ipv6] Error 2
make[2]: *** Waiting for unfinished jobs....

Using kuid_t instead of int to hold the uid fixes this.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/inet6_connection_sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index e4297a3..b386a2c 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -34,7 +34,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 	const struct hlist_node *node;
 	int reuse =3D sk->sk_reuse;
 	int reuseport =3D sk->sk_reuseport;
-	int uid =3D sock_i_uid((struct sock *)sk);
+	kuid_t uid =3D sock_i_uid((struct sock *)sk);
=20
 	/* We must walk the whole port owner list in this case. -DaveM */
 	/*
--=20
1.7.5.4
