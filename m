From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 4/6] Phonet: handle rtnetlink registration failure
Date: Fri, 23 Jan 2009 15:00:28 +0200
Message-ID: <1232715630-24951-4-git-send-email-remi.denis-courmont@nokia.com>
References: <200901231459.29743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:24240 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735AbZAWNAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 08:00:46 -0500
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n0ND0bYe019011
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:44 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n0ND0Fo7027886
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:20 +0200
In-Reply-To: <200901231459.29743.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    2 +-
 net/phonet/pn_dev.c         |    8 ++++++--
 net/phonet/pn_netlink.c     |   13 +++++++++----
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 59ae628..4ba2aed 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -38,7 +38,7 @@ struct phonet_device {
=20
 int phonet_device_init(void);
 void phonet_device_exit(void);
-void phonet_netlink_register(void);
+int phonet_netlink_register(void);
 struct net_device *phonet_device_get(struct net *net);
=20
 int phonet_address_add(struct net_device *dev, u8 addr);
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index af49db0..fd41810 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -190,9 +190,13 @@ static struct notifier_block phonet_device_notifie=
r =3D {
 /* Initialize Phonet devices list */
 int __init phonet_device_init(void)
 {
+	int err;
+
 	register_netdevice_notifier(&phonet_device_notifier);
-	phonet_netlink_register();
-	return 0;
+	err =3D phonet_netlink_register();
+	if (err)
+		phonet_device_exit();
+	return err;
 }
=20
 void phonet_device_exit(void)
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 242fe8f..918a4f0 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -160,9 +160,14 @@ out:
 	return skb->len;
 }
=20
-void __init phonet_netlink_register(void)
+int __init phonet_netlink_register(void)
 {
-	rtnl_register(PF_PHONET, RTM_NEWADDR, addr_doit, NULL);
-	rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL);
-	rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit);
+	int err =3D __rtnl_register(PF_PHONET, RTM_NEWADDR, addr_doit, NULL);
+	if (err)
+		return err;
+
+	/* Further __rtnl_register() cannot fail */
+	__rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL);
+	__rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit);
+	return 0;
 }
--=20
1.5.6.3

