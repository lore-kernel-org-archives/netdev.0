From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix potential memory corruption
Date: Wed, 02 Nov 2016 07:53:17 -0700
Message-ID: <1478098397.7065.370.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
        =?ISO-8859-1?Q?H=E5kon?= Bugge <haakon.bugge@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34086 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752978AbcKBOxT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 10:53:19 -0400
Received: by mail-pf0-f195.google.com with SMTP id y68so1995969pfb.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 07:53:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Imagine initial value of max_skb_frags is 17, and last
skb in write queue has 15 frags.

Then max_skb_frags is lowered to 14 or smaller value.

tcp_sendmsg() will then be allowed to add additional page frags
and eventually go past MAX_SKB_FRAGS, overflowing struct
skb_shared_info.

Fixes: 5f74f82ea34c ("net:Add sysctl_max_skb_frags")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Cc: Håkon Bugge <haakon.bugge@oracle.com>
---
 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3251fe71f39f..18238ef8135a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1241,7 +1241,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 			if (!skb_can_coalesce(skb, i, pfrag->page,
 					      pfrag->offset)) {
-				if (i == sysctl_max_skb_frags || !sg) {
+				if (i >= sysctl_max_skb_frags || !sg) {
 					tcp_mark_push(tp, skb);
 					goto new_segment;
 				}
