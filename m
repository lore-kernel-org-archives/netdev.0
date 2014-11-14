From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 1/7] bpf: add 'flags' attribute to BPF_MAP_UPDATE_ELEM command
Date: Thu, 13 Nov 2014 17:36:44 -0800
Message-ID: <1415929010-9361-2-git-send-email-ast@plumgrid.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
either update existing map element or create a new one.
Initially the plan was to add a new command to handle the case of
'create new element if it didn't exist', but 'flags' style looks
cleaner and overall diff is much smaller (more code reused), so add 'flags'
attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
 #define BPF_ANY	0 /* create new element or update existing */
 #define BPF_NOEXIST	1 /* create new element if it didn't exist */
 #define BPF_EXIST	2 /* update existing element */

bpf_update_elem(fd, key, value, BPF_NOEXIST) call can fail with EEXIST
if element already exists.

bpf_update_elem(fd, key, value, BPF_EXIST) can fail with ENOENT
if element doesn't exist.

Userspace will call it as:
int bpf_update_elem(int fd, void *key, void *value, __u64 flags)
{
    union bpf_attr attr = {
        .map_fd = fd,
        .key = ptr_to_u64(key),
        .value = ptr_to_u64(value),
        .flags = flags;
    };

    return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
}

First two bits of 'flags' are used to encode style of bpf_update_elem() command.
Bits 2-63 are reserved for future use.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

patch 5 of this set includes tests of bpf_update_elem() with these flags

 include/linux/bpf.h      |    2 +-
 include/uapi/linux/bpf.h |    8 +++++++-
 kernel/bpf/syscall.c     |    4 ++--
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 3cf91754a957..51e9242e4803 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -22,7 +22,7 @@ struct bpf_map_ops {
 
 	/* funcs callable from userspace and from eBPF programs */
 	void *(*map_lookup_elem)(struct bpf_map *map, void *key);
-	int (*map_update_elem)(struct bpf_map *map, void *key, void *value);
+	int (*map_update_elem)(struct bpf_map *map, void *key, void *value, u64 flags);
 	int (*map_delete_elem)(struct bpf_map *map, void *key);
 };
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d18316f9e9c4..3e9e1b77f29d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -82,7 +82,7 @@ enum bpf_cmd {
 
 	/* create or update key/value pair in a given map
 	 * err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key, attr->value
+	 * Using attr->map_fd, attr->key, attr->value, attr->flags
 	 * returns zero or negative error
 	 */
 	BPF_MAP_UPDATE_ELEM,
@@ -117,6 +117,11 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 };
 
+/* flags for BPF_MAP_UPDATE_ELEM command */
+#define BPF_ANY		0 /* create new element or update existing */
+#define BPF_NOEXIST	1 /* create new element if it didn't exist */
+#define BPF_EXIST	2 /* update existing element */
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -132,6 +137,7 @@ union bpf_attr {
 			__aligned_u64 value;
 			__aligned_u64 next_key;
 		};
+		__u64		flags;
 	};
 
 	struct { /* anonymous struct used by BPF_PROG_LOAD command */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index ba61c8c16032..c0d03bf317a2 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -190,7 +190,7 @@ err_put:
 	return err;
 }
 
-#define BPF_MAP_UPDATE_ELEM_LAST_FIELD value
+#define BPF_MAP_UPDATE_ELEM_LAST_FIELD flags
 
 static int map_update_elem(union bpf_attr *attr)
 {
@@ -231,7 +231,7 @@ static int map_update_elem(union bpf_attr *attr)
 	 * therefore all map accessors rely on this fact, so do the same here
 	 */
 	rcu_read_lock();
-	err = map->ops->map_update_elem(map, key, value);
+	err = map->ops->map_update_elem(map, key, value, attr->flags);
 	rcu_read_unlock();
 
 free_value:
-- 
1.7.9.5
