From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] igb: re-assign hw address pointer on reset after PCI error
Date: Mon, 31 Oct 2016 18:12:29 -0200
Message-ID: <1477944749-22822-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: jeffrey.t.kirsher@intel.com, gpiccoli@linux.vnet.ibm.com,
        netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53036 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S946256AbcJaUMi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:12:38 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9VK8cnF037808
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 16:12:38 -0400
Received: from e24smtp03.br.ibm.com (e24smtp03.br.ibm.com [32.104.18.24])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26e91agshd-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 16:12:37 -0400
Received: from localhost
        by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Mon, 31 Oct 2016 18:12:34 -0200
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.18.232.225])
        by d24dlp01.br.ibm.com (Postfix) with ESMTP id 261C8352005F
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 16:12:05 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
        by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9VKCW0G34472096
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 18:12:32 -0200
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
        by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9VKCVYZ026481
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 18:12:32 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever the igb driver detects the result of a read operation returns
a value composed only by F's (like 0xFFFFFFFF), it will detach the
net_device, clear the hw_addr pointer and warn to the user that adapter's
link is lost - those steps happen on igb_rd32().

In case a PCI error happens on Power architecture, there's a recovery
mechanism called EEH, that will reset the PCI slot and call driver's
handlers to reset the adapter and network functionality as well.

We observed that once hw_addr is NULL after the error is detected on
igb_rd32(), it's never assigned back, so in the process of resetting
the network functionality we got a NULL pointer dereference in both
igb_configure_tx_ring() and igb_configure_rx_ring(). In order to avoid
such bug, we re-assign the hw_addr value in the beginning of the
function igb_reset(), in case the hw_addr is NULL when we reach that
path.

Reported-by: Anthony H. Thai <ahthai@us.ibm.com>
Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index edc9a6a..c19119c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1873,6 +1873,13 @@ void igb_reset(struct igb_adapter *adapter)
 	struct e1000_fc_info *fc = &hw->fc;
 	u32 pba, hwm;
 
+	/* In case of PCI error, adapter might have lost its HW
+	 * address; if we reached this point after an error scenario,
+	 * we should re-assign the hw_addr based on the saved io_addr.
+	 */
+	if (!hw->hw_addr)
+		hw->hw_addr = adapter->io_addr;
+
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
-- 
2.1.0
