From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] bnx2: Remove some unnecessary smp_mb() in
 tx fast path.
Date: Mon, 19 Jul 2010 20:31:19 -0700 (PDT)
Message-ID: <20100719.203119.106787548.davem@davemloft.net>
References: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
	<1279584905-15084-2-git-send-email-mchan@broadcom.com>
	<1279584905-15084-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758226Ab0GTDbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 23:31:03 -0400
In-Reply-To: <1279584905-15084-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 19 Jul 2010 17:15:04 -0700

> smp_mb() inside bnx2_tx_avail() is used twice in the normal
> bnx2_start_xmit() path (see illustration below).  The full memory
> barrier is only necessary during race conditions with tx completion.
> We can speed up the tx path by replacing smp_mb() in bnx2_tx_avail()
> with a compiler barrier.  The compiler barrier is to force the
> compiler to fetch the tx_prod and tx_cons from memory.
> 
> In the race condition between bnx2_start_xmit() and bnx2_tx_int(),
> we have the following situation:
> 
> bnx2_start_xmit()                       bnx2_tx_int()
>     if (!bnx2_tx_avail())
>             BUG();
> 
>     ...
> 
>     if (!bnx2_tx_avail())
>             netif_tx_stop_queue();          update_tx_index();
>             smp_mb();                       smp_mb();
>             if (bnx2_tx_avail())            if (netif_tx_queue_stopped() &&
>                     netif_tx_wake_queue();      bnx2_tx_avail())
> 
> With smp_mb() removed from bnx2_tx_avail(), we need to add smp_mb() to
> bnx2_start_xmit() as shown above to properly order netif_tx_stop_queue()
> and bnx2_tx_avail() to check the ring index.  If it is not strictly
> ordered, the tx queue can be stopped forever.
> 
> This improves performance by about 5% with 2 ports running bi-directional
> 64-byte packets.
> 
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
