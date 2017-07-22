From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master v2 2/2] bpf: fix mnt path when from env
Date: Sun, 23 Jul 2017 01:22:19 +0200
Message-ID: <1500765739-10681-3-git-send-email-daniel@iogearbox.net>
References: <1500765739-10681-1-git-send-email-daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43146 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbdGVXW3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 19:22:29 -0400
In-Reply-To: <1500765739-10681-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bpf fs mount path is from env, behavior is currently broken as
we continue to search in default paths, thus fix this up.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 55 +++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 45 insertions(+), 10 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 5d9f0a5..e7a4d12 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -459,6 +459,24 @@ static int bpf_mnt_fs(const char *target)
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
@@ -471,6 +489,21 @@ static int bpf_valid_mntpt(const char *mnt, unsigned long magic)
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
@@ -482,11 +515,8 @@ static const char *bpf_find_mntpt(const char *fstype, unsigned long magic,
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
@@ -664,6 +694,7 @@ static const char *bpf_get_work_dir(enum bpf_prog_type type)
 	static char bpf_wrk_dir[PATH_MAX];
 	static const char *mnt;
 	static bool bpf_mnt_cached;
+	const char *mnt_env = getenv(BPF_ENV_MNT);
 	static const char * const bpf_known_mnts[] = {
 		BPF_DIR_MNT,
 		"/bpf",
@@ -682,13 +713,17 @@ static const char *bpf_get_work_dir(enum bpf_prog_type type)
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
2.9.3
