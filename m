From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 41/62: nf_conntrack_sip: fix ct_sip_parse_request() REGISTER request parsing
Date: Tue, 16 Feb 2010 15:56:15 +0100 (MET)
Message-ID: <20100216145613.2796.50352.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52064 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932680Ab0BPO4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:16 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 54101f4f3bed87fa968b57f77f8ff3b09fd88bcf
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Feb 11 12:23:12 2010 +0100

    netfilter: nf_conntrack_sip: fix ct_sip_parse_request() REGISTER request parsing
    
    When requests are parsed, the "sip:" part of the SIP URI should be skipped.
    
    Usually this doesn't matter because address parsing skips forward until after
    the username part, but in case REGISTER requests it doesn't contain a username
    and the address can not be parsed.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 419c5ca..0ca2f2b 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -236,12 +236,13 @@ int ct_sip_parse_request(const struct nf_conn *ct,
 		return 0;
 
 	/* Find SIP URI */
-	limit -= strlen("sip:");
-	for (; dptr < limit; dptr++) {
+	for (; dptr < limit - strlen("sip:"); dptr++) {
 		if (*dptr == '\r' || *dptr == '\n')
 			return -1;
-		if (strnicmp(dptr, "sip:", strlen("sip:")) == 0)
+		if (strnicmp(dptr, "sip:", strlen("sip:")) == 0) {
+			dptr += strlen("sip:");
 			break;
+		}
 	}
 	if (!skp_epaddr_len(ct, dptr, limit, &shift))
 		return 0;
