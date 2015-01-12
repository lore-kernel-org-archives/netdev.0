From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/8] net: dsa: allow switch drivers to cleanup their resources
Date: Mon, 12 Jan 2015 13:57:43 -0800
Message-ID: <1421099866-3184-6-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:46784 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbbALV57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:57:59 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so32595754pdj.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:57:59 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switch drivers might request interrupts, remap register ranges,
allow such drivers to implement a "remove" callback doing just that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ed3c34bbb67a..cace02a4cbdd 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -192,6 +192,7 @@ struct dsa_switch_driver {
 	 */
 	char	*(*probe)(struct device *host_dev, int sw_addr);
 	int	(*setup)(struct dsa_switch *ds);
+	void	(*remove)(struct dsa_switch *ds);
 	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
 	u32	(*get_phy_flags)(struct dsa_switch *ds, int port);
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index df7ec066ac64..008a1a58cf0c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -331,6 +331,8 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 
 	mdiobus_unregister(ds->slave_mii_bus);
 	mdiobus_free(ds->slave_mii_bus);
+	if (ds->drv->remove)
+		ds->drv->remove(ds);
 	kfree(ds);
 }
 
-- 
2.1.0
