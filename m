From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 2.6] Prevent tulip cardbus cards from freezing machine
Date: Thu, 27 May 2004 11:59:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527095904.GG12225@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

here's a patch that should prevent lockups with tulip cardbus cards
after APM suspend/resume, or when pulling out the card.

The problem is that the status register seems to return 0xffffffff in
this case, and tulip_poll thinks RxIntr is asserted all the time.

Please review.

Cheers
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=tulip-pcmcia-remove

--- linux-2.6.5/drivers/net/tulip/interrupt.c.suspend	2004-04-04 05:36:48.000000000 +0200
+++ linux-2.6.5/drivers/net/tulip/interrupt.c	2004-05-25 12:24:07.000000000 +0200
@@ -113,6 +113,7 @@
 	int entry = tp->cur_rx % RX_RING_SIZE;
 	int rx_work_limit = *budget;
 	int received = 0;
+	int csr5;
 
 	if (!netif_running(dev))
 		goto done;
@@ -254,7 +255,12 @@
                 * No idea how to fix this if "playing with fire" will fail
                 * tomorrow (night 011029). If it will not fail, we won
                 * finally: amount of IO did not increase at all. */
-       } while ((inl(dev->base_addr + CSR5) & RxIntr));
+	       csr5 = inl(dev->base_addr + CSR5);
+	       if (csr5 == 0xffffffff) {
+		       printk(KERN_DEBUG "tulip_poll: hardware disappeared.\n");
+		       break;
+	       }
+       } while (csr5 & RxIntr);
  
 done:
  

--C7zPtVaVf+AK4Oqc--
