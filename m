From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] [PATCH] qeth: set new mac even if old mac is gone
Date: Tue, 13 Nov 2012 10:05:17 +0100
Message-ID: <20121113090530.055046731@de.ibm.com>
References: <20121113090515.223638702@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:49575 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397Ab2KMJFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:05:38 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 13 Nov 2012 09:05:37 -0000
Content-Disposition: inline; filename=606-qeth-set-mac.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If the set_mac_address() function of qeth is invoked, qeth deletes
the old mac address first on OSA. Only if deletion returns
successfully the new mac address is set on OSA. Deletion may return
with a return value "MAC not found on OSA". In this case qeth
should continue setting the new mac address.

When the OSA cable is pulled, OSA forgets any set mac address. If
the OSA network interface acts as a slave to a bonding master
interface, bonding can invoke the set_mac_address function for
failover purposes and depends on successful setting of the new mac
address even though the old mac address could no longer be deleted.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 333f583..83849c2 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -679,7 +679,7 @@ static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
 		return -ERESTARTSYS;
 	}
 	rc = qeth_l2_send_delmac(card, &card->dev->dev_addr[0]);
-	if (!rc)
+	if (!rc || (rc == IPA_RC_L2_MAC_NOT_FOUND))
 		rc = qeth_l2_send_setmac(card, addr->sa_data);
 	return rc ? -EINVAL : 0;
 }
