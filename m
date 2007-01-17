From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified
 by inet6_rt_notify().
Date: Wed, 17 Jan 2007 13:33:22 +0100
Message-ID: <45AE1792.1010002@trash.net>
References: <20070116.125728.278729390.takamiya@po.ntts.co.jp> <20070116.140159.02303722.takamiya@po.ntts.co.jp> <20070117105006.GV8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020108030101060702090406"
Cc: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42556 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbXAQMdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 07:33:25 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20070117105006.GV8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020108030101060702090406
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:
> * Noriaki TAKAMIYA <takamiya@po.ntts.co.jp> 2007-01-16 14:01
>>
>>  I think the return value of rt6_nlmsg_size() should includes the
>>  amount of RTA_METRICS.
>>
>>Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> 
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>


Somewhat related: I have this patch for 2.6.21 to get rid of the
BUG_ON()s.


--------------020108030101060702090406
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETLINK]: Don't BUG on undersized allocations

Currently netlink users BUG when the allocated skb for an event
notification is undersized. While this is certainly a kernel bug,
its not critical and crashing the kernel is too drastic, especially
when considering that these errors have appeared multiple times in
the past and it BUGs even if no listeners are present.

This patch replaces BUG by WARN_ON and changes the notification
functions to inform potential listeners of undersized allocations
using a unique error code (EMSGSIZE).

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0ec75b65e49901d1b4785dbd46651871106fb04a
tree f3c559a20cb3542f546f170e43434f542b5b286a
parent 71d31bf21bda0abda8c64d5b8de1dd45d5cd771a
author Patrick McHardy <kaber@trash.net> Fri, 12 Jan 2007 08:38:31 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 12 Jan 2007 08:38:31 +0100

 net/bridge/br_netlink.c  |   14 ++++++---
 net/core/fib_rules.c     |   14 ++++++---
 net/core/neighbour.c     |   24 ++++++++++------
 net/core/rtnetlink.c     |   23 ++++++++++-----
 net/decnet/dn_dev.c      |   14 ++++++---
 net/decnet/dn_table.c    |   11 +++++--
 net/ipv4/devinet.c       |   14 ++++++---
 net/ipv4/fib_semantics.c |   14 ++++++---
 net/ipv4/inet_diag.c     |   17 +++++++----
 net/ipv4/route.c         |    5 ++-
 net/ipv6/addrconf.c      |   70 ++++++++++++++++++++++++++++++----------------
 net/ipv6/route.c         |   14 ++++++---
 12 files changed, 149 insertions(+), 85 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a913968..7d68b24 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -45,7 +45,7 @@ static int br_fill_ifinfo(struct sk_buff
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*hdr), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	hdr = nlmsg_data(nlh);
 	hdr->ifi_family = AF_BRIDGE;
@@ -72,7 +72,8 @@ static int br_fill_ifinfo(struct sk_buff
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 /*
@@ -89,9 +90,12 @@ void br_ifinfo_notify(int event, struct 
 		goto errout;
 
 	err = br_fill_ifinfo(skb, port, 0, 0, event, 0);
-	/* failure implies BUG in br_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in br_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 1df6cd4..215f1bf 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -331,7 +331,7 @@ static int fib_nl_fill_rule(struct sk_bu
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*frh), flags);
 	if (nlh == NULL)
-		return -1;
+		return -EMSGSIZE;
 
 	frh = nlmsg_data(nlh);
 	frh->table = rule->table;
@@ -359,7 +359,8 @@ static int fib_nl_fill_rule(struct sk_bu
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 int fib_rules_dump(struct sk_buff *skb, struct netlink_callback *cb, int family)
@@ -405,9 +406,12 @@ static void notify_rule_change(int event
 		goto errout;
 
 	err = fib_nl_fill_rule(skb, rule, pid, nlh->nlmsg_seq, event, 0, ops);
-	/* failure implies BUG in fib_rule_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in fib_rule_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, pid, ops->nlgroup, nlh, GFP_KERNEL);
 errout:
 	if (err < 0)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e7300b6..9e26f38 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1637,7 +1637,7 @@ static int neightbl_fill_info(struct sk_
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndtmsg), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	ndtmsg = nlmsg_data(nlh);
 
@@ -1706,7 +1706,8 @@ static int neightbl_fill_info(struct sk_
 
 nla_put_failure:
 	read_unlock_bh(&tbl->lock);
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int neightbl_fill_param_info(struct sk_buff *skb,
@@ -1720,7 +1721,7 @@ static int neightbl_fill_param_info(stru
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndtmsg), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	ndtmsg = nlmsg_data(nlh);
 
@@ -1737,7 +1738,8 @@ static int neightbl_fill_param_info(stru
 	return nlmsg_end(skb, nlh);
 errout:
 	read_unlock_bh(&tbl->lock);
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
  
 static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
@@ -1955,7 +1957,7 @@ static int neigh_fill_info(struct sk_buf
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	ndm = nlmsg_data(nlh);
 	ndm->ndm_family	 = neigh->ops->family;
@@ -1987,7 +1989,8 @@ static int neigh_fill_info(struct sk_buf
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 
@@ -2429,9 +2432,12 @@ static void __neigh_notify(struct neighb
 		goto errout;
 
 	err = neigh_fill_info(skb, n, 0, 0, type, flags);
-	/* failure implies BUG in neigh_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in neigh_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e76539a..9bf9ae0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -320,7 +320,7 @@ static int rtnl_fill_ifinfo(struct sk_bu
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	ifm = nlmsg_data(nlh);
 	ifm->ifi_family = AF_UNSPEC;
@@ -384,7 +384,8 @@ static int rtnl_fill_ifinfo(struct sk_bu
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
@@ -633,9 +634,12 @@ #endif	/* CONFIG_NET_WIRELESS_RTNETLINK 
 
 	err = rtnl_fill_ifinfo(nskb, dev, iw, iw_buf_len, RTM_NEWLINK,
 			       NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0, 0);
-	/* failure impilies BUG in if_nlmsg_size or wireless_rtnetlink_get */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in if_nlmsg_size */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(nskb);
+		goto errout;
+	}
 	err = rtnl_unicast(nskb, NETLINK_CB(skb).pid);
 errout:
 	kfree(iw_buf);
@@ -678,9 +682,12 @@ void rtmsg_ifinfo(int type, struct net_d
 		goto errout;
 
 	err = rtnl_fill_ifinfo(skb, dev, NULL, 0, type, 0, 0, change, 0);
-	/* failure implies BUG in if_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
 errout:
 	if (err < 0)
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index fc6f3c0..fefcab3 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -749,7 +749,7 @@ static int dn_nl_fill_ifaddr(struct sk_b
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*ifm), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	ifm = nlmsg_data(nlh);
 	ifm->ifa_family = AF_DECnet;
@@ -768,7 +768,8 @@ static int dn_nl_fill_ifaddr(struct sk_b
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static void dn_ifaddr_notify(int event, struct dn_ifaddr *ifa)
@@ -781,9 +782,12 @@ static void dn_ifaddr_notify(int event, 
 		goto errout;
 
 	err = dn_nl_fill_ifaddr(skb, ifa, 0, 0, event, 0);
-	/* failure implies BUG in dn_ifaddr_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in dn_ifaddr_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, 0, RTNLGRP_DECnet_IFADDR, NULL, GFP_KERNEL);
 errout:
 	if (err < 0)
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 13b2421..c1f0cc1 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -350,7 +350,7 @@ static int dn_fib_dump_info(struct sk_bu
 nlmsg_failure:
 rtattr_failure:
         skb_trim(skb, b - skb->data);
-        return -1;
+        return -EMSGSIZE;
 }
 
 
@@ -368,9 +368,12 @@ static void dn_rtmsg_fib(int event, stru
         err = dn_fib_dump_info(skb, pid, nlh->nlmsg_seq, event, tb_id,
 			       f->fn_type, f->fn_scope, &f->fn_key, z,
 			       DN_FIB_INFO(f), 0);
-	/* failure implies BUG in dn_fib_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in dn_fib_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, pid, RTNLGRP_DECnet_ROUTE, nlh, GFP_KERNEL);
 errout:
 	if (err < 0)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 25c8a42..bccbe43 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1139,7 +1139,7 @@ static int inet_fill_ifaddr(struct sk_bu
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*ifm), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	ifm = nlmsg_data(nlh);
 	ifm->ifa_family = AF_INET;
@@ -1166,7 +1166,8 @@ static int inet_fill_ifaddr(struct sk_bu
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1224,9 +1225,12 @@ static void rtmsg_ifa(int event, struct 
 		goto errout;
 
 	err = inet_fill_ifaddr(skb, ifa, pid, seq, event, 0);
-	/* failure implies BUG in inet_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
 errout:
 	if (err < 0)
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index e63b8a9..be1028c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -314,9 +314,12 @@ void rtmsg_fib(int event, __be32 key, st
 	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
 			    fa->fa_type, fa->fa_scope, key, dst_len,
 			    fa->fa_tos, fa->fa_info, 0);
-	/* failure implies BUG in fib_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in fib_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, info->pid, RTNLGRP_IPV4_ROUTE,
 			  info->nlh, GFP_KERNEL);
 errout:
@@ -960,7 +963,7 @@ int fib_dump_info(struct sk_buff *skb, u
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	rtm = nlmsg_data(nlh);
 	rtm->rtm_family = AF_INET;
@@ -1031,7 +1034,8 @@ #endif
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 /*
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 77761ac..9cd53ad 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -153,7 +153,7 @@ #undef EXPIRES_IN_MS
 rtattr_failure:
 nlmsg_failure:
 	skb_trim(skb, b - skb->data);
-	return -1;
+	return -EMSGSIZE;
 }
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
@@ -209,7 +209,7 @@ #endif
 	return skb->len;
 nlmsg_failure:
 	skb_trim(skb, previous_tail - skb->data);
-	return -1;
+	return -EMSGSIZE;
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
@@ -274,11 +274,14 @@ #endif
 	if (!rep)
 		goto out;
 
-	if (sk_diag_fill(sk, rep, req->idiag_ext,
-			 NETLINK_CB(in_skb).pid,
-			 nlh->nlmsg_seq, 0, nlh) <= 0)
-		BUG();
-
+	err = sk_diag_fill(sk, rep, req->idiag_ext,
+			   NETLINK_CB(in_skb).pid,
+			   nlh->nlmsg_seq, 0, nlh);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(rep);
+		goto out;
+	}
 	err = netlink_unicast(idiagnl, rep, NETLINK_CB(in_skb).pid,
 			      MSG_DONTWAIT);
 	if (err > 0)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2daa0dc..baee304 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2635,7 +2635,7 @@ static int rt_fill_info(struct sk_buff *
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	r = nlmsg_data(nlh);
 	r->rtm_family	 = AF_INET;
@@ -2718,7 +2718,8 @@ #endif
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 171e5b5..f94054e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3111,7 +3111,7 @@ static int inet6_fill_ifaddr(struct sk_b
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, ifa->prefix_len, ifa->flags, rt_scope(ifa->scope),
 		      ifa->idev->dev->ifindex);
@@ -3131,8 +3131,10 @@ static int inet6_fill_ifaddr(struct sk_b
 	}
 
 	if (nla_put(skb, IFA_ADDRESS, 16, &ifa->addr) < 0 ||
-	    put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
-		return nlmsg_cancel(skb, nlh);
+	    put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
 
 	return nlmsg_end(skb, nlh);
 }
@@ -3149,13 +3151,15 @@ static int inet6_fill_ifmcaddr(struct sk
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
 	if (nla_put(skb, IFA_MULTICAST, 16, &ifmca->mca_addr) < 0 ||
 	    put_cacheinfo(skb, ifmca->mca_cstamp, ifmca->mca_tstamp,
-			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0)
-		return nlmsg_cancel(skb, nlh);
+			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
 
 	return nlmsg_end(skb, nlh);
 }
@@ -3172,13 +3176,15 @@ static int inet6_fill_ifacaddr(struct sk
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
 	if (nla_put(skb, IFA_ANYCAST, 16, &ifaca->aca_addr) < 0 ||
 	    put_cacheinfo(skb, ifaca->aca_cstamp, ifaca->aca_tstamp,
-			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0)
-		return nlmsg_cancel(skb, nlh);
+			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
 
 	return nlmsg_end(skb, nlh);
 }
@@ -3328,9 +3334,12 @@ static int inet6_rtm_getaddr(struct sk_b
 
 	err = inet6_fill_ifaddr(skb, ifa, NETLINK_CB(in_skb).pid,
 				nlh->nlmsg_seq, RTM_NEWADDR, 0);
-	/* failure implies BUG in inet6_ifaddr_msgsize() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_ifaddr_msgsize() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout_ifa;
+	}
 	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 errout_ifa:
 	in6_ifa_put(ifa);
@@ -3348,9 +3357,12 @@ static void inet6_ifa_notify(int event, 
 		goto errout;
 
 	err = inet6_fill_ifaddr(skb, ifa, 0, 0, event, 0);
-	/* failure implies BUG in inet6_ifaddr_msgsize() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_ifaddr_msgsize() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
@@ -3420,7 +3432,7 @@ static int inet6_fill_ifinfo(struct sk_b
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*hdr), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	hdr = nlmsg_data(nlh);
 	hdr->ifi_family = AF_INET6;
@@ -3463,7 +3475,8 @@ static int inet6_fill_ifinfo(struct sk_b
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int inet6_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
@@ -3501,9 +3514,12 @@ void inet6_ifinfo_notify(int event, stru
 		goto errout;
 
 	err = inet6_fill_ifinfo(skb, idev, 0, 0, event, 0);
-	/* failure implies BUG in inet6_if_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_if_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
@@ -3527,7 +3543,7 @@ static int inet6_fill_prefix(struct sk_b
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*pmsg), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	pmsg = nlmsg_data(nlh);
 	pmsg->prefix_family = AF_INET6;
@@ -3552,7 +3568,8 @@ static int inet6_fill_prefix(struct sk_b
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static void inet6_prefix_notify(int event, struct inet6_dev *idev, 
@@ -3566,9 +3583,12 @@ static void inet6_prefix_notify(int even
 		goto errout;
 
 	err = inet6_fill_prefix(skb, idev, pinfo, 0, 0, event, 0);
-	/* failure implies BUG in inet6_prefix_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_prefix_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_PREFIX, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c3d568..bdca735 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2039,7 +2039,7 @@ static int rt6_fill_node(struct sk_buff 
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*rtm), flags);
 	if (nlh == NULL)
-		return -ENOBUFS;
+		return -EMSGSIZE;
 
 	rtm = nlmsg_data(nlh);
 	rtm->rtm_family = AF_INET6;
@@ -2110,7 +2110,8 @@ #endif
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-	return nlmsg_cancel(skb, nlh);
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 int rt6_dump_route(struct rt6_info *rt, void *p_arg)
@@ -2221,9 +2222,12 @@ void inet6_rt_notify(int event, struct r
 		goto errout;
 
 	err = rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0);
-	/* failure implies BUG in rt6_nlmsg_size() */
-	BUG_ON(err < 0);
-
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
 	err = rtnl_notify(skb, pid, RTNLGRP_IPV6_ROUTE, nlh, gfp_any());
 errout:
 	if (err < 0)

--------------020108030101060702090406--
