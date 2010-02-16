From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 23/62: xt_TCPMSS: SYN packets are allowed to contain data
Date: Tue, 16 Feb 2010 15:55:51 +0100 (MET)
Message-ID: <20100216145549.2796.91116.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52009 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932420Ab0BPOzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:52 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 10a199394b8f9b4c4e0be6e14a61109a7d891b1b
Author: Simon Arlott <simon@fire.lp0.eu>
Date:   Tue Feb 2 15:33:38 2010 +0100

    netfilter: xt_TCPMSS: SYN packets are allowed to contain data
    
    The TCPMSS target is dropping SYN packets where:
      1) There is data, or
      2) The data offset makes the TCP header larger than the packet.
    
    Both of these result in an error level printk. This printk has been
    removed.
    
    This change avoids dropping SYN packets containing data. If there
    is also no MSS option (as well as data), one will not be added
    because of possible complications due to the increased packet size.
    
    Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

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
