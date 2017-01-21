From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH cumulus-4.1.y 2/5] vxlan: don't replace fdb entry if nothing changed
Date: Fri, 20 Jan 2017 23:40:07 -0800
Message-ID: <1484984410-3304-2-git-send-email-roopa@cumulusnetworks.com>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36246 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdAUHlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:41:06 -0500
Received: by mail-pf0-f179.google.com with SMTP id 189so28107399pfu.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:40:19 -0800 (PST)
In-Reply-To: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakrishnan Raman <ramanb@cumulusnetworks.com>

This will avoid unnecessary notifications to userspace.

Signed-off-by: Balakrishnan Raman <ramanb@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 15b1c23..72b99ff 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -467,12 +467,19 @@ static int vxlan_fdb_replace(struct vxlan_fdb *f,
 	if (!rd)
 		return 0;
 
-	dst_cache_reset(&rd->dst_cache);
-	rd->remote_ip = *ip;
-	rd->remote_port = port;
-	rd->remote_vni = vni;
-	rd->remote_ifindex = ifindex;
-	return 1;
+	if (!vxlan_addr_equal(&rd->remote_ip, ip) ||
+	    rd->remote_port != port ||
+	    rd->remote_vni != vni ||
+	    rd->remote_ifindex != ifindex) {
+		dst_cache_reset(&rd->dst_cache);
+		rd->remote_ip = *ip;
+		rd->remote_port = port;
+		rd->remote_vni = vni;
+		rd->remote_ifindex = ifindex;
+		return 1;
+	}
+
+	return 0;
 }
 
 /* Add/update destinations for multicast */
-- 
1.9.1
