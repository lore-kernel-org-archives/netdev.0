From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] e1000 poll behavior
Date: Thu, 9 Dec 2004 17:07:17 +0100
Message-ID: <16824.30773.125766.220826@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

Seems e1000 never gets into poll mode when tx_cleaned is false. Compare
irq's on RX interfaces eth0, eth2 in the forwarding test below.

Vanilla:
-------
Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3983334 8374749 8374749 6016848    111      0      0      0 BRU
eth1   1500   0      1      0      0      0 3982841      0      0      0 BRU
eth2   1500   0 4002156 8507930 8507930 5997844      5      0      0      0 BRU
eth3   1500   0      1      0      0      0 4001653      0      0      0 BRU

           CPU0       
 26:      66366   IO-APIC-level  eth0
 27:      75200   IO-APIC-level  eth1
 28:      66705   IO-APIC-level  eth2
 29:      75132   IO-APIC-level  eth3

--- drivers/net/e1000/e1000_main.c.orig	2004-12-09 17:49:56.000000000 +0100
+++ drivers/net/e1000/e1000_main.c	2004-12-09 19:05:07.000000000 +0100
@@ -2179,8 +2179,8 @@
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	/* if no Rx and Tx cleanup work was done, exit the polling mode */
-	if(!tx_cleaned || (work_done < work_to_do) || 
+	/* if no Tx and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done < work_to_do)) || 
 				!netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);

Patched: 
-------
Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 4193457 8283968 8283968 5806693     99      0      0      0 BRU
eth1   1500   0      1      0      0      0 4192308      0      0      0 BRU
eth2   1500   0 4190698 8441200 8441200 5809302      5      0      0      0 BRU
eth3   1500   0      1      0      0      0 4190171      0      0      0 BRU

           CPU0       
 26:        336   IO-APIC-level  eth0
 27:      58159   IO-APIC-level  eth1
 28:         64   IO-APIC-level  eth2
 29:      58228   IO-APIC-level  eth3

						--ro
