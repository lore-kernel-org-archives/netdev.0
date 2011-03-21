From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] veth: Fix the byte counters
Date: Mon, 21 Mar 2011 14:40:29 -0700
Message-ID: <m1oc54i242.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	=?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54873 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108Ab1CUVkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 17:40:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit 44540960 "veth: move loopback logic to common location" introduced
a bug in the packet counters.  I don't understand why that happened as it
is not explained in the comments and the mut check in dev_forward_skb
retains the assumption that skb->len is the total length of the packet.

I just measured this emperically by setting up a veth pair between two
noop network namespaces setting and attempting a telnet connection between
the two.  I saw three packets in each direction and the byte counters were
exactly 14*3 = 42 bytes high in each direction.  I got the actual
packet lengths with tcpdump.

So remove the extra ETH_HLEN from the veth byte count totals.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/veth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 105d7f0..2de9b90 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -171,7 +171,7 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->ip_summed == CHECKSUM_NONE)
 		skb->ip_summed = rcv_priv->ip_summed;
 
-	length = skb->len + ETH_HLEN;
+	length = skb->len;
 	if (dev_forward_skb(rcv, skb) != NET_RX_SUCCESS)
 		goto rx_drop;
 
-- 
1.7.4

