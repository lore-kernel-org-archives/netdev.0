From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 21:38:35 +0200
Message-ID: <20100820193835.GA6025@del.dom.local>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46392 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609Ab0HTTim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 15:38:42 -0400
Received: by bwz11 with SMTP id 11so2341770bwz.19
        for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 12:38:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4C6E5EA7.3040609@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Plamen Petrov wrote, On 20.08.2010 12:53:
> So, I guess its David and Herbert's turn?...

If you're bored in the meantime I'd suggest to do check the realtek
driver eg:
- for locking with the patch below,
- to turn off with ethtool its tx-checksumming and/or scatter-gather,
or if possible try to reproduce this with other NIC.

Thanks,
Jarek P.
---

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index f5166dc..aaaccc5 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1692,6 +1692,8 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 	unsigned int len = skb->len;
 	unsigned long flags;
 
+	spin_lock_irqsave(&tp->lock, flags);
+
 	/* Calculate the next Tx descriptor entry. */
 	entry = tp->cur_tx % NUM_TX_DESC;
 
@@ -1700,14 +1702,14 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 		if (len < ETH_ZLEN)
 			memset(tp->tx_buf[entry], 0, ETH_ZLEN);
 		skb_copy_and_csum_dev(skb, tp->tx_buf[entry]);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_irq(skb);
 	} else {
+		spin_unlock_irqrestore(&tp->lock, flags);
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
 
-	spin_lock_irqsave(&tp->lock, flags);
 	/*
 	 * Writing to TxStatus triggers a DMA transfer of the data
 	 * copied to tp->tx_buf[entry] above. Use a memory barrier
