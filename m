From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 04/12] bonding: always set recv_probe to bond_arp_rcv in arp monitor
Date: Fri, 17 Jan 2014 17:58:52 +0100
Message-ID: <1389977940-17084-5-git-send-email-vfalico@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752699AbaAQREQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:16 -0500
In-Reply-To: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we only set bond_arp_rcv() if we're using arp_validate, however
this makes us skip updating last_arp_rx if we're not validating incoming
ARPs - thus, if arp_validate is off, last_arp_rx will never be updated.

Fix this by always setting up recv_probe = bond_arp_rcv, even if we're not
using arp_validate.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c    |  3 +--
 drivers/net/bonding/bond_options.c | 12 ++----------
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 909f164..07ae82d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3077,8 +3077,7 @@ static int bond_open(struct net_device *bond_dev)
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
-		if (bond->params.arp_validate)
-			bond->recv_probe = bond_arp_rcv;
+		bond->recv_probe = bond_arp_rcv;
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index f1c4fba..9d6d231 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -283,13 +283,11 @@ int bond_option_arp_interval_set(struct bonding *bond, int arp_interval)
 		 * is called.
 		 */
 		if (!arp_interval) {
-			if (bond->params.arp_validate)
-				bond->recv_probe = NULL;
+			bond->recv_probe = NULL;
 			cancel_delayed_work_sync(&bond->arp_work);
 		} else {
 			/* arp_validate can be set only in active-backup mode */
-			if (bond->params.arp_validate)
-				bond->recv_probe = bond_arp_rcv;
+			bond->recv_probe = bond_arp_rcv;
 			cancel_delayed_work_sync(&bond->mii_work);
 			queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		}
@@ -440,12 +438,6 @@ int bond_option_arp_validate_set(struct bonding *bond, int arp_validate)
 		bond->dev->name, arp_validate_tbl[arp_validate].modename,
 		arp_validate);
 
-	if (bond->dev->flags & IFF_UP) {
-		if (!arp_validate)
-			bond->recv_probe = NULL;
-		else if (bond->params.arp_interval)
-			bond->recv_probe = bond_arp_rcv;
-	}
 	bond->params.arp_validate = arp_validate;
 
 	return 0;
-- 
1.8.4
