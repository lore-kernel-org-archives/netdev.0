From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] handle slip module unload race better.
Date: Thu, 12 Jun 2003 16:12:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612161243.01052de0.shemminger@osdl.org>
References: <20030612132714.6b8e1267.shemminger@osdl.org>
	<20030612.145803.112592736.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: viro@parcelfarce.linux.theplanet.co.uk, jgarzik@pobox.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030612.145803.112592736.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Jun 2003 14:58:03 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Stephen Hemminger <shemminger@osdl.org>
>    Date: Thu, 12 Jun 2003 13:27:14 -0700
> 
>    The following won't work.
>    
>  ...
>    				unregister_netdev(&slc->dev);
>    				if (slc->ctrl.tty) {
>    					printk(KERN_ERR "%s: tty discipline is still running\n", slc->dev.name);
>    					/* Pin module forever */
>    					MOD_INC_USE_COUNT;
>    
>    Because it is in the exit code for the module, and by that time
>    the module code has decided it is going to remove it and no
>    longer looks at the ref count.  Sorry, don't have a patch to
>    fix since this is related more to the problematic tty code, 
>    than the network code.
>    
> I think a reasonable thing for it to do is leak the netdevice
> and print a message when this happens.

Okay, this patch does that. I could start and unload slip, but could
not actually trigger the failure.

diff -Nru a/drivers/net/slip.c b/drivers/net/slip.c
--- a/drivers/net/slip.c	Thu Jun 12 16:10:30 2003
+++ b/drivers/net/slip.c	Thu Jun 12 16:10:30 2003
@@ -1381,27 +1381,23 @@
 			local_bh_enable();
 		} while (busy && time_before(jiffies, timeout));
 
-		busy = 0;
 		for (i = 0; i < slip_maxdev; i++) {
 			struct slip_ctrl *slc = slip_ctrls[i];
 			if (slc) {
 				unregister_netdev(&slc->dev);
 				if (slc->ctrl.tty) {
 					printk(KERN_ERR "%s: tty discipline is still running\n", slc->dev.name);
-					/* Pin module forever */
-					MOD_INC_USE_COUNT;
-					busy++;
-					continue;
+					/* Intentionally leak the control block. */
+				} else {
+					sl_free_bufs(&slc->ctrl);
+					kfree(slc);
 				}
-				sl_free_bufs(&slc->ctrl);
-				kfree(slc);
 				slip_ctrls[i] = NULL;
 			}
 		}
-		if (!busy) {
-			kfree(slip_ctrls);
-			slip_ctrls = NULL;
-		}
+
+		kfree(slip_ctrls);
+		slip_ctrls = NULL;
 	}
 	if ((i = tty_register_ldisc(N_SLIP, NULL)))
 	{
