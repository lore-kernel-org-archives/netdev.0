From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] mm: memcontrol: only manage socket pressure for CONFIG_INET
Date: Wed, 09 Dec 2015 17:32:16 +0100
Message-ID: <7343206.sFybcLLUN2@wuerfel>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org> <2564892.qO1q7YJ6Nb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2564892.qO1q7YJ6Nb@wuerfel>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When IPV4 support is disabled, the memcg->socket_pressure field is
not defined and we get a build error from the vmpressure code:

mm/vmpressure.c: In function 'vmpressure':
mm/vmpressure.c:287:9: error: 'struct mem_cgroup' has no member named 'socket_pressure'
    memcg->socket_pressure = jiffies + HZ;
mm/built-in.o: In function `mem_cgroup_css_free':
:(.text+0x1c03a): undefined reference to `tcp_destroy_cgroup'
mm/built-in.o: In function `mem_cgroup_css_online':
:(.text+0x1c20e): undefined reference to `tcp_init_cgroup'

This puts the code causing this in the same #ifdef that guards the
struct member and the TCP implementation.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Fixes: 20cc40e66c42 ("mm: memcontrol: hook up vmpressure to socket pressure")

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6faea81e66d7..73cd572167bb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4220,13 +4220,13 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (ret)
 		return ret;
 
+#ifdef CONFIG_INET
 #ifdef CONFIG_MEMCG_LEGACY_KMEM
 	ret = tcp_init_cgroup(memcg);
 	if (ret)
 		return ret;
 #endif
 
-#ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_inc(&memcg_sockets_enabled_key);
 #endif
@@ -4276,7 +4276,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 
 	memcg_free_kmem(memcg);
 
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
+#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	tcp_destroy_cgroup(memcg);
 #endif
 
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 506f03e4be47..8cdeebe48848 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -275,6 +275,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 
 		level = vmpressure_calc_level(scanned, reclaimed);
 
+#ifdef CONFIG_INET
 		if (level > VMPRESSURE_LOW) {
 			/*
 			 * Let the socket buffer allocator know that
@@ -286,6 +287,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 			 */
 			memcg->socket_pressure = jiffies + HZ;
 		}
+#endif
 	}
 }
 
