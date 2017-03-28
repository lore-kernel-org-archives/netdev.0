From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 6/9] kasan: improve slab object description
Date: Tue, 28 Mar 2017 16:00:51 +0200
Message-ID: <5ee51ce71c19e681d1e9bf10fb7632729bedd202.1490383597.git.andreyknvl__12980.4614153274$1490709736$gmane$org@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:36069 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753755AbdC1OBg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:36 -0400
Received: by mail-wr0-f169.google.com with SMTP id w11so88290351wrc.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:29 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes slab object description from:

Object at ffff880068388540, in cache kmalloc-128 size: 128

to:

Object at ffff88006a2d5a80 belongs to cache kmalloc-128 of size 128
 accessed at offset 123

This adds information about relative offset of the accessed address to
the start of the object.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 156f998199e2..06e27a342d1d 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -194,18 +194,34 @@ static struct page *addr_to_page(const void *addr)
 	return NULL;
 }
 
-static void describe_object(struct kmem_cache *cache, void *object)
+static void describe_object_addr(struct kmem_cache *cache, void *object,
+				const void *addr)
 {
-	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+	unsigned long access_addr = (unsigned long)addr;
+	unsigned long object_addr = (unsigned long)object;
+	const char *rel_type;
+	int rel_bytes;
 
-	pr_err("Object at %p, in cache %s size: %d\n", object, cache->name,
-		cache->object_size);
+	pr_err("Object at %p belongs to cache %s of size %d\n",
+		object, cache->name, cache->object_size);
 
-	if (!(cache->flags & SLAB_KASAN))
+	if (!addr)
 		return;
 
-	print_track(&alloc_info->alloc_track, "Allocated");
-	print_track(&alloc_info->free_track, "Freed");
+	pr_err(" accessed at offset %d\n", access_addr - object_addr);
+}
+
+static void describe_object(struct kmem_cache *cache, void *object,
+				const void *addr)
+{
+	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+
+	if (cache->flags & SLAB_KASAN) {
+		print_track(&alloc_info->alloc_track, "Allocated");
+		print_track(&alloc_info->free_track, "Freed");
+	}
+
+	describe_object_addr(cache, object, addr);
 }
 
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
@@ -217,13 +233,13 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 	pr_err("BUG: Double free or freeing an invalid pointer\n");
 	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
 	dump_stack();
-	describe_object(cache, object);
+	describe_object(cache, object, NULL);
 	kasan_end_report(&flags);
 }
 
 static void print_address_description(struct kasan_access_info *info)
 {
-	const void *addr = info->access_addr;
+	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
 	if (page)
@@ -233,9 +249,9 @@ static void print_address_description(struct kasan_access_info *info)
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
-		void *object = nearest_obj(cache, page,	(void *)addr);
+		void *object = nearest_obj(cache, page,	addr);
 
-		describe_object(cache, object);
+		describe_object(cache, object, addr);
 	}
 
 	if (kernel_or_module_addr(addr)) {
-- 
2.12.1.578.ge9c3154ca4-goog
