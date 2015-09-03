From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nfnetlink: work around wrong endianess in res_id field
Date: Thu,  3 Sep 2015 11:51:00 +0200
Message-ID: <1441273861-31092-6-git-send-email-pablo@netfilter.org>
References: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46743 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101AbbICJoi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 05:44:38 -0400
In-Reply-To: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The convention in nfnetlink is to use network byte order in every header field
as well as in the attribute payload. The initial version of the batching
infrastructure assumes that res_id comes in host byte order though.

The only client of the batching infrastructure is nf_tables, so let's add a
workaround to address this inconsistency. We currently have 11 nfnetlink
subsystems according to NFNL_SUBSYS_COUNT, so we can assume that the subsystem
2560, ie. htons(10), will not be allocated anytime soon, so it can be an alias
of nf_tables from the nfnetlink batching path when interpreting the res_id
field.

Based on original patch from Florian Westphal.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 0c0e8ec..70277b1 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -444,6 +444,7 @@ done:
 static void nfnetlink_rcv(struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
+	u_int16_t res_id;
 	int msglen;
 
 	if (nlh->nlmsg_len < NLMSG_HDRLEN ||
@@ -468,7 +469,12 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 
 		nfgenmsg = nlmsg_data(nlh);
 		skb_pull(skb, msglen);
-		nfnetlink_rcv_batch(skb, nlh, nfgenmsg->res_id);
+		/* Work around old nft using host byte order */
+		if (nfgenmsg->res_id == NFNL_SUBSYS_NFTABLES)
+			res_id = NFNL_SUBSYS_NFTABLES;
+		else
+			res_id = ntohs(nfgenmsg->res_id);
+		nfnetlink_rcv_batch(skb, nlh, res_id);
 	} else {
 		netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
 	}
-- 
1.7.10.4
