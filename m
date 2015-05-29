From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Properly propagate errors from dsa_switch_setup_one
Date: Fri, 29 May 2015 10:29:46 -0700
Message-ID: <1432920586-20482-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35725 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbbE2R36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 13:29:58 -0400
Received: by pdea3 with SMTP id a3so58155816pde.2
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 10:29:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While shuffling some code around, dsa_switch_setup_one() was introduced,
and it was modified to return either an error code using ERR_PTR() or a
NULL pointer when running out of memory or failing to setup a switch.

This is a problem for its caler: dsa_switch_setup() which uses IS_ERR()
and expects to find an error code, not a NULL pointer, so we still try
to proceed with dsa_switch_setup() and operate on invalid memory
addresses. This can be easily reproduced by having e.g: the bcm_sf2
driver built-in, but having no such switch, such that drv->setup will
fail.

Fix this by using PTR_ERR() consistently which is both more informative
and avoids for the caller to use IS_ERR_OR_NULL().

Fixes: df197195a5248 ("net: dsa: split dsa_switch_setup into two functions")
Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index e6f6cc3a1bcf..392e29a0227d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -359,7 +359,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	 */
 	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
 	if (ds == NULL)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	ds->dst = dst;
 	ds->index = index;
@@ -370,7 +370,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 
 	ret = dsa_switch_setup_one(ds, parent);
 	if (ret)
-		return NULL;
+		return ERR_PTR(ret);
 
 	return ds;
 }
-- 
2.1.0
