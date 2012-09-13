From: Andrew Vagin <avagin@openvz.org>
Subject: [PATCH] tcp: restore rcv_wscale in a repair mode
Date: Fri, 14 Sep 2012 01:28:07 +0400
Message-ID: <1347571687-3539973-1-git-send-email-avagin@openvz.org>
Cc: linux-kernel@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>,
	Andrew Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rcv_wscale is a symetric parameter with snd_wscale.

Both this parameters are set on a connection handshake.

Without this value a remote window size can not be interpreted correctly,
because a value from a packet should be shifted on rcv_wscale.

And one more thing is that wscale_ok should be set too.

This patch doesn't break a backward compatibility.
If someone uses it in a old scheme, a rcv window
will be restored with the same bug (rcv_wscale = 0).

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Acked-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Andrew Vagin <avagin@openvz.org>
---
 net/ipv4/tcp.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index df83d74..ed22cd7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2348,10 +2348,22 @@ static int tcp_repair_options_est(struct tcp_sock *tp,
 			tp->rx_opt.mss_clamp = opt.opt_val;
 			break;
 		case TCPOPT_WINDOW:
-			if (opt.opt_val > 14)
-				return -EFBIG;
-
-			tp->rx_opt.snd_wscale = opt.opt_val;
+			{
+				union {
+					struct {
+						u16 snd_wscale;
+						u16 rcv_wscale;
+					};
+					u32 raw;
+				} val = { .raw = opt.opt_val };
+
+				if (val.snd_wscale > 14 || val.rcv_wscale > 14)
+					return -EFBIG;
+
+				tp->rx_opt.snd_wscale = val.snd_wscale;
+				tp->rx_opt.rcv_wscale = val.rcv_wscale;
+				tp->rx_opt.wscale_ok = 1;
+			}
 			break;
 		case TCPOPT_SACK_PERM:
 			if (opt.opt_val != 0)
-- 
1.7.1
