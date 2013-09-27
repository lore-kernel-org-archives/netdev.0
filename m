From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/2] bonding: correctly verify for the first slave in bond_enslave
Date: Fri, 27 Sep 2013 15:10:57 +0200
Message-ID: <1380287458-3488-2-git-send-email-vfalico@redhat.com>
References: <1380287458-3488-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638Ab3I0NKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 09:10:42 -0400
In-Reply-To: <1380287458-3488-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 1f718f0f4f97145f4072d2d72dcf85069ca7226d ("bonding: populate
neighbour's private on enslave"), we've moved the actual 'linking' in the
end of the function - so that, once linked, the slave is ready to be used,
and is not still in the process of enslaving.

However, 802.3ad verified if it's the first slave by looking at the

if (bond_first_slave(bond) == new_slave)

which, because we've moved the linking to the end, became broken - on the
first slave bond_first_slave(bond) returns NULL.

Fix this by verifying if the prev_slave, that equals bond_last_slave(), is
actually populated - if it is - then it's not the first slave, and vice
versa.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d5c3153..0367f80 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1557,7 +1557,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		bond_set_slave_inactive_flags(new_slave);
 		/* if this is the first slave */
-		if (bond_first_slave(bond) == new_slave) {
+		if (!prev_slave) {
 			SLAVE_AD_INFO(new_slave).id = 1;
 			/* Initialize AD with the number of times that the AD timer is called in 1 second
 			 * can be called only after the mac address of the bond is set
-- 
1.8.4
