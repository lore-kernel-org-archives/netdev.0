From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] packet: allow to transmit +4 byte in TX_RING slot for VLAN case
Date: Fri, 28 Feb 2014 02:22:06 +0100
Message-ID: <1393550526-25390-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, mathias.kretschmer@fokus.fraunhofer.de,
	Ben Greear <greearb@candelatech.com>, Phil Sutter <phil@nwl.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbaB1BWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 20:22:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 57f89bfa2140 ("network: Allow af_packet to transmit +4 bytes
for VLAN packets.") added the possibility for non-mmaped frames to
send extra 4 byte for VLAN header so the MTU increases from 1500 to
1504 byte, for example.

Commit cbd89acb9eb2 ("af_packet: fix for sending VLAN frames via
packet_mmap") attempted to fix that for the mmap part but was
reverted as it caused regressions while using eth_type_trans()
on output path.

Lets just act analogous to 57f89bfa2140 and add a similar logic
to TX_RING. We presume size_max as overcharged with +4 bytes and
later on after skb has been built by tpacket_fill_skb() check
for ETH_P_8021Q header on packets larger than normal MTU. Can
be easily reproduced with a slightly modified trafgen in mmap(2)
mode, test cases:

 { fill(0xff, 12) const16(0x8100) fill(0xff, <1504|1505>) }
 { fill(0xff, 12) const16(0x0806) fill(0xff, <1500|1501>) }

Note that we need to do the test right after tpacket_fill_skb()
as sockets can have PACKET_LOSS set where we would not fail but
instead just continue to traverse the ring.

Reported-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Phil Sutter <phil@nwl.cc>
---
 net/packet/af_packet.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 48a6a93..2923044 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2257,8 +2257,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
 
-	reserve = dev->hard_header_len;
-
+	reserve = dev->hard_header_len + VLAN_HLEN;
 	size_max = po->tx_ring.frame_size
 		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));
 
@@ -2285,8 +2284,19 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			goto out_status;
 
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
-				addr, hlen);
+					  addr, hlen);
+		if (tp_len > dev->mtu + dev->hard_header_len) {
+			struct ethhdr *ehdr;
+			/* Earlier code assumed this would be a VLAN pkt,
+			 * double-check this now that we have the actual
+			 * packet in hand.
+			 */
 
+			skb_reset_mac_header(skb);
+			ehdr = eth_hdr(skb);
+			if (ehdr->h_proto != htons(ETH_P_8021Q))
+				tp_len = -EMSGSIZE;
+		}
 		if (unlikely(tp_len < 0)) {
 			if (po->tp_loss) {
 				__packet_set_status(po, ph,
-- 
1.7.11.7
