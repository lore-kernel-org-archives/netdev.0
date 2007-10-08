From: Karsten Keil <kkeil@suse.de>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by ISDN
Date: Mon, 8 Oct 2007 17:58:36 +0200
Message-ID: <20071008155836.GA19932@pingi.kke.suse.de>
References: <20071007120653.GA16184@rhlx01.hs-esslingen.de> <4708D00D.8030307@garzik.org> <20071007131723.GA22873@rhlx01.hs-esslingen.de> <20071007172037.GA29384@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, isdn4linux@listserv.isdn4linux.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:59519 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbXJHP6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 11:58:40 -0400
Content-Disposition: inline
In-Reply-To: <20071007172037.GA29384@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 07, 2007 at 07:20:37PM +0200, Andreas Mohr wrote:
> Hi,
> 
> On Sun, Oct 07, 2007 at 03:17:24PM +0200, Andreas Mohr wrote:
> > I thus decided to now try plain 2.6.23-rc8 whether it's "corrupted", too.
> 
> OK, after 3 hours of compilation the ONLY datapoint I can give right now is:
> 1 (one) boot on 2.6.23-rc8-mm2 had the BUG in /var/log/messages,
> 1 (one) boot on 2.6.23-rc8 did NOT have it.
> 
> The two .config:s (I did a make oldconfig when going back to
> non-mm2) don't seem to have any relevant differences.
> 
> I could offer to do more testing on this machine,
> but this carries a slight risk for me since I (personally) won't have physical
> access to it for a couple days and some people will kill me if the main
> internet gateway happened to go down unfixably. ;)
>

You could try following patch with 2.6.23-rc8-mm2, it change I4L to use
alloc_netdev().

Signed-off-by: Karsten Keil <kkeil@suse.de>

diff -ur linux-2.6.23-rc9.org/drivers/isdn/i4l/isdn_net.c linux-2.6.23-rc9/drivers/isdn/i4l/isdn_net.c
--- linux-2.6.23-rc9.org/drivers/isdn/i4l/isdn_net.c	2007-10-08 12:01:22.000000000 +0200
+++ linux-2.6.23-rc9/drivers/isdn/i4l/isdn_net.c	2007-10-08 17:31:43.000000000 +0200
@@ -77,7 +77,7 @@
 	if (lp->master) 
 		dev = lp->master;
 	else
-		dev = &n->dev;
+		dev = n->dev;
 	return netif_running(dev);
 }
 
@@ -90,7 +90,7 @@
 	if (lp->master) 
 		netif_wake_queue(lp->master);
 	else
-		netif_wake_queue(&lp->netdev->dev);
+		netif_wake_queue(lp->netdev->dev);
 }
 
 /*
@@ -102,7 +102,7 @@
 	if (lp->master)
 		netif_stop_queue(lp->master);
 	else
-		netif_stop_queue(&lp->netdev->dev);
+		netif_stop_queue(lp->netdev->dev);
 }
 
 /*
@@ -287,7 +287,7 @@
 		   BEWARE! This chunk of code cannot be called from hardware
 		   interrupt handler. I hope it is true. --ANK
 		 */
-		qdisc_reset(lp->netdev->dev.qdisc);
+		qdisc_reset(lp->netdev->dev->qdisc);
 	}
 	lp->dialstate = 0;
 	dev->rx_netdev[isdn_dc2minor(lp->isdn_device, lp->isdn_channel)] = NULL;
@@ -345,27 +345,27 @@
 						l->chargetime += l->chargeint;
 					if (time_after(jiffies, l->chargetime + l->chargeint - 2 * HZ))
 						if (l->outgoing || l->hupflags & ISDN_INHUP)
-							isdn_net_hangup(&p->dev);
+							isdn_net_hangup(p->dev);
 				} else if (l->outgoing) {
 					if (l->hupflags & ISDN_CHARGEHUP) {
 						if (l->hupflags & ISDN_WAITCHARGE) {
 							printk(KERN_DEBUG "isdn_net: Hupflags of %s are %X\n",
 							       l->name, l->hupflags);
-							isdn_net_hangup(&p->dev);
+							isdn_net_hangup(p->dev);
 						} else if (time_after(jiffies, l->chargetime + l->chargeint)) {
 							printk(KERN_DEBUG
 							       "isdn_net: %s: chtime = %lu, chint = %d\n",
 							       l->name, l->chargetime, l->chargeint);
-							isdn_net_hangup(&p->dev);
+							isdn_net_hangup(p->dev);
 						}
 					} else
-						isdn_net_hangup(&p->dev);
+						isdn_net_hangup(p->dev);
 				} else if (l->hupflags & ISDN_INHUP)
-					isdn_net_hangup(&p->dev);
+					isdn_net_hangup(p->dev);
 			}
 
 			if(dev->global_flags & ISDN_GLOBAL_STOPPED || (ISDN_NET_DIALMODE(*l) == ISDN_NET_DM_OFF)) {
-				isdn_net_hangup(&p->dev);
+				isdn_net_hangup(p->dev);
 				break;
 			}
 		}
@@ -579,7 +579,7 @@
 				if (!lp->dial) {
 					printk(KERN_WARNING "%s: phone number deleted?\n",
 					       lp->name);
-					isdn_net_hangup(&p->dev);
+					isdn_net_hangup(p->dev);
 					break;
 				}
 				anymore = 1;
@@ -616,8 +616,8 @@
 						s = "dial suppressed: isdn system stopped";
 					else
 						s = "dial suppressed: dialmode `off'";
-					isdn_net_unreachable(&p->dev, NULL, s);
-					isdn_net_hangup(&p->dev);
+					isdn_net_unreachable(p->dev, NULL, s);
+					isdn_net_hangup(p->dev);
 					break;
 				}
 				cmd.driver = lp->isdn_device;
@@ -633,7 +633,7 @@
 				if (!lp->dial) {
 					printk(KERN_WARNING "%s: phone number deleted?\n",
 					       lp->name);
-					isdn_net_hangup(&p->dev);
+					isdn_net_hangup(p->dev);
 					break;
 				}
 				if (!strncmp(lp->dial->num, "LEASED", strlen("LEASED"))) {
@@ -644,8 +644,8 @@
 						if (time_after(jiffies, lp->dialstarted + lp->dialtimeout)) {
 							lp->dialwait_timer = jiffies + lp->dialwait;
 							lp->dialstarted = 0;
-							isdn_net_unreachable(&p->dev, NULL, "dial: timed out");
-							isdn_net_hangup(&p->dev);
+							isdn_net_unreachable(p->dev, NULL, "dial: timed out");
+							isdn_net_hangup(p->dev);
 							break;
 						}
 
@@ -674,9 +674,9 @@
 							if (lp->dialtimeout == 0) {
 								lp->dialwait_timer = jiffies + lp->dialwait;
 								lp->dialstarted = 0;
-								isdn_net_unreachable(&p->dev, NULL, "dial: tried all numbers dialmax times");
+								isdn_net_unreachable(p->dev, NULL, "dial: tried all numbers dialmax times");
 							}
-							isdn_net_hangup(&p->dev);
+							isdn_net_hangup(p->dev);
 							break;
 						}
 					}
@@ -758,7 +758,7 @@
 				cmd.arg = lp->isdn_channel + (lp->l3_proto << 8);
 				isdn_command(&cmd);
 				if (lp->dtimer++ > ISDN_TIMER_DTIMEOUT15)
-					isdn_net_hangup(&p->dev);
+					isdn_net_hangup(p->dev);
 				else {
 					anymore = 1;
 					lp->dialstate++;
@@ -781,7 +781,7 @@
 				printk(KERN_DEBUG "dialtimer4: %d\n", lp->dtimer);
 #endif
 				if (lp->dtimer++ > ISDN_TIMER_DTIMEOUT10)
-					isdn_net_hangup(&p->dev);
+					isdn_net_hangup(p->dev);
 				else
 					anymore = 1;
 				break;
@@ -1618,7 +1618,7 @@
 	__be32 addr = 0;		/* local ipv4 address */
 	__be32 mask = 0;		/* local netmask */
 
-	if ((in_dev = lp->netdev->dev.ip_ptr) != NULL) {
+	if ((in_dev = lp->netdev->dev->ip_ptr) != NULL) {
 		/* take primary(first) address of interface */
 		struct in_ifaddr *ifa = in_dev->ifa_list;
 		if (ifa != NULL) {
@@ -1866,7 +1866,7 @@
 		isdn_net_local *lp = p->local;
 		if ((lp->flags & ISDN_NET_CONNECTED) &&
 		    (!lp->dialstate)) {
-			isdn_net_receive(&p->dev, skb);
+			isdn_net_receive(p->dev, skb);
 			return 1;
 		}
 	}
@@ -2531,6 +2531,42 @@
 }
 
 /*
+ * Helper for alloc_netdev()
+ */
+static void _isdn_setup(struct net_device *dev)
+{
+	isdn_net_local *lp = dev->priv;
+
+	dev->flags = IFF_NOARP | IFF_POINTOPOINT;
+	lp->p_encap = ISDN_NET_ENCAP_RAWIP;
+	lp->magic = ISDN_NET_MAGIC;
+	lp->last = lp;
+	lp->next = lp;
+	lp->isdn_device = -1;
+	lp->isdn_channel = -1;
+	lp->pre_device = -1;
+	lp->pre_channel = -1;
+	lp->exclusive = -1;
+	lp->ppp_slot = -1;
+	lp->pppbind = -1;
+	skb_queue_head_init(&lp->super_tx_queue);
+	lp->l2_proto = ISDN_PROTO_L2_X75I;
+	lp->l3_proto = ISDN_PROTO_L3_TRANS;
+	lp->triggercps = 6000;
+	lp->slavedelay = 10 * HZ;
+	lp->hupflags = ISDN_INHUP;	/* Do hangup even on incoming calls */
+	lp->onhtime = 10;	/* Default hangup-time for saving costs */
+	lp->dialmax = 1;
+	/* Hangup before Callback, manual dial */
+	lp->flags = ISDN_NET_CBHUP | ISDN_NET_DM_MANUAL;
+	lp->cbdelay = 25;	/* Wait 5 secs before Callback */
+	lp->dialtimeout = -1;  /* Infinite Dial-Timeout */
+	lp->dialwait = 5 * HZ; /* Wait 5 sec. after failed dial */
+	lp->dialstarted = 0;   /* Jiffies of last dial-start */
+	lp->dialwait_timer = 0;  /* Jiffies of earliest next dial-start */
+}
+
+/*
  * Allocate a new network-interface and initialize its data structures.
  */
 char *
@@ -2543,23 +2579,21 @@
 		printk(KERN_WARNING "isdn_net: interface %s already exists\n", name);
 		return NULL;
 	}
+	if (name == NULL)
+		name = "         ";
 	if (!(netdev = kzalloc(sizeof(isdn_net_dev), GFP_KERNEL))) {
 		printk(KERN_WARNING "isdn_net: Could not allocate net-device\n");
 		return NULL;
 	}
-	if (!(netdev->local = kzalloc(sizeof(isdn_net_local), GFP_KERNEL))) {
-		printk(KERN_WARNING "isdn_net: Could not allocate device locals\n");
+	netdev->dev = alloc_netdev(sizeof(isdn_net_local), name, _isdn_setup);
+	if (!netdev->dev) {
+		printk(KERN_WARNING "isdn_net: Could not allocate network device\n");
 		kfree(netdev);
 		return NULL;
 	}
-	if (name == NULL)
-		strcpy(netdev->local->name, "         ");
-	else
-		strcpy(netdev->local->name, name);
-	strcpy(netdev->dev.name, netdev->local->name);
-	netdev->dev.priv = netdev->local;
-	netdev->dev.init = isdn_net_init;
-	netdev->local->p_encap = ISDN_NET_ENCAP_RAWIP;
+	netdev->local = netdev->dev->priv;
+	strcpy(netdev->local->name, netdev->dev->name);
+	netdev->dev->init = isdn_net_init;
 	if (master) {
 		/* Device shall be a slave */
 		struct net_device *p = (((isdn_net_local *) master->priv)->slave);
@@ -2571,60 +2605,33 @@
 			q = p;
 			p = (((isdn_net_local *) p->priv)->slave);
 		}
-		((isdn_net_local *) q->priv)->slave = &(netdev->dev);
+		((isdn_net_local *) q->priv)->slave = netdev->dev;
 	} else {
 		/* Device shall be a master */
 		/*
 		 * Watchdog timer (currently) for master only.
 		 */
-		netdev->dev.tx_timeout = isdn_net_tx_timeout;
-		netdev->dev.watchdog_timeo = ISDN_NET_TX_TIMEOUT;
-		if (register_netdev(&netdev->dev) != 0) {
+		netdev->dev->tx_timeout = isdn_net_tx_timeout;
+		netdev->dev->watchdog_timeo = ISDN_NET_TX_TIMEOUT;
+		if (register_netdev(netdev->dev) != 0) {
 			printk(KERN_WARNING "isdn_net: Could not register net-device\n");
-			kfree(netdev->local);
+			free_netdev(netdev->dev);
 			kfree(netdev);
 			return NULL;
 		}
 	}
-	netdev->local->magic = ISDN_NET_MAGIC;
-
 	netdev->queue = netdev->local;
 	spin_lock_init(&netdev->queue_lock);
 
-	netdev->local->last = netdev->local;
 	netdev->local->netdev = netdev;
-	netdev->local->next = netdev->local;
 
 	INIT_WORK(&netdev->local->tqueue, isdn_net_softint);
 	spin_lock_init(&netdev->local->xmit_lock);
 
-	netdev->local->isdn_device = -1;
-	netdev->local->isdn_channel = -1;
-	netdev->local->pre_device = -1;
-	netdev->local->pre_channel = -1;
-	netdev->local->exclusive = -1;
-	netdev->local->ppp_slot = -1;
-	netdev->local->pppbind = -1;
-	skb_queue_head_init(&netdev->local->super_tx_queue);
-	netdev->local->l2_proto = ISDN_PROTO_L2_X75I;
-	netdev->local->l3_proto = ISDN_PROTO_L3_TRANS;
-	netdev->local->triggercps = 6000;
-	netdev->local->slavedelay = 10 * HZ;
-	netdev->local->hupflags = ISDN_INHUP;	/* Do hangup even on incoming calls */
-	netdev->local->onhtime = 10;	/* Default hangup-time for saving costs
-	   of those who forget configuring this */
-	netdev->local->dialmax = 1;
-	netdev->local->flags = ISDN_NET_CBHUP | ISDN_NET_DM_MANUAL;	/* Hangup before Callback, manual dial */
-	netdev->local->cbdelay = 25;	/* Wait 5 secs before Callback */
-	netdev->local->dialtimeout = -1;  /* Infinite Dial-Timeout */
-	netdev->local->dialwait = 5 * HZ; /* Wait 5 sec. after failed dial */
-	netdev->local->dialstarted = 0;   /* Jiffies of last dial-start */
-	netdev->local->dialwait_timer = 0;  /* Jiffies of earliest next dial-start */
-
 	/* Put into to netdev-chain */
 	netdev->next = (void *) dev->netdev;
 	dev->netdev = netdev;
-	return netdev->dev.name;
+	return netdev->dev->name;
 }
 
 char *
@@ -2649,7 +2656,7 @@
 		/* Master must not be started yet */
 		if (isdn_net_device_started(n)) 
 			return NULL;
-		return (isdn_net_new(newname, &(n->dev)));
+		return (isdn_net_new(newname, n->dev));
 	}
 	return NULL;
 }
@@ -2718,9 +2725,9 @@
 			       lp->name);
 			return -EINVAL;
 #else
-			p->dev.type = ARPHRD_PPP;	/* change ARP type */
-			p->dev.addr_len = 0;
-			p->dev.do_ioctl = isdn_ppp_dev_ioctl;
+			p->dev->type = ARPHRD_PPP;	/* change ARP type */
+			p->dev->addr_len = 0;
+			p->dev->do_ioctl = isdn_ppp_dev_ioctl;
 #endif
 			break;
 		case ISDN_NET_ENCAP_X25IFACE:
@@ -2729,12 +2736,12 @@
 			       p->local->name);
 			return -EINVAL;
 #else
-			p->dev.type = ARPHRD_X25;	/* change ARP type */
-			p->dev.addr_len = 0;
+			p->dev->type = ARPHRD_X25;	/* change ARP type */
+			p->dev->addr_len = 0;
 #endif
 			break;
 		case ISDN_NET_ENCAP_CISCOHDLCK:
-			p->dev.do_ioctl = isdn_ciscohdlck_dev_ioctl;
+			p->dev->do_ioctl = isdn_ciscohdlck_dev_ioctl;
 			break;
 		default:
 			if( cfg->p_encap >= 0 &&
@@ -2861,20 +2868,20 @@
 		}
 		if (cfg->p_encap != lp->p_encap) {
 			if (cfg->p_encap == ISDN_NET_ENCAP_RAWIP) {
-				p->dev.hard_header = NULL;
-				p->dev.hard_header_cache = NULL;
-				p->dev.header_cache_update = NULL;
-				p->dev.flags = IFF_NOARP|IFF_POINTOPOINT;
+				p->dev->hard_header = NULL;
+				p->dev->hard_header_cache = NULL;
+				p->dev->header_cache_update = NULL;
+				p->dev->flags = IFF_NOARP|IFF_POINTOPOINT;
 			} else {
-				p->dev.hard_header = isdn_net_header;
+				p->dev->hard_header = isdn_net_header;
 				if (cfg->p_encap == ISDN_NET_ENCAP_ETHER) {
-					p->dev.hard_header_cache = lp->org_hhc;
-					p->dev.header_cache_update = lp->org_hcu;
-					p->dev.flags = IFF_BROADCAST | IFF_MULTICAST;
+					p->dev->hard_header_cache = lp->org_hhc;
+					p->dev->header_cache_update = lp->org_hcu;
+					p->dev->flags = IFF_BROADCAST | IFF_MULTICAST;
 				} else {
-					p->dev.hard_header_cache = NULL;
-					p->dev.header_cache_update = NULL;
-					p->dev.flags = IFF_NOARP|IFF_POINTOPOINT;
+					p->dev->hard_header_cache = NULL;
+					p->dev->header_cache_update = NULL;
+					p->dev->flags = IFF_NOARP|IFF_POINTOPOINT;
 				}
 			}
 		}
@@ -3095,7 +3102,7 @@
 			isdn_net_hangup(q);
 			q = (((isdn_net_local *) q->priv)->slave);
 		}
-		isdn_net_hangup(&p->dev);
+		isdn_net_hangup(p->dev);
 		return 0;
 	}
 	return -ENODEV;
@@ -3123,13 +3130,13 @@
 		isdn_unexclusive_channel(p->local->pre_device, p->local->pre_channel);
 	if (p->local->master) {
 		/* It's a slave-device, so update master's slave-pointer if necessary */
-		if (((isdn_net_local *) (p->local->master->priv))->slave == &p->dev)
+		if (((isdn_net_local *) (p->local->master->priv))->slave == p->dev)
 			((isdn_net_local *) (p->local->master->priv))->slave = p->local->slave;
 	} else {
 		/* Unregister only if it's a master-device */
-		p->dev.hard_header_cache = p->local->org_hhc;
-		p->dev.header_cache_update = p->local->org_hcu;
-		unregister_netdev(&p->dev);
+		p->dev->hard_header_cache = p->local->org_hhc;
+		p->dev->header_cache_update = p->local->org_hcu;
+		unregister_netdev(p->dev);
 	}
 	/* Unlink device from chain */
 	spin_lock_irqsave(&dev->lock, flags);
@@ -3157,7 +3164,7 @@
 	/* If no more net-devices remain, disable auto-hangup timer */
 	if (dev->netdev == NULL)
 		isdn_timer_ctrl(ISDN_TIMER_NETHANGUP, 0);
-	kfree(p->local);
+	free_netdev(p->dev);
 	kfree(p);
 
 	return 0;
diff -ur linux-2.6.23-rc9.org/drivers/isdn/i4l/isdn_ppp.c linux-2.6.23-rc9/drivers/isdn/i4l/isdn_ppp.c
--- linux-2.6.23-rc9.org/drivers/isdn/i4l/isdn_ppp.c	2007-10-08 12:01:22.000000000 +0200
+++ linux-2.6.23-rc9/drivers/isdn/i4l/isdn_ppp.c	2007-10-08 17:42:06.000000000 +0200
@@ -360,7 +360,7 @@
 		 * isdn_ppp_free() sets is->lp to NULL and lp->ppp_slot to -1
 		 * removing the IPPP_CONNECT flag omits calling of isdn_ppp_wakeup_daemon()
 		 */
-		isdn_net_hangup(&p->dev);
+		isdn_net_hangup(p->dev);
 	}
 	for (i = 0; i < NUM_RCV_BUFFS; i++) {
 		kfree(is->rq[i].buf);
@@ -531,7 +531,7 @@
 				if (lp) {
 					/* OK .. we are ready to send buffers */
 					is->pppcfg = val; /* isdn_ppp_xmit test for SC_ENABLE_IP !!! */
-					netif_wake_queue(&lp->netdev->dev);
+					netif_wake_queue(lp->netdev->dev);
 					break;
 				}
 			}
@@ -1023,7 +1023,7 @@
 static void
 isdn_ppp_push_higher(isdn_net_dev * net_dev, isdn_net_local * lp, struct sk_buff *skb, int proto)
 {
-	struct net_device *dev = &net_dev->dev;
+	struct net_device *dev = net_dev->dev;
  	struct ippp_struct *is, *mis;
 	isdn_net_local *mlp = NULL;
 	int slot;
diff -ur linux-2.6.23-rc9.org/include/linux/isdn.h linux-2.6.23-rc9/include/linux/isdn.h
--- linux-2.6.23-rc9.org/include/linux/isdn.h	2007-04-26 05:08:32.000000000 +0200
+++ linux-2.6.23-rc9/include/linux/isdn.h	2007-10-08 16:23:43.000000000 +0200
@@ -389,7 +389,7 @@
 					  online                           */
   spinlock_t queue_lock;               /* lock to protect queue            */
   void *next;                          /* Pointer to next isdn-interface   */
-  struct net_device dev;               /* interface to upper levels        */
+  struct net_device *dev;              /* interface to upper levels        */
 #ifdef CONFIG_ISDN_PPP
   ippp_bundle * pb;		/* pointer to the common bundle structure
    			         * with the per-bundle data */



-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
