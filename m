From: =?UTF-8?Q?Micha=C5=82=20Miros=C5=82aw=20?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH 5/6 2.6.30-rc6] tipc: Use genl_register_family_with_ops()
Date: Thu, 21 May 2009 22:34:05 +0200 (CEST)
Message-ID: <5-1000-10527-1242938044-3360@rere.qmqm.pl>
References: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tipc-discussion@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48070 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756444AbZEUUeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 16:34:05 -0400
In-Reply-To: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use genl_register_family_with_ops() instead of a copy. This also change=
s
netlink related variable names to be kernel-wide unique for consistency
with other users.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

diff -urN linux-orig-mqbr/net/tipc/netlink.c linux-mqbr/net/tipc/netlin=
k.c
--- linux-orig-mqbr/net/tipc/netlink.c	2009-03-24 00:12:14.000000000 +0=
100
+++ linux-mqbr/net/tipc/netlink.c	2009-05-21 18:04:46.000000000 +0200
@@ -68,7 +68,7 @@
 	return 0;
 }
=20
-static struct genl_family family =3D {
+static struct genl_family tipc_genl_family =3D {
 	.id		=3D GENL_ID_GENERATE,
 	.name		=3D TIPC_GENL_NAME,
 	.version	=3D TIPC_GENL_VERSION,
@@ -76,39 +76,33 @@
 	.maxattr	=3D 0,
 };
=20
-static struct genl_ops ops =3D {
+static struct genl_ops tipc_genl_ops =3D {
 	.cmd		=3D TIPC_GENL_CMD,
 	.doit		=3D handle_cmd,
 };
=20
-static int family_registered =3D 0;
+static int tipc_genl_family_registered;
=20
 int tipc_netlink_start(void)
 {
+	int res;
=20
+	res =3D genl_register_family_with_ops(&tipc_genl_family,
+		&tipc_genl_ops, 1);
+	if (res) {
+		err("Failed to register netlink interface\n");
+		return res;
+	}
=20
-	if (genl_register_family(&family))
-		goto err;
-
-	family_registered =3D 1;
-
-	if (genl_register_ops(&family, &ops))
-		goto err_unregister;
-
+	tipc_genl_family_registered =3D 1;
 	return 0;
-
- err_unregister:
-	genl_unregister_family(&family);
-	family_registered =3D 0;
- err:
-	err("Failed to register netlink interface\n");
-	return -EFAULT;
 }
=20
 void tipc_netlink_stop(void)
 {
-	if (family_registered) {
-		genl_unregister_family(&family);
-		family_registered =3D 0;
-	}
+	if (!tipc_genl_family_registered)
+		return;
+
+	genl_unregister_family(&tipc_genl_family);
+	tipc_genl_family_registered =3D 0;
 }
