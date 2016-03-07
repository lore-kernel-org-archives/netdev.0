From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 5/9] samples/bpf: move ksym_search() into library
Date: Sun, 6 Mar 2016 17:58:33 -0800
Message-ID: <1457315917-1970307-6-git-send-email-ast@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:20567 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938AbcCGB6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 20:58:42 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u271sXse014721
	for <netdev@vger.kernel.org>; Sun, 6 Mar 2016 17:58:42 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21g18wm9at-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 17:58:42 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 1c7c0d36e40811e584c324be05956610-e1ae6270 for <netdev@vger.kernel.org>;	Sun,
 06 Mar 2016 17:58:39 -0800
In-Reply-To: <1457315917-1970307-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

move ksym search from offwaketime into library to be reused
in other tests

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/bpf_load.c         | 62 ++++++++++++++++++++++++++++++++++++++
 samples/bpf/bpf_load.h         |  6 ++++
 samples/bpf/offwaketime_user.c | 67 +-----------------------------------------
 3 files changed, 69 insertions(+), 66 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 816bca5760a0..d16864293c00 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -346,3 +346,65 @@ void read_trace_pipe(void)
 		}
 	}
 }
+
+#define MAX_SYMS 300000
+static struct ksym syms[MAX_SYMS];
+static int sym_cnt;
+
+static int ksym_cmp(const void *p1, const void *p2)
+{
+	return ((struct ksym *)p1)->addr - ((struct ksym *)p2)->addr;
+}
+
+int load_kallsyms(void)
+{
+	FILE *f = fopen("/proc/kallsyms", "r");
+	char func[256], buf[256];
+	char symbol;
+	void *addr;
+	int i = 0;
+
+	if (!f)
+		return -ENOENT;
+
+	while (!feof(f)) {
+		if (!fgets(buf, sizeof(buf), f))
+			break;
+		if (sscanf(buf, "%p %c %s", &addr, &symbol, func) != 3)
+			break;
+		if (!addr)
+			continue;
+		syms[i].addr = (long) addr;
+		syms[i].name = strdup(func);
+		i++;
+	}
+	sym_cnt = i;
+	qsort(syms, sym_cnt, sizeof(struct ksym), ksym_cmp);
+	return 0;
+}
+
+struct ksym *ksym_search(long key)
+{
+	int start = 0, end = sym_cnt;
+	int result;
+
+	while (start < end) {
+		size_t mid = start + (end - start) / 2;
+
+		result = key - syms[mid].addr;
+		if (result < 0)
+			end = mid;
+		else if (result > 0)
+			start = mid + 1;
+		else
+			return &syms[mid];
+	}
+
+	if (start >= 1 && syms[start - 1].addr < key &&
+	    key < syms[start].addr)
+		/* valid ksym */
+		return &syms[start - 1];
+
+	/* out of range. return _stext */
+	return &syms[0];
+}
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index cbd7c2b532b9..dfa57fe65c8e 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -23,5 +23,11 @@ extern int event_fd[MAX_PROGS];
 int load_bpf_file(char *path);
 
 void read_trace_pipe(void);
+struct ksym {
+	long addr;
+	char *name;
+};
 
+int load_kallsyms(void);
+struct ksym *ksym_search(long key);
 #endif
diff --git a/samples/bpf/offwaketime_user.c b/samples/bpf/offwaketime_user.c
index 17cf3024e22c..6f002a9c24fa 100644
--- a/samples/bpf/offwaketime_user.c
+++ b/samples/bpf/offwaketime_user.c
@@ -18,80 +18,15 @@
 #include "libbpf.h"
 #include "bpf_load.h"
 
-#define MAX_SYMS 300000
 #define PRINT_RAW_ADDR 0
 
-static struct ksym {
-	long addr;
-	char *name;
-} syms[MAX_SYMS];
-static int sym_cnt;
-
-static int ksym_cmp(const void *p1, const void *p2)
-{
-	return ((struct ksym *)p1)->addr - ((struct ksym *)p2)->addr;
-}
-
-static int load_kallsyms(void)
-{
-	FILE *f = fopen("/proc/kallsyms", "r");
-	char func[256], buf[256];
-	char symbol;
-	void *addr;
-	int i = 0;
-
-	if (!f)
-		return -ENOENT;
-
-	while (!feof(f)) {
-		if (!fgets(buf, sizeof(buf), f))
-			break;
-		if (sscanf(buf, "%p %c %s", &addr, &symbol, func) != 3)
-			break;
-		if (!addr)
-			continue;
-		syms[i].addr = (long) addr;
-		syms[i].name = strdup(func);
-		i++;
-	}
-	sym_cnt = i;
-	qsort(syms, sym_cnt, sizeof(struct ksym), ksym_cmp);
-	return 0;
-}
-
-static void *search(long key)
-{
-	int start = 0, end = sym_cnt;
-	int result;
-
-	while (start < end) {
-		size_t mid = start + (end - start) / 2;
-
-		result = key - syms[mid].addr;
-		if (result < 0)
-			end = mid;
-		else if (result > 0)
-			start = mid + 1;
-		else
-			return &syms[mid];
-	}
-
-	if (start >= 1 && syms[start - 1].addr < key &&
-	    key < syms[start].addr)
-		/* valid ksym */
-		return &syms[start - 1];
-
-	/* out of range. return _stext */
-	return &syms[0];
-}
-
 static void print_ksym(__u64 addr)
 {
 	struct ksym *sym;
 
 	if (!addr)
 		return;
-	sym = search(addr);
+	sym = ksym_search(addr);
 	if (PRINT_RAW_ADDR)
 		printf("%s/%llx;", sym->name, addr);
 	else
-- 
2.6.5
