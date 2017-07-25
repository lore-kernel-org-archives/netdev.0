From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] bpf: don't zero out the info struct in bpf_obj_get_info_by_fd()
Date: Tue, 25 Jul 2017 15:16:12 -0700
Message-ID: <20170725221612.6937-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        kafai@fb.com, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36748 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdGYWQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 18:16:38 -0400
Received: by mail-pg0-f48.google.com with SMTP id 125so75647177pgi.3
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 15:16:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The buffer passed to bpf_obj_get_info_by_fd() should be initialized
to zeros.  Kernel will enforce that to guarantee we can safely extend
info structures in the future.

Making the bpf_obj_get_info_by_fd() call in libbpf perform the zeroing
is problematic, however, since some members of the info structures
may need to be initialized by the callers (for instance pointers
to buffers to which kernel is to dump translated and jited images).

Remove the zeroing and fix up the in-tree callers before any kernel
has been released with this code.

As Daniel points out this seems to be the intended operation anyway,
since commit 95b9afd3987f ("bpf: Test for bpf ID") is itself setting
the buffer pointers before calling bpf_obj_get_info_by_fd().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
I have a small patch to add checking if kernel actually populated
the instruction dumps which I will post after this ends up in net-next.

 tools/lib/bpf/bpf.c                      | 1 -
 tools/testing/selftests/bpf/test_progs.c | 8 ++++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 412a7c82995a..256f571f2ab5 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -314,7 +314,6 @@ int bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len)
 	int err;
 
 	bzero(&attr, sizeof(attr));
-	bzero(info, *info_len);
 	attr.info.bpf_fd = prog_fd;
 	attr.info.info_len = *info_len;
 	attr.info.info = ptr_to_u64(info);
diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
index 5855cd3d3d45..1f7dd35551b9 100644
--- a/tools/testing/selftests/bpf/test_progs.c
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -340,6 +340,7 @@ static void test_bpf_obj_id(void)
 
 		/* Check getting prog info */
 		info_len = sizeof(struct bpf_prog_info) * 2;
+		bzero(&prog_infos[i], info_len);
 		prog_infos[i].jited_prog_insns = ptr_to_u64(jited_insns);
 		prog_infos[i].jited_prog_len = sizeof(jited_insns);
 		prog_infos[i].xlated_prog_insns = ptr_to_u64(xlated_insns);
@@ -369,6 +370,7 @@ static void test_bpf_obj_id(void)
 
 		/* Check getting map info */
 		info_len = sizeof(struct bpf_map_info) * 2;
+		bzero(&map_infos[i], info_len);
 		err = bpf_obj_get_info_by_fd(map_fds[i], &map_infos[i],
 					     &info_len);
 		if (CHECK(err ||
@@ -394,7 +396,7 @@ static void test_bpf_obj_id(void)
 	nr_id_found = 0;
 	next_id = 0;
 	while (!bpf_prog_get_next_id(next_id, &next_id)) {
-		struct bpf_prog_info prog_info;
+		struct bpf_prog_info prog_info = {};
 		int prog_fd;
 
 		info_len = sizeof(prog_info);
@@ -418,6 +420,8 @@ static void test_bpf_obj_id(void)
 		nr_id_found++;
 
 		err = bpf_obj_get_info_by_fd(prog_fd, &prog_info, &info_len);
+		prog_infos[i].jited_prog_insns = 0;
+		prog_infos[i].xlated_prog_insns = 0;
 		CHECK(err || info_len != sizeof(struct bpf_prog_info) ||
 		      memcmp(&prog_info, &prog_infos[i], info_len),
 		      "get-prog-info(next_id->fd)",
@@ -436,7 +440,7 @@ static void test_bpf_obj_id(void)
 	nr_id_found = 0;
 	next_id = 0;
 	while (!bpf_map_get_next_id(next_id, &next_id)) {
-		struct bpf_map_info map_info;
+		struct bpf_map_info map_info = {};
 		int map_fd;
 
 		info_len = sizeof(map_info);
-- 
2.11.0
