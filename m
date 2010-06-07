From: Alexander Strakh <strakh@ispras.ru>
Subject: BUG: double spinlock in "drivers/net/3c505.c"
Date: Mon, 7 Jun 2010 15:17:28 +0400
Message-ID: <201006071517.28744.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Craig Southeren <craigs@ineluki.apana.org.au>,
	Andrew Tridgell <tridge@nimbus.anu.edu.au>,
	Alan Cox <Alan.Cox@linux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philip Blundell <philb@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ispras.ru ([83.149.198.201]:42196 "EHLO smtp.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756453Ab0FGLiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 07:38:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	KERNEL_VERSION: 2.6.35-rc1
        SUBJECT: duble spinlock  in function elp_start_xmit
        SUBSCRIBE:
        In driver drivers/net/3c505.c in function elp_start_xmit:

1. In line 1075 we have first spinlock. In the next line we called 
check_3c505_dma:

1070 static netdev_tx_t elp_start_xmit(struct sk_buff *skb, struct net_device 
*dev)
1071 {
1072         unsigned long flags;
1073         elp_device *adapter = netdev_priv(dev);
1074
1075         spin_lock_irqsave(&adapter->lock, flags);
1076         check_3c505_dma(dev);

2. In function check_3c505_dma we have second spinloock at line 301.

 293 static inline void check_3c505_dma(struct net_device *dev)
 294 {
 295         elp_device *adapter = netdev_priv(dev);
 296         if (adapter->dmaing && time_after(jiffies, adapter-
>current_dma.start_time + 10)) {
 297                 unsigned long flags, f;
 298                 pr_err("%s: DMA %s timed out, %d bytes left\n", dev-
>name,
 299                         adapter->current_dma.direction ? "download" : 
"upload",
 300                         get_dma_residue(dev->dma));
 301                 spin_lock_irqsave(&adapter->lock, flags);


Found by Linux Device Drivers Verification Project (Svace Detector)
