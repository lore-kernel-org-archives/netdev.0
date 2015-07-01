From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Subject: [PATCH] rionet: Don't try to corrupt skbuff assigning data pointer
 directly
Date: Wed, 1 Jul 2015 15:01:11 +0200
Message-ID: <5593E497.40804@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexandre Bounine <alexandre.bounine@idt.com>,
	Frank Kunz <frank.kunz@nokia.com>,
	Marek Krzyzowski <marek.krzyzowski@nokia.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Matt Porter <mporter@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:60292 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbbGANCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 09:02:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not allowed to assign data pointer of skbuff directly, this makes no sense
if the assigned pointer is the very same as already existing one, or it brakes
all the pointer arithmetics in all other cases. We cannot do better as just
compare them and report BUG() in case of mismatch.

Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
---

We came across this problem developing new code for Octeon2 RAPIDIO. For the last
10 years since original commit of the code this assignment did nothing as the
pointers were always same. But the bug in the new code discovered this one. So
better do BUG() immediately here, this would prevent longer debugging of the
following skbuff corruption.

 drivers/net/rionet.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index dac7a0d..34c27b8 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -104,7 +104,8 @@ static int rionet_rx_clean(struct net_device *ndev)
 		if (!(data = rio_get_inb_message(rnet->mport, RIONET_MAILBOX)))
 			break;

-		rnet->rx_skb[i]->data = data;
+		if (rnet->rx_skb[i]->data != data)
+			BUG();
 		skb_put(rnet->rx_skb[i], RIO_MAX_MSG_SIZE);
 		rnet->rx_skb[i]->protocol =
 		    eth_type_trans(rnet->rx_skb[i], ndev);
