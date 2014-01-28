From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Properly handle protocol level diag module absence
Date: Tue, 28 Jan 2014 21:32:00 +0400
Message-ID: <52E7E990.7050501@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:42805 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754599AbaA1RcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:32:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When *_diag module is missing in the kernel, the ss tool should go
ad read legacry /proc/* files.

This is the case when all *_diag stuff is missing, but in case the
inet_diag.ko is loaded, but (tcp|udp)_diag.ko is not, the ss tool
doesn't notice this and produces empty output. The reason for that
is -- error from the inet_diag module (which means, that e.g. the
udp_diag is missing) is reported in the NLMSG_DONE message body.

That said, we need to check the NLMSG_DONE's message return code
and act respectively.

Reported-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/misc/ss.c b/misc/ss.c
index 37dcc11..9c7d937 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1746,8 +1746,15 @@ again:
 			    h->nlmsg_seq !=3D 123456)
 				goto skip_it;
=20
-			if (h->nlmsg_type =3D=3D NLMSG_DONE)
+			if (h->nlmsg_type =3D=3D NLMSG_DONE) {
+				int *len =3D (int *)NLMSG_DATA(h);
+				if (*len < 0) {
+					close(fd);
+					return -1;
+				}
+
 				goto done;
+			}
=20
 			if (h->nlmsg_type =3D=3D NLMSG_ERROR) {
 				struct nlmsgerr *err =3D (struct nlmsgerr*)NLMSG_DATA(h);
