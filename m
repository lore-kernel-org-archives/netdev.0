From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 1/5] openvswitch: Pad OVS_PACKET_ATTR_PACKET if linear copy was performed
Date: Tue,  4 Feb 2014 22:59:17 -0800
Message-ID: <1391583561-25399-2-git-send-email-jesse@nicira.com>
References: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Thomas Graf <tgraf@suug.ch>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:42504 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932174AbaBEG73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 01:59:29 -0500
Received: by mail-pd0-f181.google.com with SMTP id y10so9252443pdj.12
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 22:59:28 -0800 (PST)
In-Reply-To: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

While the zerocopy method is correctly omitted if user space
does not support unaligned Netlink messages. The attribute is
still not padded correctly as skb_zerocopy() will not ensure
padding and the attribute size is no longer pre calculated
though nla_reserve() which ensured padding previously.

This patch applies appropriate padding if a linear data copy
was performed in skb_zerocopy().

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index df46928..d1a73a6 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -466,6 +466,14 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 
 	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
+	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
+	if (!(dp->user_features & OVS_DP_F_UNALIGNED)) {
+		size_t plen = NLA_ALIGN(user_skb->len) - user_skb->len;
+
+		if (plen > 0)
+			memset(skb_put(user_skb, plen), 0, plen);
+	}
+
 	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
 	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
-- 
1.8.3.2
