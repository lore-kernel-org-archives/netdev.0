From: David Miller <davem@davemloft.net>
Subject: 5717 support commit is buggy
Date: Fri, 11 Sep 2009 15:15:54 -0700 (PDT)
Message-ID: <20090911.151554.181296228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755425AbZIKWPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 18:15:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The change:

commit f6eb9b1fc1411d22c073f5264e5630a541d0f7df
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Tue Sep 1 13:19:53 2009 +0000

    tg3: Add 5717 asic rev
    
    This patch adds the 5717 asic rev.
    
    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Benjamin Li <benli@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

breaks 5703 chips on my workstation.

I suspect it breaks a lot of other chips too.

I'm about to do some tests, but I suspect it's this change:

@@ -111,7 +111,8 @@
  * replace things like '% foo' with '& (foo - 1)'.
  */
 #define TG3_RX_RCB_RING_SIZE(tp)	\
-	((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ?  512 : 1024)
+	(((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) && \
+	  !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) ? 512 : 1024)
 
 #define TG3_TX_RING_SIZE		512
 #define TG3_DEF_TX_RING_PENDING		(TG3_TX_RING_SIZE - 1)

and thus an incorrect RCB ring size is being used which eventually
locks up the card.

Also:

@@ -13486,7 +13556,8 @@ static void __devinit tg3_init_link_config(struct tg3 *tp)
 
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
 			DEFAULT_MB_RDMA_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_mac_rx_low_water =

I wonder what that does with C precedence rules.  Probably need
parenhesis around "tp->tg3_flags2 & TG3_FLG2_5705_PLUS" for
safety.
