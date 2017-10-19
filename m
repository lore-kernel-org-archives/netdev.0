From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2] ip maddr: fix filtering by device
Date: Thu, 19 Oct 2017 10:21:08 +0200 (CEST)
Message-ID: <20171019082108.40D7AA0EDF@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Petr Vorel <pvorel@suse.cz>,
        Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52747 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752249AbdJSIVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 04:21:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 530903dd9003 ("ip: fix igmp parsing when iface is long") uses
variable len to keep trailing colon from interface name comparison.  This
variable is local to loop body but we set it in one pass and use it in
following one(s) so that we are actually using (pseudo)random length for
comparison. This became apparent since commit b48a1161f5f9 ("ipmaddr: Avoid
accessing uninitialized data") always initializes len to zero so that the
name comparison is always true. As a result, "ip maddr show dev eth0" shows
IPv4 multicast addresses for all interfaces.

Instead of keeping the length, let's simply replace the trailing colon with
a null byte. The bonus is that we get correct interface name in ma.name.

Fixes: 530903dd9003 ("ip: fix igmp parsing when iface is long")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/ipmaddr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 5683f6fa830c..46b86a3a7723 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -136,17 +136,18 @@ static void read_igmp(struct ma_info **result_p)
 
 	while (fgets(buf, sizeof(buf), fp)) {
 		struct ma_info *ma;
-		size_t len = 0;
 
 		if (buf[0] != '\t') {
+			size_t len;
+
 			sscanf(buf, "%d%s", &m.index, m.name);
 			len = strlen(m.name);
 			if (m.name[len - 1] == ':')
-				len--;
+				m.name[len - 1] = '\0';
 			continue;
 		}
 
-		if (filter.dev && strncmp(filter.dev, m.name, len))
+		if (filter.dev && strcmp(filter.dev, m.name))
 			continue;
 
 		sscanf(buf, "%08x%d", (__u32 *)&m.addr.data, &m.users);
-- 
2.14.2
