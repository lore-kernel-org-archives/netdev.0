From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 5/5] netdev: bfin_mac: fix crash when unloading module
Date: Wed, 27 May 2009 02:10:15 -0400
Message-ID: <1243404615-25879-6-git-send-email-vapier@gentoo.org>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Graf Yang <graf.yang@analog.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32897 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759685AbZE0GKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 02:10:20 -0400
In-Reply-To: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graf Yang <graf.yang@analog.com>

If we build the Blackfin EMAC driver as a module and then unload it at
runtime, it would cause a crash:
root:/> rmmod bfin_mac
Hardware Trace:
   0 Target : <0x00004624> { _dump_bfin_trace_buffer + 0x0 }
     Source : <0x000a57b2> { _mdiobus_unregister + 0x42 } CALL pcrel
   1 Target : <0x000a57b2> { _mdiobus_unregister + 0x42 }
     Source : <0x000a577c> { _mdiobus_unregister + 0xc } IF !CC JUMP
   2 Target : <0x000a5770> { _mdiobus_unregister + 0x0 }
     Source : <0x037a4c9e> { :bfin_mac:_cleanup_module + 0x4a } CALL (P2)
   3 Target : <0x037a4c80> { :bfin_mac:_cleanup_module + 0x2c }
     Source : <0x000a0a2e> { _platform_drv_remove + 0xe } JUMP (P1)
   4 Target : <0x000a0a20> { _platform_drv_remove + 0x0 }
     Source : <0x0009fcc0> { ___device_release_driver + 0x50 } CALL (P2)
   ....

URL: http://blackfin.uclinux.org/gf/tracker/4885
Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 7f8ea0f..e764f8c 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1074,8 +1074,7 @@ static int __devexit bfin_mac_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 
-	mdiobus_unregister(lp->mii_bus);
-	mdiobus_free(lp->mii_bus);
+	lp->mii_bus->priv = NULL;
 
 	unregister_netdev(ndev);
 
-- 
1.6.3.1

