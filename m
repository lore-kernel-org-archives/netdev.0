From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [2.6.30-git21] Network Namespace test failure
Date: Wed, 24 Jun 2009 22:38:47 -0500
Message-ID: <20090625033847.GA27181@us.ibm.com>
References: <4A422F1E.3050208@in.ibm.com> <20090624140056.GA11912@us.ibm.com> <4A42391A.4040802@in.ibm.com> <20090625031449.GA26767@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, serue@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, matthltc@us.ibm.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:45081 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbZFYDil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 23:38:41 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5P3ZcpN028078
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 21:35:38 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5P3cioi261356
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 21:38:44 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5P3chIF008943
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 21:38:44 -0600
Content-Disposition: inline
In-Reply-To: <20090625031449.GA26767@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Sachin Sant (sachinp@in.ibm.com):
> > Serge E. Hallyn wrote:
> >> Precise kernel version and .config?
> >>   
> > Kernel version is 2.6.30-git21 (626f380d0b264a1e40237f5a2a3dffc5d14f256e)
> 
> Thanks.  I bisected it to commit
> ae0e8e82205c903978a79ebf5e31c670b61fa5b4 : "veth: prevent oops caused by
> netdev destructor".  That moves the free_percpu(priv->stats) from
> veth_dev_free to veth_close().  Since it gets allocated at
> veth_dev_init, and dveth_xmit uses it unconditionally, that seems like a
> likely cause of the oops?

Indeed the following patch fixes it on my end.  Sachin can you give
this one a shot?

thanks,
-serge

>From 7193023ad09dbc4b57909c0204c19ed93472cd9e Mon Sep 17 00:00:00 2001
From: root <root@elm3b203.beaverton.ibm.com>
Date: Wed, 24 Jun 2009 20:26:17 -0700
Subject: [PATCH 1/1] veth: don't free priv->status until dev->destructor

Since commit ae0e8e82205c903978a79ebf5e31c670b61fa5b4, priv->status
has been freed at veth_close().  But that causes a NULL deref at
veth_xmit.  This patch moves priv->status free back to the device
destructor.

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 drivers/net/veth.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8e56fcf..6000aae 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -259,8 +259,6 @@ static int veth_close(struct net_device *dev)
 	netif_carrier_off(dev);
 	netif_carrier_off(priv->peer);
 
-	free_percpu(priv->stats);
-	priv->stats = NULL;
 	return 0;
 }
 
@@ -301,6 +299,15 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_set_mac_address = eth_mac_addr,
 };
 
+static void veth_dev_free(struct net_device *dev)
+{
+	struct veth_priv *priv;
+
+	priv = netdev_priv(dev);
+	free_percpu(priv->stats);
+	free_netdev(dev);
+}
+
 static void veth_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -308,7 +315,7 @@ static void veth_setup(struct net_device *dev)
 	dev->netdev_ops = &veth_netdev_ops;
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
-	dev->destructor = free_netdev;
+	dev->destructor = veth_dev_free;
 }
 
 /*
-- 
1.6.2.3

