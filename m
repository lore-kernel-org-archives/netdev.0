From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/08: nf_conntrack_reasm: properly handle packets fragmented into a single fragment
Date: Wed, 24 Feb 2010 18:49:28 +0100 (MET)
Message-ID: <20100224174928.16391.35421.sendpatchset@x2.localnet>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48767 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757382Ab0BXRta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 12:49:30 -0500
In-Reply-To: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9e2dcf72023d1447f09c47d77c99b0c49659e5ce
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Feb 19 18:18:37 2010 +0100

    netfilter: nf_conntrack_reasm: properly handle packets fragmented into a single fragment
    
    When an ICMPV6_PKT_TOOBIG message is received with a MTU below 1280,
    all further packets include a fragment header.
    
    Unlike regular defragmentation, conntrack also needs to "reassemble"
    those fragments in order to obtain a packet without the fragment
    header for connection tracking. Currently nf_conntrack_reasm checks
    whether a fragment has either IP6_MF set or an offset != 0, which
    makes it ignore those fragments.
    
    Remove the invalid check and make reassembly handle fragment queues
    containing only a single fragment.
    
    Reported-and-tested-by: Ulrich Weber <uweber@astaro.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index ad1fcda..f1171b7 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -469,7 +469,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 
 	/* all original skbs are linked into the NFCT_FRAG6_CB(head).orig */
 	fp = skb_shinfo(head)->frag_list;
-	if (NFCT_FRAG6_CB(fp)->orig == NULL)
+	if (fp && NFCT_FRAG6_CB(fp)->orig == NULL)
 		/* at above code, head skb is divided into two skbs. */
 		fp = fp->next;
 
@@ -595,12 +595,6 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	hdr = ipv6_hdr(clone);
 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
 
-	if (!(fhdr->frag_off & htons(0xFFF9))) {
-		pr_debug("Invalid fragment offset\n");
-		/* It is not a fragmented frame */
-		goto ret_orig;
-	}
-
 	if (atomic_read(&nf_init_frags.mem) > nf_init_frags.high_thresh)
 		nf_ct_frag6_evictor();
 
