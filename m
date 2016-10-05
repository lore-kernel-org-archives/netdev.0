From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netlink: do not enter direct reclaim from netlink_dump()
Date: Thu, 06 Oct 2016 04:13:18 +0900
Message-ID: <1475694798.28155.215.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Greg Thelen <gthelen@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33336 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753535AbcJETNY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 15:13:24 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so4452719pac.0
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 12:13:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since linux-3.15, netlink_dump() can use up to 16384 bytes skb
allocations.

Due to struct skb_shared_info ~320 bytes overhead, we end up using
order-3 (on x86) page allocations, that might trigger direct reclaim and
add stress.

The intent was really to attempt a large allocation but immediately
fallback to a smaller one (order-1 on x86) in case of memory stress.

On recent kernels (linux-4.4), we can remove __GFP_DIRECT_RECLAIM to
meet the goal. Old kernels would need to remove __GFP_WAIT

While we are at it, since we do an order-3 allocation, allow to use
all the allocated bytes instead of 16384 to reduce syscalls during
large dumps.

iproute2 already uses 32KB recvmsg() buffer sizes.

Alexei provided an initial patch downsizing to SKB_WITH_OVERHEAD(16384)

Fixes: 9063e21fb026 ("netlink: autosize skb lengthes")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Alexei Starovoitov <ast@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
---
Note: This will apply to net tree when it has synced with Linus tree.

 net/netlink/af_netlink.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 627f898c05b96552318a881ce995ccc3342e1576..62bea4591054820eb516ef016214ee23fe89b6e9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1832,7 +1832,7 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	/* Record the max length of recvmsg() calls for future allocations */
 	nlk->max_recvmsg_len = max(nlk->max_recvmsg_len, len);
 	nlk->max_recvmsg_len = min_t(size_t, nlk->max_recvmsg_len,
-				     16384);
+				     SKB_WITH_OVERHEAD(32768));
 
 	copied = data_skb->len;
 	if (len < copied) {
@@ -2083,8 +2083,9 @@ static int netlink_dump(struct sock *sk)
 
 	if (alloc_min_size < nlk->max_recvmsg_len) {
 		alloc_size = nlk->max_recvmsg_len;
-		skb = alloc_skb(alloc_size, GFP_KERNEL |
-					    __GFP_NOWARN | __GFP_NORETRY);
+		skb = alloc_skb(alloc_size,
+				(GFP_KERNEL & ~__GFP_DIRECT_RECLAIM) |
+				__GFP_NOWARN | __GFP_NORETRY);
 	}
 	if (!skb) {
 		alloc_size = alloc_min_size;
