From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH -next] ax25: avoid overflows in ax25_setsockopt()
Date: Tue, 27 Dec 2011 14:43:19 -0500
Message-ID: <1325014999-28931-1-git-send-email-xi.wang@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>, Ralf Baechle <ralf@linux-mips.org>
To: linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit be639ac6 ("NET: AX.25: Check ioctl arguments to avoid overflows
further down the road") rejects very large arguments, but doesn't
completely fix overflows on 64-bit systems.  Consider the AX25_T2 case.

	int opt;
	...
	if (opt < 1 || opt > ULONG_MAX / HZ) {
		res = -EINVAL;
		break;
	}
	ax25->t2 = opt * HZ;

The 32-bit multiplication opt * HZ would overflow before being assigned
to 64-bit ax25->t2.  This patch changes "opt" to unsigned long.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
---
 net/ax25/af_ax25.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index b863c18..3cd0a0d 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -545,15 +545,16 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 	ax25_cb *ax25;
 	struct net_device *dev;
 	char devname[IFNAMSIZ];
-	int opt, res = 0;
+	unsigned long opt;
+	int res = 0;
 
 	if (level != SOL_AX25)
 		return -ENOPROTOOPT;
 
-	if (optlen < sizeof(int))
+	if (optlen < sizeof(unsigned int))
 		return -EINVAL;
 
-	if (get_user(opt, (int __user *)optval))
+	if (get_user(opt, (unsigned int __user *)optval))
 		return -EFAULT;
 
 	lock_sock(sk);
@@ -609,7 +610,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case AX25_IDLE:
-		if (opt < 0 || opt > ULONG_MAX / (60 * HZ)) {
+		if (opt > ULONG_MAX / (60 * HZ)) {
 			res = -EINVAL;
 			break;
 		}
@@ -617,7 +618,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case AX25_BACKOFF:
-		if (opt < 0 || opt > 2) {
+		if (opt > 2) {
 			res = -EINVAL;
 			break;
 		}
-- 
1.7.5.4

