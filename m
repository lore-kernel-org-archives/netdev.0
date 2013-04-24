From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/4] net: avoid false perf interpretations in frag
	code
Date: Wed, 24 Apr 2013 17:48:43 +0200
Message-ID: <20130424154836.16883.79599.stgit@dragon>
References: <20130424154624.16883.40974.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17994 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641Ab3DXPsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 11:48:47 -0400
In-Reply-To: <20130424154624.16883.40974.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The compiler make us misinterpret performance issues in the frag code,
because its auto inlining functions.  Lets instead do explicit
inlining to make this situation obvious to the programmer.

The function inet_frag_find() get the perf blame, because auto
inlining of the functions inet_frag_create(), inet_frag_alloc() and
inet_frag_intern().

My solution is to explicit inline inet_frag_alloc() and
inet_frag_intern(), but explicitly "noinline" inet_frag_create(),
in-order to make it explicit to the performance engineer, that
creation phase is a bottleneck. Then, when reading the code the
programmer should notice the inline, and see the bottleneck is really
located in inet_frag_intern().

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/inet_fragment.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index cabe3d7..db30a01 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -240,7 +240,7 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 }
 EXPORT_SYMBOL(inet_frag_evictor);
 
-static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
+static inline struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
 		void *arg)
 {
@@ -288,7 +288,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 	return qp;
 }
 
-static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
+static inline struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 		struct inet_frags *f, void *arg)
 {
 	struct inet_frag_queue *q;
@@ -308,7 +308,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 	return q;
 }
 
-static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
+static noinline struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 		struct inet_frags *f, void *arg)
 {
 	struct inet_frag_queue *q;
