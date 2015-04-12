From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v2 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 22:29:46 +0200
Message-ID: <CACna6rzJ0dDhbF_-=Jwkni=0d+PzrMBpfJQfkKAPkWX7Eg7eFA@mail.gmail.com>
References: <1428848565-94187-1-git-send-email-nbd@openwrt.org>
	<1428848565-94187-4-git-send-email-nbd@openwrt.org>
	<1428862182.25985.354.camel@edumazet-glaptop2.roam.corp.google.com>
	<552ABD6E.10000@openwrt.org>
	<1428865466.25985.366.camel@edumazet-glaptop2.roam.corp.google.com>
	<552AC6B3.9010203@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38046 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbbDLU3r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 16:29:47 -0400
Received: by igbqf9 with SMTP id qf9so30724462igb.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 13:29:46 -0700 (PDT)
In-Reply-To: <552AC6B3.9010203@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 April 2015 at 21:25, Felix Fietkau <nbd@openwrt.org> wrote:
> On 2015-04-12 21:04, Eric Dumazet wrote:
>> On Sun, 2015-04-12 at 20:46 +0200, Felix Fietkau wrote:
>>> On 2015-04-12 20:09, Eric Dumazet wrote:
>>
>>> >
>>> > Given the fact that previous driver kind of worked, have you trie=
d not
>>> > doing the modulo at all here ?
>>> The previous driver was causing reproducible DMA corruption issues =
under
>>> load. My patch fixes this, and I've verified this with hours of str=
ess
>>> testing (previously I could reproduce the issue in minutes).
>>>
>>> > ring->end =3D desc_idx + 1;
>>> >
>>> > It looks like the hardware accepted setting BGMAC_DMA_RX_INDEX to
>>> > ring->index_base + ring->num_slots * sizeof(struct bgmac_dma_desc=
)
>>> The hardware accepts it, but with that value, it considers all rx s=
lot
>>> entries filled, there's no CPU ownership bit in the descriptor.
>>> According to documentation, that register indicates the first *inva=
lid*
>>> rx descriptor (i.e. one where the CPU hasn't posted a valid buffer =
yet).
>>>
>>> > So apparently the presence of BGMAC_DESC_CTL0_EOT in last rx desc=
 was
>>> > enough to avoid any problem with this.
>>> EOT serves a completely different purpose. It simply indicates the =
end
>>> of the ring, telling the hardware to go back to the beginning for t=
he
>>> next descriptor.
>>
>> Right, but after your patch, we program the hardware with end =3D=3D=
 start
>> =3D=3D 0
>>
>> So I do not really understand how the hardware can still deliver fir=
st
>> frame.
>>
>> If it was really taking care of 'end' value, then it should not even
>> deliver one frame.
> Good point.
>
>> The dma corruption happened because hardware was simply reusing fram=
es,
>> that driver already took to upper stack, since as you said, there is=
 no
>> ownership bit.
>>
>> You might try your patch with BGMAC_RX_RING_SLOTS =3D 3 and check if=
 it is
>> still working properly.
>>
>> I find BGMAC_RX_RING_SLOTS=3D=3D511 very suspect, and a comment of w=
hy this
>> magic value is not 512 would be nice.
> I think it's probably a valid idea that was implemented in the wrong
> way. I'm pretty sure the idea was to only fill 511 descriptors in a r=
ing
> with a size of 512. That would eliminate the issue you mentioned abov=
e.
> I'll send v3 with an extra patch to take care of this.

I don't recall differences between Broadcom's code and bgmac now.
However it could be that Broadcom used BGMAC_RX_RING_SLOTS=3D=3D511 for
the same/similar purpose I did following:
/* Always keep one slot free to allow detecting bugged calls. */
if (--free_slots =3D=3D 1)
        netif_stop_queue(net_dev);

--=20
Rafa=C5=82
