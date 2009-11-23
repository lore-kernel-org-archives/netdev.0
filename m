From: Patrick McHardy <kaber@trash.net>
Subject: Re: macvlan: fix gso_max_size setting
Date: Mon, 23 Nov 2009 23:33:05 +0100
Message-ID: <4B0B0DA1.7010403@trash.net>
References: <4B0A64E2.8090203@trash.net>	<20091123.101013.40629093.davem@davemloft.net>	<4B0B087B.3020000@trash.net> <20091123.142207.14190542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030602040803050207040902"
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52855 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbZKWWdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:33:02 -0500
In-Reply-To: <20091123.142207.14190542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030602040803050207040902
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 23 Nov 2009 23:11:07 +0100
>
>   
>> David Miller wrote:
>>     
>>> From: Patrick McHardy <kaber@trash.net>
>>> Date: Mon, 23 Nov 2009 11:33:06 +0100
>>>
>>>   
>>>       
>>>> Fix macvlan gso_max_size setting. Based on net-next-2.6.git.
>>>>         
>>> Pretty serious defect, maybe net-2.6 material?
>>>       
>> Sure, please take it in net-2.6.
>>     
>
> Done, thanks.
>
>   
>>> If someone hits this, it's going to trigger something awful.
>>>       
>> Don't drivers simply drop the packet? Otherwise I think you
>> should be able to trigger the same problem using the TC mirred
>> action.
>>     
>
> I see nothing in the IXGBE driver's transmit code paths which guard
> against this.
>   


Perhaps we should simply fall back to software in that case.
Compile tested only.



--------------030602040803050207040902
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

net: fall back to software segmentation if skb length exceeds dev->gso_max_size

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ffc3106..edd1e2b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1943,7 +1943,8 @@ static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
 	return skb_is_gso(skb) &&
 	       (!skb_gso_ok(skb, dev->features) ||
-		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
+		unlikely(skb->ip_summed != CHECKSUM_PARTIAL) ||
+		unlikely(skb->len > dev->gso_max_size));
 }
 
 static inline void netif_set_gso_max_size(struct net_device *dev,

--------------030602040803050207040902--
