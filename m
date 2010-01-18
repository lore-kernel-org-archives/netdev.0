From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Mon, 18 Jan 2010 21:08:53 +0000
Message-ID: <4B54CDE5.3070100@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755565Ab0ARVUf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The check for data only needs to apply where the packet length
could be increased by adding the MSS option. (The MSS option
itself applies to the sender's maximum receive size which is
not relevant to any data in its own packet.)

This moves the check for (header size != packet size) to after
attempting to modify an existing MSS option. Another check is
needed before looking through the header to ensure it doesn't
claim to be larger than the packet size.

The ERROR level printk() is also removed as it can be triggered
by remote hosts and is not useful:
[4941777.937417] xt_TCPMSS: bad length (40 bytes)
[4941782.409724] xt_TCPMSS: bad length (40 bytes)
[4941790.762332] xt_TCPMSS: bad length (40 bytes)

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 net/netfilter/xt_TCPMSS.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index eda64c1..76f92bf 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -60,17 +60,9 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	tcplen = skb->len - tcphoff;
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
 
-	/* Since it passed flags test in tcp match, we know it is is
-	   not a fragment, and has data >= tcp header length.  SYN
-	   packets should not contain data: if they did, then we risk
-	   running over MTU, sending Frag Needed and breaking things
-	   badly. --RR */
-	if (tcplen != tcph->doff*4) {
-		if (net_ratelimit())
-			printk(KERN_ERR "xt_TCPMSS: bad length (%u bytes)\n",
-			       skb->len);
+	/* Header cannot be larger than the packet */
+	if (tcplen < tcph->doff*4)
 		return -1;
-	}
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
@@ -115,6 +107,15 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 		}
 	}
 
+	/* Since it passed flags test in tcp match, we know it is
+	   not a fragment, and has data >= tcp header length.  SYN
+	   packets should not contain data: if they did, then we risk
+	   running over MTU, sending Frag Needed and breaking things
+	   badly. --RR
+	*/
+	if (tcplen > tcph->doff*4)
+		return -1;
+
 	/*
 	 * MSS Option not found ?! add it..
 	 */
-- 
1.6.3.3

-- 
Simon Arlott
