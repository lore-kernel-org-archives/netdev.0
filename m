From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] rtnetlink: fix userspace API breakage for iproute2 < v3.9.0
Date: Wed, 28 May 2014 14:15:19 +0200
Message-ID: <1401279319-29088-1-git-send-email-mschmidt@redhat.com>
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Michael Riesch <michael.riesch@omicron.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbaE1MPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 08:15:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running RHEL6 userspace on a current upstream kernel, "ip link"
fails to show VF information.

The reason is a kernel<->userspace API change introduced by commit
88c5b5ce5cb57 ("rtnetlink: Call nlmsg_parse() with correct header length"),
after which the kernel does not see iproute2's IFLA_EXT_MASK attribute
in the netlink request.

iproute2 adjusted for the API change in its commit 63338dca4513
("libnetlink: Use ifinfomsg instead of rtgenmsg in rtnl_wilddump_req_filter").

The problem has been noticed before:
http://marc.info/?l=linux-netdev&m=136692296022182&w=2
(Subject: Re: getting VF link info seems to be broken in 3.9-rc8)

We can do better than tell those with old userspace to upgrade. We can
recognize the old iproute2 in the kernel by checking the netlink message
length. Even when including the IFLA_EXT_MASK attribute, its netlink
message is shorter than struct ifinfomsg.

With this patch "ip link" shows VF information in both old and new
iproute2 versions.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 net/core/rtnetlink.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2d8d8fc..750119b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1234,6 +1234,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	struct nlattr *tb[IFLA_MAX+1];
 	u32 ext_filter_mask = 0;
 	int err;
+	int hdrlen;
 
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
@@ -1241,8 +1242,17 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 	cb->seq = net->dev_base_seq;
 
-	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
-			ifla_policy) >= 0) {
+	/* A hack to preserve kernel<->userspace interface.
+	 * The correct header is ifinfomsg. It is consistent with rtnl_getlink.
+	 * However, before Linux v3.9 the code here assumed rtgenmsg and that's
+	 * what iproute2 < v3.9.0 used.
+	 * We can detect the old iproute2. Even including the IFLA_EXT_MASK
+	 * attribute, its netlink message is shorter than struct ifinfomsg.
+	 */
+	hdrlen = nlmsg_len(cb->nlh) < sizeof(struct ifinfomsg) ?
+		 sizeof(struct rtgenmsg) : sizeof(struct ifinfomsg);
+
+	if (nlmsg_parse(cb->nlh, hdrlen, tb, IFLA_MAX, ifla_policy) >= 0) {
 
 		if (tb[IFLA_EXT_MASK])
 			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
@@ -2095,9 +2105,13 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[IFLA_MAX+1];
 	u32 ext_filter_mask = 0;
 	u16 min_ifinfo_dump_size = 0;
+	int hdrlen;
+
+	/* Same kernel<->userspace interface hack as in rtnl_dump_ifinfo. */
+	hdrlen = nlmsg_len(nlh) < sizeof(struct ifinfomsg) ?
+		 sizeof(struct rtgenmsg) : sizeof(struct ifinfomsg);
 
-	if (nlmsg_parse(nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
-			ifla_policy) >= 0) {
+	if (nlmsg_parse(nlh, hdrlen, tb, IFLA_MAX, ifla_policy) >= 0) {
 		if (tb[IFLA_EXT_MASK])
 			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
 	}
-- 
1.9.3
