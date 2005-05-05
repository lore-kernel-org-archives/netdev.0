From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Mystery packet killing tg3
Date: Thu, 05 May 2005 12:56:34 -0700
Message-ID: <1115322994.15156.98.camel@rh4>
References: <B1508D50A0692F42B217C22C02D84972020F3EB2@NT-IRVA-0741.brcm.ad.broadcom.com>
 <20050504155143.1a78cb7a@dxpl.pdx.osdl.net>
 <1115245822.15156.78.camel@rh4>
 <20050505113356.0f1b4c00.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505113356.0f1b4c00.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-05-05 at 11:33 -0700, David S. Miller wrote:

> I'm very tempted to add a silencer to these messages in these
> cases.  Something like the patch below.  Michael, what do you
> think?
> 
> [TG3]: Elide tg3_stop_block messages when such events are normal.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 

Looks good. I'm adding this patch to further ignore the tg3_stop_block
errors.

[TG3]: Ignore tg3_stop_block() errors.

tg3_stop_block() errors can be safely ignored since tg3_chip_reset()
always follows tg3_stop_block() calls.


Signed-off-by: Michael Chan <mchan@broadcom.com>

diff -Nru f/drivers/net/tg3.c g/drivers/net/tg3.c
--- f/drivers/net/tg3.c	2005-05-05 12:29:41.000000000 -0700
+++ g/drivers/net/tg3.c	2005-05-05 12:37:14.000000000 -0700
@@ -3725,8 +3725,6 @@
 	err |= tg3_stop_block(tp, SNDDATAC_MODE, SNDDATAC_MODE_ENABLE,
silent);
 	err |= tg3_stop_block(tp, DMAC_MODE, DMAC_MODE_ENABLE, silent);
 	err |= tg3_stop_block(tp, SNDBDC_MODE, SNDBDC_MODE_ENABLE, silent);
-	if (err)
-		goto out;
 
 	tp->mac_mode &= ~MAC_MODE_TDE_ENABLE;
 	tw32_f(MAC_MODE, tp->mac_mode);
@@ -3744,10 +3742,10 @@
 		printk(KERN_ERR PFX "tg3_abort_hw timed out for %s, "
 		       "TX_MODE_ENABLE will not clear MAC_TX_MODE=%08x\n",
 		       tp->dev->name, tr32(MAC_TX_MODE));
-		return -ENODEV;
+		err |= -ENODEV;
 	}
 
-	err  = tg3_stop_block(tp, HOSTCC_MODE, HOSTCC_MODE_ENABLE, silent);
+	err |= tg3_stop_block(tp, HOSTCC_MODE, HOSTCC_MODE_ENABLE, silent);
 	err |= tg3_stop_block(tp, WDMAC_MODE, WDMAC_MODE_ENABLE, silent);
 	err |= tg3_stop_block(tp, MBFREE_MODE, MBFREE_MODE_ENABLE, silent);
 
@@ -3756,15 +3754,12 @@
 
 	err |= tg3_stop_block(tp, BUFMGR_MODE, BUFMGR_MODE_ENABLE, silent);
 	err |= tg3_stop_block(tp, MEMARB_MODE, MEMARB_MODE_ENABLE, silent);
-	if (err)
-		goto out;
 
 	if (tp->hw_status)
 		memset(tp->hw_status, 0, TG3_HW_STATUS_SIZE);
 	if (tp->hw_stats)
 		memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
 
-out:
 	return err;
 }
 
@@ -5063,9 +5058,7 @@
 	tg3_write_sig_pre_reset(tp, RESET_KIND_INIT);
 
 	if (tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) {
-		err = tg3_abort_hw(tp, 1);
-		if (err)
-			return err;
+		tg3_abort_hw(tp, 1);
 	}
 
 	err = tg3_chip_reset(tp);
