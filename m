From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC 2/3] net: Support IFLA_ENV_HDR_LEN to configure max envelope header length
Date: Tue, 27 Sep 2016 17:55:38 +0900
Message-ID: <1474966541-4420-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:54963 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752885AbcI0I64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 04:58:56 -0400
In-Reply-To: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this change, admin can configure env_hdr_len.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 16 ++++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b4fba66..9545ea4 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_ENV_HDR_LEN,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3ac8946..9233709 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -943,7 +943,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + rtnl_xdp_size(dev) /* IFLA_XDP */
-	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
+	       + nla_total_size(1) /* IFLA_PROTO_DOWN */
+	       + nla_total_size(4); /* IFLA_ENV_HDR_LEN */
 
 }
 
@@ -1321,7 +1322,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
 	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
 			atomic_read(&dev->carrier_changes)) ||
-	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
+	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down) ||
+	    nla_put_u32(skb, IFLA_ENV_HDR_LEN, netif_get_env_hdr_len(dev)))
 		goto nla_put_failure;
 
 	if (rtnl_fill_link_ifmap(skb, dev))
@@ -1458,6 +1460,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
 	[IFLA_XDP]		= { .type = NLA_NESTED },
+	[IFLA_ENV_HDR_LEN]	= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -2174,6 +2177,13 @@ static int do_setlink(const struct sk_buff *skb,
 		}
 	}
 
+	if (tb[IFLA_ENV_HDR_LEN]) {
+		err = dev_set_env_hdr_len(dev, nla_get_u32(tb[IFLA_ENV_HDR_LEN]));
+		if (err < 0)
+			goto errout;
+		status |= DO_SETLINK_MODIFIED;
+	}
+
 errout:
 	if (status & DO_SETLINK_MODIFIED) {
 		if (status & DO_SETLINK_NOTIFY)
@@ -2378,6 +2388,8 @@ struct net_device *rtnl_create_link(struct net *net,
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
 	if (tb[IFLA_GROUP])
 		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
+	if (tb[IFLA_ENV_HDR_LEN])
+		dev->env_hdr_len = nla_get_u32(tb[IFLA_ENV_HDR_LEN]);
 
 	return dev;
 
-- 
1.8.3.1
