From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH net-next 3/3] bpf: make xdp sample variable names more meaningful
Date: Wed, 20 Jul 2016 17:22:35 -0700
Message-ID: <1469060555-20250-4-git-send-email-bblanco@plumgrid.com>
References: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34676 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbcGUAXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 20:23:09 -0400
Received: by mail-pa0-f47.google.com with SMTP id fi15so22971347pac.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 17:23:09 -0700 (PDT)
In-Reply-To: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The naming choice of index is not terribly descriptive, and dropcnt is
in fact incorrect for xdp2. Pick better names for these: ipproto and
rxcnt.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 samples/bpf/xdp1_kern.c | 12 ++++++------
 samples/bpf/xdp2_kern.c | 14 +++++++-------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/samples/bpf/xdp1_kern.c b/samples/bpf/xdp1_kern.c
index e7dd8ac..2197421 100644
--- a/samples/bpf/xdp1_kern.c
+++ b/samples/bpf/xdp1_kern.c
@@ -14,7 +14,7 @@
 #include <linux/ipv6.h>
 #include "bpf_helpers.h"
 
-struct bpf_map_def SEC("maps") dropcnt = {
+struct bpf_map_def SEC("maps") rxcnt = {
 	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
 	.key_size = sizeof(u32),
 	.value_size = sizeof(long),
@@ -49,7 +49,7 @@ int xdp_prog1(struct xdp_md *ctx)
 	long *value;
 	u16 h_proto;
 	u64 nh_off;
-	u32 index;
+	u32 ipproto;
 
 	nh_off = sizeof(*eth);
 	if (data + nh_off > data_end)
@@ -77,13 +77,13 @@ int xdp_prog1(struct xdp_md *ctx)
 	}
 
 	if (h_proto == htons(ETH_P_IP))
-		index = parse_ipv4(data, nh_off, data_end);
+		ipproto = parse_ipv4(data, nh_off, data_end);
 	else if (h_proto == htons(ETH_P_IPV6))
-		index = parse_ipv6(data, nh_off, data_end);
+		ipproto = parse_ipv6(data, nh_off, data_end);
 	else
-		index = 0;
+		ipproto = 0;
 
-	value = bpf_map_lookup_elem(&dropcnt, &index);
+	value = bpf_map_lookup_elem(&rxcnt, &ipproto);
 	if (value)
 		*value += 1;
 
diff --git a/samples/bpf/xdp2_kern.c b/samples/bpf/xdp2_kern.c
index 38fe7e1..e012888 100644
--- a/samples/bpf/xdp2_kern.c
+++ b/samples/bpf/xdp2_kern.c
@@ -14,7 +14,7 @@
 #include <linux/ipv6.h>
 #include "bpf_helpers.h"
 
-struct bpf_map_def SEC("maps") dropcnt = {
+struct bpf_map_def SEC("maps") rxcnt = {
 	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
 	.key_size = sizeof(u32),
 	.value_size = sizeof(long),
@@ -65,7 +65,7 @@ int xdp_prog1(struct xdp_md *ctx)
 	long *value;
 	u16 h_proto;
 	u64 nh_off;
-	u32 index;
+	u32 ipproto;
 
 	nh_off = sizeof(*eth);
 	if (data + nh_off > data_end)
@@ -93,17 +93,17 @@ int xdp_prog1(struct xdp_md *ctx)
 	}
 
 	if (h_proto == htons(ETH_P_IP))
-		index = parse_ipv4(data, nh_off, data_end);
+		ipproto = parse_ipv4(data, nh_off, data_end);
 	else if (h_proto == htons(ETH_P_IPV6))
-		index = parse_ipv6(data, nh_off, data_end);
+		ipproto = parse_ipv6(data, nh_off, data_end);
 	else
-		index = 0;
+		ipproto = 0;
 
-	value = bpf_map_lookup_elem(&dropcnt, &index);
+	value = bpf_map_lookup_elem(&rxcnt, &ipproto);
 	if (value)
 		*value += 1;
 
-	if (index == 17) {
+	if (ipproto == IPPROTO_UDP) {
 		swap_src_dst_mac(data);
 		rc = XDP_TX;
 	}
-- 
2.8.2
