From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: net: mvpp2: fix missing DMA region unmap in egress processing
Date: Tue, 8 Dec 2015 22:38:46 +0300
Message-ID: <20151208193846.GA25726@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: mw@semihalf.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31042 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbLHTjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 14:39:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Marcin Wojtas,

The patch e864b4c7b184: "net: mvpp2: fix missing DMA region unmap in
egress processing" from Dec 3, 2015, leads to the following static
checker warning:

	drivers/net/ethernet/marvell/mvpp2.c:4414 mvpp2_txq_bufs_free()
	warn: variable dereferenced before check 'skb' (see line 4412)

drivers/net/ethernet/marvell/mvpp2.c
  4399  static void mvpp2_txq_bufs_free(struct mvpp2_port *port,
  4400                                  struct mvpp2_tx_queue *txq,
  4401                                  struct mvpp2_txq_pcpu *txq_pcpu, int num)
  4402  {
  4403          int i;
  4404  
  4405          for (i = 0; i < num; i++) {
  4406                  dma_addr_t buf_phys_addr =
  4407                                      txq_pcpu->tx_buffs[txq_pcpu->txq_get_index];
  4408                  struct sk_buff *skb = txq_pcpu->tx_skb[txq_pcpu->txq_get_index];
  4409  
  4410                  mvpp2_txq_inc_get(txq_pcpu);
  4411  
  4412                  dma_unmap_single(port->dev->dev.parent, buf_phys_addr,
  4413                                   skb_headlen(skb), DMA_TO_DEVICE);
                                         ^^^^^^^^^^^^^^^^
Dereference inside function.

  4414                  if (!skb)
                            ^^^^^
Check too late.  There is no way that patch can be fix a bug, the best
case is that it does nothing or maybe it adds an oops...

  4415                          continue;
  4416                  dev_kfree_skb_any(skb);
  4417          }
  4418  }


regards,
dan carpenter
