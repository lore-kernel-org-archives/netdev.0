From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH 1/5] samples/bpf: xdp_tx_iptunnel make use of
 map_data[]
Date: Thu, 18 May 2017 17:41:33 +0200
Message-ID: <149512209298.14733.14668513619424960672.stgit@firesoul>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755614AbdERPlg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:41:36 -0400
In-Reply-To: <149512205297.14733.15729847433404265933.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to use a compile time constant MAX_IPTNL_ENTRIES
shared between the _user.c and _kern.c, when map_data[].def.max_entries
can tell us dynamically what the max_entries were of the ELF map that
the bpf loaded created.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/xdp_tx_iptunnel_common.h |    2 --
 samples/bpf/xdp_tx_iptunnel_kern.c   |    2 +-
 samples/bpf/xdp_tx_iptunnel_user.c   |   14 +++++++++-----
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/samples/bpf/xdp_tx_iptunnel_common.h b/samples/bpf/xdp_tx_iptunnel_common.h
index dd12cc35110f..b065699cacb5 100644
--- a/samples/bpf/xdp_tx_iptunnel_common.h
+++ b/samples/bpf/xdp_tx_iptunnel_common.h
@@ -9,8 +9,6 @@
 
 #include <linux/types.h>
 
-#define MAX_IPTNL_ENTRIES 256U
-
 struct vip {
 	union {
 		__u32 v6[4];
diff --git a/samples/bpf/xdp_tx_iptunnel_kern.c b/samples/bpf/xdp_tx_iptunnel_kern.c
index 0f4f6e8c8611..b19489eb3c22 100644
--- a/samples/bpf/xdp_tx_iptunnel_kern.c
+++ b/samples/bpf/xdp_tx_iptunnel_kern.c
@@ -30,7 +30,7 @@ struct bpf_map_def SEC("maps") vip2tnl = {
 	.type = BPF_MAP_TYPE_HASH,
 	.key_size = sizeof(struct vip),
 	.value_size = sizeof(struct iptnl_info),
-	.max_entries = MAX_IPTNL_ENTRIES,
+	.max_entries = 256,
 };
 
 static __always_inline void count_tx(u32 protocol)
diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
index 92b8bde9337c..0500a5cc75c4 100644
--- a/samples/bpf/xdp_tx_iptunnel_user.c
+++ b/samples/bpf/xdp_tx_iptunnel_user.c
@@ -123,11 +123,6 @@ static int parse_ports(const char *port_str, int *min_port, int *max_port)
 		return 1;
 	}
 
-	if (tmp_max_port - tmp_min_port + 1 > MAX_IPTNL_ENTRIES) {
-		fprintf(stderr, "Port range (%s) is larger than %u\n",
-			port_str, MAX_IPTNL_ENTRIES);
-		return 1;
-	}
 	*min_port = tmp_min_port;
 	*max_port = tmp_max_port;
 
@@ -142,6 +137,7 @@ int main(int argc, char **argv)
 	int min_port = 0, max_port = 0;
 	struct iptnl_info tnl = {};
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	unsigned int entries, max_entries;
 	struct vip vip = {};
 	char filename[256];
 	int opt;
@@ -238,6 +234,14 @@ int main(int argc, char **argv)
 		return 1;
 	}
 
+	entries = max_port - min_port + 1;
+	max_entries = map_data[1].def.max_entries;
+	if (entries > max_entries) {
+		fprintf(stderr, "Req port entries (%u) is larger than max %u\n",
+			entries, max_entries);
+		return 1;
+	}
+
 	signal(SIGINT, int_exit);
 
 	while (min_port <= max_port) {
