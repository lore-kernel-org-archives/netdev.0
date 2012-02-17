From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT] nf_contrack_udp: handle packets with padding and hwchecksum
Date: Fri, 17 Feb 2012 10:16:48 -0800
Message-ID: <20120217101648.01f31fcd@nehalam.linuxnetplumber.net>
References: <20120130155816.GA1400@phenom.dumpdata.com>
	<20120130083843.160ffe5e@nehalam.linuxnetplumber.net>
	<1327944148.3303.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1327944148.3303.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If UDP packet with extra padding is received on a device that
does hardware checksumming (but not checking) is processed
by netfilter conntrack, it would generate a bogus warning
about the checksum being incorrect.

There were two possible solutions. The netfilter conntrack
code could trim the packet, discarding the extra padding
and adjusting the checksum. Or it can force regular
non-offloaded checksum. This patch implements the latter
on the principal that is better for firewall code to not
modify the packet.

Compile tested only; haven't been able to reproduce the
problem yet.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against -net tree, after review/test it should go
to stable as well.

--- a/net/netfilter/nf_conntrack_proto_udp.c	2012-01-10 10:57:00.407196614 -0800
+++ b/net/netfilter/nf_conntrack_proto_udp.c	2012-02-17 10:06:18.038472559 -0800
@@ -125,12 +125,17 @@ static int udp_error(struct net *net, st
 	 * We skip checking packets on the outgoing path
 	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
-	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
-	    nf_checksum(skb, hooknum, dataoff, IPPROTO_UDP, pf)) {
-		if (LOG_INVALID(net, IPPROTO_UDP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
-				"nf_ct_udp: bad UDP checksum ");
-		return -NF_ACCEPT;
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING) {
+		/* Special case for hardware checksum offload with padding */
+		if (skb->ip_summed == CHECKSUM_COMPLETE && udplen > ntohs(hdr->len))
+			skb->ip_summed = CHECKSUM_NONE;
+
+		if (nf_checksum(skb, hooknum, dataoff, IPPROTO_UDP, pf)) {
+			if (LOG_INVALID(net, IPPROTO_UDP))
+				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+					      "nf_ct_udp: bad UDP checksum ");
+			return -NF_ACCEPT;
+		}
 	}
 
 	return NF_ACCEPT;
