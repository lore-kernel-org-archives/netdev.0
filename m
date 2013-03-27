From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/3] net: frag,
	avoid several CPUs grabbing same frag queue during LRU evictor loop
Date: Wed, 27 Mar 2013 16:55:25 +0100
Message-ID: <20130327155457.15203.69656.stgit@dragon>
References: <20130327155238.15203.6688.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348Ab3C0Pzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 11:55:33 -0400
In-Reply-To: <20130327155238.15203.6688.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LRU list is protected by its own lock, since commit 3ef0eb0db4
(net: frag, move LRU list maintenance outside of rwlock), and
no-longer by a read_lock.

This makes it possible, to remove the inet_frag_queue, which is about
to be "evicted", from the LRU list head.  This avoids the problem, of
several CPUs grabbing the same frag queue.

Note, cannot remove the inet_frag_lru_del() call in fq_unlink()
called by inet_frag_kill(), because inet_frag_kill() is also used in
other situations.  Thus, we use list_del_init() to allow this
double list_del to work.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/inet_fragment.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 2bff045..8ba548a 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -204,6 +204,9 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 		q = list_first_entry(&nf->lru_list,
 				struct inet_frag_queue, lru_list);
 		atomic_inc(&q->refcnt);
+		/* Remove q from list to avoid several CPUs grabbing it */
+		list_del_init(&q->lru_list);
+
 		spin_unlock(&nf->lru_lock);
 
 		spin_lock(&q->lock);
