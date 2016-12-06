From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -net-next] bpf: check for owner_prog_type and notify users when differ
Date: Tue,  6 Dec 2016 02:17:58 +0100
Message-ID: <96d911b76235bec7fc7551eb227eb750ff8c5de1.1480986807.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47801 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752144AbcLFBSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 20:18:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel commit 21116b7068b9 ("bpf: add owner_prog_type and accounted mem
to array map's fdinfo") added support for telling the owner prog type in
case of prog arrays. Give a notification to the user when they differ,
and the program eventually fails to load.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 lib/bpf.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 8a5b84b..f714993 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -273,11 +273,11 @@ static void bpf_map_pin_report(const struct bpf_elf_map *pin,
 }
 
 static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
-				    int length)
+				    int length, enum bpf_prog_type type)
 {
 	char file[PATH_MAX], buff[4096];
 	struct bpf_elf_map tmp = {}, zero = {};
-	unsigned int val;
+	unsigned int val, owner_type = 0;
 	FILE *fp;
 
 	snprintf(file, sizeof(file), "/proc/%d/fdinfo/%d", getpid(), fd);
@@ -299,10 +299,19 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 			tmp.max_elem = val;
 		else if (sscanf(buff, "map_flags:\t%i", &val) == 1)
 			tmp.flags = val;
+		else if (sscanf(buff, "owner_prog_type:\t%i", &val) == 1)
+			owner_type = val;
 	}
 
 	fclose(fp);
 
+	/* The decision to reject this is on kernel side eventually, but
+	 * at least give the user a chance to know what's wrong.
+	 */
+	if (owner_type && owner_type != type)
+		fprintf(stderr, "Program array map owner types differ: %u (obj) != %u (pin)\n",
+			type, owner_type);
+
 	if (!memcmp(&tmp, map, length)) {
 		return 0;
 	} else {
@@ -818,7 +827,8 @@ int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv)
 	}
 
 	ret = bpf_map_selfcheck_pinned(map_fd, &test,
-				       offsetof(struct bpf_elf_map, max_elem));
+				       offsetof(struct bpf_elf_map, max_elem),
+				       type);
 	if (ret < 0) {
 		fprintf(stderr, "Map \'%s\' self-check failed!\n", map_path);
 		goto out_map;
@@ -1300,7 +1310,7 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 	if (fd > 0) {
 		ret = bpf_map_selfcheck_pinned(fd, map,
 					       offsetof(struct bpf_elf_map,
-							id));
+							id), ctx->type);
 		if (ret < 0) {
 			close(fd);
 			fprintf(stderr, "Map \'%s\' self-check failed!\n",
-- 
1.9.3
