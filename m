From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] e1000 poll behavior
Date: Fri, 10 Dec 2004 18:28:48 +0100
Message-ID: <16825.56528.212904.417227@robur.slu.se>
References: <16824.30773.125766.220826@robur.slu.se>
	<1102695576.12078.22.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1102695576.12078.22.camel@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Martin Josefsson writes:

 > What about the case where tx_cleaned is true but (work_done <
 > work_to_do) is true. Then the statement is false and we continue, later
 > we return (work_done >= work_to_do) which equals 0 (not seen in patch).
 > We are not allowed to return 0 when still on poll_list. That will sort
 > of continue polling in a degraded way (no increase in quota) but will
 > screw up device refcounting badly.
 > 
 > That final return must be changed into "return 1;"

 Ohoh thanks yes...

--- drivers/net/e1000/e1000_main.c.orig	2004-12-09 17:49:56.000000000 +0100
+++ drivers/net/e1000/e1000_main.c	2004-12-10 20:13:57.000000000 +0100
@@ -2179,15 +2179,15 @@
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	/* if no Rx and Tx cleanup work was done, exit the polling mode */
-	if(!tx_cleaned || (work_done < work_to_do) || 
+	/* if no Tx and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done < work_to_do)) || 
 				!netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	return 1;
 }
 
 #endif

Same experiment again.

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 4351378 8252365 8252365 5648874    155      0      0      0 BRU
eth1   1500   0      1      0      0      0 4350771      0      0      0 BRU
eth2   1500   0 4352289 8383841 8383841 5647711      5      0      0      0 BRU
eth3   1500   0      1      0      0      0 4352126      0      0      0 BRU

           CPU0       
 26:        434   IO-APIC-level  eth0
 27:        109   IO-APIC-level  eth1
 28:        112   IO-APIC-level  eth2
 29:        112   IO-APIC-level  eth3

						--ro
