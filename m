From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] [AX25] unsigned long timers in ax25_info_struct_new
Date: Fri, 11 Jul 2008 20:30:21 +0200
Message-ID: <200807112030.22162.bpidoux@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-hams" <linux-hams@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:58632 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbYGKS25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 14:28:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new structure is proposed with unsigned long types
for AX25 timers, in order to be compliant with kernel 2.6.
These timers are listed in /proc/net/ax25/

AX25 info can be copied into user space via ioctl call using
a new argument SIOCAX25GETINFONEW.

A KERN_INFO warning is printed if ioctl is called using
deprecated structure and argument.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 include/linux/ax25.h |   16 +++++++++++++++-
 net/ax25/af_ax25.c   |   16 +++++++++++-----
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/include/linux/ax25.h b/include/linux/ax25.h
index 56c11f0..5b4ee2f 100644
--- a/include/linux/ax25.h
+++ b/include/linux/ax25.h
@@ -36,6 +36,7 @@
 #define SIOCAX25DELFWD		(SIOCPROTOPRIVATE+11)
 #define SIOCAX25DEVCTL          (SIOCPROTOPRIVATE+12)
 #define SIOCAX25GETINFO         (SIOCPROTOPRIVATE+13)
+#define SIOCAX25GETINFONEW      (SIOCPROTOPRIVATE+14)
 
 #define AX25_SET_RT_IPMODE	2
 
@@ -94,7 +95,7 @@ struct ax25_info_struct_deprecated {
 	unsigned int	state;
 	unsigned int	rcv_q, snd_q;
 };
-
+/* deprecated */
 struct ax25_info_struct {
 	unsigned int	n2, n2count;
 	unsigned int	t1, t1timer;
@@ -108,6 +109,19 @@ struct ax25_info_struct {
 	unsigned int	window;
 };
 
+struct ax25_info_struct_new {
+	unsigned int	n2, n2count;
+	unsigned long	t1, t1timer;
+	unsigned long	t2, t2timer;
+	unsigned long	t3, t3timer;
+	unsigned long	idle, idletimer;
+	unsigned int	state;
+	unsigned int	rcv_q, snd_q;
+	unsigned int	vs, vr, va, vs_max;
+	unsigned int	paclen;
+	unsigned int	window;
+};
+
 struct ax25_fwd_struct {
 	ax25_address	port_from;
 	ax25_address	port_to;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 2712544..e52c6af 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1769,9 +1769,10 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		break;
 
 	case SIOCAX25GETINFO:
+	case SIOCAX25GETINFONEW:
 	case SIOCAX25GETINFOOLD: {
 		ax25_cb *ax25 = ax25_sk(sk);
-		struct ax25_info_struct ax25_info;
+		struct ax25_info_struct_new ax25_info;
 
 		ax25_info.t1        = ax25->t1   / HZ;
 		ax25_info.t2        = ax25->t2   / HZ;
@@ -1793,11 +1794,11 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		ax25_info.paclen    = ax25->paclen;
 		ax25_info.window    = ax25->window;
 
-		/* old structure? */
-		if (cmd == SIOCAX25GETINFOOLD) {
+		/* old structure ? */
+		if (cmd != SIOCAX25GETINFONEW) {
 			static int warned = 0;
 			if (!warned) {
-				printk(KERN_INFO "%s uses old SIOCAX25GETINFO\n",
+				printk(KERN_INFO "%s uses deprecated SIOCAX25GETINFOOLD or SIOCAX25GETINFO\n",
 					current->comm);
 				warned=1;
 			}
@@ -1806,8 +1807,13 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 				res = -EFAULT;
 				break;
 			}
-		} else {
+
 			if (copy_to_user(argp, &ax25_info, sizeof(struct ax25_info_struct))) {
+				res = -EFAULT;
+				break;
+			}
+		} else {
+			if (copy_to_user(argp, &ax25_info, sizeof(struct ax25_info_struct_new))) {
 				res = -EINVAL;
 				break;
 			}
-- 
1.5.5

