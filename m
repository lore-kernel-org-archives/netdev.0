From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: drivers: net: xgene: fix statistics counters race condition
Date: Tue, 17 May 2016 10:33:44 +0300
Message-ID: <20160517073344.GD10872@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38776 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbcEQHd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 03:33:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Iyappan Subramanian,

The patch 3bb502f83080: "drivers: net: xgene: fix statistics counters
race condition" from May 13, 2016, leads to the following static
checker warning:

	drivers/net/ethernet/apm/xgene/xgene_enet_main.c:487 xgene_enet_rx_frame()
	warn: should this be a bitwise op?

drivers/net/ethernet/apm/xgene/xgene_enet_main.c
   472          u8 status;
   473          int ret = 0;
   474  
   475          ndev = rx_ring->ndev;
   476          pdata = netdev_priv(ndev);
   477          dev = ndev_to_dev(rx_ring->ndev);
   478          buf_pool = rx_ring->buf_pool;
   479  
   480          dma_unmap_single(dev, GET_VAL(DATAADDR, le64_to_cpu(raw_desc->m1)),
   481                           XGENE_ENET_MAX_MTU, DMA_FROM_DEVICE);
   482          skb_index = GET_VAL(USERINFO, le64_to_cpu(raw_desc->m0));
   483          skb = buf_pool->rx_skb[skb_index];
   484  
   485          /* checking for error */
   486          status = (GET_VAL(ELERR, le64_to_cpu(raw_desc->m0)) << LERR_LEN) ||
   487                    GET_VAL(LERR, le64_to_cpu(raw_desc->m0));
   488          if (unlikely(status > 2)) {

This code doesn't make sense and I don't know what is intended.
LERR_LEN is 3, but why are we shifting when we just care about
true/false?  In the original code status could be > 2 but now it's
either 0 or 1.

   489                  dev_kfree_skb_any(skb);
   490                  xgene_enet_parse_error(rx_ring, netdev_priv(rx_ring->ndev),
   491                                         status);
   492                  ret = -EIO;
   493                  goto out;
   494          }

regards,
dan carpenter
