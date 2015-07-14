From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v7 2/4] netlink: changes for setting and clearing protodown via netlink.
Date: Tue, 14 Jul 2015 13:43:20 -0700
Message-ID: <1436906602-2958-3-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35835 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbbGNUnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 16:43:33 -0400
Received: by pactm7 with SMTP id tm7so11175144pac.2
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 13:43:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |    1 +
 net/core/rtnetlink.c         |   16 ++++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 2c7e8e3..24d68b7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -148,6 +148,7 @@ enum {
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
 	IFLA_PHYS_PORT_NAME,
+	IFLA_PROTO_DOWN,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 01ced4a..4104e27 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -896,7 +896,9 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
-	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_SWITCH_ID */
+	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
+	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
+
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -1082,7 +1084,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    (dev->ifalias &&
 	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
 	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
-			atomic_read(&dev->carrier_changes)))
+			atomic_read(&dev->carrier_changes)) ||
+	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
 		goto nla_put_failure;
 
 	if (1) {
@@ -1319,6 +1322,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
+	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1853,6 +1857,14 @@ static int do_setlink(const struct sk_buff *skb,
 	}
 	err = 0;
 
+	if (tb[IFLA_PROTO_DOWN]) {
+		err = dev_change_proto_down(dev,
+					    nla_get_u8(tb[IFLA_PROTO_DOWN]));
+		if (err)
+			goto errout;
+		status |= DO_SETLINK_NOTIFY;
+	}
+
 errout:
 	if (status & DO_SETLINK_MODIFIED) {
 		if (status & DO_SETLINK_NOTIFY)
-- 
1.7.10.4
