From: Bernhard Thaler <bernhard.thaler@r-it.at>
Subject: [PATCH 1/1] bluetooth: Check for SCO type before setting  retransmission effort
Date: Wed, 17 Sep 2014 09:13:30 +0200
Message-ID: <1410938010-6181-1-git-send-email-bernhard.thaler@r-it.at>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Bernhard Thaler" <bernhard.thaler@r-it.at>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Bernhard Thaler" <bernhard.thaler@r-it.at>

SCO connection cannot be setup to devices that do not support retransmission.
Patch based on http://permalink.gmane.org/gmane.linux.bluez.kernel/7779 and
adapted for this kernel version.
Code changed to check SCO/eSCO type before setting retransmission effort 
and max. latency. The purpose of the patch is to support older devices not
 capable of eSCO.

Tested on Blackberry 655+ headset which does not support retransmission.
Credits go to Alexander Sommerhuber.

Signed-off-by: Bernhard Thaler <bernhard.thaler@r-it.at>
---
 net/bluetooth/hci_conn.c |   39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index faff624..093abcc 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -186,26 +186,31 @@ bool hci_setup_sync(struct hci_conn *conn, __u16 handle)
 	cp.rx_bandwidth   = cpu_to_le32(0x00001f40);
 	cp.voice_setting  = cpu_to_le16(conn->setting);
 
-	switch (conn->setting & SCO_AIRMODE_MASK) {
-	case SCO_AIRMODE_TRANSP:
-		if (conn->attempt > ARRAY_SIZE(sco_param_wideband))
-			return false;
-		cp.retrans_effort = 0x02;
-		param = &sco_param_wideband[conn->attempt - 1];
-		break;
-	case SCO_AIRMODE_CVSD:
-		if (conn->attempt > ARRAY_SIZE(sco_param_cvsd))
+	if (!(conn->link->features[0][3] & LMP_ESCO)) {
+		cp.retrans_effort = 0xff;
+		cp.pkt_type = __cpu_to_le16(conn->pkt_type);
+		cp.max_latency = __cpu_to_le16(0xffff);
+	} else {
+		switch (conn->setting & SCO_AIRMODE_MASK) {
+		case SCO_AIRMODE_TRANSP:
+			if (conn->attempt > ARRAY_SIZE(sco_param_wideband))
+				return false;
+			cp.retrans_effort = 0x02;
+			param = &sco_param_wideband[conn->attempt - 1];
+			break;
+		case SCO_AIRMODE_CVSD:
+			if (conn->attempt > ARRAY_SIZE(sco_param_cvsd))
+				return false;
+			cp.retrans_effort = 0x01;
+			param = &sco_param_cvsd[conn->attempt - 1];
+			break;
+		default:
 			return false;
-		cp.retrans_effort = 0x01;
-		param = &sco_param_cvsd[conn->attempt - 1];
-		break;
-	default:
-		return false;
+		}
+		cp.pkt_type = __cpu_to_le16(param->pkt_type);
+		cp.max_latency = __cpu_to_le16(param->max_latency);
 	}
 
-	cp.pkt_type = __cpu_to_le16(param->pkt_type);
-	cp.max_latency = __cpu_to_le16(param->max_latency);
-
 	if (hci_send_cmd(hdev, HCI_OP_SETUP_SYNC_CONN, sizeof(cp), &cp) < 0)
 		return false;
 
-- 
1.7.10.4
