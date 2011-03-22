From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/3] drivers/net/ariadne.c: Convert release_resource to release_region/release_mem_region
Date: Tue, 22 Mar 2011 18:15:21 +0100
Message-ID: <1300814123-25314-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Jinqiu Yang <crindy646@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/ariadne.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index 7ca0ede..b7f45cd 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -182,14 +182,14 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
 	return -EBUSY;
     r2 = request_mem_region(mem_start, ARIADNE_RAM_SIZE, "RAM");
     if (!r2) {
-	release_resource(r1);
+	release_mem_region(base_addr, sizeof(struct Am79C960));
 	return -EBUSY;
     }
 
     dev = alloc_etherdev(sizeof(struct ariadne_private));
     if (dev == NULL) {
-	release_resource(r1);
-	release_resource(r2);
+	release_mem_region(base_addr, sizeof(struct Am79C960));
+	release_mem_region(mem_start, ARIADNE_RAM_SIZE);
 	return -ENOMEM;
     }
 
@@ -213,8 +213,8 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
 
     err = register_netdev(dev);
     if (err) {
-	release_resource(r1);
-	release_resource(r2);
+	release_mem_region(base_addr, sizeof(struct Am79C960));
+	release_mem_region(mem_start, ARIADNE_RAM_SIZE);
 	free_netdev(dev);
 	return err;
     }
