From: Andrew Vagin <avagin@openvz.org>
Subject: [PATCH] tcp: restore rcv_wscale in a repair mode (v2)
Date: Wed, 19 Sep 2012 23:40:00 +0400
Message-ID: <1348083600-3881500-1-git-send-email-avagin@openvz.org>
Cc: linux-kernel@vger.kernel.org, Andrew Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@parallels.com>
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

v2: Save backward compatibility on big-endian system. Before
    the first two bytes were snd_wscale and the second two bytes were
    rcv_wscale. Now snd_wscale is opt_val & 0xFFFF and rcv_wscale >> 16.
    This approach is independent on byte ordering.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
CC: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Andrew Vagin <avagin@openvz.org>
---
 net/ipv4/tcp.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index df83d74..42689aa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2348,10 +2348,17 @@ static int tcp_repair_options_est(struct tcp_sock *tp,
 			tp->rx_opt.mss_clamp = opt.opt_val;
 			break;
 		case TCPOPT_WINDOW:
-			if (opt.opt_val > 14)
-				return -EFBIG;
+			{
+				u16 snd_wscale = opt.opt_val & 0xFFFF;
+				u16 rcv_wscale = opt.opt_val >> 16;
+
+				if (snd_wscale > 14 || rcv_wscale > 14)
+					return -EFBIG;
 
-			tp->rx_opt.snd_wscale = opt.opt_val;
+				tp->rx_opt.snd_wscale = snd_wscale;
+				tp->rx_opt.rcv_wscale = rcv_wscale;
+				tp->rx_opt.wscale_ok = 1;
+			}
 			break;
 		case TCPOPT_SACK_PERM:
 			if (opt.opt_val != 0)
-- 
1.7.1
