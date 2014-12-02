From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: [PATCH 1/1] net: dsa: replacing the hard-coded sized array "dsa_switch"
 by dynamic one
Date: Tue, 02 Dec 2014 15:50:46 +0100
Message-ID: <547DD1C6.2090304@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 15.mo4.mail-out.ovh.net ([91.121.62.11]:48905 "EHLO
	mo4.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753824AbaLBPfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 10:35:55 -0500
Received: from mail178.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo4.mail-out.ovh.net (Postfix) with SMTP id D77C2FF949A
	for <netdev@vger.kernel.org>; Tue,  2 Dec 2014 15:50:57 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

In time of developing one of our devices (with huge, more then 6, number of onboard switches),
I've bumped with this ancient, I hope, restriction in the 'struct dsa_switch_tree' definition. 
So this simple patch remove this restriction and make dsa_switch_tree more scalable for 
the "usual" 1-2 switches configuration too.

P.S. I've plans to fix hardcoded number of ports too, but it is not so easy as with number of switches.
So if someone have any objections/suggestions I'll happy to discuss them.

Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>                                                                                                                                                                                    
---                                                                                                                                                                                                                                          
 include/net/dsa.h |    3 +--                                                                                                                                                                                                                
 net/dsa/dsa.c     |    7 +++----                                                                                                                                                                                                            
 2 files changed, 4 insertions(+), 6 deletions(-)                                                                                                                                                                                            
                                                                                                                                                                                                                                             
diff --git a/include/net/dsa.h b/include/net/dsa.h                                                                                                                                                                                           
index ed3c34b..733db2e 100644                                                                                                                                                                                                                
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -28,7 +28,6 @@ enum dsa_tag_protocol {
        DSA_TAG_PROTO_BRCM,
 };
 
-#define DSA_MAX_SWITCHES       4
 #define DSA_MAX_PORTS          12
 
 struct dsa_chip_data {
@@ -117,7 +116,7 @@ struct dsa_switch_tree {
        /*
         * Data for the individual switch chips.
         */
-       struct dsa_switch       *ds[DSA_MAX_SWITCHES];
+       struct dsa_switch       *ds[];
 };
 
 struct dsa_switch {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 322c778..c081a19 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -604,8 +604,6 @@ static int dsa_of_probe(struct platform_device *pdev)
        pdev->dev.platform_data = pd;
        pd->netdev = &ethernet_dev->dev;
        pd->nr_chips = of_get_child_count(np);
-       if (pd->nr_chips > DSA_MAX_SWITCHES)
-               pd->nr_chips = DSA_MAX_SWITCHES;
 
        pd->chip = kcalloc(pd->nr_chips, sizeof(struct dsa_chip_data),
                           GFP_KERNEL);
@@ -717,7 +715,7 @@ static int dsa_probe(struct platform_device *pdev)
                pd = pdev->dev.platform_data;
        }
 
-       if (pd == NULL || pd->netdev == NULL)
+       if (pd == NULL || pd->netdev == NULL || pd->nr_chips == 0)
                return -EINVAL;
 
        dev = dev_to_net_device(pd->netdev);
@@ -732,7 +730,8 @@ static int dsa_probe(struct platform_device *pdev)
                goto out;
        }
 
-       dst = kzalloc(sizeof(*dst), GFP_KERNEL);
+       dst = kzalloc(sizeof(*dst) +
+                       sizeof(struct dsa_switch *) * pd->nr_chips, GFP_KERNEL);
        if (dst == NULL) {
                dev_put(dev);
                ret = -ENOMEM;
