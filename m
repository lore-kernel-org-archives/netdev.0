From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Thu, 22 Jan 2004 00:59:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122005940.A26438@electric-eye.fr.zoreil.com>
References: <200401152039.00182.harisri@bigpond.com> <200401202150.12892.harisri@bigpond.com> <20040120215230.A8935@electric-eye.fr.zoreil.com> <200401212115.45027.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@bigpond.com>
Content-Disposition: inline
In-Reply-To: <200401212115.45027.harisri@bigpond.com>; from harisri@bigpond.com on Wed, Jan 21, 2004 at 09:15:44PM +1100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Srihari Vijayaraghavan <harisri@bigpond.com> :
[...]
> I have a good news: I checked out things as usual under vanilla 
> linux-2.6.2-rc1, and to my surprise Kernel does not hang anymore :-). 
> (although Tx counter not incrementing is altogether another problem).

r8169 did not evolve between 2.6.1 and 2.6.2-rc1. Change of behavior
probably comes from some other part of the kernel. Joy.

> If you want me to I can test your r8169-tc-index-overflow.patch.

See attachment. It applies against plain 2.6.2-rc1.

--
Ueimor

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169.c-diff"

--- linux-2.6.2-rc1/drivers/net/r8169.c.orig	2004-01-22 00:41:03.000000000 +0100
+++ linux-2.6.2-rc1/drivers/net/r8169.c	2004-01-22 00:46:46.000000000 +0100
@@ -871,7 +871,6 @@ rtl8169_tx_interrupt(struct net_device *
 		     void *ioaddr)
 {
 	unsigned long dirty_tx, tx_left = 0;
-	int entry = tp->cur_tx % NUM_TX_DESC;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -881,14 +880,14 @@ rtl8169_tx_interrupt(struct net_device *
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
+		int entry = dirty_tx % NUM_TX_DESC;
+
 		if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
-			dev_kfree_skb_irq(tp->
-					  Tx_skbuff[dirty_tx % NUM_TX_DESC]);
-			tp->Tx_skbuff[dirty_tx % NUM_TX_DESC] = NULL;
+			dev_kfree_skb_irq(tp->Tx_skbuff[entry]);
+			tp->Tx_skbuff[entry] = NULL;
 			tp->stats.tx_packets++;
 			dirty_tx++;
 			tx_left--;
-			entry++;
 		}
 	}
 

--YZ5djTAD1cGYuMQK--
