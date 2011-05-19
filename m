From: Benoit Sigoure <tsunanet@gmail.com>
Subject: [PATCH] tcp: Lower the initial RTO to 1s as per draft RFC 2988bis-02.
Date: Wed, 18 May 2011 23:36:16 -0700
Message-ID: <1305786976-84532-1-git-send-email-tsunanet@gmail.com>
References: <20110519.014656.1735519603194773578.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Benoit Sigoure <tsuna@stumbleupon.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	hagen@jauu.net, eric.dumazet@gmail.com,
	alexander.zimmermann
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110519.014656.1735519603194773578.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Sigoure <tsuna@stumbleupon.com>

Draft RFC 2988bis-02 recommends that the initial RTO be lowered
from 3 seconds down to 1 second, and that in case of a timeout
during the TCP 3WHS, the RTO should fallback to 3 seconds when
data transmission begins.
---

On Wed, May 18, 2011 at 10:46 PM, David Miller <davem@davemloft.net> wrote:
> From: tsuna <tsunanet@gmail.com>
> Date: Wed, 18 May 2011 21:33:21 -0700
>
>> On Wed, May 18, 2011 at 9:14 PM, David Miller <davem@davemloft.net> wrote:
>>> I really would rather see the initial RTO be static and be set to 1
>>> with fallback RTO of 3.
>>
>> I can also provide a simple patch for this if you want to start from
>> there.  And then maybe we can discuss having a runtime knob some more
>> :-)
>
> Yeah why don't we do that :-)

Alright, here we go.


 include/net/tcp.h    |    5 ++++-
 net/ipv4/tcp_input.c |   13 +++++++++----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..274d761 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -122,7 +122,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #endif
 #define TCP_RTO_MAX	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
-#define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/
+/* The next 2 values come from Draft RFC 2988bis-02. */
+#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))		/* initial RTO value	*/
+#define TCP_TIMEOUT_INIT_FALLBACK ((unsigned)(3*HZ))	/* initial RTO to fallback to when
+							 * a timeout happens during the 3WHS.	*/
 
 #define TCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ/2U)) /* Maximal interval between probes
 					                 * for local resources.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bef9f04..a36bc35 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -868,6 +868,11 @@ static void tcp_init_metrics(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
+	/* If we had to retransmit anything during the 3WHS, use
+	 * the initial fallback RTO as per draft RFC 2988bis-02.
+	 */
+	int init_rto = inet_csk(sk)->icsk_retransmits ?
+		TCP_TIMEOUT_INIT_FALLBACK : TCP_TIMEOUT_INIT;
 
 	if (dst == NULL)
 		goto reset;
@@ -890,7 +895,7 @@ static void tcp_init_metrics(struct sock *sk)
 	if (dst_metric(dst, RTAX_RTT) == 0)
 		goto reset;
 
-	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
+	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (init_rto << 3))
 		goto reset;
 
 	/* Initial rtt is determined from SYN,SYN-ACK.
@@ -916,7 +921,7 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);
-	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp) {
+	if (inet_csk(sk)->icsk_rto < init_rto && !tp->rx_opt.saw_tstamp) {
 reset:
 		/* Play conservative. If timestamps are not
 		 * supported, TCP will fail to recalculate correct
@@ -924,8 +929,8 @@ reset:
 		 */
 		if (!tp->rx_opt.saw_tstamp && tp->srtt) {
 			tp->srtt = 0;
-			tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
-			inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+			tp->mdev = tp->mdev_max = tp->rttvar = init_rto;
+			inet_csk(sk)->icsk_rto = init_rto;
 		}
 	}
 	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
-- 
1.7.0.4
