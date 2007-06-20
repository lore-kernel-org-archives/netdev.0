From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/8] s390: avoid inconsistent lock state in qeth
Date: Wed, 20 Jun 2007 12:58:02 +0200
Message-ID: <20070620105802.GC9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:60530 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816AbXFTK6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 06:58:46 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5K9timd018403
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 05:55:44 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KAwj6M458138
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KAwjXP007499
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:45 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

ipv6_regen_rndid in net/ipv6/addrconf.c makes use of "write_lock_bh"
for its inet6_dev->lock. It may run in softirq-context.
qeth makes use of "read_lock" for the same inet6_dev->lock.
To avoid a potential deadlock situation, qeth should make use of
"read_lock_bh" for its usages of inet6_dev->lock.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/qeth_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index c5a9507..79b7379 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -5850,9 +5850,9 @@ qeth_add_vlan_mc6(struct qeth_card *card)
 		in_dev = in6_dev_get(netdev);
 		if (!in_dev)
 			continue;
-		read_lock(&in_dev->lock);
+		read_lock_bh(&in_dev->lock);
 		qeth_add_mc6(card,in_dev);
-		read_unlock(&in_dev->lock);
+		read_unlock_bh(&in_dev->lock);
 		in6_dev_put(in_dev);
 	}
 #endif /* CONFIG_QETH_VLAN */
@@ -5869,10 +5869,10 @@ qeth_add_multicast_ipv6(struct qeth_card *card)
 	in6_dev = in6_dev_get(card->dev);
 	if (in6_dev == NULL)
 		return;
-	read_lock(&in6_dev->lock);
+	read_lock_bh(&in6_dev->lock);
 	qeth_add_mc6(card, in6_dev);
 	qeth_add_vlan_mc6(card);
-	read_unlock(&in6_dev->lock);
+	read_unlock_bh(&in6_dev->lock);
 	in6_dev_put(in6_dev);
 }
 #endif /* CONFIG_QETH_IPV6 */
-- 
1.5.2.1

