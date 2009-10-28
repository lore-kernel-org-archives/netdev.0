From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 08:01:57 +0100
Message-ID: <4AE7EC65.8000600@gmail.com>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE78297.9000909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59655 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932087AbZJ1HB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 03:01:57 -0400
In-Reply-To: <4AE78297.9000909@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :
>=20
> Probably the right way is to give a cmd-line arg to set the buffer si=
ze
> and also continue if the error is ENOBUFs (but print some error out
> so users know they have issues).  I can make the attempt if that
> sounds good to you.

Real fix is to realloc buffer at receive time, no need for user setting=
=2E

In my testings I saw it reaching 1 Mbyte
write(2, "REALLOC buflen 8192\n"..., 20) =3D 20
write(2, "REALLOC buflen 16384\n"..., 21) =3D 21
write(2, "REALLOC buflen 32768\n"..., 21) =3D 21
write(2, "REALLOC buflen 65536\n"..., 21) =3D 21
write(2, "REALLOC buflen 131072\n"..., 22) =3D 22
write(2, "REALLOC buflen 262144\n"..., 22) =3D 22
write(2, "REALLOC buflen 524288\n"..., 22) =3D 22


[iproute2] realloc buffer in rtnl_listen

# ip monitor route
netlink receive error No buffer space available (105)
Dump terminated=20

Reported-by: Ben Greear<greearb@candelatech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..134ce7f 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -392,8 +392,14 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		.msg_iov =3D &iov,
 		.msg_iovlen =3D 1,
 	};
-	char   buf[8192];
+	char   *buf;
+	size_t buflen =3D 8192;
=20
+	buf =3D malloc(buflen);
+	if (buf =3D=3D NULL) {
+		fprintf(stderr, "netlink could not alloc %lu bytes\n", buflen);
+		return -1;
+	}
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family =3D AF_NETLINK;
 	nladdr.nl_pid =3D 0;
@@ -401,12 +407,20 @@ int rtnl_listen(struct rtnl_handle *rtnl,
=20
 	iov.iov_base =3D buf;
 	while (1) {
-		iov.iov_len =3D sizeof(buf);
+		iov.iov_len =3D buflen;
 		status =3D recvmsg(rtnl->fd, &msg, 0);
=20
 		if (status < 0) {
 			if (errno =3D=3D EINTR || errno =3D=3D EAGAIN)
 				continue;
+			if (errno =3D=3D ENOBUFS) {
+				buf =3D realloc(buf, buflen * 2);
+				if (buf) {
+					buflen *=3D 2;
+					iov.iov_base =3D buf;
+					continue;
+				}
+			}
 			fprintf(stderr, "netlink receive error %s (%d)\n",
 				strerror(errno), errno);
 			return -1;
