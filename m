From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 3/3] r8169: clean up
Date: Tue, 2 Nov 2004 12:03:25 -0600
Message-ID: <200411021203.25100.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_tv8hBKxXyyw9TC0"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_tv8hBKxXyyw9TC0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Removal of some magic numbers, unnecessary double not, and addition of "link 
down" notification.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- r8169.c     2004-11-02 10:37:31.035203120 -0600
+++ r8169.c.latest      2004-11-02 10:44:01.367863536 -0600
@@ -519,8 +519,10 @@ static void rtl8169_check_link_status(st
        if (tp->link_ok(ioaddr)) {
                netif_carrier_on(dev);
                printk(KERN_INFO PFX "%s: link up\n", dev->name);
-       } else
+       } else {
                netif_carrier_off(dev);
+               printk(KERN_INFO PFX "%s: link down\n", dev->name);
+       }
        spin_unlock_irqrestore(&tp->lock, flags);
 }

@@ -773,7 +775,7 @@ static void rtl8169_gset_tbi(struct net_

        status = RTL_R32(TBICSR);
        cmd->advertising = (status & TBINwEnable) ?  ADVERTISED_Autoneg : 0;
-       cmd->autoneg = !!(status & TBINwEnable);
+       cmd->autoneg = status & TBINwEnable;

        cmd->speed = SPEED_1000;
        cmd->duplex = DUPLEX_FULL; /* Always set */
@@ -1639,7 +1641,7 @@ static int rtl8169_alloc_rx_skb(struct p
        if (!skb)
                goto err_out;

-       skb_reserve(skb, 2);
+       skb_reserve(skb, NET_IP_ALIGN);
        *sk_buff = skb;

        mapping = pci_map_single(pdev, skb->tail, rx_buf_sz,
@@ -2071,9 +2073,9 @@ static inline int rtl8169_try_rx_copy(st
        if (pkt_size < rx_copybreak) {
                struct sk_buff *skb;

-               skb = dev_alloc_skb(pkt_size + 2);
+               skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
                if (skb) {
-                       skb_reserve(skb, 2);
+                       skb_reserve(skb, NET_IP_ALIGN);
                        eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
                        *sk_buff = skb;
                        rtl8169_return_to_asic(desc, rx_buf_sz);


--Boundary-00=_tv8hBKxXyyw9TC0
Content-Type: text/x-diff;
  charset="us-ascii";
  name="r8169-cleanup-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="r8169-cleanup-3.patch"

--- r8169.c	2004-11-02 10:37:31.035203120 -0600
+++ r8169.c.latest	2004-11-02 10:44:01.367863536 -0600
@@ -519,8 +519,10 @@ static void rtl8169_check_link_status(st
 	if (tp->link_ok(ioaddr)) {
 		netif_carrier_on(dev);
 		printk(KERN_INFO PFX "%s: link up\n", dev->name);
-	} else
+	} else {
 		netif_carrier_off(dev);
+		printk(KERN_INFO PFX "%s: link down\n", dev->name);
+	}	
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
@@ -773,7 +775,7 @@ static void rtl8169_gset_tbi(struct net_
 
 	status = RTL_R32(TBICSR);
 	cmd->advertising = (status & TBINwEnable) ?  ADVERTISED_Autoneg : 0;
-	cmd->autoneg = !!(status & TBINwEnable);
+	cmd->autoneg = status & TBINwEnable;
 
 	cmd->speed = SPEED_1000;
 	cmd->duplex = DUPLEX_FULL; /* Always set */
@@ -1639,7 +1641,7 @@ static int rtl8169_alloc_rx_skb(struct p
 	if (!skb)
 		goto err_out;
 
-	skb_reserve(skb, 2);
+	skb_reserve(skb, NET_IP_ALIGN);
 	*sk_buff = skb;
 
 	mapping = pci_map_single(pdev, skb->tail, rx_buf_sz,
@@ -2071,9 +2073,9 @@ static inline int rtl8169_try_rx_copy(st
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_size + 2);
+		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
 		if (skb) {
-			skb_reserve(skb, 2);
+			skb_reserve(skb, NET_IP_ALIGN);
 			eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
 			*sk_buff = skb;
 			rtl8169_return_to_asic(desc, rx_buf_sz);

--Boundary-00=_tv8hBKxXyyw9TC0--
