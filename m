From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC net-next] net: Assert napi_gro_cb size against skb->cb[]
Date: Fri, 31 Jul 2015 11:51:09 -0700
Message-ID: <1438368669-659-1-git-send-email-f.fainelli@gmail.com>
Cc: herbert@gondor.apana.org.au, daniel@iogearbox.net,
	edumazet@google.com, davem@davemloft.net,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35089 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbbGaSxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 14:53:49 -0400
Received: by pabkd10 with SMTP id kd10so45023037pab.2
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 11:53:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64-bits hosts, napi_gro_cb is 48 bytes, which is exactly the size of
skb->cb[], while on 32-bits hosts it is 36 bytes, but if it were to
grow, we would not be catching a size inflation as we should.

Make sure that we have enough room for a napi_gro_cb to be hosted in
skb->cb[], and put this build-time assertion in skb_gro_reset_offset()
since this function is invoked by the GRO layers entry points.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/core/dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4870c3556a5a..20bc82604b75 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4115,6 +4115,8 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
 	const struct skb_shared_info *pinfo = skb_shinfo(skb);
 	const skb_frag_t *frag0 = &pinfo->frags[0];
 
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct napi_gro_cb));
+
 	NAPI_GRO_CB(skb)->data_offset = 0;
 	NAPI_GRO_CB(skb)->frag0 = NULL;
 	NAPI_GRO_CB(skb)->frag0_len = 0;
-- 
2.1.0
