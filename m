From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: Fix three oopses in PHY {de,}initialization code
Date: Fri, 27 Mar 2009 20:40:47 +0300
Message-ID: <20090327174047.GA23111@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:58419 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752714AbZC0Rku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 13:40:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there are no free snums, UCC ethernet should gracefully fail, but
currently it oopses this way:

  # ifconfig eth0 up
  fill_init_enet_entries: Can not get SNUM.
  ucc_geth_startup: Can not fill p_init_enet_param_shadow.
  eth0: Cannot configure net device, aborting.
  Unable to handle kernel paging request for data at address 0x00000190
  Faulting instruction address: 0xc0294c88
  Oops: Kernel access of bad area, sig: 11 [#1]
  [...]
  NIP [c0294c88] mutex_lock+0x0/0x1c
  LR [c01b6be8] phy_stop+0x20/0x70
  Call Trace:
  [efb25da0] [efb2eb60] 0xefb2eb60 (unreliable)
  [efb25db0] [c01b2058] ucc_geth_stop+0x2c/0x8c
  [efb25dd0] [c01b4194] ucc_geth_open+0x48/0x27c
  [efb25df0] [c020eec0] dev_open+0xc0/0x118
  [...]

This is because the ucc_geth_stop() routine assumes that ugeth->phydev
is always initialized by the ucc_geth_open(), while it is not in case
of errors.

If we add a check to the ucc_geth_stop(), then another oops pops up:

  Unable to handle kernel paging request for data at address 0x00000004
  Faulting instruction address: 0xc01b46a4
  Oops: Kernel access of bad area, sig: 11 [#1]
  [...]
  NIP [c01b46a4] adjust_link+0x20/0x1b4
  LR [c01b770c] phy_state_machine+0xdc/0x44c
  Call Trace:
  [ef83bf10] [c021b388] linkwatch_schedule_work+0x74/0xf8 (unreliable)
  [ef83bf40] [c01b770c] phy_state_machine+0xdc/0x44c
  [ef83bf60] [c004c13c] run_workqueue+0xb8/0x148
  [ef83bf90] [c004c870] worker_thread+0x70/0xd0
  [ef83bfd0] [c00505fc] kthread+0x48/0x84
  [ef83bff0] [c000f464] kernel_thread+0x4c/0x68
  [...]

That one happens because ucc_geth_stop() does not call phy_disconnect()
and so phylib state machine is running without any idea that a MAC has
just died.

Also, when device tree specifies fixed-link, and CONFIG_FIXED_PHY
is disabled, we'll get this oops:

  0:01 not found
  eth2: Could not attach to PHY
  eth2: Cannot initialize PHY, aborting.
  Unable to handle kernel paging request for data at address 0x00000190
  Faulting instruction address: 0xc02967d0
  Oops: Kernel access of bad area, sig: 11 [#1]
  [...]
  NIP [c02967d0] mutex_lock+0x0/0x1c
  LR [c01b6bcc] phy_stop+0x20/0x70
  Call Trace:
  [ef82be50] [efb6bb60] 0xefb6bb60 (unreliable)
  [ef82be60] [c01b2058] ucc_geth_stop+0x2c/0x8c
  [ef82be80] [c01b4194] ucc_geth_open+0x48/0x27c
  [ef82bea0] [c0210a04] dev_open+0xc0/0x118
  [ef82bec0] [c020f85c] dev_change_flags+0x84/0x1ac
  [ef82bee0] [c037b768] ic_open_devs+0x168/0x2bc
  [ef82bf20] [c037ca98] ip_auto_config+0x90/0x28c
  [ef82bf60] [c0001b9c] do_one_initcall+0x34/0x1a0
  [ef82bfd0] [c035e240] do_initcalls+0x38/0x58
  [ef82bfe0] [c035e2c4] kernel_init+0x30/0x90
  [ef82bff0] [c000f464] kernel_thread+0x4c/0x68
  [...]

And again, ucc_geth_stop() assumes that ugeth->phydev is there, while
it isn't.

This patch fixes all three oopses simply by rearranging some code:

- In ucc_geth_open(): move init_phy() call to the beginning, so
  that we only call ucc_geth_stop() with a PHY attached;
- Move phy_disconnect() call from ucc_geth_close() to
  ucc_geth_stop(), so that we'll always disconnect the PHY.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 1f61e42..9eef04b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2009,6 +2009,9 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	/* Disable Rx and Tx */
 	clrbits32(&ug_regs->maccfg1, MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);
 
+	phy_disconnect(ugeth->phydev);
+	ugeth->phydev = NULL;
+
 	ucc_geth_memclean(ugeth);
 }
 
@@ -3345,6 +3348,14 @@ static int ucc_geth_open(struct net_device *dev)
 		return -EINVAL;
 	}
 
+	err = init_phy(dev);
+	if (err) {
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot initialize PHY, aborting.",
+				  dev->name);
+		return err;
+	}
+
 	err = ucc_struct_init(ugeth);
 	if (err) {
 		if (netif_msg_ifup(ugeth))
@@ -3381,13 +3392,6 @@ static int ucc_geth_open(struct net_device *dev)
 				   &ugeth->ug_regs->macstnaddr1,
 				   &ugeth->ug_regs->macstnaddr2);
 
-	err = init_phy(dev);
-	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot initialize PHY, aborting.", dev->name);
-		goto out_err;
-	}
-
 	phy_start(ugeth->phydev);
 
 	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
@@ -3430,9 +3434,6 @@ static int ucc_geth_close(struct net_device *dev)
 
 	free_irq(ugeth->ug_info->uf_info.irq, ugeth->dev);
 
-	phy_disconnect(ugeth->phydev);
-	ugeth->phydev = NULL;
-
 	netif_stop_queue(dev);
 
 	return 0;
-- 
1.5.6.5
