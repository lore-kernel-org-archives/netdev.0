From: Jean-Louis Dupond <info@dupondje.be>
Subject: Re: b44: device restarts on heavy load
Date: Tue, 16 Jun 2009 17:11:08 +0200
Message-ID: <4A37B60C.7000303@dupondje.be>
References: <4A37B08F.9000809@dupondje.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.dupie.be ([85.17.239.130]:46609 "EHLO apollo.dupie.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786AbZFPPLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 11:11:06 -0400
Received: from [192.168.3.138] (235.167-78-194.adsl-static.isp.belgacom.be [194.78.167.235])
	(Authenticated sender: info@dupondje.be)
	by apollo.dupie.be (Postfix) with ESMTP id EF8D11E501A6
	for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 17:11:08 +0200 (CEST)
In-Reply-To: <4A37B08F.9000809@dupondje.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be more precise, the error is ISTAT_RFO              0x00004000 /* 
Receive FIFO Overflow */

Jean-Louis Dupond schreef:
> Hello,
> 
> There seems to be a bug in the b44 driver to cause a restart/reset of 
> the network card. I tried to debug it a bit, and the error is in the 
> b44_poll method.
> 
> 846 static int b44_poll(struct napi_struct *napi, int budget)
> 847 {
> 848         struct b44 *bp = container_of(napi, struct b44, napi);
> 849         int work_done;
> 850
> 851         spin_lock_irq(&bp->lock);
> 852
> 853         if (bp->istat & (ISTAT_TX | ISTAT_TO)) {
> 854                 /* spin_lock(&bp->tx_lock); */
> 855                 b44_tx(bp);
> 856                 /* spin_unlock(&bp->tx_lock); */
> 857         }
> 858         spin_unlock_irq(&bp->lock);
> 859
> 860         work_done = 0;
> 861         if (bp->istat & ISTAT_RX)
> 862                 work_done += b44_rx(bp, budget);
> 863
> 864         if (bp->istat & ISTAT_ERRORS) {
> 865                 unsigned long flags;
> 866
> 867                 spin_lock_irqsave(&bp->lock, flags);
> 868                 b44_halt(bp);
> 869                 b44_init_rings(bp);
> 870                 b44_init_hw(bp, B44_FULL_RESET_SKIP_PHY);
> 871                 netif_wake_queue(bp->dev);
> 872                 spin_unlock_irqrestore(&bp->lock, flags);
> 873                 work_done = 0;
> 874         }
> 875
> 876         if (work_done < budget) {
> 877                 napi_complete(napi);
> 878                 b44_enable_ints(bp);
> 879         }
> 880
> 881         return work_done;
> 882 }
> 
> 
> It seems that suddenly bp->istat & ISTAT_ERRORS is true, so it resets 
> the network card. This isn't really nice :(
> 
> There seems to be ALOT of people having this issue: 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/279102
> 
> Sincerely
> Jean-Louis Dupond
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
