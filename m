From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] net/rose: Use GFP_ATOMIC
Date: Sat, 31 Jul 2010 11:56:39 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1007311156180.6434@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The other calls to kmalloc in the same function use GFP_ATOMIC, and indeed
two locks are held within the body of the function.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@ identifier f; @@

*f(...,GFP_ATOMIC,...)
... when != spin_unlock(...)
    when != read_unlock(...)
    when != write_unlock(...)
    when != read_unlock_irq(...)
    when != write_unlock_irq(...)
    when != read_unlock_irqrestore(...)
    when != write_unlock_irqrestore(...)
    when != spin_unlock_irq(...)
    when != spin_unlock_irqrestore(...)
*f(...,GFP_KERNEL,...)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/rose/rose_route.c               |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index cbc244a..b4fdaac 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -109,7 +109,9 @@ static int __must_check rose_add_node(struct rose_route_struct *rose_route,
 		init_timer(&rose_neigh->t0timer);
 
 		if (rose_route->ndigis != 0) {
-			if ((rose_neigh->digipeat = kmalloc(sizeof(ax25_digi), GFP_KERNEL)) == NULL) {
+			rose_neigh->digipeat =
+				kmalloc(sizeof(ax25_digi), GFP_ATOMIC);
+			if (rose_neigh->digipeat == NULL) {
 				kfree(rose_neigh);
 				res = -ENOMEM;
 				goto out;
