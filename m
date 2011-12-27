From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH -next] netrom: avoid overflows in nr_setsockopt()
Date: Tue, 27 Dec 2011 14:44:53 -0500
Message-ID: <1325015093-28968-1-git-send-email-xi.wang@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>, Xi Wang <xi.wang@gmail.com>
To: linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:64090 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab1L0Tqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 14:46:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check setsockopt arguments to avoid overflows and return -EINVAL for
too large arguments.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 net/netrom/af_netrom.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index c329b47..7dab229 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -306,26 +306,26 @@ static int nr_setsockopt(struct socket *sock, int level, int optname,
 {
 	struct sock *sk = sock->sk;
 	struct nr_sock *nr = nr_sk(sk);
-	int opt;
+	unsigned long opt;
 
 	if (level != SOL_NETROM)
 		return -ENOPROTOOPT;
 
-	if (optlen < sizeof(int))
+	if (optlen < sizeof(unsigned int))
 		return -EINVAL;
 
-	if (get_user(opt, (int __user *)optval))
+	if (get_user(opt, (unsigned int __user *)optval))
 		return -EFAULT;
 
 	switch (optname) {
 	case NETROM_T1:
-		if (opt < 1)
+		if (opt < 1 || opt > ULONG_MAX / HZ)
 			return -EINVAL;
 		nr->t1 = opt * HZ;
 		return 0;
 
 	case NETROM_T2:
-		if (opt < 1)
+		if (opt < 1 || opt > ULONG_MAX / HZ)
 			return -EINVAL;
 		nr->t2 = opt * HZ;
 		return 0;
@@ -337,13 +337,13 @@ static int nr_setsockopt(struct socket *sock, int level, int optname,
 		return 0;
 
 	case NETROM_T4:
-		if (opt < 1)
+		if (opt < 1 || opt > ULONG_MAX / HZ)
 			return -EINVAL;
 		nr->t4 = opt * HZ;
 		return 0;
 
 	case NETROM_IDLE:
-		if (opt < 0)
+		if (opt > ULONG_MAX / (60 * HZ))
 			return -EINVAL;
 		nr->idle = opt * 60 * HZ;
 		return 0;
-- 
1.7.5.4
