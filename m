From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH 2/10] [SKBUFF]: Add skb_morph
Date: Mon, 26 Nov 2007 15:50:22 +0900 (JST)
Message-ID: <200711260650.lAQ6oOnl006778@toshiba.co.jp>
References: <20071014042604.GA11431@gondor.apana.org.au>
	<E1Igv4m-00030E-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:40394 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbXKZHU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 02:20:27 -0500
Received: from inet-tsb5.toshiba.co.jp (inet-tsb5 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id lAQ7KP43008564
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 16:20:26 +0900 (JST)
Received: from arc1.toshiba.co.jp ([133.199.194.235])
	by inet-tsb5.toshiba.co.jp  with ESMTP id lAQ6oRrS017916
	for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 15:50:27 +0900 (JST)
Received: (from root@localhost)
	by arc1.toshiba.co.jp  id lAQ6oRTE029780
	for netdev@vger.kernel.org; Mon, 26 Nov 2007 15:50:27 +0900 (JST)
Received: from mx2.toshiba.co.jp (localhost [127.0.0.1])
	by ovp1.toshiba.co.jp  with ESMTP id lAQ6oQ88024953
	for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 15:50:26 +0900 (JST)
In-Reply-To: <E1Igv4m-00030E-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello,

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 14 Oct 2007 12:27:40 +0800

> [SKBUFF]: Add skb_morph
> 
> This patch creates a new function skb_morph that's just like skb_clone
> except that it lets user provide the spare skb that will be overwritten
> by the one that's to be cloned.
> 
> This will be used by IP fragment reassembly so that we get back the same
> skb that went in last (rather than the head skb that we get now which
> requires us to carry around double pointers all over the place).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


> +struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
> +{
> +	skb_release_data(dst);
> +	return __skb_clone(dst, src);
> +}
> +EXPORT_SYMBOL_GPL(skb_morph);

The refcount of nfct is leaked by this function. As a result,
nf_conntrack_ipv6.ko cannot be unloaded after doing "ping6 -s 2000 ..." .
dst->dst and dst->secpath are also needed to be released, I think.

Please consider to apply this patch.

Regards,

-- Yasuyuki Kozakai

>From a876e48dfed87dd564a352509c74e572b09bed7d Mon Sep 17 00:00:00 2001
From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date: Sun, 25 Nov 2007 01:02:29 +0900
Subject: [SKBUFF]: Fixes refcount leaks by skb_morph

skb_morph can take a dirty skb as destination skb, so it should release
dst, nfct, and secpath before overriding them by members in source skb.

Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
---
 net/core/skbuff.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 32d5826..72f720b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -442,6 +442,11 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 {
 	skb_release_data(dst);
+	dst_release(dst->dst);
+#ifdef CONFIG_INET
+	secpath_put(dst->sp);
+#endif
+	nf_reset(dst);
 	return __skb_clone(dst, src);
 }
 EXPORT_SYMBOL_GPL(skb_morph);
-- 
1.5.2.2



