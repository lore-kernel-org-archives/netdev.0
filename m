From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH cumulus-4.1.y 3/5] vxlan: enforce precedence for static over dynamic fdb entry
Date: Fri, 20 Jan 2017 23:40:08 -0800
Message-ID: <1484984410-3304-3-git-send-email-roopa@cumulusnetworks.com>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34043 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdAUHlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:41:06 -0500
Received: by mail-pg0-f48.google.com with SMTP id 14so29793755pgg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:40:20 -0800 (PST)
In-Reply-To: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

This patch enforces fdb state correctly when deciding
to add or update an existing fdb. It makes sure static fdb
entries are not replaced by dynamic fdb entries.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 72b99ff..7300586 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -628,6 +628,10 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			return -EEXIST;
 		}
 		if (f->state != state) {
+			if ((f->state & NUD_PERMANENT) &&
+			    !(state & NUD_PERMANENT))
+				return -EINVAL;
+
 			f->state = state;
 			f->updated = jiffies;
 			notify = 1;
-- 
1.9.1
