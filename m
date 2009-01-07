From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH 33/42] I4l: convert to net_device_ops
Date: Wed, 7 Jan 2009 12:30:14 +0100
Message-ID: <20090107113013.GA25205@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51290 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754108AbZAGLaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 06:30:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add net_device_ops and use interal stats 

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Karsten Keil <kkeil@suse.de>

--- a/drivers/isdn/i4l/isdn_net.c	2009-01-03 22:04:20.322771793 -0800
+++ b/drivers/isdn/i4l/isdn_net.c	2009-01-03 22:25:41.290763701 -0800
@@ -1485,6 +1485,24 @@ isdn_ciscohdlck_dev_ioctl(struct net_dev
 	return (rc);
 }
 
+
+static int isdn_net_ioctl(struct net_device *dev,
+			  struct ifreq *ifr, int cmd)
+{
+	isdn_net_local *lp = (isdn_net_local *) netdev_priv(dev);
+
+	switch (lp->p_encap) {
+#ifdef CONFIG_ISDN_PPP
+	case ISDN_NET_ENCAP_SYNCPPP:
+		return isdn_ppp_dev_ioctl(dev, ifr, cmd);
+#endif
+	case ISDN_NET_ENCAP_CISCOHDLCK:
+		return isdn_ciscohdlck_dev_ioctl(dev, ifr, cmd);
+	default:
+		return -EINVAL;
+	}
+}
+
 /* called via cisco_timer.function */
 static void
 isdn_net_ciscohdlck_slarp_send_keepalive(unsigned long data)
@@ -1998,23 +2016,6 @@ isdn_net_init(struct net_device *ndev)
 	ushort max_hlhdr_len = 0;
 	int drvidx;
 
-	ether_setup(ndev);
-	ndev->header_ops = NULL;
-
-	/* Setup the generic properties */
-	ndev->mtu = 1500;
-	ndev->flags = IFF_NOARP|IFF_POINTOPOINT;
-	ndev->type = ARPHRD_ETHER;
-	ndev->addr_len = ETH_ALEN;
-	ndev->validate_addr = NULL;
-
-	/* for clients with MPPP maybe higher values better */
-	ndev->tx_queue_len = 30;
-
-	/* The ISDN-specific entries in the device structure. */
-	ndev->open = &isdn_net_open;
-	ndev->hard_start_xmit = &isdn_net_start_xmit;
-
 	/*
 	 *  up till binding we ask the protocol layer to reserve as much
 	 *  as we might need for HL layer
@@ -2026,9 +2027,6 @@ isdn_net_init(struct net_device *ndev)
 				max_hlhdr_len = dev->drv[drvidx]->interface->hl_hdrlen;
 
 	ndev->hard_header_len = ETH_HLEN + max_hlhdr_len;
-	ndev->stop = &isdn_net_close;
-	ndev->get_stats = &isdn_net_get_stats;
-	ndev->do_ioctl = NULL;
 	return 0;
 }
 
@@ -2508,6 +2506,19 @@ isdn_net_force_dial(char *name)
 	return (isdn_net_force_dial_lp(p->local));
 }
 
+/* The ISDN-specific entries in the device structure. */
+static const struct net_device_ops isdn_netdev_ops = {
+	.ndo_init	      = isdn_net_init,
+	.ndo_open	      = isdn_net_open,
+	.ndo_stop	      = isdn_net_close,
+	.ndo_do_ioctl	      = isdn_net_ioctl,
+
+	.ndo_validate_addr    = NULL,
+	.ndo_start_xmit	      = isdn_net_start_xmit,
+	.ndo_get_stats	      = isdn_net_get_stats,
+	.ndo_tx_timeout	      = isdn_net_tx_timeout,
+};
+
 /*
  * Helper for alloc_netdev()
  */
@@ -2515,7 +2526,20 @@ static void _isdn_setup(struct net_devic
 {
 	isdn_net_local *lp = netdev_priv(dev);
 
+	ether_setup(dev);
+
 	dev->flags = IFF_NOARP | IFF_POINTOPOINT;
+	/* Setup the generic properties */
+	dev->mtu = 1500;
+	dev->flags = IFF_NOARP|IFF_POINTOPOINT;
+	dev->type = ARPHRD_ETHER;
+	dev->addr_len = ETH_ALEN;
+	dev->header_ops = NULL;
+	dev->netdev_ops = &isdn_netdev_ops;
+
+	/* for clients with MPPP maybe higher values better */
+	dev->tx_queue_len = 30;
+
 	lp->p_encap = ISDN_NET_ENCAP_RAWIP;
 	lp->magic = ISDN_NET_MAGIC;
 	lp->last = lp;
@@ -2570,7 +2594,7 @@ isdn_net_new(char *name, struct net_devi
 		return NULL;
 	}
 	netdev->local = netdev_priv(netdev->dev);
-	netdev->dev->init = isdn_net_init;
+
 	if (master) {
 		/* Device shall be a slave */
 		struct net_device *p = MASTER_TO_SLAVE(master);
@@ -2588,7 +2612,6 @@ isdn_net_new(char *name, struct net_devi
 		/*
 		 * Watchdog timer (currently) for master only.
 		 */
-		netdev->dev->tx_timeout = isdn_net_tx_timeout;
 		netdev->dev->watchdog_timeo = ISDN_NET_TX_TIMEOUT;
 		if (register_netdev(netdev->dev) != 0) {
 			printk(KERN_WARNING "isdn_net: Could not register net-device\n");
@@ -2704,7 +2727,6 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg
 #else
 			p->dev->type = ARPHRD_PPP;	/* change ARP type */
 			p->dev->addr_len = 0;
-			p->dev->do_ioctl = isdn_ppp_dev_ioctl;
 #endif
 			break;
 		case ISDN_NET_ENCAP_X25IFACE:
@@ -2718,7 +2740,6 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg
 #endif
 			break;
 		case ISDN_NET_ENCAP_CISCOHDLCK:
-			p->dev->do_ioctl = isdn_ciscohdlck_dev_ioctl;
 			break;
 		default:
 			if( cfg->p_encap >= 0 &&

-- 

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
