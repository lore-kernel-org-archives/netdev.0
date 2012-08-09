From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: [PATCH net-next] af_packet: relax BUG statement in
 tpacket_destruct_skb
Date: Thu, 09 Aug 2012 18:39:05 +0200
Message-ID: <1344530345.28842.11.camel@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44887 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758678Ab2HIQjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 12:39:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a quote of the comment about the BUG macro from asm-generic/bug.h:

 Don't use BUG() or BUG_ON() unless there's really no way out; one
 example might be detecting data structure corruption in the middle
 of an operation that can't be backed out of.  If the (sub)system
 can somehow continue operating, perhaps with reduced functionality,
 it's probably not BUG-worthy.

 If you're tempted to BUG(), think again:  is completely giving up
 really the *only* solution?  There are usually better options, where
 users don't need to reboot ASAP and can mostly shut down cleanly.

In our case, the status flag of a ring buffer slot is managed from both sides,
the kernel space and the user space. This means that even though the kernel
side might work as expected, the user space screws up and changes this flag
right between the send(2) is triggered when the flag is changed to
TP_STATUS_SENDING and a given skb is destructed after some time. Then, this
will hit the BUG macro. Instead, we relax this condition with a WARN_ON_ONCE
macro, so that the user is aware of this situation. I've tested it and the
system still behaves /stable/, so in accordance with the above comment, we
should rather relax this behavior with a warning.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 net/packet/af_packet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ceaca7c..4def36f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1936,7 +1936,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 
 	if (likely(po->tx_ring.pg_vec)) {
 		ph = skb_shinfo(skb)->destructor_arg;
-		BUG_ON(__packet_get_status(po, ph) != TP_STATUS_SENDING);
+		WARN_ON_ONCE(__packet_get_status(po, ph) != TP_STATUS_SENDING);
 		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
 		atomic_dec(&po->tx_ring.pending);
 		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
