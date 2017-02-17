From: Josh Hunt <johunt@akamai.com>
Subject: [RFC] TCP_NOTSENT_LOWAT behavior
Date: Fri, 17 Feb 2017 01:20:05 -0500
Message-ID: <1487312405-18480-1-git-send-email-johunt@akamai.com>
Cc: netdev@vger.kernel.org, jbaron@akamai.com,
        Josh Hunt <johunt@akamai.com>
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:10023 "EHLO
        prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752681AbdBQGaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 01:30:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric

A team here was using the TCP_NOTSENT_LOWAT socket option and noticed that
more unsent data than they were expecting was sitting in the write queue. I
took a look and noticed that while we don't allow allocation of new skbs once
we exceed this value, we still allow adding data to the skb at the tail of the
write queue. In this context that means we could add up to size_goal to the
skb, which could be up to 64kb.

The patch below attempts to put a cap on the amount we allow to write over
the TCP_NOTSENT_LOWAT value at 50%. In cases where the setting is smaller this
will allow the # of unsent bytes to more closely reflect the value. In cases
where the setting is 128kb or higher this will have no impact compared to the
current behavior. This should have two benefits: 1) finer-grain control of the
amount of unsent data, 2) reduction of TCP memory for values of TCP_NOTSENT_LOWAT
< 128k.

I reran the netperf results from your original commit with and without my patch:

4.10.0-rc8:
# echo $(( 128 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
# (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
TCPv6     2064      2   21735   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
TCP       1912    465   21735   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y

# echo $(( 64 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
# (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
TCPv6     2064      2   19859   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
TCP       1912    465   19859   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y

4.10.0-rc8 + patch:
# echo $(( 128 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
# (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
TCPv6     2064      2   21570   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
TCP       1912    465   21570   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y

# echo $(( 64 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
# (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
TCPv6     2064      2   18257   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
TCP       1912    465   18257   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y

I still need to do more testing, but wanted to get feedback on the idea.

Josh

---
In tcp_sendmsg() we check to see if we are under the TCP_NOTSENT_LOWAT
threshold before allocating a new skb. However we do no checks when adding
page frags to an existing skb. On systems with large size_goals we can
wind up adding up to 64k to the send queue over the TCP_NOTSENT_LOWAT
setting.

This patch adds a cap on the amount of data we can add to the send queue
at 50% above the TCP_NOTSENT_LOWAT setting.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 include/net/tcp.h |  7 ++++++-
 net/ipv4/tcp.c    | 14 ++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6061963..a2cce3c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1773,10 +1773,15 @@ static inline u32 tcp_notsent_lowat(const struct tcp_sock *tp)
 	return tp->notsent_lowat ?: net->ipv4.sysctl_tcp_notsent_lowat;
 }
 
+static inline u32 tcp_notsent_bytes(const struct tcp_sock *tp)
+{
+	return tp->write_seq - tp->snd_nxt;
+}
+
 static inline bool tcp_stream_memory_free(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	u32 notsent_bytes = tp->write_seq - tp->snd_nxt;
+	u32 notsent_bytes = tcp_notsent_bytes(tp);
 
 	return notsent_bytes < tcp_notsent_lowat(tp);
 }
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0efb4c7..c1b5e08 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1178,6 +1178,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	while (msg_data_left(msg)) {
 		int copy = 0;
 		int max = size_goal;
+		int notsent_lowat;
 
 		skb = tcp_write_queue_tail(sk);
 		if (tcp_send_head(sk)) {
@@ -1227,6 +1228,19 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 				TCP_SKB_CB(skb)->sacked |= TCPCB_REPAIRED;
 		}
 
+		notsent_lowat = tcp_notsent_lowat(tp);
+		if (notsent_lowat != -1) {
+			/* Cap unsent bytes at no more than 50% above TCP_NOTSENT_LOWAT value */
+			notsent_lowat += (notsent_lowat >> 1) - tcp_notsent_bytes(tp);
+			notsent_lowat = (notsent_lowat / mss_now) * mss_now;
+
+			if (notsent_lowat > 0 && copy > notsent_lowat) {
+				copy = notsent_lowat;
+			} else if (notsent_lowat <= 0) {
+				goto wait_for_sndbuf;
+			}
+		}
+
 		/* Try to append data to the end of skb. */
 		if (copy > msg_data_left(msg))
 			copy = msg_data_left(msg);
-- 
1.9.1
