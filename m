From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 21:40:56 +0100
Message-ID: <16862.62424.180929.680029@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<16862.57504.383176.640058@robur.slu.se>
	<200501071338.16621.jeremy.guthrie@berbee.com>
	<200501071414.05126.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501071414.05126.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > During a 60 second window the machine received 5,110,164 packets and 
 > dropped 20461 or roughly 0.4% packet loss.

 Around 85 kpps. If you run rtstat we could a feeling how may slow-pathx
 that are taken. Or save the /proc/net/stat/rt_cache before you 60 sec
 run.

 mpstat I don't trust in this context.

 > It has been at 150dc67c for a while now.  So while I am dropping at the 
 > card, I am not dropping in the stack.

 You use NAPI driver then... 
 Check if the patch below is in your e1000 driver. 

				       --ro


 --- drivers/net/e1000/e1000_main.c.orig	2004-02-16 14:46:16.000000000 +0100
+++ drivers/net/e1000/e1000_main.c	2004-02-16 15:45:05.000000000 +0100
@@ -2161,19 +2161,21 @@
 	struct e1000_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
 	int work_done = 0;
-	
-	e1000_clean_tx_irq(adapter);
+	static boolean_t tx_cleaned;	
+
+	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	if(work_done < work_to_do || !netif_running(netdev)) {
+	if( (!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
+		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	return 1;
 }
 #endif
 
