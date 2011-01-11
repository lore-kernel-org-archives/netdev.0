From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ah: reload pointers to skb data after calling skb_cow_data()
Date: Tue, 11 Jan 2011 18:13:33 +0100
Message-ID: <4D2C8FBD.8060701@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070508030403010909000903"
Cc: Steffen Klassert <steffen.klassert@secunet.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59918 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192Ab1AKRNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 12:13:38 -0500
Received: by bwz15 with SMTP id 15so20299371bwz.19
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 09:13:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070508030403010909000903
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

patch is enclosed.


Regards,
Nicolas

--------------070508030403010909000903
Content-Type: text/x-patch;
 name="0001-ah-reload-pointers-to-skb-data-after-calling-skb_co.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ah-reload-pointers-to-skb-data-after-calling-skb_co.pat";
 filename*1="ch"

>From ba44ef6e00ca0f4c13e425f4a39e8749c56db843 Mon Sep 17 00:00:00 2001
From: Dang Hongwu <hongwu.dang@6wind.com>
Date: Tue, 11 Jan 2011 12:00:05 -0500
Subject: [PATCH] ah: reload pointers to skb data after calling skb_cow_data()

skb_cow_data() may allocate a new data buffer, so pointers on
skb should be set after this function.

Bug was introduced by commit dff3bb06 and 8631e9bd.

Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
Acked-by: Krzysztof Witek <krzysztof.witek@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ah4.c |    7 ++++---
 net/ipv6/ah6.c |    8 +++++---
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 880a5ec..86961be 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -314,14 +314,15 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	ah = (struct ip_auth_hdr *)skb->data;
-	iph = ip_hdr(skb);
-	ihl = ip_hdrlen(skb);
 
 	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
 		goto out;
 	nfrags = err;
 
+	ah = (struct ip_auth_hdr *)skb->data;
+	iph = ip_hdr(skb);
+	ihl = ip_hdrlen(skb);
+
 	work_iph = ah_alloc_tmp(ahash, nfrags, ihl + ahp->icv_trunc_len);
 	if (!work_iph)
 		goto out;
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ee82d4e..1aba54a 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -538,14 +538,16 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, ah_hlen))
 		goto out;
 
-	ip6h = ipv6_hdr(skb);
-
-	skb_push(skb, hdr_len);
 
 	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
 		goto out;
 	nfrags = err;
 
+	ah = (struct ip_auth_hdr *)skb->data;
+	ip6h = ipv6_hdr(skb);
+
+	skb_push(skb, hdr_len);
+
 	work_iph = ah_alloc_tmp(ahash, nfrags, hdr_len + ahp->icv_trunc_len);
 	if (!work_iph)
 		goto out;
-- 
1.5.6.5


--------------070508030403010909000903--
