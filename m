From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
Date: Fri, 25 Sep 2009 13:10:38 +0000
Message-ID: <20090925131038.GA14778@ff.dom.local>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:22856 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbZIYNKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 09:10:42 -0400
Content-Disposition: inline
In-Reply-To: <4ABA9058.3010605@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug isn't responsible for these oopses here, but looks quite
obviously. (I'm not sure if it's easy to test/hit with the common
tools.)

Jarek P.
------------>
[PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl

Use ax25_cb_put after ax25_find_cb in ax25_ctl_ioctl.

Reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/ax25/af_ax25.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index d6b1b05..fbcac76 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -358,6 +358,7 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 	ax25_dev *ax25_dev;
 	ax25_cb *ax25;
 	unsigned int k;
+	int ret = 0;
 
 	if (copy_from_user(&ax25_ctl, arg, sizeof(ax25_ctl)))
 		return -EFAULT;
@@ -388,57 +389,63 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 	case AX25_WINDOW:
 		if (ax25->modulus == AX25_MODULUS) {
 			if (ax25_ctl.arg < 1 || ax25_ctl.arg > 7)
-				return -EINVAL;
+				goto einval_put;
 		} else {
 			if (ax25_ctl.arg < 1 || ax25_ctl.arg > 63)
-				return -EINVAL;
+				goto einval_put;
 		}
 		ax25->window = ax25_ctl.arg;
 		break;
 
 	case AX25_T1:
 		if (ax25_ctl.arg < 1)
-			return -EINVAL;
+			goto einval_put;
 		ax25->rtt = (ax25_ctl.arg * HZ) / 2;
 		ax25->t1  = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_T2:
 		if (ax25_ctl.arg < 1)
-			return -EINVAL;
+			goto einval_put;
 		ax25->t2 = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_N2:
 		if (ax25_ctl.arg < 1 || ax25_ctl.arg > 31)
-			return -EINVAL;
+			goto einval_put;
 		ax25->n2count = 0;
 		ax25->n2 = ax25_ctl.arg;
 		break;
 
 	case AX25_T3:
 		if (ax25_ctl.arg < 0)
-			return -EINVAL;
+			goto einval_put;
 		ax25->t3 = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_IDLE:
 		if (ax25_ctl.arg < 0)
-			return -EINVAL;
+			goto einval_put;
 		ax25->idle = ax25_ctl.arg * 60 * HZ;
 		break;
 
 	case AX25_PACLEN:
 		if (ax25_ctl.arg < 16 || ax25_ctl.arg > 65535)
-			return -EINVAL;
+			goto einval_put;
 		ax25->paclen = ax25_ctl.arg;
 		break;
 
 	default:
-		return -EINVAL;
+		goto einval_put;
 	  }
 
-	return 0;
+out_put:
+	ax25_cb_put(ax25);
+	return ret;
+
+einval_put:
+	ret = -EINVAL;
+	goto out_put;
 }
 
 static void ax25_fillin_cb_from_dev(ax25_cb *ax25, ax25_dev *ax25_dev)
