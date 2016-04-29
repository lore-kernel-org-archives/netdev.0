From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] cxgb3: fix out of bounds read
Date: Fri, 29 Apr 2016 11:06:50 +0200
Message-ID: <1461920810-15228-1-git-send-email-mschmidt@redhat.com>
Cc: Santosh Raspatur <santosh@chelsio.com>,
	Jan Stancek <jstancek@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498AbcD2JGx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2016 05:06:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An out of bounds read of 2 bytes was discovered in cxgb3 with KASAN.

t3_config_rss() expects both arrays it gets as parameters to have
terminators. setup_rss(), the caller, forgets to add a terminator to
one of the arrays. Thankfully the iteration in t3_config_rss() stops
anyway, but in the last iteration the check for the terminator
is an out of bounds read.

Add the missing terminator to rspq_map[].

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 60908eab3b..43da891fab 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -576,7 +576,7 @@ static void setup_rss(struct adapter *adap)
 	unsigned int nq0 = adap2pinfo(adap, 0)->nqsets;
 	unsigned int nq1 = adap->port[1] ? adap2pinfo(adap, 1)->nqsets : 1;
 	u8 cpus[SGE_QSETS + 1];
-	u16 rspq_map[RSS_TABLE_SIZE];
+	u16 rspq_map[RSS_TABLE_SIZE + 1];
 
 	for (i = 0; i < SGE_QSETS; ++i)
 		cpus[i] = i;
@@ -586,6 +586,7 @@ static void setup_rss(struct adapter *adap)
 		rspq_map[i] = i % nq0;
 		rspq_map[i + RSS_TABLE_SIZE / 2] = (i % nq1) + nq0;
 	}
+	rspq_map[RSS_TABLE_SIZE] = 0xffff; /* terminator */
 
 	t3_config_rss(adap, F_RQFEEDBACKENABLE | F_TNLLKPEN | F_TNLMAPEN |
 		      F_TNLPRTEN | F_TNL2TUPEN | F_TNL4TUPEN |
-- 
2.7.4
