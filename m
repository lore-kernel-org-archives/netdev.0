From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Do not destroy invalid network devices
Date: Tue,  7 Feb 2017 23:10:13 -0800
Message-ID: <20170208071013.19216-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:35654 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753478AbdBHHKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:10:19 -0500
Received: by mail-ot0-f196.google.com with SMTP id 65so17059038otq.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 23:10:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_slave_create() can fail, and dsa_user_port_unapply() will properly check
for the network device not being NULL before attempting to destroy it. We were
not setting the slave network device as NULL if dsa_slave_create() failed, so
we would later on be calling dsa_slave_destroy() on a now free'd and
unitialized network device, causing crashes in dsa_slave_destroy().

Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 6f5f0a2ad256..737be6470c7f 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -271,6 +271,7 @@ static int dsa_user_port_apply(struct dsa_port *port, u32 index,
 	if (err) {
 		dev_warn(ds->dev, "Failed to create slave %d: %d\n",
 			 index, err);
+		ds->ports[index].netdev = NULL;
 		return err;
 	}
 
-- 
2.9.3
