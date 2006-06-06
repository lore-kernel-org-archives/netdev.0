From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 23:01:34 -0700
Message-ID: <ada8xoan7pd.fsf@cisco.com>
References: <adapshmnbam.fsf@cisco.com> <adalksanb0c.fsf@cisco.com>
	<adahd2ynank.fsf@cisco.com>
	<20060605.221018.70218518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:30864 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932118AbWFFGBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 02:01:37 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060605.221018.70218518.davem@davemloft.net> (David Miller's message of "Mon, 05 Jun 2006 22:10:18 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> As long as you never take priv->lock while ->xmit_lock is
    David> held your patch should be OK.

Duh ... unfortunately priv->lock is taken from interrupt context so
that patch isn't safe.  A correct fix would be the following, which
leads to a trivial conversion to using netif_tx_lock().

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 1dae4b2..7a8ca5d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -821,8 +821,8 @@ void ipoib_mcast_restart_task(void *dev_
 
 	ipoib_mcast_stop_thread(dev, 0);
 
-	spin_lock_irqsave(&dev->xmit_lock, flags);
-	spin_lock(&priv->lock);
+	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	/*
 	 * Unfortunately, the networking core only gives us a list of all of
@@ -895,8 +895,8 @@ void ipoib_mcast_restart_task(void *dev_
 		}
 	}
 
-	spin_unlock(&priv->lock);
-	spin_unlock_irqrestore(&dev->xmit_lock, flags);
+	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_bh(&dev->xmit_lock);
 
 	/* We have to cancel outside of the spinlock */
 	list_for_each_entry_safe(mcast, tmcast, &remove_list, list) {
