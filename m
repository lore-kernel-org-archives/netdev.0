From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] bpf: cpumap micro-optimization in cpu_map_enqueue
Date: Wed, 01 Nov 2017 12:44:45 +0100
Message-ID: <150953668583.30172.5069550217700139382.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753734AbdKALot (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 07:44:49 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 379AA5F739
        for <netdev@vger.kernel.org>; Wed,  1 Nov 2017 11:44:49 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Discovered that the compiler laid-out asm code in suboptimal way
when studying perf report during benchmarking of cpumap. Help
the compiler by the marking unlikely code paths.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 kernel/bpf/cpumap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
index 86e29cbf7827..ce5b669003b2 100644
--- a/kernel/bpf/cpumap.c
+++ b/kernel/bpf/cpumap.c
@@ -208,7 +208,7 @@ static struct xdp_pkt *convert_to_xdp_pkt(struct xdp_buff *xdp)
 	headroom = xdp->data - xdp->data_hard_start;
 	metasize = xdp->data - xdp->data_meta;
 	metasize = metasize > 0 ? metasize : 0;
-	if ((headroom - metasize) < sizeof(*xdp_pkt))
+	if (unlikely((headroom - metasize) < sizeof(*xdp_pkt)))
 		return NULL;
 
 	/* Store info in top of packet */
@@ -656,7 +656,7 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
 	struct xdp_pkt *xdp_pkt;
 
 	xdp_pkt = convert_to_xdp_pkt(xdp);
-	if (!xdp_pkt)
+	if (unlikely(!xdp_pkt))
 		return -EOVERFLOW;
 
 	/* Info needed when constructing SKB on remote CPU */
