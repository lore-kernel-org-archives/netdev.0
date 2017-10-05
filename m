From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: tulip: de2104x: Convert timers to use
Date: Wed, 4 Oct 2017 17:50:48 -0700
Message-ID: <20171005005048.GA23304@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Jarod Wilson <jarod@redhat.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-parisc@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/dec/tulip/de2104x.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index c87b8cc42963..13430f75496c 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -333,8 +333,8 @@ static void de_set_rx_mode (struct net_device *dev);
 static void de_tx (struct de_private *de);
 static void de_clean_rings (struct de_private *de);
 static void de_media_interrupt (struct de_private *de, u32 status);
-static void de21040_media_timer (unsigned long data);
-static void de21041_media_timer (unsigned long data);
+static void de21040_media_timer (struct timer_list *t);
+static void de21041_media_timer (struct timer_list *t);
 static unsigned int de_ok_to_advertise (struct de_private *de, u32 new_media);
 
 
@@ -959,9 +959,9 @@ static void de_next_media (struct de_private *de, const u32 *media,
 	}
 }
 
-static void de21040_media_timer (unsigned long data)
+static void de21040_media_timer (struct timer_list *t)
 {
-	struct de_private *de = (struct de_private *) data;
+	struct de_private *de = from_timer(de, t, media_timer);
 	struct net_device *dev = de->dev;
 	u32 status = dr32(SIAStatus);
 	unsigned int carrier;
@@ -1040,9 +1040,9 @@ static unsigned int de_ok_to_advertise (struct de_private *de, u32 new_media)
 	return 1;
 }
 
-static void de21041_media_timer (unsigned long data)
+static void de21041_media_timer (struct timer_list *t)
 {
-	struct de_private *de = (struct de_private *) data;
+	struct de_private *de = from_timer(de, t, media_timer);
 	struct net_device *dev = de->dev;
 	u32 status = dr32(SIAStatus);
 	unsigned int carrier;
@@ -1999,12 +1999,9 @@ static int de_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	de->msg_enable = (debug < 0 ? DE_DEF_MSG_ENABLE : debug);
 	de->board_idx = board_idx;
 	spin_lock_init (&de->lock);
-	init_timer(&de->media_timer);
-	if (de->de21040)
-		de->media_timer.function = de21040_media_timer;
-	else
-		de->media_timer.function = de21041_media_timer;
-	de->media_timer.data = (unsigned long) de;
+	timer_setup(&de->media_timer,
+		    de->de21040 ? de21040_media_timer : de21041_media_timer,
+		    0);
 
 	netif_carrier_off(dev);
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
