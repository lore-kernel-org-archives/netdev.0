From: Kai Makisara <Kai.Makisara@kolumbus.fi>
Subject: e1000 lockup with Linux 2.6.3-rc4
Date: Tue, 17 Feb 2004 21:16:20 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402172104020.1073@kai.makisara.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This kernel locks up with one of my machines when bringing up the e1000 
interface. Reverting the patch at the end of this message solves the 
problem.

The motherboard is Intel D875PBZLK and lspci gives the following
information about the e1000:

02:01.0 Ethernet controller: Intel Corp.: Unknown device 1019
        Subsystem: Intel Corp.: Unknown device 3025
        Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 18
        Memory at fe9e0000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at 9c00 [size=32]
        Capabilities: <available only to root>


The Changelog for 2.6.3-rc1 contains the following entry:

<scott.feldman@intel.com>
        [e1000] 82547 interrupt assert/de-assert re-ordering
        
        * 82547 needs interrupt disable/enable to keep interrupt assertion
          state synced between 82547 and APIC.  82547 will re-order
          assert and de-assert messages if hub link bus is busy (heavy
          traffic).  Disabling interrupt on device works around re-
          order issue.

which is the patch at the end of this message. Later there is the 
following entry:

<scott.feldman@intel.com>
        [netdrvr e1000] back out CSA interrupt fix
        
        * 8086:1019 82547 CSA-based LOMs lock up the system with
          this code, so let's revert back to what's in 2.6.0 until
          we can figure out why this is causing problems.

Is this patch missing from 2.6.3-rc4 or have I misread the logs?

-- 
Kai

diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	Wed Feb  4 12:35:36 2004
+++ b/drivers/net/e1000/e1000_main.c	Wed Feb  4 12:35:36 2004
@@ -2124,10 +2124,26 @@
 		__netif_rx_schedule(netdev);
 	}
 #else
+        /* Writing IMC and IMS is needed for 82547.
+	   Due to Hub Link bus being occupied, an interrupt 
+	   de-assertion message is not able to be sent. 
+	   When an interrupt assertion message is generated later,
+	   two messages are re-ordered and sent out.
+	   That causes APIC to think 82547 is in de-assertion
+	   state, while 82547 is in assertion state, resulting 
+	   in dead lock. Writing IMC forces 82547 into 
+	   de-assertion state.
+        */
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+		e1000_irq_disable(adapter);
+
 	for(i = 0; i < E1000_MAX_INTR; i++)
 		if(!e1000_clean_rx_irq(adapter) &
 		   !e1000_clean_tx_irq(adapter))
 			break;
+
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+		e1000_irq_enable(adapter);
 #endif
 
 	return IRQ_HANDLED;
