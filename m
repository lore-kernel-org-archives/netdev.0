From: adobriyan@gmail.com
Subject: [PATCH] nf_conntrack_sip: fix by making helper pointers thread-local
Date: Thu, 21 Aug 2008 00:09:00 +0400
Message-ID: <20080820200900.GA32237@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick, do I read correctly that ->help hook can run concurrently with itself?

If yes, apply this patch to fix potential crashes and all sorts of
nasties.



[PATCH] nf_conntrack_sip: de-static helper pointers

Helper's ->help hook can run concurrently with itself, so iterating over
SIP helpers with static pointer won't work reliably.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_sip.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1193,7 +1193,6 @@ static const struct sip_handler sip_handlers[] = {
 static int process_sip_response(struct sk_buff *skb,
 				const char **dptr, unsigned int *datalen)
 {
-	static const struct sip_handler *handler;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	unsigned int matchoff, matchlen;
@@ -1214,6 +1213,8 @@ static int process_sip_response(struct sk_buff *skb,
 	dataoff = matchoff + matchlen + 1;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
+		const struct sip_handler *handler;
+
 		handler = &sip_handlers[i];
 		if (handler->response == NULL)
 			continue;
@@ -1228,13 +1229,14 @@ static int process_sip_response(struct sk_buff *skb,
 static int process_sip_request(struct sk_buff *skb,
 			       const char **dptr, unsigned int *datalen)
 {
-	static const struct sip_handler *handler;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	unsigned int matchoff, matchlen;
 	unsigned int cseq, i;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
+		const struct sip_handler *handler;
+
 		handler = &sip_handlers[i];
 		if (handler->request == NULL)
 			continue;

