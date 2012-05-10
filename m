From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] ehea: fix losing of NEQ events when one event occurred early
Date: Thu, 10 May 2012 11:00:53 -0300
Message-ID: <1336658453-687-1-git-send-email-cascardo@linux.vnet.ibm.com>
References: <20120509.202913.886545227635873372.davem@davemloft.net>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:41104 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759259Ab2EJOBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 10:01:19 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Thu, 10 May 2012 11:01:09 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 2F3491DC0050
	for <netdev@vger.kernel.org>; Thu, 10 May 2012 11:01:01 -0300 (BRT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4AE0gLB27459848
	for <netdev@vger.kernel.org>; Thu, 10 May 2012 11:00:42 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4AE15ts017606
	for <netdev@vger.kernel.org>; Thu, 10 May 2012 11:01:05 -0300
In-Reply-To: <20120509.202913.886545227635873372.davem@davemloft.net>
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
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index c9069a2..f4d2da0 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3335,6 +3335,8 @@ static int __devinit ehea_probe_adapter(struct platform_device *dev,
 		goto out_shutdown_ports;
 	}
 
+	/* Handle any events that might be pending. */
+	tasklet_hi_schedule(&adapter->neq_tasklet);
 
 	ret = 0;
 	goto out;
-- 
1.7.4.4
