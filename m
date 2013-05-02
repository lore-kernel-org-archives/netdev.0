From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH RFT] 3c59x: fix freeing nonexistent resource on driver unload
Date: Fri, 3 May 2013 01:10:22 +0400
Message-ID: <201305030110.22462.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:47652 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143Ab3EBVK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 17:10:29 -0400
Received: by mail-la0-f42.google.com with SMTP id fq13so967574lab.15
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 14:10:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When unloading the driver that drives an EISA board, a message similar to the
following one is displayed:

Trying to free nonexistent resource <0000000000013000-000000000001301f>

Then an user is unable to reload the driver because the resource it requested in
the previous load hasn't been freed. This happens most probably due to a typo in
vortex_eisa_remove() which calls release_region() with 'dev->base_addr'  instead
of 'edev->base_addr'...

Reported-by: Matthew Whitehead <tedheadster@gmail.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against David Miller's 'net-next.git' repo.
Matthew, please test it and report on the list.

 drivers/net/ethernet/3com/3c59x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/3com/3c59x.c
===================================================================
--- net-next.orig/drivers/net/ethernet/3com/3c59x.c
+++ net-next/drivers/net/ethernet/3com/3c59x.c
@@ -951,7 +951,7 @@ static int vortex_eisa_remove(struct dev
 
 	unregister_netdev(dev);
 	iowrite16(TotalReset|0x14, ioaddr + EL3_CMD);
-	release_region(dev->base_addr, VORTEX_TOTAL_SIZE);
+	release_region(edev->base_addr, VORTEX_TOTAL_SIZE);
 
 	free_netdev(dev);
 	return 0;
