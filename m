From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] tipc: fix the error handling in tipc_udp_enable()
Date: Wed, 24 Aug 2016 13:32:19 +0000
Message-ID: <1472045539-19923-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35795 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932467AbcHXNcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 09:32:47 -0400
Received: by mail-pa0-f65.google.com with SMTP id cf3so1217265pad.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 06:32:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return a negative error code in enable_mcast() error handling
case, and release udp socket when necessary.

Fixes: d0f91938bede ("tipc: add ip/udp media type")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/tipc/udp_media.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 33bdf54..453ab0b 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -396,10 +396,13 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
 	tuncfg.encap_destroy = NULL;
 	setup_udp_tunnel_sock(net, ub->ubsock, &tuncfg);
 
-	if (enable_mcast(ub, remote))
+	err = enable_mcast(ub, remote);
+	if (err)
 		goto err;
 	return 0;
 err:
+	if (ub->ubsock)
+		udp_tunnel_sock_release(ub->ubsock);
 	kfree(ub);
 	return err;
 }
