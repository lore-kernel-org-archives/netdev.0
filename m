From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 12/16] net: Add ipv4 route helper to set next hop
Date: Mon, 27 Jul 2015 12:31:05 -0600
Message-ID: <1438021869-49186-13-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36053 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015AbbG0SdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:33:12 -0400
Received: by igbij6 with SMTP id ij6so83994580igb.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:33:11 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/route.h |  3 +++
 net/ipv4/route.c    | 10 ++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/net/route.h b/include/net/route.h
index b14cbec93fbd..900d50fbcfc7 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -107,6 +107,7 @@ struct rt_cache_stat {
 extern struct ip_rt_acct __percpu *ip_rt_acct;
 
 struct in_device;
+struct fib_result;
 
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
@@ -114,6 +115,8 @@ void rt_flush_dev(struct net_device *dev);
 struct rtable *ip_route_new_rtable(struct net_device *dev,
 				   unsigned int flags, u16 type,
 				   bool nopolicy, bool noxfrm, bool do_cache);
+void ip_route_set_nexthop(struct rtable *rt, __be32 daddr,
+			  const struct fib_result *res);
 struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 				    struct sock *sk);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 050a3c1d89ba..47dae001a000 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1537,6 +1537,16 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	return err;
 }
 
+void ip_route_set_nexthop(struct rtable *rt, __be32 daddr,
+			  const struct fib_result *res)
+{
+	struct fib_nh_exception *fnhe;
+
+	fnhe = find_exception(&FIB_RES_NH(*res), daddr);
+
+	rt_set_nexthop(rt, daddr, res, fnhe, res->fi, res->type, 0);
+}
+EXPORT_SYMBOL(ip_route_set_nexthop);
 
 static void ip_handle_martian_source(struct net_device *dev,
 				     struct in_device *in_dev,
-- 
2.3.2 (Apple Git-55)
