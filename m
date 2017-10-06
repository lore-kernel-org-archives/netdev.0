From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 10/16] ipv6: don't release rt->rt6i_pcpu memory during rt6_release()
Date: Fri,  6 Oct 2017 12:06:05 -0700
Message-ID: <20171006190611.110633-11-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
 <20171006190611.110633-6-tracywwnj@gmail.com>
 <20171006190611.110633-7-tracywwnj@gmail.com>
 <20171006190611.110633-8-tracywwnj@gmail.com>
 <20171006190611.110633-9-tracywwnj@gmail.com>
 <20171006190611.110633-10-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:47314 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752716AbdJFTGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:49 -0400
Received: by mail-pg0-f42.google.com with SMTP id r25so7997021pgn.4
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:49 -0700 (PDT)
In-Reply-To: <20171006190611.110633-10-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

After rwlock is replaced with rcu and spinlock, route lookup can happen
simultanously with route deletion.
This patch removes the call to free_percpu(rt->rt6i_pcpu) from
rt6_release() to avoid the race condition between rt6_release() and
rt6_get_pcpu_route(). And as free_percpu(rt->rt6i_pcpu) is already
called in ip6_dst_destroy() after the rcu grace period, it is safe to do
this change.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_fib.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 9c8e704e6af7..eee392f7b1f6 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -190,9 +190,6 @@ void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 			*ppcpu_rt = NULL;
 		}
 	}
-
-	free_percpu(non_pcpu_rt->rt6i_pcpu);
-	non_pcpu_rt->rt6i_pcpu = NULL;
 }
 EXPORT_SYMBOL_GPL(rt6_free_pcpu);
 
-- 
2.14.2.920.gcf0c67979c-goog
