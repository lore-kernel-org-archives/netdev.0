From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/9] isdn/gigaset: correct bas_gigaset rx buffer handling
Date: Fri,  1 Oct 2010 01:34:51 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-03.tilman@imap.cc>
References: <20100930-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100930-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In transparent data reception, avoid a NULL pointer dereference
in case an skbuff cannot be allocated, remove an inappropriate
call to the HDLC flush routine, and correct the accounting of
received bytes for continued buffers.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
CC: stable <stable@kernel.org>
---
 drivers/isdn/gigaset/isocdata.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index 2dfd346..f39ccdf 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -842,13 +842,14 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 
 	if (unlikely(bcs->ignore)) {
 		bcs->ignore--;
-		hdlc_flush(bcs);
 		return;
 	}
 	skb = bcs->rx_skb;
-	if (skb == NULL)
+	if (skb == NULL) {
 		skb = gigaset_new_rx_skb(bcs);
-	bcs->hw.bas->goodbytes += skb->len;
+		if (skb == NULL)
+			return;
+	}
 	dobytes = bcs->rx_bufsize - skb->len;
 	while (count > 0) {
 		dst = skb_put(skb, count < dobytes ? count : dobytes);
@@ -860,6 +861,7 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 		if (dobytes == 0) {
 			dump_bytes(DEBUG_STREAM_DUMP,
 				   "rcv data", skb->data, skb->len);
+			bcs->hw.bas->goodbytes += skb->len;
 			gigaset_skb_rcvd(bcs, skb);
 			skb = gigaset_new_rx_skb(bcs);
 			if (skb == NULL)
-- 
1.7.3.15.g442cb
