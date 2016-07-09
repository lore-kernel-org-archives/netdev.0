From: Masashi Honma <masashi.honma@gmail.com>
Subject: [PATCH v2 net-next] rtnl: Add GFP flag argument to rtnl_unicast()
Date: Sat,  9 Jul 2016 12:59:04 +0900
Message-ID: <1468036744-3964-1-git-send-email-masashi.honma@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Cc: netdev@vger.kernel.org, Masashi Honma <masashi.honma@gmail.com>
To: eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34262 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbcGID7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 23:59:17 -0400
Received: by mail-pf0-f193.google.com with SMTP id 66so9643261pfy.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 20:59:17 -0700 (PDT)
In-Reply-To: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit extends rtnl_unicast() to specify GFP flags.

This commit depends on Eric Dumazet's commits below.
	ipv4: do not abuse GFP_ATOMIC in inet_netconf_notify_devconf()
	ipv6: do not abuse GFP_ATOMIC in inet6_netconf_notify_devconf()

Signed-off-by: Masashi Honma <masashi.honma@gmail.com>
---
 include/linux/netlink.h   |  2 ++
 include/linux/rtnetlink.h |  3 ++-
 net/core/net_namespace.c  |  2 +-
 net/core/rtnetlink.c      | 16 +++++++++++-----
 net/dcb/dcbnl.c           |  2 +-
 net/decnet/dn_route.c     |  3 ++-
 net/ipv4/devinet.c        |  2 +-
 net/ipv4/ipmr.c           |  6 ++++--
 net/ipv4/route.c          |  2 +-
 net/ipv6/addrconf.c       |  4 ++--
 net/ipv6/addrlabel.c      |  2 +-
 net/ipv6/ip6mr.c          |  6 ++++--
 net/ipv6/route.c          |  2 +-
 net/netlink/af_netlink.c  | 12 +++++++++---
 net/sched/act_api.c       |  2 +-
 15 files changed, 43 insertions(+), 23 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index da14ab6..5b8e34d 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -69,6 +69,8 @@ extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group)
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 
+extern int __netlink_unicast(struct sock *ssk, struct sk_buff *skb, u32 portid,
+			     int nonblock, gfp_t allocation);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
 			     __u32 group, gfp_t allocation);
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 2daece8..132730f 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -8,7 +8,8 @@
 #include <uapi/linux/rtnetlink.h>
 
 extern int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, u32 group, int echo);
-extern int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid);
+extern int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid,
+			gfp_t flags);
 extern void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid,
 			u32 group, struct nlmsghdr *nlh, gfp_t flags);
 extern void rtnl_set_sk_err(struct net *net, u32 group, int error);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b..28eed58 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -646,7 +646,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (err < 0)
 		goto err_out;
 
-	err = rtnl_unicast(msg, net, NETLINK_CB(skb).portid);
+	err = rtnl_unicast(msg, net, NETLINK_CB(skb).portid, GFP_KERNEL);
 	goto out;
 
 err_out:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eb49ca2..42e6c5c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -653,11 +653,15 @@ int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int g
 	return err;
 }
 
-int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid)
+int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid, gfp_t flags)
 {
-	struct sock *rtnl = net->rtnl;
+	int err;
 
-	return nlmsg_unicast(rtnl, skb, pid);
+	err = __netlink_unicast(net->rtnl, skb, pid, MSG_DONTWAIT, flags);
+	if (err > 0)
+		err = 0;
+
+	return err;
 }
 EXPORT_SYMBOL(rtnl_unicast);
 
@@ -2565,7 +2569,8 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(nskb);
 	} else
-		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
+		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid,
+				   GFP_KERNEL);
 
 	return err;
 }
@@ -3601,7 +3606,8 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(nskb);
 	} else {
-		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
+		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid,
+				   GFP_KERNEL);
 	}
 
 	return err;
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 4f6c186..e4de9fe 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1749,7 +1749,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	nlmsg_end(reply_skb, reply_nlh);
 
-	ret = rtnl_unicast(reply_skb, net, portid);
+	ret = rtnl_unicast(reply_skb, net, portid, GFP_KERNEL);
 out:
 	return ret;
 }
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index b1dc096..6fe02bb 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1714,7 +1714,8 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		goto out_free;
 	}
 
-	return rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).portid);
+	return rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).portid,
+			    GFP_KERNEL);
 
 out_free:
 	kfree_skb(skb);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e333bc8..12422c0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1917,7 +1917,7 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_KERNEL);
 errout:
 	return err;
 }
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5ad48ec..c704a2a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -654,7 +654,8 @@ static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 			e->error = -ETIMEDOUT;
 			memset(&e->msg, 0, sizeof(e->msg));
 
-			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid,
+				     gfp_any());
 		} else {
 			kfree_skb(skb);
 		}
@@ -933,7 +934,8 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
 
-			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid,
+				     gfp_any());
 		} else {
 			ip_mr_forward(net, mrt, skb, c, 0);
 		}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a1f2830..10cb0e0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2621,7 +2621,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (err < 0)
 		goto errout_free;
 
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_KERNEL);
 errout:
 	return err;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a1f6b7b..eb72512 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -628,7 +628,7 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_KERNEL);
 errout:
 	return err;
 }
@@ -4824,7 +4824,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		kfree_skb(skb);
 		goto errout_ifa;
 	}
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_KERNEL);
 errout_ifa:
 	in6_ifa_put(ifa);
 errout:
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index a8f6986..597e0eb 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -580,7 +580,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		goto out;
 	}
 
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_KERNEL);
 out:
 	return err;
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 487ef3b..135ba15 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -850,7 +850,8 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
 			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
 			((struct nlmsgerr *)nlmsg_data(nlh))->error = -ETIMEDOUT;
-			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid,
+				     gfp_any());
 		} else
 			kfree_skb(skb);
 	}
@@ -1114,7 +1115,8 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 				skb_trim(skb, nlh->nlmsg_len);
 				((struct nlmsgerr *)nlmsg_data(nlh))->error = -EMSGSIZE;
 			}
-			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid,
+				     gfp_any());
 		} else
 			ip6_mr_forward(net, mrt, skb, c);
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4981755..81318a8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3367,7 +3367,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_KERNEL);
 errout:
 	return err;
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 627f898..9f2cde4 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1220,14 +1220,14 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 	return ret;
 }
 
-int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
-		    u32 portid, int nonblock)
+int __netlink_unicast(struct sock *ssk, struct sk_buff *skb, u32 portid,
+		      int nonblock, gfp_t allocation)
 {
 	struct sock *sk;
 	int err;
 	long timeo;
 
-	skb = netlink_trim(skb, gfp_any());
+	skb = netlink_trim(skb, allocation);
 
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:
@@ -1254,6 +1254,12 @@ retry:
 
 	return netlink_sendskb(sk, skb);
 }
+
+int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
+		    u32 portid, int nonblock)
+{
+	return __netlink_unicast(ssk, skb, portid, nonblock, gfp_any());
+}
 EXPORT_SYMBOL(netlink_unicast);
 
 int netlink_has_listeners(struct sock *sk, unsigned int group)
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 47ec230..b988a84 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -737,7 +737,7 @@ act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
 		return -EINVAL;
 	}
 
-	return rtnl_unicast(skb, net, portid);
+	return rtnl_unicast(skb, net, portid, GFP_KERNEL);
 }
 
 static struct tc_action *create_a(int i)
-- 
2.7.4
