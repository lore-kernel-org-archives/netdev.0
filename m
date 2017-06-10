From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] net: caif: Fix a sleep-in-atomic bug in cfpkt_create_pfx
Date: Sat, 10 Jun 2017 16:49:39 +0800
Message-ID: <1497084579-32434-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: dmitry.tarnyagin@lockless.no, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:54490 "EHLO m12-17.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751893AbdFJIrM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 04:47:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel may sleep under a rcu read lock in cfpkt_create_pfx, and the
function call path is:
cfcnfg_linkup_rsp (acquire the lock by rcu_read_lock)
  cfctrl_linkdown_req
    cfpkt_create
      cfpkt_create_pfx
        alloc_skb(GFP_KERNEL) --> may sleep
cfserl_receive (acquire the lock by rcu_read_lock)
  cfpkt_split
    cfpkt_create_pfx
      alloc_skb(GFP_KERNEL) --> may sleep

There is "in_interrupt" in cfpkt_create_pfx to decide use "GFP_KERNEL" or
"GFP_ATOMIC". In this situation, "GFP_KERNEL" is used because the function 
is called under a rcu read lock, instead in interrupt.

To fix it, only "GFP_ATOMIC" is used in cfpkt_create_pfx.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 net/caif/cfpkt_skbuff.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 59ce1fc..71b6ab2 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -81,11 +81,7 @@ static struct cfpkt *cfpkt_create_pfx(u16 len, u16 pfx)
 {
 	struct sk_buff *skb;
 
-	if (likely(in_interrupt()))
-		skb = alloc_skb(len + pfx, GFP_ATOMIC);
-	else
-		skb = alloc_skb(len + pfx, GFP_KERNEL);
-
+	skb = alloc_skb(len + pfx, GFP_ATOMIC);
 	if (unlikely(skb == NULL))
 		return NULL;
 
-- 
1.7.9.5
