From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 6/6] samples/bpf: update tracex[23] examples to use per-cpu maps
Date: Mon, 1 Feb 2016 22:39:58 -0800
Message-ID: <1454395198-1796236-7-git-send-email-ast@fb.com>
References: <1454395198-1796236-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Martin KaFai Lau <kafai@fb.com>, Ming Lei <tom.leiming@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:16737 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752419AbcBBGkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 01:40:03 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u126b9CW006980
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2016 22:40:03 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 20rsvbkkew-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 22:40:03 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 c86d2d4cc97711e5837124be05956610-99f42b0 for <netdev@vger.kernel.org>;	Mon,
 01 Feb 2016 22:40:00 -0800
In-Reply-To: <1454395198-1796236-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/tracex2_kern.c |  2 +-
 samples/bpf/tracex2_user.c |  7 ++++++-
 samples/bpf/tracex3_kern.c |  8 ++++----
 samples/bpf/tracex3_user.c | 21 ++++++++++++++-------
 4 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/samples/bpf/tracex2_kern.c b/samples/bpf/tracex2_kern.c
index b32367cfbff4..09c1adc27d42 100644
--- a/samples/bpf/tracex2_kern.c
+++ b/samples/bpf/tracex2_kern.c
@@ -70,7 +70,7 @@ struct hist_key {
 };
 
 struct bpf_map_def SEC("maps") my_hist_map = {
-	.type = BPF_MAP_TYPE_HASH,
+	.type = BPF_MAP_TYPE_PERCPU_HASH,
 	.key_size = sizeof(struct hist_key),
 	.value_size = sizeof(long),
 	.max_entries = 1024,
diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
index cd0241c1447a..ab5b19e68acf 100644
--- a/samples/bpf/tracex2_user.c
+++ b/samples/bpf/tracex2_user.c
@@ -37,6 +37,8 @@ struct hist_key {
 static void print_hist_for_pid(int fd, void *task)
 {
 	struct hist_key key = {}, next_key;
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	long values[nr_cpus];
 	char starstr[MAX_STARS];
 	long value;
 	long data[MAX_INDEX] = {};
@@ -49,7 +51,10 @@ static void print_hist_for_pid(int fd, void *task)
 			key = next_key;
 			continue;
 		}
-		bpf_lookup_elem(fd, &next_key, &value);
+		bpf_lookup_elem(fd, &next_key, values);
+		value = 0;
+		for (i = 0; i < nr_cpus; i++)
+			value += values[i];
 		ind = next_key.index;
 		data[ind] = value;
 		if (value && ind > max_ind)
diff --git a/samples/bpf/tracex3_kern.c b/samples/bpf/tracex3_kern.c
index bf337fbb0947..9974c3d7c18b 100644
--- a/samples/bpf/tracex3_kern.c
+++ b/samples/bpf/tracex3_kern.c
@@ -20,7 +20,7 @@ struct bpf_map_def SEC("maps") my_map = {
 /* kprobe is NOT a stable ABI. If kernel internals change this bpf+kprobe
  * example will no longer be meaningful
  */
-SEC("kprobe/blk_mq_start_request")
+SEC("kprobe/blk_start_request")
 int bpf_prog1(struct pt_regs *ctx)
 {
 	long rq = PT_REGS_PARM1(ctx);
@@ -42,13 +42,13 @@ static unsigned int log2l(unsigned long long n)
 #define SLOTS 100
 
 struct bpf_map_def SEC("maps") lat_map = {
-	.type = BPF_MAP_TYPE_ARRAY,
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
 	.key_size = sizeof(u32),
 	.value_size = sizeof(u64),
 	.max_entries = SLOTS,
 };
 
-SEC("kprobe/blk_update_request")
+SEC("kprobe/blk_account_io_completion")
 int bpf_prog2(struct pt_regs *ctx)
 {
 	long rq = PT_REGS_PARM1(ctx);
@@ -81,7 +81,7 @@ int bpf_prog2(struct pt_regs *ctx)
 
 	value = bpf_map_lookup_elem(&lat_map, &index);
 	if (value)
-		__sync_fetch_and_add((long *)value, 1);
+		*value += 1;
 
 	return 0;
 }
diff --git a/samples/bpf/tracex3_user.c b/samples/bpf/tracex3_user.c
index 0aaa933ab938..48716f7f0d8b 100644
--- a/samples/bpf/tracex3_user.c
+++ b/samples/bpf/tracex3_user.c
@@ -20,11 +20,13 @@
 
 static void clear_stats(int fd)
 {
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	__u64 values[nr_cpus];
 	__u32 key;
-	__u64 value = 0;
 
+	memset(values, 0, sizeof(values));
 	for (key = 0; key < SLOTS; key++)
-		bpf_update_elem(fd, &key, &value, BPF_ANY);
+		bpf_update_elem(fd, &key, values, BPF_ANY);
 }
 
 const char *color[] = {
@@ -75,15 +77,20 @@ static void print_banner(void)
 
 static void print_hist(int fd)
 {
-	__u32 key;
-	__u64 value;
-	__u64 cnt[SLOTS];
-	__u64 max_cnt = 0;
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
 	__u64 total_events = 0;
+	long values[nr_cpus];
+	__u64 max_cnt = 0;
+	__u64 cnt[SLOTS];
+	__u64 value;
+	__u32 key;
+	int i;
 
 	for (key = 0; key < SLOTS; key++) {
+		bpf_lookup_elem(fd, &key, values);
 		value = 0;
-		bpf_lookup_elem(fd, &key, &value);
+		for (i = 0; i < nr_cpus; i++)
+			value += values[i];
 		cnt[key] = value;
 		total_events += value;
 		if (value > max_cnt)
-- 
2.4.6
