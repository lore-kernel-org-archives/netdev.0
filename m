From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Thu, 27 Mar 2003 17:54:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16003.11449.497905.815776@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Jeff Garzik
	 <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Feldman, Scott writes:

 > Easy enough to revert back.  I don't think we've lost any of the
 > non-perf benefits of NAPI, and if testing shows no meaningful perf
 > difference, let's let Occam's razor rule.

Hello!

Here is a hi-perf routing/DoS to start with...

10 Million pkts injected at high speed into eth2 and forwarded to eth3. Rx and 
Tx buffers are 256 and HW_FLOW is disabled and RxIntDelay=1. Which is same 
parameters as we use for production systems. As seen link now flaps. 
Eventually can hw_flowcontrol and interrupt delays help this... but thats not 
an option at least not for us. 


Twist:        New                        Old
             ====================================
Input rate:    680 (due to link drop)    820 kpps
T-put:         309                       385 kpps 
RX irq's:    78963                       434


Cheers.
						--ro


e1000 2.5.66 NAPI (680 kpps in)
-------------------------------
NETDEV WATCHDOG: eth2: transmit timed out
e1000: eth2 NIC Link is Up 1000 Mbps Full Duplex

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth2   1500   0 4175392 7277442 7277442 4696985     18      0      0      0 BRU
eth3   1500   0      1      0      0      0 4555009      0      0      0 BRU

 26:      78963   IO-APIC-level  eth2
 27:      92979   IO-APIC-level  eth3


e1000 2.5.66 NAPI with patch (820 kpps in)
------------------------------------------
Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth2   1500   0 4708196 8173469 8173469 5291805     18      0      0      0 BRU
eth3   1500   0      1      0      0      0 4708135      0      0      0 BRU

 26:        434   IO-APIC-level  eth2
 27:      74584   IO-APIC-level  eth3


--- e1000_main.c.orig   2003-03-27 14:38:02.000000000 +0100
+++ e1000_main.c        2003-03-27 16:43:38.000000000 +0100
@@ -2000,9 +2000,12 @@
        }
 
 #ifdef CONFIG_E1000_NAPI
-       /* Don't disable interrupts - rely on h/w interrupt
-        * moderation to keep interrupts low.  netif_rx_schedule
-        * is NOP if already polling. */
+       /* Disable interrupts and register for poll. The flush 
+          of the posted write is intentionally left out.
+       */
+
+       atomic_inc(&adapter->irq_sem);
+       E1000_WRITE_REG(&adapter->hw, IMC, ~0);
        netif_rx_schedule(netdev);
 #else
        for(i = 0; i < E1000_MAX_INTR; i++)
@@ -2024,18 +2027,17 @@
        struct e1000_adapter *adapter = netdev->priv;
        int work_to_do = min(*budget, netdev->quota);
        int work_done = 0;
-
-       while(work_done < work_to_do)
-               if(!e1000_clean_rx_irq(adapter, &work_done, work_to_do) &&
-                  !e1000_clean_tx_irq(adapter))
-                       break;
+
+       e1000_clean_tx_irq(adapter);
+       e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
        *budget -= work_done;
        netdev->quota -= work_done;
 
-       if(work_done < work_to_do)
+       if(work_done < work_to_do) {
                netif_rx_complete(netdev);
-
+               e1000_irq_enable(adapter);
+       }
        return (work_done >= work_to_do);
 }
 #endif
