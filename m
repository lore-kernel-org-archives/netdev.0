From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 1/7] netfilter: add socket to struct nft_pktinfo
Date: Tue, 29 Sep 2015 13:12:14 +0200
Message-ID: <1443525140-13493-2-git-send-email-daniel@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:60161 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934568AbbI2LMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 07:12:37 -0400
In-Reply-To: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The high-level netfilter hook API already enables users to pass a socket,
but that information is lost when the chains are walked.

In order to let internal eval callbacks use the passed filter rather than
skb->sk, add a pointer of type 'struct sock' to 'struct nft_pktinfo' and
set that field via nft_set_pktinfo().

This allows us to run filter chains from situations where skb->sk is unset.
Fall back to skb->sk in case state->sk is NULL, so filter callbacks can be
written in a generic way.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/net/netfilter/nf_tables.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index aa8bee7..05e97ed 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -13,6 +13,7 @@
 #define NFT_JUMP_STACK_SIZE	16
 
 struct nft_pktinfo {
+	struct sock			*sk;
 	struct sk_buff			*skb;
 	const struct net_device		*in;
 	const struct net_device		*out;
@@ -29,6 +30,7 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
+	pkt->sk = state->sk ?: skb->sk;
 	pkt->skb = skb;
 	pkt->in = pkt->xt.in = state->in;
 	pkt->out = pkt->xt.out = state->out;
-- 
2.5.0
