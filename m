From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] bridge: mdb: zero out the local br_ip variable before use
Date: Tue,  7 Jul 2015 15:55:56 +0200
Message-ID: <1436277356-21404-1-git-send-email-razor@blackwall.org>
Cc: bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	davem@davemloft.net, vyasevich@gmail.com,
	Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:32977 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756815AbbGGN4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 09:56:49 -0400
Received: by wiwl6 with SMTP id l6so315551440wiw.0
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 06:56:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit b0e9a30dd669 ("bridge: Add vlan id to multicast groups")
there's a check in br_ip_equal() for a matching vlan id, but the mdb
functions were not modified to use (or at least zero it) so when an
entry was added it would have a garbage vlan id (from the local br_ip
variable in __br_mdb_add/del) and this would prevent it from being
matched and also deleted. So zero out the whole local ip var to protect
ourselves from future changes and also to fix the current bug, since
there's no vlan id support in the mdb uapi - use always vlan id 0.
Example before patch:
root@debian:~# bridge mdb add dev br0 port eth1 grp 239.0.0.1 permanent
root@debian:~# bridge mdb
dev br0 port eth1 grp 239.0.0.1 permanent
root@debian:~# bridge mdb del dev br0 port eth1 grp 239.0.0.1 permanent
RTNETLINK answers: Invalid argument

After patch:
root@debian:~# bridge mdb add dev br0 port eth1 grp 239.0.0.1 permanent
root@debian:~# bridge mdb
dev br0 port eth1 grp 239.0.0.1 permanent
root@debian:~# bridge mdb del dev br0 port eth1 grp 239.0.0.1 permanent
root@debian:~# bridge mdb

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
Fixes: b0e9a30dd669 ("bridge: Add vlan id to multicast groups")
---
 net/bridge/br_mdb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index e29ad70b3000..cc00066c0622 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -371,6 +371,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
 		return -EINVAL;
 
+	memset(&ip, 0, sizeof(ip));
 	ip.proto = entry->addr.proto;
 	if (ip.proto == htons(ETH_P_IP))
 		ip.u.ip4 = entry->addr.u.ip4;
@@ -417,6 +418,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 	if (!netif_running(br->dev) || br->multicast_disabled)
 		return -EINVAL;
 
+	memset(&ip, 0, sizeof(ip));
 	ip.proto = entry->addr.proto;
 	if (ip.proto == htons(ETH_P_IP)) {
 		if (timer_pending(&br->ip4_other_query.timer))
-- 
1.9.3
