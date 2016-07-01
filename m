From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq
Date: Fri,  1 Jul 2016 11:48:33 +0200 (CEST)
Message-ID: <20160701094833.B281E1A23A2@localhost.localdomain>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not drop packet when CSeq is 0 as 0 is also a valid value for CSeq.

In order to do so, we replace obsolete simple_strtoul() which
returns 0 on error by kstrtouint(). As kstrtouint() requires a
NULL terminated string, we need to use a temporary buffer

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 net/netfilter/nf_conntrack_sip.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index f72ba55..e770477 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1368,6 +1368,7 @@ static int process_sip_response(struct sk_buff *skb, unsigned int protoff,
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	unsigned int matchoff, matchlen, matchend;
 	unsigned int code, cseq, i;
+	char buf[21];
 
 	if (*datalen < strlen("SIP/2.0 200"))
 		return NF_ACCEPT;
@@ -1382,8 +1383,13 @@ static int process_sip_response(struct sk_buff *skb, unsigned int protoff,
 		nf_ct_helper_log(skb, ct, "cannot parse cseq");
 		return NF_DROP;
 	}
-	cseq = simple_strtoul(*dptr + matchoff, NULL, 10);
-	if (!cseq) {
+	if (matchlen > sizeof(buf) - 1) {
+		nf_ct_helper_log(skb, ct, "cannot parse cseq (too big)");
+		return NF_DROP;
+	}
+	memcpy(buf, *dptr + matchoff, matchlen);
+	buf[matchlen] = 0;
+	if (kstrtouint(buf, 10, &cseq)) {
 		nf_ct_helper_log(skb, ct, "cannot get cseq");
 		return NF_DROP;
 	}
@@ -1432,6 +1438,7 @@ static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
 		const struct sip_handler *handler;
+		char buf[21];
 
 		handler = &sip_handlers[i];
 		if (handler->request == NULL)
@@ -1445,8 +1452,13 @@ static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
 			nf_ct_helper_log(skb, ct, "cannot parse cseq");
 			return NF_DROP;
 		}
-		cseq = simple_strtoul(*dptr + matchoff, NULL, 10);
-		if (!cseq) {
+		if (matchlen > sizeof(buf) - 1) {
+			nf_ct_helper_log(skb, ct, "cannot parse cseq(too big)");
+			return NF_DROP;
+		}
+		memcpy(buf, *dptr + matchoff, matchlen);
+		buf[matchlen] = 0;
+		if (kstrtouint(buf, 10, &cseq)) {
 			nf_ct_helper_log(skb, ct, "cannot get cseq");
 			return NF_DROP;
 		}
-- 
2.1.0
