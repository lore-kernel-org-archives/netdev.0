From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX lowerdev
Date: Sat, 28 Dec 2013 14:38:40 +0100
Message-ID: <1388237920-5140-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:58134 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755356Ab3L1Nl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 08:41:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 797f87f83b60685ff8a13fa0572d2f10393c50d3
(macvlan: fix netdev feature propagation from lower device) can result
in oops:

[   81.011639] 8021q: adding VLAN 0 to HW filter on device wan0
[   81.030402] BUG: unable to handle kernel NULL pointer dereference at 00000000000001e0
[   81.032267] IP: [<ffffffff813269d0>] macvlan_hard_header+0x40/0x60
[..]
[   81.034359] RIP: 0010:[<ffffffff813269d0>]  [<ffffffff813269d0>] macvlan_hard_header+0x40/0x60
[..]
[   81.034359]  <IRQ> 
[   81.034359]  [<ffffffff8139c7ed>] ? neigh_resolve_output+0x16d/0x2b0
[   81.034359]  [<ffffffff81484246>] ? ip6_finish_output2+0x176/0x600
[   81.034359]  [<ffffffff81484246>] ip6_finish_output2+0x176/0x600
[   81.034359]  [<ffffffff81484129>] ? ip6_finish_output2+0x59/0x600
[   81.034359]  [<ffffffff814865c6>] ip6_finish_output+0x96/0x1f0
[   81.034359]  [<ffffffff81486773>] ip6_output+0x53/0x1c0
[   81.034359]  [<ffffffff814a7dc2>] mld_sendpack+0x2b2/0x330
[   81.034359]  [<ffffffff814a8774>] mld_ifc_timer_expire+0x194/0x2c0

...if the lower device supports NETIF_F_HW_VLAN_CTAG_TX flag and a vlan
is created on top of the macvlan device, i.e.

ip link add link eth0 name wan0 type macvlan
ip link add link wan0 name wan1 type vlan id 2
ip link set wan0 up

reason is that 8021q sets dev->header_ops to the realdev in
'NETIF_F_HW_VLAN_CTAG_TX present' case - but macvlan_heard_header
assumes that the *dev pointer passed is a macvlan device.

But thats not the case in the above scenario.
macvlan_hard_header is invokes with *dev being the 8021q interface,
which then oopses since the netdev_priv area is something completely different.

Cap lowerdev feature set to the one explicitly set via MACVLAN_FEATURES
before trying to increment any features.

Fixes: 797f87f83b ("macvlan: fix netdev feature propagation from lower device")
Reported-by: Will Trives <renevant@internode.on.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 WARNING: I am not sure this is correct.

 We lose flags that the lowerdev of the macvlan could handle.

 What 8021q is doing in net/8021q/vlan_dev.c:vlan_dev_init seems strange to me.

 Where does it say that is ok to just do
  dev->header_ops      = real_dev->header_ops;

 and then assume that header_ops->create() et al. will cope
 with dev being a 8021q device instead of real_dev?

 To me this was completely unexpected.

 Or is the real bug the use of netdev_priv in macvlan_hard_header()?

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 60406b0..cd2791b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -690,13 +690,13 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 					      netdev_features_t features)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	netdev_features_t mask;
+	netdev_features_t mask, lowerdev_features;
 
-	features |= NETIF_F_ALL_FOR_ALL;
 	features &= (vlan->set_features | ~MACVLAN_FEATURES);
+	lowerdev_features = vlan->lowerdev->features & MACVLAN_FEATURES;
 	mask = features;
 
-	features = netdev_increment_features(vlan->lowerdev->features,
+	features = netdev_increment_features(lowerdev_features,
 					     features,
 					     mask);
 	if (!vlan->fwd_priv)
-- 
1.8.1.5
