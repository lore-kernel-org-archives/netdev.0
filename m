From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3] iov_iter: don't revert iov buffer if csum error
Date: Wed, 3 May 2017 15:02:32 +0800
Message-ID: <12d4d81f-40c7-c83d-11d6-290acc084695@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, <pabeni@redhat.com>,
        <edumazet@google.com>, <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5852 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdECHEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 03:04:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 327868212381 (make skb_copy_datagram_msg() et.al. preserve
->msg_iter on error) will revert the iov buffer if copy to iter
failed, but it didn't copy any datagram if the skb_checksum_complete
error, so no need to revert any data at this place.

v2: Sabrina notice that return -EFAULT when checksum error is not correct
    here, it would confuse the caller about the return value, so fix it.

v3: According AI's suggestion, directly return -EINVAL when __skb_checksum_complete()
    return error is a more simple solution.

Fixes: 327868212381 ("make skb_copy_datagram_msg() et.al. preserve->msg_iter on error")
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/core/datagram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 0306543..726bf8a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -719,7 +719,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,

 	if (msg_data_left(msg) < chunk) {
 		if (__skb_checksum_complete(skb))
-			goto csum_error;
+			return -EINVAL;
 		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
 			goto fault;
 	} else {
-- 
1.8.3.1
