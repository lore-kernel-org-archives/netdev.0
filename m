From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 5/8] bpf: Add BPF_MAP_GET_FD_BY_ID
Date: Mon, 5 Jun 2017 12:15:50 -0700
Message-ID: <643c335d0dca1d0c2b657722f8c405231cfce756.1496686606.git.kafai@fb.com>
References: <cover.1496686606.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58027 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751291AbdFETP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:15:58 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v55JFllt023581
        for <netdev@vger.kernel.org>; Mon, 5 Jun 2017 12:15:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2awc0s08sx-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:15:57 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 66cd33b04a2311e789ee0002c9521c9e-1b3f8f0 for <netdev@vger.kernel.org>; Mon,
 05 Jun 2017 12:15:56 -0700
In-Reply-To: <cover.1496686606.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add BPF_MAP_GET_FD_BY_ID command to allow user to get a fd
from a bpf_map's ID.

bpf_map_inc_not_zero() is added and is called with map_idr_lock
held.

__bpf_map_put() is also added which has the 'bool do_idr_lock'
param to decide if the map_idr_lock should be acquired when
freeing the map->id.

In the error path of bpf_map_inc_not_zero(), it may have to
call __bpf_map_put(map, false) which does not need
to take the map_idr_lock when freeing the map->id.

It is currently limited to CAP_SYS_ADMIN which we can
consider to lift it in followup patches.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h |  2 +
 kernel/bpf/syscall.c     | 95 +++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 87 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d70cfed19d5e..dd23f47ff00c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -85,6 +85,7 @@ enum bpf_cmd {
 	BPF_PROG_GET_NEXT_ID,
 	BPF_MAP_GET_NEXT_ID,
 	BPF_PROG_GET_FD_BY_ID,
+	BPF_MAP_GET_FD_BY_ID,
 };
 
 enum bpf_map_type {
@@ -217,6 +218,7 @@ union bpf_attr {
 		union {
 			__u32		start_id;
 			__u32		prog_id;
+			__u32		map_id;
 		};
 		__u32		next_id;
 	};
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index dc6253bb8ebb..1802bb9c47d9 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -135,11 +135,19 @@ static int bpf_map_alloc_id(struct bpf_map *map)
 	return id > 0 ? 0 : id;
 }
 
-static void bpf_map_free_id(struct bpf_map *map)
+static void bpf_map_free_id(struct bpf_map *map, bool do_idr_lock)
 {
-	spin_lock_bh(&map_idr_lock);
+	if (do_idr_lock)
+		spin_lock_bh(&map_idr_lock);
+	else
+		__acquire(&map_idr_lock);
+
 	idr_remove(&map_idr, map->id);
-	spin_unlock_bh(&map_idr_lock);
+
+	if (do_idr_lock)
+		spin_unlock_bh(&map_idr_lock);
+	else
+		__release(&map_idr_lock);
 }
 
 /* called from workqueue */
@@ -163,16 +171,21 @@ static void bpf_map_put_uref(struct bpf_map *map)
 /* decrement map refcnt and schedule it for freeing via workqueue
  * (unrelying map implementation ops->map_free() might sleep)
  */
-void bpf_map_put(struct bpf_map *map)
+static void __bpf_map_put(struct bpf_map *map, bool do_idr_lock)
 {
 	if (atomic_dec_and_test(&map->refcnt)) {
 		/* bpf_map_free_id() must be called first */
-		bpf_map_free_id(map);
+		bpf_map_free_id(map, do_idr_lock);
 		INIT_WORK(&map->work, bpf_map_free_deferred);
 		schedule_work(&map->work);
 	}
 }
 
+void bpf_map_put(struct bpf_map *map)
+{
+	__bpf_map_put(map, true);
+}
+
 void bpf_map_put_with_uref(struct bpf_map *map)
 {
 	bpf_map_put_uref(map);
@@ -271,15 +284,20 @@ static int map_create(union bpf_attr *attr)
 		goto free_map;
 
 	err = bpf_map_new_fd(map);
-	if (err < 0)
-		/* failed to allocate fd */
-		goto free_id;
+	if (err < 0) {
+		/* failed to allocate fd.
+		 * bpf_map_put() is needed because the above
+		 * bpf_map_alloc_id() has published the map
+		 * to the userspace and the userspace may
+		 * have refcnt-ed it through BPF_MAP_GET_FD_BY_ID.
+		 */
+		bpf_map_put(map);
+		return err;
+	}
 
 	trace_bpf_map_create(map, err);
 	return err;
 
-free_id:
-	bpf_map_free_id(map);
 free_map:
 	bpf_map_uncharge_memlock(map);
 free_map_nouncharge:
@@ -331,6 +349,28 @@ struct bpf_map *bpf_map_get_with_uref(u32 ufd)
 	return map;
 }
 
+/* map_idr_lock should have been held */
+static struct bpf_map *bpf_map_inc_not_zero(struct bpf_map *map,
+					    bool uref)
+{
+	int refold;
+
+	refold = __atomic_add_unless(&map->refcnt, 1, 0);
+
+	if (refold >= BPF_MAX_REFCNT) {
+		__bpf_map_put(map, false);
+		return ERR_PTR(-EBUSY);
+	}
+
+	if (!refold)
+		return ERR_PTR(-ENOENT);
+
+	if (uref)
+		atomic_inc(&map->usercnt);
+
+	return map;
+}
+
 int __weak bpf_stackmap_copy(struct bpf_map *map, void *key, void *value)
 {
 	return -ENOTSUPP;
@@ -1167,6 +1207,38 @@ static int bpf_prog_get_fd_by_id(const union bpf_attr *attr)
 	return fd;
 }
 
+#define BPF_MAP_GET_FD_BY_ID_LAST_FIELD map_id
+
+static int bpf_map_get_fd_by_id(const union bpf_attr *attr)
+{
+	struct bpf_map *map;
+	u32 id = attr->map_id;
+	int fd;
+
+	if (CHECK_ATTR(BPF_MAP_GET_FD_BY_ID))
+		return -EINVAL;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	spin_lock_bh(&map_idr_lock);
+	map = idr_find(&map_idr, id);
+	if (map)
+		map = bpf_map_inc_not_zero(map, true);
+	else
+		map = ERR_PTR(-ENOENT);
+	spin_unlock_bh(&map_idr_lock);
+
+	if (IS_ERR(map))
+		return PTR_ERR(map);
+
+	fd = bpf_map_new_fd(map);
+	if (fd < 0)
+		bpf_map_put(map);
+
+	return fd;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -1255,6 +1327,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_PROG_GET_FD_BY_ID:
 		err = bpf_prog_get_fd_by_id(&attr);
 		break;
+	case BPF_MAP_GET_FD_BY_ID:
+		err = bpf_map_get_fd_by_id(&attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
2.9.3
