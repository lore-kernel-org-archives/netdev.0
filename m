From: David Miller <davem@davemloft.net>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Sun, 18 Jan 2015 23:37:22 -0500 (EST)
Message-ID: <20150118.233722.226468667930444145.davem@davemloft.net>
References: <E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org>
	<CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
	<01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net, teg@jklm.no
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbbASEh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 23:37:26 -0500
In-Reply-To: <01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sun, 18 Jan 2015 18:10:46 -0800

> Hi Scott,
> 
>> This patch needs to be reverted ASAP.  git bisect landed me here also;
>> my processes are getting the OOM msgs.  What testing was done?
>> 
>> Seems someone does care that nlmsg_end() returns skb->len.
> 
> I still wonder how this affects userspace. I have not figured that
> out. Something goes wrong pretty badly somewhere.
> 
> Have you tried the small diff with the two locations that were
> problematic for me?

There were a lot more cases not converted properly, I hope the
patch below gets them all.

Johannes, this was either not tested or tested very poorly, please
don't submit changes like this.  Even neighbour entry and route
dumping were hosed.

====================
[PATCH] netlink: Fix bugs in nlmsg_end() conversions.

Commit 053c095a82cf ("netlink: make nlmsg_end() and genlmsg_end()
void") didn't catch all of the cases where callers were breaking out
on the return value being equal to zero, which they no longer should
when zero means success.

Fix all such cases.

Reported-by: Marcel Holtmann <marcel@holtmann.org>
Reported-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/neighbour.c  | 8 ++++----
 net/core/rtnetlink.c  | 2 +-
 net/decnet/dn_route.c | 5 +----
 net/ipv4/devinet.c    | 6 +++---
 net/ipv4/route.c      | 2 +-
 net/ipv6/addrconf.c   | 2 +-
 6 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d36d564..70fe9e1 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2128,7 +2128,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (neightbl_fill_info(skb, tbl, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq, RTM_NEWNEIGHTBL,
-				       NLM_F_MULTI) <= 0)
+				       NLM_F_MULTI) < 0)
 			break;
 
 		nidx = 0;
@@ -2144,7 +2144,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 						     NETLINK_CB(cb->skb).portid,
 						     cb->nlh->nlmsg_seq,
 						     RTM_NEWNEIGHTBL,
-						     NLM_F_MULTI) <= 0)
+						     NLM_F_MULTI) < 0)
 				goto out;
 		next:
 			nidx++;
@@ -2274,7 +2274,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
-					    NLM_F_MULTI) <= 0) {
+					    NLM_F_MULTI) < 0) {
 				rc = -1;
 				goto out;
 			}
@@ -2311,7 +2311,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			if (pneigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
-					    NLM_F_MULTI, tbl) <= 0) {
+					    NLM_F_MULTI, tbl) < 0) {
 				read_unlock_bh(&tbl->lock);
 				rc = -1;
 				goto out;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e13b9db..0e26b9f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1327,7 +1327,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			 */
 			WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
 
-			if (err <= 0)
+			if (err < 0)
 				goto out;
 
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 812e5e6..1d7c125 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1710,9 +1710,6 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		rt->rt_flags |= RTCF_NOTIFY;
 
 	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).portid, nlh->nlmsg_seq, RTM_NEWROUTE, 0, 0);
-
-	if (err == 0)
-		goto out_free;
 	if (err < 0) {
 		err = -EMSGSIZE;
 		goto out_free;
@@ -1763,7 +1760,7 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			skb_dst_set(skb, dst_clone(&rt->dst));
 			if (dn_rt_fill_info(skb, NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, RTM_NEWROUTE,
-					1, NLM_F_MULTI) <= 0) {
+					1, NLM_F_MULTI) < 0) {
 				skb_dst_drop(skb);
 				rcu_read_unlock_bh();
 				goto done;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5f344eb..59ebe16 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1883,7 +1883,7 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 						      cb->nlh->nlmsg_seq,
 						      RTM_NEWNETCONF,
 						      NLM_F_MULTI,
-						      -1) <= 0) {
+						      -1) < 0) {
 				rcu_read_unlock();
 				goto done;
 			}
@@ -1899,7 +1899,7 @@ cont:
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWNETCONF, NLM_F_MULTI,
-					      -1) <= 0)
+					      -1) < 0)
 			goto done;
 		else
 			h++;
@@ -1910,7 +1910,7 @@ cont:
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWNETCONF, NLM_F_MULTI,
-					      -1) <= 0)
+					      -1) < 0)
 			goto done;
 		else
 			h++;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f6e43ca..2000110 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2483,7 +2483,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	err = rt_fill_info(net, dst, src, &fl4, skb,
 			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
-	if (err <= 0)
+	if (err < 0)
 		goto errout_free;
 
 	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8975d95..d6b4f5d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4213,7 +4213,7 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 				goto cont;
 
 			if (in6_dump_addrs(idev, skb, cb, type,
-					   s_ip_idx, &ip_idx) <= 0)
+					   s_ip_idx, &ip_idx) < 0)
 				goto done;
 cont:
 			idx++;
-- 
2.1.0
