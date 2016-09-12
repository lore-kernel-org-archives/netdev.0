From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next] xen-netfront: avoid packet loss when ethernet header crosses page boundary
Date: Mon, 12 Sep 2016 13:52:17 +0200
Message-ID: <87sht59vym.fsf@vitty.brq.redhat.com>
References: <1471880577-21380-1-git-send-email-vkuznets@redhat.com>
        <57D2BC13.8050903@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
        <linux-kernel@vger.kernel.org>,
        "Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>,
        Patrick Talbert <ptalbert@redhat.com>,
        David Vrabel <david.vrabel@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57D2BC13.8050903@citrix.com> (David Vrabel's message of "Fri, 9
        Sep 2016 14:41:39 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Vrabel <david.vrabel@citrix.com> writes:

> On 22/08/16 16:42, Vitaly Kuznetsov wrote:
>> Small packet loss is reported on complex multi host network configurations
>> including tunnels, NAT, ... My investigation led me to the following check
>> in netback which drops packets:
>> 
>>         if (unlikely(txreq.size < ETH_HLEN)) {
>>                 netdev_err(queue->vif->dev,
>>                            "Bad packet size: %d\n", txreq.size);
>>                 xenvif_tx_err(queue, &txreq, extra_count, idx);
>>                 break;
>>         }
>> 
>> But this check itself is legitimate. SKBs consist of a linear part (which
>> has to have the ethernet header) and (optionally) a number of frags.
>> Netfront transmits the head of the linear part up to the page boundary
>> as the first request and all the rest becomes frags so when we're
>> reconstructing the SKB in netback we can't distinguish between original
>> frags and the 'tail' of the linear part. The first SKB needs to be at
>> least ETH_HLEN size. So in case we have an SKB with its linear part
>> starting too close to the page boundary the packet is lost.
>> 
>> I see two ways to fix the issue:
>> - Change the 'wire' protocol between netfront and netback to start keeping
>>   the original SKB structure. We'll have to add a flag indicating the fact
>>   that the particular request is a part of the original linear part and not
>>   a frag. We'll need to know the length of the linear part to pre-allocate
>>   memory.
>> - Avoid transmitting SKBs with linear parts starting too close to the page
>>   boundary. That seems preferable short-term and shouldn't bring
>>   significant performance degradation as such packets are rare. That's what
>>   this patch is trying to achieve with skb_copy().
>> 
>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>
> We should probably fix the backend to handle this (by grant copying a
> minimum amount in the linear area, but since netfront needs to work with
> older netback.
>
> Acked-by: David Vrabel <david.vrabel@citrix.com>

David,

could you please pick this up for net-next or are there any concerns
remaining?

Thanks,

-- 
  Vitaly
