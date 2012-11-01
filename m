From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/3] bridge: Use is_link_local() in
 store_group_addr()
Date: Thu, 1 Nov 2012 19:10:04 +0000
Message-ID: <1351797004.2883.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39057 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752285Ab2KATKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 15:10:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parse the string into an array of bytes rather than ints, so we can
use is_link_local() rather than reimplementing it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/bridge/br_sysfs_br.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index e157b0d..82385fd 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -298,23 +298,18 @@ static ssize_t store_group_addr(struct device *d,
 				const char *buf, size_t len)
 {
 	struct net_bridge *br = to_bridge(d);
-	unsigned int new_addr[6];
+	u8 new_addr[6];
 	int i;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (sscanf(buf, "%x:%x:%x:%x:%x:%x",
+	if (sscanf(buf, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
 		   &new_addr[0], &new_addr[1], &new_addr[2],
 		   &new_addr[3], &new_addr[4], &new_addr[5]) != 6)
 		return -EINVAL;
 
-	/* Must be 01:80:c2:00:00:0X */
-	for (i = 0; i < 5; i++)
-		if (new_addr[i] != br_reserved_address[i])
-			return -EINVAL;
-
-	if (new_addr[5] & ~0xf)
+	if (!is_link_local(new_addr))
 		return -EINVAL;
 
 	if (new_addr[5] == 1 ||		/* 802.3x Pause address */
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
