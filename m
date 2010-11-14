From: Kevin Cernekee <cernekee@gmail.com>
Subject: [PATCH/RFC] netfilter: nf_conntrack_sip: Handle quirky Cisco phones
Date: Sun, 14 Nov 2010 00:32:21 -0800
Message-ID: <28d666269c390965f1a4edca42f93c12@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<coreteam@netfilter.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
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

This issue was seen on a Cisco CP-7965G, firmware 8-5(3).  It appears
to be a well-known problem on 7941 and newer:

http://www.voip-info.org/wiki/view/Standalone+Cisco+7941%252F7961+without+a+local+PBX

Search for "Connecting to the outside world"

I contacted Cisco support and they were not amenable to changing the
behavior.  It appears to be RFC3261-compliant, as the "Sent-by port"
field in the request specifies 5060:

18.2.2 Sending Responses

   The server transport uses the value of the top Via header field in
   order to determine where to send a response.  It MUST follow the
   following process:

...

      o  Otherwise (for unreliable unicast transports), if the top Via
         has a "received" parameter, the response MUST be sent to the
         address in the "received" parameter, using the port indicated
         in the "sent-by" value, or using port 5060 if none is specified
         explicitly.  If this fails, for example, elicits an ICMP "port
         unreachable" response, the procedures of Section 5 of [4]
         SHOULD be used to determine where to send the response.

This patch modifies nf_*_sip to work around this quirk, by rewriting
the response port to 5060 when the following conditions are met:

 - User-Agent starts with "Cisco"

 - Incoming TTL was exactly 64 (meaning that our system is the phone's
   local router, not an intermediate router)

Tested on Linus' latest 2.6.37-rc tree.

Signed-off-by: Kevin Cernekee <cernekee@gmail.com>
---
 include/linux/netfilter/nf_conntrack_sip.h |    2 ++
 net/ipv4/netfilter/nf_nat_sip.c            |   12 ++++++++++++
 net/netfilter/nf_conntrack_sip.c           |   25 +++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index 0ce91d5..a6ea620 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -8,6 +8,7 @@
 struct nf_ct_sip_master {
 	unsigned int	register_cseq;
 	unsigned int	invite_cseq;
+	unsigned int	cisco_port_mangle;
 };
 
 enum sip_expectation_classes {
@@ -90,6 +91,7 @@ enum sip_header_types {
 	SIP_HDR_EXPIRES,
 	SIP_HDR_CONTENT_LENGTH,
 	SIP_HDR_CALL_ID,
+	SIP_HDR_USER_AGENT,
 };
 
 enum sdp_header_types {
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index e40cf78..4b9a46d 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -121,6 +121,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	struct nf_conn_help *help = nfct_help(ct);
 	unsigned int coff, matchoff, matchlen;
 	enum sip_header_types hdr;
 	union nf_inet_addr addr;
@@ -225,6 +226,17 @@ next:
 			return NF_DROP;
 	}
 
+	/* Mangle destination port for Cisco phones, then fix up checksums */
+	if (help->help.ct_sip_info.cisco_port_mangle) {
+		struct udphdr *uh;
+
+		uh = (struct udphdr *)(skb->data + ip_hdrlen(skb));
+		uh->dest = htons(SIP_PORT);
+
+		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo, 0, 0, NULL, 0))
+			return NF_DROP;
+	}
+
 	if (!map_sip_addr(skb, dataoff, dptr, datalen, SIP_HDR_FROM) ||
 	    !map_sip_addr(skb, dataoff, dptr, datalen, SIP_HDR_TO))
 		return NF_DROP;
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index bcf47eb..6042f66 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -18,6 +18,7 @@
 #include <linux/udp.h>
 #include <linux/tcp.h>
 #include <linux/netfilter.h>
+#include <linux/ip.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
@@ -338,6 +339,7 @@ static const struct sip_header ct_sip_hdrs[] = {
 	[SIP_HDR_EXPIRES]		= SIP_HDR("Expires", NULL, NULL, digits_len),
 	[SIP_HDR_CONTENT_LENGTH]	= SIP_HDR("Content-Length", "l", NULL, digits_len),
 	[SIP_HDR_CALL_ID]		= SIP_HDR("Call-Id", "i", NULL, callid_len),
+	[SIP_HDR_USER_AGENT]		= SIP_HDR("User-Agent", NULL, NULL, string_len),
 };
 
 static const char *sip_follow_continuation(const char *dptr, const char *limit)
@@ -1366,6 +1368,29 @@ static int process_sip_request(struct sk_buff *skb, unsigned int dataoff,
 	unsigned int matchoff, matchlen;
 	unsigned int cseq, i;
 
+	/* Many Cisco IP phones use a high source port for SIP requests, but
+	 * listen for the response on port 5060.  If we are the local
+	 * router for one of these phones, flag the connection here so that
+	 * responses will be redirected to the correct port.
+	 */
+	do {
+		static const char cisco[] = "Cisco";
+		struct iphdr *iph = ip_hdr(skb);
+		struct nf_conn_help *help = nfct_help(ct);
+
+		if (iph->ttl != 63)
+			break;
+		if (ct_sip_get_header(ct, *dptr, 0, *datalen,
+				SIP_HDR_USER_AGENT, &matchoff, &matchlen) <= 0)
+			break;
+		if (matchlen < strlen(cisco))
+			break;
+		if (strnicmp(*dptr + matchoff, cisco, strlen(cisco)) != 0)
+			break;
+
+		help->help.ct_sip_info.cisco_port_mangle = 1;
+	} while (0);
+
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
 		const struct sip_handler *handler;
 
-- 
1.7.0.4
