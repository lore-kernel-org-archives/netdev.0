From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 2/8] bpf: Introduce bpf_map ID
Date: Mon, 5 Jun 2017 12:15:47 -0700
Message-ID: <b059a34ab512533214321b5551ac8cd4eb87fe50.1496686606.git.kafai@fb.com>
References: <cover.1496686606.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41847 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751290AbdFETP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:15:58 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v55JFsVL024690
        for <netdev@vger.kernel.org>; Mon, 5 Jun 2017 12:15:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2awda2800y-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:15:57 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 667b087e4a2311e7a1000002c991e86a-1cc8e6b0 for <netdev@vger.kernel.org>;        Mon,
 05 Jun 2017 12:15:56 -0700
In-Reply-To: <cover.1496686606.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch generates an unique ID for each created bpf_map.
The approach is similar to the earlier patch for bpf_prog ID.

It is worth to note that the bpf_map's ID and bpf_prog's ID
are in two independent ID spaces and both have the same valid range:
[1, INT_MAX).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h  |  1 +
 kernel/bpf/syscall.c | 34 +++++++++++++++++++++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index c5946d19f2ca..c32bace66d3d 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -46,6 +46,7 @@ struct bpf_map {
 	u32 max_entries;
 	u32 map_flags;
 	u32 pages;
+	u32 id;
 	struct user_struct *user;
 	const struct bpf_map_ops *ops;
 	struct work_struct work;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 2a1b32b470f1..4c3075b5d840 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -27,6 +27,8 @@
 DEFINE_PER_CPU(int, bpf_prog_active);
 static DEFINE_IDR(prog_idr);
 static DEFINE_SPINLOCK(prog_idr_lock);
+static DEFINE_IDR(map_idr);
+static DEFINE_SPINLOCK(map_idr_lock);
 
 int sysctl_unprivileged_bpf_disabled __read_mostly;
 
@@ -117,6 +119,29 @@ static void bpf_map_uncharge_memlock(struct bpf_map *map)
 	free_uid(user);
 }
 
+static int bpf_map_alloc_id(struct bpf_map *map)
+{
+	int id;
+
+	spin_lock_bh(&map_idr_lock);
+	id = idr_alloc_cyclic(&map_idr, map, 1, INT_MAX, GFP_ATOMIC);
+	if (id > 0)
+		map->id = id;
+	spin_unlock_bh(&map_idr_lock);
+
+	if (WARN_ON_ONCE(!id))
+		return -ENOSPC;
+
+	return id > 0 ? 0 : id;
+}
+
+static void bpf_map_free_id(struct bpf_map *map)
+{
+	spin_lock_bh(&map_idr_lock);
+	idr_remove(&map_idr, map->id);
+	spin_unlock_bh(&map_idr_lock);
+}
+
 /* called from workqueue */
 static void bpf_map_free_deferred(struct work_struct *work)
 {
@@ -141,6 +166,7 @@ static void bpf_map_put_uref(struct bpf_map *map)
 void bpf_map_put(struct bpf_map *map)
 {
 	if (atomic_dec_and_test(&map->refcnt)) {
+		bpf_map_free_id(map);
 		INIT_WORK(&map->work, bpf_map_free_deferred);
 		schedule_work(&map->work);
 	}
@@ -239,14 +265,20 @@ static int map_create(union bpf_attr *attr)
 	if (err)
 		goto free_map_nouncharge;
 
+	err = bpf_map_alloc_id(map);
+	if (err)
+		goto free_map;
+
 	err = bpf_map_new_fd(map);
 	if (err < 0)
 		/* failed to allocate fd */
-		goto free_map;
+		goto free_id;
 
 	trace_bpf_map_create(map, err);
 	return err;
 
+free_id:
+	bpf_map_free_id(map);
 free_map:
 	bpf_map_uncharge_memlock(map);
 free_map_nouncharge:
-- 
2.9.3
