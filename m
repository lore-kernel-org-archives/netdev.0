From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][2/6] remove listenq and backlog_quota from struct atm_vcc
Date: Mon, 13 Oct 2003 23:44:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310140344.h9E3iekT005589@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.4 --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1137  -> 1.1138 
#	include/linux/atmdev.h	1.10    -> 1.11   
#	       net/atm/svc.c	1.6     -> 1.7    
#	 net/atm/signaling.c	1.6     -> 1.7    
#	    net/atm/common.c	1.22    -> 1.23   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/29	chas@relax.cmf.nrl.navy.mil	1.1138
# [ATM]: remove listenq and backlog_quota from struct atm_vcc
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Mon Oct 13 18:41:13 2003
+++ b/include/linux/atmdev.h	Mon Oct 13 18:41:13 2003
@@ -302,9 +302,6 @@
 	struct sockaddr_atmsvc local;
 	struct sockaddr_atmsvc remote;
 	void (*callback)(struct atm_vcc *vcc);
-	struct sk_buff_head listenq;
-	int		backlog_quota;	/* number of connection requests we */
-					/* can still accept */
 	int		reply;		/* also used by ATMTCP */
 	/* Multipoint part ------------------------------------------------- */
 	struct atm_vcc	*session;	/* session VCC descriptor */
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Oct 13 18:41:13 2003
+++ b/net/atm/common.c	Mon Oct 13 18:41:13 2003
@@ -217,7 +217,6 @@
 	vcc->vpi = vcc->vci = 0; /* no VCI/VPI yet */
 	vcc->atm_options = vcc->aal_options = 0;
 	init_waitqueue_head(&vcc->sleep);
-	skb_queue_head_init(&vcc->listenq);
 	sk->sleep = &vcc->sleep;
 	sock->sk = sk;
 	return 0;
@@ -553,7 +552,7 @@
 	vcc = ATM_SD(sock);
 	poll_wait(file,&vcc->sleep,wait);
 	mask = 0;
-	if (skb_peek(&vcc->sk->receive_queue) || skb_peek(&vcc->listenq))
+	if (skb_peek(&vcc->sk->receive_queue))
 		mask |= POLLIN | POLLRDNORM;
 	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE,&vcc->flags))
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Oct 13 18:41:13 2003
+++ b/net/atm/signaling.c	Mon Oct 13 18:41:13 2003
@@ -129,12 +129,12 @@
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
 			DPRINTK("as_indicate!!!\n");
-			if (!vcc->backlog_quota) {
+			if (vcc->sk->ack_backlog == vcc->sk->max_ack_backlog) {
 				sigd_enq(0,as_reject,vcc,NULL,NULL);
 				return 0;
 			}
-			vcc->backlog_quota--;
-			skb_queue_tail(&vcc->listenq,skb);
+			vcc->sk->ack_backlog++;
+			skb_queue_tail(&vcc->sk->receive_queue,skb);
 			if (vcc->callback) {
 				DPRINTK("waking vcc->sleep 0x%p\n",
 				    &vcc->sleep);
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Oct 13 18:41:13 2003
+++ b/net/atm/svc.c	Mon Oct 13 18:41:13 2003
@@ -75,7 +75,7 @@
 	}
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
-	while ((skb = skb_dequeue(&vcc->listenq))) {
+	while ((skb = skb_dequeue(&vcc->sk->receive_queue))) {
 		DPRINTK("LISTEN REL\n");
 		sigd_enq2(NULL,as_reject,vcc,NULL,NULL,&vcc->qos,0);
 		dev_kfree_skb(skb);
@@ -254,7 +254,7 @@
 	remove_wait_queue(&vcc->sleep,&wait);
 	if (!sigd) return -EUNATCH;
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
-	vcc->backlog_quota = backlog > 0 ? backlog : ATM_BACKLOG_DEFAULT;
+	vcc->sk->max_ack_backlog = backlog > 0 ? backlog : ATM_BACKLOG_DEFAULT;
 	return vcc->reply;
 }
 
@@ -278,7 +278,7 @@
 		DECLARE_WAITQUEUE(wait,current);
 
 		add_wait_queue(&old_vcc->sleep,&wait);
-		while (!(skb = skb_dequeue(&old_vcc->listenq)) && sigd) {
+		while (!(skb = skb_dequeue(&old_vcc->sk->receive_queue)) && sigd) {
 			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
 			if (test_bit(ATM_VF_CLOSE,&old_vcc->flags)) {
 				error = old_vcc->reply;
@@ -307,7 +307,7 @@
 		error = atm_connect(newsock,msg->pvc.sap_addr.itf,
 		    msg->pvc.sap_addr.vpi,msg->pvc.sap_addr.vci);
 		dev_kfree_skb(skb);
-		old_vcc->backlog_quota++;
+		old_vcc->sk->ack_backlog--;
 		if (error) {
 			sigd_enq2(NULL,as_reject,old_vcc,NULL,NULL,
 			    &old_vcc->qos,error);
