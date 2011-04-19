From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH] ehea: Fix a DLPAR bug on ehea_rereg_mrs().
Date: Tue, 19 Apr 2011 16:39:22 -0300
Message-ID: <1303241962-32285-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:52804 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503Ab1DSTjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 15:39:35 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <leitao@linux.vnet.ibm.com>;
	Tue, 19 Apr 2011 16:39:32 -0300
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3JJakhS3985660
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 16:36:46 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3JJdSq0002662
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 16:39:28 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are currently continuing if ehea_restart_qps() fails, when we
do a memory DLPAR (remove or add more memory to the system).

This patch just let the NAPI disabled if the ehea_restart_qps()
fails.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index f75d314..53c0f04 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3040,11 +3040,14 @@ static void ehea_rereg_mrs(void)
 
 					if (dev->flags & IFF_UP) {
 						mutex_lock(&port->port_lock);
-						port_napi_enable(port);
 						ret = ehea_restart_qps(dev);
-						check_sqs(port);
-						if (!ret)
+						if (!ret) {
+							check_sqs(port);
+							port_napi_enable(port);
 							netif_wake_queue(dev);
+						} else {
+							netdev_err(dev, "Unable to restart QPS\n");
+						}
 						mutex_unlock(&port->port_lock);
 					}
 				}
-- 
1.7.1

