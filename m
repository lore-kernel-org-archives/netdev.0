From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v2] iov_iter: don't revert iov buffer if csum error
Date: Sat, 29 Apr 2017 10:38:48 +0800
Message-ID: <d1ef9185-0956-aed9-e44b-84458cf28764@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, <pabeni@redhat.com>,
        <edumazet@google.com>, <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:5901 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1164198AbdD2CjX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 22:39:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 327868212381 (make skb_copy_datagram_msg() et.al. preserve
->msg_iter on error) will revert the iov buffer if copy to iter
failed, but it didn't copy any datagram if the skb_checksum_complete
error, so no need to revert any data at this place.

v2: Sabrina notice that return -EFAULT when checksum error is not correct
    here, it would confuse the caller about the return value, so fix it.

Fixes: 327868212381 ("make skb_copy_datagram_msg() et.al. preserve->msg_iter on error")
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/core/datagram.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index f4947e7..0e6a9a9 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -768,14 +768,17 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 		if (skb_copy_and_csum_datagram(skb, hlen, &msg->msg_iter,
 					       chunk, &csum))
 			goto fault;
-		if (csum_fold(csum))
+
+		if (csum_fold(csum)) {
+			iov_iter_revert(&msg->msg_iter, chunk);
 			goto csum_error;
+		}
+
 		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
 	}
 	return 0;
 csum_error:
-	iov_iter_revert(&msg->msg_iter, chunk);
 	return -EINVAL;
 fault:
 	return -EFAULT;
-- 
1.8.3.1
