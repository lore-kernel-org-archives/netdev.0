From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM] some misc sk-related fixups for atm
Date: Tue, 15 Jul 2003 08:52:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307151254.h6FCshsG028747@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this set does away with a few redundant bits in the struct atm_vcc,
in particular .reply and .svc_callback.  WAITING becomes a flag 
instead of overloading sk_err.  it also changes the wake_up's to
the appropriate sk event.


[atm]: use sk_state_change() and eliminate vcc->callback()

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1360  -> 1.1361 
#	       net/atm/svc.c	1.19    -> 1.20   
#	 net/atm/signaling.c	1.15    -> 1.16   
#	include/linux/atmdev.h	1.19    -> 1.20   
#	    net/atm/common.c	1.36    -> 1.37   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/20	chas@relax.cmf.nrl.navy.mil	1.1361
# use sk_state_change() and eliminate vcc->callback()
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Mon Jun 23 09:54:19 2003
+++ b/include/linux/atmdev.h	Mon Jun 23 09:54:19 2003
@@ -297,7 +297,6 @@
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
 	struct sockaddr_atmsvc remote;
-	void (*callback)(struct atm_vcc *vcc);
 	int		reply;		/* also used by ATMTCP */
 	/* Multipoint part ------------------------------------------------- */
 	struct atm_vcc	*session;	/* session VCC descriptor */
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 09:54:19 2003
+++ b/net/atm/common.c	Mon Jun 23 09:54:19 2003
@@ -215,6 +215,14 @@
 
 	kfree(sk->sk_protinfo);
 }
+
+static void vcc_def_wakeup(struct sock *sk)
+{
+	read_lock(&sk->sk_callback_lock);
+	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		wake_up(sk->sk_sleep);
+	read_unlock(&sk->sk_callback_lock);
+}
  
 int vcc_create(struct socket *sock, int protocol, int family)
 {
@@ -228,6 +236,7 @@
 	if (!sk)
 		return -ENOMEM;
 	sock_init_data(NULL, sk);
+	sk->sk_state_change = vcc_def_wakeup;
 
 	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
 	if (!vcc) {
@@ -238,7 +247,6 @@
 	memset(vcc, 0, sizeof(*vcc));
 	vcc->sk = sk;
 	vcc->dev = NULL;
-	vcc->callback = NULL;
 	memset(&vcc->local,0,sizeof(struct sockaddr_atmsvc));
 	memset(&vcc->remote,0,sizeof(struct sockaddr_atmsvc));
 	vcc->qos.txtp.max_sdu = 1 << 16; /* for meta VCs */
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jun 23 09:54:19 2003
+++ b/net/atm/signaling.c	Mon Jun 23 09:54:19 2003
@@ -137,11 +137,8 @@
 			}
 			vcc->sk->sk_ack_backlog++;
 			skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-			if (vcc->callback) {
-				DPRINTK("waking vcc->sleep 0x%p\n",
-				    &vcc->sleep);
-				vcc->callback(vcc);
-			}
+			DPRINTK("waking vcc->sleep 0x%p\n", &vcc->sleep);
+			vcc->sk->sk_state_change(vcc->sk);
 as_indicate_complete:
 			release_sock(vcc->sk);
 			return 0;
@@ -159,7 +156,7 @@
 			    (int) msg->type);
 			return -EINVAL;
 	}
-	if (vcc->callback) vcc->callback(vcc);
+	vcc->sk->sk_state_change(vcc->sk);
 	dev_kfree_skb(skb);
 	return 0;
 }
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Jun 23 09:54:19 2003
+++ b/net/atm/svc.c	Mon Jun 23 09:54:19 2003
@@ -43,14 +43,6 @@
  */
 
 
-void svc_callback(struct atm_vcc *vcc)
-{
-	wake_up(&vcc->sleep);
-}
-
-
-
-
 static int svc_shutdown(struct socket *sock,int how)
 {
 	return 0;
@@ -547,7 +539,6 @@
 	sock->ops = &svc_proto_ops;
 	error = vcc_create(sock, protocol, AF_ATMSVC);
 	if (error) return error;
-	ATM_SD(sock)->callback = svc_callback;
 	ATM_SD(sock)->local.sas_family = AF_ATMSVC;
 	ATM_SD(sock)->remote.sas_family = AF_ATMSVC;
 	return 0;

[atm]: eliminate vcc->sleep in favor of sk->sk_sleep

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1361  -> 1.1362 
#	       net/atm/lec.c	1.30    -> 1.31   
#	       net/atm/svc.c	1.20    -> 1.21   
#	drivers/atm/atmtcp.c	1.11    -> 1.12   
#	 net/atm/signaling.c	1.16    -> 1.17   
#	       net/atm/mpc.c	1.21    -> 1.22   
#	include/linux/atmdev.h	1.20    -> 1.21   
#	       net/atm/raw.c	1.4     -> 1.5    
#	      net/atm/clip.c	1.18    -> 1.19   
#	    net/atm/common.c	1.37    -> 1.38   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/23	chas@relax.cmf.nrl.navy.mil	1.1362
# eliminate vcc->sleep
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Mon Jun 23 10:58:07 2003
+++ b/drivers/atm/atmtcp.c	Mon Jun 23 10:58:07 2003
@@ -66,7 +66,7 @@
 	*(struct atm_vcc **) &new_msg->vcc = vcc;
 	old_test = test_bit(flag,&vcc->flags);
 	out_vcc->push(out_vcc,skb);
-	add_wait_queue(&vcc->sleep,&wait);
+	add_wait_queue(vcc->sk->sk_sleep, &wait);
 	while (test_bit(flag,&vcc->flags) == old_test) {
 		mb();
 		out_vcc = PRIV(vcc->dev) ? PRIV(vcc->dev)->vcc : NULL;
@@ -78,7 +78,7 @@
 		schedule();
 	}
 	current->state = TASK_RUNNING;
-	remove_wait_queue(&vcc->sleep,&wait);
+	remove_wait_queue(vcc->sk->sk_sleep, &wait);
 	return error;
 }
 
@@ -103,7 +103,7 @@
 		    msg->type);
 		return -EINVAL;
 	}
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 	return 0;
 }
 
@@ -257,7 +257,7 @@
 		walk = atm_sk(s);
 		if (walk->dev != atmtcp_dev)
 			continue;
-		wake_up(&walk->sleep);
+		wake_up(walk->sk->sk_sleep);
 	}
 	read_unlock(&vcc_sklist_lock);
 }
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Mon Jun 23 10:58:07 2003
+++ b/include/linux/atmdev.h	Mon Jun 23 10:58:07 2003
@@ -291,7 +291,6 @@
 	void		*dev_data;	/* per-device data */
 	void		*proto_data;	/* per-protocol data */
 	struct k_atm_aal_stats *stats;	/* pointer to AAL stats group */
-	wait_queue_head_t sleep;	/* if socket is busy */
 	struct sock	*sk;		/* socket backpointer */
 	/* SVC part --- may move later ------------------------------------- */
 	short		itf;		/* interface number */
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/clip.c	Mon Jun 23 10:58:07 2003
@@ -67,7 +67,7 @@
 	ctrl->ip = ip;
 	atm_force_charge(atmarpd,skb->truesize);
 	skb_queue_tail(&atmarpd->sk->sk_receive_queue, skb);
-	wake_up(&atmarpd->sleep);
+	wake_up(atmarpd->sk->sk_sleep);
 	return 0;
 }
 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/common.c	Mon Jun 23 10:58:07 2003
@@ -235,7 +235,7 @@
 	sk = sk_alloc(family, GFP_KERNEL, 1, NULL);
 	if (!sk)
 		return -ENOMEM;
-	sock_init_data(NULL, sk);
+	sock_init_data(sock, sk);
 	sk->sk_state_change = vcc_def_wakeup;
 
 	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
@@ -257,8 +257,6 @@
 	vcc->push_oam = NULL;
 	vcc->vpi = vcc->vci = 0; /* no VCI/VPI yet */
 	vcc->atm_options = vcc->aal_options = 0;
-	init_waitqueue_head(&vcc->sleep);
-	sk->sk_sleep = &vcc->sleep;
 	sk->sk_destruct = vcc_sock_destruct;
 	sock->sk = sk;
 	return 0;
@@ -310,7 +308,7 @@
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	vcc->reply = reply;
 	vcc->sk->sk_err = -reply;
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 }
 
 
@@ -557,7 +555,7 @@
 	}
 	/* verify_area is done by net/socket.c */
 	eff = (size+3) & ~3; /* align to word boundary */
-	prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	error = 0;
 	while (!(skb = alloc_tx(vcc,eff))) {
 		if (m->msg_flags & MSG_DONTWAIT) {
@@ -578,9 +576,9 @@
 			error = -EPIPE;
 			break;
 		}
-		prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	if (error)
 		goto out;
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
@@ -605,7 +603,7 @@
 	unsigned int mask;
 
 	vcc = ATM_SD(sock);
-	poll_wait(file,&vcc->sleep,wait);
+	poll_wait(file, vcc->sk->sk_sleep, wait);
 	mask = 0;
 	if (skb_peek(&vcc->sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/lec.c	Mon Jun 23 10:58:07 2003
@@ -134,7 +134,7 @@
                 priv = (struct lec_priv *)dev->priv;
                 atm_force_charge(priv->lecd, skb2->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                wake_up(&priv->lecd->sleep);
+                wake_up(priv->lecd->sk->sk_sleep);
         }
 
         return;
@@ -513,7 +513,7 @@
                         memcpy(skb2->data, mesg, sizeof(struct atmlec_msg));
                         atm_force_charge(priv->lecd, skb2->truesize);
                         skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                        wake_up(&priv->lecd->sleep);
+                        wake_up(priv->lecd->sk->sk_sleep);
                 }
                 if (f != NULL) br_fdb_put_hook(f);
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
@@ -598,13 +598,13 @@
 
         atm_force_charge(priv->lecd, skb->truesize);
 	skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb);
-        wake_up(&priv->lecd->sleep);
+        wake_up(priv->lecd->sk->sk_sleep);
 
         if (data != NULL) {
                 DPRINTK("lec: about to send %d bytes of data\n", data->len);
                 atm_force_charge(priv->lecd, data->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, data);
-                wake_up(&priv->lecd->sleep);
+                wake_up(priv->lecd->sk->sk_sleep);
         }
 
         return 0;
@@ -686,7 +686,7 @@
         if (memcmp(skb->data, lec_ctrl_magic, 4) ==0) { /* Control frame, to daemon*/
                 DPRINTK("%s: To daemon\n",dev->name);
                 skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-                wake_up(&vcc->sleep);
+                wake_up(vcc->sk->sk_sleep);
         } else { /* Data frame, queue to protocol handlers */
                 unsigned char *dst;
 
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/mpc.c	Mon Jun 23 10:58:07 2003
@@ -669,7 +669,7 @@
 		dprintk("mpoa: (%s) mpc_push: control packet arrived\n", dev->name);
 		/* Pass control packets to daemon */
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(&vcc->sleep);
+		wake_up(vcc->sk->sk_sleep);
 		return;
 	}
 
@@ -947,7 +947,7 @@
 	memcpy(skb->data, mesg, sizeof(struct k_message));
 	atm_force_charge(mpc->mpoad_vcc, skb->truesize);
 	skb_queue_tail(&mpc->mpoad_vcc->sk->sk_receive_queue, skb);
-	wake_up(&mpc->mpoad_vcc->sleep);
+	wake_up(mpc->mpoad_vcc->sk->sk_sleep);
 
 	return 0;
 }
@@ -1226,7 +1226,7 @@
 
 	atm_force_charge(vcc, skb->truesize);
 	skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 	dprintk("mpoa: purge_egress_shortcut: exiting:\n");
 
 	return;
diff -Nru a/net/atm/raw.c b/net/atm/raw.c
--- a/net/atm/raw.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/raw.c	Mon Jun 23 10:58:07 2003
@@ -29,7 +29,7 @@
 {
 	if (skb) {
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(&vcc->sleep);
+		wake_up(vcc->sk->sk_sleep);
 	}
 }
 
@@ -40,7 +40,7 @@
 		skb->truesize);
 	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 }
 
 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/signaling.c	Mon Jun 23 10:58:07 2003
@@ -61,7 +61,7 @@
 #endif
 	atm_force_charge(sigd,skb->truesize);
 	skb_queue_tail(&sigd->sk->sk_receive_queue,skb);
-	wake_up(&sigd->sleep);
+	wake_up(sigd->sk->sk_sleep);
 }
 
 
@@ -137,7 +137,7 @@
 			}
 			vcc->sk->sk_ack_backlog++;
 			skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-			DPRINTK("waking vcc->sleep 0x%p\n", &vcc->sleep);
+			DPRINTK("waking vcc->sk->sk_sleep 0x%p\n", vcc->sk->sk_sleep);
 			vcc->sk->sk_state_change(vcc->sk);
 as_indicate_complete:
 			release_sock(vcc->sk);
@@ -204,7 +204,7 @@
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
 		vcc->reply = -EUNATCH;
 		vcc->sk->sk_err = EUNATCH;
-		wake_up(&vcc->sleep);
+		wake_up(vcc->sk->sk_sleep);
 	}
 }
 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/svc.c	Mon Jun 23 10:58:07 2003
@@ -56,13 +56,13 @@
 
 	DPRINTK("svc_disconnect %p\n",vcc);
 	if (test_bit(ATM_VF_REGIS,&vcc->flags)) {
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc,as_close,NULL,NULL,NULL);
 		while (!test_bit(ATM_VF_RELEASED,&vcc->flags) && sigd) {
 			schedule();
-			prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(&vcc->sleep, &wait);
+		finish_wait(vcc->sk->sk_sleep, &wait);
 	}
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
@@ -138,13 +138,13 @@
 	}
 	vcc->local = *addr;
 	vcc->reply = WAITING;
-	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_bind,NULL,NULL,&vcc->local);
 	while (vcc->reply == WAITING && sigd) {
 		schedule();
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	clear_bit(ATM_VF_REGIS,&vcc->flags); /* doesn't count */
 	if (!sigd) {
 		error = -EUNATCH;
@@ -219,10 +219,10 @@
 		}
 		vcc->remote = *addr;
 		vcc->reply = WAITING;
-		prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		sigd_enq(vcc,as_connect,NULL,NULL,&vcc->remote);
 		if (flags & O_NONBLOCK) {
-			finish_wait(&vcc->sleep, &wait);
+			finish_wait(sk->sk_sleep, &wait);
 			sock->state = SS_CONNECTING;
 			error = -EINPROGRESS;
 			goto out;
@@ -231,7 +231,7 @@
 		while (vcc->reply == WAITING && sigd) {
 			schedule();
 			if (!signal_pending(current)) {
-				prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 				continue;
 			}
 			DPRINTK("*ABORT*\n");
@@ -249,13 +249,13 @@
 			 */
 			sigd_enq(vcc,as_close,NULL,NULL,NULL);
 			while (vcc->reply == WAITING && sigd) {
-				prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 				schedule();
 			}
 			if (!vcc->reply)
 				while (!test_bit(ATM_VF_RELEASED,&vcc->flags)
 				    && sigd) {
-					prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+					prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 					schedule();
 				}
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
@@ -265,7 +265,7 @@
 			error = -EINTR;
 			break;
 		}
-		finish_wait(&vcc->sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
 		if (error)
 			goto out;
 		if (!sigd) {
@@ -312,13 +312,13 @@
 		goto out;
 	}
 	vcc->reply = WAITING;
-	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
 	while (vcc->reply == WAITING && sigd) {
 		schedule();
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	if (!sigd) {
 		error = -EUNATCH;
 		goto out;
@@ -354,7 +354,7 @@
 	while (1) {
 		DEFINE_WAIT(wait);
 
-		prepare_to_wait(&old_vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(old_vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		while (!(skb = skb_dequeue(&old_vcc->sk->sk_receive_queue)) &&
 		       sigd) {
 			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
@@ -373,9 +373,9 @@
 				error = -ERESTARTSYS;
 				break;
 			}
-			prepare_to_wait(&old_vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+			prepare_to_wait(old_vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		}
-		finish_wait(&old_vcc->sleep, &wait);
+		finish_wait(old_vcc->sk->sk_sleep, &wait);
 		if (error)
 			goto out;
 		if (!skb) {
@@ -400,15 +400,15 @@
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		new_vcc->reply = WAITING;
-		prepare_to_wait(&new_vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
 		while (new_vcc->reply == WAITING && sigd) {
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
-			prepare_to_wait(&new_vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(&new_vcc->sleep, &wait);
+		finish_wait(new_vcc->sk->sk_sleep, &wait);
 		if (!sigd) {
 			error = -EUNATCH;
 			goto out;
@@ -444,14 +444,14 @@
 	DEFINE_WAIT(wait);
 
 	vcc->reply = WAITING;
-	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc,as_modify,NULL,NULL,&vcc->local,qos,0);
 	while (vcc->reply == WAITING && !test_bit(ATM_VF_RELEASED,&vcc->flags)
 	    && sigd) {
 		schedule();
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(vcc->sk->sk_sleep, &wait);
 	if (!sigd) return -EUNATCH;
 	return vcc->reply;
 }




[atm]: use sk_data_ready and sk_change_state instead of wake_up

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1365  -> 1.1366 
#	       net/atm/lec.c	1.31    -> 1.32   
#	 net/atm/signaling.c	1.18    -> 1.19   
#	       net/atm/mpc.c	1.22    -> 1.23   
#	       net/atm/raw.c	1.5     -> 1.6    
#	      net/atm/clip.c	1.19    -> 1.20   
#	    net/atm/common.c	1.40    -> 1.41   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/23	chas@relax.cmf.nrl.navy.mil	1.1366
# use sk_data_ready and sk_change_state instead of wake_up
# --------------------------------------------
#
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/clip.c	Mon Jun 23 10:57:48 2003
@@ -67,7 +67,7 @@
 	ctrl->ip = ip;
 	atm_force_charge(atmarpd,skb->truesize);
 	skb_queue_tail(&atmarpd->sk->sk_receive_queue, skb);
-	wake_up(atmarpd->sk->sk_sleep);
+	atmarpd->sk->sk_data_ready(atmarpd->sk, skb->len);
 	return 0;
 }
 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/common.c	Mon Jun 23 10:57:48 2003
@@ -328,7 +328,7 @@
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	vcc->reply = reply;
 	vcc->sk->sk_err = -reply;
-	wake_up(vcc->sk->sk_sleep);
+	vcc->sk->sk_state_change(vcc->sk);
 }
 
 
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/lec.c	Mon Jun 23 10:57:48 2003
@@ -134,7 +134,7 @@
                 priv = (struct lec_priv *)dev->priv;
                 atm_force_charge(priv->lecd, skb2->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                wake_up(priv->lecd->sk->sk_sleep);
+                priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb2->len);
         }
 
         return;
@@ -513,7 +513,7 @@
                         memcpy(skb2->data, mesg, sizeof(struct atmlec_msg));
                         atm_force_charge(priv->lecd, skb2->truesize);
                         skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                        wake_up(priv->lecd->sk->sk_sleep);
+                        priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb2->len);
                 }
                 if (f != NULL) br_fdb_put_hook(f);
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
@@ -598,13 +598,13 @@
 
         atm_force_charge(priv->lecd, skb->truesize);
 	skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb);
-        wake_up(priv->lecd->sk->sk_sleep);
+        priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb->len);
 
         if (data != NULL) {
                 DPRINTK("lec: about to send %d bytes of data\n", data->len);
                 atm_force_charge(priv->lecd, data->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, data);
-                wake_up(priv->lecd->sk->sk_sleep);
+                priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb->len);
         }
 
         return 0;
@@ -686,7 +686,7 @@
         if (memcmp(skb->data, lec_ctrl_magic, 4) ==0) { /* Control frame, to daemon*/
                 DPRINTK("%s: To daemon\n",dev->name);
                 skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-                wake_up(vcc->sk->sk_sleep);
+                vcc->sk->sk_data_ready(vcc->sk, skb->len);
         } else { /* Data frame, queue to protocol handlers */
                 unsigned char *dst;
 
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/mpc.c	Mon Jun 23 10:57:48 2003
@@ -669,7 +669,7 @@
 		dprintk("mpoa: (%s) mpc_push: control packet arrived\n", dev->name);
 		/* Pass control packets to daemon */
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(vcc->sk->sk_sleep);
+		vcc->sk->sk_data_ready(vcc->sk, skb->len);
 		return;
 	}
 
@@ -947,7 +947,7 @@
 	memcpy(skb->data, mesg, sizeof(struct k_message));
 	atm_force_charge(mpc->mpoad_vcc, skb->truesize);
 	skb_queue_tail(&mpc->mpoad_vcc->sk->sk_receive_queue, skb);
-	wake_up(mpc->mpoad_vcc->sk->sk_sleep);
+	mpc->mpoad_vcc->sk->sk_data_ready(mpc->mpoad_vcc->sk, skb->len);
 
 	return 0;
 }
@@ -1226,7 +1226,7 @@
 
 	atm_force_charge(vcc, skb->truesize);
 	skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-	wake_up(vcc->sk->sk_sleep);
+	vcc->sk->sk_data_ready(vcc->sk, skb->len);
 	dprintk("mpoa: purge_egress_shortcut: exiting:\n");
 
 	return;
diff -Nru a/net/atm/raw.c b/net/atm/raw.c
--- a/net/atm/raw.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/raw.c	Mon Jun 23 10:57:48 2003
@@ -29,7 +29,7 @@
 {
 	if (skb) {
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(vcc->sk->sk_sleep);
+		vcc->sk->sk_data_ready(vcc->sk, skb->len);
 	}
 }
 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/signaling.c	Mon Jun 23 10:57:48 2003
@@ -63,7 +63,7 @@
 #endif
 	atm_force_charge(sigd,skb->truesize);
 	skb_queue_tail(&sigd->sk->sk_receive_queue,skb);
-	wake_up(sigd->sk->sk_sleep);
+	sigd->sk->sk_data_ready(sigd->sk, skb->len);
 }
 
 
@@ -206,7 +206,7 @@
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
 		vcc->reply = -EUNATCH;
 		vcc->sk->sk_err = EUNATCH;
-		wake_up(vcc->sk->sk_sleep);
+		vcc->sk->sk_state_change(vcc->sk);
 	}
 }
 




[atm]: replace vcc->reply with sk->sk_err; implement sk_write_space

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1310.51.8 -> 1.1310.51.9
#	 net/atm/signaling.h	1.1     -> 1.2    
#	      net/atm/proc.c	1.21    -> 1.22   
#	       net/atm/pvc.c	1.17    -> 1.18   
#	drivers/atm/atmtcp.c	1.12    -> 1.13   
#	       net/atm/svc.c	1.21    -> 1.22   
#	    net/atm/common.h	1.15    -> 1.16   
#	 net/atm/signaling.c	1.19    -> 1.20   
#	include/linux/atmdev.h	1.21    -> 1.22   
#	       net/atm/raw.c	1.6     -> 1.7    
#	    net/atm/common.c	1.41    -> 1.42   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/05	chas@relax.cmf.nrl.navy.mil	1.1310.51.9
# replace vcc->reply with sk->sk_err; making WAITING a ATM_VF flag
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Mon Jul 14 22:19:44 2003
+++ b/drivers/atm/atmtcp.c	Mon Jul 14 22:19:44 2003
@@ -90,7 +90,7 @@
 	vcc->vpi = msg->addr.sap_addr.vpi;
 	vcc->vci = msg->addr.sap_addr.vci;
 	vcc->qos = msg->qos;
-	vcc->reply = msg->result;
+	vcc->sk->sk_err = -msg->result;
 	switch (msg->type) {
 	    case ATMTCP_CTRL_OPEN:
 		change_bit(ATM_VF_READY,&vcc->flags);
@@ -134,7 +134,7 @@
 	clear_bit(ATM_VF_READY,&vcc->flags); /* just in case ... */
 	error = atmtcp_send_control(vcc,ATMTCP_CTRL_OPEN,&msg,ATM_VF_READY);
 	if (error) return error;
-	return vcc->reply;
+	return -vcc->sk->sk_err;
 }
 
 
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Mon Jul 14 22:19:44 2003
+++ b/include/linux/atmdev.h	Mon Jul 14 22:19:44 2003
@@ -252,6 +252,7 @@
 	ATM_VF_SESSION,		/* VCC is p2mp session control descriptor */
 	ATM_VF_HASSAP,		/* SAP has been set */
 	ATM_VF_CLOSE,		/* asynchronous close - treat like VF_RELEASED*/
+	ATM_VF_WAITING,		/* waiting for reply from sigd */
 };
 
 
@@ -296,7 +297,6 @@
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
 	struct sockaddr_atmsvc remote;
-	int		reply;		/* also used by ATMTCP */
 	/* Multipoint part ------------------------------------------------- */
 	struct atm_vcc	*session;	/* session VCC descriptor */
 	/* Other stuff ----------------------------------------------------- */
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jul 14 22:19:44 2003
+++ b/net/atm/common.c	Mon Jul 14 22:19:44 2003
@@ -243,6 +243,29 @@
 		wake_up(sk->sk_sleep);
 	read_unlock(&sk->sk_callback_lock);
 }
+
+static inline int vcc_writable(struct sock *sk)
+{
+	struct atm_vcc *vcc = atm_sk(sk);
+
+	return (vcc->qos.txtp.max_sdu +
+	        atomic_read(&sk->sk_wmem_alloc)) <= sk->sk_sndbuf;
+}
+
+static void vcc_write_space(struct sock *sk)
+{       
+	read_lock(&sk->sk_callback_lock);
+
+	if (vcc_writable(sk)) {
+		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+			wake_up_interruptible(sk->sk_sleep);
+
+		sk_wake_async(sk, 2, POLL_OUT);
+	}
+
+	read_unlock(&sk->sk_callback_lock);
+}
+
  
 int vcc_create(struct socket *sock, int protocol, int family)
 {
@@ -257,6 +280,7 @@
 		return -ENOMEM;
 	sock_init_data(sock, sk);
 	sk->sk_state_change = vcc_def_wakeup;
+	sk->sk_write_space = vcc_write_space;
 
 	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
 	if (!vcc) {
@@ -326,8 +350,8 @@
 void vcc_release_async(struct atm_vcc *vcc, int reply)
 {
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
-	vcc->reply = reply;
 	vcc->sk->sk_err = -reply;
+	clear_bit(ATM_VF_WAITING, &vcc->flags);
 	vcc->sk->sk_state_change(vcc->sk);
 }
 
@@ -501,7 +525,7 @@
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE,&vcc->flags))
-		return vcc->reply;
+		return -sk->sk_err;
 	if (!test_bit(ATM_VF_READY, &vcc->flags))
 		return 0;
 
@@ -558,7 +582,7 @@
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE, &vcc->flags)) {
-		error = vcc->reply;
+		error = -sk->sk_err;
 		goto out;
 	}
 	if (!test_bit(ATM_VF_READY, &vcc->flags)) {
@@ -589,7 +613,7 @@
 		}
 		if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
 		    test_bit(ATM_VF_CLOSE,&vcc->flags)) {
-			error = vcc->reply;
+			error = -sk->sk_err;
 			break;
 		}
 		if (!test_bit(ATM_VF_READY,&vcc->flags)) {
@@ -617,29 +641,38 @@
 }
 
 
-unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait)
+unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 	unsigned int mask;
 
-	vcc = ATM_SD(sock);
-	poll_wait(file, vcc->sk->sk_sleep, wait);
+	poll_wait(file, sk->sk_sleep, wait);
 	mask = 0;
-	if (skb_peek(&vcc->sk->sk_receive_queue))
-		mask |= POLLIN | POLLRDNORM;
-	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-	    test_bit(ATM_VF_CLOSE,&vcc->flags))
+
+	vcc = ATM_SD(sock);
+
+	/* exceptional events */
+	if (sk->sk_err)
+		mask = POLLERR;
+
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+	    test_bit(ATM_VF_CLOSE, &vcc->flags))
 		mask |= POLLHUP;
-	if (sock->state != SS_CONNECTING) {
-		if (vcc->qos.txtp.traffic_class != ATM_NONE &&
-		    vcc->qos.txtp.max_sdu +
-		    atomic_read(&vcc->sk->sk_wmem_alloc) <= vcc->sk->sk_sndbuf)
-			mask |= POLLOUT | POLLWRNORM;
-	}
-	else if (vcc->reply != WAITING) {
-			mask |= POLLOUT | POLLWRNORM;
-			if (vcc->reply) mask |= POLLERR;
-		}
+
+	/* readable? */
+	if (!skb_queue_empty(&sk->sk_receive_queue))
+		mask |= POLLIN | POLLRDNORM;
+
+	/* writable? */
+	if (sock->state == SS_CONNECTING &&
+	    test_bit(ATM_VF_WAITING, &vcc->flags))
+		return mask;
+
+	if (vcc->qos.txtp.traffic_class != ATM_NONE &&
+	    vcc_writable(vcc->sk))
+		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+
 	return mask;
 }
 
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jul 14 22:19:44 2003
+++ b/net/atm/common.h	Mon Jul 14 22:19:44 2003
@@ -17,7 +17,7 @@
 		int size, int flags);
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		int total_len);
-unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
+unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int vcc_setsockopt(struct socket *sock, int level, int optname, char *optval,
 		   int optlen);
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Mon Jul 14 22:19:44 2003
+++ b/net/atm/proc.c	Mon Jul 14 22:19:44 2003
@@ -224,7 +224,7 @@
 			here += sprintf(here, "%3d", vcc->sk->sk_family);
 	}
 	here += sprintf(here," %04lx  %5d %7d/%7d %7d/%7d\n",vcc->flags,
-	    vcc->reply,
+	    vcc->sk->sk_err,
 	    atomic_read(&vcc->sk->sk_wmem_alloc), vcc->sk->sk_sndbuf,
 	    atomic_read(&vcc->sk->sk_rmem_alloc), vcc->sk->sk_rcvbuf);
 }
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Mon Jul 14 22:19:44 2003
+++ b/net/atm/pvc.c	Mon Jul 14 22:19:44 2003
@@ -111,7 +111,7 @@
 	.socketpair =	sock_no_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	pvc_getname,
-	.poll =		atm_poll,
+	.poll =		vcc_poll,
 	.ioctl =	vcc_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	pvc_shutdown,
diff -Nru a/net/atm/raw.c b/net/atm/raw.c
--- a/net/atm/raw.c	Mon Jul 14 22:19:44 2003
+++ b/net/atm/raw.c	Mon Jul 14 22:19:44 2003
@@ -40,7 +40,7 @@
 		skb->truesize);
 	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
-	wake_up(vcc->sk->sk_sleep);
+	vcc->sk->sk_write_space(vcc->sk);
 }
 
 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jul 14 22:19:44 2003
+++ b/net/atm/signaling.c	Mon Jul 14 22:19:44 2003
@@ -105,7 +105,8 @@
 	vcc = *(struct atm_vcc **) &msg->vcc;
 	switch (msg->type) {
 		case as_okay:
-			vcc->reply = msg->reply;
+			vcc->sk->sk_err = -msg->reply;
+			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			if (!*vcc->local.sas_addr.prv &&
 			    !*vcc->local.sas_addr.pub) {
 				vcc->local.sas_family = AF_ATMSVC;
@@ -125,8 +126,8 @@
 		case as_error:
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
-			vcc->reply = msg->reply;
 			vcc->sk->sk_err = -msg->reply;
+			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			break;
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
@@ -147,8 +148,8 @@
 		case as_close:
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
-			vcc->reply = msg->reply;
 			vcc->sk->sk_err = -msg->reply;
+			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			break;
 		case as_modify:
 			modify_qos(vcc,msg);
@@ -204,8 +205,8 @@
 	if (vcc->sk->sk_family == PF_ATMSVC &&
 	    !test_bit(ATM_VF_META,&vcc->flags)) {
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
-		vcc->reply = -EUNATCH;
 		vcc->sk->sk_err = EUNATCH;
+		clear_bit(ATM_VF_WAITING, &vcc->flags);
 		vcc->sk->sk_state_change(vcc->sk);
 	}
 }
diff -Nru a/net/atm/signaling.h b/net/atm/signaling.h
--- a/net/atm/signaling.h	Mon Jul 14 22:19:44 2003
+++ b/net/atm/signaling.h	Mon Jul 14 22:19:44 2003
@@ -11,9 +11,6 @@
 #include <linux/atmsvc.h>
 
 
-#define WAITING 1 /* for reply: 0: no error, < 0: error, ... */
-
-
 extern struct atm_vcc *sigd; /* needed in svc_release */
 
 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Jul 14 22:19:44 2003
+++ b/net/atm/svc.c	Mon Jul 14 22:19:44 2003
@@ -137,10 +137,10 @@
 		goto out;
 	}
 	vcc->local = *addr;
-	vcc->reply = WAITING;
+	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_bind,NULL,NULL,&vcc->local);
-	while (vcc->reply == WAITING && sigd) {
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
@@ -150,9 +150,9 @@
 		error = -EUNATCH;
 		goto out;
 	}
-        if (!vcc->reply)
+        if (!sk->sk_err)
 		set_bit(ATM_VF_BOUND,&vcc->flags);
-	error = vcc->reply;
+	error = -sk->sk_err;
 out:
 	release_sock(sk);
 	return error;
@@ -183,13 +183,13 @@
 		error = -EISCONN;
 		goto out;
 	case SS_CONNECTING:
-		if (vcc->reply == WAITING) {
+		if (test_bit(ATM_VF_WAITING, &vcc->flags)) {
 			error = -EALREADY;
 			goto out;
 		}
 		sock->state = SS_UNCONNECTED;
-		if (vcc->reply) {
-			error = vcc->reply;
+		if (sk->sk_err) {
+			error = -sk->sk_err;
 			goto out;
 		}
 		break;
@@ -218,7 +218,7 @@
 			goto out;
 		}
 		vcc->remote = *addr;
-		vcc->reply = WAITING;
+		set_bit(ATM_VF_WAITING, &vcc->flags);
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		sigd_enq(vcc,as_connect,NULL,NULL,&vcc->remote);
 		if (flags & O_NONBLOCK) {
@@ -228,7 +228,7 @@
 			goto out;
 		}
 		error = 0;
-		while (vcc->reply == WAITING && sigd) {
+		while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 			schedule();
 			if (!signal_pending(current)) {
 				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -248,11 +248,11 @@
 			 *   Kernel <--close--- Demon
 			 */
 			sigd_enq(vcc,as_close,NULL,NULL,NULL);
-			while (vcc->reply == WAITING && sigd) {
+			while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 				schedule();
 			}
-			if (!vcc->reply)
+			if (!sk->sk_err)
 				while (!test_bit(ATM_VF_RELEASED,&vcc->flags)
 				    && sigd) {
 					prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -272,8 +272,8 @@
 			error = -EUNATCH;
 			goto out;
 		}
-		if (vcc->reply) {
-			error = vcc->reply;
+		if (sk->sk_err) {
+			error = -sk->sk_err;
 			goto out;
 		}
 	}
@@ -311,10 +311,10 @@
 		error = -EINVAL;
 		goto out;
 	}
-	vcc->reply = WAITING;
+	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
-	while (vcc->reply == WAITING && sigd) {
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
@@ -326,7 +326,7 @@
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
 	vcc->sk->sk_max_ack_backlog = backlog > 0 ? backlog :
 						    ATM_BACKLOG_DEFAULT;
-	error = vcc->reply;
+	error = -sk->sk_err;
 out:
 	release_sock(sk);
 	return error;
@@ -359,7 +359,7 @@
 		       sigd) {
 			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
 			if (test_bit(ATM_VF_CLOSE,&old_vcc->flags)) {
-				error = old_vcc->reply;
+				error = -sk->sk_err;
 				break;
 			}
 			if (flags & O_NONBLOCK) {
@@ -399,10 +399,10 @@
 			goto out;
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
-		new_vcc->reply = WAITING;
+		set_bit(ATM_VF_WAITING, &new_vcc->flags);
 		prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
-		while (new_vcc->reply == WAITING && sigd) {
+		while (test_bit(ATM_VF_WAITING, &new_vcc->flags) && sigd) {
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
@@ -413,9 +413,10 @@
 			error = -EUNATCH;
 			goto out;
 		}
-		if (!new_vcc->reply) break;
-		if (new_vcc->reply != -ERESTARTSYS) {
-			error = new_vcc->reply;
+		if (!new_vcc->sk->sk_err)
+			break;
+		if (new_vcc->sk->sk_err != ERESTARTSYS) {
+			error = -new_vcc->sk->sk_err;
 			goto out;
 		}
 	}
@@ -443,17 +444,17 @@
 {
 	DEFINE_WAIT(wait);
 
-	vcc->reply = WAITING;
+	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc,as_modify,NULL,NULL,&vcc->local,qos,0);
-	while (vcc->reply == WAITING && !test_bit(ATM_VF_RELEASED,&vcc->flags)
-	    && sigd) {
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) &&
+	       !test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
 	finish_wait(vcc->sk->sk_sleep, &wait);
 	if (!sigd) return -EUNATCH;
-	return vcc->reply;
+	return -vcc->sk->sk_err;
 }
 
 
@@ -519,7 +520,7 @@
 	.socketpair =	sock_no_socketpair,
 	.accept =	svc_accept,
 	.getname =	svc_getname,
-	.poll =		atm_poll,
+	.poll =		vcc_poll,
 	.ioctl =	vcc_ioctl,
 	.listen =	svc_listen,
 	.shutdown =	svc_shutdown,
