From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 7/9] sample/bpf: introduces helpers for percpu array example
Date: Mon, 11 Jan 2016 23:56:59 +0800
Message-ID: <1452527821-12276-8-git-send-email-tom.leiming@gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patches introduces helpers for using percpu array.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 samples/bpf/bpf_helpers.h |  5 +++++
 samples/bpf/libbpf.c      | 42 ++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/libbpf.h      |  5 +++++
 3 files changed, 52 insertions(+)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 7ad19e1..9996f38 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -39,6 +39,11 @@ static int (*bpf_redirect)(int ifindex, int flags) =
 	(void *) BPF_FUNC_redirect;
 static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data, int size) =
 	(void *) BPF_FUNC_perf_event_output;
+static void *(*bpf_map_lookup_elem_percpu)(void *map, void *key, unsigned cpu) =
+	(void *) BPF_FUNC_map_lookup_elem_percpu;
+static int (*bpf_map_update_elem_percpu)(void *map, void *key, void *value,
+				  unsigned long long flags, unsigned cpu) =
+	(void *) BPF_FUNC_map_update_elem_percpu;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 65a8d48..2a240c6 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -43,6 +43,20 @@ int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
 	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
 
+int bpf_update_elem_percpu(int fd, void *key, void *value,
+			   unsigned long long flags, unsigned cpu)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.value = ptr_to_u64(value),
+		.flags = flags,
+		.cpu = cpu
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM_PERCPU, &attr, sizeof(attr));
+}
+
 int bpf_lookup_elem(int fd, void *key, void *value)
 {
 	union bpf_attr attr = {
@@ -54,6 +68,34 @@ int bpf_lookup_elem(int fd, void *key, void *value)
 	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
 }
 
+int bpf_lookup_elem_percpu(int fd, void *key, void *value, unsigned cpu)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.value = ptr_to_u64(value),
+		.cpu = cpu,
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM_PERCPU, &attr, sizeof(attr));
+}
+
+int bpf_lookup_elem_allcpu(int fd, void *key, void *value_percpu, void *value,
+			   int (*handle_one_cpu)(unsigned, void *, void *))
+{
+	unsigned cpu;
+	int ret;
+
+	for (cpu = 0; cpu < sysconf(_SC_NPROCESSORS_CONF); cpu++) {
+		ret = bpf_lookup_elem_percpu(fd, key, value_percpu, cpu);
+		if (!ret)
+			ret = handle_one_cpu(cpu, value_percpu, value);
+		if  (ret)
+			return ret;
+	}
+	return 0;
+}
+
 int bpf_delete_elem(int fd, void *key)
 {
 	union bpf_attr attr = {
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 014aacf..e94484d 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -8,6 +8,11 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries);
 int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
 int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_update_elem_percpu(int fd, void *key, void *value,
+			   unsigned long long flags, unsigned cpu);
+int bpf_lookup_elem_percpu(int fd, void *key, void *value, unsigned cpu);
+int bpf_lookup_elem_allcpu(int fd, void *key, void *value_percpu, void *value,
+			   int (*handle_one_cpu)(unsigned, void *, void *));
 int bpf_delete_elem(int fd, void *key);
 int bpf_get_next_key(int fd, void *key, void *next_key);
 
-- 
1.9.1
