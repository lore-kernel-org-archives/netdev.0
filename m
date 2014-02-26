From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: [PATCH] vhost: poll vhost_net only when tx notification is enabled
Date: Wed, 26 Feb 2014 17:20:09 +0800
Message-ID: <530DB1C9.2060106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <zhangjie14@huawei.com>
To: <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, <netdev@vger.kernel.org>,
	KVM list <kvm@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5106 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaBZJUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 04:20:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

guest kick host base on avail_ring flags value and get perfermance
improved, vhost_zerocopy_callback could do the same thing. As
virtqueue_enable_cb need one more check after modifying the value of
avail_ring flags, vhost also need do the same thing after
vhost_enable_notify.

test result list as below:
guest and host: suse11sp3, netperf, intel CPU 2.4GHz
+------+----------+--------+----------+--------+--------+---------+
|      |             old              |            new            |
+------+----------+--------+----------+--------+--------+---------+
| UDP  |  Gbit/s  |  PPS   |CPU idle% | Gbit/s |   PPS  |CPU idle%|
| 256  | 0.74805  | 321309 |  87.16   | 0.77933| 334743 |  90.71  |
| 512  |   1.42   | 328475 |  87.03   |  1.44  | 333550 |  90.43  |
| 1024 |   2.79   | 334426 |  89.09   |  2.81  | 336986 |  89.55  |
| 1460 |   3.71   | 316215 |  87.53   |  4.02  | 342325 |  89.58  |
+------+----------+--------+----------+--------+--------+---------+

Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
---
  drivers/vhost/net.c |   13 ++++++++++++-
  1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index a0fa5de..a90f51b 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -315,6 +315,10 @@ static void vhost_zerocopy_callback(struct 
ubuf_info *ubuf, bool success)
  		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
  	cnt = vhost_net_ubuf_put(ubufs);

+	/* make sure len has been updated because handle_tx would use it
+	 * and used_flags should also been checked.
+	 */
+	smp_mb();
  	/*
  	 * Trigger polling thread if guest stopped submitting new buffers:
  	 * in this case, the refcount after decrement will eventually reach 1.
@@ -322,7 +326,8 @@ static void vhost_zerocopy_callback(struct ubuf_info 
*ubuf, bool success)
  	 * (the value 16 here is more or less arbitrary, it's tuned to trigger
  	 * less than 10% of times).
  	 */
-	if (cnt <= 1 || !(cnt % 16))
+	if ((!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
+			&& (cnt <= 1 || !(cnt % 16)))
  		vhost_poll_queue(&vq->poll);

  	rcu_read_unlock_bh();
@@ -386,6 +391,12 @@ static void handle_tx(struct vhost_net *net)
  				vhost_disable_notify(&net->dev, vq);
  				continue;
  			}
+			/* there might skb been freed between last
+			* vhost_zerocopy_signal_used and vhost_enable_notify,
+			* so one more check is needed.
+			*/
+			if (zcopy)
+				vhost_zerocopy_signal_used(net, vq);
  			break;
  		}
  		if (in) {
-- 
1.7.3.1.msysgit.0
