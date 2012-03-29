From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 3/3] memcg/tcp: ignore tcp usage before accounting
 started
Date: Thu, 29 Mar 2012 16:10:39 +0900
Message-ID: <4F740AEF.7090900@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer@parallels.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:60264 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583Ab2C2HMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 03:12:22 -0400
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 04E5C3EE0BC
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:12:22 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF0F245DEA6
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:12:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDE6045DE7E
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:12:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF059E38001
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:12:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 651E3E38004
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:12:21 +0900 (JST)
In-Reply-To: <4F7408B7.9090706@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp memcontrol starts accouting after res->limit is set. So, if a sockets
starts before setting res->limit, there are already used resource.
After setting res->limit, the resource (already used) will be uncharged and
make res_counter below 0 because they are not charged. This causes warning.

This patch fixes that by adding res_counter_uncharge_nowarn().
(*) We cannot avoid this while we have 'account start' switch.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/res_counter.h |    2 ++
 include/net/sock.h          |    3 ++-
 kernel/res_counter.c        |   18 ++++++++++++++++++
 3 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index da81af0..e081948 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -134,6 +134,8 @@ int __must_check res_counter_charge_nofail(struct res_counter *counter,
 
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
 void res_counter_uncharge(struct res_counter *counter, unsigned long val);
+void res_counter_uncharge_nowarn(struct res_counter *counter,
+				unsigned long val);
 
 /**
  * res_counter_margin - calculate chargeable space of a counter
diff --git a/include/net/sock.h b/include/net/sock.h
index a6ba1f8..a1b3f4802 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1048,7 +1048,8 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
 					      unsigned long amt)
 {
-	res_counter_uncharge(prot->memory_allocated, amt << PAGE_SHIFT);
+	res_counter_uncharge_nowarn(prot->memory_allocated,
+				amt << PAGE_SHIFT);
 }
 
 static inline u64 memcg_memory_allocated_read(struct cg_proto *prot)
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index d508363..2bb01ac 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -113,6 +113,24 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	local_irq_restore(flags);
 }
 
+void res_counter_uncharge_nowarn(struct res_counter *counter,
+					unsigned long val)
+{
+	struct res_counter *c;
+	unsigned long flags;
+
+	local_irq_save(flags);
+
+	for (c = counter; c != NULL; c = c->parent) {
+		spin_lock(&c->lock);
+		if (c->usage < val)
+			val = c->usage;
+		res_counter_uncharge_locked(c, val);
+		spin_unlock(&c->lock);
+	}
+	local_irq_restore(flags);
+}
+
 
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
-- 
1.7.4.1
