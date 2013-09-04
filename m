From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 1/2] tuntap: purge socket error queue on detach
Date: Wed,  4 Sep 2013 12:33:45 +0800
Message-ID: <1378269226-5969-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit eda297729171fe16bf34fe5b0419dfb69060f623
(tun: Support software transmit time stamping) will queue skbs into error queue
when tx stamping is enabled. But it forgets to purge the error queue during
detach. This patch fixes this.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 60a1e93..2dddb1b 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -409,6 +409,12 @@ static struct tun_struct *tun_enable_queue(struct tun_file *tfile)
 	return tun;
 }
 
+static void tun_queue_purge(struct tun_file *tfile)
+{
+	skb_queue_purge(&tfile->sk.sk_receive_queue);
+	skb_queue_purge(&tfile->sk.sk_error_queue);
+}
+
 static void __tun_detach(struct tun_file *tfile, bool clean)
 {
 	struct tun_file *ntfile;
@@ -435,7 +441,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 		synchronize_net();
 		tun_flow_delete_by_queue(tun, tun->numqueues + 1);
 		/* Drop read queue */
-		skb_queue_purge(&tfile->sk.sk_receive_queue);
+		tun_queue_purge(tfile);
 		tun_set_real_num_queues(tun);
 	} else if (tfile->detached && clean) {
 		tun = tun_enable_queue(tfile);
@@ -487,12 +493,12 @@ static void tun_detach_all(struct net_device *dev)
 	for (i = 0; i < n; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
 		/* Drop read queue */
-		skb_queue_purge(&tfile->sk.sk_receive_queue);
+		tun_queue_purge(tfile);
 		sock_put(&tfile->sk);
 	}
 	list_for_each_entry_safe(tfile, tmp, &tun->disabled, next) {
 		tun_enable_queue(tfile);
-		skb_queue_purge(&tfile->sk.sk_receive_queue);
+		tun_queue_purge(tfile);
 		sock_put(&tfile->sk);
 	}
 	BUG_ON(tun->numdisabled != 0);
-- 
1.7.1
