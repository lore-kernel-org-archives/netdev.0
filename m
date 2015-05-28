From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v2] openvswitch: disable LRO
Date: Thu, 28 May 2015 15:04:53 +0200
Message-ID: <cf405251e71318f7c7f8ddac07919acb8c28232e.1432818254.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Flavio Leitner <fbl@sysclose.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387AbbE1NFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 09:05:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, openvswitch tries to disable LRO from the user space. This does
not work correctly when the device added is a vlan interface, though.
Instead of dealing with possibly complex stacked cross name space relations
in the user space, do the same as bridging does and call dev_disable_lro in
the kernel.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v1->v2: Disable LRO unconditionally. If the feature that leaves LRO enabled
is implemented in the future in ovs user space, the conditional disablement
can be implemented in the kernel easily. There won't be any problem even
if such new ovs user space is run with older kernels, enabling LRO is just
an optimization.
---
 net/openvswitch/vport-netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4776282c6417..33e6d6e2908f 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -125,6 +125,7 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	if (err)
 		goto error_master_upper_dev_unlink;
 
+	dev_disable_lro(netdev_vport->dev);
 	dev_set_promiscuity(netdev_vport->dev, 1);
 	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
 	rtnl_unlock();
-- 
1.8.3.1
