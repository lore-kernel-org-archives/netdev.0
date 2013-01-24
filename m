From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/6] net: cacheline adjust struct netns_frags for
	better frag performance
Date: Thu, 24 Jan 2013 15:04:12 +0100
Message-ID: <20130124140405.14119.49967.stgit@dragon>
References: <20130124140343.14119.77712.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753008Ab3AXOFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 09:05:08 -0500
In-Reply-To: <20130124140343.14119.77712.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small cacheline adjustment of struct netns_frags improves
performance significantly for the fragmentation code.

Struct members 'lru_list' and 'mem' are both hot elements, and it
hurts performance, due to cacheline bouncing at every call point,
when they share a cacheline.  Also notice, how mem is placed
together with 'high_thresh' and 'low_thresh', as they are used in
the compare operations together.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 32786a0..91e7797 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -3,9 +3,12 @@
 
 struct netns_frags {
 	int			nqueues;
-	atomic_t		mem;
 	struct list_head	lru_list;
 
+	/* Its important for performance to keep lru_list and mem on
+	 * separate cachelines
+	 */
+	atomic_t		mem ____cacheline_aligned_in_smp;
 	/* sysctls */
 	int			timeout;
 	int			high_thresh;
