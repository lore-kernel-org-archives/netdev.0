From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Fix a race between sky2_down and sky2_poll
Date: Tue, 9 Jun 2009 23:03:52 +0900
Message-ID: <392fb48f0906090703q66fbaf56wbf1157f90b97df0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:53865 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZFIODv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 10:03:51 -0400
Received: by fxm9 with SMTP id 9so3005109fxm.37
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 07:03:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

This patch fixes a crash in the sky2 driver when doing "ifconfig eth1
down" and receiving a constant stream of ethernet packets on my
mac-mini with Linux 2.6.29.4.  This is what I can see of the crash on
the console:

do_IRQ+0x64/0x77
common_interrupt+0x27/0x2c
kfree+0x78/0x95
__kfree_skb+0xf/0x6e
sky2_rx_clean+0x35/0x48
sky2_down+0x367/0x486
dev_close+0x63/0x85
dev_change_flags+0xa2/0x153
devinet_ioctl+0x22a/0x532
sock_ioctl+0x1ad/0x1d1
sock_ioctl+0x0/0x1d1
vfs_ioctl+0x1c/0x5f
do_vfs_ioctl+0x456/0x491
net_tx_action+0xc6/0x123
__do_soft_irq+0x8c/0x115
sys_ioctl+0x4/0x58
sysenter_do_call+0x12/0x2f
Code: 68 cd f0 93 de e9 0 02 00 00 8b 4c 24 24 0f b7 ...
EIP: sky2_poll+0x856/0xb49 [sky2]
kernel panic - no syncing: fatal exception in interrupt

This was tested by adding a USB ethernet dongle to the same machine,
and creating a program that spews raw packets back to the sky2 port.

I have update my analysis and tweaked the patch slightly.

I had a look at the callers of sky2_down, and can't see any immediate
trouble that could be caused by this patch.  If you have any
suggestions for further improvements, please let me know what they are
and I will do my best to address them.

thanks,

Mike


---

If sky2_down was called between an interrupt and the corresponding sky2_poll,
rx_ring will have been free'd and we'll crash.

This may happen because not all sources of interrupts are masked in sky2_down,
but a single interrupt from any source will cause all sources to be
checked, regardless of whether they are masked or not.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a2ff9cb..d0d4840 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1822,8 +1822,8 @@ static int sky2_down(struct net_device *dev)
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);

-	/* Make sure no packets are pending */
-	napi_synchronize(&hw->napi);
+	/* disable soft interrupts */
+	napi_disable(&hw->napi);

 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);

@@ -1878,6 +1878,9 @@ static int sky2_down(struct net_device *dev)
 	sky2->rx_ring = NULL;
 	sky2->tx_ring = NULL;

+	/* re-enable soft interrupts */
+	napi_enable(&hw->napi);
+
 	return 0;
 }

@@ -2372,6 +2375,13 @@ static int sky2_status_intr(struct sky2_hw *hw,
int to_do, u16 idx)
 		length = le16_to_cpu(le->length);
 		status = le32_to_cpu(le->status);

+		/* rx_ring may have been free'd in sky2_down */
+		if (unlikely(!sky2->rx_ring)) {
+			printk(KERN_INFO "sky2_status_intr: rx_ring NULL opcode %02x\n", opcode);
+			work_done++;
+			break;
+		}
+
 		le->opcode = 0;
 		switch (opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
-- 
1.5.6.5
