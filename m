From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 1/2] bpf: fix struct htab_elem layout
Date: Tue, 7 Mar 2017 20:00:12 -0800
Message-ID: <1488945613-1857856-2-git-send-email-ast@fb.com>
References: <1488945613-1857856-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51295 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752908AbdCHEAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 23:00:16 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v283xg3d011216
        for <netdev@vger.kernel.org>; Tue, 7 Mar 2017 20:00:14 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2928260cf3-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 20:00:14 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 bbc306f803b311e7bbf90002c9931860-b45f09a0 for <netdev@vger.kernel.org>;        Tue,
 07 Mar 2017 20:00:14 -0800
In-Reply-To: <1488945613-1857856-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when htab_elem is removed from the bucket list the htab_elem.hash_node.next
field should not be overridden too early otherwise we have a tiny race window
between lookup and delete.
The bug was discovered by manual code analysis and reproducible
only with explicit udelay() in lookup_elem_raw().

Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
Reported-by: Jonathan Perry <jonperry@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/hashtab.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 3ea87fb19a94..63c86a7be2a1 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -45,8 +45,13 @@ enum extra_elem_state {
 struct htab_elem {
 	union {
 		struct hlist_node hash_node;
-		struct bpf_htab *htab;
-		struct pcpu_freelist_node fnode;
+		struct {
+			void *padding;
+			union {
+				struct bpf_htab *htab;
+				struct pcpu_freelist_node fnode;
+			};
+		};
 	};
 	union {
 		struct rcu_head rcu;
@@ -162,7 +167,8 @@ static int prealloc_init(struct bpf_htab *htab)
 				 offsetof(struct htab_elem, lru_node),
 				 htab->elem_size, htab->map.max_entries);
 	else
-		pcpu_freelist_populate(&htab->freelist, htab->elems,
+		pcpu_freelist_populate(&htab->freelist,
+				       htab->elems + offsetof(struct htab_elem, fnode),
 				       htab->elem_size, htab->map.max_entries);
 
 	return 0;
@@ -217,6 +223,11 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	int err, i;
 	u64 cost;
 
+	BUILD_BUG_ON(offsetof(struct htab_elem, htab) !=
+		     offsetof(struct htab_elem, hash_node.pprev));
+	BUILD_BUG_ON(offsetof(struct htab_elem, fnode.next) !=
+		     offsetof(struct htab_elem, hash_node.pprev));
+
 	if (lru && !capable(CAP_SYS_ADMIN))
 		/* LRU implementation is much complicated than other
 		 * maps.  Hence, limit to CAP_SYS_ADMIN for now.
@@ -582,9 +593,13 @@ static struct htab_elem *alloc_htab_elem(struct bpf_htab *htab, void *key,
 	int err = 0;
 
 	if (prealloc) {
-		l_new = (struct htab_elem *)pcpu_freelist_pop(&htab->freelist);
-		if (!l_new)
+		struct pcpu_freelist_node *l;
+
+		l = pcpu_freelist_pop(&htab->freelist);
+		if (!l)
 			err = -E2BIG;
+		else
+			l_new = container_of(l, struct htab_elem, fnode);
 	} else {
 		if (atomic_inc_return(&htab->count) > htab->map.max_entries) {
 			atomic_dec(&htab->count);
-- 
2.8.0
