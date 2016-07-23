From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/2] be2net: query temperature on probe and decrease its frequency on be_worker()
Date: Fri, 22 Jul 2016 22:29:55 -0300
Message-ID: <1469237395-11501-2-git-send-email-gpiccoli@linux.vnet.ibm.com>
References: <1469237395-11501-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57466 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751061AbcGWBaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 21:30:01 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6N1TFpf108185
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 21:30:00 -0400
Received: from e24smtp03.br.ibm.com (e24smtp03.br.ibm.com [32.104.18.24])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24bhvwt5wy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 21:29:59 -0400
Received: from localhost
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Fri, 22 Jul 2016 22:29:58 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 348C9352006C
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 21:29:37 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6N1TuqK28311970
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 22:29:56 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6N1TthR027906
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 22:29:55 -0300
In-Reply-To: <1469237395-11501-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the be2net driver queries the temperature from fw in regular
intervals on be_worker(), which is a delayed work procedure that
reschedules itself to run in next second. The interval for temperature
query is currently set to 64, meaning at each 64 seconds the query will
happen on be_worker().

This patch adds a temperature fw query on be_probe() and increase the
current query timeout of 64 to 128, lowering the frequency of the
temperature fw queries in be_worker() by half. In our experiments, the
probing time got increased by 8.7% (from 11.62s to 12.63s) for a
4-function Lancer adapter (PCI Vid:Did == 10df:e220).

This aims to solve the problem of userspace temperature request right after
be2net probing shows inconsistent values because be_worker() didn't perform
the first temperature query yet. Besides, this patch aims to reduce the
overhead of querying fw each minute for temperature information.

Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9f44a00..0e23ab2 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5232,7 +5232,7 @@ static int be_drv_init(struct be_adapter *adapter)
 	adapter->tx_fc = true;
 
 	/* Must be a power of 2 or else MODULO will BUG_ON */
-	adapter->be_get_temp_freq = 64;
+	adapter->be_get_temp_freq = 128;
 
 	return 0;
 
@@ -5445,6 +5445,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 							       adapter,
 							       be_hwmon_groups);
 		adapter->hwmon_info.be_on_die_temp = BE_INVALID_DIE_TEMP;
+		be_cmd_get_die_temperature(adapter);
 	}
 
 	dev_info(&pdev->dev, "%s: %s %s port %c\n", nic_name(pdev),
-- 
2.1.0
