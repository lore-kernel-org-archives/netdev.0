From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2] lwt: fix rx checksum setting for lwt devices tunneling over ipv6
Date: Wed, 17 Feb 2016 19:30:01 +0100
Message-ID: <244994c83cb73d98205f39aaefcee846dab48260.1455731463.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Jiri Benc <jbenc@redhat.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932113AbcBQSaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 13:30:15 -0500
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
v2: rebased against current -net
---
 drivers/net/geneve.c          | 3 ++-
 net/openvswitch/vport-vxlan.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 028e387..3496d78 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1452,7 +1452,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 		return dev;
 
 	err = geneve_configure(net, dev, &geneve_remote_unspec,
-			       0, 0, 0, htons(dst_port), true, 0);
+			       0, 0, 0, htons(dst_port), true,
+			       GENEVE_F_UDP_ZERO_CSUM6_RX);
 	if (err)
 		goto err;
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index de9cb19..5eb7694 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -90,7 +90,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	int err;
 	struct vxlan_config conf = {
 		.no_share = true,
-		.flags = VXLAN_F_COLLECT_METADATA,
+		.flags = VXLAN_F_COLLECT_METADATA | VXLAN_F_UDP_ZERO_CSUM6_RX,
 		/* Don't restrict the packets that can be sent by MTU */
 		.mtu = IP_MAX_MTU,
 	};
-- 
1.8.3.1
