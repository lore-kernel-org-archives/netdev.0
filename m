From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net] team: team should sync the port's uc/mc addrs when add a port
Date: Wed, 30 Mar 2016 10:58:39 +0800
Message-ID: <e7eed00cdf5b0bf2d7eda4364f0fd28e95028db8.1459306719.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34495 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbcC3C6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 22:58:43 -0400
Received: by mail-pa0-f44.google.com with SMTP id fe3so28889550pab.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 19:58:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is an issue when we use mavtap over team:
When we replug nic links from team0, the real nics's mc list will not
include the maddr for macvtap any more. then we can't receive pkts to
macvtap device, as they are filterred by mc list of nic.

In Bonding Driver, it syncs the uc/mc addrs in bond_enslave().

We will fix this issue on team by adding the port's uc/mc addrs sync in
team_port_add.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/team/team.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 26c64d2..a0f64cb 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1198,6 +1198,9 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_dev_open;
 	}
 
+	dev_uc_sync_multiple(port_dev, dev);
+	dev_mc_sync_multiple(port_dev, dev);
+
 	err = vlan_vids_add_by_dev(port_dev, dev);
 	if (err) {
 		netdev_err(dev, "Failed to add vlan ids to device %s\n",
@@ -1261,6 +1264,8 @@ err_enable_netpoll:
 	vlan_vids_del_by_dev(port_dev, dev);
 
 err_vids_add:
+	dev_uc_unsync(port_dev, dev);
+	dev_mc_unsync(port_dev, dev);
 	dev_close(port_dev);
 
 err_dev_open:
-- 
2.1.0
