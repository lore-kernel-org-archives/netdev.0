From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [iproute2] iproute2: fix the link group name getting error
Date: Fri, 18 Nov 2016 09:12:53 +0800
Message-ID: <1479431573-2910-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:19232 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbcKRBTR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 20:19:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the situation where more than one entry live in the same hash bucket,
loop to get the correct one.

Before:
$ cat /etc/iproute2/group
0	default
256     test

$ sudo ip link set group test dummy1

$ ip link show type dummy
11: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group 0 qlen 1000
    link/ether 4e:3b:d3:6c:f0:e6 brd ff:ff:ff:ff:ff:ff
12: dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group test qlen 1000
    link/ether d6:9c:a4:1f:e7:e5 brd ff:ff:ff:ff:ff:ff

After:
$ ip link show type dummy
11: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 4e:3b:d3:6c:f0:e6 brd ff:ff:ff:ff:ff:ff
12: dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group test qlen 1000
    link/ether d6:9c:a4:1f:e7:e5 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 lib/rt_names.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index b665d3e..c66cb1e 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -559,8 +559,12 @@ const char *rtnl_group_n2a(int id, char *buf, int len)
 
 	for (i = 0; i < 256; i++) {
 		entry = rtnl_group_hash[i];
-		if (entry && entry->id == id)
-			return entry->name;
+
+		while (entry) {
+			if (entry->id == id)
+				return entry->name;
+			entry = entry->next;
+		}
 	}
 
 	snprintf(buf, len, "%d", id);
-- 
1.8.3.1
