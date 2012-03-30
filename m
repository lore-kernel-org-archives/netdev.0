From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Fri, 30 Mar 2012 10:44:08 +0900
Message-ID: <4F750FE8.2030800@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:41118 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759658Ab2C3BqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 21:46:05 -0400
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 311363EE0B5
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 10:46:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1522545DE53
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 10:46:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3A0045DE4D
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 10:46:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E6785E08003
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 10:46:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 92068E08004
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 10:46:02 +0900 (JST)
In-Reply-To: <4F742983.1080402@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe what we can do before lsf/mm summit will be this (avoid warning.)
This patch is onto linus's git tree. Patch description is updated.

Thanks.
-Kame
==
>From 4ab80f84bbcb02a790342426c1de84aeb17fcbe9 Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 29 Mar 2012 14:59:04 +0900
Subject: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.

tcp memcontrol starts accouting after res->limit is set. So, if a sockets
starts before setting res->limit, there are already used resource.
At setting res->limit, accounting starts. The resource will be uncharged
and make res_counter below 0 because they are not charged. 
This causes warning.

==
kernel: ------------[ cut here ]----------
kernel: WARNING: at kernel/res_counter.c:96 res_counter_uncharge_locked+0x37/0x40()
 <snip>
kernel: Pid: 17753, comm: bash Tainted: G  W    3.3.0+ #99
kernel: Call Trace:
kernel: <IRQ>  [<ffffffff8104cc9f>] warn_slowpath_common+0x7f/0xc0
kernel: [<ffffffff810d7e88>] ? rb_reserve__next_event+0x68/0x470
kernel: [<ffffffff8104ccfa>] warn_slowpath_null+0x1a/0x20
kernel: [<ffffffff810b4e37>] res_counter_uncharge_locked+0x37/0x40
...
==

This patch fixes that by adding res_counter_uncharge_nowarn()
and hide the wrong accounting.

The reason for this fix is :
 - For avoid overheads, we don't account tcp usage by a cgroup before
   setting limit. So, we cannot know the amount of possible error when
   we start accounting. If we have this on/off switch for performance,
   this cannot be avoidable.

Consideration:
 - As memcg, if some marking to resources as PCG_USED could be used..
   ...we don't have problems. But it adds overhead.

TODO:
 - When enable/disable tcp accounting frequently, we'll see usage accounting
   leak. This should be fixed. (still under discussion.)
 - sockets_allocated has the same trouble. But it has no warning and never
   shows negative value even if it's negative.

Changelog:
 - updated patch description.

Acked-by: Glauber Costa <glommer@parallels.com>
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
