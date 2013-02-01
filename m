From: roy.qing.li@gmail.com
Subject: [PATCH 1/2 net-next] xfrm: count esp/ah header to lifetime
Date: Fri,  1 Feb 2013 13:17:15 +0800
Message-ID: <1359695836-5666-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:50337 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab3BAFRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 00:17:32 -0500
Received: by mail-pa0-f49.google.com with SMTP id kp6so49186pab.8
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 21:17:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

rfc4301 4.4.2 says:

(a) If byte count is used, then the implementation SHOULD count the
    number of bytes to which the IPsec cryptographic algorithm is
    applied.  For ESP, this is the encryption algorithm (including
    Null encryption) and for AH, this is the authentication
    algorithm.  This includes pad bytes, etc.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_input.c  |    4 +++-
 net/xfrm/xfrm_output.c |    8 +++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ab2bb42..da156e9 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -114,6 +114,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	unsigned int family;
 	int decaps = 0;
 	int async = 0;
+	int skb_len = 0;
 
 	/* A negative encap_type indicates async resumption. */
 	if (encap_type < 0) {
@@ -192,6 +193,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		skb_dst_force(skb);
 
+		skb_len = skb->len;
 		nexthdr = x->type->input(x, skb);
 
 		if (nexthdr == -EINPROGRESS)
@@ -219,7 +221,7 @@ resume:
 
 		x->repl->advance(x, seq);
 
-		x->curlft.bytes += skb->len;
+		x->curlft.bytes += skb_len;
 		x->curlft.packets++;
 
 		spin_unlock(&x->lock);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 3670526..2c5aa8d 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -79,9 +79,6 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 			goto error;
 		}
 
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-
 		spin_unlock_bh(&x->lock);
 
 		skb_dst_force(skb);
@@ -90,6 +87,11 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		if (err == -EINPROGRESS)
 			goto out_exit;
 
+		spin_lock_bh(&x->lock);
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+		spin_unlock_bh(&x->lock);
+
 resume:
 		if (err) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEPROTOERROR);
-- 
1.7.10.4
