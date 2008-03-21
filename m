From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Fri, 21 Mar 2008 11:05:15 -0700
Message-ID: <20080321110515.422f9798@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41750 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754462AbYCUS7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 14:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make socket filters work for netlink unicast and notifications.
This is useful for applications like Zebra that get overrun with
messages that are then ignored.

Note: netlink messages are in host byte order, but packet filter
state machine operations are done as network byte order.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/netlink/af_netlink.c	2008-03-21 09:35:54.000000000 -0700
+++ b/net/netlink/af_netlink.c	2008-03-21 11:00:51.000000000 -0700
@@ -886,6 +886,13 @@ retry:
 	if (netlink_is_kernel(sk))
 		return netlink_unicast_kernel(sk, skb);
 
+	if (sk_filter(sk, skb)) {
+		int err = skb->len;
+		kfree_skb(skb);
+		sock_put(sk);
+		return err;
+	}
+
 	err = netlink_attachskb(sk, skb, nonblock, &timeo, ssk);
 	if (err == 1)
 		goto retry;
@@ -980,6 +987,9 @@ static inline int do_one_broadcast(struc
 		netlink_overrun(sk);
 		/* Clone failed. Notify ALL listeners. */
 		p->failure = 1;
+	} else if (sk_filter(sk, p->skb2)) {
+		kfree_skb(p->skb2);
+		p->skb2 = NULL;
 	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
 		netlink_overrun(sk);
 	} else {
@@ -1533,8 +1543,13 @@ static int netlink_dump(struct sock *sk)
 
 	if (len > 0) {
 		mutex_unlock(nlk->cb_mutex);
-		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, len);
+
+		if (sk_filter(sk, skb))
+			kfree_skb(skb);
+		else {
+			skb_queue_tail(&sk->sk_receive_queue, skb);
+			sk->sk_data_ready(sk, skb->len);
+		}
 		return 0;
 	}
 
@@ -1544,8 +1559,12 @@ static int netlink_dump(struct sock *sk)
 
 	memcpy(nlmsg_data(nlh), &len, sizeof(len));
 
-	skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, skb->len);
+	if (sk_filter(sk, skb))
+		kfree_skb(skb);
+	else {
+		skb_queue_tail(&sk->sk_receive_queue, skb);
+		sk->sk_data_ready(sk, skb->len);
+	}
 
 	if (cb->done)
 		cb->done(cb);
