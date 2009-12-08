From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/20] net/atm/common.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:03 -0800
Message-ID: <8c0a7ad1d7af8085bb09f0be8cf7902fb2973b1f.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1054 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932411AbZLHF5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:13 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/common.c |  338 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 173 insertions(+), 165 deletions(-)

diff --git a/net/atm/common.c b/net/atm/common.c
index 17f7e5f..74d095a 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -19,11 +19,10 @@
 #include <linux/bitops.h>
 #include <linux/init.h>
 #include <net/sock.h>		/* struct sock */
+#include <linux/uaccess.h>
+#include <linux/poll.h>
 
-#include <asm/uaccess.h>
 #include <asm/atomic.h>
-#include <asm/poll.h>
-
 
 #include "resources.h"		/* atm_find_dev */
 #include "common.h"		/* prototypes */
@@ -32,13 +31,15 @@
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
 struct hlist_head vcc_hash[VCC_HTABLE_SIZE];
+EXPORT_SYMBOL(vcc_hash);
+
 DEFINE_RWLOCK(vcc_sklist_lock);
+EXPORT_SYMBOL(vcc_sklist_lock);
 
 static void __vcc_insert_socket(struct sock *sk)
 {
 	struct atm_vcc *vcc = atm_sk(sk);
-	struct hlist_head *head = &vcc_hash[vcc->vci &
-					(VCC_HTABLE_SIZE - 1)];
+	struct hlist_head *head = &vcc_hash[vcc->vci & (VCC_HTABLE_SIZE - 1)];
 	sk->sk_hash = vcc->vci & (VCC_HTABLE_SIZE - 1);
 	sk_add_node(sk, head);
 }
@@ -49,6 +50,7 @@ void vcc_insert_socket(struct sock *sk)
 	__vcc_insert_socket(sk);
 	write_unlock_irq(&vcc_sklist_lock);
 }
+EXPORT_SYMBOL(vcc_insert_socket);
 
 static void vcc_remove_socket(struct sock *sk)
 {
@@ -57,8 +59,7 @@ static void vcc_remove_socket(struct sock *sk)
 	write_unlock_irq(&vcc_sklist_lock);
 }
 
-
-static struct sk_buff *alloc_tx(struct atm_vcc *vcc,unsigned int size)
+static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
 {
 	struct sk_buff *skb;
 	struct sock *sk = sk_atm(vcc);
@@ -70,23 +71,20 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc,unsigned int size)
 	}
 	while (!(skb = alloc_skb(size, GFP_KERNEL)))
 		schedule();
-	pr_debug("AlTx %d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
+	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 	return skb;
 }
 
-
-EXPORT_SYMBOL(vcc_hash);
-EXPORT_SYMBOL(vcc_sklist_lock);
-EXPORT_SYMBOL(vcc_insert_socket);
-
 static void vcc_sock_destruct(struct sock *sk)
 {
 	if (atomic_read(&sk->sk_rmem_alloc))
-		printk(KERN_DEBUG "vcc_sock_destruct: rmem leakage (%d bytes) detected.\n", atomic_read(&sk->sk_rmem_alloc));
+		printk(KERN_DEBUG "%s: rmem leakage (%d bytes) detected.\n",
+		       __func__, atomic_read(&sk->sk_rmem_alloc));
 
 	if (atomic_read(&sk->sk_wmem_alloc))
-		printk(KERN_DEBUG "vcc_sock_destruct: wmem leakage (%d bytes) detected.\n", atomic_read(&sk->sk_wmem_alloc));
+		printk(KERN_DEBUG "%s: wmem leakage (%d bytes) detected.\n",
+		       __func__, atomic_read(&sk->sk_wmem_alloc));
 }
 
 static void vcc_def_wakeup(struct sock *sk)
@@ -142,8 +140,8 @@ int vcc_create(struct net *net, struct socket *sock, int protocol, int family)
 
 	vcc = atm_sk(sk);
 	vcc->dev = NULL;
-	memset(&vcc->local,0,sizeof(struct sockaddr_atmsvc));
-	memset(&vcc->remote,0,sizeof(struct sockaddr_atmsvc));
+	memset(&vcc->local, 0, sizeof(struct sockaddr_atmsvc));
+	memset(&vcc->remote, 0, sizeof(struct sockaddr_atmsvc));
 	vcc->qos.txtp.max_sdu = 1 << 16; /* for meta VCs */
 	atomic_set(&sk->sk_wmem_alloc, 1);
 	atomic_set(&sk->sk_rmem_alloc, 0);
@@ -156,7 +154,6 @@ int vcc_create(struct net *net, struct socket *sock, int protocol, int family)
 	return 0;
 }
 
-
 static void vcc_destroy_socket(struct sock *sk)
 {
 	struct atm_vcc *vcc = atm_sk(sk);
@@ -171,7 +168,7 @@ static void vcc_destroy_socket(struct sock *sk)
 			vcc->push(vcc, NULL); /* atmarpd has no push */
 
 		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-			atm_return(vcc,skb->truesize);
+			atm_return(vcc, skb->truesize);
 			kfree_skb(skb);
 		}
 
@@ -182,7 +179,6 @@ static void vcc_destroy_socket(struct sock *sk)
 	vcc_remove_socket(sk);
 }
 
-
 int vcc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -197,7 +193,6 @@ int vcc_release(struct socket *sock)
 	return 0;
 }
 
-
 void vcc_release_async(struct atm_vcc *vcc, int reply)
 {
 	struct sock *sk = sk_atm(vcc);
@@ -208,8 +203,6 @@ void vcc_release_async(struct atm_vcc *vcc, int reply)
 	clear_bit(ATM_VF_WAITING, &vcc->flags);
 	sk->sk_state_change(sk);
 }
-
-
 EXPORT_SYMBOL(vcc_release_async);
 
 
@@ -235,36 +228,37 @@ void atm_dev_release_vccs(struct atm_dev *dev)
 	write_unlock_irq(&vcc_sklist_lock);
 }
 
-
-static int adjust_tp(struct atm_trafprm *tp,unsigned char aal)
+static int adjust_tp(struct atm_trafprm *tp, unsigned char aal)
 {
 	int max_sdu;
 
-	if (!tp->traffic_class) return 0;
+	if (!tp->traffic_class)
+		return 0;
 	switch (aal) {
-		case ATM_AAL0:
-			max_sdu = ATM_CELL_SIZE-1;
-			break;
-		case ATM_AAL34:
-			max_sdu = ATM_MAX_AAL34_PDU;
-			break;
-		default:
-			pr_warning("AAL problems ... (%d)\n", aal);
-			/* fall through */
-		case ATM_AAL5:
-			max_sdu = ATM_MAX_AAL5_PDU;
+	case ATM_AAL0:
+		max_sdu = ATM_CELL_SIZE-1;
+		break;
+	case ATM_AAL34:
+		max_sdu = ATM_MAX_AAL34_PDU;
+		break;
+	default:
+		pr_warning("AAL problems ... (%d)\n", aal);
+		/* fall through */
+	case ATM_AAL5:
+		max_sdu = ATM_MAX_AAL5_PDU;
 	}
-	if (!tp->max_sdu) tp->max_sdu = max_sdu;
-	else if (tp->max_sdu > max_sdu) return -EINVAL;
-	if (!tp->max_cdv) tp->max_cdv = ATM_MAX_CDV;
+	if (!tp->max_sdu)
+		tp->max_sdu = max_sdu;
+	else if (tp->max_sdu > max_sdu)
+		return -EINVAL;
+	if (!tp->max_cdv)
+		tp->max_cdv = ATM_MAX_CDV;
 	return 0;
 }
 
-
 static int check_ci(const struct atm_vcc *vcc, short vpi, int vci)
 {
-	struct hlist_head *head = &vcc_hash[vci &
-					(VCC_HTABLE_SIZE - 1)];
+	struct hlist_head *head = &vcc_hash[vci & (VCC_HTABLE_SIZE - 1)];
 	struct hlist_node *node;
 	struct sock *s;
 	struct atm_vcc *walk;
@@ -288,7 +282,6 @@ static int check_ci(const struct atm_vcc *vcc, short vpi, int vci)
 	return 0;
 }
 
-
 static int find_ci(const struct atm_vcc *vcc, short *vpi, int *vci)
 {
 	static short p;        /* poor man's per-device cache */
@@ -326,14 +319,13 @@ static int find_ci(const struct atm_vcc *vcc, short *vpi, int *vci)
 		if ((c == ATM_NOT_RSV_VCI || *vci != ATM_VCI_ANY) &&
 		    *vpi == ATM_VPI_ANY) {
 			p++;
-			if (p >= 1 << vcc->dev->ci_range.vpi_bits) p = 0;
+			if (p >= 1 << vcc->dev->ci_range.vpi_bits)
+				p = 0;
 		}
-	}
-	while (old_p != p || old_c != c);
+	} while (old_p != p || old_c != c);
 	return -EADDRINUSE;
 }
 
-
 static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, short vpi,
 			 int vci)
 {
@@ -361,27 +353,29 @@ static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, short vpi,
 	__vcc_insert_socket(sk);
 	write_unlock_irq(&vcc_sklist_lock);
 	switch (vcc->qos.aal) {
-		case ATM_AAL0:
-			error = atm_init_aal0(vcc);
-			vcc->stats = &dev->stats.aal0;
-			break;
-		case ATM_AAL34:
-			error = atm_init_aal34(vcc);
-			vcc->stats = &dev->stats.aal34;
-			break;
-		case ATM_NO_AAL:
-			/* ATM_AAL5 is also used in the "0 for default" case */
-			vcc->qos.aal = ATM_AAL5;
-			/* fall through */
-		case ATM_AAL5:
-			error = atm_init_aal5(vcc);
-			vcc->stats = &dev->stats.aal5;
-			break;
-		default:
-			error = -EPROTOTYPE;
+	case ATM_AAL0:
+		error = atm_init_aal0(vcc);
+		vcc->stats = &dev->stats.aal0;
+		break;
+	case ATM_AAL34:
+		error = atm_init_aal34(vcc);
+		vcc->stats = &dev->stats.aal34;
+		break;
+	case ATM_NO_AAL:
+		/* ATM_AAL5 is also used in the "0 for default" case */
+		vcc->qos.aal = ATM_AAL5;
+		/* fall through */
+	case ATM_AAL5:
+		error = atm_init_aal5(vcc);
+		vcc->stats = &dev->stats.aal5;
+		break;
+	default:
+		error = -EPROTOTYPE;
 	}
-	if (!error) error = adjust_tp(&vcc->qos.txtp,vcc->qos.aal);
-	if (!error) error = adjust_tp(&vcc->qos.rxtp,vcc->qos.aal);
+	if (!error)
+		error = adjust_tp(&vcc->qos.txtp, vcc->qos.aal);
+	if (!error)
+		error = adjust_tp(&vcc->qos.rxtp, vcc->qos.aal);
 	if (error)
 		goto fail;
 	pr_debug("VCC %d.%d, AAL %d\n", vpi, vci, vcc->qos.aal);
@@ -397,7 +391,8 @@ static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, short vpi,
 		 vcc->qos.rxtp.max_sdu);
 
 	if (dev->ops->open) {
-		if ((error = dev->ops->open(vcc)))
+		error = dev->ops->open(vcc);
+		if (error)
 			goto fail;
 	}
 	return 0;
@@ -411,7 +406,6 @@ fail_module_put:
 	return error;
 }
 
-
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 {
 	struct atm_dev *dev;
@@ -427,16 +421,16 @@ int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 		return -EINVAL;
 
 	if (vpi != ATM_VPI_UNSPEC && vci != ATM_VCI_UNSPEC)
-		clear_bit(ATM_VF_PARTIAL,&vcc->flags);
+		clear_bit(ATM_VF_PARTIAL, &vcc->flags);
 	else
-		if (test_bit(ATM_VF_PARTIAL,&vcc->flags))
+		if (test_bit(ATM_VF_PARTIAL, &vcc->flags))
 			return -EINVAL;
 	pr_debug("(TX: cl %d,bw %d-%d,sdu %d; "
 		 "RX: cl %d,bw %d-%d,sdu %d,AAL %s%d)\n",
 		 vcc->qos.txtp.traffic_class, vcc->qos.txtp.min_pcr,
 		 vcc->qos.txtp.max_pcr, vcc->qos.txtp.max_sdu,
 		 vcc->qos.rxtp.traffic_class, vcc->qos.rxtp.min_pcr,
-		 vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu,
+		 vcc->qos.rxtp.max_pcr, vcc->qos.rxtp.max_sdu,
 		 vcc->qos.aal == ATM_AAL5 ? "" :
 		 vcc->qos.aal == ATM_AAL0 ? "" : " ??? code ",
 		 vcc->qos.aal == ATM_AAL0 ? 0 : vcc->qos.aal);
@@ -446,12 +440,14 @@ int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 	    vcc->qos.rxtp.traffic_class == ATM_ANYCLASS)
 		return -EINVAL;
 	if (likely(itf != ATM_ITF_ANY)) {
-		dev = try_then_request_module(atm_dev_lookup(itf), "atm-device-%d", itf);
+		dev = try_then_request_module(atm_dev_lookup(itf),
+					      "atm-device-%d", itf);
 	} else {
 		dev = NULL;
 		mutex_lock(&atm_dev_mutex);
 		if (!list_empty(&atm_devs)) {
-			dev = list_entry(atm_devs.next, struct atm_dev, dev_list);
+			dev = list_entry(atm_devs.next,
+					 struct atm_dev, dev_list);
 			atm_dev_hold(dev);
 		}
 		mutex_unlock(&atm_dev_mutex);
@@ -464,13 +460,12 @@ int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 		return error;
 	}
 	if (vpi == ATM_VPI_UNSPEC || vci == ATM_VCI_UNSPEC)
-		set_bit(ATM_VF_PARTIAL,&vcc->flags);
-	if (test_bit(ATM_VF_READY,&ATM_SD(sock)->flags))
+		set_bit(ATM_VF_PARTIAL, &vcc->flags);
+	if (test_bit(ATM_VF_READY, &ATM_SD(sock)->flags))
 		sock->state = SS_CONNECTED;
 	return 0;
 }
 
-
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		size_t size, int flags)
 {
@@ -484,8 +479,8 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	if (flags & ~MSG_DONTWAIT)		/* only handle MSG_DONTWAIT */
 		return -EOPNOTSUPP;
 	vcc = ATM_SD(sock);
-	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-	    test_bit(ATM_VF_CLOSE,&vcc->flags) ||
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
 	    !test_bit(ATM_VF_READY, &vcc->flags))
 		return 0;
 
@@ -509,7 +504,6 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	return copied;
 }
 
-
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		size_t total_len)
 {
@@ -517,7 +511,7 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 	DEFINE_WAIT(wait);
 	struct atm_vcc *vcc;
 	struct sk_buff *skb;
-	int eff,error;
+	int eff, error;
 	const void __user *buff;
 	int size;
 
@@ -556,7 +550,7 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 	eff = (size+3) & ~3; /* align to word boundary */
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	error = 0;
-	while (!(skb = alloc_tx(vcc,eff))) {
+	while (!(skb = alloc_tx(vcc, eff))) {
 		if (m->msg_flags & MSG_DONTWAIT) {
 			error = -EAGAIN;
 			break;
@@ -566,9 +560,9 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 			error = -ERESTARTSYS;
 			break;
 		}
-		if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-		    test_bit(ATM_VF_CLOSE,&vcc->flags) ||
-		    !test_bit(ATM_VF_READY,&vcc->flags)) {
+		if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+		    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+		    !test_bit(ATM_VF_READY, &vcc->flags)) {
 			error = -EPIPE;
 			send_sig(SIGPIPE, current, 0);
 			break;
@@ -580,20 +574,20 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		goto out;
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
-	if (copy_from_user(skb_put(skb,size),buff,size)) {
+	if (copy_from_user(skb_put(skb, size), buff, size)) {
 		kfree_skb(skb);
 		error = -EFAULT;
 		goto out;
 	}
-	if (eff != size) memset(skb->data+size,0,eff-size);
-	error = vcc->dev->ops->send(vcc,skb);
+	if (eff != size)
+		memset(skb->data + size, 0, eff-size);
+	error = vcc->dev->ops->send(vcc, skb);
 	error = error ? error : size;
 out:
 	release_sock(sk);
 	return error;
 }
 
-
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
 	struct sock *sk = sock->sk;
@@ -629,8 +623,7 @@ unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 	return mask;
 }
 
-
-static int atm_change_qos(struct atm_vcc *vcc,struct atm_qos *qos)
+static int atm_change_qos(struct atm_vcc *vcc, struct atm_qos *qos)
 {
 	int error;
 
@@ -642,25 +635,31 @@ static int atm_change_qos(struct atm_vcc *vcc,struct atm_qos *qos)
 	    qos->rxtp.traffic_class != vcc->qos.rxtp.traffic_class ||
 	    qos->txtp.traffic_class != vcc->qos.txtp.traffic_class)
 		return -EINVAL;
-	error = adjust_tp(&qos->txtp,qos->aal);
-	if (!error) error = adjust_tp(&qos->rxtp,qos->aal);
-	if (error) return error;
-	if (!vcc->dev->ops->change_qos) return -EOPNOTSUPP;
+	error = adjust_tp(&qos->txtp, qos->aal);
+	if (!error)
+		error = adjust_tp(&qos->rxtp, qos->aal);
+	if (error)
+		return error;
+	if (!vcc->dev->ops->change_qos)
+		return -EOPNOTSUPP;
 	if (sk_atm(vcc)->sk_family == AF_ATMPVC)
-		return vcc->dev->ops->change_qos(vcc,qos,ATM_MF_SET);
-	return svc_change_qos(vcc,qos);
+		return vcc->dev->ops->change_qos(vcc, qos, ATM_MF_SET);
+	return svc_change_qos(vcc, qos);
 }
 
-
 static int check_tp(const struct atm_trafprm *tp)
 {
 	/* @@@ Should be merged with adjust_tp */
-	if (!tp->traffic_class || tp->traffic_class == ATM_ANYCLASS) return 0;
+	if (!tp->traffic_class || tp->traffic_class == ATM_ANYCLASS)
+		return 0;
 	if (tp->traffic_class != ATM_UBR && !tp->min_pcr && !tp->pcr &&
-	    !tp->max_pcr) return -EINVAL;
-	if (tp->min_pcr == ATM_MAX_PCR) return -EINVAL;
+	    !tp->max_pcr)
+		return -EINVAL;
+	if (tp->min_pcr == ATM_MAX_PCR)
+		return -EINVAL;
 	if (tp->min_pcr && tp->max_pcr && tp->max_pcr != ATM_MAX_PCR &&
-	    tp->min_pcr > tp->max_pcr) return -EINVAL;
+	    tp->min_pcr > tp->max_pcr)
+		return -EINVAL;
 	/*
 	 * We allow pcr to be outside [min_pcr,max_pcr], because later
 	 * adjustment may still push it in the valid range.
@@ -668,7 +667,6 @@ static int check_tp(const struct atm_trafprm *tp)
 	return 0;
 }
 
-
 static int check_qos(const struct atm_qos *qos)
 {
 	int error;
@@ -678,9 +676,11 @@ static int check_qos(const struct atm_qos *qos)
 	if (qos->txtp.traffic_class != qos->rxtp.traffic_class &&
 	    qos->txtp.traffic_class && qos->rxtp.traffic_class &&
 	    qos->txtp.traffic_class != ATM_ANYCLASS &&
-	    qos->rxtp.traffic_class != ATM_ANYCLASS) return -EINVAL;
+	    qos->rxtp.traffic_class != ATM_ANYCLASS)
+		return -EINVAL;
 	error = check_tp(&qos->txtp);
-	if (error) return error;
+	if (error)
+		return error;
 	return check_tp(&qos->rxtp);
 }
 
@@ -696,37 +696,41 @@ int vcc_setsockopt(struct socket *sock, int level, int optname,
 
 	vcc = ATM_SD(sock);
 	switch (optname) {
-		case SO_ATMQOS:
-			{
-				struct atm_qos qos;
-
-				if (copy_from_user(&qos,optval,sizeof(qos)))
-					return -EFAULT;
-				error = check_qos(&qos);
-				if (error) return error;
-				if (sock->state == SS_CONNECTED)
-					return atm_change_qos(vcc,&qos);
-				if (sock->state != SS_UNCONNECTED)
-					return -EBADFD;
-				vcc->qos = qos;
-				set_bit(ATM_VF_HASQOS,&vcc->flags);
-				return 0;
-			}
-		case SO_SETCLP:
-			if (get_user(value,(unsigned long __user *)optval))
-				return -EFAULT;
-			if (value) vcc->atm_options |= ATM_ATMOPT_CLP;
-			else vcc->atm_options &= ~ATM_ATMOPT_CLP;
-			return 0;
-		default:
-			if (level == SOL_SOCKET) return -EINVAL;
-			break;
+	case SO_ATMQOS:
+	{
+		struct atm_qos qos;
+
+		if (copy_from_user(&qos, optval, sizeof(qos)))
+			return -EFAULT;
+		error = check_qos(&qos);
+		if (error)
+			return error;
+		if (sock->state == SS_CONNECTED)
+			return atm_change_qos(vcc, &qos);
+		if (sock->state != SS_UNCONNECTED)
+			return -EBADFD;
+		vcc->qos = qos;
+		set_bit(ATM_VF_HASQOS, &vcc->flags);
+		return 0;
 	}
-	if (!vcc->dev || !vcc->dev->ops->setsockopt) return -EINVAL;
-	return vcc->dev->ops->setsockopt(vcc,level,optname,optval,optlen);
+	case SO_SETCLP:
+		if (get_user(value, (unsigned long __user *)optval))
+			return -EFAULT;
+		if (value)
+			vcc->atm_options |= ATM_ATMOPT_CLP;
+		else
+			vcc->atm_options &= ~ATM_ATMOPT_CLP;
+		return 0;
+	default:
+		if (level == SOL_SOCKET)
+			return -EINVAL;
+		break;
+	}
+	if (!vcc->dev || !vcc->dev->ops->setsockopt)
+		return -EINVAL;
+	return vcc->dev->ops->setsockopt(vcc, level, optname, optval, optlen);
 }
 
-
 int vcc_getsockopt(struct socket *sock, int level, int optname,
 		   char __user *optval, int __user *optlen)
 {
@@ -740,33 +744,33 @@ int vcc_getsockopt(struct socket *sock, int level, int optname,
 
 	vcc = ATM_SD(sock);
 	switch (optname) {
-		case SO_ATMQOS:
-			if (!test_bit(ATM_VF_HASQOS,&vcc->flags))
-				return -EINVAL;
-			return copy_to_user(optval,&vcc->qos,sizeof(vcc->qos)) ?
-			    -EFAULT : 0;
-		case SO_SETCLP:
-			return put_user(vcc->atm_options & ATM_ATMOPT_CLP ? 1 :
-			  0,(unsigned long __user *)optval) ? -EFAULT : 0;
-		case SO_ATMPVC:
-			{
-				struct sockaddr_atmpvc pvc;
-
-				if (!vcc->dev ||
-				    !test_bit(ATM_VF_ADDR,&vcc->flags))
-					return -ENOTCONN;
-				pvc.sap_family = AF_ATMPVC;
-				pvc.sap_addr.itf = vcc->dev->number;
-				pvc.sap_addr.vpi = vcc->vpi;
-				pvc.sap_addr.vci = vcc->vci;
-				return copy_to_user(optval,&pvc,sizeof(pvc)) ?
-				    -EFAULT : 0;
-			}
-		default:
-			if (level == SOL_SOCKET) return -EINVAL;
+	case SO_ATMQOS:
+		if (!test_bit(ATM_VF_HASQOS, &vcc->flags))
+			return -EINVAL;
+		return copy_to_user(optval, &vcc->qos, sizeof(vcc->qos))
+			? -EFAULT : 0;
+	case SO_SETCLP:
+		return put_user(vcc->atm_options & ATM_ATMOPT_CLP ? 1 : 0,
+				(unsigned long __user *)optval) ? -EFAULT : 0;
+	case SO_ATMPVC:
+	{
+		struct sockaddr_atmpvc pvc;
+
+		if (!vcc->dev || !test_bit(ATM_VF_ADDR, &vcc->flags))
+			return -ENOTCONN;
+		pvc.sap_family = AF_ATMPVC;
+		pvc.sap_addr.itf = vcc->dev->number;
+		pvc.sap_addr.vpi = vcc->vpi;
+		pvc.sap_addr.vci = vcc->vci;
+		return copy_to_user(optval, &pvc, sizeof(pvc)) ? -EFAULT : 0;
+	}
+	default:
+		if (level == SOL_SOCKET)
+			return -EINVAL;
 			break;
 	}
-	if (!vcc->dev || !vcc->dev->ops->getsockopt) return -EINVAL;
+	if (!vcc->dev || !vcc->dev->ops->getsockopt)
+		return -EINVAL;
 	return vcc->dev->ops->getsockopt(vcc, level, optname, optval, len);
 }
 
@@ -774,22 +778,26 @@ static int __init atm_init(void)
 {
 	int error;
 
-	if ((error = proto_register(&vcc_proto, 0)) < 0)
+	error = proto_register(&vcc_proto, 0);
+	if (error < 0)
 		goto out;
-
-	if ((error = atmpvc_init()) < 0) {
+	error = atmpvc_init();
+	if (error < 0) {
 		pr_err("atmpvc_init() failed with %d\n", error);
 		goto out_unregister_vcc_proto;
 	}
-	if ((error = atmsvc_init()) < 0) {
+	error = atmsvc_init();
+	if (error < 0) {
 		pr_err("atmsvc_init() failed with %d\n", error);
 		goto out_atmpvc_exit;
 	}
-	if ((error = atm_proc_init()) < 0) {
+	error = atm_proc_init();
+	if (error < 0) {
 		pr_err("atm_proc_init() failed with %d\n", error);
 		goto out_atmsvc_exit;
 	}
-	if ((error = atm_sysfs_init()) < 0) {
+	error = atm_sysfs_init();
+	if (error < 0) {
 		pr_err("atm_sysfs_init() failed with %d\n", error);
 		goto out_atmproc_exit;
 	}
-- 
1.6.6.rc0.57.gad7a

