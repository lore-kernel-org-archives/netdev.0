From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/3] drivers/net/smsc911x.c: Fix resource size off by 1 error
Date: Sat, 4 Jul 2009 23:31:47 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907042331070.9841@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:56156 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbZGDVbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jul 2009 17:31:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The call resource_size(res) returns res->end - res->start + 1 and thus the
second change is semantics-preserving.  res_size is then used as the second
argument of a call to request_mem_region, and the memory allocated by this
call appears to be the same as what is released in the two calls to
release_mem_region.  So the size argument for those calls should be
resource_size(size) as well.  Alternatively, in the second call to
release_mem_region, the second argument could be res_size, as that variable
has already been initialized at the point of this call.

The problem was found using the following semantic patch:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
struct resource *res;
@@

- (res->end - res->start) + 1
+ resource_size(res)

@@
struct resource *res;
@@

- res->end - res->start
+ BAD(resource_size(res))
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/smsc911x.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -u -p a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
--- a/drivers/net/smsc911x.c 2009-06-24 21:18:49.000000000 +0200
+++ b/drivers/net/smsc911x.c 2009-07-04 21:38:00.000000000 +0200
@@ -1938,7 +1938,7 @@ static int __devexit smsc911x_drv_remove
 	if (!res)
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 
-	release_mem_region(res->start, res->end - res->start);
+	release_mem_region(res->start, resource_size(res));
 
 	iounmap(pdata->ioaddr);
 
@@ -1976,7 +1976,7 @@ static int __devinit smsc911x_drv_probe(
 		retval = -ENODEV;
 		goto out_0;
 	}
-	res_size = res->end - res->start + 1;
+	res_size = resource_size(res);
 
 	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (!irq_res) {
@@ -2104,7 +2104,7 @@ out_unmap_io_3:
 out_free_netdev_2:
 	free_netdev(dev);
 out_release_io_1:
-	release_mem_region(res->start, res->end - res->start);
+	release_mem_region(res->start, resource_size(res));
 out_0:
 	return retval;
 }
