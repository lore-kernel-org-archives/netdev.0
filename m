From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports sg dma
Date: Thu, 1 Aug 2013 12:41:08 +0800
Message-ID: <CACVXFVNSZJ+ojjBCwYDKsWWvs03aL8BugcX7u483MvBCQCH1sg@mail.gmail.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	<1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	<1375329066.10515.125.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Freddy Xin <freddy@asix.com.tw>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38086 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab3HAElL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 00:41:11 -0400
In-Reply-To: <1375329066.10515.125.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for your review.

On Thu, Aug 1, 2013 at 11:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-07-31 at 18:51 +0800, Ming Lei wrote:
>> This patch enables 'can_dma_sg' flag for ax88179_178a device
>> if the attached host controller supports building packet from
>> discontinuous buffers(DMA SG is possible), so both frame header
>> and skb data buffers can be passed to usb stack via urb->sg,
>> then skb data copy can be saved.
>>
>> With the patch, CPU utilization decreased much in iperf test at
>> client mode.
>>
>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>> ---
>>  drivers/net/usb/ax88179_178a.c |   30 ++++++++++++++++++++++++++++++
>>  1 file changed, 30 insertions(+)
>>
>> diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
>> index 5a468f3..c75bded 100644
>> --- a/drivers/net/usb/ax88179_178a.c
>> +++ b/drivers/net/usb/ax88179_178a.c
>> @@ -1031,12 +1031,20 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
>>       dev->mii.phy_id = 0x03;
>>       dev->mii.supports_gmii = 1;
>>
>> +     if (dev->udev->bus->no_sg_limit)
>> +             dev->can_dma_sg = 1;
>> +
>>       dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>>                             NETIF_F_RXCSUM;
>>
>>       dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>>                                NETIF_F_RXCSUM;
>>
>> +     if (dev->can_dma_sg) {
>> +             dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
>> +             dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
>> +     }
>> +
>>       /* Enable checksum offload */
>>       *tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
>>              AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
>> @@ -1170,12 +1178,30 @@ ax88179_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
>>       int mss = skb_shinfo(skb)->gso_size;
>>       int headroom;
>>       int tailroom;
>> +     struct skb_data *entry = (struct skb_data *)skb->cb;
>>
>>       tx_hdr1 = skb->len;
>>       tx_hdr2 = mss;
>>       if (((skb->len + 8) % frame_size) == 0)
>>               tx_hdr2 |= 0x80008000;  /* Enable padding */
>>
>> +     if (dev->can_dma_sg) {
>
>
>
>> +             if (!(entry->header = kmalloc(8, GFP_ATOMIC)))
>> +                     goto no_sg;
>> +
>> +             entry->length = 8;
>> +             cpu_to_le32s(&tx_hdr1);
>> +             cpu_to_le32s(&tx_hdr2);
>
> You could do these cpu_to_le32s() calls before the if (dev->can_dma_sg)
> and remove them before the skb_copy_to_linear_data() calls.

OK.

>
>> +             memcpy(entry->header, &tx_hdr1, 4);
>> +             memcpy(entry->header + 4, &tx_hdr2, 4);
>> +
>> +             return skb;
>> +     } else {
>> +no_sg:
>> +             entry->header = NULL;
>> +             entry->length = 0;
>> +     }
>> +
>>       headroom = skb_headroom(skb);
>>       tailroom = skb_tailroom(skb);
>>
>> @@ -1323,6 +1349,10 @@ static int ax88179_reset(struct usbnet *dev)
>>
>>       dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>>                                NETIF_F_RXCSUM;
>> +     if (dev->can_dma_sg) {
>> +             dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
>> +             dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
>> +     }
>
> Are you sure this part is needed ?

I add flags here because the part existed previously, and if you are sure
it isn't needed anymore, I can remove this part.

>
> Also it looks like that you are going through this sg allocation/setup
> even for linear skb ?
>
> For linear skb, with 8+ bytes of headroom, I guess this adds significant
> overhead (2 kmalloc() + sg setup)

>From my trace result, lots of linear SKBs are cloned or header-cloned, so
it needs skb copy too.

Is it normal in xmit path to see cloned SKBs for driver? If not, I can add check
to avoid allocation of 8 bytes header for non-cloned skb.

But for the kmalloc of urb->sg, I don't think there is one way to save that.

Thanks,
--
Ming Lei
