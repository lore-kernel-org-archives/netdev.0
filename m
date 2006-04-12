From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1
Date: Wed, 12 Apr 2006 14:48:12 -0700
Message-ID: <20060412144812.6b679204@localhost.localdomain>
References: <200604121442.56750.gthomsen@bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12229 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932332AbWDLVs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 17:48:29 -0400
To: Guenther Thomsen <gthomsen@bluearc.com>
In-Reply-To: <200604121442.56750.gthomsen@bluearc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You need this patch, which Jeff hasn't applied yet.
-----
Subject: sky2: crash when bringing up second port

Sky2 driver will oops referencing bad memory if used on
a dual port card.  The problem is accessing past end of
MIB counter space.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- test-2.6.orig/drivers/net/sky2.c
+++ test-2.6/drivers/net/sky2.c
@@ -579,8 +579,8 @@ static void sky2_mac_init(struct sky2_hw
 	reg = gma_read16(hw, port, GM_PHY_ADDR);
 	gma_write16(hw, port, GM_PHY_ADDR, reg | GM_PAR_MIB_CLR);
 
-	for (i = 0; i < GM_MIB_CNT_SIZE; i++)
-		gma_read16(hw, port, GM_MIB_CNT_BASE + 8 * i);
+	for (i = GM_MIB_CNT_BASE; i <= GM_MIB_CNT_END; i += 4)
+		gma_read16(hw, port, i);
 	gma_write16(hw, port, GM_PHY_ADDR, reg);
 
 	/* transmit control */
--- test-2.6.orig/drivers/net/sky2.h
+++ test-2.6/drivers/net/sky2.h
@@ -1375,7 +1375,7 @@ enum {
 	GM_PHY_ADDR	= 0x0088,	/* 16 bit r/w	GPHY Address Register */
 /* MIB Counters */
 	GM_MIB_CNT_BASE	= 0x0100,	/* Base Address of MIB Counters */
-	GM_MIB_CNT_SIZE	= 256,
+	GM_MIB_CNT_END	= 0x025C,	/* Last MIB counter */
 };
 
 

