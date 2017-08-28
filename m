From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 6/9] bpf: harden sockmap program attach to ensure
 correct map type
Date: Mon, 28 Aug 2017 07:11:43 -0700
Message-ID: <20170828141143.14143.89655.stgit@john-Precision-Tower-5810>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36636 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdH1OL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:11:56 -0400
Received: by mail-pf0-f194.google.com with SMTP id k3so395043pfc.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:11:55 -0700 (PDT)
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When attaching a program to sockmap we need to check map type
is correct.

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/sockmap.c                               |    3 ++
 tools/testing/selftests/bpf/sockmap_verdict_prog.c |    7 +++++
 tools/testing/selftests/bpf/test_maps.c            |   27 +++++++++++++++++---
 3 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 266011c8..38bf4e4 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -794,6 +794,9 @@ int sock_map_attach_prog(struct bpf_map *map, struct bpf_prog *prog, u32 type)
 	struct bpf_stab *stab = container_of(map, struct bpf_stab, map);
 	struct bpf_prog *orig;
 
+	if (unlikely(map->map_type != BPF_MAP_TYPE_SOCKMAP))
+		return -EINVAL;
+
 	switch (type) {
 	case BPF_SK_SKB_STREAM_PARSER:
 		orig = xchg(&stab->bpf_parse, prog);
diff --git a/tools/testing/selftests/bpf/sockmap_verdict_prog.c b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
index dada207..9b99bd1 100644
--- a/tools/testing/selftests/bpf/sockmap_verdict_prog.c
+++ b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
@@ -26,6 +26,13 @@ struct bpf_map_def SEC("maps") sock_map_tx = {
 	.max_entries = 20,
 };
 
+struct bpf_map_def SEC("maps") sock_map_break = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(int),
+	.max_entries = 20,
+};
+
 SEC("sk_skb2")
 int bpf_prog2(struct __sk_buff *skb)
 {
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 0a7f457..0c4b56d 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -463,12 +463,12 @@ static void test_devmap(int task, void *data)
 #define SOCKMAP_VERDICT_PROG "./sockmap_verdict_prog.o"
 static void test_sockmap(int task, void *data)
 {
+	int one = 1, map_fd_rx, map_fd_tx, map_fd_break, s, sc, rc;
+	struct bpf_map *bpf_map_rx, *bpf_map_tx, *bpf_map_break;
 	int ports[] = {50200, 50201, 50202, 50204};
 	int err, i, fd, sfd[6] = {0xdeadbeef};
 	u8 buf[20] = {0x0, 0x5, 0x3, 0x2, 0x1, 0x0};
-	int one = 1, map_fd_rx, map_fd_tx, s, sc, rc;
 	int parse_prog, verdict_prog;
-	struct bpf_map *bpf_map_rx, *bpf_map_tx;
 	struct sockaddr_in addr;
 	struct bpf_object *obj;
 	struct timeval to;
@@ -609,17 +609,36 @@ static void test_sockmap(int task, void *data)
 		goto out_sockmap;
 	}
 
+	bpf_map_break = bpf_object__find_map_by_name(obj, "sock_map_break");
+	if (IS_ERR(bpf_map_break)) {
+		printf("Failed to load map tx from verdict prog\n");
+		goto out_sockmap;
+	}
+
+	map_fd_break = bpf_map__fd(bpf_map_break);
+	if (map_fd_break < 0) {
+		printf("Failed to get map tx fd\n");
+		goto out_sockmap;
+	}
+
+	err = bpf_prog_attach(parse_prog, map_fd_break,
+			      BPF_SK_SKB_STREAM_PARSER, 0);
+	if (!err) {
+		printf("Allowed attaching SK_SKB program to invalid map\n");
+		goto out_sockmap;
+	}
+
 	err = bpf_prog_attach(parse_prog, map_fd_rx,
 		      BPF_SK_SKB_STREAM_PARSER, 0);
 	if (err) {
-		printf("Failed bpf prog attach\n");
+		printf("Failed stream parser bpf prog attach\n");
 		goto out_sockmap;
 	}
 
 	err = bpf_prog_attach(verdict_prog, map_fd_rx,
 			      BPF_SK_SKB_STREAM_VERDICT, 0);
 	if (err) {
-		printf("Failed bpf prog attach\n");
+		printf("Failed stream verdict bpf prog attach\n");
 		goto out_sockmap;
 	}
 
