From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net v2] tg3: Avoid NULL pointer dereference in tg3_io_error_detected()
Date: Thu, 29 Sep 2016 13:24:08 -0300
Message-ID: <1475166248-8665-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, gpiccoli@linux.vnet.ibm.com,
        Milton Miller <miltonm@us.ibm.com>
To: siva.kallam@broadcom.com, prashant@broadcom.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58836 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755768AbcI2QYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:24:38 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8TGOAG6102707
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 12:24:38 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25s25swg1j-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 12:24:38 -0400
Received: from localhost
        by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 13:24:34 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.18.232.225])
        by d24dlp02.br.ibm.com (Postfix) with ESMTP id C5B451DC0054
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 12:24:32 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
        by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8TGOWqS35979436
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 13:24:32 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
        by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8TGOWOe009796
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 13:24:32 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Milton Miller <miltonm@us.ibm.com>

While the driver is probing the adapter, an error may occur before the
netdev structure is allocated and attached to pci_dev. In this case,
not only netdev isn't available, but the tg3 private structure is also
not available as it is just math from the NULL pointer, so dereferences
must be skipped.

The following trace is seen when the error is triggered:

  [1.402247] Unable to handle kernel paging request for data at address 0x00001a99
  [1.402410] Faulting instruction address: 0xc0000000007e33f8
  [1.402450] Oops: Kernel access of bad area, sig: 11 [#1]
  [1.402481] SMP NR_CPUS=2048 NUMA PowerNV
  [1.402513] Modules linked in:
  [1.402545] CPU: 0 PID: 651 Comm: eehd Not tainted 4.4.0-36-generic #55-Ubuntu
  [1.402591] task: c000001fe4e42a20 ti: c000001fe4e88000 task.ti: c000001fe4e88000
  [1.402742] NIP: c0000000007e33f8 LR: c0000000007e3164 CTR: c000000000595ea0
  [1.402787] REGS: c000001fe4e8b790 TRAP: 0300   Not tainted  (4.4.0-36-generic)
  [1.402832] MSR: 9000000100009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 28000422  XER: 20000000
  [1.403058] CFAR: c000000000008468 DAR: 0000000000001a99 DSISR: 42000000 SOFTE: 1
  GPR00: c0000000007e3164 c000001fe4e8ba10 c0000000015c5e00 0000000000000000
  GPR04: 0000000000000001 0000000000000000 0000000000000039 0000000000000299
  GPR08: 0000000000000000 0000000000000001 c000001fe4e88000 0000000000000006
  GPR12: 0000000000000000 c00000000fb40000 c0000000000e6558 c000003ca1bffd00
  GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
  GPR20: 0000000000000000 0000000000000000 0000000000000000 c000000000d52768
  GPR24: c000000000d52740 0000000000000100 c000003ca1b52000 0000000000000002
  GPR28: 0000000000000900 0000000000000000 c00000000152a0c0 c000003ca1b52000
  [1.404226] NIP [c0000000007e33f8] tg3_io_error_detected+0x308/0x340
  [1.404265] LR [c0000000007e3164] tg3_io_error_detected+0x74/0x340

This patch avoids the NULL pointer dereference by moving the access after
the netdev NULL pointer check on tg3_io_error_detected(). Also, we add a
check for netdev being NULL on tg3_io_resume() [suggested by Michael Chan].

Fixes: 0486a063b1ff ("tg3: prevent ifup/ifdown during PCI error recovery")
Fixes: dfc8f370316b ("net/tg3: Release IRQs on permanent error")
Tested-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
Signed-off-by: Milton Miller <miltonm@us.ibm.com>
Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---

  * v2 changelog: added netdev NULL check on tg3_io_resume() as per
    Michael Chan's suggestion.

 drivers/net/ethernet/broadcom/tg3.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a2551bc..ea967df 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -18122,14 +18122,14 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 
 	rtnl_lock();
 
-	/* We needn't recover from permanent error */
-	if (state == pci_channel_io_frozen)
-		tp->pcierr_recovery = true;
-
 	/* We probably don't have netdev yet */
 	if (!netdev || !netif_running(netdev))
 		goto done;
 
+	/* We needn't recover from permanent error */
+	if (state == pci_channel_io_frozen)
+		tp->pcierr_recovery = true;
+
 	tg3_phy_stop(tp);
 
 	tg3_netif_stop(tp);
@@ -18226,7 +18226,7 @@ static void tg3_io_resume(struct pci_dev *pdev)
 
 	rtnl_lock();
 
-	if (!netif_running(netdev))
+	if (!netdev || !netif_running(netdev))
 		goto done;
 
 	tg3_full_lock(tp, 0);
-- 
2.1.0
