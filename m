From: Yunjian Wang <wangyunjian@huawei.com>
Subject: [PATCH net] vhost_net: don't continue to call the recvmsg when meet errors
Date: Wed, 30 Nov 2016 20:10:57 +0800
Message-ID: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <caihe@huawei.com>, <wangyunjian@huawei.com>
To: <mst@redhat.com>, <jasowang@redhat.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33360 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbcK3MLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 07:11:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we meet an error(err=-EBADFD) recvmsg, the error handling in vhost
handle_rx() will continue. This will cause a soft CPU lockup in vhost thread.

Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
---
 drivers/vhost/net.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 5dc128a..edc470b 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -717,6 +717,9 @@ static void handle_rx(struct vhost_net *net)
 			pr_debug("Discarded rx packet: "
 				 " len %d, expected %zd\n", err, sock_len);
 			vhost_discard_vq_desc(vq, headcount);
+			/* Don't continue to do, when meet errors. */
+			if (err < 0)
+				goto out;
 			continue;
 		}
 		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
-- 
1.9.5.msysgit.1
