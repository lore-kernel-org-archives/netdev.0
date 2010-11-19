From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: use reciprocal divide
Date: Fri, 19 Nov 2010 09:04:46 +0100
Message-ID: <1290153886.29509.10.camel@edumazet-laptop>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
	 <b2c34db84e88366e465af590900ae3db@localhost>
	 <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
	 <1290153111.29509.2.camel@edumazet-laptop>
	 <1290153398.29509.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35612 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab0KSIEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 03:04:51 -0500
Received: by wyb28 with SMTP id 28so4160999wyb.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 00:04:50 -0800 (PST)
In-Reply-To: <1290153398.29509.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At compile time, we can replace the DIV_K instruction (divide by a
constant value) by a reciprocal divide.

At exec time, the expensive divide is replaced by a multiply, a less
expensive operation on most processors.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/filter.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index a1edb5d..13853c7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -37,6 +37,7 @@
 #include <asm/uaccess.h>
 #include <asm/unaligned.h>
 #include <linux/filter.h>
+#include <linux/reciprocal_div.h>
 
 enum {
 	BPF_S_RET_K = 1,
@@ -202,7 +203,7 @@ unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *filter, int
 			A /= X;
 			continue;
 		case BPF_S_ALU_DIV_K:
-			A /= f_k;
+			A = reciprocal_divide(A, f_k);
 			continue;
 		case BPF_S_ALU_AND_X:
 			A &= X;
@@ -503,6 +504,7 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 			/* check for division by zero */
 			if (ftest->k == 0)
 				return -EINVAL;
+			ftest->k = reciprocal_value(ftest->k);
 			break;
 		case BPF_S_LD_MEM:
 		case BPF_S_LDX_MEM:


