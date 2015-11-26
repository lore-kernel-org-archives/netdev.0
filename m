From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 2/5] {f,m}_bpf: check map attributes when fetching as pinned
Date: Thu, 26 Nov 2015 13:58:30 +0100
Message-ID: <92ddef47c9e902586a96c34318c16107c78c683e.1448541097.git.daniel@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37251 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbbKZM6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 07:58:41 -0500
In-Reply-To: <cover.1448541097.git.daniel@iogearbox.net>
In-Reply-To: <cover.1448541097.git.daniel@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the new show_fdinfo() facility and verify that when a
pinned map is being fetched that its basic attributes are the same
as the map we declared from the ELF file. I.e. when placed into the
globalns, collisions could occur. In such a case warn the user and
bail out.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tc/tc_bpf.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 73a0f41..a9f5f8b 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -205,6 +205,52 @@ void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
 		ops[i].jf, ops[i].k);
 }
 
+static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map)
+{
+	char file[PATH_MAX], buff[4096];
+	struct bpf_elf_map tmp, zero;
+	unsigned int val;
+	FILE *fp;
+
+	snprintf(file, sizeof(file), "/proc/%d/fdinfo/%d", getpid(), fd);
+
+	fp = fopen(file, "r");
+	if (!fp) {
+		fprintf(stderr, "No procfs support?!\n");
+		return -EIO;
+	}
+
+	memset(&tmp, 0, sizeof(tmp));
+	while (fgets(buff, sizeof(buff), fp)) {
+		if (sscanf(buff, "map_type:\t%u", &val) == 1)
+			tmp.type = val;
+		else if (sscanf(buff, "key_size:\t%u", &val) == 1)
+			tmp.size_key = val;
+		else if (sscanf(buff, "value_size:\t%u", &val) == 1)
+			tmp.size_value = val;
+		else if (sscanf(buff, "max_entries:\t%u", &val) == 1)
+			tmp.max_elem = val;
+	}
+
+	fclose(fp);
+
+	if (!memcmp(&tmp, map, offsetof(struct bpf_elf_map, id))) {
+		return 0;
+	} else {
+		memset(&zero, 0, sizeof(zero));
+		/* If kernel doesn't have eBPF-related fdinfo, we cannot do much,
+		 * so just accept it. We know we do have an eBPF fd and in this
+		 * case, everything is 0. It is guaranteed that no such map exists
+		 * since map type of 0 is unloadable BPF_MAP_TYPE_UNSPEC.
+		 */
+		if (!memcmp(&tmp, &zero, offsetof(struct bpf_elf_map, id)))
+			return 0;
+
+		fprintf(stderr, "Map specs from pinned file differ!\n");
+		return -EINVAL;
+	}
+}
+
 static int bpf_valid_mntpt(const char *mnt, unsigned long magic)
 {
 	struct statfs st_fs;
@@ -816,6 +862,13 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 
 	fd = bpf_probe_pinned(name, map->pinning);
 	if (fd > 0) {
+		ret = bpf_map_selfcheck_pinned(fd, map);
+		if (ret < 0) {
+			close(fd);
+			fprintf(stderr, "Map \'%s\' self-check failed!\n",
+				name);
+			return ret;
+		}
 		if (verbose)
 			fprintf(stderr, "Map \'%s\' loaded as pinned!\n",
 				name);
-- 
1.9.3
