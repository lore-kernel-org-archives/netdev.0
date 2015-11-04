From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 3/8] mm: page_counter: let page_counter_try_charge() return bool
Date: Wed,  4 Nov 2015 17:22:09 -0500
Message-ID: <1446675734-25671-4-git-send-email-hannes@cmpxchg.org>
References: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446675734-25671-1-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

page_counter_try_charge() currently returns 0 on success and -ENOMEM
on failure, which is surprising behavior given the function name.

Make it follow the expected pattern of try_stuff() functions that
return a boolean true to indicate success, or false for failure.

Signed-off-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Acked-by: Michal Hocko <mhocko-IBi9RG/b67k@public.gmane.org>
---
 include/linux/page_counter.h |  6 +++---
 mm/hugetlb_cgroup.c          |  3 ++-
 mm/memcontrol.c              | 11 +++++------
 mm/page_counter.c            | 14 +++++++-------
 4 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index 17fa4f8..7e62920 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -36,9 +36,9 @@ static inline unsigned long page_counter_read(struct page_counter *counter)
 
 void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
-int page_counter_try_charge(struct page_counter *counter,
-			    unsigned long nr_pages,
-			    struct page_counter **fail);
+bool page_counter_try_charge(struct page_counter *counter,
+			     unsigned long nr_pages,
+			     struct page_counter **fail);
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_limit(struct page_counter *counter, unsigned long limit);
 int page_counter_memparse(const char *buf, const char *max,
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 6a44263..d8fb10d 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -186,7 +186,8 @@ again:
 	}
 	rcu_read_unlock();
 
-	ret = page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter);
+	if (!page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter))
+		ret = -ENOMEM;
 	css_put(&h_cg->css);
 done:
 	*ptr = h_cg;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7049e55..e54f434 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2018,8 +2018,8 @@ retry:
 		return 0;
 
 	if (!do_swap_account ||
-	    !page_counter_try_charge(&memcg->memsw, batch, &counter)) {
-		if (!page_counter_try_charge(&memcg->memory, batch, &counter))
+	    page_counter_try_charge(&memcg->memsw, batch, &counter)) {
+		if (page_counter_try_charge(&memcg->memory, batch, &counter))
 			goto done_restock;
 		if (do_swap_account)
 			page_counter_uncharge(&memcg->memsw, batch);
@@ -2383,14 +2383,13 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 {
 	unsigned int nr_pages = 1 << order;
 	struct page_counter *counter;
-	int ret = 0;
+	int ret;
 
 	if (!memcg_kmem_is_active(memcg))
 		return 0;
 
-	ret = page_counter_try_charge(&memcg->kmem, nr_pages, &counter);
-	if (ret)
-		return ret;
+	if (!page_counter_try_charge(&memcg->kmem, nr_pages, &counter))
+		return -ENOMEM;
 
 	ret = try_charge(memcg, gfp, nr_pages);
 	if (ret) {
diff --git a/mm/page_counter.c b/mm/page_counter.c
index 11b4bed..7c6a63d 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -56,12 +56,12 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
  * @nr_pages: number of pages to charge
  * @fail: points first counter to hit its limit, if any
  *
- * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
- * its ancestors has hit its configured limit.
+ * Returns %true on success, or %false and @fail if the counter or one
+ * of its ancestors has hit its configured limit.
  */
-int page_counter_try_charge(struct page_counter *counter,
-			    unsigned long nr_pages,
-			    struct page_counter **fail)
+bool page_counter_try_charge(struct page_counter *counter,
+			     unsigned long nr_pages,
+			     struct page_counter **fail)
 {
 	struct page_counter *c;
 
@@ -99,13 +99,13 @@ int page_counter_try_charge(struct page_counter *counter,
 		if (new > c->watermark)
 			c->watermark = new;
 	}
-	return 0;
+	return true;
 
 failed:
 	for (c = counter; c != *fail; c = c->parent)
 		page_counter_cancel(c, nr_pages);
 
-	return -ENOMEM;
+	return false;
 }
 
 /**
-- 
2.6.2
