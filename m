From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: fix a race in nf_ct_ext_create()
Date: Tue, 31 Aug 2010 17:48:02 +0200
Message-ID: <1283269682.2550.111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As soon as rcu_read_unlock() is called, there is no guarantee current
thread can safely derefence t pointer, rcu protected.

Fix is to copy t->alloc_size in a temporary variable.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/nf_conntrack_extend.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 7dcf7a4..8d9e4c9 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -48,15 +48,17 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 {
 	unsigned int off, len;
 	struct nf_ct_ext_type *t;
+	size_t alloc_size;
 
 	rcu_read_lock();
 	t = rcu_dereference(nf_ct_ext_types[id]);
 	BUG_ON(t == NULL);
 	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
 	len = off + t->len;
+	alloc_size = t->alloc_size;
 	rcu_read_unlock();
 
-	*ext = kzalloc(t->alloc_size, gfp);
+	*ext = kzalloc(alloc_size, gfp);
 	if (!*ext)
 		return NULL;
 


