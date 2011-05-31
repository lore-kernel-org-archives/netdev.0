From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Fallback to the older opcode if MCC_CREATE_EXT opcode is not supported on the card
Date: Tue, 31 May 2011 19:52:45 +0530
Message-ID: <fc661b1b-2368-41ce-9c6d-d0f799e243d8@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:3153 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755554Ab1EaIzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 04:55:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of failing the init/probe code in the driver fallback to the older opcode
to ensure the driver is loaded thereby enabling users to upgrade the f/w to
whatever version is required.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_cmds.c |   65 +++++++++++++++++++++++++++++++++++++++++-
 drivers/net/benet/be_cmds.h |    8 +++++
 drivers/net/benet/be_main.c |    4 ++
 3 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 2463b1c..6c75f54 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -799,12 +799,12 @@ static u32 be_encoded_q_len(int q_len)
 	return len_encoded;
 }
 
-int be_cmd_mccq_create(struct be_adapter *adapter,
+int be_cmd_mccq_ext_create(struct be_adapter *adapter,
 			struct be_queue_info *mccq,
 			struct be_queue_info *cq)
 {
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_mcc_create *req;
+	struct be_cmd_req_mcc_ext_create *req;
 	struct be_dma_mem *q_mem = &mccq->dma_mem;
 	void *ctxt;
 	int status;
@@ -859,6 +859,67 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 	return status;
 }
 
+int be_cmd_mccq_org_create(struct be_adapter *adapter,
+			struct be_queue_info *mccq,
+			struct be_queue_info *cq)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_mcc_create *req;
+	struct be_dma_mem *q_mem = &mccq->dma_mem;
+	void *ctxt;
+	int status;
+
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
+	ctxt = &req->context;
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_MCC_CREATE);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_MCC_CREATE, sizeof(*req));
+
+	req->num_pages = cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
+
+	AMAP_SET_BITS(struct amap_mcc_context_be, valid, ctxt, 1);
+	AMAP_SET_BITS(struct amap_mcc_context_be, ring_size, ctxt,
+			be_encoded_q_len(mccq->len));
+	AMAP_SET_BITS(struct amap_mcc_context_be, cq_id, ctxt, cq->id);
+
+	be_dws_cpu_to_le(ctxt, sizeof(req->context));
+
+	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
+
+	status = be_mbox_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_mcc_create *resp = embedded_payload(wrb);
+		mccq->id = le16_to_cpu(resp->id);
+		mccq->created = true;
+	}
+
+	mutex_unlock(&adapter->mbox_lock);
+	return status;
+}
+
+int be_cmd_mccq_create(struct be_adapter *adapter,
+			struct be_queue_info *mccq,
+			struct be_queue_info *cq)
+{
+	int status;
+
+	status = be_cmd_mccq_ext_create(adapter, mccq, cq);
+	if (status && !lancer_chip(adapter)) {
+		dev_warn(&adapter->pdev->dev, "Upgrade to F/W ver 2.102.235.0 "
+			"or newer to avoid conflicting priorities between NIC "
+			"and FCoE traffic");
+		status = be_cmd_mccq_org_create(adapter, mccq, cq);
+	}
+	return status;
+}
+
 int be_cmd_txq_create(struct be_adapter *adapter,
 			struct be_queue_info *txq,
 			struct be_queue_info *cq)
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 8148cc6..d08289e 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -434,6 +434,14 @@ struct be_cmd_req_mcc_create {
 	struct be_cmd_req_hdr hdr;
 	u16 num_pages;
 	u16 cq_id;
+	u8 context[sizeof(struct amap_mcc_context_be) / 8];
+	struct phys_addr pages[8];
+} __packed;
+
+struct be_cmd_req_mcc_ext_create {
+	struct be_cmd_req_hdr hdr;
+	u16 num_pages;
+	u16 cq_id;
 	u32 async_event_bitmap[1];
 	u8 context[sizeof(struct amap_mcc_context_be) / 8];
 	struct phys_addr pages[8];
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4b5e0ed..4a034cc 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3395,6 +3395,10 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	}
 
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
+	/* By default all priorities are enabled.
+	Needed in case of no GRP5 evt support */
+	adapter->vlan_prio_bmap = 0xff;
+
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 
-- 
1.5.6.1

