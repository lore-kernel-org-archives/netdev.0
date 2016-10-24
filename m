From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] can: fix warning in bcm_connect/proc_register
Date: Mon, 24 Oct 2016 21:11:26 +0200
Message-ID: <20161024191126.30256-1-socketcan@hartkopp.net>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
        kcc@google.com, glider@google.com, dvyukov@google.com,
        edumazet@google.com, Oliver Hartkopp <socketcan@hartkopp.net>
To: andreyknvl@google.com, xiyou.wangcong@gmail.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Konovalov reported an issue with proc_register in bcm.c.
As suggested by Cong Wang this patch adds a lock_sock() protection and
a check for unsuccessful proc_create_data() in bcm_connect().

Reference: http://marc.info/?l=linux-netdev&m=147732648731237

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 net/can/bcm.c | 32 +++++++++++++++++++++++---------
 1 file changed, 23 insertions(+), 9 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 8e999ff..8af9d25 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1549,24 +1549,31 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	struct sockaddr_can *addr = (struct sockaddr_can *)uaddr;
 	struct sock *sk = sock->sk;
 	struct bcm_sock *bo = bcm_sk(sk);
+	int ret = 0;
 
 	if (len < sizeof(*addr))
 		return -EINVAL;
 
-	if (bo->bound)
-		return -EISCONN;
+	lock_sock(sk);
+
+	if (bo->bound) {
+		ret = -EISCONN;
+		goto fail;
+	}
 
 	/* bind a device to this socket */
 	if (addr->can_ifindex) {
 		struct net_device *dev;
 
 		dev = dev_get_by_index(&init_net, addr->can_ifindex);
-		if (!dev)
-			return -ENODEV;
-
+		if (!dev) {
+			ret = -ENODEV;
+			goto fail;
+		}
 		if (dev->type != ARPHRD_CAN) {
 			dev_put(dev);
-			return -ENODEV;
+			ret = -ENODEV;
+			goto fail;
 		}
 
 		bo->ifindex = dev->ifindex;
@@ -1577,17 +1584,24 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 		bo->ifindex = 0;
 	}
 
-	bo->bound = 1;
-
 	if (proc_dir) {
 		/* unique socket address as filename */
 		sprintf(bo->procname, "%lu", sock_i_ino(sk));
 		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
 						     proc_dir,
 						     &bcm_proc_fops, sk);
+		if (!bo->bcm_proc_read) {
+			ret = -ENOMEM;
+			goto fail;
+		}
 	}
 
-	return 0;
+	bo->bound = 1;
+
+fail:
+	release_sock(sk);
+
+	return ret;
 }
 
 static int bcm_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
-- 
2.9.3
