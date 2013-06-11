From: nikolay@redhat.com
Subject: [PATCH v2 1/2] bonding: reset master mac on first enslave failure
Date: Wed, 12 Jun 2013 00:07:01 +0200
Message-ID: <1370988422-2035-2-git-send-email-nikolay@redhat.com>
References: <1370988422-2035-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, davem@davemloft.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025Ab3FKWJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 18:09:59 -0400
In-Reply-To: <1370988422-2035-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

If the bond device is supposed to get the first slave's MAC address and
the first enslavement fails then we need to reset the master's MAC
otherwise it will stay the same as the failed slave device. We do it
after err_undo_flags since that is the first place where the MAC can be
changed and we check if it should've been the first slave and if the
bond's MAC was set to it because that err place is used by multiple
locations prior to changing the master's MAC address.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 29b846c..473633a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1957,6 +1957,10 @@ err_free:
 
 err_undo_flags:
 	bond_compute_features(bond);
+	/* Enslave of first slave has failed and we need to fix master's mac */
+	if (bond->slave_cnt == 0 &&
+	    ether_addr_equal(bond_dev->dev_addr, slave_dev->dev_addr))
+		eth_hw_addr_random(bond_dev);
 
 	return res;
 }
-- 
1.8.1.4
