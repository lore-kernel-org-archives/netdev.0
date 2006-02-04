From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] sky2 broken for Yukon PCI-E Gigabit Ethernet Controller
 11ab:4362 (rev 19)
Date: Sat, 04 Feb 2006 11:32:05 +0100
Message-ID: <43E482A5.8020306@t-online.de>
References: <E1F1UqC-0002XE-00@gondolin.me.apana.org.au> <43D9B8A6.5020200@t-online.de> <20060127122242.GA32128@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751231AbWBDKdy@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060127122242.GA32128@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.16-rc2 still misses your patch. Was there a special reason not to 
send it
to Linus?

cu,
 Knut

>On Fri, Jan 27, 2006 at 07:07:34AM +0100, Knut Petersen wrote:
>  
>
>>Well, there are no problems if SuSEfirewall2 is disabled. But have a look
>>at the loaded modules:
>>
>>ipt_MASQUERADE          3968  1
>>pppoe                  15360  2
>>pppox                   4616  1 pppoe
>>    
>>
>
>OK, although we can't rule out sky2/netfilter from the enquiry, I've
>identified two bugs in ppp/pppoe that may be responsible for what you
>are seeing.  So please try the following patch and let us know if the
>problem still exists (or deteriorates/improves).
>
>[PPP]: Fixed hardware RX checksum handling
>
>When we pull the PPP protocol off the skb, we forgot to update the
>hardware RX checksum.  This may lead to messages such as
>
>	dsl0: hw csum failure.
>
>Similarly, we need to clear the hardware checksum flag when we use
>the existing packet to store the decompressed result.
>
>Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
>Cheers,
>  
>
>------------------------------------------------------------------------
>
>diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
>--- a/drivers/net/ppp_generic.c
>+++ b/drivers/net/ppp_generic.c
>@@ -1610,6 +1610,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp,
> 		}
> 		else if (!pskb_may_pull(skb, skb->len))
> 			goto err;
>+		else
>+			skb->ip_summed = CHECKSUM_NONE;
> 
> 		len = slhc_uncompress(ppp->vj, skb->data + 2, skb->len - 2);
> 		if (len <= 0) {
>@@ -1690,6 +1692,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp,
> 			kfree_skb(skb);
> 		} else {
> 			skb_pull(skb, 2);	/* chop off protocol */
>+			skb_postpull_rcsum(skb, skb->data - 2, 2);
> 			skb->dev = ppp->dev;
> 			skb->protocol = htons(npindex_to_ethertype[npi]);
> 			skb->mac.raw = skb->data;
>  
>
