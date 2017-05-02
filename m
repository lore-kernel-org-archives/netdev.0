From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/4] samples/bpf: load_bpf.c make callback fixup
 more flexible
Date: Tue, 02 May 2017 14:32:01 +0200
Message-ID: <149372832108.22268.4265414102730853145.stgit@firesoul>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63799 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750951AbdEBMcK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 08:32:10 -0400
In-Reply-To: <149372826543.22268.3617359219409721129.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do this change before others start to use this callback.
Change map_perf_test_user.c which seems to be the only user.

This patch extends capabilities of commit 9fd63d05f3e8 ("bpf:
Allow bpf sample programs (*_user.c) to change bpf_map_def").

Give fixup callback access to struct bpf_map_data, instead of
only stuct bpf_map_def.  This add flexibility to allow userspace
to reassign the map file descriptor.  This is very useful when
wanting to share maps between several bpf programs.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/bpf_load.c           |   17 ++++++++---------
 samples/bpf/bpf_load.h           |   10 ++++++++--
 samples/bpf/map_perf_test_user.c |   14 +++++++-------
 3 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index fedec29c7817..74456b3eb89a 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -39,13 +39,6 @@ int event_fd[MAX_PROGS];
 int prog_cnt;
 int prog_array_fd = -1;
 
-/* Keeping relevant info on maps */
-struct bpf_map_data {
-	int fd;
-	char *name;
-	size_t elf_offset;
-	struct bpf_map_def def;
-};
 struct bpf_map_data map_data[MAX_MAPS];
 int map_data_count = 0;
 
@@ -202,8 +195,14 @@ static int load_maps(struct bpf_map_data *maps, int nr_maps,
 	int i;
 
 	for (i = 0; i < nr_maps; i++) {
-		if (fixup_map)
-			fixup_map(&maps[i].def, maps[i].name, i);
+		if (fixup_map) {
+			fixup_map(&maps[i], i);
+			/* Allow userspace to assign map FD prior to creation */
+			if (maps[i].fd != -1) {
+				map_fd[i] = maps[i].fd;
+				continue;
+			}
+		}
 
 		if (maps[i].def.type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
 		    maps[i].def.type == BPF_MAP_TYPE_HASH_OF_MAPS) {
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index 05822f83173a..4d4fd4678a64 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -15,8 +15,14 @@ struct bpf_map_def {
 	unsigned int inner_map_idx;
 };
 
-typedef void (*fixup_map_cb)(struct bpf_map_def *map, const char *map_name,
-			     int idx);
+struct bpf_map_data {
+	int fd;
+	char *name;
+	size_t elf_offset;
+	struct bpf_map_def def;
+};
+
+typedef void (*fixup_map_cb)(struct bpf_map_data *map, int idx);
 
 extern int map_fd[MAX_MAPS];
 extern int prog_fd[MAX_PROGS];
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 6ac778153315..1a8894b5ac51 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -320,21 +320,21 @@ static void fill_lpm_trie(void)
 	assert(!r);
 }
 
-static void fixup_map(struct bpf_map_def *map, const char *name, int idx)
+static void fixup_map(struct bpf_map_data *map, int idx)
 {
 	int i;
 
-	if (!strcmp("inner_lru_hash_map", name)) {
+	if (!strcmp("inner_lru_hash_map", map->name)) {
 		inner_lru_hash_idx = idx;
-		inner_lru_hash_size = map->max_entries;
+		inner_lru_hash_size = map->def.max_entries;
 	}
 
-	if (!strcmp("array_of_lru_hashs", name)) {
+	if (!strcmp("array_of_lru_hashs", map->name)) {
 		if (inner_lru_hash_idx == -1) {
 			printf("inner_lru_hash_map must be defined before array_of_lru_hashs\n");
 			exit(1);
 		}
-		map->inner_map_idx = inner_lru_hash_idx;
+		map->def.inner_map_idx = inner_lru_hash_idx;
 		array_of_lru_hashs_idx = idx;
 	}
 
@@ -345,9 +345,9 @@ static void fixup_map(struct bpf_map_def *map, const char *name, int idx)
 
 	/* Only change the max_entries for the enabled test(s) */
 	for (i = 0; i < NR_TESTS; i++) {
-		if (!strcmp(test_map_names[i], name) &&
+		if (!strcmp(test_map_names[i], map->name) &&
 		    (check_test_flags(i))) {
-			map->max_entries = num_map_entries;
+			map->def.max_entries = num_map_entries;
 		}
 	}
 }
