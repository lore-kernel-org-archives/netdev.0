From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCHv2] netfilter: Remove skb_is_nonlinear check from
	nf_conntrack_sip
Date: Fri, 14 May 2010 12:01:38 -0600
Message-ID: <20100514180138.GF15969@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [139.142.54.143] ([139.142.54.143]:53166 "EHLO quartz.orcorp.ca"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758608Ab0ENSBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 14:01:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least the XEN net front driver always produces non linear skbs,
so the SIP module does nothing at all when used with that NIC.

Unconditionally linearize the skb..

Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 net/netfilter/nf_conntrack_sip.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

Patrick/Jan, thanks.. This is what I wanted to do in the first place,
but I couldn't convince myself it was safe, as no other nf code does
this..

Unfortunately I can no longer test it :(
 
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4b57216..02d0b59 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1275,13 +1275,10 @@ static int sip_help(struct sk_buff *skb,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (!skb_is_nonlinear(skb))
-		dptr = skb->data + dataoff;
-	else {
-		pr_debug("Copy of skbuff not supported yet.\n");
-		return NF_ACCEPT;
-	}
+	if (unlikely(skb_linearize(skb)))
+		return NF_DROP;
 
+	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
 	if (datalen < strlen("SIP/2.0 200"))
 		return NF_ACCEPT;
-- 
1.6.0.4

