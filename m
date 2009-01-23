From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 5/6] Phonet: remove useless locking in device cleanup
Date: Fri, 23 Jan 2009 15:00:29 +0200
Message-ID: <1232715630-24951-5-git-send-email-remi.denis-courmont@nokia.com>
References: <200901231459.29743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:50721 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402AbZAWNAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 08:00:39 -0500
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n0ND0ETW011091
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:36 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n0ND0Fo8027886
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:21 +0200
In-Reply-To: <200901231459.29743.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Incoming packets and sockets are already gone.
The netdevice notifier is unregistered under the RTNL lock
There remains a race with the rtnetlink handlers unregistration, but it
is a generic RTNL issue that was already present before this change.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_dev.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index fd41810..3e24c05 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -204,13 +204,8 @@ void phonet_device_exit(void)
 	struct phonet_device *pnd, *n;
=20
 	rtnl_unregister_all(PF_PHONET);
-	rtnl_lock();
-	spin_lock_bh(&pndevs.lock);
+	unregister_netdevice_notifier(&phonet_device_notifier);
=20
 	list_for_each_entry_safe(pnd, n, &pndevs.list, list)
 		__phonet_device_free(pnd);
-
-	spin_unlock_bh(&pndevs.lock);
-	rtnl_unlock();
-	unregister_netdevice_notifier(&phonet_device_notifier);
 }
--=20
1.5.6.3

