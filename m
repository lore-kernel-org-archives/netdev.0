From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Resend: [NETDRV] Fix successive calls to spin_lock_irqsave in sk98lin
Date: Sat, 3 Jul 2004 12:08:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703020852.GA29105@gondor.apana.org.au>
References: <20040701110418.GA10797@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040701110418.GA10797@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jeff:

On Thu, Jul 01, 2004 at 09:04:18PM +1000, herbert wrote:
> 
> This patch fixes the few places in sk98lin where it calls
> spin_lock_saveirq on the same flags variable thus causing
> interrupts to be disabled upon leaving the driver.

That patch doesn't apply with patch -p1.  I've fixed it now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/sk98lin/skge.c 1.38 vs edited =====
--- 1.38/drivers/net/sk98lin/skge.c	2004-03-30 03:57:20 +10:00
+++ edited/drivers/net/sk98lin/skge.c	2004-07-03 12:07:10 +10:00
@@ -3093,8 +3093,7 @@
 	SkEventDispatcher(pAC, pAC->IoBase);
 
 	for (i=0; i<pAC->GIni.GIMacsFound; i++) {
-		spin_lock_irqsave(
-			&pAC->TxPort[i][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_lock(&pAC->TxPort[i][TX_PRIO_LOW].TxDesRingLock);
 		netif_stop_queue(pAC->dev[i]);
 
 	}
@@ -4773,12 +4772,10 @@
 		spin_lock_irqsave(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);
-		spin_lock_irqsave(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_lock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		SkGeStopPort(pAC, IoC, FromPort, SK_STOP_ALL, SK_SOFT_RST);
 		SkGeStopPort(pAC, IoC, ToPort, SK_STOP_ALL, SK_SOFT_RST);
-		spin_unlock_irqrestore(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_unlock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		spin_unlock_irqrestore(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);
@@ -4791,8 +4788,7 @@
 		spin_lock_irqsave(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);
-		spin_lock_irqsave(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_lock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		pAC->ActivePort = ToPort;
 #if 0
 		SetQueueSizes(pAC);
@@ -4807,8 +4803,7 @@
 			pAC,
 			pAC->ActivePort,
 			DualNet)) {
-			spin_unlock_irqrestore(
-				&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+			spin_unlock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 			spin_unlock_irqrestore(
 				&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 				Flags);
@@ -4834,8 +4829,7 @@
 		SkGePollTxD(pAC, IoC, ToPort, SK_TRUE);
 		ClearAndStartRx(pAC, FromPort);
 		ClearAndStartRx(pAC, ToPort);
-		spin_unlock_irqrestore(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_unlock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		spin_unlock_irqrestore(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);

--8t9RHnE3ZwKMSgU+--
