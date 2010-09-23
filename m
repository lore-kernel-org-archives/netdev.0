From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: skb_frag_t can be smaller on small arches
Date: Thu, 23 Sep 2010 17:06:54 +0200
Message-ID: <1285254414.2509.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48245 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab0IWPG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 11:06:58 -0400
Received: by fxm3 with SMTP id 3so100109fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 08:06:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

I remember you reacted on my three years old comment about
commit a309bb072b96bfe (Page offsets and lengths need to be __u32.)

http://www.mail-archive.com/netdev@vger.kernel.org/msg43999.html

Could we reconsider the thing now and allow to shrink
sizeof(skb_shared_info) from 0x104 to 0xbc, considering nothing happened
about scatterlist work ?

This saves 128 bytes on i386 because of alignments, and can be reverted
pretty fast if needed.

Thanks !

[PATCH net-next-2.6] net: skb_frag_t can be smaller on small arches

On 32bit arches, if PAGE_SIZE is smaller than 65536, we can use 16bit
offset and size fields. This patch saves 72 bytes per skb on i386, or
128 bytes after rounding.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |    5 +++++
 1 files changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9e8085a..9a7ea70 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -129,8 +129,13 @@ typedef struct skb_frag_struct skb_frag_t;
 
 struct skb_frag_struct {
 	struct page *page;
+#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
 	__u32 page_offset;
 	__u32 size;
+#else
+	__u16 page_offset;
+	__u16 size;
+#endif
 };
 
 #define HAVE_HW_TIME_STAMP


