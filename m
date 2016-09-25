From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/53] netfilter: nf_ct_sip: correct parsing of continuation lines in SIP headers
Date: Mon, 26 Sep 2016 01:06:13 +0200
Message-ID: <1474844823-2026-4-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54522 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941090AbcIYXHX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:23 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 2E57CB6C7E
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:21 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1C1BADA847
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:21 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1799DDA81A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:19 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marco Angaroni <marcoangaroni@gmail.com>

Current parsing methods for SIP headers do not properly manage
continuation lines: in case of Call-ID header the first character of
Call-ID header value is truncated. As a result IPVS SIP persistence
engine hashes over a call-id that is not exactly the one present in
the originale message.

Example: "Call-ID: \r\n abcdeABCDE1234"
results in extracted call-id equal to "bcdeABCDE1234".

In above example Call-ID is represented as a string in C language.
Obviously in real message the first bytes after colon (":") are
"20 0d 0a 20".

Proposed fix is in nf_conntrack_sip module.
Since sip_follow_continuation() function walks past the leading
spaces or tabs of the continuation line, sip_skip_whitespace()
should simply return the ouput of sip_follow_continuation().
Otherwise another iteration of the for loop is done and dptr
is incremented by one pointing to the second character of the
first word in the header.

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
 net/netfilter/nf_conntrack_sip.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 7d77217de6a3..251a9a44d189 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -334,8 +334,7 @@ static const char *sip_skip_whitespace(const char *dptr, const char *limit)
 		if (*dptr != '\r' && *dptr != '\n')
 			break;
 		dptr = sip_follow_continuation(dptr, limit);
-		if (dptr == NULL)
-			return NULL;
+		break;
 	}
 	return dptr;
 }
-- 
2.1.4
