From: kaber@trash.net
Subject: [PATCH 2/2] netfilter: nf_ct_sip: fix SDP parsing in TCP SIP messages for some Cisco phones
Date: Tue, 17 May 2011 07:26:54 +0200
Message-ID: <1305610014-3056-3-git-send-email-kaber@trash.net>
References: <1305610014-3056-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36181 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1EQF1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 01:27:24 -0400
In-Reply-To: <1305610014-3056-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Some Cisco phones do not place the Content-Length field at the end of the
SIP message. This is valid, due to a misunderstanding of the specification
the parser expects the SDP body to start directly after the Content-Length
field. Fix the parser to scan for \r\n\r\n to locate the beginning of the
SDP body.

Reported-by: Teresa Kang <teresa_kang@gemtek.com.tw>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_sip.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 1f81abd..c05c0dc 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1419,6 +1419,7 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 	const char *dptr, *end;
 	s16 diff, tdiff = 0;
 	int ret = NF_ACCEPT;
+	bool term;
 	typeof(nf_nat_sip_seq_adjust_hook) nf_nat_sip_seq_adjust;
 
 	if (ctinfo != IP_CT_ESTABLISHED &&
@@ -1453,10 +1454,15 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 		if (dptr + matchoff == end)
 			break;
 
-		if (end + strlen("\r\n\r\n") > dptr + datalen)
-			break;
-		if (end[0] != '\r' || end[1] != '\n' ||
-		    end[2] != '\r' || end[3] != '\n')
+		term = false;
+		for (; end + strlen("\r\n\r\n") <= dptr + datalen; end++) {
+			if (end[0] == '\r' && end[1] == '\n' &&
+			    end[2] == '\r' && end[3] == '\n') {
+				term = true;
+				break;
+			}
+		}
+		if (!term)
 			break;
 		end += strlen("\r\n\r\n") + clen;
 
-- 
1.7.2.3

