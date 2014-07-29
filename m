From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next 2/2] net: filter: don't release unattached filter through call_rcu()
Date: Tue, 29 Jul 2014 17:36:28 +0200
Message-ID: <1406648188-3681-2-git-send-email-pablo@netfilter.org>
References: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@plumgrid.com,
	dborkman@redhat.com, willemb@google.com, keescook@chromium.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52310 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbaG2PhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 11:37:08 -0400
In-Reply-To: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_unattached_filter_destroy() does not always need to release the
filter object via rcu. Since this filter is never attached to the
socket, the caller should be responsible for releasing the filter
in a safe way, which may not necessarily imply rcu.

This is a short summary of clients of this function:

1) xt_bpf.c and cls_bpf.c use the bpf matchers from rules, these rules
   are removed from the packet path before the filter is released. Thus,
   the framework makes sure the filter is safely removed.

2) In the ppp driver, the ppp_lock ensures serialization between the
   xmit and filter attachment/detachment path. This doesn't use rcu
   so deferred release via rcu makes no sense.

3) In the isdn/ppp driver, it is called from isdn_ppp_release()
   the isdn_ppp_ioctl(). This driver uses mutex and spinlocks, no rcu.
   Thus, deferred rcu makes no sense to me either, the deferred releases
   may be just masking the effects of wrong locking strategy, which
   should be fixed in the driver itself.

4) In the team driver, this is the only place where the rcu
   synchronization with unattached filter is used. Therefore, this
   patch introduces synchronize_rcu() which is called from the
   genetlink path to make sure the filter doesn't go away while packets
   are still walking over it. I think we can revisit this once struct
   bpf_prog (that only wraps specific bpf code bits) is in place, then
   add some specific struct rcu_head in the scope of the team driver if
   Jiri thinks this is needed.

Deferred rcu release for unattached filters was originally introduced
in 302d663 ("filter: Allow to create sk-unattached filters").

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/team/team_mode_loadbalance.c |    6 +++++-
 net/core/filter.c                        |   11 ++++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index a58dfeb..7106f34 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -293,11 +293,15 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 		__fprog_destroy(lb_priv->ex->orig_fprog);
 		orig_fp = rcu_dereference_protected(lb_priv->fp,
 						lockdep_is_held(&team->lock));
-		sk_unattached_filter_destroy(orig_fp);
 	}
 
 	rcu_assign_pointer(lb_priv->fp, fp);
 	lb_priv->ex->orig_fprog = fprog;
+
+	if (orig_fp) {
+		synchronize_rcu();
+		sk_unattached_filter_destroy(orig_fp);
+	}
 	return 0;
 }
 
diff --git a/net/core/filter.c b/net/core/filter.c
index f3b2d5e..42c1944 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -841,6 +841,12 @@ static void sk_release_orig_filter(struct sk_filter *fp)
 	}
 }
 
+static void __sk_filter_release(struct sk_filter *fp)
+{
+	sk_release_orig_filter(fp);
+	sk_filter_free(fp);
+}
+
 /**
  * 	sk_filter_release_rcu - Release a socket filter by rcu_head
  *	@rcu: rcu_head that contains the sk_filter to free
@@ -849,8 +855,7 @@ static void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
-	sk_release_orig_filter(fp);
-	sk_filter_free(fp);
+	__sk_filter_release(fp);
 }
 
 /**
@@ -1050,7 +1055,7 @@ EXPORT_SYMBOL_GPL(sk_unattached_filter_create);
 
 void sk_unattached_filter_destroy(struct sk_filter *fp)
 {
-	sk_filter_release(fp);
+	__sk_filter_release(fp);
 }
 EXPORT_SYMBOL_GPL(sk_unattached_filter_destroy);
 
-- 
1.7.10.4
