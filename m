From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] netns xfrm: fix "ip xfrm state|policy count" misreport
Date: Sun, 24 Jan 2010 01:37:10 +0200
Message-ID: <20100123233709.GA4157@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

"ip xfrm state|policy count" report SA/SP count from init_net,
not from netns of caller process.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/net/xfrm.h     |    4 ++--
 net/xfrm/xfrm_policy.c |   16 ++++++++--------
 net/xfrm/xfrm_state.c  |    6 +++---
 net/xfrm/xfrm_user.c   |   14 ++++++++------
 4 files changed, 21 insertions(+), 19 deletions(-)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1367,8 +1367,8 @@ struct xfrmk_spdinfo {
 extern struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
-extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
-extern void xfrm_spd_getinfo(struct xfrmk_spdinfo *si);
+extern void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
+extern void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x,
 			     struct sk_buff *skb, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -469,16 +469,16 @@ static inline int xfrm_byidx_should_resize(struct net *net, int total)
 	return 0;
 }
 
-void xfrm_spd_getinfo(struct xfrmk_spdinfo *si)
+void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si)
 {
 	read_lock_bh(&xfrm_policy_lock);
-	si->incnt = init_net.xfrm.policy_count[XFRM_POLICY_IN];
-	si->outcnt = init_net.xfrm.policy_count[XFRM_POLICY_OUT];
-	si->fwdcnt = init_net.xfrm.policy_count[XFRM_POLICY_FWD];
-	si->inscnt = init_net.xfrm.policy_count[XFRM_POLICY_IN+XFRM_POLICY_MAX];
-	si->outscnt = init_net.xfrm.policy_count[XFRM_POLICY_OUT+XFRM_POLICY_MAX];
-	si->fwdscnt = init_net.xfrm.policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
-	si->spdhcnt = init_net.xfrm.policy_idx_hmask;
+	si->incnt = net->xfrm.policy_count[XFRM_POLICY_IN];
+	si->outcnt = net->xfrm.policy_count[XFRM_POLICY_OUT];
+	si->fwdcnt = net->xfrm.policy_count[XFRM_POLICY_FWD];
+	si->inscnt = net->xfrm.policy_count[XFRM_POLICY_IN+XFRM_POLICY_MAX];
+	si->outscnt = net->xfrm.policy_count[XFRM_POLICY_OUT+XFRM_POLICY_MAX];
+	si->fwdscnt = net->xfrm.policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
+	si->spdhcnt = net->xfrm.policy_idx_hmask;
 	si->spdhmcnt = xfrm_policy_hashmax;
 	read_unlock_bh(&xfrm_policy_lock);
 }
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -641,11 +641,11 @@ out:
 }
 EXPORT_SYMBOL(xfrm_state_flush);
 
-void xfrm_sad_getinfo(struct xfrmk_sadinfo *si)
+void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
 {
 	spin_lock_bh(&xfrm_state_lock);
-	si->sadcnt = init_net.xfrm.state_num;
-	si->sadhcnt = init_net.xfrm.state_hmask;
+	si->sadcnt = net->xfrm.state_num;
+	si->sadhcnt = net->xfrm.state_hmask;
 	si->sadhmcnt = xfrm_state_hashmax;
 	spin_unlock_bh(&xfrm_state_lock);
 }
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -781,7 +781,8 @@ static inline size_t xfrm_spdinfo_msgsize(void)
 	       + nla_total_size(sizeof(struct xfrmu_spdhinfo));
 }
 
-static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
+static int build_spdinfo(struct sk_buff *skb, struct net *net,
+			 u32 pid, u32 seq, u32 flags)
 {
 	struct xfrmk_spdinfo si;
 	struct xfrmu_spdinfo spc;
@@ -795,7 +796,7 @@ static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 
 	f = nlmsg_data(nlh);
 	*f = flags;
-	xfrm_spd_getinfo(&si);
+	xfrm_spd_getinfo(net, &si);
 	spc.incnt = si.incnt;
 	spc.outcnt = si.outcnt;
 	spc.fwdcnt = si.fwdcnt;
@@ -828,7 +829,7 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_spdinfo(r_skb, spid, seq, *flags) < 0)
+	if (build_spdinfo(r_skb, net, spid, seq, *flags) < 0)
 		BUG();
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, spid);
@@ -841,7 +842,8 @@ static inline size_t xfrm_sadinfo_msgsize(void)
 	       + nla_total_size(4); /* XFRMA_SAD_CNT */
 }
 
-static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
+static int build_sadinfo(struct sk_buff *skb, struct net *net,
+			 u32 pid, u32 seq, u32 flags)
 {
 	struct xfrmk_sadinfo si;
 	struct xfrmu_sadhinfo sh;
@@ -854,7 +856,7 @@ static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 
 	f = nlmsg_data(nlh);
 	*f = flags;
-	xfrm_sad_getinfo(&si);
+	xfrm_sad_getinfo(net, &si);
 
 	sh.sadhmcnt = si.sadhmcnt;
 	sh.sadhcnt = si.sadhcnt;
@@ -882,7 +884,7 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_sadinfo(r_skb, spid, seq, *flags) < 0)
+	if (build_sadinfo(r_skb, net, spid, seq, *flags) < 0)
 		BUG();
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, spid);
