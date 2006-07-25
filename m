From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 20:20:01 +0400
Message-ID: <20060725162001.GA15058@ms2.inr.ac.ru>
References: <20060719145716.4cb9e7e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:13533 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932437AbWGYQUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 12:20:33 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060719145716.4cb9e7e2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Code was reusing an skb which could lead to use after free or double free.

No, this does not help. The bug is not here.

I was so ashamed of this that could not touch the thing. :-)
It startled me a lot, how is it possible that the thing was in production
for several years and such bad bug never was noticed?

Now it is clear. skbs leaked sometimes before BK changeset 1.889.26.53,
subj: [IPV4]: Fix skb leak in inet_rtm_getroute. But after this fix,
which introduced new bug (goto out_free in the enclosed patch),
the bug showed on surface.

Please, review this.

- ipmr_cache_unresolved() does not free skb. Caller does.
- goto out_free in route.c in the case, when skb is enqueued
  is returned to goto out.
- some cosmetic cleanup in rt_fill_info() to make it more readable.

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9ccacf5..1788c04 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -640,8 +640,6 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 		if (atomic_read(&cache_resolve_queue_len)>=10 ||
 		    (c=ipmr_cache_alloc_unres())==NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
-
-			kfree_skb(skb);
 			return -ENOBUFS;
 		}
 
@@ -662,7 +660,6 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 			spin_unlock_bh(&mfc_unres_lock);
 
 			kmem_cache_free(mrt_cachep, c);
-			kfree_skb(skb);
 			return err;
 		}
 
@@ -677,7 +674,6 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 	 *	See if we can append the packet
 	 */
 	if (c->mfc_un.unres.unresolved.qlen>3) {
-		kfree_skb(skb);
 		err = -ENOBUFS;
 	} else {
 		skb_queue_tail(&c->mfc_un.unres.unresolved,skb);
@@ -1375,6 +1371,7 @@ int ip_mr_input(struct sk_buff *skb)
 	 */
 	if (cache==NULL) {
 		int vif;
+		int err;
 
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
@@ -1387,15 +1384,13 @@ int ip_mr_input(struct sk_buff *skb)
 		}
 
 		vif = ipmr_find_vif(skb->dev);
-		if (vif >= 0) {
-			int err = ipmr_cache_unresolved(vif, skb);
-			read_unlock(&mrt_lock);
-
-			return err;
-		}
+		err = -ENODEV;
+		if (vif >= 0)
+			err = ipmr_cache_unresolved(vif, skb);
 		read_unlock(&mrt_lock);
-		kfree_skb(skb);
-		return -ENODEV;
+		if (err)
+			kfree_skb(skb);
+		return err;
 	}
 
 	ip_mr_forward(skb, cache, local);
@@ -1568,6 +1563,17 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
+/**
+ * ipmr_get_route - return mrouting information or queue for resolution
+ * @skb - netlink skb with partially complete rtnelink information
+ * @rtm - pointer to head of rtmsg
+ * @nowait - if mroute is not in cache, do not resolve, fail with EAGAIN
+ *
+ * Return:
+ *   1 - if mrouting information is succesfully recorded in skb
+ *   0 - if information is not available, but skb is queued for resolution
+ *   < 0 - error
+ */
 int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 {
 	int err;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2dc6dbb..62f53e9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2703,16 +2703,12 @@ static int rt_fill_info(struct sk_buff *
 		if (MULTICAST(dst) && !LOCAL_MCAST(dst) &&
 		    ipv4_devconf.mc_forwarding) {
 			int err = ipmr_get_route(skb, r, nowait);
-			if (err <= 0) {
-				if (!nowait) {
-					if (err == 0)
-						return 0;
+			if (err == 0)
+				return 0;
+			if (err < 0) {
+				if (err == -EMSGSIZE)
 					goto nlmsg_failure;
-				} else {
-					if (err == -EMSGSIZE)
-						goto nlmsg_failure;
-					((struct rta_cacheinfo*)RTA_DATA(eptr))->rta_error = err;
-				}
+				((struct rta_cacheinfo*)RTA_DATA(eptr))->rta_error = err;
 			}
 		} else
 #endif
@@ -2794,7 +2790,7 @@ int inet_rtm_getroute(struct sk_buff *in
 	err = rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 				RTM_NEWROUTE, 0, 0);
 	if (!err)
-		goto out_free;
+		goto out;
 	if (err < 0) {
 		err = -EMSGSIZE;
 		goto out_free;



 
