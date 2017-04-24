From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] bridge: shutdown bridge device before removing it
Date: Mon, 24 Apr 2017 15:25:30 +0800
Message-ID: <a8b2b2c876f416431dac031a0beb7ce079c7d0a9.1493018730.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35270 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760462AbdDXHZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:25:40 -0400
Received: by mail-it0-f68.google.com with SMTP id e132so14583638ite.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 00:25:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During removing a bridge device, if the bridge is still up, a new mdb entry
still can be added in br_multicast_add_group() after all mdb entries are
removed in br_multicast_dev_del(). Like the path:

  mld_ifc_timer_expire ->
    mld_sendpack -> ...
      br_multicast_rcv ->
        br_multicast_add_group

The new mp's timer will be set up. If the timer expires after the bridge
is freed, it may cause use-after-free panic in br_multicast_group_expired.
This can happen when ip link remove a bridge or destroy a netns with a
bridge device inside.

As we can see in br_del_bridge, brctl is also supposed to remove a bridge
device after it's shutdown.

This patch is to call dev_close at the beginning of br_dev_delete so that
netif_running check in br_multicast_add_group can avoid this issue. But
to keep consistent with before, it will not remove the IFF_UP check in
br_del_bridge for brctl.

Reported-by: Jianwen Ji <jiji@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_if.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 56a2a72..8175f13 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -305,6 +305,8 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_port *p, *n;
 
+	dev_close(br->dev);
+
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
 		del_nbp(p);
 	}
-- 
2.1.0
