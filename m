From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: [PATCH] vhost: wake up worker outside spin_lock
Date: Fri, 7 Jun 2013 21:50:16 +0800
Message-ID: <51B1E518.1070003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kvm@vger.kernel.org>, <netdev@vger.kernel.org>
To: <mst@redhat.com>, <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:22963 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab3FGNuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 09:50:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the wake_up_process func is included by spin_lock/unlock in 
vhost_work_queue,
but it could be done outside the spin_lock.
I have test it with kernel 3.0.27 and guest suse11-sp2 using iperf,
the num as below.
                  original                 modified
thread_num  tp(Gbps)   vhost(%)  |  tp(Gbps)     vhost(%)
1           9.59        28.82    |   9.59        27.49
8           9.61        32.92    |   9.62        26.77
64          9.58        46.48    |   9.55        38.99
256         9.6         63.7     |   9.6         52.59

Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
---
  drivers/vhost/vhost.c |    4 +++-
  1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 94dbd25..dcc7a17 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -146,9 +146,11 @@ static inline void vhost_work_queue(struct 
vhost_dev *dev,
  	if (list_empty(&work->node)) {
  		list_add_tail(&work->node, &dev->work_list);
  		work->queue_seq++;
+		spin_unlock_irqrestore(&dev->work_lock, flags);
  		wake_up_process(dev->worker);
+	} else {
+		spin_unlock_irqrestore(&dev->work_lock, flags);
  	}
-	spin_unlock_irqrestore(&dev->work_lock, flags);
  }

  void vhost_poll_queue(struct vhost_poll *poll)
-- 
1.7.3.1.msysgit.0
