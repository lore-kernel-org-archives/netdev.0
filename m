From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 2/4] openvswitch: supply a dummy err_handler of gre_cisco_protocol to prevent kernel crash
Date: Mon, 30 Jun 2014 23:34:33 -0700
Message-ID: <1404196473-5158-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Wei Zhang <asuka.com@163.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:39929 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752003AbaGAGeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 02:34:36 -0400
Received: by mail-pa0-f47.google.com with SMTP id kq14so10018560pab.34
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 23:34:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Zhang <asuka.com@163.com>

When use gre vport, openvswitch register a gre_cisco_protocol but
does not supply a err_handler with it. The gre_cisco_err() in
net/ipv4/gre_demux.c expect err_handler be provided with the
gre_cisco_protocol implementation, and call ->err_handler() without
existence check, cause the kernel crash.

This patch provide a err_handler to fix this bug.
This bug introduced by commit aa310701e787087d (openvswitch: Add gre
tunnel support.)

Signed-off-by: Wei Zhang <asuka.com@163.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-gre.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 35ec4fe..f49148a 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -110,6 +110,22 @@ static int gre_rcv(struct sk_buff *skb,
 	return PACKET_RCVD;
 }
 
+/* Called with rcu_read_lock and BH disabled. */
+static int gre_err(struct sk_buff *skb, u32 info,
+		   const struct tnl_ptk_info *tpi)
+{
+	struct ovs_net *ovs_net;
+	struct vport *vport;
+
+	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
+	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
+
+	if (unlikely(!vport))
+		return PACKET_REJECT;
+	else
+		return PACKET_RCVD;
+}
+
 static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
@@ -186,6 +202,7 @@ error:
 
 static struct gre_cisco_protocol gre_protocol = {
 	.handler        = gre_rcv,
+	.err_handler    = gre_err,
 	.priority       = 1,
 };
 
-- 
1.9.3
