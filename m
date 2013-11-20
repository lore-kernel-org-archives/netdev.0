From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv3] net: core: Always propagate flag changes to interfaces
Date: Tue, 19 Nov 2013 20:47:15 -0500
Message-ID: <1384912035-17800-1-git-send-email-vyasevic@redhat.com>
Cc: s.priebe@profihost.ag, vfalico@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234Ab3KTBrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 20:47:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following commit:
    b6c40d68ff6498b7f63ddf97cf0aa818d748dee7
    net: only invoke dev->change_rx_flags when device is UP

tried to fix a problem with VLAN devices and promiscuouse flag setting.
The issue was that VLAN device was setting a flag on an interface that
was down, thus resulting in bad promiscuity count.
This commit blocked flag propagation to any device that is currently
down.

A later commit:
    deede2fabe24e00bd7e246eb81cd5767dc6fcfc7
    vlan: Don't propagate flag changes on down interfaces

fixed VLAN code to only propagate flags when the VLAN interface is up,
thus fixing the same issue as above, only localized to VLAN.

The problem we have now is that if we have create a complex stack
involving multiple software devices like bridges, bonds, and vlans,
then it is possible that the flags would not propagate properly to
the physical devices.  A simple examle of the scenario is the
following:

  eth0----> bond0 ----> bridge0 ---> vlan50

If bond0 or eth0 happen to be down at the time bond0 is added to
the bridge, then eth0 will never have promisc mode set which is
currently required for operation as part of the bridge.  As a
result, packets with vlan50 will be dropped by the interface.

The only 2 devices that implement the special flag handling are
VLAN and DSA and they both have required code to prevent incorrect
flag propagation.  As a result we can remove the generic solution
introduced in b6c40d68ff6498b7f63ddf97cf0aa818d748dee7 and leave
it to the individual devices to decide whether they will block
flag propagation or not.

Reported-by: Stefan Priebe <s.priebe@profihost.ag>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
v2->v3:  Removed a strange chunk that modified comments.  Not sure where it
         came from.

 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 974143d..da9c5e1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4991,7 +4991,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
-	if ((dev->flags & IFF_UP) && ops->ndo_change_rx_flags)
+	if (ops->ndo_change_rx_flags)
 		ops->ndo_change_rx_flags(dev, flags);
 }
 
-- 
1.8.4.2
