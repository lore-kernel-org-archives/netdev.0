From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETDRV] Fixed MCA resource bugs in at1700
Date: Sat, 5 Jun 2004 18:38:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605083834.GA29142@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jeff:

This patch fixes an incorrect MCA check as well as a leak on probe
failure in at1700.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/at1700.c 1.22 vs edited =====
--- 1.22/drivers/net/at1700.c	2004-05-22 17:28:45 +10:00
+++ edited/drivers/net/at1700.c	2004-06-05 18:34:29 +10:00
@@ -244,7 +244,7 @@
 {
 #ifdef CONFIG_MCA	
 	struct net_local *lp = netdev_priv(dev);
-	if (lp->mca_slot)
+	if (lp->mca_slot >= 0)
 		mca_mark_as_unused(lp->mca_slot);
 #endif	
 	free_irq(dev->irq, NULL);
@@ -446,11 +446,11 @@
 					break;
 			}
 			if (i == 8) {
-				goto err_out;
+				goto err_mca;
 			}
 		} else {
 			if (fmv18x_probe_list[inb(ioaddr + IOCONFIG) & 0x07] != ioaddr)
-				goto err_out;
+				goto err_mca;
 			irq = fmv_irqmap[(inb(ioaddr + IOCONFIG)>>6) & 0x03];
 		}
 	}
@@ -548,11 +548,16 @@
 	if (ret) {
 		printk ("  AT1700 at %#3x is unusable due to a conflict on"
 				"IRQ %d.\n", ioaddr, irq);
-		goto err_out;
+		goto err_mca;
 	}
 
 	return 0;
 
+err_mca:
+#ifdef CONFIG_MCA
+	if (slot >= 0)
+		mca_mark_as_unused(slot);
+#endif
 err_out:
 #ifndef CONFIG_X86_PC9800
 	release_region(ioaddr, AT1700_IO_EXTENT);

--a8Wt8u1KmwUX3Y2C--
