From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 2/2] bpf: fix mnt path when from env
Date: Fri, 21 Jul 2017 21:13:07 +0200
Message-ID: <0e649464a0642d80b27fcee82d49d4086311d450.1500663605.git.daniel@iogearbox.net>
References: <cover.1500663605.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58991 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754670AbdGUTNX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 15:13:23 -0400
In-Reply-To: <cover.1500663605.git.daniel@iogearbox.net>
In-Reply-To: <cover.1500663605.git.daniel@iogearbox.net>
References: <cover.1500663605.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bpf fs mount path is from env, behavior is currently broken as
we continue to search in default paths, thus fix this up.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 55 +++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 45 insertions(+), 10 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 4f6421a..851742c 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -485,6 +485,24 @@ static int bpf_mnt_fs(const char *target)
 	return 0;
 }
 
+static int bpf_mnt_check_target(const char *target)
+{
+	struct stat sb = {};
+	int ret;
+
+	ret = stat(target, &sb);
+	if (ret) {
+		ret = mkdir(target, S_IRWXU);
+		if (ret) {
+			fprintf(stderr, "mkdir %s failed: %s\n", target,
+				strerror(errno));
+			return ret;
+		}
+	}
+
+	return 0;
+}
+
 static int bpf_valid_mntpt(const char *mnt, unsigned long magic)
 {
 	struct statfs st_fs;
@@ -497,6 +515,21 @@ static int bpf_valid_mntpt(const char *mnt, unsigned long magic)
 	return 0;
 }
 
+static const char *bpf_find_mntpt_single(unsigned long magic, char *mnt,
+					 int len, const char *mntpt)
+{
+	int ret;
+
+	ret = bpf_valid_mntpt(mntpt, magic);
+	if (!ret) {
+		strncpy(mnt, mntpt, len - 1);
+		mnt[len - 1] = 0;
+		return mnt;
+	}
+
+	return NULL;
+}
+
 static const char *bpf_find_mntpt(const char *fstype, unsigned long magic,
 				  char *mnt, int len,
 				  const char * const *known_mnts)
@@ -508,11 +541,8 @@ static const char *bpf_find_mntpt(const char *fstype, unsigned long magic,
 	if (known_mnts) {
 		ptr = known_mnts;
 		while (*ptr) {
-			if (bpf_valid_mntpt(*ptr, magic) == 0) {
-				strncpy(mnt, *ptr, len - 1);
-				mnt[len - 1] = 0;
+			if (bpf_find_mntpt_single(magic, mnt, len, *ptr))
 				return mnt;
-			}
 			ptr++;
 		}
 	}
@@ -690,6 +720,7 @@ static const char *bpf_get_work_dir(enum bpf_prog_type type)
 	static char bpf_wrk_dir[PATH_MAX];
 	static const char *mnt;
 	static bool bpf_mnt_cached;
+	const char *mnt_env = getenv(BPF_ENV_MNT);
 	static const char * const bpf_known_mnts[] = {
 		BPF_DIR_MNT,
 		"/bpf",
@@ -708,13 +739,17 @@ static const char *bpf_get_work_dir(enum bpf_prog_type type)
 		return out;
 	}
 
-	mnt = bpf_find_mntpt("bpf", BPF_FS_MAGIC, bpf_tmp, sizeof(bpf_tmp),
-			     bpf_known_mnts);
+	if (mnt_env)
+		mnt = bpf_find_mntpt_single(BPF_FS_MAGIC, bpf_tmp,
+					    sizeof(bpf_tmp), mnt_env);
+	else
+		mnt = bpf_find_mntpt("bpf", BPF_FS_MAGIC, bpf_tmp,
+				     sizeof(bpf_tmp), bpf_known_mnts);
 	if (!mnt) {
-		mnt = getenv(BPF_ENV_MNT);
-		if (!mnt)
-			mnt = BPF_DIR_MNT;
-		ret = bpf_mnt_fs(mnt);
+		mnt = mnt_env ? : BPF_DIR_MNT;
+		ret = bpf_mnt_check_target(mnt);
+		if (!ret)
+			ret = bpf_mnt_fs(mnt);
 		if (ret) {
 			mnt = NULL;
 			goto out;
-- 
1.9.3
