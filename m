From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] selftests/bpf: check the instruction dumps are populated
Date: Fri, 25 Aug 2017 14:39:57 -0700
Message-ID: <20170825213957.4768-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, kafai@fb.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34926 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932688AbdHYVkX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 17:40:23 -0400
Received: by mail-pg0-f48.google.com with SMTP id 63so5288730pgc.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 14:40:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a basic test for checking whether kernel is populating
the jited and xlated BPF images.  It was used to confirm
the behaviour change from commit d777b2ddbecf ("bpf: don't 
zero out the info struct in bpf_obj_get_info_by_fd()"),
which made bpf_obj_get_info_by_fd() usable for retrieving
the image dumps.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/testing/selftests/bpf/test_progs.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
index 1cb037803679..11ee25cea227 100644
--- a/tools/testing/selftests/bpf/test_progs.c
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -279,7 +279,7 @@ static void test_bpf_obj_id(void)
 	/* +1 to test for the info_len returned by kernel */
 	struct bpf_prog_info prog_infos[nr_iters + 1];
 	struct bpf_map_info map_infos[nr_iters + 1];
-	char jited_insns[128], xlated_insns[128];
+	char jited_insns[128], xlated_insns[128], zeros[128];
 	__u32 i, next_id, info_len, nr_id_found, duration = 0;
 	int sysctl_fd, jit_enabled = 0, err = 0;
 	__u64 array_value;
@@ -305,6 +305,7 @@ static void test_bpf_obj_id(void)
 		objs[i] = NULL;
 
 	/* Check bpf_obj_get_info_by_fd() */
+	bzero(zeros, sizeof(zeros));
 	for (i = 0; i < nr_iters; i++) {
 		err = bpf_prog_load(file, BPF_PROG_TYPE_SOCKET_FILTER,
 				    &objs[i], &prog_fds[i]);
@@ -318,6 +319,8 @@ static void test_bpf_obj_id(void)
 		/* Check getting prog info */
 		info_len = sizeof(struct bpf_prog_info) * 2;
 		bzero(&prog_infos[i], info_len);
+		bzero(jited_insns, sizeof(jited_insns));
+		bzero(xlated_insns, sizeof(xlated_insns));
 		prog_infos[i].jited_prog_insns = ptr_to_u64(jited_insns);
 		prog_infos[i].jited_prog_len = sizeof(jited_insns);
 		prog_infos[i].xlated_prog_insns = ptr_to_u64(xlated_insns);
@@ -328,15 +331,20 @@ static void test_bpf_obj_id(void)
 			  prog_infos[i].type != BPF_PROG_TYPE_SOCKET_FILTER ||
 			  info_len != sizeof(struct bpf_prog_info) ||
 			  (jit_enabled && !prog_infos[i].jited_prog_len) ||
-			  !prog_infos[i].xlated_prog_len,
+			  (jit_enabled &&
+			   !memcmp(jited_insns, zeros, sizeof(zeros))) ||
+			  !prog_infos[i].xlated_prog_len ||
+			  !memcmp(xlated_insns, zeros, sizeof(zeros)),
 			  "get-prog-info(fd)",
-			  "err %d errno %d i %d type %d(%d) info_len %u(%lu) jit_enabled %d jited_prog_len %u xlated_prog_len %u\n",
+			  "err %d errno %d i %d type %d(%d) info_len %u(%lu) jit_enabled %d jited_prog_len %u xlated_prog_len %u jited_prog %d xlated_prog %d\n",
 			  err, errno, i,
 			  prog_infos[i].type, BPF_PROG_TYPE_SOCKET_FILTER,
 			  info_len, sizeof(struct bpf_prog_info),
 			  jit_enabled,
 			  prog_infos[i].jited_prog_len,
-			  prog_infos[i].xlated_prog_len))
+			  prog_infos[i].xlated_prog_len,
+			  !!memcmp(jited_insns, zeros, sizeof(zeros)),
+			  !!memcmp(xlated_insns, zeros, sizeof(zeros))))
 			goto done;
 
 		map_fds[i] = bpf_find_map(__func__, objs[i], "test_map_id");
-- 
2.11.0
