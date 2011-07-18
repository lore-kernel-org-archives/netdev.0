From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 40/45] bna: Add IOC MBOX Call Back to Client
Date: Mon, 18 Jul 2011 01:23:00 -0700
Message-ID: <1310977385-5268-30-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48279 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754872Ab1GRIZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:14 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change deatils:
 - Give a callback to the client indicating that the command is sent
 - Removed a typecast
 - When done with IOC detach we empty the notify_q.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   24 ++++++++++++++++++------
 drivers/net/bna/bfi.h     |   17 +++++++++--------
 2 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index e612ca4..b086cd7 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1768,7 +1768,9 @@ bfa_ioc_mbox_poll(struct bfa_ioc *ioc)
 {
 	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
 	struct bfa_mbox_cmd *cmd;
-	u32			stat;
+	bfa_mbox_cmd_cbfn_t cbfn;
+	void *cbarg;
+	u32 stat;
 
 	/**
 	 * If no command pending, do nothing
@@ -1788,6 +1790,16 @@ bfa_ioc_mbox_poll(struct bfa_ioc *ioc)
 	 */
 	bfa_q_deq(&mod->cmd_q, &cmd);
 	bfa_ioc_mbox_send(ioc, cmd->msg, sizeof(cmd->msg));
+
+	/**
+	 * Give a callback to the client, indicating that the command is sent
+	 */
+	if (cmd->cbfn) {
+		cbfn = cmd->cbfn;
+		cbarg = cmd->cbarg;
+		cmd->cbfn = NULL;
+		cbfn(cbarg);
+	}
 }
 
 /**
@@ -1953,7 +1965,7 @@ bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
 	case BFI_IOC_I2H_ENABLE_REPLY:
 		bfa_ioc_enable_reply(ioc,
 			(enum bfa_mode)msg->fw_event.port_mode,
-			(enum bfa_mode)msg->fw_event.cap_bm);
+			msg->fw_event.cap_bm);
 		break;
 
 	case BFI_IOC_I2H_DISABLE_REPLY:
@@ -2003,6 +2015,9 @@ void
 bfa_nw_ioc_detach(struct bfa_ioc *ioc)
 {
 	bfa_fsm_send_event(ioc, IOC_E_DETACH);
+
+	/* Done with detach, empty the notify_q. */
+	INIT_LIST_HEAD(&ioc->notify_q);
 }
 
 /**
@@ -2292,15 +2307,12 @@ bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
 enum bfa_ioc_type
 bfa_nw_ioc_get_type(struct bfa_ioc *ioc)
 {
-	enum bfi_port_mode mode;
-
 	if (ioc->clscode == BFI_PCIFN_CLASS_ETH)
 		return BFA_IOC_TYPE_LL;
 
 	BUG_ON(!(ioc->clscode == BFI_PCIFN_CLASS_FC));
 
-	mode = (ioc->port_id == 0) ? ioc->port0_mode : ioc->port1_mode;
-	return (mode == BFI_PORT_MODE_FC)
+	return (ioc->attr->port_mode == BFI_PORT_MODE_FC)
 		? BFA_IOC_TYPE_FC : BFA_IOC_TYPE_FCoE;
 }
 
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index c534318..8dd8463 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -15,7 +15,6 @@
  * All rights reserved
  * www.brocade.com
  */
-
 #ifndef __BFI_H__
 #define __BFI_H__
 
@@ -38,18 +37,20 @@ struct bfi_mhdr {
 	union {
 		struct {
 			u8	qid;
-			u8	lpu_id;	/*!< msg destination		    */
+			u8	fn_lpu;	/*!< msg destination		    */
 		} h2i;
 		u16	i2htok;	/*!< token in msgs to host	    */
 	} mtag;
 };
 
-#define bfi_mhdr_2_qid(_mh)     ((_mh)->mtag.h2i.qid)
+#define bfi_fn_lpu(__fn, __lpu)	((__fn) << 1 | (__lpu))
+#define bfi_mhdr_2_fn(_mh)	((_mh)->mtag.h2i.fn_lpu >> 1)
+#define bfi_mhdr_2_qid(_mh)	((_mh)->mtag.h2i.qid)
 
-#define bfi_h2i_set(_mh, _mc, _op, _lpuid) do {		\
+#define bfi_h2i_set(_mh, _mc, _op, _fn_lpu) do {		\
 	(_mh).msg_class			= (_mc);		\
 	(_mh).msg_id			= (_op);		\
-	(_mh).mtag.h2i.lpu_id	= (_lpuid);			\
+	(_mh).mtag.h2i.fn_lpu	= (_fn_lpu);			\
 } while (0)
 
 #define bfi_i2h_set(_mh, _mc, _op, _i2htok) do {		\
@@ -240,7 +241,8 @@ struct bfi_ioc_attr {
 	u64		mfg_pwwn;	/*!< Mfg port wwn	   */
 	u64		mfg_nwwn;	/*!< Mfg node wwn	   */
 	mac_t		mfg_mac;	/*!< Mfg mac		   */
-	u16	rsvd_a;
+	u8		port_mode;	/* enum bfi_port_mode	   */
+	u8		rsvd_a;
 	u64		pwwn;
 	u64		nwwn;
 	mac_t		mac;		/*!< PBC or Mfg mac	   */
@@ -297,7 +299,6 @@ struct bfi_ioc_image_hdr {
 	u8	asic_mode;
 	u8	port0_mode;	/*!< device mode for port 0 */
 	u8	port1_mode;	/*!< device mode for port 1 */
-	u8	rsvd_a;
 	u32	exec;		/*!< exec vector	*/
 	u32	bootenv;	/*!< firmware boot env */
 	u32	rsvd_b[4];
@@ -400,7 +401,7 @@ struct bfi_ioc_ctrl_req {
 struct bfi_ioc_ctrl_reply {
 	struct bfi_mhdr mh;			/*!< Common msg header     */
 	u8			status;		/*!< enable/disable status */
-	u8			port_mode;	/*!< bfa_mode */
+	u8			port_mode;	/*!< enum bfa_mode */
 	u8			cap_bm;		/*!< capability bit mask */
 	u8			rsvd;
 };
-- 
1.7.1

