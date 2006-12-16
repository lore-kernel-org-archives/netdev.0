From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 06/14] e1000: disable TSO on the 82544 with slab debugging
Date: Sat, 16 Dec 2006 12:04:33 +1100
Message-ID: <E1GvNyb-0005yf-00@gondolin.me.apana.org.au>
References: <4582B22B.5020004@garzik.org>
Cc: arjan@linux.intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1608 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030513AbWLPBFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 20:05:03 -0500
To: jeff@garzik.org (Jeff Garzik)
In-Reply-To: <4582B22B.5020004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
>  
>> +#ifdef CONFIG_DEBUG_SLAB
>> +     /* 82544's work arounds do not play nicely with DEBUG SLAB */
>> +     if (adapter->hw.mac_type == e1000_82544)
>> +             netdev->features &= ~NETIF_F_TSO;
>> +#endif
> 
> NAK, same reason as the others

Any chance you could apply this patch instead? I've verified that this
does resolve the problem on 82544.

[NETDRV] e1000: Do not truncate TSO TCP header with 82544 workaround

The e1000 driver has a workaround for 82544 on PCI-X where if the
terminating byte of a buffer is at addresses 0-3 mod 8, then 4 bytes
are shaved off it and defered to a new segment.  This is due to an
erratum that could otherwise cause TX hangs.

Unfortunately this breaks TSO because it may cause the TCP header to
be split over two segments which itself causes TX hangs.  The solution
is to pull 4 bytes of data up from the next segment rather than pushing
4 bytes off.  This ensures the TCP header remains in one piece and
works around the PCI-X hang.

This patch is based on one from Jesse Brandeburg.

This bug has been trigered by both CONFIG_DEBUG_SLAB as well as Xen.

Note that the only reason we don't see this normally is because the
TCP stack starts writing from the end, i.e., it writes the TCP header
first then slaps on the IP header, etc.  So the end of the TCP header
(skb->tail - 1 here) is always aligned correctly.

Had we made the start of the IP header (e.g., IPv6) 8-byte aligned
instead, this would happen for normal TCP traffic as well.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 73f3a85..2c6ba42 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3168,6 +3168,16 @@ #ifdef NETIF_F_TSO
 		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
 			switch (adapter->hw.mac_type) {
 				unsigned int pull_size;
+			case e1000_82544:
+				/* Make sure we have room to chop off 4 bytes,
+				 * and that the end alignment will work out to
+				 * this hardware's requirements
+				 * NOTE: this is a TSO only workaround
+				 * if end byte alignment not correct move us
+				 * into the next dword */
+				if ((unsigned long)(skb->tail - 1) & 4)
+					break;
+				/* fall through */
 			case e1000_82571:
 			case e1000_82572:
 			case e1000_82573:
