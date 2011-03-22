From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/3] drivers/net/a2065.c: Convert release_resource to release_region/release_mem_region
Date: Tue, 22 Mar 2011 18:15:23 +0100
Message-ID: <1300814123-25314-3-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Jiri Pirko <jpirko@redhat.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:32794 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756492Ab1CVRM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 13:12:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Request_mem_region should be used with release_mem_region, not
release_resource.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x,E;
@@
*x = request_mem_region(...)
... when != release_mem_region(x)
    when != x = E
* release_resource(x);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/a2065.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index f142cc2..deaa8bc 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -711,14 +711,14 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 		return -EBUSY;
 	r2 = request_mem_region(mem_start, A2065_RAM_SIZE, "RAM");
 	if (!r2) {
-		release_resource(r1);
+		release_mem_region(base_addr, sizeof(struct lance_regs));
 		return -EBUSY;
 	}
 
 	dev = alloc_etherdev(sizeof(struct lance_private));
 	if (dev == NULL) {
-		release_resource(r1);
-		release_resource(r2);
+		release_mem_region(base_addr, sizeof(struct lance_regs));
+		release_mem_region(mem_start, A2065_RAM_SIZE);
 		return -ENOMEM;
 	}
 
@@ -764,8 +764,8 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 
 	err = register_netdev(dev);
 	if (err) {
-		release_resource(r1);
-		release_resource(r2);
+		release_mem_region(base_addr, sizeof(struct lance_regs));
+		release_mem_region(mem_start, A2065_RAM_SIZE);
 		free_netdev(dev);
 		return err;
 	}

