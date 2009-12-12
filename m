From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] igb: fix handling of mailbox collisions between
	PF/VF
Date: Fri, 11 Dec 2009 19:40:57 -0800
Message-ID: <20091212034033.10674.67054.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:52536
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933225AbZLLDlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 22:41:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch changes the handling of collisions between the use of the PF/VF
sides of the mailbox.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 16349ba..78963a0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4608,8 +4608,14 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 
 	retval = igb_read_mbx(hw, msgbuf, E1000_VFMAILBOX_SIZE, vf);
 
-	if (retval)
+	if (retval) {
+		/* if receive failed revoke VF CTS stats and restart init */
 		dev_err(&pdev->dev, "Error receiving message from VF\n");
+		vf_data->flags &= ~IGB_VF_FLAG_CTS;
+		if (!time_after(jiffies, vf_data->last_nack + (2 * HZ)))
+			return;
+		goto out;
+	}
 
 	/* this is a message we already processed, do nothing */
 	if (msgbuf[0] & (E1000_VT_MSGTYPE_ACK | E1000_VT_MSGTYPE_NACK))
@@ -4626,12 +4632,10 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 	}
 
 	if (!(vf_data->flags & IGB_VF_FLAG_CTS)) {
-		msgbuf[0] = E1000_VT_MSGTYPE_NACK;
-		if (time_after(jiffies, vf_data->last_nack + (2 * HZ))) {
-			igb_write_mbx(hw, msgbuf, 1, vf);
-			vf_data->last_nack = jiffies;
-		}
-		return;
+		if (!time_after(jiffies, vf_data->last_nack + (2 * HZ)))
+			return;
+		retval = -1;
+		goto out;
 	}
 
 	switch ((msgbuf[0] & 0xFFFF)) {
@@ -4656,14 +4660,14 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 		break;
 	}
 
+	msgbuf[0] |= E1000_VT_MSGTYPE_CTS;
+out:
 	/* notify the VF of the results of what it sent us */
 	if (retval)
 		msgbuf[0] |= E1000_VT_MSGTYPE_NACK;
 	else
 		msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
 
-	msgbuf[0] |= E1000_VT_MSGTYPE_CTS;
-
 	igb_write_mbx(hw, msgbuf, 1, vf);
 }
 

