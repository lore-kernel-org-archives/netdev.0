From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/14] netfilter: nf_conntrack_sip: extend request line validation
Date: Thu, 10 Nov 2016 01:23:37 +0100
Message-ID: <1478737427-1574-5-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Weber <ulrich.weber@riverbed.com>

on SIP requests, so a fragmented TCP SIP packet from an allow header starting with
 INVITE,NOTIFY,OPTIONS,REFER,REGISTER,UPDATE,SUBSCRIBE
 Content-Length: 0

will not bet interpreted as an INVITE request. Also Request-URI must start with an alphabetic character.

Confirm with RFC 3261
 Request-Line   =  Method SP Request-URI SP SIP-Version CRLF

Fixes: 30f33e6dee80 ("[NETFILTER]: nf_conntrack_sip: support method specific request/response handling")
Signed-off-by: Ulrich Weber <ulrich.weber@riverbed.com>
Acked-by: Marco Angaroni <marcoangaroni@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_sip.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 621b81c7bddc..c3fc14e021ec 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1436,9 +1436,12 @@ static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
 		handler = &sip_handlers[i];
 		if (handler->request == NULL)
 			continue;
-		if (*datalen < handler->len ||
+		if (*datalen < handler->len + 2 ||
 		    strncasecmp(*dptr, handler->method, handler->len))
 			continue;
+		if ((*dptr)[handler->len] != ' ' ||
+		    !isalpha((*dptr)[handler->len+1]))
+			continue;
 
 		if (ct_sip_get_header(ct, *dptr, 0, *datalen, SIP_HDR_CSEQ,
 				      &matchoff, &matchlen) <= 0) {
-- 
2.1.4

