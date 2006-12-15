From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 13/22] e1000: disable TSO when debugging slab
Date: Fri, 15 Dec 2006 13:42:14 +1100
Message-ID: <E1Gv31a-0002Vl-00@gondolin.me.apana.org.au>
References: <457D6F69.9090509@pobox.com>
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, auke@foo-projects.org,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4681 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965044AbWLOCmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 21:42:38 -0500
To: jgarzik@pobox.com (Jeff Garzik)
In-Reply-To: <457D6F69.9090509@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>>  
>> +#ifdef CONFIG_DEBUG_SLAB
>> +     /* 82544's work arounds do not play nicely with DEBUG SLAB */
>> +     if (adapter->hw.mac_type == e1000_82544)
>> +             netdev->features &= ~NETIF_F_TSO;
>> +#endif
> 
> ACK, provided that you greatly enhance the comment to explain -why-, not 
> just the desired results.

Actually, CONFIG_DEBUG_SLAB is not the only thing that can break the
82544 work-around, Xen for example will also generate packets that
breaks it.  Jesse has a more recent fix that resolves both problems.

I've updated his patch to make it smaller.

Note that the only reason we don't see this normally is because the
TCP stack starts writing from the end, i.e., it writes the TCP header
first then slaps on the IP header, etc.  So the end of the TCP header
(skb->tail - 1 here) is always aligned correctly.

Had we made the start of the IP header (e.g., IPv6) 8-byte aligned
instead, this would happen for normal TCP traffic as well.

Cheers,
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
