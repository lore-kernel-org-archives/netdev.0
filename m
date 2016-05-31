From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] tcp: extend window to fit all restored unacked data in a send queue
Date: Tue, 31 May 2016 08:02:36 -0700
Message-ID: <1464706956-29291-1-git-send-email-avagin@openvz.org>
Cc: linux-kernel@vger.kernel.org, criu@openvz.org,
	Andrey Vagin <avagin@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Data from a send queue is sent only if there is enough space in a
window, so when we restore unacked data, we need to expand a window to
fit this data.

Currently we don't do this and tcp_acceptable_seq() returns
tcp_wnd_end(tp) instead of tp->snd_nxt. The other side drops packets
with this seq, becuse tcp_sequence() returns false (seq < tp->rcv_nxt).

Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/ipv4/tcp_output.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 79a03b8..b36f968 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -75,6 +75,10 @@ static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
 	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 
+	/* All sent data have to fit into the window */
+	if (unlikely(tp->repair) && before(tcp_wnd_end(tp), tp->snd_nxt))
+		tp->snd_wnd = tp->snd_nxt - tp->snd_una;
+
 	tp->packets_out += tcp_skb_pcount(skb);
 	if (!prior_packets || icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
 	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
-- 
2.5.5
