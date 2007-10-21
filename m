From: David Miller <davem@davemloft.net>
Subject: Re: net: alignment problem in icmp code
Date: Sun, 21 Oct 2007 16:02:15 -0700 (PDT)
Message-ID: <20071021.160215.115679567.davem@davemloft.net>
References: <20071021113405.37fa0bc5@poseidon.drzeus.cx>
	<20071021.124814.50617600.davem@davemloft.net>
	<20071021232113.52ce1be7@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drzeus@drzeus.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbXJUXCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 19:02:04 -0400
In-Reply-To: <20071021232113.52ce1be7@poseidon.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ossman <drzeus@drzeus.cx>
Date: Sun, 21 Oct 2007 23:21:13 +0200

> Not sure that would be valid. memcpy() is defined as having void*
> arguments, and the compiler cannot just ignore that if it chooses to
> inline it.

Yes it can, there are C language rules about the alignment of types
that the compiler completely can take advantage of in those kinds of
situations.

If you don't believe me, compile something like the following
with optimizations enabled:

void foo(unsigned long long *a,
	 unsigned long long *b)
{
	memcpy(a, b, sizeof(*a));
}

You will get a 64-bit load and a 64-bit store emitted by
the compiler.  Here is what we get on sparc64:

foo:
	ldx	[%o1], %g1
	jmp	%o7+8
	 stx	%g1, [%o0]

Structure assignment is also essentially just another kind of
inline memcpy().

> Still, just give it the char* from the skb and it cannot make any
> assumption on alignment.

Yes, that would make it more likely to work.

However, instead of relying upon magic like this, let's just tell the
compiler explicitly what it going on by using get_unaligned().

Next, there are redundant stores being done here since the code and
type are explicitly overwritten in various ways.

commit 6471862b69e9272125f6a01916e6587523bf91f3
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Sun Oct 21 16:01:49 2007 -0700

    [IPV4]: Handle potentially unaligned icmp headers in skb.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 272c69e..2b654b1 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -92,6 +92,7 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 #include <net/checksum.h>
+#include <asm/unaligned.h>
 
 /*
  *	Build xmit assembly blocks
@@ -766,6 +767,17 @@ out_err:
 	goto out;
 }
 
+static void fill_icmp_param_data(struct icmp_bxm *param,
+				 struct icmphdr *src,
+				 u8 type, u8 code)
+{
+	struct icmphdr *dst = &param->data.icmph;
+
+	dst->type = type;
+	dst->code = code;
+	dst->un.gateway = get_unaligned(&src->un.gateway);
+}
+
 /*
  *	Handle ICMP_ECHO ("ping") requests.
  *
@@ -783,8 +795,10 @@ static void icmp_echo(struct sk_buff *skb)
 	if (!sysctl_icmp_echo_ignore_all) {
 		struct icmp_bxm icmp_param;
 
-		icmp_param.data.icmph	   = *icmp_hdr(skb);
-		icmp_param.data.icmph.type = ICMP_ECHOREPLY;
+		fill_icmp_param_data(&icmp_param,
+				     icmp_hdr(skb),
+				     ICMP_ECHOREPLY,
+				     icmp_hdr(skb)->code);
 		icmp_param.skb		   = skb;
 		icmp_param.offset	   = 0;
 		icmp_param.data_len	   = skb->len;
@@ -819,9 +833,8 @@ static void icmp_timestamp(struct sk_buff *skb)
 	icmp_param.data.times[2] = icmp_param.data.times[1];
 	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
 		BUG();
-	icmp_param.data.icmph	   = *icmp_hdr(skb);
-	icmp_param.data.icmph.type = ICMP_TIMESTAMPREPLY;
-	icmp_param.data.icmph.code = 0;
+	fill_icmp_param_data(&icmp_param, icmp_hdr(skb),
+			     ICMP_TIMESTAMPREPLY, 0);
 	icmp_param.skb		   = skb;
 	icmp_param.offset	   = 0;
 	icmp_param.data_len	   = 0;
