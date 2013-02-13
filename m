From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] net: Convert skb->csum_(start|offset) integrity BUG_ON() to
 WARN_ON() & drop
Date: Wed, 13 Feb 2013 23:40:21 +0000
Message-ID: <20130213234021.GA21829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47597 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab3BMXkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 18:40:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_checksum_help() verifies the integrity of skb->csum_start
and skb->csum_offset with BUG_ON()s.

They have been hit with IPoIB which uses a 64K MTU. If a TCP
retransmission gets partially ACKed and collapsed multiple times
it is possible for the headroom to grow beyond 64K which will
overflow the 16bit skb->csum_start.

This in turn will trigger the BUG_ON() in skb_checksum_help().
Convert these to WARN_ON() and drop the packet.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/dev.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f64e439..629d22e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2047,11 +2047,14 @@ int skb_checksum_help(struct sk_buff *skb)
 	}
 
 	offset = skb_checksum_start_offset(skb);
-	BUG_ON(offset >= skb_headlen(skb));
+	if (WARN_ON(offset >= skb_headlen(skb)))
+		return -ERANGE;
+
 	csum = skb_checksum(skb, offset, skb->len - offset, 0);
 
 	offset += skb->csum_offset;
-	BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
+	if (WARN_ON(offset + sizeof(__sum16) > skb_headlen(skb)))
+		return -ERANGE;
 
 	if (skb_cloned(skb) &&
 	    !skb_clone_writable(skb, offset + sizeof(__sum16))) {
