From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [RFC PATCH net-next 2/4] cls_cgroup: introduce a helper: bk_cls_classid()
Date: Fri, 3 Jan 2014 11:11:09 +0800
Message-ID: <52C62A4D.5010000@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	<ebiederm@xmission.com>, <containers@lists.linux-foundation.org>,
	<cgroups@vger.kernel.org>, Serge Hallyn <serge.hallyn@ubuntu.com>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>, <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


it can save classid from skb->sk->sk_classid
to skb->bk_classid

Signed-off-by: Libo Chen <clbchenlibo.chen@huawei.com>
---
 include/net/cls_cgroup.h | 11 +++++++++++
 net/sched/cls_cgroup.c   |  1 -
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 33d03b6..4249ea3 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
+#include <net/sock.h>

 #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 struct cgroup_cls_state
@@ -26,6 +27,12 @@ struct cgroup_cls_state

 void sock_update_classid(struct sock *sk);

+static inline void bk_cls_classid(struct sk_buff *skb)
+{
+	if (skb->sk && skb->sk->sk_classid)
+		skb->backup_classid = skb->sk->sk_classid;
+}
+
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
 {
@@ -61,6 +68,10 @@ static inline u32 task_cls_classid(struct task_struct *p)
 }
 #endif
 #else /* !CGROUP_NET_CLS_CGROUP */
+static inline void bk_cls_classid(struct sk_buff *skb)
+{
+}
+
 static inline void sock_update_classid(struct sock *sk)
 {
 }
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index f9d21258..d228a5d 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -20,7 +20,6 @@
 #include <linux/fdtable.h>
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
-#include <net/sock.h>
 #include <net/cls_cgroup.h>

 static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state *css)
-- 
1.8.2.2
