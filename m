From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/7] bpf: add 'flags' attribute to BPF_MAP_UPDATE_ELEM command
Date: Mon,  3 Nov 2014 18:54:10 -0800
Message-ID: <1415069656-14138-2-git-send-email-ast@plumgrid.com>
References: <1415069656-14138-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415069656-14138-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
either update existing map element or create a new one.
Initially the plan was to add a new command to handle the case of
'create new element if it didn't exist', but 'flags' style looks
cleaner and overall diff is much smaller (more code reused), so add 'flags'
attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
enum {
  BPF_MAP_UPDATE_OR_CREATE = 0, /* add new element or update existing */
  BPF_MAP_CREATE_ONLY,          /* add new element if it didn't exist */
  BPF_MAP_UPDATE_ONLY           /* update existing element */
};

BPF_MAP_CREATE_ONLY can fail with EEXIST if element already exists.
BPF_MAP_UPDATE_ONLY can fail with ENOENT if element doesn't exist.

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

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h      |    2 +-
 include/uapi/linux/bpf.h |   10 +++++++++-
 kernel/bpf/syscall.c     |    4 ++--
 3 files changed, 12 insertions(+), 4 deletions(-)

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
index d18316f9e9c4..19c7ae4a4dd5 100644
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
@@ -117,6 +117,13 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 };
 
+/* flags for BPF_MAP_UPDATE_ELEM command */
+enum bpf_map_update_flags {
+	BPF_MAP_UPDATE_OR_CREATE = 0,	/* add new element or update existing */
+	BPF_MAP_CREATE_ONLY,		/* add new element if it didn't exist */
+	BPF_MAP_UPDATE_ONLY		/* update existing element */
+};
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -132,6 +139,7 @@ union bpf_attr {
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
