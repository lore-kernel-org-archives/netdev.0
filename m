From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 2/2] bridge: Allow clearing of pvid and untagged bitmap
Date: Fri, 12 Sep 2014 16:26:17 -0400
Message-ID: <1410553577-17519-3-git-send-email-vyasevic@redhat.com>
References: <1410553577-17519-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:40850 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbaILU0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:26:47 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so1359788qgd.5
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:26:46 -0700 (PDT)
In-Reply-To: <1410553577-17519-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>

Currently, it is possible to modify the vlan filter
configuration to add pvid or untagged support.
For example:
  bridge vlan add vid 10 dev eth0
  bridge vlan add vid 10 dev eth0 untagged pvid

The second statement will modify vlan 10 to
include untagged and pvid configuration.
However, it is currently impossible to go backwards
  bridge vlan add vid 10 dev eth0 untagged pvid
  bridge vlan add vid 10 dev eth0

Here nothing happens.  This patch correct this so
that any modifiers not supplied are removed from
the configuration.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_vlan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index f645197..4b86738 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -27,9 +27,13 @@ static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
 {
 	if (flags & BRIDGE_VLAN_INFO_PVID)
 		__vlan_add_pvid(v, vid);
+	else
+		__vlan_delete_pvid(v, vid);
 
 	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		set_bit(vid, v->untagged_bitmap);
+	else
+		clear_bit(vid, v->untagged_bitmap);
 }
 
 static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
-- 
1.9.3
