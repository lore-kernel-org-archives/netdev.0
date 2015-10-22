From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 7/8] mm: vmscan: report vmpressure at the level of reclaim activity
Date: Thu, 22 Oct 2015 00:21:35 -0400
Message-ID: <1445487696-21545-8-git-send-email-hannes@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vmpressure metric is based on reclaim efficiency, which in turn is
an attribute of the LRU. However, vmpressure events are currently
reported at the source of pressure rather than at the reclaim level.

Switch the reporting to the reclaim level to allow finer-grained
analysis of which memcg is having trouble reclaiming its pages.

As far as memory.pressure_level interface semantics go, events are
escalated up the hierarchy until a listener is found, so this won't
affect existing users that listen at higher levels.

This also prepares vmpressure for hooking it up to the networking
stack's memory pressure code.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ecc2125..50630c8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2404,6 +2404,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
 			unsigned long lru_pages;
+			unsigned long reclaimed;
 			unsigned long scanned;
 			struct lruvec *lruvec;
 			int swappiness;
@@ -2416,6 +2417,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
+			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
 
 			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
@@ -2437,6 +2439,10 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 				}
 			}
 
+			vmpressure(sc->gfp_mask, memcg,
+				   sc->nr_scanned - scanned,
+				   sc->nr_reclaimed - reclaimed);
+
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
 			 * cgroups to fulfill the overall scan target for the
@@ -2454,10 +2460,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
-			   sc->nr_scanned - nr_scanned,
-			   sc->nr_reclaimed - nr_reclaimed);
-
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
-- 
2.6.1
