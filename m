From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Fix erratic behavior in rt6_dump_route()
Date: Mon, 17 Nov 2003 12:11:52 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0311171155050.21177@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

===== net/ipv6/route.c 1.60 vs edited =====
Hi Dave!

I noticed some erratic behavior when doing "ip -6 r". I traced the problem
to rt6_dump_route() where we typecast NLMSG_DATA() to a rtmsg without
checking the size of the netlink message first. Seems like ip only passes
a rtgenmsg to the kernel when it does a dump, so we end up reading pure
garbage when we interpret it as a rtmsg. Please apply the patch!

Thanks,
Ville

--- 1.60/net/ipv6/route.c	Tue Nov 11 09:09:55 2003
+++ edited/net/ipv6/route.c	Mon Nov 17 11:10:21 2003
@@ -1558,13 +1558,13 @@
 static int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
-	struct rtmsg *rtm;
 	int prefix;

-	rtm = NLMSG_DATA(arg->cb->nlh);
-	if (rtm)
+	if (arg->cb->nlh->nlmsg_len >= NLMSG_LENGTH(sizeof(struct rtmsg))) {
+		struct rtmsg *rtm = NLMSG_DATA(arg->cb->nlh);
 		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
-	else prefix = 0;
+	} else
+		prefix = 0;

 	return rt6_fill_node(arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq,

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
