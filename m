From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] vlan: Correctly propagate promisc|allmulti flags in notifier.
Date: Tue, 12 May 2015 20:53:14 -0400
Message-ID: <1431478394-8257-1-git-send-email-vyasevic@redhat.com>
Cc: kaber@trash.net, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:34132 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933877AbbEMAxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 20:53:24 -0400
Received: by qcyk17 with SMTP id k17so14612205qcy.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 17:53:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently vlan notifier handler will try to update all vlans
for a device when that device comes up.  A problem occurs,
however, when the vlan device was set to promiscuous, but not
by the user (ex: a bridge).  In that case, dev->gflags are
not updated.  What results is that the lower device ends
up with an extra promiscuity count.  Here are the
backtraces that prove this:
[62852.052179]  [<ffffffff814fe248>] __dev_set_promiscuity+0x38/0x1e0
[62852.052186]  [<ffffffff8160bcbb>] ? _raw_spin_unlock_bh+0x1b/0x40
[62852.052188]  [<ffffffff814fe4be>] ? dev_set_rx_mode+0x2e/0x40
[62852.052190]  [<ffffffff814fe694>] dev_set_promiscuity+0x24/0x50
[62852.052194]  [<ffffffffa0324795>] vlan_dev_open+0xd5/0x1f0 [8021q]
[62852.052196]  [<ffffffff814fe58f>] __dev_open+0xbf/0x140
[62852.052198]  [<ffffffff814fe88d>] __dev_change_flags+0x9d/0x170
[62852.052200]  [<ffffffff814fe989>] dev_change_flags+0x29/0x60

The above comes from the setting the vlan device to IFF_UP state.

[62852.053569]  [<ffffffff814fe248>] __dev_set_promiscuity+0x38/0x1e0
[62852.053571]  [<ffffffffa032459b>] ? vlan_dev_set_rx_mode+0x2b/0x30
[8021q]
[62852.053573]  [<ffffffff814fe8d5>] __dev_change_flags+0xe5/0x170
[62852.053645]  [<ffffffff814fe989>] dev_change_flags+0x29/0x60
[62852.053647]  [<ffffffffa032334a>] vlan_device_event+0x18a/0x690
[8021q]
[62852.053649]  [<ffffffff8161036c>] notifier_call_chain+0x4c/0x70
[62852.053651]  [<ffffffff8109d456>] raw_notifier_call_chain+0x16/0x20
[62852.053653]  [<ffffffff814f744d>] call_netdevice_notifiers+0x2d/0x60
[62852.053654]  [<ffffffff814fe1a3>] __dev_notify_flags+0x33/0xa0
[62852.053656]  [<ffffffff814fe9b2>] dev_change_flags+0x52/0x60
[62852.053657]  [<ffffffff8150cd57>] do_setlink+0x397/0xa40

And this one comes from the notification code.  What we end
up with is a vlan with promiscuity count of 1 and and a physical
device with a promiscuity count of 2.  They should both have
a count 1.

To resolve this issue, vlan code can use dev_get_flags() api
which correctly masks promiscuity and allmulti flags.

Sign-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/8021q/vlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 98a30a5..59555f0 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -443,7 +443,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	case NETDEV_UP:
 		/* Put all VLANs for this dev in the up state too.  */
 		vlan_group_for_each_dev(grp, i, vlandev) {
-			flgs = vlandev->flags;
+			flgs = dev_get_flags(vlandev);
 			if (flgs & IFF_UP)
 				continue;
 
-- 
1.9.3
