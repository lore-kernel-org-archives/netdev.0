From: Amit Virdi <amit.virdi@st.com>
Subject: [PATCH] net/irda/ircomm_tty.c: Use flip buffers to deliver data
Date: Thu, 12 May 2011 16:34:40 +0530
Message-ID: <1305198280-14449-1-git-send-email-amit.virdi@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <amit.virdi@st.com>, <shiraz.hashim@st.com>,
	<armando.visconti@st.com>, <viresh.kumar@st.com>
To: <samuel@sortiz.org>, <alan@linux.intel.com>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use tty_insert_flip_string and tty_flip_buffer_push to deliver incoming data
packets from the IrDA device instead of delivering the packets directly to the
line discipline. Following later approach resulted in warning "Sleeping function
called from invalid context".

Signed-off-by: Amit Virdi <amit.virdi@st.com>
---
 net/irda/ircomm/ircomm_tty.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index a39cca8..b3cc8b3 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -38,6 +38,7 @@
 #include <linux/seq_file.h>
 #include <linux/termios.h>
 #include <linux/tty.h>
+#include <linux/tty_flip.h>
 #include <linux/interrupt.h>
 #include <linux/device.h>		/* for MODULE_ALIAS_CHARDEV_MAJOR */
 
@@ -1132,7 +1133,6 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 				      struct sk_buff *skb)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
-	struct tty_ldisc *ld;
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
@@ -1161,15 +1161,11 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 	}
 
 	/*
-	 * Just give it over to the line discipline. There is no need to
-	 * involve the flip buffers, since we are not running in an interrupt
-	 * handler
+	 * Use flip buffer functions since the code may be called from interrupt
+	 * context
 	 */
-
-	ld = tty_ldisc_ref(self->tty);
-	if (ld)
-		ld->ops->receive_buf(self->tty, skb->data, NULL, skb->len);
-	tty_ldisc_deref(ld);
+	tty_insert_flip_string(self->tty, skb->data, skb->len);
+	tty_flip_buffer_push(self->tty);
 
 	/* No need to kfree_skb - see ircomm_ttp_data_indication() */
 
-- 
1.7.3.4
