From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Thu, 07 Jul 2005 15:24:17 -0700 (PDT)
Message-ID: <20050707.152417.59653729.davem@davemloft.net>
References: <20050706124206.GW16076@postel.suug.ch>
	<20050707.141718.85410359.davem@davemloft.net>
	<20050707213450.GB16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050707213450.GB16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 7 Jul 2005 23:34:50 +0200

> Since I'm changing the classful qdiscs to use a generic API
> for queue management anyway I could take care of this if you want.
> WRT the leaf qdiscs it's a bit more complicated since we have
> to change the new API to take a new struct which includes the qlen
> and the sk_buff_head but not a problem either.

Ok.  I'm going to check something like the following into
my tree.  It takes care of the obvious cases of direct
binary test of queue length being zero vs. non-zero.

This uncovered some seriously questionable stuff along the way.

For example, take a look at drivers/usb/net/usbnet.c:usbnet_stop().
That code seems to want to wait until all the SKB queues are empty,
but the way it is coded it only waits if all the queues have at least
one packet.

I preserved the behavior there, but if someone could verify my
analysis and post a bug fix, I'd really appreciate it.

Thanks.

diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -120,7 +120,7 @@ static unsigned int hci_vhci_chr_poll(st
 
 	poll_wait(file, &hci_vhci->read_wait, wait);
  
-	if (skb_queue_len(&hci_vhci->readq))
+	if (!skb_queue_empty(&hci_vhci->readq))
 		return POLLIN | POLLRDNORM;
 
 	return POLLOUT | POLLWRNORM;
diff --git a/drivers/isdn/hisax/isdnl1.c b/drivers/isdn/hisax/isdnl1.c
--- a/drivers/isdn/hisax/isdnl1.c
+++ b/drivers/isdn/hisax/isdnl1.c
@@ -279,7 +279,8 @@ BChannel_proc_xmt(struct BCState *bcs)
 	if (test_and_clear_bit(FLG_L1_PULL_REQ, &st->l1.Flags))
 		st->l1.l1l2(st, PH_PULL | CONFIRM, NULL);
 	if (!test_bit(BC_FLG_ACTIV, &bcs->Flag)) {
-		if (!test_bit(BC_FLG_BUSY, &bcs->Flag) && (!skb_queue_len(&bcs->squeue))) {
+		if (!test_bit(BC_FLG_BUSY, &bcs->Flag) &&
+		    skb_queue_empty(&bcs->squeue)) {
 			st->l2.l2l1(st, PH_DEACTIVATE | CONFIRM, NULL);
 		}
 	}
diff --git a/drivers/isdn/hisax/isdnl2.c b/drivers/isdn/hisax/isdnl2.c
--- a/drivers/isdn/hisax/isdnl2.c
+++ b/drivers/isdn/hisax/isdnl2.c
@@ -108,7 +108,8 @@ static int l2addrsize(struct Layer2 *l2)
 static void
 set_peer_busy(struct Layer2 *l2) {
 	test_and_set_bit(FLG_PEER_BUSY, &l2->flag);
-	if (skb_queue_len(&l2->i_queue) || skb_queue_len(&l2->ui_queue))
+	if (!skb_queue_empty(&l2->i_queue) ||
+	    !skb_queue_empty(&l2->ui_queue))
 		test_and_set_bit(FLG_L2BLOCK, &l2->flag);
 }
 
@@ -754,7 +755,7 @@ l2_restart_multi(struct FsmInst *fi, int
 		st->l2.l2l3(st, DL_ESTABLISH | INDICATION, NULL);
 
 	if ((ST_L2_7==state) || (ST_L2_8 == state))
-		if (skb_queue_len(&st->l2.i_queue) && cansend(st))
+		if (!skb_queue_empty(&st->l2.i_queue) && cansend(st))
 			st->l2.l2l1(st, PH_PULL | REQUEST, NULL);
 }
 
@@ -810,7 +811,7 @@ l2_connected(struct FsmInst *fi, int eve
 	if (pr != -1)
 		st->l2.l2l3(st, pr, NULL);
 
-	if (skb_queue_len(&st->l2.i_queue) && cansend(st))
+	if (!skb_queue_empty(&st->l2.i_queue) && cansend(st))
 		st->l2.l2l1(st, PH_PULL | REQUEST, NULL);
 }
 
@@ -1014,7 +1015,7 @@ l2_st7_got_super(struct FsmInst *fi, int
 			if(typ != RR) FsmDelTimer(&st->l2.t203, 9);
 			restart_t200(st, 12);
 		}
-		if (skb_queue_len(&st->l2.i_queue) && (typ == RR))
+		if (!skb_queue_empty(&st->l2.i_queue) && (typ == RR))
 			st->l2.l2l1(st, PH_PULL | REQUEST, NULL);
 	} else
 		nrerrorrecovery(fi);
@@ -1120,7 +1121,7 @@ l2_got_iframe(struct FsmInst *fi, int ev
 		return;
 	}
 
-	if (skb_queue_len(&st->l2.i_queue) && (fi->state == ST_L2_7))
+	if (!skb_queue_empty(&st->l2.i_queue) && (fi->state == ST_L2_7))
 		st->l2.l2l1(st, PH_PULL | REQUEST, NULL);
 	if (test_and_clear_bit(FLG_ACK_PEND, &st->l2.flag))
 		enquiry_cr(st, RR, RSP, 0);
@@ -1138,7 +1139,7 @@ l2_got_tei(struct FsmInst *fi, int event
 		test_and_set_bit(FLG_L3_INIT, &st->l2.flag);
 	} else
 		FsmChangeState(fi, ST_L2_4);
-	if (skb_queue_len(&st->l2.ui_queue))
+	if (!skb_queue_empty(&st->l2.ui_queue))
 		tx_ui(st);
 }
 
@@ -1301,7 +1302,7 @@ l2_pull_iqueue(struct FsmInst *fi, int e
 		FsmDelTimer(&st->l2.t203, 13);
 		FsmAddTimer(&st->l2.t200, st->l2.T200, EV_L2_T200, NULL, 11);
 	}
-	if (skb_queue_len(&l2->i_queue) && cansend(st))
+	if (!skb_queue_empty(&l2->i_queue) && cansend(st))
 		st->l2.l2l1(st, PH_PULL | REQUEST, NULL);
 }
 
@@ -1347,7 +1348,7 @@ l2_st8_got_super(struct FsmInst *fi, int
 			}
 			invoke_retransmission(st, nr);
 			FsmChangeState(fi, ST_L2_7);
-			if (skb_queue_len(&l2->i_queue) && cansend(st))
+			if (!skb_queue_empty(&l2->i_queue) && cansend(st))
 				st->l2.l2l1(st, PH_PULL | REQUEST, NULL);
 		} else
 			nrerrorrecovery(fi);
diff --git a/drivers/isdn/hisax/isdnl3.c b/drivers/isdn/hisax/isdnl3.c
--- a/drivers/isdn/hisax/isdnl3.c
+++ b/drivers/isdn/hisax/isdnl3.c
@@ -302,7 +302,7 @@ release_l3_process(struct l3_process *p)
 				!test_bit(FLG_PTP, &p->st->l2.flag)) {
 				if (p->debug)
 					l3_debug(p->st, "release_l3_process: last process");
-				if (!skb_queue_len(&p->st->l3.squeue)) {
+				if (skb_queue_empty(&p->st->l3.squeue)) {
 					if (p->debug)
 						l3_debug(p->st, "release_l3_process: release link");
 					if (p->st->protocol != ISDN_PTYPE_NI1)
diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1223,7 +1223,7 @@ isdn_tty_write(struct tty_struct *tty, c
 		total += c;
 	}
 	atomic_dec(&info->xmit_lock);
-	if ((info->xmit_count) || (skb_queue_len(&info->xmit_queue))) {
+	if ((info->xmit_count) || !skb_queue_empty(&info->xmit_queue)) {
 		if (m->mdmreg[REG_DXMT] & BIT_DXMT) {
 			isdn_tty_senddown(info);
 			isdn_tty_tint(info);
@@ -1284,7 +1284,7 @@ isdn_tty_flush_chars(struct tty_struct *
 
 	if (isdn_tty_paranoia_check(info, tty->name, "isdn_tty_flush_chars"))
 		return;
-	if ((info->xmit_count) || (skb_queue_len(&info->xmit_queue)))
+	if ((info->xmit_count) || !skb_queue_empty(&info->xmit_queue))
 		isdn_timer_ctrl(ISDN_TIMER_MODEMXMIT, 1);
 }
 
diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
--- a/drivers/isdn/icn/icn.c
+++ b/drivers/isdn/icn/icn.c
@@ -304,12 +304,12 @@ icn_pollbchan_send(int channel, icn_card
 	isdn_ctrl cmd;
 
 	if (!(card->sndcount[channel] || card->xskb[channel] ||
-	      skb_queue_len(&card->spqueue[channel])))
+	      !skb_queue_empty(&card->spqueue[channel])))
 		return;
 	if (icn_trymaplock_channel(card, mch)) {
 		while (sbfree && 
 		       (card->sndcount[channel] ||
-			skb_queue_len(&card->spqueue[channel]) ||
+			!skb_queue_empty(&card->spqueue[channel]) ||
 			card->xskb[channel])) {
 			spin_lock_irqsave(&card->lock, flags);
 			if (card->xmit_lock[channel]) {
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -304,7 +304,7 @@ static inline void scc_discard_buffers(s
 		scc->tx_buff = NULL;
 	}
 	
-	while (skb_queue_len(&scc->tx_queue))
+	while (!skb_queue_empty(&scc->tx_queue))
 		dev_kfree_skb(skb_dequeue(&scc->tx_queue));
 
 	spin_unlock_irqrestore(&scc->lock, flags);
@@ -1126,8 +1126,7 @@ static void t_dwait(unsigned long channe
 	
 	if (scc->stat.tx_state == TXS_WAIT)	/* maxkeyup or idle timeout */
 	{
-		if (skb_queue_len(&scc->tx_queue) == 0)	/* nothing to send */
-		{
+		if (skb_queue_empty(&scc->tx_queue)) {	/* nothing to send */
 			scc->stat.tx_state = TXS_IDLE;
 			netif_wake_queue(scc->dev);	/* t_maxkeyup locked it. */
 			return;
diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -364,7 +364,7 @@ ppp_asynctty_receive(struct tty_struct *
 	spin_lock_irqsave(&ap->recv_lock, flags);
 	ppp_async_input(ap, buf, cflags, count);
 	spin_unlock_irqrestore(&ap->recv_lock, flags);
-	if (skb_queue_len(&ap->rqueue))
+	if (!skb_queue_empty(&ap->rqueue))
 		tasklet_schedule(&ap->tsk);
 	ap_put(ap);
 	if (test_and_clear_bit(TTY_THROTTLED, &tty->flags)
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1237,8 +1237,8 @@ static int ppp_mp_explode(struct ppp *pp
 		pch = list_entry(list, struct channel, clist);
 		navail += pch->avail = (pch->chan != NULL);
 		if (pch->avail) {
-			if (skb_queue_len(&pch->file.xq) == 0
-			    || !pch->had_frag) {
+			if (skb_queue_empty(&pch->file.xq) ||
+			    !pch->had_frag) {
 				pch->avail = 2;
 				++nfree;
 			}
@@ -1374,8 +1374,8 @@ static int ppp_mp_explode(struct ppp *pp
 
 		/* try to send it down the channel */
 		chan = pch->chan;
-		if (skb_queue_len(&pch->file.xq)
-		    || !chan->ops->start_xmit(chan, frag))
+		if (!skb_queue_empty(&pch->file.xq) ||
+		    !chan->ops->start_xmit(chan, frag))
 			skb_queue_tail(&pch->file.xq, frag);
 		pch->had_frag = 1;
 		p += flen;
@@ -1412,7 +1412,7 @@ ppp_channel_push(struct channel *pch)
 
 	spin_lock_bh(&pch->downl);
 	if (pch->chan != 0) {
-		while (skb_queue_len(&pch->file.xq) > 0) {
+		while (!skb_queue_empty(&pch->file.xq)) {
 			skb = skb_dequeue(&pch->file.xq);
 			if (!pch->chan->ops->start_xmit(pch->chan, skb)) {
 				/* put the packet back and try again later */
@@ -1426,7 +1426,7 @@ ppp_channel_push(struct channel *pch)
 	}
 	spin_unlock_bh(&pch->downl);
 	/* see if there is anything from the attached unit to be sent */
-	if (skb_queue_len(&pch->file.xq) == 0) {
+	if (skb_queue_empty(&pch->file.xq)) {
 		read_lock_bh(&pch->upl);
 		ppp = pch->ppp;
 		if (ppp != 0)
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -406,7 +406,7 @@ ppp_sync_receive(struct tty_struct *tty,
 	spin_lock_irqsave(&ap->recv_lock, flags);
 	ppp_sync_input(ap, buf, cflags, count);
 	spin_unlock_irqrestore(&ap->recv_lock, flags);
-	if (skb_queue_len(&ap->rqueue))
+	if (!skb_queue_empty(&ap->rqueue))
 		tasklet_schedule(&ap->tsk);
 	sp_put(ap);
 	if (test_and_clear_bit(TTY_THROTTLED, &tty->flags)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -215,7 +215,7 @@ static unsigned int tun_chr_poll(struct 
 
 	poll_wait(file, &tun->read_wait, wait);
  
-	if (skb_queue_len(&tun->readq))
+	if (!skb_queue_empty(&tun->readq))
 		mask |= POLLIN | POLLRDNORM;
 
 	return mask;
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2374,7 +2374,7 @@ void stop_airo_card( struct net_device *
 	/*
 	 * Clean out tx queue
 	 */
-	if (test_bit(FLAG_MPI, &ai->flags) && skb_queue_len (&ai->txq) > 0) {
+	if (test_bit(FLAG_MPI, &ai->flags) && !skb_queue_empty(&ai->txq)) {
 		struct sk_buff *skb = NULL;
 		for (;(skb = skb_dequeue(&ai->txq));)
 			dev_kfree_skb(skb);
@@ -3287,7 +3287,7 @@ exitrx:
 				if (status & EV_TXEXC)
 					get_tx_error(apriv, -1);
 				spin_lock_irqsave(&apriv->aux_lock, flags);
-				if (skb_queue_len (&apriv->txq)) {
+				if (!skb_queue_empty(&apriv->txq)) {
 					spin_unlock_irqrestore(&apriv->aux_lock,flags);
 					mpi_send_packet (dev);
 				} else {
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -428,7 +428,7 @@ claw_pack_skb(struct claw_privbk *privpt
 	new_skb = NULL;		/* assume no dice */
 	pkt_cnt = 0;
 	CLAW_DBF_TEXT(4,trace,"PackSKBe");
-	if (skb_queue_len(&p_ch->collect_queue) > 0) {
+	if (!skb_queue_empty(&p_ch->collect_queue)) {
 	/* some data */
 		held_skb = skb_dequeue(&p_ch->collect_queue);
 		if (p_env->packing != DO_PACKED)
@@ -1254,7 +1254,7 @@ claw_write_next ( struct chbk * p_ch )
 	privptr = (struct claw_privbk *) dev->priv;
         claw_free_wrt_buf( dev );
 	if ((privptr->write_free_count > 0) &&
-	    (skb_queue_len(&p_ch->collect_queue) > 0)) {
+	    !skb_queue_empty(&p_ch->collect_queue)) {
 	  	pk_skb = claw_pack_skb(privptr);
 		while (pk_skb != NULL) {
 			rc = claw_hw_tx( pk_skb, dev,1);
diff --git a/drivers/s390/net/ctctty.c b/drivers/s390/net/ctctty.c
--- a/drivers/s390/net/ctctty.c
+++ b/drivers/s390/net/ctctty.c
@@ -156,7 +156,7 @@ ctc_tty_readmodem(ctc_tty_info *info)
 					skb_queue_head(&info->rx_queue, skb);
 				else {
 					kfree_skb(skb);
-					ret = skb_queue_len(&info->rx_queue);
+					ret = !skb_queue_empty(&info->rx_queue);
 				}
 			}
 		}
@@ -530,7 +530,7 @@ ctc_tty_write(struct tty_struct *tty, co
 		total += c;
 		count -= c;
 	}
-	if (skb_queue_len(&info->tx_queue)) {
+	if (!skb_queue_empty(&info->tx_queue)) {
 		info->lsr &= ~UART_LSR_TEMT;
 		tasklet_schedule(&info->tasklet);
 	}
@@ -594,7 +594,7 @@ ctc_tty_flush_chars(struct tty_struct *t
 		return;
 	if (ctc_tty_paranoia_check(info, tty->name, "ctc_tty_flush_chars"))
 		return;
-	if (tty->stopped || tty->hw_stopped || (!skb_queue_len(&info->tx_queue)))
+	if (tty->stopped || tty->hw_stopped || skb_queue_empty(&info->tx_queue))
 		return;
 	tasklet_schedule(&info->tasklet);
 }
diff --git a/drivers/usb/net/usbnet.c b/drivers/usb/net/usbnet.c
--- a/drivers/usb/net/usbnet.c
+++ b/drivers/usb/net/usbnet.c
@@ -3227,9 +3227,9 @@ static int usbnet_stop (struct net_devic
 	temp = unlink_urbs (dev, &dev->txq) + unlink_urbs (dev, &dev->rxq);
 
 	// maybe wait for deletions to finish.
-	while (skb_queue_len (&dev->rxq)
-			&& skb_queue_len (&dev->txq)
-			&& skb_queue_len (&dev->done)) {
+	while (!skb_queue_empty(&dev->rxq) &&
+	       !skb_queue_empty(&dev->txq) &&
+	       !skb_queue_empty(&dev->done)) {
 		msleep(UNLINK_TIMEOUT_MS);
 		if (netif_msg_ifdown (dev))
 			devdbg (dev, "waited for %d urb completions", temp);
diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -224,7 +224,7 @@ int  irda_device_is_receiving(struct net
 /* Interface for internal use */
 static inline int irda_device_txqueue_empty(const struct net_device *dev)
 {
-	return (skb_queue_len(&dev->qdisc->q) == 0);
+	return skb_queue_empty(&dev->qdisc->q);
 }
 int  irda_device_set_raw_mode(struct net_device* self, int status);
 struct net_device *alloc_irdadev(int sizeof_priv);
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -991,7 +991,7 @@ static __inline__ void tcp_fast_path_on(
 
 static inline void tcp_fast_path_check(struct sock *sk, struct tcp_sock *tp)
 {
-	if (skb_queue_len(&tp->out_of_order_queue) == 0 &&
+	if (skb_queue_empty(&tp->out_of_order_queue) &&
 	    tp->rcv_wnd &&
 	    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf &&
 	    !tp->urg_data)
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -213,7 +213,7 @@ static int cmtp_send_frame(struct cmtp_s
 	return kernel_sendmsg(sock, &msg, &iv, 1, len);
 }
 
-static int cmtp_process_transmit(struct cmtp_session *session)
+static void cmtp_process_transmit(struct cmtp_session *session)
 {
 	struct sk_buff *skb, *nskb;
 	unsigned char *hdr;
@@ -223,7 +223,7 @@ static int cmtp_process_transmit(struct 
 
 	if (!(nskb = alloc_skb(session->mtu, GFP_ATOMIC))) {
 		BT_ERR("Can't allocate memory for new frame");
-		return -ENOMEM;
+		return;
 	}
 
 	while ((skb = skb_dequeue(&session->transmit))) {
@@ -275,8 +275,6 @@ static int cmtp_process_transmit(struct 
 	cmtp_send_frame(session, nskb->data, nskb->len);
 
 	kfree_skb(nskb);
-
-	return skb_queue_len(&session->transmit);
 }
 
 static int cmtp_session(void *arg)
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -428,7 +428,7 @@ static int hidp_send_frame(struct socket
 	return kernel_sendmsg(sock, &msg, &iv, 1, len);
 }
 
-static int hidp_process_transmit(struct hidp_session *session)
+static void hidp_process_transmit(struct hidp_session *session)
 {
 	struct sk_buff *skb;
 
@@ -453,9 +453,6 @@ static int hidp_process_transmit(struct 
 		hidp_set_timer(session);
 		kfree_skb(skb);
 	}
-
-	return skb_queue_len(&session->ctrl_transmit) +
-				skb_queue_len(&session->intr_transmit);
 }
 
 static int hidp_session(void *arg)
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -590,8 +590,11 @@ static long rfcomm_sock_data_wait(struct
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
 
-		if (skb_queue_len(&sk->sk_receive_queue) || sk->sk_err || (sk->sk_shutdown & RCV_SHUTDOWN) ||
-				signal_pending(current) || !timeo)
+		if (!skb_queue_empty(&sk->sk_receive_queue) ||
+		    sk->sk_err ||
+		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
+		    signal_pending(current) ||
+		    !timeo)
 			break;
 
 		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -781,7 +781,7 @@ static int rfcomm_tty_chars_in_buffer(st
 
 	BT_DBG("tty %p dev %p", tty, dev);
 
-	if (skb_queue_len(&dlc->tx_queue))
+	if (!skb_queue_empty(&dlc->tx_queue))
 		return dlc->mtu;
 
 	return 0;
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -536,7 +536,7 @@ static void dn_keepalive(struct sock *sk
 	 * we are double checking that we are not sending too
 	 * many of these keepalive frames.
 	 */
-	if (skb_queue_len(&scp->other_xmit_queue) == 0)
+	if (skb_queue_empty(&scp->other_xmit_queue))
 		dn_nsp_send_link(sk, DN_NOCHANGE, 0);
 }
 
@@ -1191,7 +1191,7 @@ static unsigned int dn_poll(struct file 
 	struct dn_scp *scp = DN_SK(sk);
 	int mask = datagram_poll(file, sock, wait);
 
-	if (skb_queue_len(&scp->other_receive_queue))
+	if (!skb_queue_empty(&scp->other_receive_queue))
 		mask |= POLLRDBAND;
 
 	return mask;
@@ -1214,7 +1214,7 @@ static int dn_ioctl(struct socket *sock,
 
 	case SIOCATMARK:
 		lock_sock(sk);
-		val = (skb_queue_len(&scp->other_receive_queue) != 0);
+		val = !skb_queue_empty(&scp->other_receive_queue);
 		if (scp->state != DN_RUN)
 			val = -ENOTCONN;
 		release_sock(sk);
@@ -1630,7 +1630,7 @@ static int dn_data_ready(struct sock *sk
 	int len = 0;
 
 	if (flags & MSG_OOB)
-		return skb_queue_len(q) ? 1 : 0;
+		return !skb_queue_empty(q) ? 1 : 0;
 
 	while(skb != (struct sk_buff *)q) {
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
@@ -1707,7 +1707,7 @@ static int dn_recvmsg(struct kiocb *iocb
 		if (sk->sk_err)
 			goto out;
 
-		if (skb_queue_len(&scp->other_receive_queue)) {
+		if (!skb_queue_empty(&scp->other_receive_queue)) {
 			if (!(flags & MSG_OOB)) {
 				msg->msg_flags |= MSG_OOB;
 				if (!scp->other_report) {
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -342,7 +342,8 @@ int dn_nsp_xmit_timeout(struct sock *sk)
 
 	dn_nsp_output(sk);
 
-	if (skb_queue_len(&scp->data_xmit_queue) || skb_queue_len(&scp->other_xmit_queue))
+	if (!skb_queue_empty(&scp->data_xmit_queue) ||
+	    !skb_queue_empty(&scp->other_xmit_queue))
 		scp->persist = dn_nsp_persist(sk);
 
 	return 0;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1105,7 +1105,7 @@ static void tcp_prequeue_process(struct 
 	struct sk_buff *skb;
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	NET_ADD_STATS_USER(LINUX_MIB_TCPPREQUEUED, skb_queue_len(&tp->ucopy.prequeue));
+	NET_INC_STATS_USER(LINUX_MIB_TCPPREQUEUED);
 
 	/* RX process wants to run with disabled BHs, though it is not
 	 * necessary */
@@ -1369,7 +1369,7 @@ int tcp_recvmsg(struct kiocb *iocb, stru
 			 * is not empty. It is more elegant, but eats cycles,
 			 * unfortunately.
 			 */
-			if (skb_queue_len(&tp->ucopy.prequeue))
+			if (!skb_queue_empty(&tp->ucopy.prequeue))
 				goto do_prequeue;
 
 			/* __ Set realtime policy in scheduler __ */
@@ -1394,7 +1394,7 @@ int tcp_recvmsg(struct kiocb *iocb, stru
 			}
 
 			if (tp->rcv_nxt == tp->copied_seq &&
-			    skb_queue_len(&tp->ucopy.prequeue)) {
+			    !skb_queue_empty(&tp->ucopy.prequeue)) {
 do_prequeue:
 				tcp_prequeue_process(sk);
 
@@ -1476,7 +1476,7 @@ skip_copy:
 	} while (len > 0);
 
 	if (user_recv) {
-		if (skb_queue_len(&tp->ucopy.prequeue)) {
+		if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 			int chunk;
 
 			tp->ucopy.len = copied > 0 ? len : 0;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2802,7 +2802,7 @@ static void tcp_sack_remove(struct tcp_s
 	int this_sack;
 
 	/* Empty ofo queue, hence, all the SACKs are eaten. Clear. */
-	if (skb_queue_len(&tp->out_of_order_queue) == 0) {
+	if (skb_queue_empty(&tp->out_of_order_queue)) {
 		tp->rx_opt.num_sacks = 0;
 		tp->rx_opt.eff_sacks = tp->rx_opt.dsack;
 		return;
@@ -2935,13 +2935,13 @@ queue_and_out:
 		if(th->fin)
 			tcp_fin(skb, sk, th);
 
-		if (skb_queue_len(&tp->out_of_order_queue)) {
+		if (!skb_queue_empty(&tp->out_of_order_queue)) {
 			tcp_ofo_queue(sk);
 
 			/* RFC2581. 4.2. SHOULD send immediate ACK, when
 			 * gap in queue is filled.
 			 */
-			if (!skb_queue_len(&tp->out_of_order_queue))
+			if (skb_queue_empty(&tp->out_of_order_queue))
 				tp->ack.pingpong = 0;
 		}
 
@@ -3249,9 +3249,8 @@ static int tcp_prune_queue(struct sock *
 	 * This must not ever occur. */
 
 	/* First, purge the out_of_order queue. */
-	if (skb_queue_len(&tp->out_of_order_queue)) {
-		NET_ADD_STATS_BH(LINUX_MIB_OFOPRUNED, 
-				 skb_queue_len(&tp->out_of_order_queue));
+	if (!skb_queue_empty(&tp->out_of_order_queue)) {
+		NET_INC_STATS_BH(LINUX_MIB_OFOPRUNED);
 		__skb_queue_purge(&tp->out_of_order_queue);
 
 		/* Reset SACK state.  A conforming SACK implementation will
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -231,11 +231,10 @@ static void tcp_delack_timer(unsigned lo
 	}
 	tp->ack.pending &= ~TCP_ACK_TIMER;
 
-	if (skb_queue_len(&tp->ucopy.prequeue)) {
+	if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 		struct sk_buff *skb;
 
-		NET_ADD_STATS_BH(LINUX_MIB_TCPSCHEDULERFAILED, 
-				 skb_queue_len(&tp->ucopy.prequeue));
+		NET_INC_STATS_BH(LINUX_MIB_TCPSCHEDULERFAILED);
 
 		while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
 			sk->sk_backlog_rcv(sk, skb);
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -445,9 +445,8 @@ void irlap_disconnect_request(struct irl
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Don't disconnect until all data frames are successfully sent */
-	if (skb_queue_len(&self->txq) > 0) {
+	if (!skb_queue_empty(&self->txq)) {
 		self->disconnect_pending = TRUE;
-
 		return;
 	}
 
diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -191,7 +191,7 @@ static void irlap_start_poll_timer(struc
 	 * Send out the RR frames faster if our own transmit queue is empty, or
 	 * if the peer is busy. The effect is a much faster conversation
 	 */
-	if ((skb_queue_len(&self->txq) == 0) || (self->remote_busy)) {
+	if (skb_queue_empty(&self->txq) || self->remote_busy) {
 		if (self->fast_RR == TRUE) {
 			/*
 			 *  Assert that the fast poll timer has not reached the
@@ -263,7 +263,7 @@ void irlap_do_event(struct irlap_cb *sel
 		IRDA_DEBUG(2, "%s() : queue len = %d\n", __FUNCTION__,
 			   skb_queue_len(&self->txq));
 
-		if (skb_queue_len(&self->txq)) {
+		if (!skb_queue_empty(&self->txq)) {
 			/* Prevent race conditions with irlap_data_request() */
 			self->local_busy = TRUE;
 
@@ -1074,7 +1074,7 @@ static int irlap_state_xmit_p(struct irl
 #else	/* CONFIG_IRDA_DYNAMIC_WINDOW */
 			/* Window has been adjusted for the max packet
 			 * size, so much simpler... - Jean II */
-			nextfit = (skb_queue_len(&self->txq) > 0);
+			nextfit = !skb_queue_empty(&self->txq);
 #endif	/* CONFIG_IRDA_DYNAMIC_WINDOW */
 			/*
 			 *  Send data with poll bit cleared only if window > 1
@@ -1814,7 +1814,7 @@ static int irlap_state_xmit_s(struct irl
 #else	/* CONFIG_IRDA_DYNAMIC_WINDOW */
 			/* Window has been adjusted for the max packet
 			 * size, so much simpler... - Jean II */
-			nextfit = (skb_queue_len(&self->txq) > 0);
+			nextfit = !skb_queue_empty(&self->txq);
 #endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
 			/*
 			 *  Send data with final bit cleared only if window > 1
@@ -1937,7 +1937,7 @@ static int irlap_state_nrm_s(struct irla
 				irlap_data_indication(self, skb, FALSE);
 
 				/* Any pending data requests?  */
-				if ((skb_queue_len(&self->txq) > 0) &&
+				if (!skb_queue_empty(&self->txq) &&
 				    (self->window > 0))
 				{
 					self->ack_required = TRUE;
@@ -2038,7 +2038,7 @@ static int irlap_state_nrm_s(struct irla
 			/*
 			 *  Any pending data requests?
 			 */
-			if ((skb_queue_len(&self->txq) > 0) &&
+			if (!skb_queue_empty(&self->txq) &&
 			    (self->window > 0) && !self->remote_busy)
 			{
 				irlap_data_indication(self, skb, TRUE);
@@ -2069,7 +2069,7 @@ static int irlap_state_nrm_s(struct irla
 		 */
 		nr_status = irlap_validate_nr_received(self, info->nr);
 		if (nr_status == NR_EXPECTED) {
-			if ((skb_queue_len( &self->txq) > 0) &&
+			if (!skb_queue_empty(&self->txq) &&
 			    (self->window > 0)) {
 				self->remote_busy = FALSE;
 
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -1018,11 +1018,10 @@ void irlap_resend_rejected_frames(struct
 	/*
 	 *  We can now fill the window with additional data frames
 	 */
-	while (skb_queue_len( &self->txq) > 0) {
+	while (!skb_queue_empty(&self->txq)) {
 
 		IRDA_DEBUG(0, "%s(), sending additional frames!\n", __FUNCTION__);
-		if ((skb_queue_len( &self->txq) > 0) &&
-		    (self->window > 0)) {
+		if (self->window > 0) {
 			skb = skb_dequeue( &self->txq);
 			IRDA_ASSERT(skb != NULL, return;);
 
@@ -1031,8 +1030,7 @@ void irlap_resend_rejected_frames(struct
 			 *  bit cleared
 			 */
 			if ((self->window > 1) &&
-			    skb_queue_len(&self->txq) > 0)
-			{
+			    !skb_queue_empty(&self->txq)) {
 				irlap_send_data_primary(self, skb);
 			} else {
 				irlap_send_data_primary_poll(self, skb);
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -1513,7 +1513,7 @@ int irttp_disconnect_request(struct tsap
 	/*
 	 *  Check if there is still data segments in the transmit queue
 	 */
-	if (skb_queue_len(&self->tx_queue) > 0) {
+	if (!skb_queue_empty(&self->tx_queue)) {
 		if (priority == P_HIGH) {
 			/*
 			 *  No need to send the queued data, if we are
diff --git a/net/llc/llc_c_ev.c b/net/llc/llc_c_ev.c
--- a/net/llc/llc_c_ev.c
+++ b/net/llc/llc_c_ev.c
@@ -84,7 +84,7 @@ static u16 llc_util_nr_inside_tx_window(
 	if (llc->dev->flags & IFF_LOOPBACK)
 		goto out;
 	rc = 1;
-	if (!skb_queue_len(&llc->pdu_unack_q))
+	if (skb_queue_empty(&llc->pdu_unack_q))
 		goto out;
 	skb = skb_peek(&llc->pdu_unack_q);
 	pdu = llc_pdu_sn_hdr(skb);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -858,7 +858,7 @@ static inline void netlink_rcv_wake(stru
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
-	if (!skb_queue_len(&sk->sk_receive_queue))
+	if (skb_queue_empty(&sk->sk_receive_queue))
 		clear_bit(0, &nlk->state);
 	if (!test_bit(0, &nlk->state))
 		wake_up_interruptible(&nlk->wait);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -385,7 +385,7 @@ static int red_change(struct Qdisc *sch,
 	memcpy(q->Stab, RTA_DATA(tb[TCA_RED_STAB-1]), 256);
 
 	q->qcount = -1;
-	if (skb_queue_len(&sch->q) == 0)
+	if (skb_queue_empty(&sch->q))
 		PSCHED_SET_PASTPERFECT(q->qidlestart);
 	sch_tree_unlock(sch);
 	return 0;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -302,7 +302,7 @@ static void unix_write_space(struct sock
  * may receive messages only from that peer. */
 static void unix_dgram_disconnected(struct sock *sk, struct sock *other)
 {
-	if (skb_queue_len(&sk->sk_receive_queue)) {
+	if (!skb_queue_empty(&sk->sk_receive_queue)) {
 		skb_queue_purge(&sk->sk_receive_queue);
 		wake_up_interruptible_all(&unix_sk(sk)->peer_wait);
 
@@ -1619,7 +1619,7 @@ static long unix_stream_data_wait(struct
 	for (;;) {
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 
-		if (skb_queue_len(&sk->sk_receive_queue) ||
+		if (!skb_queue_empty(&sk->sk_receive_queue) ||
 		    sk->sk_err ||
 		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 		    signal_pending(current) ||
