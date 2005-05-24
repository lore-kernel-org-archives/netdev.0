From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/6] bnx2: Fix excessive stack usage
Date: Mon, 23 May 2005 21:29:16 -0700
Message-ID: <1116908956.5984.4.camel@rh4>
References: <1116892439.4908.1.camel@rh4> <1116894307.4908.28.camel@rh4>
 <429286A3.1060606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <429286A3.1060606@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-05-23 at 21:42 -0400, Jeff Garzik wrote:
> 
> memleak -- you need to free good_mbuf.
> 

Oops, here is the revised patch with kfree(). Thanks.

Fix excessive stack usage in bnx2_alloc_bad_rbuf() by replacing local
variable array with kmalloc array. Also changed function to return error
code, and changed some of the callers to check for the return code.

Spotted by Jeff Garzik.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff -Nru 10/drivers/net/bnx2.c 11/drivers/net/bnx2.c
--- 10/drivers/net/bnx2.c	2005-05-23 10:20:02.000000000 -0700
+++ 11/drivers/net/bnx2.c	2005-05-23 21:13:46.000000000 -0700
@@ -1138,13 +1138,20 @@
 	}
 }
 
-static void
+static int
 bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 {
-	u16 good_mbuf[512];
+	u16 *good_mbuf;
 	u32 good_mbuf_cnt;
 	u32 val;
 
+	good_mbuf = kmalloc(512 * sizeof(u16), GFP_KERNEL);
+	if (good_mbuf == NULL) {
+		printk(KERN_ERR PFX "Failed to allocate memory in "
+				    "bnx2_alloc_bad_rbuf\n");
+		return -ENOMEM;
+	}
+
 	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
 		BNX2_MISC_ENABLE_SET_BITS_RX_MBUF_ENABLE);
 
@@ -1178,6 +1185,8 @@
 
 		REG_WR_IND(bp, BNX2_RBUF_FW_BUF_FREE, val);
 	}
+	kfree(good_mbuf);
+	return 0;
 }
 
 static void
@@ -2710,7 +2719,7 @@
 bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 {
 	u32 val;
-	int i;
+	int i, rc = 0;
 
 	/* Wait for the current PCI transaction to complete before
 	 * issuing a reset. */
@@ -2785,10 +2794,10 @@
 		REG_WR(bp, BNX2_MISC_VREG_CONTROL, 0x000000fa);
 
 		/* Remove bad rbuf memory from the free pool. */
-		bnx2_alloc_bad_rbuf(bp);
+		rc = bnx2_alloc_bad_rbuf(bp);
 	}
 
-	return 0;
+	return rc;
 }
 
 static int
@@ -3097,8 +3106,13 @@
 static int
 bnx2_reset_nic(struct bnx2 *bp, u32 reset_code)
 {
-	bnx2_reset_chip(bp, reset_code);
+	int rc;
+
+	rc = bnx2_reset_chip(bp, reset_code);
 	bnx2_free_skbs(bp);
+	if (rc)
+		return rc;
+
 	bnx2_init_chip(bp);
 	bnx2_init_tx_ring(bp);
 	bnx2_init_rx_ring(bp);
@@ -3108,7 +3122,11 @@
 static int
 bnx2_init_nic(struct bnx2 *bp)
 {
-	bnx2_reset_nic(bp, BNX2_DRV_MSG_CODE_RESET);
+	int rc;
+
+	if ((rc = bnx2_reset_nic(bp, BNX2_DRV_MSG_CODE_RESET)) != 0)
+		return rc;
+
 	bnx2_init_phy(bp);
 	bnx2_set_link(bp);
 	return 0;
