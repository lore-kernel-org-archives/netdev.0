From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP BIC not binary searching correctly
Date: Fri, 18 Mar 2005 14:05:47 -0800
Message-ID: <20050318140547.1ca66106@dxpl.pdx.osdl.net>
References: <20050318135713.1171df83@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Marcelo W. Tosatti" <marcelo.tosatti@cyclades.com.br>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050318135713.1171df83@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2.4 version of same fix as 2.6.11.

The problem is that BIC is supposed to reset the cwnd to the last loss value
rather than ssthresh when loss is detected.  The correct code (from the BIC
TCP code for Web100) is in this patch.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2005-03-18 14:03:44 -08:00
+++ b/net/ipv4/tcp_input.c	2005-03-18 14:03:44 -08:00
@@ -1642,7 +1642,10 @@
 static void tcp_undo_cwr(struct tcp_opt *tp, int undo)
 {
 	if (tp->prior_ssthresh) {
-		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
+		if (tcp_is_bic(tp))
+			tp->snd_cwnd = max(tp->snd_cwnd, tp->bictcp.last_max_cwnd);
+		else
+			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
 
 		if (undo && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
