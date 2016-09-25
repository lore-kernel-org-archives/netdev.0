From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/53] netfilter: nf_ct_sip: allow tab character in SIP headers
Date: Mon, 26 Sep 2016 01:06:20 +0200
Message-ID: <1474844823-2026-11-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54542 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941198AbcIYXHa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:30 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 2E248C0B40
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1F742DA7E9
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0F141DA7FA
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:27 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marco Angaroni <marcoangaroni@gmail.com>

Current parsing methods for SIP headers do not allow the presence of
tab characters between header name and header value. As a result Call-ID
SIP headers like the following are discarded by IPVS SIP persistence
engine:

"Call-ID\t: mycallid@abcde"
"Call-ID:\tmycallid@abcde"

In above examples Call-IDs are represented as strings in C language.
Obviously in real message we have byte "09" before/after colon (":").

Proposed fix is in nf_conntrack_sip module.
Function sip_skip_whitespace() should skip tabs in addition to spaces,
since in SIP grammar whitespace (WSP) corresponds to space or tab.

Below is an extract of relevant SIP ABNF syntax.

Call-ID  =  ( "Call-ID" / "i" ) HCOLON callid
callid   =  word [ "@" word ]

HCOLON  =  *( SP / HTAB ) ":" SWS
SWS     =  [LWS] ; sep whitespace
LWS     =  [*WSP CRLF] 1*WSP ; linear whitespace
WSP     =  SP / HTAB
word    =  1*(alphanum / "-" / "." / "!" / "%" / "*" /
           "_" / "+" / "`" / "'" / "~" /
           "(" / ")" / "<" / ">" /
           ":" / "\" / DQUOTE /
           "/" / "[" / "]" / "?" /
           "{" / "}" )

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_sip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index d8035351aff5..621b81c7bddc 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -330,7 +330,7 @@ static const char *sip_follow_continuation(const char *dptr, const char *limit)
 static const char *sip_skip_whitespace(const char *dptr, const char *limit)
 {
 	for (; dptr < limit; dptr++) {
-		if (*dptr == ' ')
+		if (*dptr == ' ' || *dptr == '\t')
 			continue;
 		if (*dptr != '\r' && *dptr != '\n')
 			break;
-- 
2.1.4
