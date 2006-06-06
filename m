From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 21:57:51 -0700
Message-ID: <adahd2ynank.fsf@cisco.com>
References: <20060531.170908.46214247.davem@davemloft.net>
	<20060601002525.GA19220@gondor.apana.org.au>
	<20060601111503.GA16097@gondor.apana.org.au>
	<20060605.213250.85688925.davem@davemloft.net>
	<adapshmnbam.fsf@cisco.com> <adalksanb0c.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:62555 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932094AbWFFE5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:57:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <adalksanb0c.fsf@cisco.com> (Roland Dreier's message of "Mon, 05 Jun 2006 21:50:11 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Roland> You know, looking at the ipoib code, I can't even recreate
    Roland> why xmit_lock is taken in the set_multicast_list method
    Roland> anyway, or how it works at all -- it seems
    Roland> set_multicast_list will always be called with xmit_lock
    Roland> already held.  What the heck is going on?

Never mind -- I see that the set_multicast_list work needs to be
deferred to process context, so ipoib_mcast_restart_task() doesn't run
directly from the call to set_multicast_list.

I guess the fix in the current kernel is just something like the
below.  And in the netif_tx_lock() patch, the local_irq_save() /
local_irq_restore() calls can just be removed.

Am I on the right track?

Anyway I won't push the patch below since the bug is harmless right
now and it can be fixed up as part of the netif_tx_lock() patch.

Thanks,
  Roland

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index ec41c8f..5f3eaf1 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -814,13 +814,12 @@ void ipoib_mcast_restart_task(void *dev_
 	struct dev_mc_list *mclist;
 	struct ipoib_mcast *mcast, *tmcast;
 	LIST_HEAD(remove_list);
-	unsigned long flags;
 
 	ipoib_dbg_mcast(priv, "restarting multicast task\n");
 
 	ipoib_mcast_stop_thread(dev, 0);
 
-	spin_lock_irqsave(&dev->xmit_lock, flags);
+	spin_lock_bh(&dev->xmit_lock);
 	spin_lock(&priv->lock);
 
 	/*
@@ -895,7 +894,7 @@ void ipoib_mcast_restart_task(void *dev_
 	}
 
 	spin_unlock(&priv->lock);
-	spin_unlock_irqrestore(&dev->xmit_lock, flags);
+	spin_unlock_bh(&dev->xmit_lock);
 
 	/* We have to cancel outside of the spinlock */
 	list_for_each_entry_safe(mcast, tmcast, &remove_list, list) {
