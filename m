From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH v2 net-next] net:dsa: check for EPROBE_DEFER from dsa_dst_parse()
Date: Thu,  5 Jan 2017 11:10:13 +0100
Message-ID: <1483611013-15013-1-git-send-email-volodymyr.bendiuga@gmail.com>
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35514 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934922AbdAEKLc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 05:11:32 -0500
Received: by mail-lf0-f65.google.com with SMTP id x140so32777787lfa.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 02:10:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since there can be multiple dsa switches stacked together but
not all of devicetree nodes available at the time of calling
dsa_dst_parse(), EPROBE_DEFER can be returned by it. When this
happens, only the last dsa switch has to be deleted by
dsa_dst_del_ds(), but not the whole list, because next time linux
cames back to this function it will try to add only the last dsa
switch which returned EPROBE_DEFER.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa2.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 7924c92..a799718 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -673,8 +673,14 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 	}
 
 	err = dsa_dst_parse(dst);
-	if (err)
+	if (err) {
+		if (err == -EPROBE_DEFER) {
+			dsa_dst_del_ds(dst, ds, ds->index);
+			return err;
+		}
+
 		goto out_del_dst;
+	}
 
 	err = dsa_dst_apply(dst);
 	if (err) {
-- 
2.7.4
