From: Unai Uribarri <unai.uribarri@optenet.com>
Subject: [PATCH 1/1] af_packet: don't enable timestamps in mmap'ed sockets
Date: Wed, 08 Aug 2007 13:50:29 +0200
Message-ID: <1186573829.24669.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipsec.mad.optenet.com ([213.27.232.70]:35871 "EHLO
	mta-mad.optenet.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbXHHLuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 07:50:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello folks,

I've discovered two strange behaviours (bugs?) about timestamp
generation:

1. If a program opens an AF_PACKET socket and setup a reception ring
with setsockopt(sock, SOL_PACKET, PACKET_RX_RING), timestamps are
automatically (re)enabled at the reception of every packet.

2. Setting SOL_SOCKET/SO_TIMESTAMP to 0 doesn't disables timestamp
generation. Every skb continues begin timestamped until you close the
socket that activated it.


Timestamp generation is a heavy task that is consuming more than 50% of
the CPU (using ACPI PM clock) and is currently the bottleneck in my
packet capturing application.

The attached patch removes the automatic timestamp activation, that
only mmap'ed AF_PACKET sockets perform. I known it can break user
applications, but I believe that it's the correct solution.

I will be very pleased to receive any feedback.

Signed-off-by: Unai Uribarri <unai.uribarri@optenet.com>

---

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1322d62..a4f2da3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -640,10 +640,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
        h->tp_snaplen = snaplen;
        h->tp_mac = macoff;
        h->tp_net = netoff;
-       if (skb->tstamp.tv64 == 0) {
-               __net_timestamp(skb);
-               sock_enable_timestamp(sk);
-       }
        tv = ktime_to_timeval(skb->tstamp);
        h->tp_sec = tv.tv_sec;
        h->tp_usec = tv.tv_usec;



