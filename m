From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Fix Netid value for multi-families output
Date: Tue, 28 Jan 2014 10:24:15 +0400
Message-ID: <52E74D0F.4050806@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:39242 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaA1GYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 01:24:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When requesting simultaneous output of TCP and UDP sockets
the netid field shows "tcp" always.

[root@xemvm1 iproute2]# ./misc/ss -a -tu
Netid State      Recv-Q Send-Q                            Local Address=
:Port                                Peer Address:Port  =20
tcp   UNCONN     0      0                                             *=
:32713                                          *:*      =20
tcp   UNCONN     0      0                                             *=
:bootpc                                         *:*      =20
tcp   UNCONN     0      0                                            ::=
:57879                                         :::*      =20
tcp   LISTEN     0      128                                           *=
:ssh                                            *:*      =20
tcp   ESTAB      0      48                                      1.2.3.5=
:ssh                                      1.2.3.4:45826  =20
tcp   ESTAB      0      0                                       1.2.3.5=
:ssh                                      1.2.3.4:45814  =20
tcp   LISTEN     0      128                                          ::=
:ssh                                           :::*      =20

While the 1st 3 sockets are UDP ones:

[root@xemvm1 iproute2]# ./misc/ss -a -u
State       Recv-Q Send-Q                              Local Address:Po=
rt                                  Peer Address:Port  =20
UNCONN      0      0                                               *:32=
713                                            *:*      =20
UNCONN      0      0                                               *:bo=
otpc                                           *:*      =20
UNCONN      0      0                                              :::57=
879                                           :::*      =20

Reported-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/misc/ss.c b/misc/ss.c
index 764ffe2..37dcc11 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1462,7 +1462,21 @@ static void tcp_show_info(const struct nlmsghdr =
*nlh, struct inet_diag_msg *r,
 	}
 }
=20
-static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
+static char *proto_name(int protocol)
+{
+	switch (protocol) {
+	case IPPROTO_UDP:
+		return "udp";
+	case IPPROTO_TCP:
+		return "tcp";
+	case IPPROTO_DCCP:
+		return "dccp";
+	}
+
+	return "???";
+}
+
+static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int =
protocol)
 {
 	struct rtattr * tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r =3D NLMSG_DATA(nlh);
@@ -1487,7 +1501,7 @@ static int inet_show_sock(struct nlmsghdr *nlh, s=
truct filter *f)
 		return 0;
=20
 	if (netid_width)
-		printf("%-*s ", netid_width, "tcp");
+		printf("%-*s ", netid_width, proto_name(protocol));
 	if (state_width)
 		printf("%-*s ", state_width, sstate_name[s.state]);
=20
@@ -1760,7 +1774,7 @@ again:
 					h =3D NLMSG_NEXT(h, status);
 					continue;
 				}
-				err =3D inet_show_sock(h, NULL);
+				err =3D inet_show_sock(h, NULL, protocol);
 				if (err < 0) {
 					close(fd);
 					return err;
@@ -1839,7 +1853,7 @@ static int tcp_show_netlink_file(struct filter *f=
)
 			return -1;
 		}
=20
-		err =3D inet_show_sock(h, f);
+		err =3D inet_show_sock(h, f, IPPROTO_TCP);
 		if (err < 0)
 			return err;
 	}
