From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 04/12] bonding: always set recv_probe to bond_arp_rcv in arp monitor
Date: Mon, 17 Feb 2014 14:39:13 +0100
Message-ID: <1392644361-8510-5-git-send-email-vfalico@redhat.com>
References: <1392644361-8510-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753162AbaBQNoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 08:44:25 -0500
In-Reply-To: <1392644361-8510-1-git-send-email-vfalico@redhat.com>
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
 drivers/net/bonding/bond_main.c    | 3 +--
 drivers/net/bonding/bond_options.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7747cc5..257ee7f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3059,8 +3059,7 @@ static int bond_open(struct net_device *bond_dev)
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
-		if (bond->params.arp_validate)
-			bond->recv_probe = bond_arp_rcv;
+		bond->recv_probe = bond_arp_rcv;
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index f3eb44d..cda686d 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -809,8 +809,7 @@ int bond_option_arp_interval_set(struct bonding *bond,
 			cancel_delayed_work_sync(&bond->arp_work);
 		} else {
 			/* arp_validate can be set only in active-backup mode */
-			if (bond->params.arp_validate)
-				bond->recv_probe = bond_arp_rcv;
+			bond->recv_probe = bond_arp_rcv;
 			cancel_delayed_work_sync(&bond->mii_work);
 			queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		}
-- 
1.8.4
