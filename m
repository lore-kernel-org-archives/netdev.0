From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/16] mm: Account for the number of times direct reclaimers get throttled
Date: Mon, 16 Apr 2012 13:17:03 +0100
Message-ID: <1334578624-23257-17-git-send-email-mgorman@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric B Munson <emunson@mgebm.net>,
	Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under significant pressure when writing back to network-backed storage,
direct reclaimers may get throttled. This is expected to be a
short-lived event and the processes get woken up again but processes do
get stalled. This patch counts how many times such stalling occurs. It's
up to the administrator whether to reduce these stalls by increasing
min_free_kbytes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h |    1 +
 mm/vmscan.c                   |    3 +++
 mm/vmstat.c                   |    1 +
 3 files changed, 5 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 03b90cdc..652e5f3 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -29,6 +29,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGSTEAL),
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
+		PGSCAN_DIRECT_THROTTLE,
 #ifdef CONFIG_NUMA
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fdb63db..ff2322e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2480,6 +2480,9 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 	if (pfmemalloc_watermark_ok(pgdat))
 		return;
 
+	/* Account for the throttling */
+	count_vm_event(PGSCAN_DIRECT_THROTTLE);
+
 	/*
 	 * If the caller cannot enter the filesystem, it's possible that it
 	 * is processing a journal transaction. In this case, it is not safe
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..0fff13d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -741,6 +741,7 @@ const char * const vmstat_text[] = {
 	TEXTS_FOR_ZONES("pgsteal")
 	TEXTS_FOR_ZONES("pgscan_kswapd")
 	TEXTS_FOR_ZONES("pgscan_direct")
+	"pgscan_direct_throttle",
 
 #ifdef CONFIG_NUMA
 	"zone_reclaim_failed",
-- 
1.7.9.2
