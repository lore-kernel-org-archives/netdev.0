From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH,RFC] skb->network_header and __vlan_put_tag()
Date: Sat, 05 Jul 2008 20:33:01 +0200
Message-ID: <486FBE5D.1020807@trash.net>
References: <20080616221525.GG27971@xi.wantstofly.org> <4857AB84.2090409@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050005050301060206020509"
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40474 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbYGESdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 14:33:05 -0400
In-Reply-To: <4857AB84.2090409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050005050301060206020509
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Lennert Buytenhek wrote:
>> __vlan_put_tag() is not only substracting 4 from the skb's
>> ->mac_header pointer (which kind of makes sense[*]), but it is
>> substracting 4 from the ->network_header pointer as well.
>>
>> Conceptually, sure, VLAN is another layer of encapsulation between
>> ethernet and IP, but doesn't it make more sense to just consider the
>> VLAN tag part of the MAC header?  What good does it do to point
>> ->network_header to the _middle_ of the VLAN tag when a VLAN tag is
>> inserted?
>>
>> I'm adding VLAN support to mv643xx_eth (which does not support HW
>> insertion of a VLAN tag, but it does support HW checksumming when
>> a VLAN tag is present, you just have to tell the HW how many bytes
>> there are between the start of the packet and the IP header), and
>> I'm ending up with code like this:
>>
>>     if (skb->protocol == htons(ETH_P_8021Q))
>>         ip_header = ip_hdr(skb) + 4;
>>     else
>>         ip_header = ip_hdr(skb);
>>
>> whereas it'd be nicer if you could just have the same code for the
>> VLAN and non-VLAN case:
>>
>>     ip_header = ip_hdr(skb);
>>
>>
>> [*] But skb->mac_header seems to be mostly NULL when this function
>>     is called, causing it to end up being 0xfffffffc by the time the
>>     packet is given to the device's ->hard_start_xmit().
> 
> I agree that your patch makes sense, it seems some drivers
> (niu, gianfar) even assume this. Regarding the invalid
> mac_header pointer, that looks like a bug and it should
> probably call skb_reset_mac_header() instead of manually
> changing the potentially invalid ->mac_header.
> 
>> Index: linux-2.6.26-rc5/include/linux/if_vlan.h
>> ===================================================================
>> --- linux-2.6.26-rc5.orig/include/linux/if_vlan.h
>> +++ linux-2.6.26-rc5/include/linux/if_vlan.h
>> @@ -280,7 +280,6 @@ static inline struct sk_buff *__vlan_put
>>  
>>      skb->protocol = htons(ETH_P_8021Q);
>>      skb->mac_header -= VLAN_HLEN;
>> -    skb->network_header -= VLAN_HLEN;
>>  
>>      return skb;
>>  }
> 
> There is another spot where VLAN headers are built with an also
> incorrect looking network_header adjustment in vlan_dev_hard_header()
> that should also be changed for consisteny.
> 
> Could you try if changing both these spots and adding the
> skb_reset_mac_header() works for you and still displays
> the packets properly in tcpdump?

I've queued this patch for testing. I'll send it upstream with
my next VLAN update if everything works properly.

--------------050005050301060206020509
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 2381526d1d9ed17c60bd0cf875f23ca079909753
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Jul 5 20:32:11 2008 +0200

    vlan: fix network_header/mac_header adjustments
    
    Lennert Buytenhek points out that the VLAN code incorrectly adjusts
    skb->network_header to point in the middle of the VLAN header and
    additionally tries to adjust the mac_header without checking for
    validty.
    
    The network_header should not be touched at all, the mac_header
    should simply be set to the beginning of the VLAN header.
    
    Based on patch by Lennert Buytenhek <buytenh@wantstofly.org>.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 037929f..d0157d4 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -188,8 +188,7 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short
 	veth->h_vlan_TCI = htons(tag);
 
 	skb->protocol = htons(ETH_P_8021Q);
-	skb->mac_header -= VLAN_HLEN;
-	skb->network_header -= VLAN_HLEN;
+	skb_reset_mac_header(skb);
 
 	return skb;
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5dc0fe6..147ba25 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -308,7 +308,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 			vhdr->h_vlan_encapsulated_proto = htons(len);
 
 		skb->protocol = htons(ETH_P_8021Q);
-		skb_reset_network_header(skb);
+		skb_reset_mac_header(skb);
 	}
 
 	/* Before delegating work to the lower layer, enter our MAC-address */

--------------050005050301060206020509--
