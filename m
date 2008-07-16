From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/2] drivers/net/r6040.c: adjust error handling
Date: Wed, 16 Jul 2008 16:34:29 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807161633570.28783@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:44044 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756045AbYGPOei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 10:34:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The just preceding error case does a lot of error handling, so it seems
like this one should as well.

The semantic match that found the problem is:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression E,E1,E2;
@@

E = alloc_etherdev(...)
... when != E = E1
if (...) { ... free_netdev(E); ... return ...; }
... when != E = E2
(
  if (...)
   {
   ... when != free_netdev(E);
   return dev; }
|
* if (...)
   {
   ... when != free_netdev(E);
   return ...; }
|
register_netdev(E)
)

// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
diff -u -p a/drivers/net/r6040.c b/drivers/net/r6040.c
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1029,7 +1029,8 @@ static int __devinit r6040_init_one(stru
 	if (!ioaddr) {
 		printk(KERN_ERR "ioremap failed for device %s\n",
 			pci_name(pdev));
-		return -EIO;
+		err = -EIO;
+		goto err_out_res;
 	}
 
 	/* Init system & device */
