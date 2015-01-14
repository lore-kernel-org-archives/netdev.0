From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] openvswitch: packet messages need their own probe
 attribtue
Date: Wed, 14 Jan 2015 13:56:19 +0000
Message-ID: <20150114135619.GC564@casper.infradead.org>
References: <1645184106.20150114131420@eikelenboom.it>
 <20150114130005.GA564@casper.infradead.org>
 <20150114130351.GB13716@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
	dev@openvswitch.org, jrajahalme@nicira.com
To: Florian Westphal <fw@strlen.de>, davem@davemloft.net,
	Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59160 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbbANN4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 08:56:21 -0500
Content-Disposition: inline
In-Reply-To: <20150114130351.GB13716@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User space is currently sending a OVS_FLOW_ATTR_PROBE for both flow
and packet messages. This leads to an out-of-bounds access in
ovs_packet_cmd_execute() because OVS_FLOW_ATTR_PROBE >
OVS_PACKET_ATTR_MAX.

Introduce a new OVS_PACKET_ATTR_PROBE with the same numeric value
as OVS_FLOW_ATTR_PROBE to grow the range of accepted packet attributes
while maintaining to be binary compatible with existing OVS binaries.

Fixes: 05da589 ("openvswitch: Add support for OVS_FLOW_ATTR_PROBE.")
Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Tracked-down-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/uapi/linux/openvswitch.h | 4 ++++
 net/openvswitch/datapath.c       | 3 ++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 3a6dcaa..f714e86 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -174,6 +174,10 @@ enum ovs_packet_attr {
 	OVS_PACKET_ATTR_USERDATA,    /* OVS_ACTION_ATTR_USERSPACE arg. */
 	OVS_PACKET_ATTR_EGRESS_TUN_KEY,  /* Nested OVS_TUNNEL_KEY_ATTR_*
 					    attributes. */
+	OVS_PACKET_ATTR_UNUSED1,
+	OVS_PACKET_ATTR_UNUSED2,
+	OVS_PACKET_ATTR_PROBE,      /* Packet operation is a feature probe,
+				       error logging should be suppressed. */
 	__OVS_PACKET_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4e9a5f0..b07349e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -524,7 +524,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct vport *input_vport;
 	int len;
 	int err;
-	bool log = !a[OVS_FLOW_ATTR_PROBE];
+	bool log = !a[OVS_PACKET_ATTR_PROBE];
 
 	err = -EINVAL;
 	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
@@ -610,6 +610,7 @@ static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
 	[OVS_PACKET_ATTR_PACKET] = { .len = ETH_HLEN },
 	[OVS_PACKET_ATTR_KEY] = { .type = NLA_NESTED },
 	[OVS_PACKET_ATTR_ACTIONS] = { .type = NLA_NESTED },
+	[OVS_PACKET_ATTR_PROBE] = { .type = NLA_FLAG },
 };
 
 static const struct genl_ops dp_packet_genl_ops[] = {
-- 
1.9.3
