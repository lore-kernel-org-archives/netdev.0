From: Karsten Keil <kkeil@suse.de>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by ISDN
Date: Fri, 12 Oct 2007 16:05:22 +0200
Message-ID: <20071012140521.GA28413@pingi.kke.suse.de>
References: <20071007131723.GA22873@rhlx01.hs-esslingen.de> <20071007172037.GA29384@rhlx01.hs-esslingen.de> <20071008155836.GA19932@pingi.kke.suse.de> <20071008.203733.132907566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kkeil@suse.de, andi@lisas.de, jeff@garzik.org,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:44117 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683AbXJLOF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 10:05:26 -0400
Content-Disposition: inline
In-Reply-To: <20071008.203733.132907566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

a follow up to the previous patch for net-2.6.24.

On Mon, Oct 08, 2007 at 08:37:33PM -0700, David Miller wrote:
> > 
> > You could try following patch with 2.6.23-rc8-mm2, it change I4L to use
> > alloc_netdev().
> > 
> > Signed-off-by: Karsten Keil <kkeil@suse.de>
> 
> I've added this patch to net-2.6.24, thanks Karsten!

This is a followup to the previous ISDN alloc_netdev() patch.
It removes the local copy of the device name to make sure
that device renames work.

Signed-off-by: Karsten Keil <kkeil@suse.de>

diff -urNp linux-2.6.23.old/drivers/isdn/i4l/isdn_net.c linux-2.6.23/drivers/isdn/i4l/isdn_net.c
--- linux-2.6.23.old/drivers/isdn/i4l/isdn_net.c	2007-10-08 17:31:43.000000000 +0200
+++ linux-2.6.23/drivers/isdn/i4l/isdn_net.c	2007-10-12 13:43:50.000000000 +0200
@@ -328,7 +328,7 @@ isdn_net_autohup(void)
 			l->cps = (l->transcount * HZ) / (jiffies - last_jiffies);
 		l->transcount = 0;
 		if (dev->net_verbose > 3)
-			printk(KERN_DEBUG "%s: %d bogocps\n", l->name, l->cps);
+			printk(KERN_DEBUG "%s: %d bogocps\n", p->dev->name, l->cps);
 		if ((l->flags & ISDN_NET_CONNECTED) && (!l->dialstate)) {
 			anymore = 1;
 			l->huptimer++;
@@ -350,12 +350,12 @@ isdn_net_autohup(void)
 					if (l->hupflags & ISDN_CHARGEHUP) {
 						if (l->hupflags & ISDN_WAITCHARGE) {
 							printk(KERN_DEBUG "isdn_net: Hupflags of %s are %X\n",
-							       l->name, l->hupflags);
+							       p->dev->name, l->hupflags);
 							isdn_net_hangup(p->dev);
 						} else if (time_after(jiffies, l->chargetime + l->chargeint)) {
 							printk(KERN_DEBUG
 							       "isdn_net: %s: chtime = %lu, chint = %d\n",
-							       l->name, l->chargetime, l->chargeint);
+							       p->dev->name, l->chargetime, l->chargeint);
 							isdn_net_hangup(p->dev);
 						}
 					} else
@@ -442,8 +442,8 @@ isdn_net_stat_callback(int idx, isdn_ctr
 #endif
 					isdn_net_lp_disconnected(lp);
 					isdn_all_eaz(lp->isdn_device, lp->isdn_channel);
-					printk(KERN_INFO "%s: remote hangup\n", lp->name);
-					printk(KERN_INFO "%s: Chargesum is %d\n", lp->name,
+					printk(KERN_INFO "%s: remote hangup\n", p->dev->name);
+					printk(KERN_INFO "%s: Chargesum is %d\n", p->dev->name,
 					       lp->charge);
 					isdn_net_unbind_channel(lp);
 					return 1;
@@ -487,7 +487,7 @@ isdn_net_stat_callback(int idx, isdn_ctr
 								isdn_net_add_to_bundle(nd, lp);
 							}
 						}
-						printk(KERN_INFO "isdn_net: %s connected\n", lp->name);
+						printk(KERN_INFO "isdn_net: %s connected\n", p->dev->name);
 						/* If first Chargeinfo comes before B-Channel connect,
 						 * we correct the timestamp here.
 						 */
@@ -534,7 +534,7 @@ isdn_net_stat_callback(int idx, isdn_ctr
 					lp->hupflags |= ISDN_HAVECHARGE;
 				lp->chargetime = jiffies;
 				printk(KERN_DEBUG "isdn_net: Got CINF chargetime of %s now %lu\n",
-				       lp->name, lp->chargetime);
+				       p->dev->name, lp->chargetime);
 				return 1;
 		}
 	}
@@ -565,7 +565,7 @@ isdn_net_dial(void)
 
 #ifdef ISDN_DEBUG_NET_DIAL
 		if (lp->dialstate)
-			printk(KERN_DEBUG "%s: dialstate=%d\n", lp->name, lp->dialstate);
+			printk(KERN_DEBUG "%s: dialstate=%d\n", p->dev->name, lp->dialstate);
 #endif
 		switch (lp->dialstate) {
 			case 0:
@@ -578,7 +578,7 @@ isdn_net_dial(void)
 				lp->dial = lp->phone[1];
 				if (!lp->dial) {
 					printk(KERN_WARNING "%s: phone number deleted?\n",
-					       lp->name);
+					       p->dev->name);
 					isdn_net_hangup(p->dev);
 					break;
 				}
@@ -632,13 +632,13 @@ isdn_net_dial(void)
 				cmd.arg = lp->isdn_channel;
 				if (!lp->dial) {
 					printk(KERN_WARNING "%s: phone number deleted?\n",
-					       lp->name);
+					       p->dev->name);
 					isdn_net_hangup(p->dev);
 					break;
 				}
 				if (!strncmp(lp->dial->num, "LEASED", strlen("LEASED"))) {
 					lp->dialstate = 4;
-					printk(KERN_INFO "%s: Open leased line ...\n", lp->name);
+					printk(KERN_INFO "%s: Open leased line ...\n", p->dev->name);
 				} else {
 					if(lp->dialtimeout > 0)
 						if (time_after(jiffies, lp->dialstarted + lp->dialtimeout)) {
@@ -688,7 +688,7 @@ isdn_net_dial(void)
 						dev->usage[i] |= ISDN_USAGE_OUTGOING;
 						isdn_info_update();
 					}
-					printk(KERN_INFO "%s: dialing %d %s... %s\n", lp->name,
+					printk(KERN_INFO "%s: dialing %d %s... %s\n", p->dev->name,
 					       lp->dialretry, cmd.parm.setup.phone,
 					       (cmd.parm.setup.si1 == 1) ? "DOV" : "");
 					lp->dtimer = 0;
@@ -797,7 +797,7 @@ isdn_net_dial(void)
 				 */
 				if (lp->dtimer++ > lp->cbdelay)
 				{
-					printk(KERN_INFO "%s: hangup waiting for callback ...\n", lp->name);
+					printk(KERN_INFO "%s: hangup waiting for callback ...\n", p->dev->name);
 					lp->dtimer = 0;
 					lp->dialstate = 4;
 					cmd.driver = lp->isdn_device;
@@ -810,7 +810,7 @@ isdn_net_dial(void)
 				break;
 			default:
 				printk(KERN_WARNING "isdn_net: Illegal dialstate %d for device %s\n",
-				       lp->dialstate, lp->name);
+				       lp->dialstate, p->dev->name);
 		}
 		p = (isdn_net_dev *) p->next;
 	}
@@ -836,11 +836,11 @@ isdn_net_hangup(struct net_device *d)
 			if (slp->flags & ISDN_NET_CONNECTED) {
 				printk(KERN_INFO
 					"isdn_net: hang up slave %s before %s\n",
-					slp->name, lp->name);
+					lp->slave->name, d->name);
 				isdn_net_hangup(lp->slave);
 			}
 		}
-		printk(KERN_INFO "isdn_net: local hangup %s\n", lp->name);
+		printk(KERN_INFO "isdn_net: local hangup %s\n", d->name);
 #ifdef CONFIG_ISDN_PPP
 		if (lp->p_encap == ISDN_NET_ENCAP_SYNCPPP)
 			isdn_ppp_free(lp);
@@ -858,7 +858,7 @@ isdn_net_hangup(struct net_device *d)
 		cmd.command = ISDN_CMD_HANGUP;
 		cmd.arg = lp->isdn_channel;
 		isdn_command(&cmd);
-		printk(KERN_INFO "%s: Chargesum is %d\n", lp->name, lp->charge);
+		printk(KERN_INFO "%s: Chargesum is %d\n", d->name, lp->charge);
 		isdn_all_eaz(lp->isdn_device, lp->isdn_channel);
 	}
 	isdn_net_unbind_channel(lp);
@@ -885,7 +885,7 @@ isdn_net_log_skb(struct sk_buff * skb, i
 		/* fall back to old isdn_net_log_packet method() */
 		char * buf = skb->data;
 
-		printk(KERN_DEBUG "isdn_net: protocol %04x is buggy, dev %s\n", skb->protocol, lp->name);
+		printk(KERN_DEBUG "isdn_net: protocol %04x is buggy, dev %s\n", skb->protocol, lp->netdev->dev->name);
 		p = buf;
 		proto = ETH_P_IP;
 		switch (lp->p_encap) {
@@ -1023,7 +1023,7 @@ void isdn_net_writebuf_skb(isdn_net_loca
 	ret = isdn_writebuf_skb_stub(lp->isdn_device, lp->isdn_channel, 1, skb);
 	if (ret != len) {
 		/* we should never get here */
-		printk(KERN_WARNING "%s: HL driver queue full\n", lp->name);
+		printk(KERN_WARNING "%s: HL driver queue full\n", lp->netdev->dev->name);
 		goto error;
 	}
 	
@@ -1461,7 +1461,7 @@ isdn_ciscohdlck_dev_ioctl(struct net_dev
 				mod_timer(&lp->cisco_timer, expires);
 				printk(KERN_INFO "%s: Keepalive period set "
 					"to %d seconds.\n",
-					lp->name, lp->cisco_keepalive_period);
+					dev->name, lp->cisco_keepalive_period);
 			}
 			break;
 
@@ -1512,7 +1512,7 @@ isdn_net_ciscohdlck_slarp_send_keepalive
 		lp->cisco_line_state = 0;
 		printk (KERN_WARNING
 				"UPDOWN: Line protocol on Interface %s,"
-				" changed state to down\n", lp->name);
+				" changed state to down\n", lp->netdev->dev->name);
 		/* should stop routing higher-level data accross */
 	} else if ((!lp->cisco_line_state) &&
 		(myseq_diff >= 0) && (myseq_diff <= 2)) {
@@ -1520,14 +1520,14 @@ isdn_net_ciscohdlck_slarp_send_keepalive
 		lp->cisco_line_state = 1;
 		printk (KERN_WARNING
 				"UPDOWN: Line protocol on Interface %s,"
-				" changed state to up\n", lp->name);
+				" changed state to up\n", lp->netdev->dev->name);
 		/* restart routing higher-level data accross */
 	}
 
 	if (lp->cisco_debserint)
 		printk (KERN_DEBUG "%s: HDLC "
 			"myseq %lu, mineseen %lu%c, yourseen %lu, %s\n",
-			lp->name, last_cisco_myseq, lp->cisco_mineseen,
+			lp->netdev->dev->name, last_cisco_myseq, lp->cisco_mineseen,
 			((last_cisco_myseq == lp->cisco_mineseen) ? '*' : 040),
 			lp->cisco_yourseq,
 			((lp->cisco_line_state) ? "line up" : "line down"));
@@ -1682,7 +1682,7 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_lo
 			"remote ip: %d.%d.%d.%d, "
 			"local ip: %d.%d.%d.%d "
 			"mask: %d.%d.%d.%d\n",
-		       lp->name,
+		       lp->netdev->dev->name,
 		       HIPQUAD(addr),
 		       HIPQUAD(local),
 		       HIPQUAD(mask));
@@ -1690,7 +1690,7 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_lo
   slarp_reply_out:
 		 printk(KERN_INFO "%s: got invalid slarp "
 				 "reply (%d.%d.%d.%d/%d.%d.%d.%d) "
-				 "- ignored\n", lp->name,
+				 "- ignored\n", lp->netdev->dev->name,
 				 HIPQUAD(addr), HIPQUAD(mask));
 		break;
 	case CISCO_SLARP_KEEPALIVE:
@@ -1701,7 +1701,8 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_lo
 				lp->cisco_last_slarp_in) {
 			printk(KERN_DEBUG "%s: Keepalive period mismatch - "
 				"is %d but should be %d.\n",
-				lp->name, period, lp->cisco_keepalive_period);
+				lp->netdev->dev->name, period,
+				lp->cisco_keepalive_period);
 		}
 		lp->cisco_last_slarp_in = jiffies;
 		p += get_u32(p, &my_seq);
@@ -1732,12 +1733,12 @@ isdn_net_ciscohdlck_receive(isdn_net_loc
 	
 	if (addr != CISCO_ADDR_UNICAST && addr != CISCO_ADDR_BROADCAST) {
 		printk(KERN_WARNING "%s: Unknown Cisco addr 0x%02x\n",
-		       lp->name, addr);
+		       lp->netdev->dev->name, addr);
 		goto out_free;
 	}
 	if (ctrl != CISCO_CTRL) {
 		printk(KERN_WARNING "%s: Unknown Cisco ctrl 0x%02x\n",
-		       lp->name, ctrl);
+		       lp->netdev->dev->name, ctrl);
 		goto out_free;
 	}
 
@@ -1748,7 +1749,8 @@ isdn_net_ciscohdlck_receive(isdn_net_loc
 	case CISCO_TYPE_CDP:
 		if (lp->cisco_debserint)
 			printk(KERN_DEBUG "%s: Received CDP packet. use "
-				"\"no cdp enable\" on cisco.\n", lp->name);
+				"\"no cdp enable\" on cisco.\n",
+				lp->netdev->dev->name);
 		goto out_free;
 	default:
 		/* no special cisco protocol */
@@ -1843,7 +1845,7 @@ isdn_net_receive(struct net_device *ndev
 				};
 #endif /* CONFIG_ISDN_X25 */
 			printk(KERN_WARNING "%s: unknown encapsulation, dropping\n",
-			       lp->name);
+			       lp->netdev->dev->name);
 			kfree_skb(skb);
 			return;
 	}
@@ -2198,7 +2200,7 @@ isdn_net_find_icall(int di, int ch, int 
 			wret = matchret;
 #ifdef ISDN_DEBUG_NET_ICALL
 		printk(KERN_DEBUG "n_fi: if='%s', l.msn=%s, l.flags=%d, l.dstate=%d\n",
-		       lp->name, lp->msn, lp->flags, lp->dialstate);
+		       p->dev->name, lp->msn, lp->flags, lp->dialstate);
 #endif
 		if ((!matchret) &&                                        /* EAZ is matching   */
 		    (((!(lp->flags & ISDN_NET_CONNECTED)) &&              /* but not connected */
@@ -2301,7 +2303,7 @@ isdn_net_find_icall(int di, int ch, int 
 				 * */
 				if (ISDN_NET_DIALMODE(*lp) == ISDN_NET_DM_OFF) {
 					printk(KERN_INFO "incoming call, interface %s `stopped' -> rejected\n",
-					       lp->name);
+					       p->dev->name);
 					return 3;
 				}
 				/*
@@ -2310,7 +2312,7 @@ isdn_net_find_icall(int di, int ch, int 
 				 */
 				if (!isdn_net_device_started(p)) {
 					printk(KERN_INFO "%s: incoming call, interface down -> rejected\n",
-					       lp->name);
+					       p->dev->name);
 					return 3;
 				}
 				/* Interface is up, now see if it's a slave. If so, see if
@@ -2318,8 +2320,8 @@ isdn_net_find_icall(int di, int ch, int 
 				 */
 				if (lp->master) {
 					isdn_net_local *mlp = (isdn_net_local *) lp->master->priv;
-					printk(KERN_DEBUG "ICALLslv: %s\n", lp->name);
-					printk(KERN_DEBUG "master=%s\n", mlp->name);
+					printk(KERN_DEBUG "ICALLslv: %s\n", p->dev->name);
+					printk(KERN_DEBUG "master=%s\n", lp->master->name);
 					if (mlp->flags & ISDN_NET_CONNECTED) {
 						printk(KERN_DEBUG "master online\n");
 						/* Master is online, find parent-slave (master if first slave) */
@@ -2346,11 +2348,11 @@ isdn_net_find_icall(int di, int ch, int 
 					 * */
 					if (ISDN_NET_DIALMODE(*lp) == ISDN_NET_DM_OFF) {
 						printk(KERN_INFO "incoming call for callback, interface %s `off' -> rejected\n",
-						       lp->name);
+						       p->dev->name);
 						return 3;
 					}
 					printk(KERN_DEBUG "%s: call from %s -> %s, start callback\n",
-					       lp->name, nr, eaz);
+					       p->dev->name, nr, eaz);
 					if (lp->phone[1]) {
 						/* Grab a free ISDN-Channel */
 						spin_lock_irqsave(&dev->lock, flags);
@@ -2364,7 +2366,8 @@ isdn_net_find_icall(int di, int ch, int 
 						 		lp->msn)
 								) < 0) {
 
-							printk(KERN_WARNING "isdn_net_find_icall: No channel for %s\n", lp->name);
+							printk(KERN_WARNING "isdn_net_find_icall: No channel for %s\n",
+								p->dev->name);
 							spin_unlock_irqrestore(&dev->lock, flags);
 							return 0;
 						}
@@ -2385,11 +2388,12 @@ isdn_net_find_icall(int di, int ch, int 
 						/* Initiate dialing by returning 2 or 4 */
 						return (lp->flags & ISDN_NET_CBHUP) ? 2 : 4;
 					} else
-						printk(KERN_WARNING "isdn_net: %s: No phone number\n", lp->name);
+						printk(KERN_WARNING "isdn_net: %s: No phone number\n",
+							p->dev->name);
 					return 0;
 				} else {
-					printk(KERN_DEBUG "%s: call from %s -> %s accepted\n", lp->name, nr,
-					       eaz);
+					printk(KERN_DEBUG "%s: call from %s -> %s accepted\n",
+						p->dev->name, nr, eaz);
 					/* if this interface is dialing, it does it probably on a different
 					   device, so free this device */
 					if ((lp->dialstate == 4) || (lp->dialstate == 12)) {
@@ -2448,7 +2452,7 @@ isdn_net_findif(char *name)
 	isdn_net_dev *p = dev->netdev;
 
 	while (p) {
-		if (!strcmp(p->local->name, name))
+		if (!strcmp(p->dev->name, name))
 			return p;
 		p = (isdn_net_dev *) p->next;
 	}
@@ -2477,7 +2481,8 @@ isdn_net_force_dial_lp(isdn_net_local * 
 					lp->pre_device,
 					lp->pre_channel,
 					lp->msn)) < 0) {
-				printk(KERN_WARNING "isdn_net_force_dial: No channel for %s\n", lp->name);
+				printk(KERN_WARNING "isdn_net_force_dial: No channel for %s\n",
+					lp->netdev->dev->name);
 				spin_unlock_irqrestore(&dev->lock, flags);
 				return -EAGAIN;
 			}
@@ -2580,7 +2585,7 @@ isdn_net_new(char *name, struct net_devi
 		return NULL;
 	}
 	if (name == NULL)
-		name = "         ";
+		return NULL;
 	if (!(netdev = kzalloc(sizeof(isdn_net_dev), GFP_KERNEL))) {
 		printk(KERN_WARNING "isdn_net: Could not allocate net-device\n");
 		return NULL;
@@ -2592,7 +2597,6 @@ isdn_net_new(char *name, struct net_devi
 		return NULL;
 	}
 	netdev->local = netdev->dev->priv;
-	strcpy(netdev->local->name, netdev->dev->name);
 	netdev->dev->init = isdn_net_init;
 	if (master) {
 		/* Device shall be a slave */
@@ -2697,7 +2701,7 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg
 #endif
 			if (isdn_net_device_started(p)) {
 				printk(KERN_WARNING "%s: cannot change encap when if is up\n",
-				       lp->name);
+				       p->dev->name);
 				return -EBUSY;
 			}
 #ifdef CONFIG_ISDN_X25
@@ -2722,7 +2726,7 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg
 		case ISDN_NET_ENCAP_SYNCPPP:
 #ifndef CONFIG_ISDN_PPP
 			printk(KERN_WARNING "%s: SyncPPP support not configured\n",
-			       lp->name);
+			       p->dev->name);
 			return -EINVAL;
 #else
 			p->dev->type = ARPHRD_PPP;	/* change ARP type */
@@ -2749,7 +2753,7 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg
 				break;
 			printk(KERN_WARNING
 			       "%s: encapsulation protocol %d not supported\n",
-			       p->local->name, cfg->p_encap);
+			       p->dev->name, cfg->p_encap);
 			return -EINVAL;
 		}
 		if (strlen(cfg->drvid)) {
@@ -2933,13 +2937,18 @@ isdn_net_getcfg(isdn_net_ioctl_cfg * cfg
 		cfg->pppbind = lp->pppbind;
 		cfg->dialtimeout = lp->dialtimeout >= 0 ? lp->dialtimeout / HZ : -1;
 		cfg->dialwait = lp->dialwait / HZ;
-		if (lp->slave)
-			strcpy(cfg->slave, ((isdn_net_local *) lp->slave->priv)->name);
-		else
+		if (lp->slave) {
+			if (strlen(lp->slave->name) > 8)
+				strcpy(cfg->slave, "too-long");
+			else
+				strcpy(cfg->slave, lp->slave->name);
+		} else
 			cfg->slave[0] = '\0';
-		if (lp->master)
-			strcpy(cfg->master, ((isdn_net_local *) lp->master->priv)->name);
-		else
+		if (lp->master) {
+			if (strlen(lp->master->name) > 8)
+				strcpy(cfg->master, "too-long"); 
+			strcpy(cfg->master, lp->master->name);
+		} else
 			cfg->master[0] = '\0';
 		return 0;
 	}
@@ -3009,7 +3018,8 @@ isdn_net_getpeer(isdn_net_ioctl_phone *p
 	isdn_net_dev *p = isdn_net_findif(phone->name);
 	int ch, dv, idx;
 
-	if (!p) return -ENODEV;
+	if (!p)
+		return -ENODEV;
 	/*
 	 * Theoretical race: while this executes, the remote number might
 	 * become invalid (hang up) or change (new connection), resulting
@@ -3018,14 +3028,18 @@ isdn_net_getpeer(isdn_net_ioctl_phone *p
 	 */
 	ch = p->local->isdn_channel;
 	dv = p->local->isdn_device;
-	if(ch<0 && dv<0) return -ENOTCONN;
+	if(ch < 0 && dv < 0)
+		return -ENOTCONN;
 	idx = isdn_dc2minor(dv, ch);
-	if (idx<0) return -ENODEV;
+	if (idx <0 )
+		return -ENODEV;
 	/* for pre-bound channels, we need this extra check */
-	if ( strncmp(dev->num[idx],"???",3) == 0 ) return -ENOTCONN;
-	strncpy(phone->phone,dev->num[idx],ISDN_MSNLEN);
-	phone->outgoing=USG_OUTGOING(dev->usage[idx]);
-	if ( copy_to_user(peer,phone,sizeof(*peer)) ) return -EFAULT;
+	if (strncmp(dev->num[idx], "???", 3) == 0)
+		return -ENOTCONN;
+	strncpy(phone->phone, dev->num[idx], ISDN_MSNLEN);
+	phone->outgoing = USG_OUTGOING(dev->usage[idx]);
+	if (copy_to_user(peer, phone, sizeof(*peer)))
+		return -EFAULT;
 	return 0;
 }
 /*
@@ -3146,18 +3160,18 @@ isdn_net_realrm(isdn_net_dev * p, isdn_n
 		dev->netdev = p->next;
 	if (p->local->slave) {
 		/* If this interface has a slave, remove it also */
-		char *slavename = ((isdn_net_local *) (p->local->slave->priv))->name;
+		char *slavename = p->local->slave->name;
 		isdn_net_dev *n = dev->netdev;
 		q = NULL;
 		while (n) {
-			if (!strcmp(n->local->name, slavename)) {
+			if (!strcmp(n->dev->name, slavename)) {
 				spin_unlock_irqrestore(&dev->lock, flags);
 				isdn_net_realrm(n, q);
 				spin_lock_irqsave(&dev->lock, flags);
 				break;
 			}
 			q = n;
-			n = (isdn_net_dev *) n->next;
+			n = (isdn_net_dev *)n->next;
 		}
 	}
 	spin_unlock_irqrestore(&dev->lock, flags);
@@ -3185,7 +3199,7 @@ isdn_net_rm(char *name)
 	p = dev->netdev;
 	q = NULL;
 	while (p) {
-		if (!strcmp(p->local->name, name)) {
+		if (!strcmp(p->dev->name, name)) {
 			spin_unlock_irqrestore(&dev->lock, flags);
 			return (isdn_net_realrm(p, q));
 		}
diff -urNp linux-2.6.23.old/drivers/isdn/i4l/isdn_ppp.c linux-2.6.23/drivers/isdn/i4l/isdn_ppp.c
--- linux-2.6.23.old/drivers/isdn/i4l/isdn_ppp.c	2007-10-08 17:42:06.000000000 +0200
+++ linux-2.6.23/drivers/isdn/i4l/isdn_ppp.c	2007-10-12 13:51:17.000000000 +0200
@@ -190,9 +190,11 @@ isdn_ppp_bind(isdn_net_local * lp)
 		retval = -1;
 		goto out;
 	}
-	unit = isdn_ppp_if_get_unit(lp->name);	/* get unit number from interface name .. ugly! */
+	/* get unit number from interface name .. ugly! */
+	unit = isdn_ppp_if_get_unit(lp->netdev->dev->name);
 	if (unit < 0) {
-		printk(KERN_ERR "isdn_ppp_bind: illegal interface name %s.\n", lp->name);
+		printk(KERN_ERR "isdn_ppp_bind: illegal interface name %s.\n",
+			lp->netdev->dev->name);
 		retval = -1;
 		goto out;
 	}
@@ -507,7 +509,8 @@ isdn_ppp_ioctl(int min, struct file *fil
 		case PPPIOCGIFNAME:
 			if(!lp)
 				return -EINVAL;
-			if ((r = set_arg(argp, lp->name, strlen(lp->name))))
+			if ((r = set_arg(argp, lp->netdev->dev->name,
+				strlen(lp->netdev->dev->name))))
 				return r;
 			break;
 		case PPPIOCGMPFLAGS:	/* get configuration flags */
diff -urNp linux-2.6.23.old/include/linux/isdn.h linux-2.6.23/include/linux/isdn.h
--- linux-2.6.23.old/include/linux/isdn.h	2007-10-08 16:23:43.000000000 +0200
+++ linux-2.6.23/include/linux/isdn.h	2007-10-12 13:06:04.000000000 +0200
@@ -286,7 +286,6 @@ typedef struct {
 /* Local interface-data */
 typedef struct isdn_net_local_s {
   ulong                  magic;
-  char                   name[10];     /* Name of device                   */
   struct net_device_stats stats;       /* Ethernet Statistics              */
   int                    isdn_device;  /* Index to isdn-device             */
   int                    isdn_channel; /* Index to isdn-channel            */

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
