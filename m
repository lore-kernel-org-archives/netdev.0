From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Delay during kdump load
Date: Wed, 29 Apr 2015 08:09:49 +0300
Message-ID: <1430284189-6773-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:3244 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751518AbbD2FKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 01:10:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a kdump environment interfaces might be re-loaded without a proper
unload sequence in the previous running kernel.
bnx2x management FW and driver maintains a `pulse' that notifies the FW
that the driver is still up and running.

Driver load on the kdump kernel should be performed only after the pulse
has been out-of-sync long enough for the management FW to identify that
the driver has crashed, on which point it will perform some necessary
cleanup of the HW.

In today's distros kdump loading is quite fast, sometimes too fast for our
FW to get out-of-sync. This patch delays the bnx2x's probe during kdump
to allow a proper re-load on the kdump kernel.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

---
Hi Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b9f85fcc..0939279 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13371,6 +13371,12 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	bool is_vf;
 	int cnic_cnt;
 
+	/* Management FW 'remembers' living interfaces. Allow it some time
+	 * to forget previously living interfaces, allowing a proper re-load.
+	 */
+	if (is_kdump_kernel())
+		msleep(5000);
+
 	/* An estimated maximum supported CoS number according to the chip
 	 * version.
 	 * We will try to roughly estimate the maximum number of CoSes this chip
-- 
1.9.3
