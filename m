From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] net: Correct TOS priority mapping for DSCP EF
Date: Mon, 15 Sep 2014 16:50:47 +0200
Message-ID: <20140915145023.4834.93706.stgit@dragon>
References: <=1410783785.7106.154.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626AbaIOOuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 10:50:51 -0400
In-Reply-To: <=1410783785.7106.154.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DSCP value for Expedited Forwarding (EF) got mapped to
internal priority TC_PRIO_INTERACTIVE_BULK, which ends up in
medium/best-effort priority band(1) of pfifo_fast

This patch change TOS mapping, causing the DSCP EF to get mapped
to TC_PRIO_INTERACTIVE, which end up in high priority band(0)
of pfifo_fast.

While performing this policy change, document the TOS to priority
lookup table ip_tos2prio[16].  Thus, making it easier to
understand this table for reviewers.

The DSCP AFxx mappings are also suboptimal, but we choose not to
change those mapping, only document the mapping in the code.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/route.c |   43 +++++++++++++++++++++++++++----------------
 1 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 234a43e..800b6f4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -168,23 +168,34 @@ static struct dst_ops ipv4_dst_ops = {
 
 #define ECN_OR_COST(class)	TC_PRIO_##class
 
+/* lookup: tos bitmasked 0x1E and shifted right (tos>>1) in rt_tos2priority() */
 const __u8 ip_tos2prio[16] = {
-	TC_PRIO_BESTEFFORT,
-	ECN_OR_COST(BESTEFFORT),
-	TC_PRIO_BESTEFFORT,
-	ECN_OR_COST(BESTEFFORT),
-	TC_PRIO_BULK,
-	ECN_OR_COST(BULK),
-	TC_PRIO_BULK,
-	ECN_OR_COST(BULK),
-	TC_PRIO_INTERACTIVE,
-	ECN_OR_COST(INTERACTIVE),
-	TC_PRIO_INTERACTIVE,
-	ECN_OR_COST(INTERACTIVE),
-	TC_PRIO_INTERACTIVE_BULK,
-	ECN_OR_COST(INTERACTIVE_BULK),
-	TC_PRIO_INTERACTIVE_BULK,
-	ECN_OR_COST(INTERACTIVE_BULK)
+	/* Desc format: two least-significant bits should have been
+	 * for ECN (see "-" split). The hex values represent the TOS
+	 * byte in IP-header (masked with 0x1E)
+	 */
+	TC_PRIO_BESTEFFORT,           /* [0] 000-00 = 0x00 default            */
+	ECN_OR_COST(BESTEFFORT),      /* [1] 000-10 = 0x02 TOS-"mincost"      */
+	TC_PRIO_BESTEFFORT,           /* [2] 001-00 = 0x04 TOS-"reliability"  */
+	ECN_OR_COST(BESTEFFORT),      /* [3] 001-10 = 0x06                    */
+	TC_PRIO_BULK,                 /* [4] 010-00 = 0x08 TOS-"throughput"
+				       * (incidentally maps) DSCP(AF11+21+31+41)
+				       */
+	ECN_OR_COST(BULK),            /* [5] 010-10 = 0x0A                    */
+	TC_PRIO_BULK,                 /* [6] 011-00 = 0x0C                    */
+	ECN_OR_COST(BULK),            /* [7] 011-10 = 0x0E                    */
+	TC_PRIO_INTERACTIVE,          /* [8] 100-00 = 0x10 TOS-"lowdelay"
+				       * (incidentally maps) DSCP(AF12+22+32+42)
+				       */
+	ECN_OR_COST(INTERACTIVE),     /* [9] 100-10 = 0x12                    */
+	TC_PRIO_INTERACTIVE,          /*[10] 101-00 = 0x14                    */
+	ECN_OR_COST(INTERACTIVE),     /*[11] 101-10 = 0x16                    */
+	TC_PRIO_INTERACTIVE_BULK,     /*[12] 110-00 = 0x18
+				       * (incidentally maps) DSCP(AF13+23+33+43)
+				       */
+	ECN_OR_COST(INTERACTIVE_BULK),/*[13] 110-10 = 0x1A                    */
+	TC_PRIO_INTERACTIVE,          /*[14] 111-00 = 0x1C maps DSCP(EF)      */
+	ECN_OR_COST(INTERACTIVE_BULK) /*[15] 111-10 = 0x1E                    */
 };
 EXPORT_SYMBOL(ip_tos2prio);
 
