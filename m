From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3 v2] net: Allow user to get table id from route lookup
Date: Wed,  2 Sep 2015 13:58:36 -0700
Message-ID: <1441227516-39692-3-git-send-email-dsa@cumulusnetworks.com>
References: <1441227516-39692-1-git-send-email-dsa@cumulusnetworks.com>
Cc: tgraf@suug.ch, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32820 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755810AbbIBU6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:58:52 -0400
Received: by pacex6 with SMTP id ex6so17613496pac.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:58:51 -0700 (PDT)
In-Reply-To: <1441227516-39692-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt_fill_info which is called for 'route get' requests hardcodes the
table id as RT_TABLE_MAIN which is not correct when multiple tables
are used. Use the newly added table id in the rtable to send back
the correct table similar to what is done for IPv6.

To maintain current ABI a new request flag, RTM_F_LOOKUP_TABLE, is
added to indicate the actual table is wanted versus the hardcoded
response.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- use a new request flag to indicate the real table id is wanted
  (suggested by Thomas)

 include/uapi/linux/rtnetlink.h |  1 +
 net/ipv4/route.c               | 12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 702024769c74..06625b401422 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -270,6 +270,7 @@ enum rt_scope_t {
 #define RTM_F_CLONED		0x200	/* This route is cloned		*/
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
 #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
+#define RTM_F_LOOKUP_TABLE	0x1000	/* set rtm_table to FIB lookup result */
 
 /* Reserved table identifiers */
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92acc95b7578..da427a4a33fe 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2305,7 +2305,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
+static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
 			u32 seq, int event, int nowait, unsigned int flags)
 {
@@ -2325,8 +2325,8 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
 	r->rtm_tos	= fl4->flowi4_tos;
-	r->rtm_table	= RT_TABLE_MAIN;
-	if (nla_put_u32(skb, RTA_TABLE, RT_TABLE_MAIN))
+	r->rtm_table	= table_id;
+	if (nla_put_u32(skb, RTA_TABLE, table_id))
 		goto nla_put_failure;
 	r->rtm_type	= rt->rt_type;
 	r->rtm_scope	= RT_SCOPE_UNIVERSE;
@@ -2431,6 +2431,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	int err;
 	int mark;
 	struct sk_buff *skb;
+	u32 table_id = RT_TABLE_MAIN;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy);
 	if (err < 0)
@@ -2500,7 +2501,10 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, dst, src, &fl4, skb,
+	if (rtm->rtm_flags & RTM_F_LOOKUP_TABLE)
+		table_id = rt->rt_table_id;
+
+	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
 			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err < 0)
-- 
1.9.1
