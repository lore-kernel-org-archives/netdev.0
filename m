From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 7/8] inet fragments: fix sparse warning: context imbalance
Date: Wed, 25 Feb 2009 21:32:52 +0100
Message-ID: <20090225203247.6251.30496.stgit@vmbox.hanneseder.net>
References: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760498AbZBYUd0@vger.kernel.org>
In-Reply-To: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: Attribute function with __releases(...)

Fix this sparse warning:
  net/ipv4/inet_fragment.c:276:35: warning: context imbalance in 'inet_frag_find' - unexpected unlock

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 include/net/inet_frag.h  |    3 ++-
 net/ipv4/inet_fragment.c |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index e081eef..39f2dc9 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -61,7 +61,8 @@ void inet_frag_destroy(struct inet_frag_queue *q,
 				struct inet_frags *f, int *work);
 int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
-		struct inet_frags *f, void *key, unsigned int hash);
+		struct inet_frags *f, void *key, unsigned int hash)
+	__releases(&f->lock);
 
 static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
 {
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 6c52e08..eaf3e2c 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -267,6 +267,7 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
+	__releases(&f->lock)
 {
 	struct inet_frag_queue *q;
 	struct hlist_node *n;
