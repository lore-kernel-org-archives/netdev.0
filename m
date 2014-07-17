From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] wan/x25_asy: integer overflow in x25_asy_change_mtu()
Date: Thu, 17 Jul 2014 11:03:10 +0300
Message-ID: <20140717080310.GB477@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41955 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbaGQID3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 04:03:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If "newmtu * 2 + 4" is too large then it can cause an integer overflow
leading to memory corruption.  Btw, "newmtu" is not allowed to be a
negative number because of the check in dev_set_mtu(), so that's ok.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 5895f19..f04c8c1 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -122,8 +122,11 @@ static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 {
 	struct x25_asy *sl = netdev_priv(dev);
 	unsigned char *xbuff, *rbuff;
-	int len = 2 * newmtu;
+	int len;
 
+	if (newmtu > INT_MAX / 2 - 4)
+		return -EINVAL;
+	len = 2 * newmtu;
 	xbuff = kmalloc(len + 4, GFP_ATOMIC);
 	rbuff = kmalloc(len + 4, GFP_ATOMIC);
 
