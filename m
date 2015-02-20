From: sfeldma@gmail.com
Subject: [PATCH net-next RFC 3/5] bridge: call external learn add if adding FDB entry with NTF_EXT_LEARNED set
Date: Thu, 19 Feb 2015 23:09:53 -0800
Message-ID: <1424416195-19098-4-git-send-email-sfeldma@gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:43599 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbbBTHJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:09:31 -0500
Received: by paceu11 with SMTP id eu11so5914912pac.10
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:09:30 -0800 (PST)
In-Reply-To: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Only call into bridge driver to add externally learned FDB entry if driver/
device indicates entry with NTF_EXT_LEARNED.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/bridge/br.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index fb57ab6..3dc5463 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -140,17 +140,19 @@ static int br_netdev_switch_event(struct notifier_block *unused,
 	switch (event) {
 	case NETDEV_SWITCH_FDB_ADD:
 		fdb_info = ptr;
-		err = br_fdb_external_learn_add(br, p, fdb_info->addr,
-						fdb_info->vid);
-		if (err)
-			err = notifier_from_errno(err);
+		if (fdb_info->ntf_flags & NTF_EXT_LEARNED) {
+			err = br_fdb_external_learn_add(br, p, fdb_info);
+			if (err)
+				err = notifier_from_errno(err);
+		}
 		break;
 	case NETDEV_SWITCH_FDB_DEL:
 		fdb_info = ptr;
-		err = br_fdb_external_learn_del(br, p, fdb_info->addr,
-						fdb_info->vid);
-		if (err)
-			err = notifier_from_errno(err);
+		if (fdb_info->ntf_flags & NTF_EXT_LEARNED) {
+			err = br_fdb_external_learn_del(br, p, fdb_info);
+			if (err)
+				err = notifier_from_errno(err);
+		}
 		break;
 	}
 
-- 
1.7.10.4
