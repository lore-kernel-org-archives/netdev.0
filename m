From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: Re: [RFC] [ver3 PATCH 0/6] Implement multiqueue virtio-net
Date: Sat, 12 Nov 2011 11:15:46 +0530
Message-ID: <20111112054546.9555.7764.sendpatchset@krkumar2.in.ibm.com>
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, virtualization@lists.linux-foundation.org,
	davem@davemloft.net, Krishna Kumar <krkumar2@in.ibm.com>
To: levinsasha928@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sasha Levin <levinsasha928@gmail.com> wrote on 11/12/2011 03:32:04 AM:

> I'm seeing this BUG() sometimes when running it using a small patch I
> did for KVM tool:
> 
> [    1.281531] Call Trace:
> [    1.281531]  [<ffffffff8138a0e5>] ? free_rq_sq+0x2c/0xce
> [    1.281531]  [<ffffffff8138bb63>] ? virtnet_probe+0x81c/0x855
> [    1.281531]  [<ffffffff8129c9e7>] ? virtio_dev_probe+0xa7/0xc6
> [    1.281531]  [<ffffffff8134d2c3>] ? driver_probe_device+0xb2/0x142
> [    1.281531]  [<ffffffff8134d3a2>] ? __driver_attach+0x4f/0x6f
> [    1.281531]  [<ffffffff8134d353>] ? driver_probe_device+0x142/0x142
> [    1.281531]  [<ffffffff8134c3ab>] ? bus_for_each_dev+0x47/0x72
> [    1.281531]  [<ffffffff8134c90d>] ? bus_add_driver+0xa2/0x1e6
> [    1.281531]  [<ffffffff81cc1b36>] ? tun_init+0x89/0x89
> [    1.281531]  [<ffffffff8134db59>] ? driver_register+0x8d/0xf8
> [    1.281531]  [<ffffffff81cc1b36>] ? tun_init+0x89/0x89
> [    1.281531]  [<ffffffff81c98ac1>] ? do_one_initcall+0x78/0x130
> [    1.281531]  [<ffffffff81c98c0e>] ? kernel_init+0x95/0x113
> [    1.281531]  [<ffffffff81658274>] ? kernel_thread_helper+0x4/0x10
> [    1.281531]  [<ffffffff81c98b79>] ? do_one_initcall+0x130/0x130
> [    1.281531]  [<ffffffff81658270>] ? gs_change+0x13/0x13
> [    1.281531] Code: c2 85 d2 48 0f 45 2d d1 39 ce 00 eb 22 65 8b 14 25
> 90 cc 00 00 48 8b 05 f0 a6 bc 00 48 63 d2 4c 89 e7 48 03 3c d0 e8 83 dd
> 00 00 
> [    1.281531]  8b 68 10 44 89 e6 48 89 ef 2b 75 18 e8 e4 f1 ff ff 8b 05
> fd 
> [    1.281531] RIP  [<ffffffff810b3ac7>] free_percpu+0x9a/0x104
> [    1.281531]  RSP <ffff88001383fd50>
> [    1.281531] CR2: 0000000000000010
> [    1.281531] ---[ end trace 68cbc23dfe2fe62a ]---
> 
> I don't have time today to dig into it, sorry.

Thanks for the report.

free_rq_sq() was being called twice in the failure path. The second
call panic'd since it had freed the same pointers earlier.

1. free_rq_sq() was being called twice in the failure path.
   virtnet_setup_vqs() had already freed up rq/sq on error, and
   virtnet_probe() tried to do it again. Fix it in virtnet_probe
   by moving the call up.
2. Make free_rq_sq() re-entrant by setting freed pointers to NULL.
3. Remove free_stats() as it was being called only once.

Sasha, could you please try this patch on top of existing patches?

thanks!

Signed-off-by: krkumar2@in.ibm.com
---
 drivers/net/virtio_net.c |   41 +++++++++++--------------------------
 1 file changed, 13 insertions(+), 28 deletions(-)

diff -ruNp n6/drivers/net/virtio_net.c n7/drivers/net/virtio_net.c
--- n6/drivers/net/virtio_net.c	2011-11-12 11:03:48.000000000 +0530
+++ n7/drivers/net/virtio_net.c	2011-11-12 10:39:28.000000000 +0530
@@ -782,23 +782,6 @@ static void virtnet_netpoll(struct net_d
 }
 #endif
 
-static void free_stats(struct virtnet_info *vi)
-{
-	int i;
-
-	for (i = 0; i < vi->num_queue_pairs; i++) {
-		if (vi->sq && vi->sq[i]) {
-			free_percpu(vi->sq[i]->stats);
-			vi->sq[i]->stats = NULL;
-		}
-
-		if (vi->rq && vi->rq[i]) {
-			free_percpu(vi->rq[i]->stats);
-			vi->rq[i]->stats = NULL;
-		}
-	}
-}
-
 static int virtnet_open(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -1054,19 +1037,22 @@ static void free_rq_sq(struct virtnet_in
 {
 	int i;
 
-	free_stats(vi);
-
-	if (vi->rq) {
-		for (i = 0; i < vi->num_queue_pairs; i++)
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		if (vi->rq && vi->rq[i]) {
+			free_percpu(vi->rq[i]->stats);
 			kfree(vi->rq[i]);
-		kfree(vi->rq);
-	}
+			vi->rq[i] = NULL;
+		}
 
-	if (vi->sq) {
-		for (i = 0; i < vi->num_queue_pairs; i++)
+		if (vi->sq && vi->sq[i]) {
+			free_percpu(vi->sq[i]->stats);
 			kfree(vi->sq[i]);
-		kfree(vi->sq);
+			vi->sq[i] = NULL;
+		}
 	}
+
+	kfree(vi->rq);
+	kfree(vi->sq);
 }
 
 static void free_unused_bufs(struct virtnet_info *vi)
@@ -1387,10 +1373,9 @@ free_vqs:
 	for (i = 0; i < num_queue_pairs; i++)
 		cancel_delayed_work_sync(&vi->rq[i]->refill);
 	vdev->config->del_vqs(vdev);
-
-free_netdev:
 	free_rq_sq(vi);
 
+free_netdev:
 	free_netdev(dev);
 	return err;
 }

