From: Dan Carpenter <error27@gmail.com>
Subject: dl2k: potential null dereference in recieve_packet()
Date: Sun, 19 Jul 2009 14:59:24 +0300 (EAT)
Message-ID: <alpine.DEB.2.00.0907171612530.12306@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:38639 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417AbZGSM5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2009 08:57:35 -0400
Received: by an-out-0708.google.com with SMTP id d40so2734163and.1
        for <netdev@vger.kernel.org>; Sun, 19 Jul 2009 05:57:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Smatch (http://repo.or.cz/w/smatch.git) found a potential null dereference 
in drivers/net/dl2k.c receive_packet().  If the allocation on line 874 
fails we still dereference skb on line 890.

drivers/net/dl2k.c 
   874                          } else if ((skb = netdev_alloc_skb(dev, pkt_len + 2))) {
   875                                  pci_dma_sync_single_for_cpu(np->pdev,
   876                                                              desc_to_dma(desc),
   877                                                              np->rx_buf_sz,
   878                                                              PCI_DMA_FROMDEVICE);
   879                                  /* 16 byte align the IP header */
   880                                  skb_reserve (skb, 2);
   881                                  skb_copy_to_linear_data (skb,
   882                                                    np->rx_skbuff[entry]->data,
   883                                                    pkt_len);
   884                                  skb_put (skb, pkt_len);
   885                                  pci_dma_sync_single_for_device(np->pdev,
   886                                                                 desc_to_dma(desc),
   887                                                                 np->rx_buf_sz,
   888                                                                 PCI_DMA_FROMDEVICE);
   889                          }
   890                          skb->protocol = eth_type_trans (skb, dev);

regards,
dan carpenter

