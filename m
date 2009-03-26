From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: enforce read-after-write timing restriction on eeprom access
Date: Thu, 26 Mar 2009 17:14:36 +0000
Message-ID: <1238087676-14194-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:33646 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751167AbZCZROf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 13:14:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LAN911x datasheet specifies a minimum delay of 45ns between a write
of E2P_DATA and any read.  This patch adds a single dummy read of
BYTE_TEST to enforce this timing constraint.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index ad3cbc9..af8f60c 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1680,6 +1680,7 @@ static int smsc911x_eeprom_write_location(struct smsc911x_data *pdata,
 					  u8 address, u8 data)
 {
 	u32 op = E2P_CMD_EPC_CMD_ERASE_ | address;
+	u32 temp;
 	int ret;
 
 	SMSC_TRACE(DRV, "address 0x%x, data 0x%x", address, data);
@@ -1688,6 +1689,10 @@ static int smsc911x_eeprom_write_location(struct smsc911x_data *pdata,
 	if (!ret) {
 		op = E2P_CMD_EPC_CMD_WRITE_ | address;
 		smsc911x_reg_write(pdata, E2P_DATA, (u32)data);
+
+		/* Workaround for hardware read-after-write restriction */
+		temp = smsc911x_reg_read(pdata, BYTE_TEST);
+
 		ret = smsc911x_eeprom_send_cmd(pdata, op);
 	}
 
-- 
1.6.0.6

