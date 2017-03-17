From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 18/18] net, netrom: convert nr_node.refcount from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 13:12:59 +0200
Message-ID: <1489749179-12063-19-git-send-email-elena.reshetova@intel.com>
References: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        marcel@holtmann.org, johan.hedberg@gmail.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/netrom.h  | 6 +++---
 net/netrom/nr_route.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/netrom.h b/include/net/netrom.h
index cecb4fd..443a4ff 100644
--- a/include/net/netrom.h
+++ b/include/net/netrom.h
@@ -110,7 +110,7 @@ struct nr_node {
 	unsigned char		which;
 	unsigned char		count;
 	struct nr_route		routes[3];
-	atomic_t		refcount;
+	refcount_t		refcount;
 	spinlock_t		node_lock;
 };
 
@@ -119,11 +119,11 @@ struct nr_node {
  *********************************************************************/
 
 #define nr_node_hold(__nr_node) \
-	atomic_inc(&((__nr_node)->refcount))
+	refcount_inc(&((__nr_node)->refcount))
 
 static __inline__ void nr_node_put(struct nr_node *nr_node)
 {
-	if (atomic_dec_and_test(&nr_node->refcount)) {
+	if (refcount_dec_and_test(&nr_node->refcount)) {
 		kfree(nr_node);
 	}
 }
diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index 6b72970..0c59354 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -184,7 +184,7 @@ static int __must_check nr_add_node(ax25_address *nr, const char *mnemonic,
 
 		nr_node->which = 0;
 		nr_node->count = 1;
-		atomic_set(&nr_node->refcount, 1);
+		refcount_set(&nr_node->refcount, 1);
 		spin_lock_init(&nr_node->node_lock);
 
 		nr_node->routes[0].quality   = quality;
-- 
2.7.4
