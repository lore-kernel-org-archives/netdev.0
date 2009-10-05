From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 08/15] igb: add function to handle mailbox lock
Date: Mon, 05 Oct 2009 09:33:46 -0700
Message-ID: <20091005163345.32487.58098.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:45723
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753894AbZJEQf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:35:57 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Both the read and write mailbox functions need to acquire the mailbox lock.
Since that is the case we might as well combine both of the procedures into
one function so it is easier to maintain.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mbx.c |   63 +++++++++++++++++++++++--------------------
 1 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/igb/e1000_mbx.c
index ed9058e..ef645f6 100644
--- a/drivers/net/igb/e1000_mbx.c
+++ b/drivers/net/igb/e1000_mbx.c
@@ -305,6 +305,30 @@ static s32 igb_check_for_rst_pf(struct e1000_hw *hw, u16 vf_number)
 }
 
 /**
+ *  igb_obtain_mbx_lock_pf - obtain mailbox lock
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  return SUCCESS if we obtained the mailbox lock
+ **/
+static s32 igb_obtain_mbx_lock_pf(struct e1000_hw *hw, u16 vf_number)
+{
+	s32 ret_val = -E1000_ERR_MBX;
+	u32 p2v_mailbox;
+
+
+	/* Take ownership of the buffer */
+	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_PFU);
+
+	/* reserve mailbox for vf use */
+	p2v_mailbox = rd32(E1000_P2VMAILBOX(vf_number));
+	if (p2v_mailbox & E1000_P2VMAILBOX_PFU)
+		ret_val = 0;
+
+	return ret_val;
+}
+
+/**
  *  igb_write_mbx_pf - Places a message in the mailbox
  *  @hw: pointer to the HW structure
  *  @msg: The message buffer
@@ -316,27 +340,17 @@ static s32 igb_check_for_rst_pf(struct e1000_hw *hw, u16 vf_number)
 static s32 igb_write_mbx_pf(struct e1000_hw *hw, u32 *msg, u16 size,
                               u16 vf_number)
 {
-	u32 p2v_mailbox;
-	s32 ret_val = 0;
+	s32 ret_val;
 	u16 i;
 
-	/* Take ownership of the buffer */
-	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_PFU);
-
-	/* Make sure we have ownership now... */
-	p2v_mailbox = rd32(E1000_P2VMAILBOX(vf_number));
-	if (!(p2v_mailbox & E1000_P2VMAILBOX_PFU)) {
-		/* failed to grab ownership */
-		ret_val = -E1000_ERR_MBX;
+	/* lock the mailbox to prevent pf/vf race condition */
+	ret_val = igb_obtain_mbx_lock_pf(hw, vf_number);
+	if (ret_val)
 		goto out_no_write;
-	}
 
-	/*
-	 * flush any ack or msg which may already be in the queue
-	 * as they are likely the result of an error
-	 */
-	igb_check_for_ack_pf(hw, vf_number);
+	/* flush msg and acks as we are overwriting the message buffer */
 	igb_check_for_msg_pf(hw, vf_number);
+	igb_check_for_ack_pf(hw, vf_number);
 
 	/* copy the caller specified message to the mailbox memory buffer */
 	for (i = 0; i < size; i++)
@@ -367,20 +381,13 @@ out_no_write:
 static s32 igb_read_mbx_pf(struct e1000_hw *hw, u32 *msg, u16 size,
                              u16 vf_number)
 {
-	u32 p2v_mailbox;
-	s32 ret_val = 0;
+	s32 ret_val;
 	u16 i;
 
-	/* Take ownership of the buffer */
-	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_PFU);
-
-	/* Make sure we have ownership now... */
-	p2v_mailbox = rd32(E1000_P2VMAILBOX(vf_number));
-	if (!(p2v_mailbox & E1000_P2VMAILBOX_PFU)) {
-		/* failed to grab ownership */
-		ret_val = -E1000_ERR_MBX;
+	/* lock the mailbox to prevent pf/vf race condition */
+	ret_val = igb_obtain_mbx_lock_pf(hw, vf_number);
+	if (ret_val)
 		goto out_no_read;
-	}
 
 	/* copy the message to the mailbox memory buffer */
 	for (i = 0; i < size; i++)
@@ -392,8 +399,6 @@ static s32 igb_read_mbx_pf(struct e1000_hw *hw, u32 *msg, u16 size,
 	/* update stats */
 	hw->mbx.stats.msgs_rx++;
 
-	ret_val = 0;
-
 out_no_read:
 	return ret_val;
 }

