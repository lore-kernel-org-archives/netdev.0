From: Kevin Cernekee <cernekee@gmail.com>
Subject: [PATCH v3] netfilter: nf_conntrack_sip: Handle Cisco 7941/7945 IP phones
Date: Sun, 21 Nov 2010 18:40:11 -0800
Message-ID: <f0955e6c2110044fa058d0f3ecf945ca@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<coreteam@netfilter.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pek
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[v3:
  Only activate the new forced_dport logic if the IP matches, but the
  port does not. ]

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
---
 include/linux/netfilter/nf_conntrack_sip.h |    3 +++
 net/ipv4/netfilter/nf_nat_sip.c            |   26 +++++++++++++++++++++++---
 net/netfilter/nf_conntrack_sip.c           |   17 +++++++++++++++++
 3 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index 0ce91d5..feda699 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -2,12 +2,15 @@
 #define __NF_CONNTRACK_SIP_H__
 #ifdef __KERNEL__
 
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
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index e40cf78..e5856b0 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -73,6 +73,7 @@ static int map_addr(struct sk_buff *skb, unsigned int dataoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	struct nf_conn_help *help = nfct_help(ct);
 	char buffer[sizeof("nnn.nnn.nnn.nnn:nnnnn")];
 	unsigned int buflen;
 	__be32 newaddr;
@@ -85,7 +86,8 @@ static int map_addr(struct sk_buff *skb, unsigned int dataoff,
 	} else if (ct->tuplehash[dir].tuple.dst.u3.ip == addr->ip &&
 		   ct->tuplehash[dir].tuple.dst.u.udp.port == port) {
 		newaddr = ct->tuplehash[!dir].tuple.src.u3.ip;
-		newport = ct->tuplehash[!dir].tuple.src.u.udp.port;
+		newport = help->help.ct_sip_info.forced_dport ? :
+			  ct->tuplehash[!dir].tuple.src.u.udp.port;
 	} else
 		return 1;
 
@@ -121,6 +123,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	struct nf_conn_help *help = nfct_help(ct);
 	unsigned int coff, matchoff, matchlen;
 	enum sip_header_types hdr;
 	union nf_inet_addr addr;
@@ -229,6 +232,20 @@ next:
 	    !map_sip_addr(skb, dataoff, dptr, datalen, SIP_HDR_TO))
 		return NF_DROP;
 
+	/* Mangle destination port for Cisco phones, then fix up checksums */
+	if (dir == IP_CT_DIR_REPLY && help->help.ct_sip_info.forced_dport) {
+		struct udphdr *uh;
+
+		if (!skb_make_writable(skb, skb->len))
+			return NF_DROP;
+
+		uh = (struct udphdr *)(skb->data + ip_hdrlen(skb));
+		uh->dest = help->help.ct_sip_info.forced_dport;
+
+		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo, 0, 0, NULL, 0))
+			return NF_DROP;
+	}
+
 	return NF_ACCEPT;
 }
 
@@ -280,8 +297,10 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int dataoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	struct nf_conn_help *help = nfct_help(ct);
 	__be32 newip;
 	u_int16_t port;
+	__be16 srcport;
 	char buffer[sizeof("nnn.nnn.nnn.nnn:nnnnn")];
 	unsigned buflen;
 
@@ -294,8 +313,9 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int dataoff,
 	/* If the signalling port matches the connection's source port in the
 	 * original direction, try to use the destination port in the opposite
 	 * direction. */
-	if (exp->tuple.dst.u.udp.port ==
-	    ct->tuplehash[dir].tuple.src.u.udp.port)
+	srcport = help->help.ct_sip_info.forced_dport ? :
+		  ct->tuplehash[dir].tuple.src.u.udp.port;
+	if (exp->tuple.dst.u.udp.port == srcport)
 		port = ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port);
 	else
 		port = ntohs(exp->tuple.dst.u.udp.port);
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index bcf47eb..776130d 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1363,8 +1363,25 @@ static int process_sip_request(struct sk_buff *skb, unsigned int dataoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conn_help *help = nfct_help(ct);
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
+		help->help.ct_sip_info.forced_dport = port;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
 		const struct sip_handler *handler;
-- 
1.7.0.4

