From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Thu, 21 Jan 2010 20:13:44 +0000
Message-ID: <4B58B578.9080505@simon.arlott.org.uk>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B55D372.4020807@gmail.com>    <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B5773C2.2010000@simon.arlott.org.uk>    <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr>    <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>    <4B578E59.8090203@trash.net> <0b01c450344abffd72a5b1b037ee6584e6db6b82@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid> <4B585079.1070904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B585079.1070904@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCPMSS target is dropping SYN packets where:
  1) There is data, or
  2) The data offset makes the TCP header larger than the packet.

Both of these result in an error level printk. This printk has been
removed.

This change avoids dropping SYN packets containing data. If there
is also no MSS option (as well as data), one will not be added
because of possible complications due to the increased packet size.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 net/netfilter/xt_TCPMSS.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index eda64c1..6f21b43 100644
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
@@ -115,6 +107,12 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 		}
 	}
 
+	/* There is data after the header so the option can't be added
+	   without moving it, and doing so may make the SYN packet
+	   itself too large. Accept the packet unmodified instead. */
+	if (tcplen > tcph->doff*4)
+		return 0;
+
 	/*
 	 * MSS Option not found ?! add it..
 	 */
-- 
1.6.3.3

-- 
Simon Arlott
