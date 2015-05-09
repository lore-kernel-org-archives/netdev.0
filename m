From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH] pppoe: drop pppoe device in pppoe_unbind_sock_work
Date: Sat,  9 May 2015 23:08:38 +0200
Message-ID: <1431205718-9603-1-git-send-email-nbd@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:46320
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751451AbbEIVIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:08:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After receiving a PADT and the socket is closed, user space will no
longer drop the reference to the pppoe device.
This leads to errors like this:

[  488.570000] unregister_netdevice: waiting for eth0.2 to become free. Usage count = 2

Fixes: 287f3a943fe ("pppoe: Use workqueue to die properly when a PADT is received")
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ppp/pppoe.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index ff059e1..6a544f2 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -462,6 +462,10 @@ static void pppoe_unbind_sock_work(struct work_struct *work)
 	struct sock *sk = sk_pppox(po);
 
 	lock_sock(sk);
+	if (po->pppoe_dev) {
+		dev_put(po->pppoe_dev);
+		po->pppoe_dev = NULL;
+	}
 	pppox_unbind_sock(sk);
 	release_sock(sk);
 	sock_put(sk);
-- 
2.2.2
