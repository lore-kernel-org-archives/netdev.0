From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fix cosa to get rid of warnings and build on SMP
Date: Thu, 4 Sep 2003 14:28:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904142828.14218966.shemminger@osdl.org>
References: <20030903173417.GC18025@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030903173417.GC18025@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* get rid of leftover sti
* no longer need MOD_INC/DEC stuff
* get rid of dead code related to MOD_INC/DEC
* use module_init/module_exit to cleanly run init code

diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	Thu Sep  4 14:18:36 2003
+++ b/drivers/net/wan/cosa.c	Thu Sep  4 14:18:36 2003
@@ -357,11 +357,7 @@
 
 /* ---------- Initialization stuff ---------- */
 
-#ifdef MODULE
-int init_module(void)
-#else
 static int __init cosa_init(void)
-#endif
 {
 	int i;
 
@@ -398,9 +394,9 @@
 	}
 	return 0;
 }
+module_init(cosa_init);
 
-#ifdef MODULE
-void cleanup_module (void)
+static void __exit cosa_exit(void)
 {
 	struct cosa_data *cosa;
 	int i;
@@ -424,7 +420,7 @@
 	}
 	unregister_chrdev(cosa_major, "cosa");
 }
-#endif
+module_exit(cosa_exit);
 
 /*
  * This function should register all the net devices needed for the
@@ -513,7 +509,6 @@
 	if (irq < 0) {
 		unsigned long irqs;
 /*		printk(KERN_INFO "IRQ autoprobe\n"); */
-		sti();
 		irqs = probe_irq_on();
 		/* 
 		 * Enable interrupt on tx buffer empty (it sure is) 
@@ -624,6 +619,7 @@
 	if (register_netdev(d) == -1) {
 		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
 		sppp_detach(chan->pppdev.dev);
+		free_netdev(chan->pppdev.dev);
 		return;
 	}
 }
@@ -658,7 +654,6 @@
 	chan->rx_done = sppp_rx_done;
 	chan->usage=-1;
 	chan->cosa->usage++;
-	MOD_INC_USE_COUNT;
 	spin_unlock_irqrestore(&chan->cosa->lock, flags);
 
 	err = sppp_open(d);
@@ -666,7 +661,6 @@
 		spin_lock_irqsave(&chan->cosa->lock, flags);
 		chan->usage=0;
 		chan->cosa->usage--;
-		MOD_DEC_USE_COUNT;
 		
 		spin_unlock_irqrestore(&chan->cosa->lock, flags);
 		return err;
@@ -726,7 +720,6 @@
 	}
 	chan->usage=0;
 	chan->cosa->usage--;
-	MOD_DEC_USE_COUNT;
 	spin_unlock_irqrestore(&chan->cosa->lock, flags);
 	return 0;
 }
@@ -1187,21 +1180,6 @@
 		return cosa_gettype(cosa, (char *)arg);
 	case COSAIORIDSTR:
 		return cosa_getidstr(cosa, (char *)arg);
-/*
- * These two are _very_ugly_hack_(tm). Don't even look at this.
- * Implementing this saved me few reboots after some process segfaulted
- * inside this module.
- */
-#ifdef MODULE
-#if 0
-	case COSAIOMINC:
-		MOD_INC_USE_COUNT;
-		return 0;
-	case COSAIOMDEC:
-		MOD_DEC_USE_COUNT;
-		return 0;
-#endif
-#endif
 	case COSAIONRCARDS:
 		return nr_cards;
 	case COSAIONRCHANS:
