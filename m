From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/13] mm: Account for the number of times direct reclaimers get throttled
Date: Tue, 26 Apr 2011 08:36:54 +0100
Message-ID: <1303803414-5937-14-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mel Gorman <mgorman@suse.de>
To: Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303803414-5937-1-git-send-email-mgorman@suse.de>
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
 mm/vmscan.c                   |    1 +
 mm/vmstat.c                   |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

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
index 8b6da2b..e88138b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2154,6 +2154,7 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 		goto out;
 
 	/* Throttle */
+	count_vm_event(PGSCAN_DIRECT_THROTTLE);
 	do {
 		schedule();
 		finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a2b7344..5725387 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -911,6 +911,7 @@ const char * const vmstat_text[] = {
 	TEXTS_FOR_ZONES("pgsteal")
 	TEXTS_FOR_ZONES("pgscan_kswapd")
 	TEXTS_FOR_ZONES("pgscan_direct")
+	"pgscan_direct_throttle",
 
 #ifdef CONFIG_NUMA
 	"zone_reclaim_failed",
-- 
1.7.3.4
