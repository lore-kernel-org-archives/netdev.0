From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 1/7] bnx2x: fix crash on big-endian when adding VLAN
Date: Wed,  2 Mar 2016 13:47:05 +0100
Message-ID: <1456922831-15071-2-git-send-email-mschmidt@redhat.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45722 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcCBMoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:18 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x crashes during the initialization of the 8021q module on ppc64.
The bug is a missing conversion from le32 in
bnx2x_handle_classification_eqe() when obtaining the cid value from
struct eth_event_data.

The fields in struct eth_event_data should all be declared as
little-endian and conversions added where missing.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h   |  6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 13 +++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  9 ++++-----
 3 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 27aa080..90a4dba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -5207,9 +5207,9 @@ struct e2_integ_data {
  * set mac event data
  */
 struct eth_event_data {
-	u32 echo;
-	u32 reserved0;
-	u32 reserved1;
+	__le32 echo;
+	__le32 reserved0;
+	__le32 reserved1;
 };
 
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6c4e3a6..b707ba8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5280,14 +5280,14 @@ static void bnx2x_handle_classification_eqe(struct bnx2x *bp,
 {
 	unsigned long ramrod_flags = 0;
 	int rc = 0;
-	u32 cid = elem->message.data.eth_event.echo & BNX2X_SWCID_MASK;
+	u32 echo = le32_to_cpu(elem->message.data.eth_event.echo);
+	u32 cid = echo & BNX2X_SWCID_MASK;
 	struct bnx2x_vlan_mac_obj *vlan_mac_obj;
 
 	/* Always push next commands out, don't wait here */
 	__set_bit(RAMROD_CONT, &ramrod_flags);
 
-	switch (le32_to_cpu((__force __le32)elem->message.data.eth_event.echo)
-			    >> BNX2X_SWCID_SHIFT) {
+	switch (echo >> BNX2X_SWCID_SHIFT) {
 	case BNX2X_FILTER_MAC_PENDING:
 		DP(BNX2X_MSG_SP, "Got SETUP_MAC completions\n");
 		if (CNIC_LOADED(bp) && (cid == BNX2X_ISCSI_ETH_CID(bp)))
@@ -5308,8 +5308,7 @@ static void bnx2x_handle_classification_eqe(struct bnx2x *bp,
 		bnx2x_handle_mcast_eqe(bp);
 		return;
 	default:
-		BNX2X_ERR("Unsupported classification command: %d\n",
-			  elem->message.data.eth_event.echo);
+		BNX2X_ERR("Unsupported classification command: 0x%x\n", echo);
 		return;
 	}
 
@@ -5596,10 +5595,8 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 		      BNX2X_STATE_OPENING_WAIT4_PORT):
 		case (EVENT_RING_OPCODE_RSS_UPDATE_RULES |
 		      BNX2X_STATE_CLOSING_WAIT4_HALT):
-			cid = elem->message.data.eth_event.echo &
-				BNX2X_SWCID_MASK;
 			DP(BNX2X_MSG_SP, "got RSS_UPDATE ramrod. CID %d\n",
-			   cid);
+			   SW_CID(elem->message.data.eth_event.echo));
 			rss_raw->clear_pending(rss_raw);
 			break;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 9d02734..55fcc21 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1672,11 +1672,12 @@ void bnx2x_vf_handle_classification_eqe(struct bnx2x *bp,
 {
 	unsigned long ramrod_flags = 0;
 	int rc = 0;
+	u32 echo = le32_to_cpu(elem->message.data.eth_event.echo);
 
 	/* Always push next commands out, don't wait here */
 	set_bit(RAMROD_CONT, &ramrod_flags);
 
-	switch (elem->message.data.eth_event.echo >> BNX2X_SWCID_SHIFT) {
+	switch (echo >> BNX2X_SWCID_SHIFT) {
 	case BNX2X_FILTER_MAC_PENDING:
 		rc = vfq->mac_obj.complete(bp, &vfq->mac_obj, elem,
 					   &ramrod_flags);
@@ -1686,8 +1687,7 @@ void bnx2x_vf_handle_classification_eqe(struct bnx2x *bp,
 					    &ramrod_flags);
 		break;
 	default:
-		BNX2X_ERR("Unsupported classification command: %d\n",
-			  elem->message.data.eth_event.echo);
+		BNX2X_ERR("Unsupported classification command: 0x%x\n", echo);
 		return;
 	}
 	if (rc < 0)
@@ -1755,8 +1755,7 @@ int bnx2x_iov_eq_sp_event(struct bnx2x *bp, union event_ring_elem *elem)
 	case EVENT_RING_OPCODE_MULTICAST_RULES:
 	case EVENT_RING_OPCODE_FILTERS_RULES:
 	case EVENT_RING_OPCODE_RSS_UPDATE_RULES:
-		cid = (elem->message.data.eth_event.echo &
-		       BNX2X_SWCID_MASK);
+		cid = SW_CID(elem->message.data.eth_event.echo);
 		DP(BNX2X_MSG_IOV, "checking filtering comp cid=%d\n", cid);
 		break;
 	case EVENT_RING_OPCODE_VF_FLR:
-- 
2.5.0
