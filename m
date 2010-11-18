From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 1/4] X25: pushdown bkl in ioctls
Date: Fri, 19 Nov 2010 10:20:57 +1100
Message-ID: <1290122457.20070.57.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56454 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754835Ab0KRXVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 18:21:03 -0500
Received: by vws13 with SMTP id 13so2163943vws.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 15:21:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Push down the bkl in the ioctls so they can be removed one at a time.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |   41 ++++++++++++++++++++++++++++++++++++++---
 1 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index f7af98d..c99029b 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1357,14 +1357,16 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 	int rc;
 
-	lock_kernel();
 	switch (cmd) {
 		case TIOCOUTQ: {
-			int amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
+			int amount;
 
+			lock_kernel();
+			amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 			if (amount < 0)
 				amount = 0;
 			rc = put_user(amount, (unsigned int __user *)argp);
+			unlock_kernel();
 			break;
 		}
 
@@ -1375,23 +1377,29 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			 * These two are safe on a single CPU system as
 			 * only user tasks fiddle here
 			 */
+			lock_kernel();
 			if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
 				amount = skb->len;
 			rc = put_user(amount, (unsigned int __user *)argp);
+			unlock_kernel();
 			break;
 		}
 
 		case SIOCGSTAMP:
 			rc = -EINVAL;
+			lock_kernel();
 			if (sk)
 				rc = sock_get_timestamp(sk,
 						(struct timeval __user *)argp);
+			unlock_kernel();
 			break;
 		case SIOCGSTAMPNS:
 			rc = -EINVAL;
+			lock_kernel();
 			if (sk)
 				rc = sock_get_timestampns(sk,
 						(struct timespec __user *)argp);
+			unlock_kernel();
 			break;
 		case SIOCGIFADDR:
 		case SIOCSIFADDR:
@@ -1410,27 +1418,36 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = -EPERM;
 			if (!capable(CAP_NET_ADMIN))
 				break;
+			lock_kernel();
 			rc = x25_route_ioctl(cmd, argp);
+			unlock_kernel();
 			break;
 		case SIOCX25GSUBSCRIP:
+			lock_kernel();
 			rc = x25_subscr_ioctl(cmd, argp);
+			unlock_kernel();
 			break;
 		case SIOCX25SSUBSCRIP:
 			rc = -EPERM;
 			if (!capable(CAP_NET_ADMIN))
 				break;
+			lock_kernel();
 			rc = x25_subscr_ioctl(cmd, argp);
+			unlock_kernel();
 			break;
 		case SIOCX25GFACILITIES: {
 			struct x25_facilities fac = x25->facilities;
+			lock_kernel();
 			rc = copy_to_user(argp, &fac,
 					  sizeof(fac)) ? -EFAULT : 0;
+			unlock_kernel();
 			break;
 		}
 
 		case SIOCX25SFACILITIES: {
 			struct x25_facilities facilities;
 			rc = -EFAULT;
+			lock_kernel();
 			if (copy_from_user(&facilities, argp,
 					   sizeof(facilities)))
 				break;
@@ -1466,12 +1483,15 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 				break;
 			x25->facilities = facilities;
 			rc = 0;
+			unlock_kernel();
 			break;
 		}
 
 		case SIOCX25GDTEFACILITIES: {
+			lock_kernel();
 			rc = copy_to_user(argp, &x25->dte_facilities,
 						sizeof(x25->dte_facilities));
+			unlock_kernel();
 			if (rc)
 				rc = -EFAULT;
 			break;
@@ -1480,6 +1500,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		case SIOCX25SDTEFACILITIES: {
 			struct x25_dte_facilities dtefacs;
 			rc = -EFAULT;
+			lock_kernel();
 			if (copy_from_user(&dtefacs, argp, sizeof(dtefacs)))
 				break;
 			rc = -EINVAL;
@@ -1496,13 +1517,16 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 				break;
 			x25->dte_facilities = dtefacs;
 			rc = 0;
+			unlock_kernel();
 			break;
 		}
 
 		case SIOCX25GCALLUSERDATA: {
 			struct x25_calluserdata cud = x25->calluserdata;
+			lock_kernel();
 			rc = copy_to_user(argp, &cud,
 					  sizeof(cud)) ? -EFAULT : 0;
+			unlock_kernel();
 			break;
 		}
 
@@ -1510,6 +1534,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			struct x25_calluserdata calluserdata;
 
 			rc = -EFAULT;
+			lock_kernel();
 			if (copy_from_user(&calluserdata, argp,
 					   sizeof(calluserdata)))
 				break;
@@ -1517,24 +1542,29 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			if (calluserdata.cudlength > X25_MAX_CUD_LEN)
 				break;
 			x25->calluserdata = calluserdata;
+			unlock_kernel();
 			rc = 0;
 			break;
 		}
 
 		case SIOCX25GCAUSEDIAG: {
 			struct x25_causediag causediag;
+			lock_kernel();
 			causediag = x25->causediag;
 			rc = copy_to_user(argp, &causediag,
 					  sizeof(causediag)) ? -EFAULT : 0;
+			unlock_kernel();
 			break;
 		}
 
 		case SIOCX25SCAUSEDIAG: {
 			struct x25_causediag causediag;
 			rc = -EFAULT;
+			lock_kernel();
 			if (copy_from_user(&causediag, argp, sizeof(causediag)))
 				break;
 			x25->causediag = causediag;
+			unlock_kernel();
 			rc = 0;
 			break;
 
@@ -1543,6 +1573,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		case SIOCX25SCUDMATCHLEN: {
 			struct x25_subaddr sub_addr;
 			rc = -EINVAL;
+			lock_kernel();
 			if(sk->sk_state != TCP_CLOSE)
 				break;
 			rc = -EFAULT;
@@ -1553,21 +1584,25 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			if(sub_addr.cudmatchlength > X25_MAX_CUD_LEN)
 				break;
 			x25->cudmatchlength = sub_addr.cudmatchlength;
+			unlock_kernel();
 			rc = 0;
 			break;
 		}
 
 		case SIOCX25CALLACCPTAPPRV: {
 			rc = -EINVAL;
+			lock_kernel();
 			if (sk->sk_state != TCP_CLOSE)
 				break;
 			clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
+			unlock_kernel();
 			rc = 0;
 			break;
 		}
 
 		case SIOCX25SENDCALLACCPT:  {
 			rc = -EINVAL;
+			lock_kernel();
 			if (sk->sk_state != TCP_ESTABLISHED)
 				break;
 			/* must call accptapprv above */
@@ -1575,6 +1610,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 				break;
 			x25_write_internal(sk, X25_CALL_ACCEPTED);
 			x25->state = X25_STATE_3;
+			unlock_kernel();
 			rc = 0;
 			break;
 		}
@@ -1583,7 +1619,6 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = -ENOIOCTLCMD;
 			break;
 	}
-	unlock_kernel();
 
 	return rc;
 }
-- 
1.7.1


