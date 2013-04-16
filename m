From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 07/10] openvswitch: Don't insert empty OVS_VPORT_ATTR_OPTIONS attribute
Date: Tue, 16 Apr 2013 14:00:16 -0700
Message-ID: <1366146019-9015-8-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:36454 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965290Ab3DPVA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:00:28 -0400
Received: by mail-pa0-f71.google.com with SMTP id fb10so795015pad.6
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:00:22 -0700 (PDT)
In-Reply-To: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

The port specific options are currently unused resulting in an
empty OVS_VPORT_ATTR_OPTIONS nested attribute being inserted
into every OVS_VPORT_CMD_GET message.

Don't insert OVS_VPORT_ATTR_OPTIONS if no options are present.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index f6b8132..71a2de8 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -301,17 +301,19 @@ void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
 {
 	struct nlattr *nla;
+	int err;
+
+	if (!vport->ops->get_options)
+		return 0;
 
 	nla = nla_nest_start(skb, OVS_VPORT_ATTR_OPTIONS);
 	if (!nla)
 		return -EMSGSIZE;
 
-	if (vport->ops->get_options) {
-		int err = vport->ops->get_options(vport, skb);
-		if (err) {
-			nla_nest_cancel(skb, nla);
-			return err;
-		}
+	err = vport->ops->get_options(vport, skb);
+	if (err) {
+		nla_nest_cancel(skb, nla);
+		return err;
 	}
 
 	nla_nest_end(skb, nla);
-- 
1.7.10.4
