From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] e1000: Fix for e1000 kills IPMI on a tagged vlan.
Date: Mon, 31 Aug 2009 17:12:51 -0700
Message-ID: <20090901001250.31418.88709.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Dave Graham <david.graham@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:59803 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752053AbZIAANJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 20:13:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graham, David <david.graham@intel.com>

Enabling VLAN filters (VFE) when the primary interface is brought up
(per commit 78ed11a) has caused problems for some users who manage
their systems using IPMI over a VLAN. This is because when the driver
enables the VLAN filter, this same filter table is enabled for the
management channel, and the table is initially empty, which means that
the IPMI/VLAN packets are filtered out and not received by the BMC.
This is a problem only on e1000 class adapters, as it is only
on e1000 that the filter table is common to the management and host
streams.

With this change, filtering is only enabled when one or more host VLANs
exist, and is disabled when the last host VLAN is removed. VLAN filtering
is always disabled when the primary interface is in promiscuous mode,
and will be (re)enabled if VLANs exist when the interface exits
promiscuous mode.

Note that this does not completely resolve the issue for those using VLAN
management, because if the host adds a VLAN, then the above problem
occurs when that VLAN is enabled. However, it does mean the there is no
problem for configurations where management is on a VLAN and the host is
not.

A complete solution to this issue would require further driver changes.
The driver would need to discover if (and which) management VLANs are
active before enabling VLAN filtering, so that it could ensure that the
managed VLANs are included in the VLAN filter table. This discovery
requires that the BMC identifies its VLAN in registers accessible
to the driver, and at least on Dell PE2850 systems the BMC does not
identify its VLAN to allow such discovery. Intel is pursuing this issue
with the BMC vendor.

Signed-off-by: Dave Graham <david.graham@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d7df00c..4bdbadc 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2401,7 +2401,9 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			rctl &= ~E1000_RCTL_MPE;
 		}
 		if (adapter->hw.mac_type != e1000_ich8lan)
-			rctl |= E1000_RCTL_VFE;
+			/* Enable VLAN filter if there is a VLAN */
+			if (adapter->vlgrp)
+				rctl |= E1000_RCTL_VFE;
 	}
 
 	if (netdev->uc.count > rar_entries - 1) {
@@ -4854,6 +4856,8 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 			/* enable VLAN receive filtering */
 			rctl = er32(RCTL);
 			rctl &= ~E1000_RCTL_CFIEN;
+	                if (!(netdev->flags & IFF_PROMISC))
+				rctl |= E1000_RCTL_VFE;
 			ew32(RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
 		}
@@ -4864,6 +4868,11 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		ew32(CTRL, ctrl);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
+			/* disable VLAN receive filtering */
+			rctl = er32(RCTL);
+			rctl &= ~E1000_RCTL_VFE;
+			ew32(RCTL, rctl);
+
 			if (adapter->mng_vlan_id !=
 			    (u16)E1000_MNG_VLAN_NONE) {
 				e1000_vlan_rx_kill_vid(netdev,

