From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] udp: some improvements on RX path.
Date: Sun, 04 Dec 2016 18:43:04 -0800
Message-ID: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34194 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbcLECnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 21:43:20 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so14839426pgc.1
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 18:43:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently access 3 cache lines from an skb in receive queue while
holding receive queue lock :

First cache line (contains ->next / prev pointers )
2nd cache line (skb->peeked)
3rd cache line (skb->truesize)

I believe we could get rid of skb->peeked completely.

I will cook a patch, but basically the idea is that the last owner of a
skb (right before skb->users becomes 0) can have the 'ownership' and
thus increase stats.

The 3rd cache line miss is easily avoided by the following patch.

But I also want to work on the idea I gave few days back, having a
separate queue and use splice to transfer the 'softirq queue' into
a calm queue in a different cache line.

I expect a 50 % performance increase under load, maybe 1.5 Mpps.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 16d88ba9ff1c..37d4e8da6482 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1191,7 +1191,13 @@ static void udp_rmem_release(struct sock *sk, int size, int partial)
 /* Note: called with sk_receive_queue.lock held */
 void udp_skb_destructor(struct sock *sk, struct sk_buff *skb)
 {
-	udp_rmem_release(sk, skb->truesize, 1);
+	/* HACK HACK HACK :
+	 * Instead of using skb->truesize here, find a copy of it in skb->dev.
+	 * This avoids a cache line miss in this path,
+	 * while sk_receive_queue lock is held.
+	 * Look at __udp_enqueue_schedule_skb() to find where this copy is done.
+	 */
+	udp_rmem_release(sk, (int)(unsigned long)skb->dev, 1);
 }
 EXPORT_SYMBOL(udp_skb_destructor);
 
@@ -1201,6 +1207,11 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	int rmem, delta, amt, err = -ENOMEM;
 	int size = skb->truesize;
 
+	/* help udp_skb_destructor() to get skb->truesize from skb->dev
+	 * without a cache line miss.
+	 */
+	skb->dev = (struct net_device *)(unsigned long)size;
+
 	/* try to avoid the costly atomic add/sub pair when the receive
 	 * queue is full; always allow at least a packet
 	 */
@@ -1233,7 +1244,6 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	/* no need to setup a destructor, we will explicitly release the
 	 * forward allocated memory on dequeue
 	 */
-	skb->dev = NULL;
 	sock_skb_set_dropcount(sk, skb);
 
 	__skb_queue_tail(list, skb);
