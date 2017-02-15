From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] atm: idt77252, use setup_timer and mod_timer
Date: Wed, 15 Feb 2017 16:59:35 +0100
Message-ID: <20170215155935.27606-1-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org,
        Jan Koniarik <jan.koniarik@trustica.cz>,
        Jiri Slaby <jslaby@suse.cz>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: 3chas3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Koniarik <jan.koniarik@trustica.cz>

Stop accessing timer struct members directly and use setup_timer and
mod_timer helpers intended for that use. It makes the code cleaner and
will allow for easier change of the timer struct internals.

Signed-off-by: Jan Koniarik <jan.koniarik@trustica.cz>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Chas Williams <3chas3@gmail.com>
Cc: <linux-atm-general@lists.sourceforge.net>
Cc: <netdev@vger.kernel.org>
---
 drivers/atm/idt77252.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 471ddfd93ea8..5ec109533bb9 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -2132,12 +2132,8 @@ idt77252_init_est(struct vc_map *vc, int pcr)
 
 	est->interval = 2;		/* XXX: make this configurable */
 	est->ewma_log = 2;		/* XXX: make this configurable */
-	init_timer(&est->timer);
-	est->timer.data = (unsigned long)vc;
-	est->timer.function = idt77252_est_timer;
-
-	est->timer.expires = jiffies + ((HZ / 4) << est->interval);
-	add_timer(&est->timer);
+	setup_timer(&est->timer, idt77252_est_timer, (unsigned long)vc);
+	mod_timer(&est->timer, jiffies + ((HZ / 4) << est->interval));
 
 	return est;
 }
@@ -3638,9 +3634,7 @@ static int idt77252_init_one(struct pci_dev *pcidev,
 	spin_lock_init(&card->cmd_lock);
 	spin_lock_init(&card->tst_lock);
 
-	init_timer(&card->tst_timer);
-	card->tst_timer.data = (unsigned long)card;
-	card->tst_timer.function = tst_timer;
+	setup_timer(&card->tst_timer, tst_timer, (unsigned long)card);
 
 	/* Do the I/O remapping... */
 	card->membase = ioremap(membase, 1024);
-- 
2.11.1
