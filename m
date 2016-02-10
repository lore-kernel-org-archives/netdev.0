From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] lwt: fix rx checksum setting for lwt devices tunneling over ipv6
Date: Wed, 10 Feb 2016 16:47:21 +0100
Message-ID: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Benc <jbenc@redhat.com>,
	Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbcBJPru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 10:47:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the commit 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be
correctly controlled.") changed the default xmit checksum setting
for lwt vxlan/geneve ipv6 tunnels, so that now the checksum is not
set into external UDP header.
This commit changes the rx checksum setting for both lwt vxlan/geneve
devices created by openvswitch accordingly, so that lwt over ipv6
tunnel pairs are again able to communicate with default values.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/geneve.c          | 3 ++-
 net/openvswitch/vport-vxlan.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 0b14ac3..d8d8f33 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1441,7 +1441,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 		return dev;
 
 	err = geneve_configure(net, dev, &geneve_remote_unspec,
-			       0, 0, 0, htons(dst_port), true, 0);
+			       0, 0, 0, htons(dst_port), true,
+			       GENEVE_F_UDP_ZERO_CSUM6_RX);
 	if (err) {
 		free_netdev(dev);
 		return ERR_PTR(err);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 1605691..d933cb8 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -90,7 +90,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	int err;
 	struct vxlan_config conf = {
 		.no_share = true,
-		.flags = VXLAN_F_COLLECT_METADATA,
+		.flags = VXLAN_F_COLLECT_METADATA | VXLAN_F_UDP_ZERO_CSUM6_RX,
 	};
 
 	if (!options) {
-- 
1.8.3.1
