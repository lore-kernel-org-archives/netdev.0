From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH net-next 2/5] X25 remove bkl in facility ioctls
Date: Thu, 25 Nov 2010 23:18:35 +1100
Message-ID: <1290687515.5053.40.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62246 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab0KYMSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:18:24 -0500
Received: by gyb11 with SMTP id 11so421210gyb.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 04:18:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |   48 +++++++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 45be72c..2518efa 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1424,34 +1424,34 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = x25_subscr_ioctl(cmd, argp);
 			break;
 		case SIOCX25GFACILITIES: {
-			struct x25_facilities fac = x25->facilities;
-			lock_kernel();
-			rc = copy_to_user(argp, &fac,
-					  sizeof(fac)) ? -EFAULT : 0;
-			unlock_kernel();
+			lock_sock(sk);
+			rc = copy_to_user(argp, &x25->facilities,
+						sizeof(x25->facilities))
+						? -EFAULT : 0;
+			release_sock(sk);
 			break;
 		}
 
 		case SIOCX25SFACILITIES: {
 			struct x25_facilities facilities;
 			rc = -EFAULT;
-			lock_kernel();
 			if (copy_from_user(&facilities, argp,
 					   sizeof(facilities)))
 				break;
 			rc = -EINVAL;
+			lock_sock(sk);
 			if (sk->sk_state != TCP_LISTEN &&
 			    sk->sk_state != TCP_CLOSE)
-				break;
+				goto out_fac_release;
 			if (facilities.pacsize_in < X25_PS16 ||
 			    facilities.pacsize_in > X25_PS4096)
-				break;
+				goto out_fac_release;
 			if (facilities.pacsize_out < X25_PS16 ||
 			    facilities.pacsize_out > X25_PS4096)
-				break;
+				goto out_fac_release;
 			if (facilities.winsize_in < 1 ||
 			    facilities.winsize_in > 127)
-				break;
+				goto out_fac_release;
 			if (facilities.throughput) {
 				int out = facilities.throughput & 0xf0;
 				int in  = facilities.throughput & 0x0f;
@@ -1459,27 +1459,28 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 					facilities.throughput |=
 						X25_DEFAULT_THROUGHPUT << 4;
 				else if (out < 0x30 || out > 0xD0)
-					break;
+					goto out_fac_release;
 				if (!in)
 					facilities.throughput |=
 						X25_DEFAULT_THROUGHPUT;
 				else if (in < 0x03 || in > 0x0D)
-					break;
+					goto out_fac_release;
 			}
 			if (facilities.reverse &&
 				(facilities.reverse & 0x81) != 0x81)
-				break;
+				goto out_fac_release;
 			x25->facilities = facilities;
 			rc = 0;
-			unlock_kernel();
+out_fac_release:
+			release_sock(sk);
 			break;
 		}
 
 		case SIOCX25GDTEFACILITIES: {
-			lock_kernel();
+			lock_sock(sk);
 			rc = copy_to_user(argp, &x25->dte_facilities,
 						sizeof(x25->dte_facilities));
-			unlock_kernel();
+			release_sock(sk);
 			if (rc)
 				rc = -EFAULT;
 			break;
@@ -1488,24 +1489,25 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		case SIOCX25SDTEFACILITIES: {
 			struct x25_dte_facilities dtefacs;
 			rc = -EFAULT;
-			lock_kernel();
 			if (copy_from_user(&dtefacs, argp, sizeof(dtefacs)))
 				break;
 			rc = -EINVAL;
+			lock_sock(sk);
 			if (sk->sk_state != TCP_LISTEN &&
 					sk->sk_state != TCP_CLOSE)
-				break;
+				goto out_dtefac_release;
 			if (dtefacs.calling_len > X25_MAX_AE_LEN)
-				break;
+				goto out_dtefac_release;
 			if (dtefacs.calling_ae == NULL)
-				break;
+				goto out_dtefac_release;
 			if (dtefacs.called_len > X25_MAX_AE_LEN)
-				break;
+				goto out_dtefac_release;
 			if (dtefacs.called_ae == NULL)
-				break;
+				goto out_dtefac_release;
 			x25->dte_facilities = dtefacs;
 			rc = 0;
-			unlock_kernel();
+out_dtefac_release:
+			release_sock(sk);
 			break;
 		}
 
-- 
1.7.1



