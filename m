From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] [PATCH] qeth: fix possible memory leak in qeth_l3_add_[vipa|rxip]()
Date: Mon, 24 Sep 2012 16:24:25 +0200
Message-ID: <20120924142501.240612803@de.ibm.com>
References: <20120924142422.001953152@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:52054 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748Ab2IXOZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:25:13 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Sep 2012 15:25:12 +0100
Content-Disposition: inline; filename=602-qeth-memory-leak-l3.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

ipaddr has been allocated in function qeth_l3_add_vipa() but
does not free before leaving from the error handling cases. The
same problem also exists in function qeth_l3_add_rxip().

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index c5f03fa..4cd310c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -794,6 +794,7 @@ int qeth_l3_add_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
 		rc = -EEXIST;
 	spin_unlock_irqrestore(&card->ip_lock, flags);
 	if (rc) {
+		kfree(ipaddr);
 		return rc;
 	}
 	if (!qeth_l3_add_ip(card, ipaddr))
@@ -858,6 +859,7 @@ int qeth_l3_add_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
 		rc = -EEXIST;
 	spin_unlock_irqrestore(&card->ip_lock, flags);
 	if (rc) {
+		kfree(ipaddr);
 		return rc;
 	}
 	if (!qeth_l3_add_ip(card, ipaddr))
-- 
1.7.11.7
