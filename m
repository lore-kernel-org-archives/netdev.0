From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH-next] drivers/net: fix broadcom/bcmsysport.c compile fail
 on SPARC
Date: Fri, 30 May 2014 14:21:23 -0400
Message-ID: <5388CC23.8050608@windriver.com>
References: <1401458527-26513-1-git-send-email-paul.gortmaker@windriver.com> <CAGVrzcbUmaGt4hjKmmME7ssLGR_1bz=ggSePZJu28avc6GZJbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33257 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933014AbaE3SVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 14:21:21 -0400
In-Reply-To: <CAGVrzcbUmaGt4hjKmmME7ssLGR_1bz=ggSePZJu28avc6GZJbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-05-30 01:04 PM, Florian Fainelli wrote:
> Hi Paul,
> 
> 2014-05-30 7:02 GMT-07:00 Paul Gortmaker <paul.gortmaker@windriver.com>:
>> To fix:
>>
>>   CC      drivers/net/ethernet/broadcom/bcmsysport.o
>> In file included from drivers/net/ethernet/broadcom/bcmsysport.c:28:0:
>> drivers/net/ethernet/broadcom/bcmsysport.h:41:8: error: redefinition of 'struct tsb'
>> arch/sparc/include/asm/mmu_64.h:65:8: note: originally defined here
>> make[1]: *** [drivers/net/ethernet/broadcom/bcmsysport.o] Error 1
>>
>> we change struct tsb to struct bcm_tsb in the broadcom driver in
>> order to avoid the namespace collision.
>>
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> For consistency, we might want to rename 'struct tsb' to 'struct
> bcm_tsb', thanks for catching this.

The above is what I did ; I assume however you meant "struct rsb"
to "struct bcm_rsb", which does make sense for consistency.  I'll
send a v2 with that incorporated.

Thanks,
Paul.
--

> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> 
>>
>> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
>> index 4dc8d1e9829b..0d466c134a9e 100644
>> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
>> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
>> @@ -759,7 +759,7 @@ static irqreturn_t bcm_sysport_tx_isr(int irq, void *dev_id)
>>  static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
>>  {
>>         struct sk_buff *nskb;
>> -       struct tsb *tsb;
>> +       struct bcm_tsb *tsb;
>>         u32 csum_info;
>>         u8 ip_proto;
>>         u16 csum_start;
>> @@ -777,7 +777,7 @@ static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
>>                 skb = nskb;
>>         }
>>
>> -       tsb = (struct tsb *)skb_push(skb, sizeof(*tsb));
>> +       tsb = (struct bcm_tsb *)skb_push(skb, sizeof(*tsb));
>>         /* Zero-out TSB by default */
>>         memset(tsb, 0, sizeof(*tsb));
>>
>> @@ -1549,8 +1549,8 @@ static int bcm_sysport_probe(struct platform_device *pdev)
>>                                 NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>>
>>         /* Set the needed headroom once and for all */
>> -       BUILD_BUG_ON(sizeof(struct tsb) != 8);
>> -       dev->needed_headroom += sizeof(struct tsb);
>> +       BUILD_BUG_ON(sizeof(struct bcm_tsb) != 8);
>> +       dev->needed_headroom += sizeof(struct bcm_tsb);
>>
>>         /* We are interfaced to a switch which handles the multicast
>>          * filtering for us, so we do not support programming any
>> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
>> index a0441e7c83cd..72a103c096f2 100644
>> --- a/drivers/net/ethernet/broadcom/bcmsysport.h
>> +++ b/drivers/net/ethernet/broadcom/bcmsysport.h
>> @@ -38,7 +38,7 @@
>>                                  ENET_BRCM_TAG_LEN + ETH_FCS_LEN + ENET_PAD)
>>
>>  /* Transmit status block */
>> -struct tsb {
>> +struct bcm_tsb {
>>         u32 pcp_dei_vid;
>>  #define PCP_DEI_MASK           0xf
>>  #define VID_SHIFT              4
>> --
>> 1.9.3
>>
> 
> 
> 
