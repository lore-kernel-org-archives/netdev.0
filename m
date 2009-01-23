From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 3/6] Phonet: allow phonet_device_init() to fail, put it to __init section
Date: Fri, 23 Jan 2009 15:00:27 +0200
Message-ID: <1232715630-24951-3-git-send-email-remi.denis-courmont@nokia.com>
References: <200901231459.29743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:50767 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884AbZAWNAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 08:00:51 -0500
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n0ND0flA011584
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:49 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n0ND0Fo6027886
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:18 +0200
In-Reply-To: <200901231459.29743.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 -
 include/net/phonet/pn_dev.h |    3 ++-
 net/phonet/af_phonet.c      |    9 ++++++---
 net/phonet/pn_dev.c         |    4 +++-
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 057b0a8..d43f71b 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -105,7 +105,6 @@ void phonet_proto_unregister(int protocol, struct p=
honet_protocol *pp);
=20
 int phonet_sysctl_init(void);
 void phonet_sysctl_exit(void);
-void phonet_netlink_register(void);
 int isi_register(void);
 void isi_unregister(void);
=20
diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index aa1c59a..59ae628 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -36,8 +36,9 @@ struct phonet_device {
 	DECLARE_BITMAP(addrs, 64);
 };
=20
-void phonet_device_init(void);
+int phonet_device_init(void);
 void phonet_device_exit(void);
+void phonet_netlink_register(void);
 struct net_device *phonet_device_get(struct net *net);
=20
 int phonet_address_add(struct net_device *dev, u8 addr);
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index c7c39d9..95bc49d 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -426,16 +426,18 @@ static int __init phonet_init(void)
 {
 	int err;
=20
+	err =3D phonet_device_init();
+	if (err)
+		return err;
+
 	err =3D sock_register(&phonet_proto_family);
 	if (err) {
 		printk(KERN_ALERT
 			"phonet protocol family initialization failed\n");
-		return err;
+		goto err_sock;
 	}
=20
-	phonet_device_init();
 	dev_add_pack(&phonet_packet_type);
-	phonet_netlink_register();
 	phonet_sysctl_init();
=20
 	err =3D isi_register();
@@ -447,6 +449,7 @@ err:
 	phonet_sysctl_exit();
 	sock_unregister(PF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
+err_sock:
 	phonet_device_exit();
 	return err;
 }
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 5491bf5..af49db0 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -188,9 +188,11 @@ static struct notifier_block phonet_device_notifie=
r =3D {
 };
=20
 /* Initialize Phonet devices list */
-void phonet_device_init(void)
+int __init phonet_device_init(void)
 {
 	register_netdevice_notifier(&phonet_device_notifier);
+	phonet_netlink_register();
+	return 0;
 }
=20
 void phonet_device_exit(void)
--=20
1.5.6.3

