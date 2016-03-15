From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/18] ipvs: correct initial offset of Call-ID header search in SIP persistence engine
Date: Tue, 15 Mar 2016 02:27:50 +0100
Message-ID: <1458005282-24665-7-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marco Angaroni <marcoangaroni@gmail.com>

The IPVS SIP persistence engine is not able to parse the SIP header
"Call-ID" when such header is inserted in the first positions of
the SIP message.

When IPVS is configured with "--pe sip" option, like for example:
ipvsadm -A -u 1.2.3.4:5060 -s rr --pe sip -p 120 -o
some particular messages (see below for details) do not create entries
in the connection template table, which can be listed with:
ipvsadm -Lcn --persistent-conn

Problematic SIP messages are SIP responses having "Call-ID" header
positioned just after message first line:
SIP/2.0 200 OK
[Call-ID header here]
[rest of the headers]

When "Call-ID" header is positioned down (after a few other headers)
it is correctly recognized.

This is due to the data offset used in get_callid function call inside
ip_vs_pe_sip.c file: since dptr already points to the start of the
SIP message, the value of dataoff should be initially 0.
Otherwise the header is searched starting from some bytes after the
first character of the SIP message.

Fixes: 758ff0338722 ("IPVS: sip persistence engine")
Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index c4e9ca0..0a6eb5c 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -88,7 +88,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
 
-	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
+	if (get_callid(dptr, 0, datalen, &matchoff, &matchlen))
 		return -EINVAL;
 
 	/* N.B: pe_data is only set on success,
-- 
2.1.4

