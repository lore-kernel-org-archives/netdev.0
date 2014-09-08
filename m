From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: remove dst refcount false sharing for
 prequeue mode
Date: Mon, 08 Sep 2014 08:06:07 -0700
Message-ID: <1410188767.11872.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ED4354.9090904@intel.com>
	 <20140814.162024.2218312002979492106.davem@davemloft.net>
	 <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
	 <20140821.162406.2076033247433267586.davem@davemloft.net>
	 <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:55148 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbaIHPGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 11:06:09 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq14so254820pab.25
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 08:06:09 -0700 (PDT)
In-Reply-To: <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Alexander Duyck reported high false sharing on dst refcount in tcp stack
when prequeue is used. prequeue is the mechanism used when a thread is
blocked in recvmsg()/read() on a TCP socket, using a blocking model
rather than select()/poll()/epoll() non blocking one.

We already try to use RCU in input path as much as possible, but we were
forced to take a refcount on the dst when skb escaped RCU protected
region. When/if the user thread runs on different cpu, dst_release()
will then touch dst refcount again.

Commit 093162553c33 (tcp: force a dst refcount when prequeue packet)
was an example of a race fix.

It turns out the only remaining usage of skb->dst for a packet stored
in a TCP socket prequeue is IP early demux.

We can add a logic to detect when IP early demux is probably going
to use skb->dst. Because we do an optimistic check rather than duplicate
existing logic, we need to guard inet_sk_rx_dst_set() and
inet6_sk_rx_dst_set() from using a NULL dst.

Many thanks to Alexander for providing a nice bug report, git bisection,
and reproducer.

Tested using Alexander script on a 40Gb NIC, 8 RX queues.
Hosts have 24 cores, 48 hyper threads.

echo 0 >/proc/sys/net/ipv4/tcp_autocorking

for i in `seq 0 47`
do
  for j in `seq 0 2`
  do
     netperf -H $DEST -t TCP_STREAM -l 1000 \
             -c -C -T $i,$i -P 0 -- \
             -m 64 -s 64K -D &
  done
done

Before patch : ~6Mpps and ~95% cpu usage on receiver
After patch : ~9Mpps and ~35% cpu usage on receiver.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
v2: remove the skb_dst_drop() before enqueue to backlog, as this is
currently valid only for ESTABLISHED sockets.
 net/ipv4/tcp_ipv4.c |   20 ++++++++++++++++----
 net/ipv6/tcp_ipv6.c |   15 +++++++++------
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3f9bc3f0bba0..7881b96d2b72 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1559,7 +1559,17 @@ bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 	    skb_queue_len(&tp->ucopy.prequeue) == 0)
 		return false;
 
-	skb_dst_force(skb);
+	/* Before escaping RCU protected region, we need to take care of skb
+	 * dst. Prequeue is only enabled for established sockets.
+	 * For such sockets, we might need the skb dst only to set sk->sk_rx_dst
+	 * Instead of doing full sk_rx_dst validity here, let's perform
+	 * an optimistic check.
+	 */
+	if (likely(sk->sk_rx_dst))
+		skb_dst_drop(skb);
+	else
+		skb_dst_force(skb);
+
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
 	tp->ucopy.memory += skb->truesize;
 	if (tp->ucopy.memory > sk->sk_rcvbuf) {
@@ -1765,9 +1775,11 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 
-	dst_hold(dst);
-	sk->sk_rx_dst = dst;
-	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+	if (dst) {
+		dst_hold(dst);
+		sk->sk_rx_dst = dst;
+		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+	}
 }
 EXPORT_SYMBOL(inet_sk_rx_dst_set);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5b3c70ff7a72..1835480336ac 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -93,13 +93,16 @@ static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
 static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	const struct rt6_info *rt = (const struct rt6_info *)dst;
 
-	dst_hold(dst);
-	sk->sk_rx_dst = dst;
-	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-	if (rt->rt6i_node)
-		inet6_sk(sk)->rx_dst_cookie = rt->rt6i_node->fn_sernum;
+	if (dst) {
+		const struct rt6_info *rt = (const struct rt6_info *)dst;
+
+		dst_hold(dst);
+		sk->sk_rx_dst = dst;
+		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+		if (rt->rt6i_node)
+			inet6_sk(sk)->rx_dst_cookie = rt->rt6i_node->fn_sernum;
+	}
 }
 
 static void tcp_v6_hash(struct sock *sk)
