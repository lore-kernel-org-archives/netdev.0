From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: [PATCH v2 1/1] net: dsa: replacing the hard-coded sized array "dsa_switch"
 by dynamic one
Date: Thu, 04 Dec 2014 16:54:32 +0100
Message-ID: <548083B8.5090900@nexvision.fr>
References: <547DD1C6.2090304@nexvision.fr> <547E23C1.2040007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 3.mo1.mail-out.ovh.net ([46.105.60.232]:53497 "EHLO
	mo1.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932256AbaLDRKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 12:10:55 -0500
Received: from mail140.ha.ovh.net (gw6.ovh.net [213.251.189.206])
	by mo1.mail-out.ovh.net (Postfix) with SMTP id A7A17FFAE06
	for <netdev@vger.kernel.org>; Thu,  4 Dec 2014 16:54:34 +0100 (CET)
In-Reply-To: <547E23C1.2040007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replacing the hard-coded sized array "dsa_switch" by dynamic one
and remove useless DSA_MAX_SWITCHES define.
This patch also make dsa_switch_tree scalable from the "usual"
1-2 up to 10th switches configuration.

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
 
-#define DSA_MAX_SWITCHES    4
 #define DSA_MAX_PORTS        12
 
 struct dsa_chip_data {
@@ -117,7 +116,7 @@ struct dsa_switch_tree {
     /*
      * Data for the individual switch chips.
      */
-    struct dsa_switch    *ds[DSA_MAX_SWITCHES];
+    struct dsa_switch    *ds[];
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
-    if (pd->nr_chips > DSA_MAX_SWITCHES)
-        pd->nr_chips = DSA_MAX_SWITCHES;
 
     pd->chip = kcalloc(pd->nr_chips, sizeof(struct dsa_chip_data),
                GFP_KERNEL);
@@ -717,7 +715,7 @@ static int dsa_probe(struct platform_device *pdev)
         pd = pdev->dev.platform_data;
     }
 
-    if (pd == NULL || pd->netdev == NULL)
+    if (pd == NULL || pd->netdev == NULL || pd->nr_chips == 0)
         return -EINVAL;
 
     dev = dev_to_net_device(pd->netdev);
@@ -732,7 +730,8 @@ static int dsa_probe(struct platform_device *pdev)
         goto out;
     }
 
-    dst = kzalloc(sizeof(*dst), GFP_KERNEL);
+    dst = kzalloc(sizeof(*dst) +
+            sizeof(struct dsa_switch *) * pd->nr_chips, GFP_KERNEL);
     if (dst == NULL) {
         dev_put(dev);
         ret = -ENOMEM;
