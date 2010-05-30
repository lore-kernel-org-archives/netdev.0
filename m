From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/2] drivers/isdn/hardware/mISDN: Use GFP_ATOMIC when a lock
 is held
Date: Sun, 30 May 2010 15:49:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005301549230.15938@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The function inittiger is only called from nj_init_card, where a lock is held.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@gfp exists@
identifier fn;
position p;
@@

fn(...) {
 ... when != spin_unlock_irqrestore
     when any
 GFP_KERNEL@p
 ... when any
}

@locked@
identifier gfp.fn;
@@

spin_lock_irqsave(...)
...  when != spin_unlock_irqrestore
fn(...)

@depends on locked@
position gfp.p;
@@

- GFP_KERNEL@p
+ GFP_ATOMIC
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/isdn/hardware/mISDN/netjet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -u -p a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -320,12 +320,12 @@ inittiger(struct tiger_hw *card)
 		return -ENOMEM;
 	}
 	for (i = 0; i < 2; i++) {
-		card->bc[i].hsbuf = kmalloc(NJ_DMA_TXSIZE, GFP_KERNEL);
+		card->bc[i].hsbuf = kmalloc(NJ_DMA_TXSIZE, GFP_ATOMIC);
 		if (!card->bc[i].hsbuf) {
 			pr_info("%s: no B%d send buffer\n", card->name, i + 1);
 			return -ENOMEM;
 		}
-		card->bc[i].hrbuf = kmalloc(NJ_DMA_RXSIZE, GFP_KERNEL);
+		card->bc[i].hrbuf = kmalloc(NJ_DMA_RXSIZE, GFP_ATOMIC);
 		if (!card->bc[i].hrbuf) {
 			pr_info("%s: no B%d recv buffer\n", card->name, i + 1);
 			return -ENOMEM;
