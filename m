From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Initialize ds->cpu_port_mask earlier
Date: Mon, 24 Jul 2017 10:49:23 -0700
Message-ID: <20170724174923.29156-1-f.fainelli@gmail.com>
Cc: sean.wang@mediatek.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34509 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753132AbdGXRtv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:49:51 -0400
Received: by mail-qk0-f193.google.com with SMTP id q66so10566239qki.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:49:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mt7530 driver has its dsa_switch_ops::get_tag_protocol function
check ds->cpu_port_mask to issue a warning in case the configured CPU
port is not capable of supporting tags.

After commit 14be36c2c96c ("net: dsa: Initialize all CPU and enabled
ports masks in dsa_ds_parse()") we slightly re-arranged the
initialization such that this was no longer working. Just make sure that
ds->cpu_port_mask is set prior to the first call to get_tag_protocol,
thus restoring the expected contract. In case of error, the CPU port bit
is cleared.

Fixes: 14be36c2c96c ("net: dsa: Initialize all CPU and enabled ports masks in dsa_ds_parse()")
Reported-by: Sean Wang <sean.wang@mediatek.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Sean, can you check this does fix the problem you originally reported
correctly for you? Thanks!

 net/dsa/dsa2.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 56e46090526b..c442051d5a55 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -509,21 +509,22 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 		dst->cpu_dp->netdev = ethernet_dev;
 	}
 
+	/* Initialize cpu_port_mask now for drv->setup()
+	 * to have access to a correct value, just like what
+	 * net/dsa/dsa.c::dsa_switch_setup_one does.
+	 */
+	ds->cpu_port_mask |= BIT(index);
+
 	tag_protocol = ds->ops->get_tag_protocol(ds);
 	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 	if (IS_ERR(dst->tag_ops)) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
+		ds->cpu_port_mask &= ~BIT(index);
 		return PTR_ERR(dst->tag_ops);
 	}
 
 	dst->rcv = dst->tag_ops->rcv;
 
-	/* Initialize cpu_port_mask now for drv->setup()
-	 * to have access to a correct value, just like what
-	 * net/dsa/dsa.c::dsa_switch_setup_one does.
-	 */
-	ds->cpu_port_mask |= BIT(index);
-
 	return 0;
 }
 
-- 
2.9.3
