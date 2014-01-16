From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH net-next 2/2] r6040: use ETH_ZLEN instead of MISR for SKB
 length checking
Date: Thu, 16 Jan 2014 11:30:01 -0800
Message-ID: <CAGVrzcbNVWqK1a766iSQfaGwSfH10a0ftdDZwDGogE17M2N++w@mail.gmail.com>
References: <1389819866-32142-1-git-send-email-florian@openwrt.org>
 <1389819866-32142-3-git-send-email-florian@openwrt.org> <1389857001.19462.33.camel@deadeye.wl.decadent.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D45D812@AcuExch.aculab.com> <1389893604.11912.47.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:47118 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbaAPTan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:30:43 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so3072076pab.23
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 11:30:41 -0800 (PST)
In-Reply-To: <1389893604.11912.47.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/16 Ben Hutchings <bhutchings@solarflare.com>:
> On Thu, 2014-01-16 at 09:10 +0000, David Laight wrote:
>> From: Ben Hutchings
>> > On Wed, 2014-01-15 at 13:04 -0800, Florian Fainelli wrote:
>> > > Ever since this driver was merged the following code was included:
>> ...
>> > > - if (skb->len < MISR)
>> > > -         descptr->len = MISR;
>> > > + if (skb->len < ETH_ZLEN)
>> > > +         descptr->len = ETH_ZLEN;
>> >
>> > It looks like this is just increasing the TX descriptor length so the
>> > packet is tail-padded with whatever happens to come next in the skb.
>> > This is absolutely incorrect behaviour and may leak sensitive
>> > information.
>>
>> And possibly page fault if the data is right at the end of a page.
>
> If the CPU was accessing it, it would be fine as the skb linear area
> ends with struct skb_shared_info.  (sfc actually takes advantage of that
> in efx_enqueue_skb_pio() which can add padding (*not* transmitted) to
> ensure that the CPU does write-combining.)
>
> But the NIC, if it's connected through an IOMMU, might get a page fault
> due to the incorrect length of the DMA mapping.
>
>> > Presumably it is necessary to pad the frame because the MAC is too lame
>> > to do it, and the correct way to do that is using skb_padto(skb,
>> > ETH_ZLEN).  But this may fail as it might have to allocate memory
>>
>> Alternatively use two ring entries with the 'more' bit set on
>> the first one and transmit the padding from a permanently allocated
>> and dma-mapped block of zeros.
>> Assuming the hardware support SG transmit and doesn't have a
>> constraint on the length of the first fragment.
>
> Do you see NETIF_F_SG in this driver?

No this driver does not it, your fix padding the SKB to max(skb->len,
ETH_ZLEN) looks good to me. Could you submit these as two separate
patches?

Thanks!
-- 
Florian
