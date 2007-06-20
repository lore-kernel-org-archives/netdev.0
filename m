From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 6/8] s390: don't call iucv_path_connect from tasklet context
Date: Wed, 20 Jun 2007 13:01:30 +0200
Message-ID: <20070620110130.GF9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:59640 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbXFTK6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 06:58:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5KAwiqK009410
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:44 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KAwihW514726
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KAwiWQ007454
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:44 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

net/iucv/iucv.c creates the requirement for
iucv_path_connect not to be called from tasklet context anymore.
An extra checking is added in case of a failing netiucv_tx
to fulfil this requirement for netiucv.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/netiucv.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index c358764..648ee13 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1315,7 +1315,8 @@ static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 	 * and throw away packet.
 	 */
 	if (fsm_getstate(privptr->fsm) != DEV_STATE_RUNNING) {
-		fsm_event(privptr->fsm, DEV_EVENT_START, dev);
+		if (!in_atomic())
+			fsm_event(privptr->fsm, DEV_EVENT_START, dev);
 		dev_kfree_skb(skb);
 		privptr->stats.tx_dropped++;
 		privptr->stats.tx_errors++;
-- 
1.5.2.1

