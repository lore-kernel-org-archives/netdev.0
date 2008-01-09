From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ATM]: Check IP header validity in mpc_send_packet
Date: Wed, 9 Jan 2008 21:27:45 +1100
Message-ID: <20080109102745.GA29297@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ftp.linux.org.uk>,
	Chas Williams <chas@cmf.nrl.navy.mil>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4644 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751837AbYAIK1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 05:27:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

[ATM]: Check IP header validity in mpc_send_packet

Al went through the ip_fast_csum callers and found this piece of code
that did not validate the IP header.  While root crashing the machine
by sending bogus packets through raw or AF_PACKET sockets isn't that
serious, it is still nice to react gracefully.

This patch ensures that the skb has enough data for an IP header and
that the header length field is valid.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 2086396..9c7f712 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -542,6 +542,13 @@ static int mpc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if (eth->h_proto != htons(ETH_P_IP))
 		goto non_ip; /* Multi-Protocol Over ATM :-) */
 
+	/* Weed out funny packets (e.g., AF_PACKET or raw). */
+	if (skb->len < ETH_HLEN + sizeof(struct iphdr))
+		goto non_ip;
+	skb_set_network_header(skb, ETH_HLEN);
+	if (skb->len < ETH_HLEN + ip_hdr(skb)->ihl * 4 || ip_hdr(skb)->ihl < 5)
+		goto non_ip;
+
 	while (i < mpc->number_of_mps_macs) {
 		if (!compare_ether_addr(eth->h_dest, (mpc->mps_macs + i*ETH_ALEN)))
 			if ( send_via_shortcut(skb, mpc) == 0 )           /* try shortcut */
