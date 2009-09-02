From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: Fix possible corruption in bpqether driver
Date: Wed, 2 Sep 2009 09:58:52 +0100
Message-ID: <20090902085841.GA5910@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, Thomas Osterried <thomas@osterried.de>,
	Jann Traschewski <jann@gmx.de>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bpq ether driver is modifying the data art of the skb by first
dropping the KISS byte (a command byte for the radio) then prepending the
length + 4 of the remaining AX.25 packet to be transmitted as a little
endian 16-bit number.  If the high byte of the length has a different
value than the dropped KISS byte users of clones of the skb may observe
this as corruption.  This was observed with by running listen(8) -a which
uses a packet socket which clones transmit packets.  The corruption will
then typically be displayed for as a KISS "TX Delay" command for AX.25
packets in the range of 252..508 bytes or any other KISS command for
yet larger packets.

Fixed by using skb_cow to create a private copy should the skb be cloned.
Using skb_cow also allows us to cleanup the old logic to ensure sufficient
headroom in the skb.

While at it, replace a return of 0 from bpq_xmit with the proper constant
NETDEV_TX_OK which is now being used everywhere else in this function.

Affected: all 2.2, 2.4 and 2.6 kernels.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Reported-by: Jann Traschewski <jann@gmx.de>

 drivers/net/hamradio/bpqether.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index abcd19a..184a528 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -249,7 +249,6 @@ drop:
  */
 static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sk_buff *newskb;
 	unsigned char *ptr;
 	struct bpqdev *bpq;
 	int size;
@@ -263,28 +262,23 @@ static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	skb_pull(skb, 1);
+	skb_pull(skb, 1);			/* Drop KISS byte */
 	size = skb->len;
 
 	/*
-	 * The AX.25 code leaves enough room for the ethernet header, but
-	 * sendto() does not.
+	 * We're about to mess with the skb which may still shared with the
+	 * generic networking code so unshare and ensure it's got enough
+	 * space for the BPQ headers.
 	 */
-	if (skb_headroom(skb) < AX25_BPQ_HEADER_LEN) {	/* Ough! */
-		if ((newskb = skb_realloc_headroom(skb, AX25_BPQ_HEADER_LEN)) == NULL) {
-			printk(KERN_WARNING "bpqether: out of memory\n");
-			kfree_skb(skb);
-			return NETDEV_TX_OK;
-		}
-
-		if (skb->sk != NULL)
-			skb_set_owner_w(newskb, skb->sk);
-
+	if (skb_cow(skb, AX25_BPQ_HEADER_LEN)) {
+		if (net_ratelimit())
+			pr_err("bpqether: out of memory\n");
 		kfree_skb(skb);
-		skb = newskb;
+
+		return NETDEV_TX_OK;
 	}
 
-	ptr = skb_push(skb, 2);
+	ptr = skb_push(skb, 2);			/* Make space for length */
 
 	*ptr++ = (size + 5) % 256;
 	*ptr++ = (size + 5) / 256;
@@ -305,7 +299,8 @@ static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
   
 	dev_queue_xmit(skb);
 	netif_wake_queue(dev);
-	return 0;
+
+	return NETDEV_TX_OK;
 }
 
 /*
