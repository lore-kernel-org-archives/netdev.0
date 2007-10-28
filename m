From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Sun, 28 Oct 2007 14:01:37 -0700
Message-ID: <1193605297.26695.121.camel@localhost>
References: <E1IkAo9-0006xM-00@gondolin.me.apana.org.au>
	 <ygfk5p7vvq7.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	acme@ghostprotocols.net, netdev@vger.kernel.org
To: Urs Thuermann <urs.thuermann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1276 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036AbXJ1V2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 17:28:08 -0400
In-Reply-To: <ygfk5p7vvq7.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-10-28 at 21:18 +0100, Urs Thuermann wrote:

> I have written a short test program to show this and tested it on i686
> (gcc-4.2.2) and powerpc (gcc-3.4.5) without optimization and with -O6.

Thanks for that.

> BTW, shouldn't unsigned long be replaced by unsigned int to avoid
> 64-bit operations one some platforms?

probably unsigned long should be u16.

Compiled, untested.

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 7c0b515..c3890cc 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -922,25 +922,19 @@ static int atrtr_ioctl(unsigned int cmd, void __user *arg)
  * Checksum: This is 'optional'. It's quite likely also a good
  * candidate for assembler hackery 8)
  */
-static unsigned long atalk_sum_partial(const unsigned char *data,
-				       int len, unsigned long sum)
+static u16 atalk_sum_partial(const unsigned char *data,
+			     int len, u16 sum)
 {
-	/* This ought to be unwrapped neatly. I'll trust gcc for now */
 	while (len--) {
-		sum += *data;
-		sum <<= 1;
-		if (sum & 0x10000) {
-			sum++;
-			sum &= 0xffff;
-		}
-		data++;
+		sum += *data++;
+		sum = ((sum & 0x8000) >> 15) | ((sum & 0x7fff) << 1);
 	}
 	return sum;
 }
 
 /*  Checksum skb data --  similar to skb_checksum  */
-static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
-				   int len, unsigned long sum)
+static u16 atalk_sum_skb(const struct sk_buff *skb, int offset,
+			 int len, u16 sum)
 {
 	int start = skb_headlen(skb);
 	int i, copy;
@@ -1010,13 +1004,13 @@ static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
 
 static __be16 atalk_checksum(const struct sk_buff *skb, int len)
 {
-	unsigned long sum;
+	u16 sum;
 
 	/* skip header 4 bytes */
 	sum = atalk_sum_skb(skb, 4, len-4, 0);
 
 	/* Use 0xFFFF for 0. 0 itself means none */
-	return sum ? htons((unsigned short)sum) : htons(0xFFFF);
+	return cpu_to_be16(sum ? sum : 0xFFFF);
 }
 
 static struct proto ddp_proto = {
      * 




