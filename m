From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Mon, 24 Mar 2014 00:02:32 +0530
Message-ID: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
To: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	xemul@parallels.com, wuzhy@linux.vnet.ibm.com, therbert@google.com,
	yamato@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/net/tun.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 26f8635..ee328ba 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -452,7 +452,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 
 		--tun->numqueues;
 		if (clean) {
-			rcu_assign_pointer(tfile->tun, NULL);
+			RCU_INIT_POINTER(tfile->tun, NULL);
 			sock_put(&tfile->sk);
 		} else
 			tun_disable_queue(tun, tfile);
@@ -499,12 +499,12 @@ static void tun_detach_all(struct net_device *dev)
 		tfile = rtnl_dereference(tun->tfiles[i]);
 		BUG_ON(!tfile);
 		wake_up_all(&tfile->wq.wait);
-		rcu_assign_pointer(tfile->tun, NULL);
+		RCU_INIT_POINTER(tfile->tun, NULL);
 		--tun->numqueues;
 	}
 	list_for_each_entry(tfile, &tun->disabled, next) {
 		wake_up_all(&tfile->wq.wait);
-		rcu_assign_pointer(tfile->tun, NULL);
+		RCU_INIT_POINTER(tfile->tun, NULL);
 	}
 	BUG_ON(tun->numqueues != 0);
 
@@ -2194,7 +2194,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 					    &tun_proto);
 	if (!tfile)
 		return -ENOMEM;
-	rcu_assign_pointer(tfile->tun, NULL);
+	RCU_INIT_POINTER(tfile->tun, NULL);
 	tfile->net = get_net(current->nsproxy->net_ns);
 	tfile->flags = 0;
 	tfile->ifindex = 0;
-- 
1.7.9.5
