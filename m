From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 2/9] kasan: unify report headers
Date: Tue, 28 Mar 2017 16:00:43 +0200
Message-ID: <1e8bb4d01cf38337d7bbbd0d09bc6da01c60da42.1490383597.git.andreyknvl__37773.0513261215$1490709729$gmane$org@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34435 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752667AbdC1OBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:32 -0400
Received: by mail-lf0-f48.google.com with SMTP id z15so38921746lfd.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:25 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unify KASAN report header format for different kinds of bad memory
accesses. Makes the code simpler.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index e3af37b7a74c..fc0577d15671 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -119,16 +119,22 @@ static const char *get_wild_bug_type(struct kasan_access_info *info)
 	return bug_type;
 }
 
+static const char *get_bug_type(struct kasan_access_info *info)
+{
+	if (addr_has_shadow(info))
+		return get_shadow_bug_type(info);
+	return get_wild_bug_type(info);
+}
+
 static void print_error_description(struct kasan_access_info *info)
 {
-	const char *bug_type = get_shadow_bug_type(info);
+	const char *bug_type = get_bug_type(info);
 
 	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
-		bug_type, (void *)info->ip,
-		info->access_addr);
+		bug_type, (void *)info->ip, info->access_addr);
 	pr_err("%s of size %zu by task %s/%d\n",
-		info->is_write ? "Write" : "Read",
-		info->access_size, current->comm, task_pid_nr(current));
+		info->is_write ? "Write" : "Read", info->access_size,
+		current->comm, task_pid_nr(current));
 }
 
 static inline bool kernel_or_module_addr(const void *addr)
@@ -295,17 +301,11 @@ static void kasan_report_error(struct kasan_access_info *info)
 
 	kasan_start_report(&flags);
 
+	print_error_description(info);
+
 	if (!addr_has_shadow(info)) {
-		const char *bug_type = get_wild_bug_type(info);
-		pr_err("BUG: KASAN: %s on address %p\n",
-			bug_type, info->access_addr);
-		pr_err("%s of size %zu by task %s/%d\n",
-			info->is_write ? "Write" : "Read",
-			info->access_size, current->comm,
-			task_pid_nr(current));
 		dump_stack();
 	} else {
-		print_error_description(info);
 		print_address_description(info);
 		print_shadow_for_address(info->first_bad_addr);
 	}
-- 
2.12.1.578.ge9c3154ca4-goog
