From: Chris Wedgwood <cw@f00f.org>
Subject: forcedeth oops
Date: Sat, 24 Feb 2007 00:07:02 -0800
Message-ID: <20070224080701.GA4737@tuatara.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: manfred@colorfullife.com, aabdulla@nvidia.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.sbc.mail.mud.yahoo.com ([68.142.198.203]:20246 "HELO
	smtp104.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933425AbXBXIHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 03:07:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using 2.6.21-rc1 (x86-64) I can get an oops in the forcedeth driver in
usually under about 5s with heavy network load (near line-rate GE, a
simpy using netcat and /dev/zero from one host to another suffices).

In nv_rx_done we have:

        if (flags & NV_TX_LASTPACKET) {
                if (flags & NV_TX_ERROR) {
                        if (flags & NV_TX_UNDERFLOW)
                                np->stats.tx_fifo_errors++;
                        if (flags & NV_TX_CARRIERLOST)
                                np->stats.tx_carrier_errors++;
                        np->stats.tx_errors++;
                } else {
                        np->stats.tx_packets++;
                        np->stats.tx_bytes += np->get_tx_ctx->skb->len;
                }
                dev_kfree_skb_any(np->get_tx_ctx->skb);
                np->get_tx_ctx->skb = NULL;
        }

Now, it seems that sometimes, for reasons I've not really looked into
as yet that np->get_tx_ctx->skb is NULL, so things go kaput (cr2 ends
up being 0x88, which I assume is the offset of len in skb).

No, if I do something along the lines of:

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a363148..59027aa 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1918,7 +1918,12 @@ static void nv_tx_done(struct net_device *dev)
 					np->stats.tx_errors++;
 				} else {
 					np->stats.tx_packets++;
-					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
+					/* XXX for some reason under heavy load,
+					   np->get_tx_ctx->skb can be null */
+					if (likely(np->get_tx_ctx->skb))
+						np->stats.tx_bytes += np->get_tx_ctx->skb->len;
+					else
+						printk(KERN_ERR "XXX saw null skb\n");
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;

the problem goes away completely, I can do hours of traffic, 100s of
GBs where it would break in a few seconds before.  However, I never
see the printk actually print anything...  so I'm a bit mystified.  I
disassembled the code in the original case and it seems perfectly
sane.

Can anyone explain why I see ->skb == NULL and why the above change
seems to make that go away?  (Or perhaps why the printk isn't
working).

