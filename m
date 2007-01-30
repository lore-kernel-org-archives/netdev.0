From: David Miller <davem@davemloft.net>
Subject: buggy IFB driver change
Date: Tue, 30 Jan 2007 13:12:46 -0800 (PST)
Message-ID: <20070130.131246.71091370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, m.kozlowski@tuxland.pl
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751449AbXA3VNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 16:13:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff, please revert: 0c0b3ae68ec93b1db5c637d294647d1cca0df763

It's wrong.  We had a lengthy analysis of this piece of code
several months ago, and it is correct.

Consider, if we run the loop and we get an error
the following happens:

1) attempt of ifb_init_one(i) fails, therefore we should
   not try to "ifb_free_one()" on "i" since it failed
2) the loop iteration first increments "i", then it
   check for error

Therefore we must decrement "i" twice before the first
free during the cleanup.  One to "undo" the for() loop
increment, and one to "skip" the ifb_init_one() case which
failed.

commit 0c0b3ae68ec93b1db5c637d294647d1cca0df763
Author: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date:   Sat Jan 27 00:00:01 2007 -0800

    net: ifb error path loop fix
    
    On error we should start freeing resources at [i-1] not [i-2].
    
    Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
    Cc: Jeff Garzik <jeff@garzik.org>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ca2b21f..c4ca7c9 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -271,8 +271,7 @@ static int __init ifb_init_module(void)
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i);
 	if (err) {
-		i--;
-		while (--i >= 0)
+		while (i--)
 			ifb_free_one(i);
 	}
 
