From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][3/6] cleanup connect
Date: Mon, 13 Oct 2003 23:45:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310140345.h9E3jIkT005594@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1138  -> 1.1139 
#	       net/atm/pvc.c	1.6     -> 1.7    
#	       net/atm/svc.c	1.7     -> 1.8    
#	    net/atm/common.h	1.6     -> 1.7    
#	    net/atm/common.c	1.23    -> 1.24   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/29	chas@relax.cmf.nrl.navy.mil	1.1139
# [ATM]: cleanup connect
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Oct 13 18:41:18 2003
+++ b/net/atm/common.c	Mon Oct 13 18:41:18 2003
@@ -298,8 +298,8 @@
 }
 
 
-static int atm_do_connect_dev(struct atm_vcc *vcc,struct atm_dev *dev,int vpi,
-    int vci)
+static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, int vpi,
+			 int vci)
 {
 	int error;
 
@@ -310,6 +310,8 @@
 	if (vci > 0 && vci < ATM_NOT_RSV_VCI && !capable(CAP_NET_BIND_SERVICE))
 		return -EPERM;
 	error = 0;
+	if (!try_inc_mod_count(dev->ops->owner))
+		return -ENODEV;
 	bind_vcc(vcc,dev);
 	switch (vcc->qos.aal) {
 		case ATM_AAL0:
@@ -333,53 +335,48 @@
 	}
 	if (!error) error = adjust_tp(&vcc->qos.txtp,vcc->qos.aal);
 	if (!error) error = adjust_tp(&vcc->qos.rxtp,vcc->qos.aal);
-	if (error) {
-		bind_vcc(vcc,NULL);
-		return error;
-	}
+	if (error)
+		goto fail;
 	DPRINTK("VCC %d.%d, AAL %d\n",vpi,vci,vcc->qos.aal);
 	DPRINTK("  TX: %d, PCR %d..%d, SDU %d\n",vcc->qos.txtp.traffic_class,
 	    vcc->qos.txtp.min_pcr,vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu);
 	DPRINTK("  RX: %d, PCR %d..%d, SDU %d\n",vcc->qos.rxtp.traffic_class,
 	    vcc->qos.rxtp.min_pcr,vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu);
-	if (!try_inc_mod_count(dev->ops->owner))
-		return -ENODEV;
 	if (dev->ops->open) {
-		error = dev->ops->open(vcc,vpi,vci);
-		if (error) {
-			if (dev->ops->owner)
-				__MOD_DEC_USE_COUNT(dev->ops->owner);
-			bind_vcc(vcc,NULL);
-			return error;
-		}
+		if ((error = dev->ops->open(vcc,vpi,vci)))
+			goto fail;
 	}
 	return 0;
+
+fail:
+	bind_vcc(vcc, NULL);
+	if (dev->ops->owner)
+		__MOD_DEC_USE_COUNT(dev->ops->owner);
+	return error;
+	
 }
 
 
-static int atm_do_connect(struct atm_vcc *vcc,int itf,int vpi,int vci)
+int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 {
 	struct atm_dev *dev;
-	int return_val;
-
-	dev = atm_dev_lookup(itf);
-	if (!dev)
-		return_val =  -ENODEV;
-	else {
-		return_val = atm_do_connect_dev(vcc,dev,vpi,vci);
-		if (return_val) atm_dev_release(dev);
-	}
-
-	return return_val;
-}
+	struct atm_vcc *vcc = ATM_SD(sock);
+	int error;
 
+	DPRINTK("vcc_connect (vpi %d, vci %d)\n",vpi,vci);
+	if (sock->state == SS_CONNECTED)
+		return -EISCONN;
+	if (sock->state != SS_UNCONNECTED)
+		return -EINVAL;
+	if (!(vpi || vci))
+		return -EINVAL;
 
-int atm_connect_vcc(struct atm_vcc *vcc,int itf,short vpi,int vci)
-{
 	if (vpi != ATM_VPI_UNSPEC && vci != ATM_VCI_UNSPEC)
 		clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	else if (test_bit(ATM_VF_PARTIAL,&vcc->flags)) return -EINVAL;
-	DPRINTK("atm_connect (TX: cl %d,bw %d-%d,sdu %d; "
+	else
+		if (test_bit(ATM_VF_PARTIAL,&vcc->flags))
+			return -EINVAL;
+	DPRINTK("vcc_connect (TX: cl %d,bw %d-%d,sdu %d; "
 	    "RX: cl %d,bw %d-%d,sdu %d,AAL %s%d)\n",
 	    vcc->qos.txtp.traffic_class,vcc->qos.txtp.min_pcr,
 	    vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu,
@@ -387,50 +384,41 @@
 	    vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu,
 	    vcc->qos.aal == ATM_AAL5 ? "" : vcc->qos.aal == ATM_AAL0 ? "" :
 	    " ??? code ",vcc->qos.aal == ATM_AAL0 ? 0 : vcc->qos.aal);
-	if (!test_bit(ATM_VF_HASQOS,&vcc->flags)) return -EBADFD;
+	if (!test_bit(ATM_VF_HASQOS, &vcc->flags))
+		return -EBADFD;
 	if (vcc->qos.txtp.traffic_class == ATM_ANYCLASS ||
 	    vcc->qos.rxtp.traffic_class == ATM_ANYCLASS)
 		return -EINVAL;
 	if (itf != ATM_ITF_ANY) {
-		int error;
-
-		error = atm_do_connect(vcc,itf,vpi,vci);
-		if (error) return error;
-	}
-	else {
-		struct atm_dev *dev = NULL;
+		dev = atm_dev_lookup(itf);
+		if (!dev)
+			return -ENODEV;
+		error = __vcc_connect(vcc, dev, vpi, vci);
+		if (error) {
+			atm_dev_release(dev);
+			return error;
+		}
+	} else {
 		struct list_head *p, *next;
 
+		dev = NULL;
 		spin_lock(&atm_dev_lock);
 		list_for_each_safe(p, next, &atm_devs) {
 			dev = list_entry(p, struct atm_dev, dev_list);
 			atm_dev_hold(dev);
 			spin_unlock(&atm_dev_lock);
-			if (!atm_do_connect_dev(vcc,dev,vpi,vci))
+			if (!__vcc_connect(vcc, dev, vpi, vci))
 				break;
 			atm_dev_release(dev);
 			dev = NULL;
 			spin_lock(&atm_dev_lock);
 		}
 		spin_unlock(&atm_dev_lock);
-		if (!dev) return -ENODEV;
+		if (!dev)
+			return -ENODEV;
 	}
 	if (vpi == ATM_VPI_UNSPEC || vci == ATM_VCI_UNSPEC)
 		set_bit(ATM_VF_PARTIAL,&vcc->flags);
-	return 0;
-}
-
-
-int atm_connect(struct socket *sock,int itf,short vpi,int vci)
-{
-	int error;
-
-	DPRINTK("atm_connect (vpi %d, vci %d)\n",vpi,vci);
-	if (sock->state == SS_CONNECTED) return -EISCONN;
-	if (sock->state != SS_UNCONNECTED) return -EINVAL;
-	if (!(vpi || vci)) return -EINVAL;
-	error = atm_connect_vcc(ATM_SD(sock),itf,vpi,vci);
-	if (error) return error;
 	if (test_bit(ATM_VF_READY,&ATM_SD(sock)->flags))
 		sock->state = SS_CONNECTED;
 	return 0;
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Oct 13 18:41:18 2003
+++ b/net/atm/common.h	Mon Oct 13 18:41:18 2003
@@ -12,7 +12,7 @@
 
 int atm_create(struct socket *sock,int protocol,int family);
 int atm_release(struct socket *sock);
-int atm_connect(struct socket *sock,int itf,short vpi,int vci);
+int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct socket *sock, struct msghdr *msg,
 		int size, int flags, struct scm_cookie *scm);
 int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
@@ -24,7 +24,6 @@
 int atm_getsockopt(struct socket *sock,int level,int optname,char *optval,
     int *optlen);
 
-int atm_connect_vcc(struct atm_vcc *vcc,int itf,short vpi,int vci);
 void atm_release_vcc_sk(struct sock *sk,int free_sk);
 void atm_shutdown_dev(struct atm_dev *dev);
 
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Mon Oct 13 18:41:18 2003
+++ b/net/atm/pvc.c	Mon Oct 13 18:41:18 2003
@@ -44,8 +44,8 @@
 		if (vcc->vpi != ATM_VPI_UNSPEC) addr->sap_addr.vpi = vcc->vpi;
 		if (vcc->vci != ATM_VCI_UNSPEC) addr->sap_addr.vci = vcc->vci;
 	}
-	return atm_connect(sock,addr->sap_addr.itf,addr->sap_addr.vpi,
-	    addr->sap_addr.vci);
+	return vcc_connect(sock, addr->sap_addr.itf, addr->sap_addr.vpi,
+			   addr->sap_addr.vci);
 }
 
 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Oct 13 18:41:18 2003
+++ b/net/atm/svc.c	Mon Oct 13 18:41:18 2003
@@ -229,7 +229,7 @@
 /*
  * #endif
  */
-	if (!(error = atm_connect(sock,vcc->itf,vcc->vpi,vcc->vci)))
+	if (!(error = vcc_connect(sock, vcc->itf, vcc->vpi, vcc->vci)))
 		sock->state = SS_CONNECTED;
 	else (void) svc_disconnect(vcc);
 	return error;
@@ -304,8 +304,8 @@
 		new_vcc->remote = msg->svc;
 		new_vcc->local = msg->local;
 		new_vcc->sap = msg->sap;
-		error = atm_connect(newsock,msg->pvc.sap_addr.itf,
-		    msg->pvc.sap_addr.vpi,msg->pvc.sap_addr.vci);
+		error = vcc_connect(newsock, msg->pvc.sap_addr.itf,
+				    msg->pvc.sap_addr.vpi, msg->pvc.sap_addr.vci);
 		dev_kfree_skb(skb);
 		old_vcc->sk->ack_backlog--;
 		if (error) {
