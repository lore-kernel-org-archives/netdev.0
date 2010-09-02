From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH] cls_cgroup: Fix rcu lockdep warning
Date: Thu, 02 Sep 2010 14:30:07 +0800
Message-ID: <4C7F446F.8040303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Dave Jones <davej@redhat.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calling task_subsys_state() without holding rcu_read_lock or
cgroup_mutex can cause lockdep warning.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 include/net/cls_cgroup.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index dd1fdb8..a4dc5b0 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -27,11 +27,17 @@ struct cgroup_cls_state
 #ifdef CONFIG_NET_CLS_CGROUP
 static inline u32 task_cls_classid(struct task_struct *p)
 {
+	int classid;
+
 	if (in_interrupt())
 		return 0;
 
-	return container_of(task_subsys_state(p, net_cls_subsys_id),
-			    struct cgroup_cls_state, css)->classid;
+	rcu_read_lock();
+	classid = container_of(task_subsys_state(p, net_cls_subsys_id),
+			       struct cgroup_cls_state, css)->classid;
+	rcu_read_unlock();
+
+	return classid;
 }
 #else
 extern int net_cls_subsys_id;
-- 
1.6.3
