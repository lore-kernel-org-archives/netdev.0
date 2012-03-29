From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/3] [BUGFIX] memcg/tcp : fix to see use_hierarchy in tcp
 memcontrol cgroup
Date: Thu, 29 Mar 2012 16:03:55 +0900
Message-ID: <4F74095B.70105@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer@parallels.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:43802 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758027Ab2C2HFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 03:05:38 -0400
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6C5153EE0BD
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:05:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52D7245DEB2
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:05:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3758645DEA6
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:05:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 20EC9E38002
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:05:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5C13E38004
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:05:36 +0900 (JST)
In-Reply-To: <4F7408B7.9090706@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Now, tcp memory control cgroup ignores memcg's use_hierarchy value
and act as use_hierarchy=1 always. After this patch, tcp memcontrol will
work as memcg is designed.

Note:
   I know there is a discussion to remove use_hierarchy but this is BUG, now.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    3 +++
 mm/memcontrol.c            |    5 +++++
 net/ipv4/tcp_memcontrol.c  |    2 +-
 3 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f94efd2..e116b7c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -199,6 +199,9 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 bool mem_cgroup_bad_page_check(struct page *page);
 void mem_cgroup_print_bad_page(struct page *page);
 #endif
+
+bool mem_cgroup_use_hierarchy(struct mem_cgroup *memcg);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7d698df..467881f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -867,6 +867,11 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
+bool mem_cgroup_use_hierarchy(struct mem_cgroup *memcg)
+{
+	return memcg->use_hierarchy;
+}
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index e795272..32764a6 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -75,7 +75,7 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	tcp->tcp_memory_pressure = 0;
 
 	parent_cg = tcp_prot.proto_cgroup(parent);
-	if (parent_cg)
+	if (parent_cg && mem_cgroup_use_hierarchy(parent))
 		res_parent = parent_cg->memory_allocated;
 
 	res_counter_init(&tcp->tcp_memory_allocated, res_parent);
-- 
1.7.4.1
