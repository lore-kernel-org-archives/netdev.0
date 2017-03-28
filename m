From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 4/9] kasan: simplify address description logic
Date: Tue, 28 Mar 2017 16:00:47 +0200
Message-ID: <91b198a9825326a3f3e9037df60d49704f5479ad.1490383597.git.andreyknvl__13161.9124942974$1490709702$gmane$org@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34420 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752719AbdC1OBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:21 -0400
Received: by mail-lf0-f50.google.com with SMTP id z15so38921108lfd.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:14 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify logic for describing a memory address.
Add addr_to_page() helper function.

Makes the code easier to follow.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 382d4d2b9052..f77341979dae 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -188,11 +188,17 @@ static void print_track(struct kasan_track *track, const char *prefix)
 	}
 }
 
-static void kasan_object_err(struct kmem_cache *cache, void *object)
+static struct page *addr_to_page(const void *addr)
+{
+	if ((addr >= (void *)PAGE_OFFSET) && (addr < high_memory))
+		return virt_to_head_page(addr);
+	return NULL;
+}
+
+static void describe_object(struct kmem_cache *cache, void *object)
 {
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 
-	dump_stack();
 	pr_err("Object at %p, in cache %s size: %d\n", object, cache->name,
 		cache->object_size);
 
@@ -211,34 +217,32 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 	kasan_start_report(&flags);
 	pr_err("BUG: Double free or freeing an invalid pointer\n");
 	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
-	kasan_object_err(cache, object);
+	dump_stack();
+	describe_object(cache, object);
 	kasan_end_report(&flags);
 }
 
 static void print_address_description(struct kasan_access_info *info)
 {
 	const void *addr = info->access_addr;
+	struct page *page = addr_to_page(addr);
 
-	if ((addr >= (void *)PAGE_OFFSET) &&
-		(addr < high_memory)) {
-		struct page *page = virt_to_head_page(addr);
-
-		if (PageSlab(page)) {
-			void *object;
-			struct kmem_cache *cache = page->slab_cache;
-			object = nearest_obj(cache, page,
-						(void *)info->access_addr);
-			kasan_object_err(cache, object);
-			return;
-		}
+	if (page)
 		dump_page(page, "kasan: bad access detected");
+
+	dump_stack();
+
+	if (page && PageSlab(page)) {
+		struct kmem_cache *cache = page->slab_cache;
+		void *object = nearest_obj(cache, page,	(void *)addr);
+
+		describe_object(cache, object);
 	}
 
 	if (kernel_or_module_addr(addr)) {
 		if (!init_task_stack_addr(addr))
 			pr_err("Address belongs to variable %pS\n", addr);
 	}
-	dump_stack();
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
-- 
2.12.1.578.ge9c3154ca4-goog
