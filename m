From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] Naming interrupt vectors/niu
Date: Tue, 25 Nov 2008 16:45:12 +0100
Message-ID: <18732.7560.67492.918339@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:54766 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbYKYPpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 10:45:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



 Hi,

 A patch to put names on the niu interrupt vectors according the syntax below. 
 This is needed to assign correct affinity.

 > So on a multiqueue card with 2 RX queues and 2 TX queues we'd
 > have names like:
 > 
 > 	eth0-rx-0
 > 	eth0-rx-1
 > 	eth0-tx-0
 > 	eth0-tx-1


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1b6f548..9798312 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -5849,17 +5849,43 @@ static void niu_stop_hw(struct niu *np)
 	niu_reset_rx_channels(np);
 }
 
+static void niu_set_irq_name(struct niu *np)
+{
+	int i, j = 1;
+	int port = np->port;
+	
+	sprintf(np->irq_name[0], "%s:MAC", np->dev->name); 
+	 
+	if(port == 0) {
+		sprintf(np->irq_name[1], "%s:MIF", np->dev->name); 
+		sprintf(np->irq_name[2], "%s:SYSERR", np->dev->name); 
+		j = 3;
+	}
+
+	for (i = 0; i < np->num_ldg-j; i++) {
+
+		if(i < np->num_rx_rings)
+			sprintf(np->irq_name[i+j], "%s-rx-%d", np->dev->name, i);
+
+		else if(i < np->num_tx_rings + np->num_rx_rings) 
+			sprintf(np->irq_name[i+j], "%s-tx-%d", np->dev->name, 
+				i - np->num_rx_rings);
+	}
+}
+
 static int niu_request_irq(struct niu *np)
 {
 	int i, j, err;
 
+	niu_set_irq_name(np);
+
 	err = 0;
 	for (i = 0; i < np->num_ldg; i++) {
 		struct niu_ldg *lp = &np->ldg[i];
 
 		err = request_irq(lp->irq, niu_interrupt,
 				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-				  np->dev->name, lp);
+				  np->irq_name[i], lp);
 		if (err)
 			goto out_free_irqs;
 
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 180ca8a..cf449aa 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -3243,6 +3243,7 @@ struct niu {
 #define NIU_FLAGS_XMAC			0x00010000 /* 0=BMAC 1=XMAC */
 
 	u32				msg_enable;
+	char                            irq_name[NIU_NUM_RXCHAN+NIU_NUM_TXCHAN+3][IFNAMSIZ + 6];
 
 	/* Protects hw programming, and ring state.  */
 	spinlock_t			lock;

 
