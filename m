From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bug - regression - Via velocity interface coming up freezes
 kernel
Date: Fri, 15 Nov 2013 01:01:13 +0100
Message-ID: <20131115000113.GA22051@electric-eye.fr.zoreil.com>
References: <CAFES+i+OYq_dDtEqAqkW7qYDrtdzkqc9hBGBDODQuqgvFJE7zg@mail.gmail.com>
 <20130922221109.GA14246@electric-eye.fr.zoreil.com>
 <20131111234656.GA4846@marquez.int.rhx>
 <20131114072451.GA2313@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dirk Kraft <dirk.kraft@gmail.com>, netdev@vger.kernel.org,
	Julia Lawall <Julia.Lawall@lip6.fr>
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60215 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325Ab3KOABc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 19:01:32 -0500
Content-Disposition: inline
In-Reply-To: <20131114072451.GA2313@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> Michele Baldessari <michele@acksyn.org> :
> [...]
> > any chance you can submit this officially ?
> 
> Yes.
> 
> > Or does this patch need some more work ?
> 
> I'll write some narrative for the commit message.

I would actually rather send the patch below.

The previous patch isn't safe against mtu changes. Please give the patch
below some testing. Test case: receive lots of packets while changing MTU.
Loop. The former patch may crash. The later shouldn't.

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index d022bf9..ad61d26 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2172,16 +2172,13 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 	unsigned int rx_done;
 	unsigned long flags;
 
-	spin_lock_irqsave(&vptr->lock, flags);
 	/*
 	 * Do rx and tx twice for performance (taken from the VIA
 	 * out-of-tree driver).
 	 */
-	rx_done = velocity_rx_srv(vptr, budget / 2);
-	velocity_tx_srv(vptr);
-	rx_done += velocity_rx_srv(vptr, budget - rx_done);
+	rx_done = velocity_rx_srv(vptr, budget);
+	spin_lock_irqsave(&vptr->lock, flags);
 	velocity_tx_srv(vptr);
-
 	/* If budget not fully consumed, exit the polling mode */
 	if (rx_done < budget) {
 		napi_complete(napi);
@@ -2342,6 +2339,8 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 		if (ret < 0)
 			goto out_free_tmp_vptr_1;
 
+		napi_disable(&vptr->napi);
+
 		spin_lock_irqsave(&vptr->lock, flags);
 
 		netif_stop_queue(dev);
@@ -2362,6 +2361,8 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 
 		velocity_give_many_rx_descs(vptr);
 
+		napi_enable(&vptr->napi);
+
 		mac_enable_int(vptr->mac_regs);
 		netif_start_queue(dev);
 
