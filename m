From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 8/9] sample/bpf: sockex1: user percpu array map
Date: Mon, 11 Jan 2016 23:57:00 +0800
Message-ID: <1452527821-12276-9-git-send-email-tom.leiming@gmail.com>
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

It is demonstrated the expensive atomic operations can
be removed in eBPF prog.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 samples/bpf/sockex1_kern.c |  7 ++++---
 samples/bpf/sockex1_user.c | 20 ++++++++++++++++----
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/samples/bpf/sockex1_kern.c b/samples/bpf/sockex1_kern.c
index ed18e9a..400518a 100644
--- a/samples/bpf/sockex1_kern.c
+++ b/samples/bpf/sockex1_kern.c
@@ -5,7 +5,7 @@
 #include "bpf_helpers.h"
 
 struct bpf_map_def SEC("maps") my_map = {
-	.type = BPF_MAP_TYPE_ARRAY,
+	.type = BPF_MAP_TYPE_ARRAY_PERCPU,
 	.key_size = sizeof(u32),
 	.value_size = sizeof(long),
 	.max_entries = 256,
@@ -16,13 +16,14 @@ int bpf_prog1(struct __sk_buff *skb)
 {
 	int index = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
 	long *value;
+	unsigned cpu = bpf_get_smp_processor_id();
 
 	if (skb->pkt_type != PACKET_OUTGOING)
 		return 0;
 
-	value = bpf_map_lookup_elem(&my_map, &index);
+	value = bpf_map_lookup_elem_percpu(&my_map, &index, cpu);
 	if (value)
-		__sync_fetch_and_add(value, skb->len);
+		*value += skb->len;
 
 	return 0;
 }
diff --git a/samples/bpf/sockex1_user.c b/samples/bpf/sockex1_user.c
index 678ce46..8572e81 100644
--- a/samples/bpf/sockex1_user.c
+++ b/samples/bpf/sockex1_user.c
@@ -6,6 +6,14 @@
 #include <unistd.h>
 #include <arpa/inet.h>
 
+static int handle_one_cpu(unsigned cpu, void *val_cpu, void *val)
+{
+	long long *cnt = val;
+
+	*cnt += *(long *)val_cpu;
+	return 0;
+}
+
 int main(int ac, char **argv)
 {
 	char filename[256];
@@ -28,17 +36,21 @@ int main(int ac, char **argv)
 	(void) f;
 
 	for (i = 0; i < 5; i++) {
-		long long tcp_cnt, udp_cnt, icmp_cnt;
+		long cnt_percpu;
+		long long tcp_cnt = 0, udp_cnt = 0, icmp_cnt = 0;
 		int key;
 
 		key = IPPROTO_TCP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &tcp_cnt) == 0);
+		assert(bpf_lookup_elem_allcpu(map_fd[0], &key,
+		       &cnt_percpu, &tcp_cnt, handle_one_cpu) == 0);
 
 		key = IPPROTO_UDP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &udp_cnt) == 0);
+		assert(bpf_lookup_elem_allcpu(map_fd[0], &key,
+		       &cnt_percpu, &udp_cnt, handle_one_cpu) == 0);
 
 		key = IPPROTO_ICMP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &icmp_cnt) == 0);
+		assert(bpf_lookup_elem_allcpu(map_fd[0], &key,
+		       &cnt_percpu, &icmp_cnt, handle_one_cpu) == 0);
 
 		printf("TCP %lld UDP %lld ICMP %lld bytes\n",
 		       tcp_cnt, udp_cnt, icmp_cnt);
-- 
1.9.1
