From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] cxgb4: avoid crash on PCI error recovery path
Date: Sun, 28 May 2017 23:07:01 -0300
Message-ID: <20170529020701.27765-1-gpiccoli@linux.vnet.ibm.com>
Cc: muvic@linux.vnet.ibm.com, gpiccoli@linux.vnet.ibm.com,
        porcusbr@gmail.com, ganeshgr@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40507 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750837AbdE2CHI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 22:07:08 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4T23bGq099970
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 22:07:08 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2aqm1p27mk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 22:07:07 -0400
Received: from localhost
        by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Sun, 28 May 2017 23:07:05 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
        by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4T273hR34734184
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 23:07:04 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
        by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4T273BO014878
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 23:07:04 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During PCI error recovery process, specifically on eeh_err_detected()
we might have a NULL netdev struct, hence a direct dereference will
lead to a kernel oops. This was observed with latest upstream kernel
(v4.12-rc2) on Chelsio adapter T422-CR in PowerPC machines.

This patch checks for NULL pointer and avoids the crash, both in
eeh_err_detected() and eeh_resume(). Also, we avoid to trigger
a fatal error or to try disabling interrupts on FW during PCI
error recovery, because: (a) driver might not be able to accurately
access PCI regions in this case, and (b) trigger a fatal error
_during_ the recovery steps is a mistake that could prevent the
recovery path to complete successfully.

Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 21 +++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  9 +++++++--
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 38a5c6764bb5..b512149684fd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2771,6 +2771,9 @@ void t4_fatal_err(struct adapter *adap)
 {
 	int port;
 
+	if (pci_channel_offline(adap->pdev))
+		return;
+
 	/* Disable the SGE since ULDs are going to free resources that
 	 * could be exposed to the adapter.  RDMA MWs for example...
 	 */
@@ -3882,9 +3885,10 @@ static pci_ers_result_t eeh_err_detected(struct pci_dev *pdev,
 	spin_lock(&adap->stats_lock);
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
-
-		netif_device_detach(dev);
-		netif_carrier_off(dev);
+		if (dev) {
+			netif_device_detach(dev);
+			netif_carrier_off(dev);
+		}
 	}
 	spin_unlock(&adap->stats_lock);
 	disable_interrupts(adap);
@@ -3963,12 +3967,13 @@ static void eeh_resume(struct pci_dev *pdev)
 	rtnl_lock();
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
-
-		if (netif_running(dev)) {
-			link_start(dev);
-			cxgb_set_rxmode(dev);
+		if (dev) {
+			if (netif_running(dev)) {
+				link_start(dev);
+				cxgb_set_rxmode(dev);
+			}
+			netif_device_attach(dev);
 		}
-		netif_device_attach(dev);
 	}
 	rtnl_unlock();
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index aded42b96f6d..3a34aa629f7d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4557,8 +4557,13 @@ void t4_intr_enable(struct adapter *adapter)
  */
 void t4_intr_disable(struct adapter *adapter)
 {
-	u32 whoami = t4_read_reg(adapter, PL_WHOAMI_A);
-	u32 pf = CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5 ?
+	u32 whoami, pf;
+
+	if (pci_channel_offline(adapter->pdev))
+		return;
+
+	whoami = t4_read_reg(adapter, PL_WHOAMI_A);
+	pf = CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5 ?
 			SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami);
 
 	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE_A), 0);
-- 
2.12.0.rc0
