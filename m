From: Petr Vorel <pvorel@suse.cz>
Subject: [PATCH 1/1] ip: fix igmp parsing when iface is long
Date: Tue, 17 Jan 2017 00:25:50 +0100
Message-ID: <20170116232550.7764-1-pvorel@suse.cz>
Cc: Petr Vorel <pvorel@suse.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35401 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751230AbdAPXpG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 18:45:06 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 063ADAAC7
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 23:25:58 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Entries with long vhost names in /proc/net/igmp have no whitespace
between name and colon, so sscanf() adds it to vhost and
'ip maddr show iface' doesn't include inet result.

Signed-off-by: Petr Vorel <pvorel@suse.cz>
---
 ip/ipmaddr.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 22eb407..4f726fd 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -136,13 +136,17 @@ static void read_igmp(struct ma_info **result_p)
 
 	while (fgets(buf, sizeof(buf), fp)) {
 		struct ma_info *ma;
+		size_t len;
 
 		if (buf[0] != '\t') {
 			sscanf(buf, "%d%s", &m.index, m.name);
+			len = strlen(m.name);
+			if (m.name[len - 1] == ':')
+				len--;
 			continue;
 		}
 
-		if (filter.dev && strcmp(filter.dev, m.name))
+		if (filter.dev && strncmp(filter.dev, m.name, len))
 			continue;
 
 		sscanf(buf, "%08x%d", (__u32 *)&m.addr.data, &m.users);
-- 
2.11.0
