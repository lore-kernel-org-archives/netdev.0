From: Kevin Cernekee <cernekee@gmail.com>
Subject: [PATCH v4] netfilter: nf_conntrack_sip: Handle Cisco 7941/7945 IP phones
Date: Mon, 17 Dec 2012 20:33:58 -0800
Message-ID: <1355805238-2460-1-git-send-email-cernekee@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Gabor Juhos <juhosg@openwrt.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most SIP devices use a source port of 5060/udp on SIP requests, so the
response automatically comes back to port 5060:

    phone_ip:5060 -> proxy_ip:5060   REGISTER
    proxy_ip:5060 -> phone_ip:5060   100 Trying

The newer Cisco IP phones, however, use a randomly chosen high source
port for the SIP request but expect the response on port 5060:

    phone_ip:49173 -> proxy_ip:5060  REGISTER
    proxy_ip:5060 -> phone_ip:5060   100 Trying

Standard Linux NAT, with or without nf_nat_sip, will send the reply back
to port 49173, not 5060:

    phone_ip:49173 -> proxy_ip:5060  REGISTER
    proxy_ip:5060 -> phone_ip:49173  100 Trying

But the phone is not listening on 49173, so it will never see the reply.

This patch modifies nf_*_sip to work around this quirk by extracting
the SIP response port from the Via: header, iff the source IP in the
packet header matches the source IP in the SIP request.

Signed-off-by: Kevin Cernekee <cernekee@gmail.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
---


Baseline: git://1984.lsi.us.es/nf-next

v3->v4 changes:

Fix patch context and APIs to match the current Linux tree.  These
changes are from OpenWRT (Gabor?) and David W.

v4 was tested with Cisco 7945 (high UDP destination port) and Snom m9
(normal "symmetric" UDP destination port), both on IPv4 only.

I've been running a recent OpenWRT port of this patch (Attitude Adjustment
release, 3.3 kernel) for ~2mo, with both phones as clients.


 include/linux/netfilter/nf_conntrack_sip.h |    3 +++
 net/netfilter/nf_conntrack_sip.c           |   17 +++++++++++++++++
 net/netfilter/nf_nat_sip.c                 |   27 ++++++++++++++++++++++++---
 3 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index 387bdd0..ba7f571 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -4,12 +4,15 @@
 
 #include <net/netfilter/nf_conntrack_expect.h>
 
+#include <linux/types.h>
+
 #define SIP_PORT	5060
 #define SIP_TIMEOUT	3600
 
 struct nf_ct_sip_master {
 	unsigned int	register_cseq;
 	unsigned int	invite_cseq;
+	__be16		forced_dport;
 };
 
 enum sip_expectation_classes {
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index df8f4f2..72a67bb 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1440,8 +1440,25 @@ static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
+	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned int matchoff, matchlen;
 	unsigned int cseq, i;
+	union nf_inet_addr addr;
+	__be16 port;
+
+	/* Many Cisco IP phones use a high source port for SIP requests, but
+	 * listen for the response on port 5060.  If we are the local
+	 * router for one of these phones, save the port number from the
+	 * Via: header so that nf_nat_sip can redirect the responses to
+	 * the correct port.
+	 */
+	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen,
+				    SIP_HDR_VIA_UDP, NULL, &matchoff,
+				    &matchlen, &addr, &port) > 0 &&
+	    port != ct->tuplehash[dir].tuple.src.u.udp.port &&
+	    nf_inet_addr_cmp(&addr, &ct->tuplehash[dir].tuple.src.u3))
+		ct_sip_info->forced_dport = port;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
 		const struct sip_handler *handler;
diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index 16303c7..5951146e 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -95,6 +95,7 @@ static int map_addr(struct sk_buff *skb, unsigned int protoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 	char buffer[INET6_ADDRSTRLEN + sizeof("[]:nnnnn")];
 	unsigned int buflen;
 	union nf_inet_addr newaddr;
@@ -107,7 +108,8 @@ static int map_addr(struct sk_buff *skb, unsigned int protoff,
 	} else if (nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.dst.u3, addr) &&
 		   ct->tuplehash[dir].tuple.dst.u.udp.port == port) {
 		newaddr = ct->tuplehash[!dir].tuple.src.u3;
-		newport = ct->tuplehash[!dir].tuple.src.u.udp.port;
+		newport = ct_sip_info->forced_dport ? :
+			  ct->tuplehash[!dir].tuple.src.u.udp.port;
 	} else
 		return 1;
 
@@ -144,6 +146,7 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 	unsigned int coff, matchoff, matchlen;
 	enum sip_header_types hdr;
 	union nf_inet_addr addr;
@@ -258,6 +261,21 @@ next:
 	    !map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_TO))
 		return NF_DROP;
 
+	/* Mangle destination port for Cisco phones, then fix up checksums */
+	if (dir == IP_CT_DIR_REPLY && ct_sip_info->forced_dport) {
+		struct udphdr *uh;
+
+		if (!skb_make_writable(skb, skb->len))
+			return NF_DROP;
+
+		uh = (void *)skb->data + protoff;
+		uh->dest = ct_sip_info->forced_dport;
+
+		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo, protoff,
+					      0, 0, NULL, 0))
+			return NF_DROP;
+	}
+
 	return NF_ACCEPT;
 }
 
@@ -311,8 +329,10 @@ static unsigned int nf_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 	union nf_inet_addr newaddr;
 	u_int16_t port;
+	__be16 srcport;
 	char buffer[INET6_ADDRSTRLEN + sizeof("[]:nnnnn")];
 	unsigned int buflen;
 
@@ -326,8 +346,9 @@ static unsigned int nf_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
 	/* If the signalling port matches the connection's source port in the
 	 * original direction, try to use the destination port in the opposite
 	 * direction. */
-	if (exp->tuple.dst.u.udp.port ==
-	    ct->tuplehash[dir].tuple.src.u.udp.port)
+	srcport = ct_sip_info->forced_dport ? :
+		  ct->tuplehash[dir].tuple.src.u.udp.port;
+	if (exp->tuple.dst.u.udp.port == srcport)
 		port = ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port);
 	else
 		port = ntohs(exp->tuple.dst.u.udp.port);
-- 
1.7.5.4
