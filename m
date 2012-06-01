From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/2] 8139cp/8139too: terminate the eeprom access with the
	right opmode
Date: Fri, 01 Jun 2012 12:19:48 +0800
Message-ID: <20120601041948.4311.42372.stgit@dhcp-8-146.nay.redhat.com>
References: <20120601041939.4311.55827.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120601041939.4311.55827.stgit@dhcp-8-146.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, we terminate the eeprom access through clearing the CS by:

RTL_W8 (Cfg9346, ~EE_CS); or writeb (~EE_CS, ee_addr);

This would left the eeprom into "Config. Register Write Enable:"
state which is not expcted as the highest two bits were set to
0x11 ( expected is the "Normal" mode (0x00)). Solving this by write
0x0 instead of ~EE_CS when terminating the eeprom access.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/ethernet/realtek/8139cp.c  |    2 +-
 drivers/net/ethernet/realtek/8139too.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 7f08779..995d0cf 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1636,7 +1636,7 @@ static void eeprom_cmd(void __iomem *ee_addr, int cmd, int cmd_len)
 
 static void eeprom_cmd_end(void __iomem *ee_addr)
 {
-	writeb (~EE_CS, ee_addr);
+	writeb(0, ee_addr);
 	eeprom_delay ();
 }
 
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 03df076..1d83565 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1173,7 +1173,7 @@ static int __devinit read_eeprom (void __iomem *ioaddr, int location, int addr_l
 	}
 
 	/* Terminate the EEPROM access. */
-	RTL_W8 (Cfg9346, ~EE_CS);
+	RTL_W8(Cfg9346, 0);
 	eeprom_delay ();
 
 	return retval;
