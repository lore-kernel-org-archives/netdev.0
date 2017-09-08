From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 2/3] bpf: add support for sockmap detach programs
Date: Fri, 08 Sep 2017 14:00:49 -0700
Message-ID: <150490444956.11590.4733752227675213913.stgit@john-XPS-13-9360>
References: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
        daniel@iogearbox.net, ast@fb.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37878 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932400AbdIHVBE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:01:04 -0400
Received: by mail-pg0-f67.google.com with SMTP id v5so1785561pgn.4
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:01:04 -0700 (PDT)
In-Reply-To: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bpf map sockmap supports adding programs via attach commands. This
patch adds the detach command to keep the API symmetric and allow
users to remove previously added programs. Otherwise the user would
have to delete the map and re-add it to get in this state.

This also adds a series of additional tests to capture detach operation
and also attaching/detaching invalid prog types.

API note: socks will run (or not run) programs depending on the state
of the map at the time the sock is added. We do not for example walk
the map and remove programs from previously attached socks.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/linux/bpf.h                     |    8 ++---
 kernel/bpf/sockmap.c                    |    2 +
 kernel/bpf/syscall.c                    |   27 ++++++++++------
 tools/testing/selftests/bpf/test_maps.c |   51 ++++++++++++++++++++++++++++++-
 4 files changed, 72 insertions(+), 16 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index c2cb1b5..8390859 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -385,16 +385,16 @@ static inline void __dev_map_flush(struct bpf_map *map)
 
 #if defined(CONFIG_STREAM_PARSER) && defined(CONFIG_BPF_SYSCALL)
 struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key);
-int sock_map_attach_prog(struct bpf_map *map, struct bpf_prog *prog, u32 type);
+int sock_map_prog(struct bpf_map *map, struct bpf_prog *prog, u32 type);
 #else
 static inline struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key)
 {
 	return NULL;
 }
 
-static inline int sock_map_attach_prog(struct bpf_map *map,
-				       struct bpf_prog *prog,
-				       u32 type)
+static inline int sock_map_prog(struct bpf_map *map,
+				struct bpf_prog *prog,
+				u32 type)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index f6ffde9..6424ce0 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -792,7 +792,7 @@ static int sock_map_ctx_update_elem(struct bpf_sock_ops_kern *skops,
 	return err;
 }
 
-int sock_map_attach_prog(struct bpf_map *map, struct bpf_prog *prog, u32 type)
+int sock_map_prog(struct bpf_map *map, struct bpf_prog *prog, u32 type)
 {
 	struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
 	struct bpf_prog *orig;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 70ad8e2..cb17e1c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1096,10 +1096,10 @@ static int bpf_obj_get(const union bpf_attr *attr)
 
 #define BPF_PROG_ATTACH_LAST_FIELD attach_flags
 
-static int sockmap_get_from_fd(const union bpf_attr *attr)
+static int sockmap_get_from_fd(const union bpf_attr *attr, bool attach)
 {
+	struct bpf_prog *prog = NULL;
 	int ufd = attr->target_fd;
-	struct bpf_prog *prog;
 	struct bpf_map *map;
 	struct fd f;
 	int err;
@@ -1109,16 +1109,20 @@ static int sockmap_get_from_fd(const union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
-	prog = bpf_prog_get_type(attr->attach_bpf_fd, BPF_PROG_TYPE_SK_SKB);
-	if (IS_ERR(prog)) {
-		fdput(f);
-		return PTR_ERR(prog);
+	if (attach) {
+		prog = bpf_prog_get_type(attr->attach_bpf_fd,
+					 BPF_PROG_TYPE_SK_SKB);
+		if (IS_ERR(prog)) {
+			fdput(f);
+			return PTR_ERR(prog);
+		}
 	}
 
-	err = sock_map_attach_prog(map, prog, attr->attach_type);
+	err = sock_map_prog(map, prog, attr->attach_type);
 	if (err) {
 		fdput(f);
-		bpf_prog_put(prog);
+		if (prog)
+			bpf_prog_put(prog);
 		return err;
 	}
 
@@ -1155,7 +1159,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 		break;
 	case BPF_SK_SKB_STREAM_PARSER:
 	case BPF_SK_SKB_STREAM_VERDICT:
-		return sockmap_get_from_fd(attr);
+		return sockmap_get_from_fd(attr, true);
 	default:
 		return -EINVAL;
 	}
@@ -1204,7 +1208,10 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		ret = cgroup_bpf_update(cgrp, NULL, attr->attach_type, false);
 		cgroup_put(cgrp);
 		break;
-
+	case BPF_SK_SKB_STREAM_PARSER:
+	case BPF_SK_SKB_STREAM_VERDICT:
+		ret = sockmap_get_from_fd(attr, false);
+		break;
 	default:
 		return -EINVAL;
 	}
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 4acc772..fe3a443 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -558,7 +558,7 @@ static void test_sockmap(int tasks, void *data)
 		}
 	}
 
-	/* Test attaching bad fds */
+	/* Test attaching/detaching bad fds */
 	err = bpf_prog_attach(-1, fd, BPF_SK_SKB_STREAM_PARSER, 0);
 	if (!err) {
 		printf("Failed invalid parser prog attach\n");
@@ -571,6 +571,30 @@ static void test_sockmap(int tasks, void *data)
 		goto out_sockmap;
 	}
 
+	err = bpf_prog_attach(-1, fd, __MAX_BPF_ATTACH_TYPE, 0);
+	if (!err) {
+		printf("Failed unknown prog attach\n");
+		goto out_sockmap;
+	}
+
+	err = bpf_prog_detach(fd, BPF_SK_SKB_STREAM_PARSER);
+	if (err) {
+		printf("Failed empty parser prog detach\n");
+		goto out_sockmap;
+	}
+
+	err = bpf_prog_detach(fd, BPF_SK_SKB_STREAM_VERDICT);
+	if (err) {
+		printf("Failed empty verdict prog detach\n");
+		goto out_sockmap;
+	}
+
+	err = bpf_prog_detach(fd, __MAX_BPF_ATTACH_TYPE);
+	if (!err) {
+		printf("Detach invalid prog successful\n");
+		goto out_sockmap;
+	}
+
 	/* Load SK_SKB program and Attach */
 	err = bpf_prog_load(SOCKMAP_PARSE_PROG,
 			    BPF_PROG_TYPE_SK_SKB, &obj, &parse_prog);
@@ -643,6 +667,13 @@ static void test_sockmap(int tasks, void *data)
 		goto out_sockmap;
 	}
 
+	err = bpf_prog_attach(verdict_prog, map_fd_rx,
+			      __MAX_BPF_ATTACH_TYPE, 0);
+	if (!err) {
+		printf("Attached unknown bpf prog\n");
+		goto out_sockmap;
+	}
+
 	/* Test map update elem afterwards fd lives in fd and map_fd */
 	for (i = 0; i < 6; i++) {
 		err = bpf_map_update_elem(map_fd_rx, &i, &sfd[i], BPF_ANY);
@@ -809,6 +840,24 @@ static void test_sockmap(int tasks, void *data)
 		assert(status == 0);
 	}
 
+	err = bpf_prog_detach(map_fd_rx, __MAX_BPF_ATTACH_TYPE);
+	if (!err) {
+		printf("Detached an invalid prog type.\n");
+		goto out_sockmap;
+	}
+
+	err = bpf_prog_detach(map_fd_rx, BPF_SK_SKB_STREAM_PARSER);
+	if (err) {
+		printf("Failed parser prog detach\n");
+		goto out_sockmap;
+	}
+
+	err = bpf_prog_detach(map_fd_rx, BPF_SK_SKB_STREAM_VERDICT);
+	if (err) {
+		printf("Failed parser prog detach\n");
+		goto out_sockmap;
+	}
+
 	/* Test map close sockets */
 	for (i = 0; i < 6; i++)
 		close(sfd[i]);
