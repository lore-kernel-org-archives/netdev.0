From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next v1 3/4] bna: Enahncement to Identify Default IOC Function
Date: Sun, 12 May 2013 22:05:57 -0700
Message-ID: <1368421558-15695-4-git-send-email-rmody@brocade.com>
References: <1368421558-15695-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:41716 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753041Ab3EMFGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 01:06:19 -0400
In-Reply-To: <1368421558-15695-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User should not be allowed to delete base function of eth port. Add a new field
to the bfa ioc attributes structure to indicate if the given ioc is default
function on the port or not.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_defs.h |    3 ++-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c  |    7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_ioc.h  |    2 ++
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index e423f82..b7d8127 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -164,7 +164,8 @@ struct bfa_ioc_attr {
 	u8				port_mode;	/*!< enum bfa_mode */
 	u8				cap_bm;		/*!< capability */
 	u8				port_mode_cfg;	/*!< enum bfa_mode */
-	u8				rsvd[4];	/*!< 64bit align */
+	u8				def_fn;		/*!< 1 if default fn */
+	u8				rsvd[3];	/*!< 64bit align */
 };
 
 /* Adapter capability mask definition */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index f2b73ff..6f3cac0 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -2371,7 +2371,7 @@ bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr)
 	memset((void *)ioc_attr, 0, sizeof(struct bfa_ioc_attr));
 
 	ioc_attr->state = bfa_ioc_get_state(ioc);
-	ioc_attr->port_id = ioc->port_id;
+	ioc_attr->port_id = bfa_ioc_portid(ioc);
 	ioc_attr->port_mode = ioc->port_mode;
 
 	ioc_attr->port_mode_cfg = ioc->port_mode_cfg;
@@ -2381,8 +2381,9 @@ bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr)
 
 	bfa_ioc_get_adapter_attr(ioc, &ioc_attr->adapter_attr);
 
-	ioc_attr->pci_attr.device_id = ioc->pcidev.device_id;
-	ioc_attr->pci_attr.pcifn = ioc->pcidev.pci_func;
+	ioc_attr->pci_attr.device_id = bfa_ioc_devid(ioc);
+	ioc_attr->pci_attr.pcifn = bfa_ioc_pcifn(ioc);
+	ioc_attr->def_fn = bfa_ioc_is_default(ioc);
 	bfa_ioc_get_pci_chip_rev(ioc, ioc_attr->pci_attr.chip_rev);
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index 63a85e5..f04e0aa 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -222,6 +222,8 @@ struct bfa_ioc_hwif {
 #define bfa_ioc_bar0(__ioc)		((__ioc)->pcidev.pci_bar_kva)
 #define bfa_ioc_portid(__ioc)		((__ioc)->port_id)
 #define bfa_ioc_asic_gen(__ioc)		((__ioc)->asic_gen)
+#define bfa_ioc_is_default(__ioc)	\
+	(bfa_ioc_pcifn(__ioc) == bfa_ioc_portid(__ioc))
 #define bfa_ioc_fetch_stats(__ioc, __stats) \
 		(((__stats)->drv_stats) = (__ioc)->stats)
 #define bfa_ioc_clr_stats(__ioc)	\
-- 
1.7.1
