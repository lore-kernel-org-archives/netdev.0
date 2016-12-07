From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 8 Dec 2016 00:15:34 +0100
Message-ID: <20161207231534.GB5889@electric-eye.fr.zoreil.com>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com, pavel@ucw.cz,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lino Sanfilippo <LinoSanfilippo@gmx.de> :
> The driver uses a private lock for synchronization between the xmit
> function and the xmit completion handler, but since the NETIF_F_LLTX flag
> is not set, the xmit function is also called with the xmit_lock held.
> 
> On the other hand the xmit completion handler first takes the private lock
> and (in case that the tx queue has been stopped) the xmit_lock, leading
> to a reverse locking order and the potential danger of a deadlock.

netif_tx_stop_queue is used by:
1. xmit function before releasing lock and returning.
2. sxgbe_restart_tx_queue()
   <- sxgbe_tx_interrupt
   <- sxgbe_reset_all_tx_queues()
      <- sxgbe_tx_timeout()

Given xmit won't be called again until tx queue is enabled, it's not clear
how a deadlock could happen due to #1.

Regardless of deadlocks anywhere else, #2 has some serious problem due to
the lack of exclusion between the tx queue restart handler and the xmit
handler.

-- 
Ueimor
