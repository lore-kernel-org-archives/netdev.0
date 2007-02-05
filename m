From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Question on IOAT
Date: Mon, 5 Feb 2007 17:59:57 +0100
Message-ID: <200702051759.58928.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet02.oracle.com ([148.87.113.119]:13666 "EHLO
	rgminet02.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbXBERWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 12:22:43 -0500
Received: from rgminet01.oracle.com (rgminet01.oracle.com [148.87.113.118])
	by rgminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id l15HMfho027423
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 10:22:41 -0700
Received: from rgmgw1.us.oracle.com (rgmgw1.us.oracle.com [138.1.186.110])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id l15HGLXY009983
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 10:16:21 -0700
Received: from rcsmt251.oracle.com (rcsmt251.oracle.com [148.87.90.196])
	by rgmgw1.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id l15H42Kd027254
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 10:16:20 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I looked into the IOAT code today as I'm trying to find out how to add support
for it to NFS. I ran into this piece of code, which waits for the DMA
operation to complete:

                while (dma_async_memcpy_complete(tp->ucopy.dma_chan,
                                                 tp->ucopy.dma_cookie, &done,
                                                 &used) == DMA_IN_PROGRESS) {
                        /* do partial cleanup of sk_async_wait_queue */
                        while ((skb = skb_peek(&sk->sk_async_wait_queue)) &&
                               (dma_async_is_complete(skb->dma_cookie, done,
                                                      used) == DMA_SUCCESS)) {
                                __skb_dequeue(&sk->sk_async_wait_queue);
                                kfree_skb(skb);
                        }
                }

Nowhere in the dma_async_*complete functions can I see any code
that would sleep if the DMA is not yet complete. Am I missing something,
or are we really busy-waiting on the DMA engine? Wouldn't this kind of
defeat the purpose of freeing up the CPU from the chores of memcpying?

I also checked the code in ioatdma.c - I would have expected there to
be some kind of interrupt handler that kicks the upper layers when a
DMA operation completes. But the interrupt handler seems to be for
error reporting exclusively... 

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
