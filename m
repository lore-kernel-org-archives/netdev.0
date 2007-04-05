From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: Re: [BUG] 2.6.20.1-rt8 irnet + pppd recursive spinlock...
Date: Thu, 5 Apr 2007 17:11:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0704051702330.534@pcgl.dsa-ac.de>
References: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de>
 <Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: irda-users@lists.sourceforge.net, linux-rt-users@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Apr 2007, Guennadi Liakhovetski wrote:

> Ok, a simple analysis reveals the recursive spinlock:
> 
> On Thu, 5 Apr 2007, Guennadi Liakhovetski wrote:
> 
> > [<bf12b220>] (ppp_channel_push+0x0/0xc8 [ppp_generic]) from [<bf12bf98>] (ppp_output_wakeup+0x18/0x1c [ppp_generic])
> ===>		^^^^^^^^^^^^^^^^
> >  r7 = C38F42BC  r6 = C38F4200  r5 = C38F4200  r4 = 00000000
> 
> ===>	spin_lock_bh(&pch->downl);
> 
> > [<bf12bf80>] (ppp_output_wakeup+0x0/0x1c [ppp_generic]) from [<bf132c98>] (irnet_flow_indication+0x38/0x3c [irnet])
> > [<bf132c60>] (irnet_flow_indication+0x0/0x3c [irnet]) from [<bf104e4c>] (irttp_run_tx_queue+0x1c0/0x1d4 [irda])
> > [<bf104c8c>] (irttp_run_tx_queue+0x0/0x1d4 [irda]) from [<bf104f88>] (irttp_data_request+0x128/0x4f8 [irda])
> >  r8 = BF121560  r7 = 00000002  r6 = C38F4200  r5 = C21418B8
> >  r4 = C21418B8 
> > [<bf104e60>] (irttp_data_request+0x0/0x4f8 [irda]) from [<bf1321bc>] (ppp_irnet_send+0x134/0x238 [irnet])
> > [<bf132088>] (ppp_irnet_send+0x0/0x238 [irnet]) from [<bf12a600>] (ppp_push+0x80/0xb8 [ppp_generic])
> >  r7 = C3A436E0  r6 = 00000000  r5 = C21418B8  r4 = C1489600
> > [<bf12a580>] (ppp_push+0x0/0xb8 [ppp_generic]) from [<bf12a8d8>] (ppp_xmit_process+0x34/0x50c [ppp_generic])
> ===>		^^^^^^^^
> >  r7 = 00000021  r6 = C21418B8  r5 = C1489600  r4 = 00000000
> 
> ===>		spin_lock_bh(&pch->downl);

For comments, below is a patch I am testing ATM. It doesn't look right nor 
very pretty, but I couldn't come up with anything better. I do sign-off 
for it in case nothing better is proposed and it is decided to push it for 
2.6.21.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany

Fix recursion with PPP over IrNET.

Signed-off-by: G. Liakhovetski <gl@dsa-ac.de>

diff -u -r1.1.1.19.4.1 ppp_generic.c
--- a/drivers/net/ppp_generic.c	26 Mar 2007 09:21:32 -0000	1.1.1.19.4.1
+++ b/drivers/net/ppp_generic.c	5 Apr 2007 15:01:45 -0000
@@ -155,6 +155,7 @@
 	struct ppp_channel *chan;	/* public channel data structure */
 	struct rw_semaphore chan_sem;	/* protects `chan' during chan ioctl */
 	spinlock_t	downl;		/* protects `chan', file.xq dequeue */
+	struct task_struct *locker;	/* owner of the downl lock */
 	struct ppp	*ppp;		/* ppp unit we're connected to */
 	struct list_head clist;		/* link in list of channels per unit */
 	rwlock_t	upl;		/* protects `ppp' */
@@ -1214,8 +1215,11 @@
 
 		spin_lock_bh(&pch->downl);
 		if (pch->chan) {
+			/* Prevent recursive locking */
+			pch->locker = current;
 			if (pch->chan->ops->start_xmit(pch->chan, skb))
 				ppp->xmit_pending = NULL;
+			pch->locker = NULL;
 		} else {
 			/* channel got unregistered */
 			kfree_skb(skb);
@@ -1435,6 +1439,9 @@
 	struct sk_buff *skb;
 	struct ppp *ppp;
 
+	if (pch->locker == current)
+		return;
+
 	spin_lock_bh(&pch->downl);
 	if (pch->chan != 0) {
 		while (!skb_queue_empty(&pch->file.xq)) {
