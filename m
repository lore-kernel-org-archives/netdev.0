From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 2/2] bpf: sock_map fixes for !CONFIG_BPF_SYSCALL
 and !STREAM_PARSER
Date: Wed, 16 Aug 2017 15:02:32 -0700
Message-ID: <20170816220232.25438.47447.stgit@john-Precision-Tower-5810>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: daniel@iogearbox.net, davem@davemloft.net, eric.dumazet@gmail.com,
        dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36140 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdHPWCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:02:47 -0400
Received: by mail-pg0-f66.google.com with SMTP id y129so6575152pgy.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 15:02:47 -0700 (PDT)
In-Reply-To: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resolve issues with !CONFIG_BPF_SYSCALL and !STREAM_PARSER

net/core/filter.c: In function ‘do_sk_redirect_map’:
net/core/filter.c:1881:3: error: implicit declaration of function ‘__sock_map_lookup_elem’ [-Werror=implicit-function-declaration]
   sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
   ^
net/core/filter.c:1881:6: warning: assignment makes pointer from integer without a cast [enabled by default]
   sk = __sock_map_lookup_elem(ri->map, ri->ifindex);

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/linux/bpf.h       |   10 +++++++++-
 include/linux/bpf_types.h |    2 ++
 kernel/bpf/Makefile       |    5 ++++-
 kernel/bpf/core.c         |    1 +
 4 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index a4145e9..1cc6c5f 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -313,7 +313,6 @@ static inline void bpf_long_memcpy(void *dst, const void *src, u32 size)
 
 /* Map specifics */
 struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
-struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key);
 void __dev_map_insert_ctx(struct bpf_map *map, u32 index);
 void __dev_map_flush(struct bpf_map *map);
 
@@ -377,6 +376,15 @@ static inline void __dev_map_flush(struct bpf_map *map)
 }
 #endif /* CONFIG_BPF_SYSCALL */
 
+#if defined(CONFIG_STREAM_PARSER) && defined(CONFIG_BPF_SYSCALL)
+struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key);
+#else
+static inline struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key)
+{
+	return NULL;
+}
+#endif
+
 /* verifier prototypes for helper functions called from eBPF programs */
 extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
 extern const struct bpf_func_proto bpf_map_update_elem_proto;
diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index fa80507..6f1a567 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -38,5 +38,7 @@
 BPF_MAP_TYPE(BPF_MAP_TYPE_HASH_OF_MAPS, htab_of_maps_map_ops)
 #ifdef CONFIG_NET
 BPF_MAP_TYPE(BPF_MAP_TYPE_DEVMAP, dev_map_ops)
+#ifdef CONFIG_STREAM_PARSER
 BPF_MAP_TYPE(BPF_MAP_TYPE_SOCKMAP, sock_map_ops)
 #endif
+#endif
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index aa24287..897daa0 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -3,7 +3,10 @@ obj-y := core.o
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o tnum.o
 obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
 ifeq ($(CONFIG_NET),y)
-obj-$(CONFIG_BPF_SYSCALL) += devmap.o sockmap.o
+obj-$(CONFIG_BPF_SYSCALL) += devmap.o
+ifeq ($(CONFIG_STREAM_PARSER),y)
+obj-$(CONFIG_BPF_SYSCALL) += sockmap.o
+endif
 endif
 ifeq ($(CONFIG_PERF_EVENTS),y)
 obj-$(CONFIG_BPF_SYSCALL) += stackmap.o
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index c69e7f5..917cc04 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1438,6 +1438,7 @@ void bpf_user_rnd_init_once(void)
 const struct bpf_func_proto bpf_get_current_pid_tgid_proto __weak;
 const struct bpf_func_proto bpf_get_current_uid_gid_proto __weak;
 const struct bpf_func_proto bpf_get_current_comm_proto __weak;
+const struct bpf_func_proto bpf_sock_map_update_proto __weak;
 
 const struct bpf_func_proto * __weak bpf_get_trace_printk_proto(void)
 {
