From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] ehea: fix losing of NEQ events when one event occurred early
Date: Wed,  9 May 2012 21:10:18 -0300
Message-ID: <1336608618-31497-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:54888 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761337Ab2EJAK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 20:10:27 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Wed, 9 May 2012 21:10:25 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 23BF0352004C
	for <netdev@vger.kernel.org>; Wed,  9 May 2012 21:10:19 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4A09xe638732080
	for <netdev@vger.kernel.org>; Wed, 9 May 2012 21:09:59 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q49MAFZv029205
	for <netdev@vger.kernel.org>; Wed, 9 May 2012 19:10:16 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NEQ interrupt is only triggered when there was no previous pending
interrupt. If we request irq handling after an interrupt has occurred,
we will never get an interrupt until we call H_RESET_EVENTS.

Events seem to be cleared when we first register the NEQ. So, when we
requested irq handling right after registering it, a possible race with
an interrupt was much less likely. Now, there is a chance we may lose
this race and never get any events.

The fix here is to poll and acknowledge any events that might have
happened right after registering the irq handler.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index c9069a2..f088e59 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3335,6 +3335,9 @@ static int __devinit ehea_probe_adapter(struct platform_device *dev,
 		goto out_shutdown_ports;
 	}
 
+	/* Handle any events that might be pending. */
+	tasklet_hi_schedule(&adapter->neq_tasklet);
+
 
 	ret = 0;
 	goto out;
-- 
1.7.4.4
