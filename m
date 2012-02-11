From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 02/10] e100: Support RXFCS feature flag.
Date: Fri, 10 Feb 2012 16:17:25 -0800
Message-ID: <4F35B395.3000003@candelatech.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com> <1328730885-10941-3-git-send-email-greearb@candelatech.com> <CAHXqBFJoxkM+U5y5NiepO3BxsjuK=gpYQQTvWXjbRZOnKjCiaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45691 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169Ab2BKAR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 19:17:26 -0500
In-Reply-To: <CAHXqBFJoxkM+U5y5NiepO3BxsjuK=gpYQQTvWXjbRZOnKjCiaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2012 02:56 PM, Micha=C5=82 Miros=C5=82aw wrote:
> 2012/2/8<greearb@candelatech.com>:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows e100 to be configured to append the
>> Ethernet FCS to the skb.
> [...]
>> @@ -1919,6 +1923,7 @@ static int e100_rx_indicate(struct nic *nic, s=
truct rx *rx,
>>         struct sk_buff *skb =3D rx->skb;
>>         struct rfd *rfd =3D (struct rfd *)skb->data;
>>         u16 rfd_status, actual_size;
>> +       u16 fcs_pad =3D 0;
>>
>>         if (unlikely(work_done&&  *work_done>=3D work_to_do))
>>                 return -EAGAIN;
>
> Remove this part.
>
>> @@ -1951,9 +1956,11 @@ static int e100_rx_indicate(struct nic *nic, =
struct rx *rx,
>>         }
>>
>>         /* Get actual data size */
>> +       if (unlikely(dev->features&  NETIF_F_RXFCS))
>> +               fcs_pad =3D 4;
>
> Remove part above.
>
>>         actual_size =3D le16_to_cpu(rfd->actual_size)&  0x3FFF;
>
> u16 data_size =3D actual_size;
> if (unlikely(dev->features&  NETIF_F_RXFCS))
>      actual_size -=3D 4;
>
>> -       if (unlikely(actual_size>  RFD_BUF_LEN - sizeof(struct rfd))=
)
>> -               actual_size =3D RFD_BUF_LEN - sizeof(struct rfd);
>> +       if (unlikely(actual_size>  RFD_BUF_LEN + fcs_pad - sizeof(st=
ruct rfd)))
>> +               actual_size =3D RFD_BUF_LEN + fcs_pad - sizeof(struc=
t rfd);
>>
>>         /* Get data */
>>         pci_unmap_single(nic->pdev, rx->dma_addr,
>
> Remove this part.
>
> ...
> skb_put(skb, data_size);
> ...

Well, that breaks if the unlikely() branch hits above..now 'data_size' =
will
be larger than it should be.  I can add more logic to fix that up, but
then code size is going to be larger again, and we also have the
potential confusion between what data-size and actual-size variables
mean.

I will double-check that the counter works properly, but I think I'll
leave the rest as it is, at least for now.

Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
