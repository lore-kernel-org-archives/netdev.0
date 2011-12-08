From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 6/6] team: use vlan_vids_[addr/del]_by_dev
Date: Thu,  8 Dec 2011 15:11:20 +0100
Message-ID: <1323353480-1900-7-git-send-email-jpirko@redhat.com>
References: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404Ab1LHOLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 09:11:50 -0500
In-Reply-To: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far when vlan id was added to team device befor port was added, this
vid was not added to port's vlan filter. Also after removal, vid stayed
in port device's vlan filter. Benefit of new vlan functions to handle
this work.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 79c2d1b..ed2a862 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -588,6 +588,13 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_dev_open;
 	}
 
+	err = vlan_vids_add_by_dev(port_dev, dev);
+	if (err) {
+		netdev_err(dev, "Failed to add vlan ids to device %s\n",
+				portname);
+		goto err_vids_add;
+	}
+
 	err = netdev_set_master(port_dev, dev);
 	if (err) {
 		netdev_err(dev, "Device %s failed to set master\n", portname);
@@ -615,6 +622,9 @@ err_handler_register:
 	netdev_set_master(port_dev, NULL);
 
 err_set_master:
+	vlan_vids_del_by_dev(port_dev, dev);
+
+err_vids_add:
 	dev_close(port_dev);
 
 err_dev_open:
@@ -648,6 +658,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	team_adjust_ops(team);
 	netdev_rx_handler_unregister(port_dev);
 	netdev_set_master(port_dev, NULL);
+	vlan_vids_del_by_dev(port_dev, dev);
 	dev_close(port_dev);
 	team_port_leave(team, port);
 	team_port_set_orig_mac(port);
-- 
1.7.6
