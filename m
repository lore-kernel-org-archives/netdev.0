From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 3/3] tuntap: fix leaking reference count
Date: Sat, 12 Jan 2013 10:59:34 +0800
Message-ID: <1357959574-13113-4-git-send-email-jasowang@redhat.com>
References: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Cc: edumazet@google.com, stefanha@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reference count leaking of both module and sock were found:

- When a detached file were closed, its sock refcnt from device were not
  released, solving this by add the sock_put().
- The module were hold or drop unconditionally in TUNSETPERSIST, which means we
  if we set the persist flag for N times, we need unset it for another N
  times. Solving this by only hold or drop an reference when there's a flag
  change and also drop the reference count when the persist device is deleted.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a36b56f..af372d0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -428,8 +428,10 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 		/* Drop read queue */
 		skb_queue_purge(&tfile->sk.sk_receive_queue);
 		tun_set_real_num_queues(tun);
-	} else if (tfile->detached && clean)
+	} else if (tfile->detached && clean) {
 		tun = tun_enable_queue(tfile);
+		sock_put(&tfile->sk);
+	}
 
 	if (clean) {
 		if (tun && tun->numqueues == 0 && tun->numdisabled == 0 &&
@@ -478,6 +480,9 @@ static void tun_detach_all(struct net_device *dev)
 		sock_put(&tfile->sk);
 	}
 	BUG_ON(tun->numdisabled != 0);
+
+	if (tun->flags & TUN_PERSIST)
+		module_put(THIS_MODULE);
 }
 
 static int tun_attach(struct tun_struct *tun, struct file *file)
@@ -1874,10 +1879,11 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		/* Disable/Enable persist mode. Keep an extra reference to the
 		 * module to prevent the module being unprobed.
 		 */
-		if (arg) {
+		if (arg && !(tun->flags & TUN_PERSIST)) {
 			tun->flags |= TUN_PERSIST;
 			__module_get(THIS_MODULE);
-		} else {
+		}
+		if (!arg && (tun->flags & TUN_PERSIST)) {
 			tun->flags &= ~TUN_PERSIST;
 			module_put(THIS_MODULE);
 		}
-- 
1.7.1
