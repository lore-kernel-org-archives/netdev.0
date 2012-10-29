From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: introduce ip6_rt_put()
Date: Mon, 29 Oct 2012 17:55:21 +0800
Message-ID: <1351504521-15003-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755245Ab2J2Jz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 05:55:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Eric, we could introduce a helper function
for ipv6 too, to avoid checking if rt is NULL before
dst_release().

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 20210d7..d1327e4 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -213,6 +213,15 @@ static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 	dst_hold(new);
 }
 
+static inline void ip6_rt_put(struct rt6_info *rt)
+{
+	/* dst_release() accepts a NULL parameter.
+	 * We rely on dst being first structure in struct rt6_info
+	 */
+	BUILD_BUG_ON(offsetof(struct rt6_info, dst) != 0);
+	dst_release(&rt->dst);
+}
+
 struct fib6_walker_t {
 	struct list_head lh;
 	struct fib6_node *root, *node;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f0b12a..690a6ab 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -699,7 +699,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 		pr_warn("Freeing alive inet6 address %p\n", ifp);
 		return;
 	}
-	dst_release(&ifp->rt->dst);
+	ip6_rt_put(&ifp->rt);
 
 	kfree_rcu(ifp, rcu);
 }
@@ -951,7 +951,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 				rt6_set_expires(rt, expires);
 			}
 		}
-		dst_release(&rt->dst);
+		ip6_rt_put(rt);
 	}
 
 	/* clean up prefsrc entries */
@@ -2027,8 +2027,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
 					      dev, expires, flags);
 		}
-		if (rt)
-			dst_release(&rt->dst);
+		ip6_rt_put(rt);
 	}
 
 	/* Try to figure out our local address for this prefix */
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index d9fb911..2e1a432 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -100,7 +100,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 		goto out;
 	}
 again:
-	dst_release(&rt->dst);
+	ip6_rt_put(rt);
 	rt = NULL;
 	goto out;
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 92f8e48..b19ed51 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -163,7 +163,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->dst.dev;
-			dst_release(&rt->dst);
+			ip6_rt_put(rt);
 		}
 	} else
 		dev = dev_get_by_index_rcu(net, ifindex);
@@ -260,7 +260,7 @@ static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
 
 		if (rt) {
 			dev = rt->dst.dev;
-			dst_release(&rt->dst);
+			ip6_rt_put(rt);
 		}
 	} else
 		dev = dev_get_by_index_rcu(net, ifindex);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ff36194..ae0cf81 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1145,7 +1145,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			ND_PRINTK(0, err,
 				  "RA: %s got default router without neighbour\n",
 				  __func__);
-			dst_release(&rt->dst);
+			ip6_rt_put(rt);
 			return;
 		}
 	}
@@ -1170,7 +1170,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			ND_PRINTK(0, err,
 				  "RA: %s got default router without neighbour\n",
 				  __func__);
-			dst_release(&rt->dst);
+			ip6_rt_put(rt);
 			return;
 		}
 		neigh->flags |= NTF_ROUTER;
@@ -1326,8 +1326,7 @@ skip_routeinfo:
 		ND_PRINTK(2, warn, "RA: invalid RA options\n");
 	}
 out:
-	if (rt)
-		dst_release(&rt->dst);
+	ip6_rt_put(rt);
 	if (neigh)
 		neigh_release(neigh);
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c42650c..d9badb2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -732,7 +732,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		else
 			rt6_set_expires(rt, jiffies + HZ * lifetime);
 
-		dst_release(&rt->dst);
+		ip6_rt_put(rt);
 	}
 	return 0;
 }
@@ -948,7 +948,7 @@ restart:
 	else
 		goto out2;
 
-	dst_release(&rt->dst);
+	ip6_rt_put(rt);
 	rt = nrt ? : net->ipv6.ip6_null_entry;
 
 	dst_hold(&rt->dst);
@@ -965,7 +965,7 @@ restart:
 	 * Race condition! In the gap, when table->tb6_lock was
 	 * released someone could insert this route.  Relookup.
 	 */
-	dst_release(&rt->dst);
+	ip6_rt_put(rt);
 	goto relookup;
 
 out:
@@ -1576,7 +1576,7 @@ int ip6_route_add(struct fib6_config *cfg)
 				goto out;
 			if (dev) {
 				if (dev != grt->dst.dev) {
-					dst_release(&grt->dst);
+					ip6_rt_put(grt);
 					goto out;
 				}
 			} else {
@@ -1587,7 +1587,7 @@ int ip6_route_add(struct fib6_config *cfg)
 			}
 			if (!(grt->rt6i_flags & RTF_GATEWAY))
 				err = 0;
-			dst_release(&grt->dst);
+			ip6_rt_put(grt);
 
 			if (err)
 				goto out;
@@ -1673,7 +1673,7 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	write_unlock_bh(&table->tb6_lock);
 
 out:
-	dst_release(&rt->dst);
+	ip6_rt_put(rt);
 	return err;
 }
 
@@ -2726,7 +2726,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb) {
-		dst_release(&rt->dst);
+		ip6_rt_put(rt);
 		err = -ENOBUFS;
 		goto errout;
 	}
