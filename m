From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 3/5] qlcnic: updated reset sequence
Date: Fri, 28 Oct 2011 15:57:13 -0700
Message-ID: <1319842636-14936-3-git-send-email-anirban.chakraborty@qlogic.com>
References: <1319842636-14936-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:56269
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752196Ab1J1XJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 19:09:36 -0400
In-Reply-To: <1319842636-14936-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h  |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c |   50 +++++++++++++++++++++-
 2 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 92bc8ce..a528193 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -407,7 +407,9 @@ enum {
 #define QLCNIC_CRB_SRE		QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_SRE)
 #define QLCNIC_CRB_ROMUSB	\
 	QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_ROMUSB)
+#define QLCNIC_CRB_EPG		QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_EG)
 #define QLCNIC_CRB_I2Q		QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_I2Q)
+#define QLCNIC_CRB_TIMER	QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_TIMR)
 #define QLCNIC_CRB_I2C0 	QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_I2C0)
 #define QLCNIC_CRB_SMB		QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_SMB)
 #define QLCNIC_CRB_MAX		QLCNIC_PCI_CRB_WINDOW(64)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 312c1c3..3866958 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -422,9 +422,53 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, CRB_CMDPEG_STATE, 0);
 	QLCWR32(adapter, CRB_RCVPEG_STATE, 0);
 
-	qlcnic_rom_lock(adapter);
-	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0xfeffffff);
+	/* Halt all the indiviual PEGs and other blocks */
+	/* disable all I2Q */
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x10, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x14, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x18, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x1c, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x20, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x24, 0x0);
+
+	/* disable all niu interrupts */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x40, 0xff);
+	/* disable xge rx/tx */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x70000, 0x00);
+	/* disable xg1 rx/tx */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x80000, 0x00);
+	/* disable sideband mac */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x90000, 0x00);
+	/* disable ap0 mac */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xa0000, 0x00);
+	/* disable ap1 mac */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xb0000, 0x00);
+
+	/* halt sre */
+	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000);
+	QLCWR32(adapter, QLCNIC_CRB_SRE + 0x1000, val & (~(0x1)));
+
+	/* halt epg */
+	QLCWR32(adapter, QLCNIC_CRB_EPG + 0x1300, 0x1);
+
+	/* halt timers */
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x0, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x8, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x10, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x18, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x100, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x200, 0x0);
+	/* halt pegs */
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c, 1);
+	msleep(20);
+
 	qlcnic_rom_unlock(adapter);
+	/* big hammer don't reset CAM block on reset */
+	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0xfeffffff);
 
 	/* Init HW CRB block */
 	if (qlcnic_rom_fast_read(adapter, 0, &n) != 0 || (n != 0xcafecafe) ||
@@ -522,8 +566,10 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x8, 0);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
 	msleep(1);
+
 	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
 	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
+
 	return 0;
 }
 
-- 
1.7.4.1
