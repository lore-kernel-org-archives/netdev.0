From: Bernhard Thaler <bernhard.thaler@r-it.at>
Subject: [PATCHv3 1/1] bluetooth: Check for SCO type before setting retransmission effort
Date: Tue, 23 Sep 2014 07:59:24 +0200
Message-ID: <1411451964-4025-1-git-send-email-bernhard.thaler@r-it.at>
References: <1411035321-10215-1-git-send-email-bernhard.thaler@r-it.at>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Bernhard Thaler <bernhard.thaler@r-it.at>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411035321-10215-1-git-send-email-bernhard.thaler@r-it.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 net/bluetooth/hci_conn.c |   22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index faff624..32dcde1 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -38,7 +38,7 @@ struct sco_param {
 	u16 max_latency;
 };
 
-static const struct sco_param sco_param_cvsd[] = {
+static const struct sco_param esco_param_cvsd[] = {
 	{ EDR_ESCO_MASK & ~ESCO_2EV3, 0x000a }, /* S3 */
 	{ EDR_ESCO_MASK & ~ESCO_2EV3, 0x0007 }, /* S2 */
 	{ EDR_ESCO_MASK | ESCO_EV3,   0x0007 }, /* S1 */
@@ -46,6 +46,11 @@ static const struct sco_param sco_param_cvsd[] = {
 	{ EDR_ESCO_MASK | ESCO_HV1,   0xffff }, /* D0 */
 };
 
+static const struct sco_param sco_param_cvsd[] = {
+	{ EDR_ESCO_MASK | ESCO_HV3,   0xffff }, /* D1 */
+	{ EDR_ESCO_MASK | ESCO_HV1,   0xffff }, /* D0 */
+};
+
 static const struct sco_param sco_param_wideband[] = {
 	{ EDR_ESCO_MASK & ~ESCO_2EV3, 0x000d }, /* T2 */
 	{ EDR_ESCO_MASK | ESCO_EV3,   0x0008 }, /* T1 */
@@ -194,10 +199,17 @@ bool hci_setup_sync(struct hci_conn *conn, __u16 handle)
 		param = &sco_param_wideband[conn->attempt - 1];
 		break;
 	case SCO_AIRMODE_CVSD:
-		if (conn->attempt > ARRAY_SIZE(sco_param_cvsd))
-			return false;
-		cp.retrans_effort = 0x01;
-		param = &sco_param_cvsd[conn->attempt - 1];
+		if (!lmp_esco_capable(conn->link)) {
+			if ((conn->attempt) > ARRAY_SIZE(sco_param_cvsd))
+				return false;
+			cp.retrans_effort = 0xff;
+			param = &sco_param_cvsd[conn->attempt - 1];
+		} else {
+			if (conn->attempt > ARRAY_SIZE(esco_param_cvsd))
+				return false;
+			cp.retrans_effort = 0x01;
+			param = &esco_param_cvsd[conn->attempt - 1];
+		}
 		break;
 	default:
 		return false;
-- 
1.7.10.4
