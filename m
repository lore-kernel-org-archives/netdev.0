From: Amos Kong <akong@redhat.com>
Subject: [PATCH] tun: do not put self in waitq if doing a nonblock read
Date: Thu, 09 Jun 2011 07:46:06 +0800
Message-ID: <20110608234606.8681.19932.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, davem@davemloft.net, kvm@vger.kernel.org,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Perf shows a relatively high rate (about 8%) race in
spin_lock_irqsave() when doing netperf between external host and
guest. It's mainly becuase the lock contention between the
tun_do_read() and tun_xmit_skb(), so this patch do not put self into
waitqueue to reduce this kind of race. After this patch, it drops to
4%.

Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Amos Kong <akong@redhat.com>
---
 drivers/net/tun.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 74e9405..95dbff4 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -817,7 +817,8 @@ static ssize_t tun_do_read(struct tun_struct *tun,
 
 	tun_debug(KERN_INFO, tun, "tun_chr_read\n");
 
-	add_wait_queue(&tun->wq.wait, &wait);
+	if (unlikely(!noblock))
+		add_wait_queue(&tun->wq.wait, &wait);
 	while (len) {
 		current->state = TASK_INTERRUPTIBLE;
 
@@ -848,7 +849,8 @@ static ssize_t tun_do_read(struct tun_struct *tun,
 	}
 
 	current->state = TASK_RUNNING;
-	remove_wait_queue(&tun->wq.wait, &wait);
+	if (unlikely(!noblock))
+		remove_wait_queue(&tun->wq.wait, &wait);
 
 	return ret;
 }

