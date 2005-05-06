From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH TCP 1/4] Add undo callback to Stephens cc framework
Date: Fri,  6 May 2005 20:38:31 +0300 (IDT)
Message-ID: <20050506173831.20140.43017.29524@galon.ev-en.org>
References: <20050506173729.20140.93205.37072@galon.ev-en.org>
Cc: netdev@oss.sgi.com, Baruch Even <baruch@ev-en.org>,
        Douglas Leith <doug.leith@nuim.ie>,
        "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050506173729.20140.93205.37072@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When undoing a congestion event due to reordering detection, the ssthresh is
multiplied by two. This is incorrect for anything other than (New)Reno, for
example BIC and H-TCP.

This patch adds a callback that these CC algorithms can attach to, the actual
callback is not realized yet for BIC. The callback is already in use in the
H-TCP patches.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

---
 include/net/tcp.h    |    1 +
 net/ipv4/tcp_input.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: 2.6.11-stephen-htcp/include/net/tcp.h
===================================================================
--- 2.6.11-stephen-htcp.orig/include/net/tcp.h
+++ 2.6.11-stephen-htcp/include/net/tcp.h
@@ -1196,6 +1196,7 @@ struct tcp_ca_type {
 	void (*set_state)(struct tcp_sock *tp, u8 new_state);
 
 	void (*cwnd_event)(struct tcp_sock *tp, enum tcp_ca_event ev);
+	u32 (*undo_cwnd)(struct tcp_sock *tp);
 
 	struct list_head	list;
 	struct module 		*owner;
Index: 2.6.11-stephen-htcp/net/ipv4/tcp_input.c
===================================================================
--- 2.6.11-stephen-htcp.orig/net/ipv4/tcp_input.c
+++ 2.6.11-stephen-htcp/net/ipv4/tcp_input.c
@@ -1573,7 +1573,10 @@ static void DBGUNDO(struct sock *sk, str
 static void tcp_undo_cwr(struct tcp_sock *tp, int undo)
 {
 	if (tp->prior_ssthresh) {
-		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
+		if (tp->ca_proto->undo_cwnd)
+			tp->snd_cwnd = tp->ca_proto->undo_cwnd(tp);
+		else
+			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
 
 		if (undo && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
