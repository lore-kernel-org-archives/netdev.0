From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH] smsc911x: Fix Console Hang when bringing the interface down.
Date: Thu, 12 Nov 2009 17:44:38 +0530
Message-ID: <1258028078-10933-1-git-send-email-srk@ti.com>
Cc: Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:39359 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbZKLMOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 07:14:37 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id nACCEeuO004717
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 06:14:43 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the NAPI poll function, check for netif_running() is unnecassary.
In addition to associated runtime overhead, it also results in
continuous softirq loop when the interface is brought down under heavy
traffic(tested with Traffic Generator).Once the interface is disabled,
the poll function always returns zero(with the check for netif_running)
and napi_complete() would never get called resulting in softirq loop.

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
Fix has been validated on OMAP3EVM. Similar issue found with TI Davinci
EMAC driver for which a patch has been posted to this list.


 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index ccdd196..f9cdcbc 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -986,7 +986,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = pdata->dev;
 	int npackets = 0;
 
-	while (likely(netif_running(dev)) && (npackets < budget)) {
+	while (npackets < budget) {
 		unsigned int pktlength;
 		unsigned int pktwords;
 		struct sk_buff *skb;
-- 
1.6.2.4

