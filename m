From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 12/12][ATM] stop using sk_protinfo
Date: Fri, 21 Jan 2005 01:19:45 -0200
Message-ID: <41F074D1.3090107@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010309010202000203030006"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, chas@cmf.nrl.navy.mil
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010309010202000203030006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David, Chas,

	Subject says it all. Chas, I tried contacting you, but mail to you bounces,
so I hope you can read this message thru netdev.

Regards,

- Arnaldo


--------------010309010202000203030006
Content-Type: text/plain;
 name="12-atm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="12-atm.patch"

===================================================================


ChangeSet@1.2010, 2005-01-21 00:17:51-02:00, acme@toy.ghostprotocols.net
  [ATM] stop using sk_protinfo
  
  Required to introduce struct connection_sock.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 drivers/atm/atmtcp.c   |   14 ++++-----
 drivers/atm/he.c       |    2 -
 drivers/atm/idt77252.c |    9 +++---
 drivers/atm/iphase.c   |   12 ++++----
 include/linux/atmdev.h |   28 +++++++++++++------
 net/atm/atm_misc.c     |    7 ++--
 net/atm/br2684.c       |    4 +-
 net/atm/clip.c         |   19 +++++++------
 net/atm/common.c       |   55 ++++++++++++++++---------------------
 net/atm/ioctl.c        |    9 +++---
 net/atm/lec.c          |   38 +++++++++++++++-----------
 net/atm/mpc.c          |   28 ++++++++++++-------
 net/atm/pppoatm.c      |    3 +-
 net/atm/proc.c         |   18 ++++++------
 net/atm/raw.c          |   14 ++++++---
 net/atm/signaling.c    |   41 +++++++++++++++-------------
 net/atm/svc.c          |   71 +++++++++++++++++++++++++------------------------
 net/sched/sch_atm.c    |    2 -
 18 files changed, 207 insertions(+), 167 deletions(-)


diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	2005-01-21 00:21:55 -02:00
+++ b/drivers/atm/atmtcp.c	2005-01-21 00:21:55 -02:00
@@ -67,7 +67,7 @@
 	*(struct atm_vcc **) &new_msg->vcc = vcc;
 	old_test = test_bit(flag,&vcc->flags);
 	out_vcc->push(out_vcc,skb);
-	add_wait_queue(vcc->sk->sk_sleep, &wait);
+	add_wait_queue(sk_atm(vcc)->sk_sleep, &wait);
 	while (test_bit(flag,&vcc->flags) == old_test) {
 		mb();
 		out_vcc = PRIV(vcc->dev) ? PRIV(vcc->dev)->vcc : NULL;
@@ -79,7 +79,7 @@
 		schedule();
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(vcc->sk->sk_sleep, &wait);
+	remove_wait_queue(sk_atm(vcc)->sk_sleep, &wait);
 	return error;
 }
 
@@ -91,7 +91,7 @@
 	vcc->vpi = msg->addr.sap_addr.vpi;
 	vcc->vci = msg->addr.sap_addr.vci;
 	vcc->qos = msg->qos;
-	vcc->sk->sk_err = -msg->result;
+	sk_atm(vcc)->sk_err = -msg->result;
 	switch (msg->type) {
 	    case ATMTCP_CTRL_OPEN:
 		change_bit(ATM_VF_READY,&vcc->flags);
@@ -104,7 +104,7 @@
 		    msg->type);
 		return -EINVAL;
 	}
-	wake_up(vcc->sk->sk_sleep);
+	wake_up(sk_atm(vcc)->sk_sleep);
 	return 0;
 }
 
@@ -135,7 +135,7 @@
 	clear_bit(ATM_VF_READY,&vcc->flags); /* just in case ... */
 	error = atmtcp_send_control(vcc,ATMTCP_CTRL_OPEN,&msg,ATM_VF_READY);
 	if (error) return error;
-	return -vcc->sk->sk_err;
+	return -sk_atm(vcc)->sk_err;
 }
 
 
@@ -267,7 +267,7 @@
 			walk = atm_sk(s);
 			if (walk->dev != atmtcp_dev)
 				continue;
-			wake_up(walk->sk->sk_sleep);
+			wake_up(s->sk_sleep);
 		}
 	}
 	read_unlock(&vcc_sklist_lock);
@@ -417,7 +417,7 @@
 	}
 	PRIV(dev)->vcc = vcc;
 	vcc->dev = &atmtcp_control_dev;
-	vcc_insert_socket(vcc->sk);
+	vcc_insert_socket(sk_atm(vcc));
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
 	vcc->dev_data = dev;
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2005-01-21 00:21:55 -02:00
+++ b/drivers/atm/he.c	2005-01-21 00:21:55 -02:00
@@ -2610,7 +2610,7 @@
 		 * TBRQ, the host issues the close command to the adapter.
 		 */
 
-		while (((tx_inuse = atomic_read(&vcc->sk->sk_wmem_alloc)) > 0) &&
+		while (((tx_inuse = atomic_read(&sk_atm(vcc)->sk_wmem_alloc)) > 0) &&
 		       (retry < MAX_RETRY)) {
 			msleep(sleep);
 			if (sleep < 250)
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	2005-01-21 00:21:55 -02:00
+++ b/drivers/atm/idt77252.c	2005-01-21 00:21:55 -02:00
@@ -727,10 +727,11 @@
 	spin_lock_irqsave(&vc->lock, flags);
 	if (vc->estimator) {
 		struct atm_vcc *vcc = vc->tx_vcc;
+		struct sock *sk = sk_atm(vcc);
 
 		vc->estimator->cells += (skb->len + 47) / 48;
-		if (atomic_read(&vcc->sk->sk_wmem_alloc) >
-		    (vcc->sk->sk_sndbuf >> 1)) {
+		if (atomic_read(&sk->sk_wmem_alloc) >
+		    (sk->sk_sndbuf >> 1)) {
 			u32 cps = vc->estimator->maxcps;
 
 			vc->estimator->cps = cps;
@@ -1325,7 +1326,7 @@
 			goto drop;
 		}
 
-		if ((vcc->sk != NULL) && !atm_charge(vcc, sb->truesize)) {
+		if (!atm_charge(vcc, sb->truesize)) {
 			RXPRINTK("%s: atm_charge() dropped AAL0 packets.\n",
 				 card->name);
 			dev_kfree_skb(sb);
@@ -2029,7 +2030,7 @@
 		atomic_inc(&vcc->stats->tx_err);
 		return -ENOMEM;
 	}
-	atomic_add(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 
 	memcpy(skb_put(skb, 52), cell, 52);
 
diff -Nru a/drivers/atm/iphase.c b/drivers/atm/iphase.c
--- a/drivers/atm/iphase.c	2005-01-21 00:21:55 -02:00
+++ b/drivers/atm/iphase.c	2005-01-21 00:21:55 -02:00
@@ -1777,16 +1777,18 @@
         if (ia_vcc->pcr < iadev->rate_limit)
            skb_queue_head_init (&ia_vcc->txing_skb);
         if (ia_vcc->pcr < iadev->rate_limit) {
-           if (vcc->qos.txtp.max_sdu != 0) {
+	   struct sock *sk = sk_atm(vcc);
+
+	   if (vcc->qos.txtp.max_sdu != 0) {
                if (ia_vcc->pcr > 60000)
-                  vcc->sk->sk_sndbuf = vcc->qos.txtp.max_sdu * 5;
+                  sk->sk_sndbuf = vcc->qos.txtp.max_sdu * 5;
                else if (ia_vcc->pcr > 2000)
-                  vcc->sk->sk_sndbuf = vcc->qos.txtp.max_sdu * 4;
+                  sk->sk_sndbuf = vcc->qos.txtp.max_sdu * 4;
                else
-                 vcc->sk->sk_sndbuf = vcc->qos.txtp.max_sdu * 3;
+                 sk->sk_sndbuf = vcc->qos.txtp.max_sdu * 3;
            }
            else
-             vcc->sk->sk_sndbuf = 24576;
+             sk->sk_sndbuf = 24576;
         }
            
 	vc = (struct main_vc *)iadev->MAIN_VC_TABLE_ADDR;  
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	2005-01-21 00:21:55 -02:00
+++ b/include/linux/atmdev.h	2005-01-21 00:21:55 -02:00
@@ -30,9 +30,6 @@
 #define ATM_DS3_PCR	(8000*12)
 			/* DS3: 12 cells in a 125 usec time slot */
 
-#define atm_sk(__sk) ((struct atm_vcc *)(__sk)->sk_protinfo)
-#define ATM_SD(s)	(atm_sk((s)->sk))
-
 
 #define __AAL_STAT_ITEMS \
     __HANDLE_ITEM(tx);			/* TX okay */ \
@@ -281,6 +278,8 @@
 #define ATM_ATMOPT_CLP	1	/* set CLP bit */
 
 struct atm_vcc {
+	/* struct sock has to be the first member of atm_vcc */
+	struct sock	sk;
 	unsigned long	flags;		/* VCC flags (ATM_VF_*) */
 	short		vpi;		/* VPI and VCI (types must be equal */
 					/* with sockaddr) */
@@ -297,7 +296,6 @@
 	void		*dev_data;	/* per-device data */
 	void		*proto_data;	/* per-protocol data */
 	struct k_atm_aal_stats *stats;	/* pointer to AAL stats group */
-	struct sock	*sk;		/* socket backpointer */
 	/* SVC part --- may move later ------------------------------------- */
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
@@ -310,6 +308,20 @@
 					/* by CLIP and sch_atm. */
 };
 
+static inline struct atm_vcc *atm_sk(struct sock *sk)
+{
+	return (struct atm_vcc *)sk;
+}
+
+static inline struct atm_vcc *ATM_SD(struct socket *sock)
+{
+	return atm_sk(sock->sk);
+}
+
+static inline struct sock *sk_atm(struct atm_vcc *vcc)
+{
+	return (struct sock *)vcc;
+}
 
 struct atm_dev_addr {
 	struct sockaddr_atmsvc addr;	/* ATM address */
@@ -410,20 +422,20 @@
 
 static inline void atm_force_charge(struct atm_vcc *vcc,int truesize)
 {
-	atomic_add(truesize, &vcc->sk->sk_rmem_alloc);
+	atomic_add(truesize, &sk_atm(vcc)->sk_rmem_alloc);
 }
 
 
 static inline void atm_return(struct atm_vcc *vcc,int truesize)
 {
-	atomic_sub(truesize, &vcc->sk->sk_rmem_alloc);
+	atomic_sub(truesize, &sk_atm(vcc)->sk_rmem_alloc);
 }
 
 
 static inline int atm_may_send(struct atm_vcc *vcc,unsigned int size)
 {
-	return (size + atomic_read(&vcc->sk->sk_wmem_alloc)) <
-	       vcc->sk->sk_sndbuf;
+	return (size + atomic_read(&sk_atm(vcc)->sk_wmem_alloc)) <
+	       sk_atm(vcc)->sk_sndbuf;
 }
 
 
diff -Nru a/net/atm/atm_misc.c b/net/atm/atm_misc.c
--- a/net/atm/atm_misc.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/atm_misc.c	2005-01-21 00:21:55 -02:00
@@ -16,7 +16,7 @@
 int atm_charge(struct atm_vcc *vcc,int truesize)
 {
 	atm_force_charge(vcc,truesize);
-	if (atomic_read(&vcc->sk->sk_rmem_alloc) <= vcc->sk->sk_rcvbuf)
+	if (atomic_read(&sk_atm(vcc)->sk_rmem_alloc) <= sk_atm(vcc)->sk_rcvbuf)
 		return 1;
 	atm_return(vcc,truesize);
 	atomic_inc(&vcc->stats->rx_drop);
@@ -27,15 +27,16 @@
 struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc,int pdu_size,
     int gfp_flags)
 {
+	struct sock *sk = sk_atm(vcc);
 	int guess = atm_guess_pdu2truesize(pdu_size);
 
 	atm_force_charge(vcc,guess);
-	if (atomic_read(&vcc->sk->sk_rmem_alloc) <= vcc->sk->sk_rcvbuf) {
+	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf) {
 		struct sk_buff *skb = alloc_skb(pdu_size,gfp_flags);
 
 		if (skb) {
 			atomic_add(skb->truesize-guess,
-				   &vcc->sk->sk_rmem_alloc);
+				   &sk->sk_rmem_alloc);
 			return skb;
 		}
 	}
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/br2684.c	2005-01-21 00:21:55 -02:00
@@ -190,7 +190,7 @@
 		dev_kfree_skb(skb);
 		return 0;
 		}
-	atomic_add(skb->truesize, &atmvcc->sk->sk_wmem_alloc);
+	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
 	brdev->stats.tx_packets++;
 	brdev->stats.tx_bytes += skb->len;
@@ -557,7 +557,7 @@
 	barrier();
 	atmvcc->push = br2684_push;
 	skb_queue_head_init(&copy);
-	skb_migrate(&atmvcc->sk->sk_receive_queue, &copy);
+	skb_migrate(&sk_atm(atmvcc)->sk_receive_queue, &copy);
 	while ((skb = skb_dequeue(&copy)) != NULL) {
 		BRPRIV(skb->dev)->stats.rx_bytes -= skb->len;
 		BRPRIV(skb->dev)->stats.rx_packets--;
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/clip.c	2005-01-21 00:21:55 -02:00
@@ -58,6 +58,7 @@
 
 static int to_atmarpd(enum atmarp_ctrl_type type,int itf,unsigned long ip)
 {
+	struct sock *sk;
 	struct atmarp_ctrl *ctrl;
 	struct sk_buff *skb;
 
@@ -70,8 +71,10 @@
 	ctrl->itf_num = itf;
 	ctrl->ip = ip;
 	atm_force_charge(atmarpd,skb->truesize);
-	skb_queue_tail(&atmarpd->sk->sk_receive_queue, skb);
-	atmarpd->sk->sk_data_ready(atmarpd->sk, skb->len);
+
+	sk = sk_atm(atmarpd);
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+	sk->sk_data_ready(sk, skb->len);
 	return 0;
 }
 
@@ -434,7 +437,7 @@
 		memcpy(here,llc_oui,sizeof(llc_oui));
 		((u16 *) here)[3] = skb->protocol;
 	}
-	atomic_add(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	entry->vccs->last_use = jiffies;
 	DPRINTK("atm_skb(%p)->vcc(%p)->dev(%p)\n",skb,vcc,vcc->dev);
@@ -493,7 +496,7 @@
 	vcc->push = clip_push;
 	vcc->pop = clip_pop;
 	skb_queue_head_init(&copy);
-	skb_migrate(&vcc->sk->sk_receive_queue, &copy);
+	skb_migrate(&sk_atm(vcc)->sk_receive_queue, &copy);
 	/* re-process everything received between connection setup and MKIP */
 	while ((skb = skb_dequeue(&copy)) != NULL)
 		if (!clip_devs) {
@@ -686,10 +689,10 @@
 	barrier();
 	unregister_inetaddr_notifier(&clip_inet_notifier);
 	unregister_netdevice_notifier(&clip_dev_notifier);
-	if (skb_peek(&vcc->sk->sk_receive_queue))
+	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
 		printk(KERN_ERR "atmarpd_close: closing with requests "
 		    "pending\n");
-	skb_queue_purge(&vcc->sk->sk_receive_queue);
+	skb_queue_purge(&sk_atm(vcc)->sk_receive_queue);
 	DPRINTK("(done)\n");
 	module_put(THIS_MODULE);
 }
@@ -723,7 +726,7 @@
 	set_bit(ATM_VF_READY,&vcc->flags);
 	    /* allow replies and avoid getting closed if signaling dies */
 	vcc->dev = &atmarpd_dev;
-	vcc_insert_socket(vcc->sk);
+	vcc_insert_socket(sk_atm(vcc));
 	vcc->push = NULL;
 	vcc->pop = NULL; /* crash */
 	vcc->push_oam = NULL; /* crash */
@@ -822,7 +825,7 @@
 	int svc, llc, off;
 
 	svc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
-	       (clip_vcc->vcc->sk->sk_family == AF_ATMSVC));
+	       (sk_atm(clip_vcc->vcc)->sk_family == AF_ATMSVC));
 
 	llc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
 	       clip_vcc->encap);
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/common.c	2005-01-21 00:21:55 -02:00
@@ -68,17 +68,18 @@
 static struct sk_buff *alloc_tx(struct atm_vcc *vcc,unsigned int size)
 {
 	struct sk_buff *skb;
+	struct sock *sk = sk_atm(vcc);
 
-	if (atomic_read(&vcc->sk->sk_wmem_alloc) && !atm_may_send(vcc, size)) {
+	if (atomic_read(&sk->sk_wmem_alloc) && !atm_may_send(vcc, size)) {
 		DPRINTK("Sorry: wmem_alloc = %d, size = %d, sndbuf = %d\n",
-			atomic_read(&vcc->sk->sk_wmem_alloc), size,
-			vcc->sk->sk_sndbuf);
+			atomic_read(&sk->sk_wmem_alloc), size,
+			sk->sk_sndbuf);
 		return NULL;
 	}
 	while (!(skb = alloc_skb(size,GFP_KERNEL))) schedule();
-	DPRINTK("AlTx %d += %d\n", atomic_read(&vcc->sk->sk_wmem_alloc),
+	DPRINTK("AlTx %d += %d\n", atomic_read(&sk->sk_wmem_alloc),
 		skb->truesize);
-	atomic_add(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 	return skb;
 }
 
@@ -89,15 +90,11 @@
 
 static void vcc_sock_destruct(struct sock *sk)
 {
-	struct atm_vcc *vcc = atm_sk(sk);
-
-	if (atomic_read(&vcc->sk->sk_rmem_alloc))
+	if (atomic_read(&sk->sk_rmem_alloc))
 		printk(KERN_DEBUG "vcc_sock_destruct: rmem leakage (%d bytes) detected.\n", atomic_read(&sk->sk_rmem_alloc));
 
-	if (atomic_read(&vcc->sk->sk_wmem_alloc))
+	if (atomic_read(&sk->sk_wmem_alloc))
 		printk(KERN_DEBUG "vcc_sock_destruct: wmem leakage (%d bytes) detected.\n", atomic_read(&sk->sk_wmem_alloc));
-
-	kfree(sk->sk_protinfo);
 }
 
 static void vcc_def_wakeup(struct sock *sk)
@@ -139,7 +136,7 @@
 	sock->sk = NULL;
 	if (sock->type == SOCK_STREAM)
 		return -EINVAL;
-	sk = sk_alloc(family, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(family, GFP_KERNEL, sizeof(struct atm_vcc), NULL);
 	if (!sk)
 		return -ENOMEM;
 	sock_init_data(sock, sk);
@@ -147,20 +144,13 @@
 	sk->sk_state_change = vcc_def_wakeup;
 	sk->sk_write_space = vcc_write_space;
 
-	vcc = sk->sk_protinfo = kmalloc(sizeof(*vcc), GFP_KERNEL);
-	if (!vcc) {
-		sk_free(sk);
-		return -ENOMEM;
-	}
-
-	memset(vcc, 0, sizeof(*vcc));
-	vcc->sk = sk;
+	vcc = atm_sk(sk);
 	vcc->dev = NULL;
 	memset(&vcc->local,0,sizeof(struct sockaddr_atmsvc));
 	memset(&vcc->remote,0,sizeof(struct sockaddr_atmsvc));
 	vcc->qos.txtp.max_sdu = 1 << 16; /* for meta VCs */
-	atomic_set(&vcc->sk->sk_wmem_alloc, 0);
-	atomic_set(&vcc->sk->sk_rmem_alloc, 0);
+	atomic_set(&sk->sk_wmem_alloc, 0);
+	atomic_set(&sk->sk_rmem_alloc, 0);
 	vcc->push = NULL;
 	vcc->pop = NULL;
 	vcc->push_oam = NULL;
@@ -187,7 +177,7 @@
 
 		vcc_remove_socket(sk);	/* no more receive */
 
-		while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue)) != NULL) {
+		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 			atm_return(vcc,skb->truesize);
 			kfree_skb(skb);
 		}
@@ -215,11 +205,13 @@
 
 void vcc_release_async(struct atm_vcc *vcc, int reply)
 {
+	struct sock *sk = sk_atm(vcc);
+
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
-	vcc->sk->sk_shutdown |= RCV_SHUTDOWN;
-	vcc->sk->sk_err = -reply;
+	sk->sk_shutdown |= RCV_SHUTDOWN;
+	sk->sk_err = -reply;
 	clear_bit(ATM_VF_WAITING, &vcc->flags);
-	vcc->sk->sk_state_change(vcc->sk);
+	sk->sk_state_change(sk);
 }
 
 
@@ -328,6 +320,7 @@
 static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, short vpi,
 			 int vci)
 {
+	struct sock *sk = sk_atm(vcc);
 	int error;
 
 	if ((vpi != ATM_VPI_UNSPEC && vpi != ATM_VPI_ANY &&
@@ -347,7 +340,7 @@
 	}
 	vcc->vpi = vpi;
 	vcc->vci = vci;
-	__vcc_insert_socket(vcc->sk);
+	__vcc_insert_socket(sk);
 	write_unlock_irq(&vcc_sklist_lock);
 	switch (vcc->qos.aal) {
 		case ATM_AAL0:
@@ -386,7 +379,7 @@
 	return 0;
 
 fail:
-	vcc_remove_socket(vcc->sk);
+	vcc_remove_socket(sk);
 fail_module_put:
 	module_put(dev->ops->owner);
 	/* ensure we get dev module ref count correct */
@@ -495,7 +488,7 @@
         if (error)
                 return error;
         sock_recv_timestamp(msg, sk, skb);
-        DPRINTK("RcvM %d -= %d\n", atomic_read(&vcc->sk->rmem_alloc), skb->truesize);
+        DPRINTK("RcvM %d -= %d\n", atomic_read(&sk->rmem_alloc), skb->truesize);
         atm_return(vcc, skb->truesize);
         skb_free_datagram(sk, skb);
         return copied;
@@ -615,7 +608,7 @@
 		return mask;
 
 	if (vcc->qos.txtp.traffic_class != ATM_NONE &&
-	    vcc_writable(vcc->sk))
+	    vcc_writable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 
 	return mask;
@@ -638,7 +631,7 @@
 	if (!error) error = adjust_tp(&qos->rxtp,qos->aal);
 	if (error) return error;
 	if (!vcc->dev->ops->change_qos) return -EOPNOTSUPP;
-	if (vcc->sk->sk_family == AF_ATMPVC)
+	if (sk_atm(vcc)->sk_family == AF_ATMPVC)
 		return vcc->dev->ops->change_qos(vcc,qos,ATM_MF_SET);
 	return svc_change_qos(vcc,qos);
 }
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/ioctl.c	2005-01-21 00:21:55 -02:00
@@ -46,6 +46,7 @@
 
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 	int error;
 	struct list_head * pos;
@@ -59,8 +60,8 @@
 				error =  -EINVAL;
 				goto done;
 			}
-			error = put_user(vcc->sk->sk_sndbuf -
-					 atomic_read(&vcc->sk->sk_wmem_alloc),
+			error = put_user(sk->sk_sndbuf -
+					 atomic_read(&sk->sk_wmem_alloc),
 					 (int __user *) argp) ? -EFAULT : 0;
 			goto done;
 		case SIOCINQ:
@@ -71,13 +72,13 @@
 					error = -EINVAL;
 					goto done;
 				}
-				skb = skb_peek(&vcc->sk->sk_receive_queue);
+				skb = skb_peek(&sk->sk_receive_queue);
 				error = put_user(skb ? skb->len : 0,
 					 	 (int __user *)argp) ? -EFAULT : 0;
 				goto done;
 			}
 		case SIOCGSTAMP: /* borrowed from IP */
-			error = sock_get_timestamp(vcc->sk, argp);
+			error = sock_get_timestamp(sk, argp);
 			goto done;
 		case ATM_SETSC:
 			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/lec.c	2005-01-21 00:21:55 -02:00
@@ -122,6 +122,7 @@
         eth = (struct ethhdr *)skb->data;
         buff = skb->data + skb->dev->hard_header_len;
         if (*buff++ == 0x42 && *buff++ == 0x42 && *buff++ == 0x03) {
+		struct sock *sk;
                 struct sk_buff *skb2;
                 struct atmlec_msg *mesg;
 
@@ -135,8 +136,9 @@
 
                 priv = (struct lec_priv *)dev->priv;
                 atm_force_charge(priv->lecd, skb2->truesize);
-                skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb2->len);
+		sk = sk_atm(priv->lecd);
+                skb_queue_tail(&sk->sk_receive_queue, skb2);
+                sk->sk_data_ready(sk, skb2->len);
         }
 
         return;
@@ -214,7 +216,7 @@
 	ATM_SKB(skb)->vcc = vcc;
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 
-	atomic_add(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	if (vcc->send(vcc, skb) < 0) {
 		priv->stats.tx_dropped++;
 		return;
@@ -430,7 +432,7 @@
         int i;
         char *tmp; /* FIXME */
 
-	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
         mesg = (struct atmlec_msg *)skb->data;
         tmp = skb->data;
         tmp += sizeof(struct atmlec_msg);
@@ -528,6 +530,7 @@
                     f->dst->state == BR_STATE_FORWARDING) {
                                 /* hit from bridge table, send LE_ARP_RESPONSE */
                         struct sk_buff *skb2;
+			struct sock *sk;
 
                         DPRINTK("%s: entry found, responding to zeppelin\n", dev->name);
                         skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
@@ -538,8 +541,9 @@
                         skb2->len = sizeof(struct atmlec_msg);
                         memcpy(skb2->data, mesg, sizeof(struct atmlec_msg));
                         atm_force_charge(priv->lecd, skb2->truesize);
-                        skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                        priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb2->len);
+			sk = sk_atm(priv->lecd);
+                        skb_queue_tail(&sk->sk_receive_queue, skb2);
+                        sk->sk_data_ready(sk, skb2->len);
                 }
                 if (f != NULL) br_fdb_put_hook(f);
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
@@ -567,10 +571,10 @@
         netif_stop_queue(dev);
         lec_arp_destroy(priv);
 
-        if (skb_peek(&vcc->sk->sk_receive_queue))
+        if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
 		printk("%s lec_atm_close: closing with messages pending\n",
                        dev->name);
-        while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue)) != NULL) {
+        while ((skb = skb_dequeue(&sk_atm(vcc)->sk_receive_queue)) != NULL) {
                 atm_return(vcc, skb->truesize);
 		dev_kfree_skb(skb);
         }
@@ -600,6 +604,7 @@
              unsigned char *mac_addr, unsigned char *atm_addr,
              struct sk_buff *data)
 {
+	struct sock *sk;
 	struct sk_buff *skb;
 	struct atmlec_msg *mesg;
 
@@ -623,14 +628,15 @@
 		memcpy(&mesg->content.normal.atm_addr, atm_addr, ATM_ESA_LEN);
 
         atm_force_charge(priv->lecd, skb->truesize);
-	skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb);
-        priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb->len);
+	sk = sk_atm(priv->lecd);
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+        sk->sk_data_ready(sk, skb->len);
 
         if (data != NULL) {
                 DPRINTK("lec: about to send %d bytes of data\n", data->len);
                 atm_force_charge(priv->lecd, data->truesize);
-                skb_queue_tail(&priv->lecd->sk->sk_receive_queue, data);
-                priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb->len);
+                skb_queue_tail(&sk->sk_receive_queue, data);
+                sk->sk_data_ready(sk, skb->len);
         }
 
         return 0;
@@ -711,9 +717,11 @@
                 printk("%s...\n",buf);
 #endif /* DUMP_PACKETS > 0 */
         if (memcmp(skb->data, lec_ctrl_magic, 4) ==0) { /* Control frame, to daemon*/
+		struct sock *sk = sk_atm(vcc);
+
                 DPRINTK("%s: To daemon\n",dev->name);
-                skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-                vcc->sk->sk_data_ready(vcc->sk, skb->len);
+                skb_queue_tail(&sk->sk_receive_queue, skb);
+                sk->sk_data_ready(sk, skb->len);
         } else { /* Data frame, queue to protocol handlers */
                 unsigned char *dst;
 
@@ -866,7 +874,7 @@
 	priv->itfnum = i;  /* LANE2 addition */
         priv->lecd = vcc;
         vcc->dev = &lecatm_dev;
-        vcc_insert_socket(vcc->sk);
+        vcc_insert_socket(sk_atm(vcc));
         
         vcc->proto_data = dev_lec[i];
 	set_bit(ATM_VF_META,&vcc->flags);
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/mpc.c	2005-01-21 00:21:55 -02:00
@@ -522,7 +522,7 @@
 		memcpy(skb->data, &llc_snap_mpoa_data, sizeof(struct llc_snap_hdr));
 	}
 
-	atomic_add(skb->truesize, &entry->shortcut->sk->sk_wmem_alloc);
+	atomic_add(skb->truesize, &sk_atm(entry->shortcut)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = entry->shortcut->atm_options;
 	entry->shortcut->send(entry->shortcut, skb);
 	entry->packets_fwded++;
@@ -665,10 +665,12 @@
 	
 	skb->dev = dev;
 	if (memcmp(skb->data, &llc_snap_mpoa_ctrl, sizeof(struct llc_snap_hdr)) == 0) {
+		struct sock *sk = sk_atm(vcc);
+
 		dprintk("mpoa: (%s) mpc_push: control packet arrived\n", dev->name);
 		/* Pass control packets to daemon */
-		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		vcc->sk->sk_data_ready(vcc->sk, skb->len);
+		skb_queue_tail(&sk->sk_receive_queue, skb);
+		sk->sk_data_ready(sk, skb->len);
 		return;
 	}
 
@@ -794,7 +796,7 @@
 
 	mpc->mpoad_vcc = vcc;
 	vcc->dev = &mpc_dev;
-	vcc_insert_socket(vcc->sk);
+	vcc_insert_socket(sk_atm(vcc));
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
 
@@ -853,7 +855,7 @@
 	mpc->in_ops->destroy_cache(mpc);
 	mpc->eg_ops->destroy_cache(mpc);
 
-	while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue))) {
+	while ((skb = skb_dequeue(&sk_atm(vcc)->sk_receive_queue))) {
 		atm_return(vcc, skb->truesize);
 		kfree_skb(skb);
 	}
@@ -873,7 +875,7 @@
 	
 	struct mpoa_client *mpc = find_mpc_by_vcc(vcc);
 	struct k_message *mesg = (struct k_message*)skb->data;
-	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	
 	if (mpc == NULL) {
 		printk("mpoa: msg_from_mpoad: no mpc found\n");
@@ -938,6 +940,7 @@
 int msg_to_mpoad(struct k_message *mesg, struct mpoa_client *mpc)
 {
 	struct sk_buff *skb;
+	struct sock *sk;
 
 	if (mpc == NULL || !mpc->mpoad_vcc) {
 		printk("mpoa: msg_to_mpoad: mesg %d to a non-existent mpoad\n", mesg->type);
@@ -950,8 +953,10 @@
 	skb_put(skb, sizeof(struct k_message));
 	memcpy(skb->data, mesg, sizeof(struct k_message));
 	atm_force_charge(mpc->mpoad_vcc, skb->truesize);
-	skb_queue_tail(&mpc->mpoad_vcc->sk->sk_receive_queue, skb);
-	mpc->mpoad_vcc->sk->sk_data_ready(mpc->mpoad_vcc->sk, skb->len);
+	
+	sk = sk_atm(mpc->mpoad_vcc);
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+	sk->sk_data_ready(sk, skb->len);
 
 	return 0;
 }
@@ -1206,6 +1211,7 @@
 
 static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 {
+	struct sock *sk;
 	struct k_message *purge_msg;
 	struct sk_buff *skb;
 
@@ -1229,8 +1235,10 @@
 		purge_msg->content.eg_info = entry->ctrl_info;
 
 	atm_force_charge(vcc, skb->truesize);
-	skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-	vcc->sk->sk_data_ready(vcc->sk, skb->len);
+
+	sk = sk_atm(vcc);
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+	sk->sk_data_ready(sk, skb->len);
 	dprintk("mpoa: purge_egress_shortcut: exiting:\n");
 
 	return;
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/pppoatm.c	2005-01-21 00:21:55 -02:00
@@ -233,7 +233,8 @@
 		kfree_skb(skb);
 		return 1;
 	}
-	atomic_add(skb->truesize, &ATM_SKB(skb)->vcc->sk->sk_wmem_alloc);
+
+	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
 	DPRINTK("(unit %d): atm_skb(%p)->vcc(%p)->dev(%p)\n",
 	    pvcc->chan.unit, skb, ATM_SKB(skb)->vcc,
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/proc.c	2005-01-21 00:21:55 -02:00
@@ -71,9 +71,7 @@
 
 static inline int compare_family(struct sock *sk, int family)
 {
-	struct atm_vcc *vcc = atm_sk(sk);
-
-	return !family || (vcc->sk->sk_family == family);
+	return !family || (sk->sk_family == family);
 }
 
 static int __vcc_walk(struct sock **sock, int family, int *bucket, loff_t l)
@@ -203,13 +201,15 @@
 
 static void vcc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
+	struct sock *sk = sk_atm(vcc);
+
 	seq_printf(seq, "%p ", vcc);
 	if (!vcc->dev)
 		seq_printf(seq, "Unassigned    ");
 	else 
 		seq_printf(seq, "%3d %3d %5d ", vcc->dev->number, vcc->vpi,
 			vcc->vci);
-	switch (vcc->sk->sk_family) {
+	switch (sk->sk_family) {
 		case AF_ATMPVC:
 			seq_printf(seq, "PVC");
 			break;
@@ -217,12 +217,12 @@
 			seq_printf(seq, "SVC");
 			break;
 		default:
-			seq_printf(seq, "%3d", vcc->sk->sk_family);
+			seq_printf(seq, "%3d", sk->sk_family);
 	}
-	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d]\n", vcc->flags, vcc->sk->sk_err,
-		atomic_read(&vcc->sk->sk_wmem_alloc),vcc->sk->sk_sndbuf,
-		atomic_read(&vcc->sk->sk_rmem_alloc),vcc->sk->sk_rcvbuf,
-		atomic_read(&vcc->sk->sk_refcnt));
+	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d]\n", vcc->flags, sk->sk_err,
+		  atomic_read(&sk->sk_wmem_alloc), sk->sk_sndbuf,
+		  atomic_read(&sk->sk_rmem_alloc), sk->sk_rcvbuf,
+		  atomic_read(&sk->sk_refcnt));
 }
 
 static void svc_info(struct seq_file *seq, struct atm_vcc *vcc)
diff -Nru a/net/atm/raw.c b/net/atm/raw.c
--- a/net/atm/raw.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/raw.c	2005-01-21 00:21:55 -02:00
@@ -28,19 +28,23 @@
 void atm_push_raw(struct atm_vcc *vcc,struct sk_buff *skb)
 {
 	if (skb) {
-		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		vcc->sk->sk_data_ready(vcc->sk, skb->len);
+		struct sock *sk = sk_atm(vcc);
+
+		skb_queue_tail(&sk->sk_receive_queue, skb);
+		sk->sk_data_ready(sk, skb->len);
 	}
 }
 
 
 static void atm_pop_raw(struct atm_vcc *vcc,struct sk_buff *skb)
 {
-	DPRINTK("APopR (%d) %d -= %d\n", vcc->vci, vcc->sk->sk_wmem_alloc,
+	struct sock *sk = sk_atm(vcc);
+
+	DPRINTK("APopR (%d) %d -= %d\n", vcc->vci, sk->sk_wmem_alloc,
 		skb->truesize);
-	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
-	vcc->sk->sk_write_space(vcc->sk);
+	sk->sk_write_space(sk);
 }
 
 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/signaling.c	2005-01-21 00:21:55 -02:00
@@ -62,8 +62,8 @@
 	}
 #endif
 	atm_force_charge(sigd,skb->truesize);
-	skb_queue_tail(&sigd->sk->sk_receive_queue,skb);
-	sigd->sk->sk_data_ready(sigd->sk, skb->len);
+	skb_queue_tail(&sk_atm(sigd)->sk_receive_queue,skb);
+	sk_atm(sigd)->sk_data_ready(sk_atm(sigd), skb->len);
 }
 
 
@@ -97,15 +97,18 @@
 {
 	struct atmsvc_msg *msg;
 	struct atm_vcc *session_vcc;
+	struct sock *sk;
 
 	msg = (struct atmsvc_msg *) skb->data;
-	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
+	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	DPRINTK("sigd_send %d (0x%lx)\n",(int) msg->type,
 	  (unsigned long) msg->vcc);
 	vcc = *(struct atm_vcc **) &msg->vcc;
+	sk = sk_atm(vcc);
+
 	switch (msg->type) {
 		case as_okay:
-			vcc->sk->sk_err = -msg->reply;
+			sk->sk_err = -msg->reply;
 			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			if (!*vcc->local.sas_addr.prv &&
 			    !*vcc->local.sas_addr.pub) {
@@ -126,25 +129,25 @@
 		case as_error:
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
-			vcc->sk->sk_err = -msg->reply;
+			sk->sk_err = -msg->reply;
 			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			break;
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
 			DPRINTK("as_indicate!!!\n");
-			lock_sock(vcc->sk);
-			if (vcc->sk->sk_ack_backlog ==
-			    vcc->sk->sk_max_ack_backlog) {
+			lock_sock(sk);
+			if (sk->sk_ack_backlog ==
+			    sk->sk_max_ack_backlog) {
 				sigd_enq(NULL,as_reject,vcc,NULL,NULL);
 				dev_kfree_skb(skb);
 				goto as_indicate_complete;
 			}
-			vcc->sk->sk_ack_backlog++;
-			skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-			DPRINTK("waking vcc->sk->sk_sleep 0x%p\n", vcc->sk->sk_sleep);
-			vcc->sk->sk_state_change(vcc->sk);
+			sk->sk_ack_backlog++;
+			skb_queue_tail(&sk->sk_receive_queue, skb);
+			DPRINTK("waking sk->sk_sleep 0x%p\n", sk->sk_sleep);
+			sk->sk_state_change(sk);
 as_indicate_complete:
-			release_sock(vcc->sk);
+			release_sock(sk);
 			return 0;
 		case as_close:
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
@@ -155,7 +158,7 @@
 			break;
 		case as_addparty:
 		case as_dropparty:
-			vcc->sk->sk_err_soft = msg->reply;	/* < 0 failure, otherwise ep_ref */
+			sk->sk_err_soft = msg->reply;	/* < 0 failure, otherwise ep_ref */
 			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			break;
 		default:
@@ -163,7 +166,7 @@
 			    (int) msg->type);
 			return -EINVAL;
 	}
-	vcc->sk->sk_state_change(vcc->sk);
+	sk->sk_state_change(sk);
 out:
 	dev_kfree_skb(skb);
 	return 0;
@@ -213,7 +216,7 @@
 
 static void purge_vcc(struct atm_vcc *vcc)
 {
-	if (vcc->sk->sk_family == PF_ATMSVC &&
+	if (sk_atm(vcc)->sk_family == PF_ATMSVC &&
 	    !test_bit(ATM_VF_META,&vcc->flags)) {
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
 		vcc_release_async(vcc, -EUNATCH);
@@ -229,9 +232,9 @@
 
 	DPRINTK("sigd_close\n");
 	sigd = NULL;
-	if (skb_peek(&vcc->sk->sk_receive_queue))
+	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
 		printk(KERN_ERR "sigd_close: closing with requests pending\n");
-	skb_queue_purge(&vcc->sk->sk_receive_queue);
+	skb_queue_purge(&sk_atm(vcc)->sk_receive_queue);
 
 	read_lock(&vcc_sklist_lock);
 	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
@@ -268,7 +271,7 @@
 	DPRINTK("sigd_attach\n");
 	sigd = vcc;
 	vcc->dev = &sigd_dev;
-	vcc_insert_socket(vcc->sk);
+	vcc_insert_socket(sk_atm(vcc));
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
 #ifdef WAIT_FOR_DEMON
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	2005-01-21 00:21:55 -02:00
+++ b/net/atm/svc.c	2005-01-21 00:21:55 -02:00
@@ -53,20 +53,21 @@
 {
 	DEFINE_WAIT(wait);
 	struct sk_buff *skb;
+	struct sock *sk = sk_atm(vcc);
 
 	DPRINTK("svc_disconnect %p\n",vcc);
 	if (test_bit(ATM_VF_REGIS,&vcc->flags)) {
-		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc,as_close,NULL,NULL,NULL);
 		while (!test_bit(ATM_VF_RELEASED,&vcc->flags) && sigd) {
 			schedule();
-			prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(vcc->sk->sk_sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
 	}
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
-	while ((skb = skb_dequeue(&vcc->sk->sk_receive_queue)) != NULL) {
+	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 		DPRINTK("LISTEN REL\n");
 		sigd_enq2(NULL,as_reject,vcc,NULL,NULL,&vcc->qos,0);
 		dev_kfree_skb(skb);
@@ -317,8 +318,7 @@
 		goto out;
 	}
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
-	vcc->sk->sk_max_ack_backlog = backlog > 0 ? backlog :
-						    ATM_BACKLOG_DEFAULT;
+	sk->sk_max_ack_backlog = backlog > 0 ? backlog : ATM_BACKLOG_DEFAULT;
 	error = -sk->sk_err;
 out:
 	release_sock(sk);
@@ -347,8 +347,8 @@
 	while (1) {
 		DEFINE_WAIT(wait);
 
-		prepare_to_wait(old_vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
-		while (!(skb = skb_dequeue(&old_vcc->sk->sk_receive_queue)) &&
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		while (!(skb = skb_dequeue(&sk->sk_receive_queue)) &&
 		       sigd) {
 			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
 			if (test_bit(ATM_VF_CLOSE,&old_vcc->flags)) {
@@ -366,9 +366,9 @@
 				error = -ERESTARTSYS;
 				break;
 			}
-			prepare_to_wait(old_vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+			prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		}
-		finish_wait(old_vcc->sk->sk_sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
 		if (error)
 			goto out;
 		if (!skb) {
@@ -384,7 +384,7 @@
 		error = vcc_connect(newsock, msg->pvc.sap_addr.itf,
 				    msg->pvc.sap_addr.vpi, msg->pvc.sap_addr.vci);
 		dev_kfree_skb(skb);
-		old_vcc->sk->sk_ack_backlog--;
+		sk->sk_ack_backlog--;
 		if (error) {
 			sigd_enq2(NULL,as_reject,old_vcc,NULL,NULL,
 			    &old_vcc->qos,error);
@@ -393,23 +393,23 @@
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		set_bit(ATM_VF_WAITING, &new_vcc->flags);
-		prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
 		while (test_bit(ATM_VF_WAITING, &new_vcc->flags) && sigd) {
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
-			prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(new_vcc->sk->sk_sleep, &wait);
+		finish_wait(sk_atm(new_vcc)->sk_sleep, &wait);
 		if (!sigd) {
 			error = -EUNATCH;
 			goto out;
 		}
-		if (!new_vcc->sk->sk_err)
+		if (!sk_atm(new_vcc)->sk_err)
 			break;
-		if (new_vcc->sk->sk_err != ERESTARTSYS) {
-			error = -new_vcc->sk->sk_err;
+		if (sk_atm(new_vcc)->sk_err != ERESTARTSYS) {
+			error = -sk_atm(new_vcc)->sk_err;
 			goto out;
 		}
 	}
@@ -435,19 +435,20 @@
 
 int svc_change_qos(struct atm_vcc *vcc,struct atm_qos *qos)
 {
+	struct sock *sk = sk_atm(vcc);
 	DEFINE_WAIT(wait);
 
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc,as_modify,NULL,NULL,&vcc->local,qos,0);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) &&
 	       !test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(vcc->sk->sk_sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	if (!sigd) return -EUNATCH;
-	return -vcc->sk->sk_err;
+	return -sk->sk_err;
 }
 
 
@@ -532,28 +533,29 @@
 			int sockaddr_len, int flags)
 {
 	DEFINE_WAIT(wait);
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	lock_sock(vcc->sk);
+	lock_sock(sk);
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	sigd_enq(vcc, as_addparty, NULL, NULL,
 	         (struct sockaddr_atmsvc *) sockaddr);
 	if (flags & O_NONBLOCK) {
-		finish_wait(vcc->sk->sk_sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
 		error = -EINPROGRESS;
 		goto out;
 	}
 	DPRINTK("svc_addparty added wait queue\n");
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(vcc->sk->sk_sleep, &wait);
-	error = xchg(&vcc->sk->sk_err_soft, 0);
+	finish_wait(sk->sk_sleep, &wait);
+	error = xchg(&sk->sk_err_soft, 0);
 out:
-	release_sock(vcc->sk);
+	release_sock(sk);
 	return error;
 }
 
@@ -561,25 +563,26 @@
 static int svc_dropparty(struct socket *sock, int ep_ref)
 {
 	DEFINE_WAIT(wait);
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	lock_sock(vcc->sk);
+	lock_sock(sk);
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	sigd_enq2(vcc, as_dropparty, NULL, NULL, NULL, NULL, ep_ref);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(vcc->sk->sk_sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	if (!sigd) {
 		error = -EUNATCH;
 		goto out;
 	}
-	error = xchg(&vcc->sk->sk_err_soft, 0);
+	error = xchg(&sk->sk_err_soft, 0);
 out:
-	release_sock(vcc->sk);
+	release_sock(sk);
 	return error;
 }
 
diff -Nru a/net/sched/sch_atm.c b/net/sched/sch_atm.c
--- a/net/sched/sch_atm.c	2005-01-21 00:21:55 -02:00
+++ b/net/sched/sch_atm.c	2005-01-21 00:21:55 -02:00
@@ -519,7 +519,7 @@
 			memcpy(skb_push(skb,flow->hdr_len),flow->hdr,
 			    flow->hdr_len);
 			atomic_add(skb->truesize,
-				   &flow->vcc->sk->sk_wmem_alloc);
+				   &sk_atm(flow->vcc)->sk_wmem_alloc);
 			/* atm.atm_options are already set by atm_tc_enqueue */
 			(void) flow->vcc->send(flow->vcc,skb);
 		}



--------------010309010202000203030006--
