From: Willem de Bruijn <willemb@google.com>
Subject: [patch] make PACKET_STATISTICS getsockopt report consistently between
 ring and non-ring
Date: Fri, 30 Sep 2011 16:38:28 -0400
Message-ID: <4E8628C4.2070504@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:12299 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab1I3Uif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 16:38:35 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p8UKcW1G019443
	for <netdev@vger.kernel.org>; Fri, 30 Sep 2011 13:38:33 -0700
Received: from vws20 (vws20.prod.google.com [10.241.21.148])
	by wpaz1.hot.corp.google.com with ESMTP id p8UKcV7G006258
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 30 Sep 2011 13:38:31 -0700
Received: by vws20 with SMTP id 20so1845745vws.38
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2011 13:38:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a minor change.

Up until kernel 2.6.32, getsockopt(fd, SOL_PACKET, PACKET_STATISTICS,
...) would return total and dropped packets since its last invocation. The
introduction of socket queue overflow reporting [1] changed drop
rate calculation in the normal packet socket path, but not when using a
packet ring. As a result, the getsockopt now returns different statistics
depending on the reception method used. With a ring, it still returns the
count since the last call, as counts are incremented in tpacket_rcv and
reset in getsockopt. Without a ring, it returns 0 if no drops occurred
since the last getsockopt and the total drops over the lifespan of
the socket otherwise. The culprit is this line in packet_rcv, executed
on a drop:

drop_n_acct:
        po->stats.tp_drops = atomic_inc_return(&sk->sk_drops);

As it shows, the new drop number it taken from the socket drop counter,
which is not reset at getsockopt. I put together a small example
that demonstrates the issue [2]. It runs for 10 seconds and overflows
the queue/ring on every odd second. The reported drop rates are:
ring: 16, 0, 16, 0, 16, ...
non-ring: 0, 15, 0, 30, 0, 46, 0, 60, 0 , 74.

Note how the even ring counts monotonically increase. Because the
getsockopt adds tp_drops to tp_packets, total counts are similarly
reported cumulatively. Long story short, reinstating the original code, as
the below patch does, fixes the issue at the cost of additional per-packet
cycles. Another solution that does not introduce per-packet overhead
is be to keep the current data path, record the value of sk_drops at
getsockopt() at call N in a new field in struct packetsock and subtract
that when reporting at call N+1. I'll be happy to code that, instead,
it's just more messy.

[1] http://patchwork.ozlabs.org/patch/35665/
[2] http://kernel.googlecode.com/files/test-packetsock-getstatistics.c

Signed-off-by: Willem de Bruijn <willemb@google.com>

---
 net/packet/af_packet.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c698cec..fabb4fa 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -961,7 +961,10 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 
 drop_n_acct:
-	po->stats.tp_drops = atomic_inc_return(&sk->sk_drops);
+	spin_lock(&sk->sk_receive_queue.lock);
+	po->stats.tp_drops++;
+	atomic_inc(&sk->sk_drops);
+	spin_unlock(&sk->sk_receive_queue.lock);
 
 drop_n_restore:
 	if (skb_head != skb->data && skb_shared(skb)) {
-- 
1.7.3.1
