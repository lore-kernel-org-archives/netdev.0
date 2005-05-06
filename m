From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH TCP 3/4] Adjust alpha according to RTT timing
Date: Fri,  6 May 2005 20:40:34 +0300 (IDT)
Message-ID: <20050506174034.20140.37477.77065@galon.ev-en.org>
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

This is another H-TCP layer patch. This patch adds an rtt scaling to the alpha
parameter. This increases alpha for large distance networks.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

---
 net/ipv4/tcp_htcp.c |   13 +++++++++++++
 1 files changed, 13 insertions(+)

Index: 2.6.11-stephen-htcp/net/ipv4/tcp_htcp.c
===================================================================
--- 2.6.11-stephen-htcp.orig/net/ipv4/tcp_htcp.c
+++ 2.6.11-stephen-htcp/net/ipv4/tcp_htcp.c
@@ -12,6 +12,10 @@
 #define BETA_MIN	(1<<6)  /* 0.5 with shift << 7 */
 #define BETA_MAX	102	/* 0.8 with shift << 7 */
 
+static int use_rtt_scaling = 1;
+module_param(use_rtt_scaling, int, 0644);
+MODULE_PARM_DESC(use_rtt_scaling, "turn on/off RTT scaling");
+
 struct htcp_ca {
 	u32	alpha;		/* Fixed point arith, << 7 */
 	u32	beta;           /* Fixed point arith, << 7 */
@@ -85,6 +89,15 @@ static inline void htcp_alpha_update(str
 	ca->alpha = 2*factor*((1<<7)-ca->beta);
 	if (!ca->alpha)
 		ca->alpha = 1<<7;
+
+	if (use_rtt_scaling && minRTT) {
+		u32 scale;
+		scale = (HZ<<3)/(10*minRTT);
+		scale = min(max(scale, 1U<<2), 10U<<3); /* clamping ratio to interval [0.5,10]<<3 */
+		ca->alpha = (ca->alpha<<3)/scale;
+		if (!ca->alpha)
+			ca->alpha = 1<<7;
+	}
 }
 
 /* After we have the rtt data to calculate beta, we'd still prefer to wait one
