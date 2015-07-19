From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCHv2 net-next] net: #ifdefify sk_classid member of struct sock
Date: Sun, 19 Jul 2015 22:21:13 +0200
Message-ID: <1437337273-16775-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:34520 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229AbbGSUVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2015 16:21:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk_classid member is only required when CONFIG_CGROUP_NET_CLASSID is
enabled. #ifdefify it to reduce the size of struct sock on 32 bit
systems, at least.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
v2:
- ensure we'll error out in nft_meta_get_init() if CONFIG_CGROUP_NET_CLASSID
  is not set

 include/net/sock.h       |    2 ++
 net/netfilter/nft_meta.c |    4 ++++
 2 files changed, 6 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 05a8c1aea251..4353ef70bf48 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -429,7 +429,9 @@ struct sock {
 	void			*sk_security;
 #endif
 	__u32			sk_mark;
+#ifdef CONFIG_CGROUP_NET_CLASSID
 	u32			sk_classid;
+#endif
 	struct cg_proto		*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk);
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 52561e1c31e2..cb2f13ebb5a6 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -166,11 +166,13 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 			goto err;
 		*dest = out->group;
 		break;
+#ifdef CONFIG_CGROUP_NET_CLASSID
 	case NFT_META_CGROUP:
 		if (skb->sk == NULL || !sk_fullsock(skb->sk))
 			goto err;
 		*dest = skb->sk->sk_classid;
 		break;
+#endif
 	default:
 		WARN_ON(1);
 		goto err;
@@ -246,7 +248,9 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 	case NFT_META_CPU:
 	case NFT_META_IIFGROUP:
 	case NFT_META_OIFGROUP:
+#ifdef CONFIG_CGROUP_NET_CLASSID
 	case NFT_META_CGROUP:
+#endif
 		len = sizeof(u32);
 		break;
 	case NFT_META_IIFNAME:
-- 
1.7.10.4
