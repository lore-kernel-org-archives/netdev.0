From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH resend] rds_rdma: don't assume infiniband device is PCI
Date: Mon, 28 May 2012 15:52:05 -0300
Message-ID: <1338231125-9005-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	dledford@redhat.com, Jes.Sorensen@redhat.com
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:49984 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab2E1SwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 14:52:24 -0400
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 28 May 2012 15:52:22 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id B1F2E1DC004D
	for <netdev@vger.kernel.org>; Mon, 28 May 2012 15:52:13 -0300 (BRT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4SIpoCD16318610
	for <netdev@vger.kernel.org>; Mon, 28 May 2012 15:51:50 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4SGq72k015630
	for <netdev@vger.kernel.org>; Mon, 28 May 2012 13:52:08 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS code assumes that the struct ib_device dma_device member, which is a
pointer, points to a struct device embedded in a struct pci_dev.

This is not the case for ehca, for example, which is a OF driver, and
makes dma_device point to a struct device embedded in a struct
platform_device.

This will make the system crash when rds_rdma is loaded in a system
with ehca, since it will try to access the bus member of a non-existent
struct pci_dev.

The only reason rds_rdma uses the struct pci_dev is to get the NUMA node
the device is attached to. Using dev_to_node for that is much better,
since it won't assume which bus the infiniband is attached to.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: dledford@redhat.com
Cc: Jes.Sorensen@redhat.com
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
---

Hi, Venkat.

This patch is still not applied. Can you give your Ack?

Regards.
Cascardo.

---
 net/rds/ib.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index edfaaaf..8d2b3d5 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -186,8 +186,7 @@ struct rds_ib_device {
 	struct work_struct	free_work;
 };
 
-#define pcidev_to_node(pcidev) pcibus_to_node(pcidev->bus)
-#define ibdev_to_node(ibdev) pcidev_to_node(to_pci_dev(ibdev->dma_device))
+#define ibdev_to_node(ibdev) dev_to_node(ibdev->dma_device)
 #define rdsibdev_to_node(rdsibdev) ibdev_to_node(rdsibdev->dev)
 
 /* bits for i_ack_flags */
-- 
1.7.4.4
