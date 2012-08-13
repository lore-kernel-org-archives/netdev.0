From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 15/21] net sched: Pass the skb into change so it can access
	NETLINK_CB
Date: Mon, 13 Aug 2012 13:18:29 -0700
Message-ID: <1344889115-21610-15-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

cls_flow.c plays with uids and gids.  Unless I misread that
code it is possible for classifiers to depend on the specific uid and
gid values.  Therefore I need to know the user namespace of the
netlink socket that is installing the packet classifiers.  Pass
in the rtnetlink skb so I can access the NETLINK_CB of the passed
packet.  In particular I want access to sk_user_ns(NETLINK_CB(in_skb).ssk).

Pass in not the user namespace but the incomming rtnetlink skb into
the the classifier change routines as that is generally the more useful
parameter.

Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/sch_generic.h |    3 ++-
 net/sched/cls_api.c       |    2 +-
 net/sched/cls_basic.c     |    3 ++-
 net/sched/cls_cgroup.c    |    3 ++-
 net/sched/cls_flow.c      |    3 ++-
 net/sched/cls_fw.c        |    3 ++-
 net/sched/cls_route.c     |    3 ++-
 net/sched/cls_rsvp.h      |    3 ++-
 net/sched/cls_tcindex.c   |    3 ++-
 net/sched/cls_u32.c       |    3 ++-
 10 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index d9611e0..4616f46 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -188,7 +188,8 @@ struct tcf_proto_ops {
 
 	unsigned long		(*get)(struct tcf_proto*, u32 handle);
 	void			(*put)(struct tcf_proto*, unsigned long);
-	int			(*change)(struct tcf_proto*, unsigned long,
+	int			(*change)(struct sk_buff *,
+					struct tcf_proto*, unsigned long,
 					u32 handle, struct nlattr **,
 					unsigned long *);
 	int			(*delete)(struct tcf_proto*, unsigned long);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6dd1131..dc3ef5a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -319,7 +319,7 @@ replay:
 		}
 	}
 
-	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
+	err = tp->ops->change(skb, tp, cl, t->tcm_handle, tca, &fh);
 	if (err == 0) {
 		if (tp_created) {
 			spin_lock_bh(root_lock);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 590960a..344a11b 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -162,7 +162,8 @@ errout:
 	return err;
 }
 
-static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+static int basic_change(struct sk_buff *in_skb,
+			struct tcf_proto *tp, unsigned long base, u32 handle,
 			struct nlattr **tca, unsigned long *arg)
 {
 	int err;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 7743ea8..91de666 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -151,7 +151,8 @@ static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
 	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
 };
 
-static int cls_cgroup_change(struct tcf_proto *tp, unsigned long base,
+static int cls_cgroup_change(struct sk_buff *in_skb,
+			     struct tcf_proto *tp, unsigned long base,
 			     u32 handle, struct nlattr **tca,
 			     unsigned long *arg)
 {
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index ccd08c8..ae854f3 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -347,7 +347,8 @@ static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_PERTURB]	= { .type = NLA_U32 },
 };
 
-static int flow_change(struct tcf_proto *tp, unsigned long base,
+static int flow_change(struct sk_buff *in_skb, 
+		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle, struct nlattr **tca,
 		       unsigned long *arg)
 {
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 8384a47..4075a0a 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -233,7 +233,8 @@ errout:
 	return err;
 }
 
-static int fw_change(struct tcf_proto *tp, unsigned long base,
+static int fw_change(struct sk_buff *in_skb,
+		     struct tcf_proto *tp, unsigned long base,
 		     u32 handle,
 		     struct nlattr **tca,
 		     unsigned long *arg)
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 44f405c..c10d57b 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -427,7 +427,8 @@ errout:
 	return err;
 }
 
-static int route4_change(struct tcf_proto *tp, unsigned long base,
+static int route4_change(struct sk_buff *in_skb,
+		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
 		       struct nlattr **tca,
 		       unsigned long *arg)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 18ab93e..494bbb9 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -416,7 +416,8 @@ static const struct nla_policy rsvp_policy[TCA_RSVP_MAX + 1] = {
 	[TCA_RSVP_PINFO]	= { .len = sizeof(struct tc_rsvp_pinfo) },
 };
 
-static int rsvp_change(struct tcf_proto *tp, unsigned long base,
+static int rsvp_change(struct sk_buff *in_skb,
+		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
 		       struct nlattr **tca,
 		       unsigned long *arg)
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index fe29420..a1293b4 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -332,7 +332,8 @@ errout:
 }
 
 static int
-tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+tcindex_change(struct sk_buff *in_skb,
+	       struct tcf_proto *tp, unsigned long base, u32 handle,
 	       struct nlattr **tca, unsigned long *arg)
 {
 	struct nlattr *opt = tca[TCA_OPTIONS];
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index d45373f..c7c27bc 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -544,7 +544,8 @@ errout:
 	return err;
 }
 
-static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+static int u32_change(struct sk_buff *in_skb,
+		      struct tcf_proto *tp, unsigned long base, u32 handle,
 		      struct nlattr **tca,
 		      unsigned long *arg)
 {
-- 
1.7.5.4
