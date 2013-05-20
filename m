From: Qinchuanyu <qinchuanyu@huawei.com>
Subject: [PATCH] vhost: get 2% performance improved by reducing spin_lock
 race in vhost_work_queue
Date: Mon, 20 May 2013 03:06:25 +0000
Message-ID: <5872DA217C2FF7488B20897D84F904E7338FD1E5@nkgeml511-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: " (kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	" (netdev@vger.kernel.org)" <netdev@vger.kernel.org>
To: "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"mst@redhat.com" <mst@redhat.com>,
	"dhowells@redhat.com" <dhowells@redhat.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:35773 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab3ETDHc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 23:07:32 -0400
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now the wake_up_process func is included in spin_lock/unlock, but it could be done outside the spin_lock.
I have test it with kernel 3.0.27 and guest suse11-sp2, it provide 2%-3% net performance improved.

Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
--- a/drivers/vhost/vhost.c     2013-05-20 10:36:30.000000000 +0800
+++ b/drivers/vhost/vhost.c     2013-05-20 10:36:54.000000000 +0800
@@ -144,9 +144,10 @@
        if (list_empty(&work->node)) {
                list_add_tail(&work->node, &dev->work_list);
                work->queue_seq++;
+               spin_unlock_irqrestore(&dev->work_lock, flags);
                wake_up_process(dev->worker);
-       }
-       spin_unlock_irqrestore(&dev->work_lock, flags);
+       } else
+               spin_unlock_irqrestore(&dev->work_lock, flags);
 }
 
 void vhost_poll_queue(struct vhost_poll *poll)
