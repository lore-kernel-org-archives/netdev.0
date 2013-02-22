From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix possible deadlock in sum_frag_mem_limit
Date: Fri, 22 Feb 2013 09:43:35 -0800
Message-ID: <1361555015.3683.14.camel@edumazet-glaptop>
References: <20130222171343.GB27619@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:59943 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758183Ab3BVRni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 12:43:38 -0500
In-Reply-To: <20130222171343.GB27619@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dave Jones reported a lockdep splat occurring in IP defrag code.

commit 6d7b857d541ecd1d (net: use lib/percpu_counter API for
fragmentation mem accounting) added a possible deadlock.

Because percpu_counter_sum_positive() needs to acquire
a lock that can be used from softirq, we need to disable BH
in sum_frag_mem_limit()

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/net/inet_frag.h |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 3f237db..76c3fe5 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -114,7 +114,13 @@ static inline void init_frag_mem_limit(struct netns_frags *nf)
 
 static inline int sum_frag_mem_limit(struct netns_frags *nf)
 {
-	return percpu_counter_sum_positive(&nf->mem);
+	int res;
+
+	local_bh_disable();
+	res = percpu_counter_sum_positive(&nf->mem);
+	local_bh_enable();
+
+	return res;
 }
 
 static inline void inet_frag_lru_move(struct inet_frag_queue *q)
