From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 2/5] bpf: Refactor codes handling percpu map
Date: Sat, 1 Oct 2016 20:58:30 -0700
Message-ID: <1475380713-4106095-2-git-send-email-kafai@fb.com>
References: <1475380713-4106095-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: FB Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43461 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751294AbcJBD6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 23:58:36 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u923soNo011576
        for <netdev@vger.kernel.org>; Sat, 1 Oct 2016 20:58:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25tau5axe1-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 20:58:36 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 7d686798885411e6bf970002c992ebde-355fca50 for <netdev@vger.kernel.org>;        Sat,
 01 Oct 2016 20:58:34 -0700
In-Reply-To: <1475380713-4106095-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor the codes that populate the value
of a htab_elem in a BPF_MAP_TYPE_PERCPU_HASH
typed bpf_map.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/hashtab.c | 47 +++++++++++++++++++++--------------------------
 1 file changed, 21 insertions(+), 26 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 570eeca..a5e3915 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -420,6 +420,24 @@ static void free_htab_elem(struct bpf_htab *htab, struct htab_elem *l)
 	}
 }
 
+static void pcpu_copy_value(struct bpf_htab *htab, void __percpu *pptr,
+			    void *value, bool onallcpus)
+{
+	if (!onallcpus) {
+		/* copy true value_size bytes */
+		memcpy(this_cpu_ptr(pptr), value, htab->map.value_size);
+	} else {
+		u32 size = round_up(htab->map.value_size, 8);
+		int off = 0, cpu;
+
+		for_each_possible_cpu(cpu) {
+			bpf_long_memcpy(per_cpu_ptr(pptr, cpu),
+					value + off, size);
+			off += size;
+		}
+	}
+}
+
 static struct htab_elem *alloc_htab_elem(struct bpf_htab *htab, void *key,
 					 void *value, u32 key_size, u32 hash,
 					 bool percpu, bool onallcpus,
@@ -479,18 +497,8 @@ static struct htab_elem *alloc_htab_elem(struct bpf_htab *htab, void *key,
 			}
 		}
 
-		if (!onallcpus) {
-			/* copy true value_size bytes */
-			memcpy(this_cpu_ptr(pptr), value, htab->map.value_size);
-		} else {
-			int off = 0, cpu;
+		pcpu_copy_value(htab, pptr, value, onallcpus);
 
-			for_each_possible_cpu(cpu) {
-				bpf_long_memcpy(per_cpu_ptr(pptr, cpu),
-						value + off, size);
-				off += size;
-			}
-		}
 		if (!prealloc)
 			htab_elem_set_ptr(l_new, key_size, pptr);
 	} else {
@@ -606,22 +614,9 @@ static int __htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 		goto err;
 
 	if (l_old) {
-		void __percpu *pptr = htab_elem_get_ptr(l_old, key_size);
-		u32 size = htab->map.value_size;
-
 		/* per-cpu hash map can update value in-place */
-		if (!onallcpus) {
-			memcpy(this_cpu_ptr(pptr), value, size);
-		} else {
-			int off = 0, cpu;
-
-			size = round_up(size, 8);
-			for_each_possible_cpu(cpu) {
-				bpf_long_memcpy(per_cpu_ptr(pptr, cpu),
-						value + off, size);
-				off += size;
-			}
-		}
+		pcpu_copy_value(htab, htab_elem_get_ptr(l_old, key_size),
+				value, onallcpus);
 	} else {
 		l_new = alloc_htab_elem(htab, key, value, key_size,
 					hash, true, onallcpus, false);
-- 
2.5.1
