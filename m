From: Jan Moskyto Matejka <mq@ucw.cz>
Subject: [PATCH] net: ipv6: Truncate single route when it doesn't fit into dump buffer.
Date: Fri, 12 May 2017 13:15:10 +0200
Message-ID: <20170512111510.2697-1-mq@ucw.cz>
Cc: Jan Moskyto Matejka <mq@ucw.cz>, linux-kernel@vger.kernel.org,
        David Ahern <dsa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When rt6_fill_node() fails to fit the route into the buffer,
it drops the route, returns -EMSGSIZE and waits for buffer flush.
This condition is detected by non-null return value and non-empty
buffer; the buffer is flushed and rt6_fill_node() restarted.

However, when a single route generates such a long message that
it doesn't fit into the buffer itself, inet6_dump_fib() misinterprets
the non-null return value together with non-empty buffer as end of dump
and silently truncates the dump.

This patch fixes this by explicitly truncating the message and
inidicating it by NLM_F_TRUNC flag in its nlmsghdr.

Reproducer:
  # ip -6 route show
  ... it shows some routes
  # ip -6 route add fccc::/64 via fe80::ff:fe00:0 dev testdev table 2
  # for a in $(seq 1 1000); do
      ip -6 route append fccc::/64 via fe80::ff:fe00:$a dev testdev table 2
    done
  # ip -6 route show
  ... the output is truncated

This came to light by David Ahern's
commit beb1afac518dec5a15dc ("net: ipv6: Add support to dump multipath
routes via RTA_MULTIPATH attribute")
but obviously existed before, just hidden.

Signed-off-by: Jan Moskyto Matejka <mq@ucw.cz>
---
 include/net/ip6_route.h      |  2 +-
 include/uapi/linux/netlink.h |  1 +
 net/ipv6/ip6_fib.c           | 17 ++++++++++++++---
 net/ipv6/route.c             |  9 +++++++--
 net/netlink/af_netlink.c     |  7 ++++++-
 5 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 9dc2c182a263..9b035b6bdf8c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -156,7 +156,7 @@ struct rt6_rtnl_dump_arg {
 	struct net *net;
 };
 
-int rt6_dump_route(struct rt6_info *rt, void *p_arg);
+int rt6_dump_route(struct rt6_info *rt, void *p_arg, int truncate);
 void rt6_ifdown(struct net *net, struct net_device *dev);
 void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index f3946a27bd07..1d463dbf89db 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -56,6 +56,7 @@ struct nlmsghdr {
 #define NLM_F_ECHO		8	/* Echo this request 		*/
 #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
 #define NLM_F_DUMP_FILTERED	32	/* Dump was filtered as requested */
+#define NLM_F_TRUNC		64	/* Message truncated */
 
 /* Modifiers to GET request */
 #define NLM_F_ROOT	0x100	/* specify tree	root	*/
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d4bf2c68a545..4a962a61e559 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -310,13 +310,20 @@ static int fib6_dump_node(struct fib6_walker *w)
 {
 	int res;
 	struct rt6_info *rt;
+	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *)w->args;
 
 	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
-		res = rt6_dump_route(rt, w->args);
+		res = rt6_dump_route(rt, w->args, 0);
+		if (res < 0 && arg->skb->len == 0)
+			/* One single route is too long for buffer.
+			 * Will truncate it.
+			 */
+			res = rt6_dump_route(rt, w->args, 1);
+
 		if (res < 0) {
 			/* Frame is full, suspend walking */
 			w->leaf = rt;
-			return 1;
+			return res;
 		}
 
 		/* Multipath routes are dumped in one route with the
@@ -456,9 +463,14 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	cb->args[1] = e;
 	cb->args[0] = h;
 
-	res = res < 0 ? res : skb->len;
 	if (res <= 0)
 		fib6_dump_end(cb);
+
+	if (res == -EMSGSIZE && skb->len)
+		res = skb->len;
+	else
+		res = res < 0 ? res : skb->len;
+
 	return res;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fb174b590fd3..0adcbdba87a1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3539,11 +3539,16 @@ static int rt6_fill_node(struct net *net,
 	return 0;
 
 nla_put_failure:
+	if (flags & NLM_F_TRUNC) {
+		nlmsg_end(skb, nlh);
+		return 0;
+	}
+
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
 
-int rt6_dump_route(struct rt6_info *rt, void *p_arg)
+int rt6_dump_route(struct rt6_info *rt, void *p_arg, int truncate)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
 	struct net *net = arg->net;
@@ -3565,7 +3570,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 	return rt6_fill_node(net,
 		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
-		     NLM_F_MULTI);
+		     NLM_F_MULTI | (truncate ? NLM_F_TRUNC : 0));
 }
 
 static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 596eaff66649..f8102f976cad 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2177,7 +2177,12 @@ static int netlink_dump(struct sock *sk)
 		return 0;
 	}
 
-	nlh = nlmsg_put_answer(skb, cb, NLMSG_DONE, sizeof(len), NLM_F_MULTI);
+	if (len < 0)
+		nlh = nlmsg_put_answer(skb, cb, NLMSG_ERROR, sizeof(len), 0);
+	else
+		nlh = nlmsg_put_answer(skb, cb, NLMSG_DONE, sizeof(len),
+				       NLM_F_MULTI);
+
 	if (!nlh)
 		goto errout_skb;
 
-- 
2.11.0
