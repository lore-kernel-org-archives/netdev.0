From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] ax25: Add missing dev_put in ax25_setsockopt
Date: Mon, 28 Sep 2009 13:53:13 +0100
Message-ID: <20090928125313.GA14250@linux-mips.org>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr> <20090928071211.GA8658@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090928071211.GA8658@ff.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ax25_setsockopt SO_BINDTODEVICE is missing a dev_put call in case of
success.  Re-order code to fix this bug.  While at it also reformat two
lines of code to comply with the Linux coding style.

Initial patch by Jarek Poplawski <jarkao2@gmail.com>.

Reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
Counter-proposal.  Reordering all the code avoids the need for a 2nd dev_put
and is more readable.

   Ralf

 net/ax25/af_ax25.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index fbcac76..4102de1 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -641,15 +641,10 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 
 	case SO_BINDTODEVICE:
 		if (optlen > IFNAMSIZ)
-			optlen=IFNAMSIZ;
-		if (copy_from_user(devname, optval, optlen)) {
-		res = -EFAULT;
-			break;
-		}
+			optlen = IFNAMSIZ;
 
-		dev = dev_get_by_name(&init_net, devname);
-		if (dev == NULL) {
-			res = -ENODEV;
+		if (copy_from_user(devname, optval, optlen)) {
+			res = -EFAULT;
 			break;
 		}
 
@@ -657,12 +652,18 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		   (sock->state != SS_UNCONNECTED ||
 		    sk->sk_state == TCP_LISTEN)) {
 			res = -EADDRNOTAVAIL;
-			dev_put(dev);
+			break;
+		}
+
+		dev = dev_get_by_name(&init_net, devname);
+		if (!dev) {
+			res = -ENODEV;
 			break;
 		}
 
 		ax25->ax25_dev = ax25_dev_ax25dev(dev);
 		ax25_fillin_cb(ax25, ax25->ax25_dev);
+		dev_put(dev);
 		break;
 
 	default:
