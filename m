From: David Wragg <david@weave.works>
Subject: [PATCH net 2/2] vxlan: Set a large MTU on ovs-created vxlan devices
Date: Wed,  6 Jan 2016 13:33:06 +0000
Message-ID: <1452087186-12926-3-git-send-email-david@weave.works>
References: <1452087186-12926-1-git-send-email-david@weave.works>
Cc: David Wragg <david@weave.works>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35055 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbcAFNdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 08:33:20 -0500
Received: by mail-wm0-f45.google.com with SMTP id f206so59615020wmf.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 05:33:19 -0800 (PST)
In-Reply-To: <1452087186-12926-1-git-send-email-david@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to 4.3, vxlan vports could transmit vxlan packets of any size,
constrained only by the ability to transmit the resulting UDP packets.
4.3 introduced vxlan netdevs corresponding to vxlan vports.  These
netdevs have an MTU, which limits the size of a packet that can be
successfully vxlan-encapsulated.  The default value for this MTU is
1500, which is awkwardly small, and leads to a conspicuous change in
behaviour for userspace.

This sets the MTU on openvswitch-created vxlan devices to be 65465
(the maximum IP packet size minus the vxlan-on-IPv6 overhead),
effectively restoring the behaviour prior to 4.3.  Although the
vxlan_config struct already had a mtu field for this,
vxlan_dev_configure mostly ignored it; that is also addressed here.

Signed-off-by: David Wragg <david@weave.works>
---
 drivers/net/vxlan.c           | 11 ++++++++---
 net/openvswitch/vport-vxlan.c |  2 ++
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 96d1c55..a15d300 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2764,6 +2764,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	int err;
 	bool use_ipv6 = false;
 	__be16 default_port = vxlan->cfg.dst_port;
+	struct net_device *lowerdev = NULL;
 
 	vxlan->net = src_net;
 
@@ -2784,9 +2785,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	}
 
 	if (conf->remote_ifindex) {
-		struct net_device *lowerdev
-			 = __dev_get_by_index(src_net, conf->remote_ifindex);
-
+		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
 		dst->remote_ifindex = conf->remote_ifindex;
 
 		if (!lowerdev) {
@@ -2810,6 +2809,12 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		needed_headroom = lowerdev->hard_header_len;
 	}
 
+	if (conf->mtu) {
+		err = __vxlan_change_mtu(dev, lowerdev, dst, conf->mtu);
+		if (err)
+			return err;
+	}
+
 	if (use_ipv6 || conf->flags & VXLAN_F_COLLECT_METADATA)
 		needed_headroom += VXLAN6_HEADROOM;
 	else
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 1605691..a97279f 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -91,6 +91,8 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	struct vxlan_config conf = {
 		.no_share = true,
 		.flags = VXLAN_F_COLLECT_METADATA,
+		/* The maximum VXLAN payload to fit in an IPv6 packet */
+		.mtu = 65535 - VXLAN6_HEADROOM,
 	};
 
 	if (!options) {
-- 
2.5.0
