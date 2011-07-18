From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 16/45] bna: IOC PCI Init & Enable Changes
Date: Mon, 18 Jul 2011 01:22:36 -0700
Message-ID: <1310977385-5268-6-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37784 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801Ab1GRIXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:39 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Change to pass pci function class code rather than msg class
   code in pci init and ioc enablement functions

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |    6 +++---
 drivers/net/bna/bfa_ioc.h |    3 +--
 drivers/net/bna/bfi.h     |    8 +++++---
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index d970a42..c304212 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1449,7 +1449,7 @@ bfa_ioc_send_enable(struct bfa_ioc *ioc)
 
 	bfi_h2i_set(enable_req.mh, BFI_MC_IOC, BFI_IOC_H2I_ENABLE_REQ,
 		    bfa_ioc_portid(ioc));
-	enable_req.ioc_class = ioc->ioc_mc;
+	enable_req.clscode = htons(ioc->clscode);
 	do_gettimeofday(&tv);
 	enable_req.tv_sec = ntohl(tv.tv_sec);
 	bfa_ioc_mbox_send(ioc, &enable_req, sizeof(struct bfi_ioc_ctrl_req));
@@ -1867,9 +1867,9 @@ bfa_nw_ioc_detach(struct bfa_ioc *ioc)
  */
 void
 bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
-		 enum bfi_mclass mc)
+		 enum bfi_pcifn_class clscode)
 {
-	ioc->ioc_mc	= mc;
+	ioc->clscode	= clscode;
 	ioc->pcidev	= *pcidev;
 
 	/**
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 592a104..46309e4 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -188,7 +188,6 @@ struct bfa_ioc {
 	int			dbg_fwsave_len;
 	bool			dbg_fwsave_once;
 	enum bfi_pcifn_class	clscode;
-	enum bfi_mclass		ioc_mc;
 	struct bfa_ioc_regs	ioc_regs;
 	struct bfa_ioc_drv_stats stats;
 	bool			fcmode;
@@ -286,7 +285,7 @@ void bfa_nw_ioc_attach(struct bfa_ioc *ioc, void *bfa,
 void bfa_nw_ioc_auto_recover(bool auto_recover);
 void bfa_nw_ioc_detach(struct bfa_ioc *ioc);
 void bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
-		enum bfi_mclass mc);
+		enum bfi_pcifn_class clscode);
 u32 bfa_nw_ioc_meminfo(void);
 void bfa_nw_ioc_mem_claim(struct bfa_ioc *ioc,  u8 *dm_kva, u64 dm_pa);
 void bfa_nw_ioc_enable(struct bfa_ioc *ioc);
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index c855b44..284c3f8 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -37,13 +37,15 @@ struct bfi_mhdr {
 	u8		msg_id;		/*!< msg opcode with in the class   */
 	union {
 		struct {
-			u8	rsvd;
+			u8	qid;
 			u8	lpu_id;	/*!< msg destination		    */
 		} h2i;
 		u16	i2htok;	/*!< token in msgs to host	    */
 	} mtag;
 };
 
+#define bfi_mhdr_2_qid(_mh)     ((_mh)->mtag.h2i.qid)
+
 #define bfi_h2i_set(_mh, _mc, _op, _lpuid) do {		\
 	(_mh).msg_class			= (_mc);		\
 	(_mh).msg_id			= (_op);		\
@@ -393,8 +395,8 @@ enum {
  */
 struct bfi_ioc_ctrl_req {
 	struct bfi_mhdr mh;
-	u8			ioc_class;
-	u8			rsvd[3];
+	u16			clscode;
+	u16			rsvd;
 	u32		tv_sec;
 };
 
-- 
1.7.1

