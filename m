From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] be2net: perform temperature query in adapter regardless of  its interface state
Date: Tue, 26 Jul 2016 17:39:42 -0300
Message-ID: <1469565582-5984-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46181 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758054AbcGZUjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 16:39:49 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6QKdNen005578
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 16:39:49 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24dnc6rryd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 16:39:48 -0400
Received: from localhost
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Tue, 26 Jul 2016 17:39:45 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id D54F73520070
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 16:39:23 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6QKdhOA16843226
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 17:39:43 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6QKdgkj024673
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 17:39:42 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The be2net driver performs fw temperature queries on be_worker() routine,
which is executed each second for each be_adapter. There is a frequency
threshold to avoid fw query to happens at each call to be_worker();
instead, currently a fw query occurs once in 64 runs of the procedure.

Nevertheless, this fw temperature query is invoked only for adapters which
interface is up, so we can see I/O errors on read of hwmon counters from
userspace (from tools like lm-sensors) in case we have adapters' functions
which interface is down.

This patch moves the fw query code to be invoked even if interface is down.
No functional changes were introduced.

Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ed98ef1..706fdfa 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4996,6 +4996,10 @@ static void be_worker(struct work_struct *work)
 	struct be_rx_obj *rxo;
 	int i;
 
+	if (be_physfn(adapter) &&
+	    MODULO(adapter->work_counter, adapter->be_get_temp_freq) == 0)
+		be_cmd_get_die_temperature(adapter);
+
 	/* when interrupts are not yet enabled, just reap any pending
 	 * mcc completions
 	 */
@@ -5014,10 +5018,6 @@ static void be_worker(struct work_struct *work)
 			be_cmd_get_stats(adapter, &adapter->stats_cmd);
 	}
 
-	if (be_physfn(adapter) &&
-	    MODULO(adapter->work_counter, adapter->be_get_temp_freq) == 0)
-		be_cmd_get_die_temperature(adapter);
-
 	for_all_rx_queues(adapter, rxo, i) {
 		/* Replenish RX-queues starved due to memory
 		 * allocation failures.
-- 
2.1.0
