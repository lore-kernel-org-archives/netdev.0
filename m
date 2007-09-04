From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: af_packet: don't enable global timestamps
Date: Tue, 4 Sep 2007 06:35:25 +0100
Message-ID: <20070904063525.060e7a77@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59236 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750980AbXIDFey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 01:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi mentioned he did something like this already, but never
submitted it.

The dhcp client application uses AF_PACKET with a packet filter to
receive data. The application doesn't even use timestamps, but because
the AF_PACKET API has timestamps, they get turned on globally which
causes an expensive time of day lookup for every packet received
on any system that uses the standard DHCP client.

The fix is to not enable the timestamp (but use if if available).
This causes the time lookup to only occur on those packets
that are destined for the AF_PACKET socket. 
The timestamping occurs after packet filtering
so all packets dropped by filtering to not cause a clock call.

The one downside of this a a few microseconds additional delay
added from the normal timestamping location (netif_rx) until the
receive callback in AF_PACKET. But since the offset is fairly consistent
it should not upset applications that do want really use timestamps,
like wireshark.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/net/packet/af_packet.c	2007-07-23 09:31:26.000000000 +0100
+++ b/net/packet/af_packet.c	2007-09-03 14:55:00.000000000 +0100
@@ -640,11 +640,10 @@ static int tpacket_rcv(struct sk_buff *s
 	h->tp_snaplen = snaplen;
 	h->tp_mac = macoff;
 	h->tp_net = netoff;
-	if (skb->tstamp.tv64 == 0) {
-		__net_timestamp(skb);
-		sock_enable_timestamp(sk);
-	}
-	tv = ktime_to_timeval(skb->tstamp);
+	if (skb->tstamp.tv64)
+		tv = ktime_to_timeval(skb->tstamp);
+	else
+		do_gettimeofday(&tv);
 	h->tp_sec = tv.tv_sec;
 	h->tp_usec = tv.tv_usec;
 
