From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] make tg3 NAPI support configurable
Date: Tue, 13 Jan 2004 20:09:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16388.16999.36698.328251@robur.slu.se>
References: <3FE2F3A7.2A109F28@melbourne.sgi.com>
	<16354.64258.364153.488309@robur.slu.se>
	<4000ABBA.50601@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Greg Banks <gnb@melbourne.sgi.com>,
        "David S. Miller" <davem@redhat.com>,
        Linux Network Development list <netdev@oss.sgi.com>,
        jchapman@katalix.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4000ABBA.50601@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff Garzik writes:

 > >  Furthermore NAPI can be extended to schedule dev->poll even for TX-
 > >  interrupts. There is pacth for e1000 doing this. We see about 5-8% 
 > >  overall system packet improvement with this.
 > 
 > tg3 already schedules for TX, so we've got that part covered :)

Hello!
 
I was thinking of a variant JC [jchapman@katalix.com] mentioned on this list 
some time ago. He also sent me the patch for e1000. A test and the patch is 
below.


Routing test.
============

2 * 10 Million pkts @ 2*783 kpps into eth0, eth2 routed to eth1, eth3.
(TX-OK is the number to look for)

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3494625 8258316 8258316 6505378     24      0      0      0 BRU
eth1   1500   0     45      0      0      0 3494627      0      0      0 BRU
eth2   1500   0 3493930 8270692 8270692 6506073     21      0      0      0 BRU
eth3   1500   0      1      0      0      0 3493929      0      0      0 BRU

           CPU0       
 26:         74   IO-APIC-level  eth0
 27:      48617   IO-APIC-level  eth1
 28:         71   IO-APIC-level  eth2
 29:      48659   IO-APIC-level  eth3

-------------------------------------------------------------------------------
With patch.

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3752858 8151787 8151787 6247146     23      0      0      0 BRU
eth1   1500   0     47      0      0      0 3751676      0      0      0 BRU
eth2   1500   0 3751226 8191511 8191511 6248777     21      0      0      0 BRU
eth3   1500   0      1      0      0      0 3750490      0      0      0 BRU

           CPU0       
 26:        125   IO-APIC-level  eth0
 27:        127   IO-APIC-level  eth1
 28:        122   IO-APIC-level  eth2
 29:        137   IO-APIC-level  eth3

TX interrupts alone now schedules consecutive polls. We route 7.5 Million 
pkts w/o any interrupts. Total throughput from 0.349% to 0.375% (~580 kpps)
Of course having having RX-only and TX-only is special case...  

TCP-stream test.
================
Netperf w. single TCP-stream recv showed 938 Mbit/s both with and without 
patch and interrupts rates were the same. XEON @ 2.66 GHz w. e1000 4-port 
board. Linux 2.6.0-test11/UP


--- e1000_main.c.orig	2003-08-26 22:59:00.000000000 +0100
+++ e1000_main.c	2003-08-26 23:03:35.000000000 +0100
@@ -2061,19 +2061,21 @@
 	struct e1000_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
 	int work_done = 0;
-	
-	e1000_clean_tx_irq(adapter);
+	boolean_t tx_cleaned;
+
+	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
-	*budget -= work_done;
-	netdev->quota -= work_done;
-	
-	if(work_done < work_to_do) {
+	if(!tx_cleaned && (work_done == 0)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
+		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	*budget -= work_done;
+	netdev->quota -= work_done;
+	
+	return 1;
 }
 #endif


Cheers.
						--ro
