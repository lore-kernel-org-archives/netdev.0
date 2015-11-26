From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 1/5] {f,m}_bpf: make tail calls working
Date: Thu, 26 Nov 2015 13:58:29 +0100
Message-ID: <88d074dcdf1469ea381e1d732852cc87fb1aba2c.1448541097.git.daniel@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37238 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbbKZM6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 07:58:38 -0500
In-Reply-To: <cover.1448541097.git.daniel@iogearbox.net>
In-Reply-To: <cover.1448541097.git.daniel@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have the possibility of sharing maps, it's time we get the
ELF loader fully working with regards to tail calls. Since program array
maps are pinned, we can keep them finally alive. I've noticed two bugs
that are being fixed in bpf_fill_prog_arrays() with this patch. Example
code comes as follow-up.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tc/tc_bpf.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index bc7bc9f..73a0f41 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -1139,11 +1139,26 @@ static int bpf_fetch_prog_sec(struct bpf_elf_ctx *ctx, const char *section)
 	return ret;
 }
 
+static int bpf_find_map_by_id(struct bpf_elf_ctx *ctx, uint32_t id)
+{
+	int i, ret = -1;
+
+	for (i = 0; i < ARRAY_SIZE(ctx->map_fds); i++) {
+		if (ctx->map_fds[i] && ctx->maps[i].id == id &&
+		    ctx->maps[i].type == BPF_MAP_TYPE_PROG_ARRAY) {
+			ret = i;
+			break;
+		}
+	}
+
+	return ret;
+}
+
 static int bpf_fill_prog_arrays(struct bpf_elf_ctx *ctx)
 {
 	struct bpf_elf_sec_data data;
 	uint32_t map_id, key_id;
-	int fd, i, ret;
+	int fd, i, ret, idx;
 
 	for (i = 1; i < ctx->elf_hdr.e_shnum; i++) {
 		if (ctx->sec_done[i])
@@ -1153,20 +1168,20 @@ static int bpf_fill_prog_arrays(struct bpf_elf_ctx *ctx)
 		if (ret < 0)
 			continue;
 
-		ret = sscanf(data.sec_name, "%u/%u", &map_id, &key_id);
-		if (ret != 2 || map_id >= ARRAY_SIZE(ctx->map_fds) ||
-		    !ctx->map_fds[map_id])
+		ret = sscanf(data.sec_name, "%i/%i", &map_id, &key_id);
+		if (ret != 2)
 			continue;
-		if (ctx->maps[map_id].type != BPF_MAP_TYPE_PROG_ARRAY ||
-		    ctx->maps[map_id].max_elem <= key_id)
+
+		idx = bpf_find_map_by_id(ctx, map_id);
+		if (idx < 0)
 			continue;
 
 		fd = bpf_fetch_prog_sec(ctx, data.sec_name);
 		if (fd < 0)
 			return -EIO;
 
-		ret = bpf_map_update(ctx->map_fds[map_id], &key_id,
-				     &fd, BPF_NOEXIST);
+		ret = bpf_map_update(ctx->map_fds[idx], &key_id,
+				     &fd, BPF_ANY);
 		if (ret < 0)
 			return -ENOENT;
 
-- 
1.9.3
