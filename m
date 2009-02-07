From: David Miller <davem@davemloft.net>
Subject: Re: TX pre-headers...
Date: Sat, 07 Feb 2009 00:10:41 -0800 (PST)
Message-ID: <20090207.001041.146584084.davem@davemloft.net>
References: <20090206.014107.231141422.davem@davemloft.net>
	<498C26C5.7010003@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36910
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752731AbZBGIKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 03:10:45 -0500
In-Reply-To: <498C26C5.7010003@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Fri, 06 Feb 2009 13:02:13 +0100

> Absolutely yes, this would help the s/390 qeth drivers too

Well, I did some research and it seems all of the cases we could
actually solve with such a scheme need at a maximum 32 bytes.

We already ensure 16 bytes, via NET_SKB_PAD.

So instead of all of this complex "who has the largest TX header size
and what is it" code, we can simply increase NET_SKB_PAD to 32.

You still need that headroom check there, simply because tunneling and
other device stacking situations can cause the headroom to be depleted
before your device sees the packet.

Any objections? :-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08670d0..5eba400 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1287,7 +1287,7 @@ static inline int skb_network_offset(const struct sk_buff *skb)
  * The networking layer reserves some headroom in skb data (via
  * dev_alloc_skb). This is used to avoid having to reallocate skb data when
  * the header has to grow. In the default case, if the header has to grow
- * 16 bytes or less we avoid the reallocation.
+ * 32 bytes or less we avoid the reallocation.
  *
  * Unfortunately this headroom changes the DMA alignment of the resulting
  * network packet. As for NET_IP_ALIGN, this unaligned DMA is expensive
@@ -1295,11 +1295,11 @@ static inline int skb_network_offset(const struct sk_buff *skb)
  * perhaps setting it to a cacheline in size (since that will maintain
  * cacheline alignment of the DMA). It must be a power of 2.
  *
- * Various parts of the networking layer expect at least 16 bytes of
+ * Various parts of the networking layer expect at least 32 bytes of
  * headroom, you should not reduce this.
  */
 #ifndef NET_SKB_PAD
-#define NET_SKB_PAD	16
+#define NET_SKB_PAD	32
 #endif
 
 extern int ___pskb_trim(struct sk_buff *skb, unsigned int len);
