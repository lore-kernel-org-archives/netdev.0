From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][1/3] assorted changes for atm
Date: Tue, 17 Jun 2003 08:39:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306171239.h5HCdpsF021438@locutus.cmf.nrl.navy.mil>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[atm]: split atm_ioctl into vcc_ioctl and atm_dev_ioctl

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1398  -> 1.1399 
#	       net/atm/pvc.c	1.8     -> 1.9    
#	       net/atm/svc.c	1.10    -> 1.11   
#	    net/atm/common.h	1.4     -> 1.5    
#	 net/atm/resources.h	1.3     -> 1.4    
#	 net/atm/resources.c	1.9     -> 1.10   
#	    net/atm/common.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/16	chas@relax.cmf.nrl.navy.mil	1.1399
# split atm_ioctl into vcc_ioctl and atm_dev_ioctl
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Tue Jun 17 08:12:22 2003
+++ b/net/atm/common.c	Tue Jun 17 08:12:22 2003
@@ -563,129 +563,51 @@
 }
 
 
-static void copy_aal_stats(struct k_atm_aal_stats *from,
-    struct atm_aal_stats *to)
+int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
-#define __HANDLE_ITEM(i) to->i = atomic_read(&from->i)
-	__AAL_STAT_ITEMS
-#undef __HANDLE_ITEM
-}
-
-
-static void subtract_aal_stats(struct k_atm_aal_stats *from,
-    struct atm_aal_stats *to)
-{
-#define __HANDLE_ITEM(i) atomic_sub(to->i,&from->i)
-	__AAL_STAT_ITEMS
-#undef __HANDLE_ITEM
-}
-
-
-static int fetch_stats(struct atm_dev *dev,struct atm_dev_stats *arg,int zero)
-{
-	struct atm_dev_stats tmp;
-	int error = 0;
-
-	copy_aal_stats(&dev->stats.aal0,&tmp.aal0);
-	copy_aal_stats(&dev->stats.aal34,&tmp.aal34);
-	copy_aal_stats(&dev->stats.aal5,&tmp.aal5);
-	if (arg) error = copy_to_user(arg,&tmp,sizeof(tmp));
-	if (zero && !error) {
-		subtract_aal_stats(&dev->stats.aal0,&tmp.aal0);
-		subtract_aal_stats(&dev->stats.aal34,&tmp.aal34);
-		subtract_aal_stats(&dev->stats.aal5,&tmp.aal5);
-	}
-	return error ? -EFAULT : 0;
-}
-
-
-int atm_ioctl(struct socket *sock,unsigned int cmd,unsigned long arg)
-{
-	struct atm_dev *dev;
-	struct list_head *p;
 	struct atm_vcc *vcc;
-	int *tmp_buf, *tmp_p;
-	void *buf;
-	int error,len,size,number, ret_val;
+	int error;
 
-	ret_val = 0;
 	vcc = ATM_SD(sock);
 	switch (cmd) {
 		case SIOCOUTQ:
 			if (sock->state != SS_CONNECTED ||
-			    !test_bit(ATM_VF_READY,&vcc->flags)) {
-				ret_val =  -EINVAL;
+			    !test_bit(ATM_VF_READY, &vcc->flags)) {
+				error =  -EINVAL;
 				goto done;
 			}
-			ret_val = put_user(vcc->sk->sk_sndbuf -
-					   atomic_read(&vcc->sk->sk_wmem_alloc),
-			    (int *) arg) ? -EFAULT : 0;
+			error = put_user(vcc->sk->sk_sndbuf -
+					 atomic_read(&vcc->sk->sk_wmem_alloc),
+					 (int *) arg) ? -EFAULT : 0;
 			goto done;
 		case SIOCINQ:
 			{
 				struct sk_buff *skb;
 
 				if (sock->state != SS_CONNECTED) {
-					ret_val = -EINVAL;
+					error = -EINVAL;
 					goto done;
 				}
 				skb = skb_peek(&vcc->sk->sk_receive_queue);
-				ret_val = put_user(skb ? skb->len : 0,(int *) arg)
-				    ? -EFAULT : 0;
-				goto done;
-			}
-		case ATM_GETNAMES:
-			if (get_user(buf,
-				     &((struct atm_iobuf *) arg)->buffer)) {
-				ret_val = -EFAULT;
-				goto done;
-			}
-			if (get_user(len,
-				     &((struct atm_iobuf *) arg)->length)) {
-				ret_val = -EFAULT;
+				error = put_user(skb ? skb->len : 0,
+					 	 (int *) arg) ? -EFAULT : 0;
 				goto done;
 			}
-			size = 0;
-			spin_lock(&atm_dev_lock);
-			list_for_each(p, &atm_devs)
-				size += sizeof(int);
-			if (size > len) {
-				spin_unlock(&atm_dev_lock);
-				ret_val = -E2BIG;
-				goto done;
-			}
-			tmp_buf = kmalloc(size, GFP_ATOMIC);
-			if (!tmp_buf) {
-				spin_unlock(&atm_dev_lock);
-				ret_val = -ENOMEM;
-				goto done;
-			}
-			tmp_p = tmp_buf;
-			list_for_each(p, &atm_devs) {
-				dev = list_entry(p, struct atm_dev, dev_list);
-				*tmp_p++ = dev->number;
-			}
-			spin_unlock(&atm_dev_lock);
-		        ret_val = ((copy_to_user(buf, tmp_buf, size)) ||
-			    put_user(size, &((struct atm_iobuf *) arg)->length)
-			    ) ? -EFAULT : 0;
-			kfree(tmp_buf);
-			goto done;
 		case SIOCGSTAMP: /* borrowed from IP */
 			if (!vcc->sk->sk_stamp.tv_sec) {
-				ret_val = -ENOENT;
+				error = -ENOENT;
 				goto done;
 			}
-			ret_val = copy_to_user((void *)arg, &vcc->sk->sk_stamp,
-			    sizeof(struct timeval)) ? -EFAULT : 0;
+			error = copy_to_user((void *)arg, &vcc->sk->sk_stamp,
+					     sizeof(struct timeval)) ? -EFAULT : 0;
 			goto done;
 		case ATM_SETSC:
 			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
-			ret_val = 0;
+			error = 0;
 			goto done;
 		case ATMSIGD_CTRL:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			/*
@@ -696,28 +618,28 @@
 			 * have the same privledges that /proc/kcore needs
 			 */
 			if (!capable(CAP_SYS_RAWIO)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			error = sigd_attach(vcc);
-			if (!error) sock->state = SS_CONNECTED;
-			ret_val = error;
+			if (!error)
+				sock->state = SS_CONNECTED;
 			goto done;
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 		case SIOCMKCLIP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_create(arg);
+				error = atm_clip_ops->clip_create(arg);
 				module_put(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARPD_CTRL:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 #if defined(CONFIG_ATM_CLIP_MODULE)
@@ -728,48 +650,47 @@
 				error = atm_clip_ops->atm_init_atmarp(vcc);
 				if (!error)
 					sock->state = SS_CONNECTED;
-				ret_val = error;
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARP_MKIP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_mkip(vcc, arg);
+				error = atm_clip_ops->clip_mkip(vcc, arg);
 				module_put(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARP_SETENTRY:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_setentry(vcc, arg);
+				error = atm_clip_ops->clip_setentry(vcc, arg);
 				module_put(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMARP_ENCAP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_clip_ops()) {
-				ret_val = atm_clip_ops->clip_encap(vcc, arg);
+				error = atm_clip_ops->clip_encap(vcc, arg);
 				module_put(atm_clip_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
                 case ATMLEC_CTRL:
                         if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 #if defined(CONFIG_ATM_LANE_MODULE)
@@ -781,37 +702,36 @@
 				module_put(atm_lane_ops->owner);
 				if (error >= 0)
 					sock->state = SS_CONNECTED;
-				ret_val =  error;
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
                 case ATMLEC_MCAST:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_lane_ops()) {
-				ret_val = atm_lane_ops->mcast_attach(vcc, (int) arg);
+				error = atm_lane_ops->mcast_attach(vcc, (int) arg);
 				module_put(atm_lane_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
                 case ATMLEC_DATA:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_lane_ops()) {
-				ret_val = atm_lane_ops->vcc_attach(vcc, (void *) arg);
+				error = atm_lane_ops->vcc_attach(vcc, (void *) arg);
 				module_put(atm_lane_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
 		case ATMMPC_CTRL:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 #if defined(CONFIG_ATM_MPOA_MODULE)
@@ -823,63 +743,62 @@
 				module_put(atm_mpoa_ops->owner);
 				if (error >= 0)
 					sock->state = SS_CONNECTED;
-				ret_val = error;
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 		case ATMMPC_DATA:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (try_atm_mpoa_ops()) {
-				ret_val = atm_mpoa_ops->vcc_attach(vcc, arg);
+				error = atm_mpoa_ops->vcc_attach(vcc, arg);
 				module_put(atm_mpoa_ops->owner);
 			} else
-				ret_val = -ENOSYS;
+				error = -ENOSYS;
 			goto done;
 #endif
 #if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
 		case SIOCSIFATMTCP:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (!atm_tcp_ops.attach) {
-				ret_val = -ENOPKG;
+				error = -ENOPKG;
 				goto done;
 			}
-			fops_get (&atm_tcp_ops);
-			error = atm_tcp_ops.attach(vcc,(int) arg);
-			if (error >= 0) sock->state = SS_CONNECTED;
-			else            fops_put (&atm_tcp_ops);
-			ret_val = error;
+			fops_get(&atm_tcp_ops);
+			error = atm_tcp_ops.attach(vcc, (int) arg);
+			if (error >= 0)
+				sock->state = SS_CONNECTED;
+			else
+				fops_put (&atm_tcp_ops);
 			goto done;
 		case ATMTCP_CREATE:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (!atm_tcp_ops.create_persistent) {
-				ret_val = -ENOPKG;
+				error = -ENOPKG;
 				goto done;
 			}
 			error = atm_tcp_ops.create_persistent((int) arg);
-			if (error < 0) fops_put (&atm_tcp_ops);
-			ret_val = error;
+			if (error < 0)
+				fops_put (&atm_tcp_ops);
 			goto done;
 		case ATMTCP_REMOVE:
 			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
+				error = -EPERM;
 				goto done;
 			}
 			if (!atm_tcp_ops.remove_persistent) {
-				ret_val = -ENOPKG;
+				error = -ENOPKG;
 				goto done;
 			}
 			error = atm_tcp_ops.remove_persistent((int) arg);
-			fops_put (&atm_tcp_ops);
-			ret_val = error;
+			fops_put(&atm_tcp_ops);
 			goto done;
 #endif
 		default:
@@ -887,182 +806,23 @@
 	}
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
 	if (pppoatm_ioctl_hook) {
-		ret_val = pppoatm_ioctl_hook(vcc, cmd, arg);
-		if (ret_val != -ENOIOCTLCMD)
+		error = pppoatm_ioctl_hook(vcc, cmd, arg);
+		if (error != -ENOIOCTLCMD)
 			goto done;
 	}
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
 	if (br2684_ioctl_hook) {
-		ret_val = br2684_ioctl_hook(vcc, cmd, arg);
-		if (ret_val != -ENOIOCTLCMD)
+		error = br2684_ioctl_hook(vcc, cmd, arg);
+		if (error != -ENOIOCTLCMD)
 			goto done;
 	}
 #endif
-	if (get_user(buf,&((struct atmif_sioc *) arg)->arg)) {
-		ret_val = -EFAULT;
-		goto done;
-	}
-	if (get_user(len,&((struct atmif_sioc *) arg)->length)) {
-		ret_val = -EFAULT;
-		goto done;
-	}
-	if (get_user(number,&((struct atmif_sioc *) arg)->number)) {
-		ret_val = -EFAULT;
-		goto done;
-	}
-	if (!(dev = atm_dev_lookup(number))) {
-		ret_val = -ENODEV;
-		goto done;
-	}
-	
-	size = 0;
-	switch (cmd) {
-		case ATM_GETTYPE:
-			size = strlen(dev->type)+1;
-			if (copy_to_user(buf,dev->type,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_GETESI:
-			size = ESI_LEN;
-			if (copy_to_user(buf,dev->esi,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_SETESI:
-			{
-				int i;
-
-				for (i = 0; i < ESI_LEN; i++)
-					if (dev->esi[i]) {
-						ret_val = -EEXIST;
-						goto done_release;
-					}
-			}
-			/* fall through */
-		case ATM_SETESIF:
-			{
-				unsigned char esi[ESI_LEN];
-
-				if (!capable(CAP_NET_ADMIN)) {
-					ret_val = -EPERM;
-					goto done_release;
-				}
-				if (copy_from_user(esi,buf,ESI_LEN)) {
-					ret_val = -EFAULT;
-					goto done_release;
-				}
-				memcpy(dev->esi,esi,ESI_LEN);
-				ret_val =  ESI_LEN;
-				goto done_release;
-			}
-		case ATM_GETSTATZ:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			/* fall through */
-		case ATM_GETSTAT:
-			size = sizeof(struct atm_dev_stats);
-			error = fetch_stats(dev,buf,cmd == ATM_GETSTATZ);
-			if (error) {
-				ret_val = error;
-				goto done_release;
-			}
-			break;
-		case ATM_GETCIRANGE:
-			size = sizeof(struct atm_cirange);
-			if (copy_to_user(buf,&dev->ci_range,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_GETLINKRATE:
-			size = sizeof(int);
-			if (copy_to_user(buf,&dev->link_rate,size)) {
-				ret_val = -EFAULT;
-				goto done_release;
-			}
-			break;
-		case ATM_RSTADDR:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			atm_reset_addr(dev);
-			break;
-		case ATM_ADDADDR:
-		case ATM_DELADDR:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			{
-				struct sockaddr_atmsvc addr;
 
-				if (copy_from_user(&addr,buf,sizeof(addr))) {
-					ret_val = -EFAULT;
-					goto done_release;
-				}
-				if (cmd == ATM_ADDADDR)
-					ret_val = atm_add_addr(dev,&addr);
-				else
-					ret_val = atm_del_addr(dev,&addr);
-				goto done_release;
-			}
-		case ATM_GETADDR:
-			size = atm_get_addr(dev,buf,len);
-			if (size < 0)
-				ret_val = size;
-			else
-			/* may return 0, but later on size == 0 means "don't
-			   write the length" */
-				ret_val = put_user(size,
-						   &((struct atmif_sioc *) arg)->length) ? -EFAULT : 0;
-			goto done_release;
-		case ATM_SETLOOP:
-			if (__ATM_LM_XTRMT((int) (long) buf) &&
-			    __ATM_LM_XTLOC((int) (long) buf) >
-			    __ATM_LM_XTRMT((int) (long) buf)) {
-				ret_val = -EINVAL;
-				goto done_release;
-			}
-			/* fall through */
-		case ATM_SETCIRANGE:
-		case SONET_GETSTATZ:
-		case SONET_SETDIAG:
-		case SONET_CLRDIAG:
-		case SONET_SETFRAMING:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret_val = -EPERM;
-				goto done_release;
-			}
-			/* fall through */
-		default:
-			if (!dev->ops->ioctl) {
-				ret_val = -EINVAL;
-				goto done_release;
-			}
-			size = dev->ops->ioctl(dev,cmd,buf);
-			if (size < 0) {
-				ret_val = (size == -ENOIOCTLCMD ? -EINVAL : size);
-				goto done_release;
-			}
-	}
-	
-	if (size)
-		ret_val =  put_user(size,&((struct atmif_sioc *) arg)->length) ?
-			-EFAULT : 0;
-	else
-		ret_val = 0;
-done_release:
-	atm_dev_release(dev);
+	error = atm_dev_ioctl(cmd, arg);
 
 done:
-	return ret_val;
+	return error;
 }
 
 
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Tue Jun 17 08:12:22 2003
+++ b/net/atm/common.h	Tue Jun 17 08:12:22 2003
@@ -18,7 +18,7 @@
 int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		int total_len);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
-int atm_ioctl(struct socket *sock,unsigned int cmd,unsigned long arg);
+int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
     int optlen);
 int atm_getsockopt(struct socket *sock,int level,int optname,char *optval,
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Tue Jun 17 08:12:22 2003
+++ b/net/atm/pvc.c	Tue Jun 17 08:12:22 2003
@@ -82,7 +82,7 @@
 	.accept =	sock_no_accept,
 	.getname =	pvc_getname,
 	.poll =		atm_poll,
-	.ioctl =	atm_ioctl,
+	.ioctl =	vcc_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	pvc_shutdown,
 	.setsockopt =	atm_setsockopt,
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	Tue Jun 17 08:12:22 2003
+++ b/net/atm/resources.c	Tue Jun 17 08:12:22 2003
@@ -12,6 +12,7 @@
 #include <linux/ctype.h>
 #include <linux/string.h>
 #include <linux/atmdev.h>
+#include <linux/sonet.h>
 #include <linux/kernel.h> /* for barrier */
 #include <linux/module.h>
 #include <linux/bitops.h>
@@ -19,6 +20,7 @@
 
 #include "common.h"
 #include "resources.h"
+#include "addr.h"
 
 
 #ifndef NULL
@@ -170,6 +172,240 @@
 		dev->ops->dev_close(dev);
 	atm_dev_deregister(dev);
 }
+
+
+static void copy_aal_stats(struct k_atm_aal_stats *from,
+    struct atm_aal_stats *to)
+{
+#define __HANDLE_ITEM(i) to->i = atomic_read(&from->i)
+	__AAL_STAT_ITEMS
+#undef __HANDLE_ITEM
+}
+
+
+static void subtract_aal_stats(struct k_atm_aal_stats *from,
+    struct atm_aal_stats *to)
+{
+#define __HANDLE_ITEM(i) atomic_sub(to->i, &from->i)
+	__AAL_STAT_ITEMS
+#undef __HANDLE_ITEM
+}
+
+
+static int fetch_stats(struct atm_dev *dev, struct atm_dev_stats *arg, int zero)
+{
+	struct atm_dev_stats tmp;
+	int error = 0;
+
+	copy_aal_stats(&dev->stats.aal0, &tmp.aal0);
+	copy_aal_stats(&dev->stats.aal34, &tmp.aal34);
+	copy_aal_stats(&dev->stats.aal5, &tmp.aal5);
+	if (arg)
+		error = copy_to_user(arg, &tmp, sizeof(tmp));
+	if (zero && !error) {
+		subtract_aal_stats(&dev->stats.aal0, &tmp.aal0);
+		subtract_aal_stats(&dev->stats.aal34, &tmp.aal34);
+		subtract_aal_stats(&dev->stats.aal5, &tmp.aal5);
+	}
+	return error ? -EFAULT : 0;
+}
+
+
+int atm_dev_ioctl(unsigned int cmd, unsigned long arg)
+{
+	void *buf;
+	int error, len, number, size = 0;
+	struct atm_dev *dev;
+	struct list_head *p;
+	int *tmp_buf, *tmp_p;
+
+	switch (cmd) {
+		case ATM_GETNAMES:
+			if (get_user(buf, &((struct atm_iobuf *) arg)->buffer))
+				return -EFAULT;
+			if (get_user(len, &((struct atm_iobuf *) arg)->length))
+				return -EFAULT;
+			spin_lock(&atm_dev_lock);
+			list_for_each(p, &atm_devs)
+				size += sizeof(int);
+			if (size > len) {
+				spin_unlock(&atm_dev_lock);
+				return -E2BIG;
+			}
+			tmp_buf = kmalloc(size, GFP_ATOMIC);
+			if (!tmp_buf) {
+				spin_unlock(&atm_dev_lock);
+				return -ENOMEM;
+			}
+			tmp_p = tmp_buf;
+			list_for_each(p, &atm_devs) {
+				dev = list_entry(p, struct atm_dev, dev_list);
+				*tmp_p++ = dev->number;
+			}
+			spin_unlock(&atm_dev_lock);
+		        error = ((copy_to_user(buf, tmp_buf, size)) ||
+					put_user(size, &((struct atm_iobuf *) arg)->length))
+						? -EFAULT : 0;
+			kfree(tmp_buf);
+			return error;
+		default:
+			break;
+	}
+
+	if (get_user(buf, &((struct atmif_sioc *) arg)->arg))
+		return -EFAULT;
+	if (get_user(len, &((struct atmif_sioc *) arg)->length))
+		return -EFAULT;
+	if (get_user(number, &((struct atmif_sioc *) arg)->number))
+		return -EFAULT;
+
+	if (!(dev = atm_dev_lookup(number)))
+		return -ENODEV;
+	
+	switch (cmd) {
+		case ATM_GETTYPE:
+			size = strlen(dev->type) + 1;
+			if (copy_to_user(buf, dev->type, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_GETESI:
+			size = ESI_LEN;
+			if (copy_to_user(buf, dev->esi, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_SETESI:
+			{
+				int i;
+
+				for (i = 0; i < ESI_LEN; i++)
+					if (dev->esi[i]) {
+						error = -EEXIST;
+						goto done;
+					}
+			}
+			/* fall through */
+		case ATM_SETESIF:
+			{
+				unsigned char esi[ESI_LEN];
+
+				if (!capable(CAP_NET_ADMIN)) {
+					error = -EPERM;
+					goto done;
+				}
+				if (copy_from_user(esi, buf, ESI_LEN)) {
+					error = -EFAULT;
+					goto done;
+				}
+				memcpy(dev->esi, esi, ESI_LEN);
+				error =  ESI_LEN;
+				goto done;
+			}
+		case ATM_GETSTATZ:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			/* fall through */
+		case ATM_GETSTAT:
+			size = sizeof(struct atm_dev_stats);
+			error = fetch_stats(dev, buf, cmd == ATM_GETSTATZ);
+			if (error)
+				goto done;
+			break;
+		case ATM_GETCIRANGE:
+			size = sizeof(struct atm_cirange);
+			if (copy_to_user(buf, &dev->ci_range, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_GETLINKRATE:
+			size = sizeof(int);
+			if (copy_to_user(buf, &dev->link_rate, size)) {
+				error = -EFAULT;
+				goto done;
+			}
+			break;
+		case ATM_RSTADDR:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			atm_reset_addr(dev);
+			break;
+		case ATM_ADDADDR:
+		case ATM_DELADDR:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			{
+				struct sockaddr_atmsvc addr;
+
+				if (copy_from_user(&addr, buf, sizeof(addr))) {
+					error = -EFAULT;
+					goto done;
+				}
+				if (cmd == ATM_ADDADDR)
+					error = atm_add_addr(dev, &addr);
+				else
+					error = atm_del_addr(dev, &addr);
+				goto done;
+			}
+		case ATM_GETADDR:
+			error = atm_get_addr(dev, buf, len);
+			if (error < 0)
+				goto done;
+			size = error;
+			/* may return 0, but later on size == 0 means "don't
+			   write the length" */
+			error = put_user(size, &((struct atmif_sioc *) arg)->length)
+				? -EFAULT : 0;
+			goto done;
+		case ATM_SETLOOP:
+			if (__ATM_LM_XTRMT((int) (long) buf) &&
+			    __ATM_LM_XTLOC((int) (long) buf) >
+			    __ATM_LM_XTRMT((int) (long) buf)) {
+				error = -EINVAL;
+				goto done;
+			}
+			/* fall through */
+		case ATM_SETCIRANGE:
+		case SONET_GETSTATZ:
+		case SONET_SETDIAG:
+		case SONET_CLRDIAG:
+		case SONET_SETFRAMING:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			/* fall through */
+		default:
+			if (!dev->ops->ioctl) {
+				error = -EINVAL;
+				goto done;
+			}
+			size = dev->ops->ioctl(dev, cmd, buf);
+			if (size < 0) {
+				error = (size == -ENOIOCTLCMD ? -EINVAL : size);
+				goto done;
+			}
+	}
+	
+	if (size)
+		error = put_user(size, &((struct atmif_sioc *) arg)->length)
+			? -EFAULT : 0;
+	else
+		error = 0;
+done:
+	atm_dev_release(dev);
+	return error;
+}
+
 
 struct sock *alloc_atm_vcc_sk(int family)
 {
diff -Nru a/net/atm/resources.h b/net/atm/resources.h
--- a/net/atm/resources.h	Tue Jun 17 08:12:22 2003
+++ b/net/atm/resources.h	Tue Jun 17 08:12:22 2003
@@ -16,6 +16,7 @@
 
 struct sock *alloc_atm_vcc_sk(int family);
 void free_atm_vcc_sk(struct sock *sk);
+int atm_dev_ioctl(unsigned int cmd, unsigned long arg);
 
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Tue Jun 17 08:12:22 2003
+++ b/net/atm/svc.c	Tue Jun 17 08:12:22 2003
@@ -402,7 +402,7 @@
 	.accept =	svc_accept,
 	.getname =	svc_getname,
 	.poll =		atm_poll,
-	.ioctl =	atm_ioctl,
+	.ioctl =	vcc_ioctl,
 	.listen =	svc_listen,
 	.shutdown =	svc_shutdown,
 	.setsockopt =	svc_setsockopt,










fg
