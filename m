From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: dsa: Unregister slave_dev in error path
Date: Wed, 17 Feb 2016 18:43:22 -0800
Message-ID: <1455763402-4399-1-git-send-email-f.fainelli@gmail.com>
References: <1455761951-26408-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, opendmb@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36639 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424140AbcBRCn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:43:28 -0500
Received: by mail-ob0-f180.google.com with SMTP id gc3so45388615obb.3
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 18:43:28 -0800 (PST)
In-Reply-To: <1455761951-26408-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit 0071f56e46da ("dsa: Register netdev before phy"), we are now trying
to free a network device that has been previously registered, and in case of
errors, this will make us hit the BUG_ON(dev->reg_state != NETREG_UNREGISTERED)
condition.

Fix this by adding a missing unregister_netdev() before free_netdev().

Fixes: 0071f56e46da ("dsa: Register netdev before phy")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- fixed commit message to accurately reflect what we are doing s/unregister/free

 net/dsa/slave.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 91e3b2ff364a..ab24521beb4d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1204,6 +1204,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	ret = dsa_slave_phy_setup(p, slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d setting up slave phy\n", ret);
+		unregister_netdev(slave_dev);
 		free_netdev(slave_dev);
 		return ret;
 	}
-- 
2.5.0
