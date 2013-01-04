From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: xt_recent: avoid high order page allocations
Date: Fri, 04 Jan 2013 00:18:39 -0800
Message-ID: <1357287519.1678.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Miroslav Kratochvil <exa.exa@gmail.com>,
	h.reindl@thelounge.net, Dave Jones <davej@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

xt_recent can try high order page allocations and this can fail.

iptables: page allocation failure: order:9, mode:0xc0d0

It also wastes about half the allocated space because of kmalloc()
power-of-two roundups and struct recent_table layout.

Use vmalloc() instead to save space and be less prone to allocation
errors when memory is fragmented.

Reported-by: Miroslav Kratochvil <exa.exa@gmail.com>
Reported-by: Dave Jones <davej@redhat.com>
Reported-by: Harald Reindl <h.reindl@thelounge.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/xt_recent.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index dab053e..978efc9 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -29,6 +29,7 @@
 #include <linux/skbuff.h>
 #include <linux/inet.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -310,6 +311,14 @@ out:
 	return ret;
 }
 
+static void recent_table_free(void *addr)
+{
+	if (is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
+
 static int recent_mt_check(const struct xt_mtchk_param *par,
 			   const struct xt_recent_mtinfo_v1 *info)
 {
@@ -322,6 +331,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 #endif
 	unsigned int i;
 	int ret = -EINVAL;
+	size_t sz;
 
 	if (unlikely(!hash_rnd_inited)) {
 		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
@@ -360,8 +370,11 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 		goto out;
 	}
 
-	t = kzalloc(sizeof(*t) + sizeof(t->iphash[0]) * ip_list_hash_size,
-		    GFP_KERNEL);
+	sz = sizeof(*t) + sizeof(t->iphash[0]) * ip_list_hash_size;
+	if (sz <= PAGE_SIZE)
+		t = kzalloc(sz, GFP_KERNEL);
+	else
+		t = vzalloc(sz);
 	if (t == NULL) {
 		ret = -ENOMEM;
 		goto out;
@@ -377,14 +390,14 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	uid = make_kuid(&init_user_ns, ip_list_uid);
 	gid = make_kgid(&init_user_ns, ip_list_gid);
 	if (!uid_valid(uid) || !gid_valid(gid)) {
-		kfree(t);
+		recent_table_free(t);
 		ret = -EINVAL;
 		goto out;
 	}
 	pde = proc_create_data(t->name, ip_list_perms, recent_net->xt_recent,
 		  &recent_mt_fops, t);
 	if (pde == NULL) {
-		kfree(t);
+		recent_table_free(t);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -435,7 +448,7 @@ static void recent_mt_destroy(const struct xt_mtdtor_param *par)
 			remove_proc_entry(t->name, recent_net->xt_recent);
 #endif
 		recent_table_flush(t);
-		kfree(t);
+		recent_table_free(t);
 	}
 	mutex_unlock(&recent_mutex);
 }


