From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ax25 setsockopt(SO_BINDTODEVICE) bug fix
Date: Tue, 12 Aug 2003 17:19:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812171926.628186dc.shemminger@osdl.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
	<20030812153901.6e700dcb.shemminger@osdl.org>
	<20030813010301.K28977@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, ralf@linux-mips.org, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030813010301.K28977@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix the error path (and indentation) in the SO_BINDTODEVICE setsockopt.
As it was, a reference to the device was left hanging, and it would
not check to see if the device was really an AX25 device.

Found this with a simple test program on 2.6.0-test3 with your rqx4 patch.

--- ax25/net/ax25/af_ax25.c	2003-08-12 17:08:42.025816088 -0700
+++ linux-2.5-net/net/ax25/af_ax25.c	2003-08-12 16:47:07.802057749 -0700
 		if (optlen > IFNAMSIZ)
 			optlen=IFNAMSIZ;
 		if (copy_from_user(devname, optval, optlen)) {
-		res = -EFAULT;
+			res = -EFAULT;
 			break;
 		}
 
@@ -650,12 +650,14 @@ static int ax25_setsockopt(struct socket
 		   (sock->state != SS_UNCONNECTED ||
 		    sk->sk_state == TCP_LISTEN)) {
 			res = -EADDRNOTAVAIL;
-			dev_put(dev);
-			break;
 		}
 
-		ax25->ax25_dev = ax25_dev_ax25dev(dev);
-		ax25_fillin_cb(ax25, ax25->ax25_dev);
+		else if ((ax25->ax25_dev = ax25_dev_ax25dev(dev)) == NULL)
+			res = -EINVAL;
+		else 
+			ax25_fillin_cb(ax25, ax25->ax25_dev);
+
+		dev_put(dev);
 		break;
 
 	default:
