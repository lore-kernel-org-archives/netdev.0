From: Jana Saout <jana@saout.de>
Subject: RFC: Fix checksum related BUG in l2tp_ppp receive path
Date: Mon, 13 May 2013 00:40:05 +0200
Message-ID: <1368398405.28570.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I managed to (reproducably) trigger this bug:

> kernel BUG at net/core/dev.c:2192!

which is -> BUG_ON(offset >= skb_headlen(skb));

(full BUG here: http://www1.aufwind-solutions.de/oopses/pppol2tp1.txt )

Interestingly, the PPP over L2TP (with xl2tpd) is working fine when
using my Linux client, but a simple ping from my Android phone causes
the BUG on the first packet.  It happens on the L2TP -> PPP path, as the
ping request never leaves the ppp devices to the local network.

What *might* be different from other setups, is that the machine on
which the L2TP packets are decapsulated is a Xen VM, so the packets
arrive with CHECKSUM_PARTIAL set.

I followed the code path and saw that in this direction, the checksum
members of the SKB are never adjusted, and so my theory is that the
packet travels through the ppp stack, back into the IP stack until it
tries to leave the network stack to the network device, at which point
the checksumming is supposed to happen and the checksum offset is
invalid.

I believe that since the L2TP checksum has already been checked and
everything, the decapsulated packet is supposedly "fine" and I also saw
the following line in l2tp_eth.c:

        /* checksums verified by L2TP */
        skb->ip_summed = CHECKSUM_NONE;

which sounds to mike like the right thing to do, so I modified
l2tp_ppp.c accordingly and voila - no more crashes.  In case it helps, I
would like to share that patch for inclusion or, in case I'm wrong, to
ask you to find the correct fix. :)



Fix kernel BUG at net/core/dev.c:2192 (wrong checksum offset) in L2TP -> PPP
receive path (skb checksum information is not reset during decapsulation).
Reset checksum like it is also done in the l2tp_eth path.

Signed-off-by: Jana Saout <jana@saout.de>
---
 net/l2tp/l2tp_ppp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 637a341..53aabefb 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -250,6 +250,10 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 		 *   to the inner packet either
 		 */
 		secpath_reset(skb);
+
+		/* checksums verified by L2TP */
+		skb->ip_summed = CHECKSUM_NONE;
+
 		skb_dst_drop(skb);
 		nf_reset(skb);
 
