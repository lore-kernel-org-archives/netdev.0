From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one page
 minus eth and vlan hdrs
Date: Mon, 5 Dec 2016 01:31:52 +0200
Message-ID: <CALzJLG_82MNOyuq+y63tR2SDmKo3ZQA5XAgT1_r15B8_V19xKg@mail.gmail.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
 <1480721013-1047541-3-git-send-email-kafai@fb.com> <1480725480.18162.394.camel@edumazet-glaptop3.roam.corp.google.com>
 <58421775.6090905@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34165 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcLDXcO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 18:32:14 -0500
Received: by mail-wm0-f67.google.com with SMTP id g23so12383297wme.1
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 15:32:13 -0800 (PST)
In-Reply-To: <58421775.6090905@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 3, 2016 at 2:53 AM, Alexei Starovoitov <ast@fb.com> wrote:
> On 12/2/16 4:38 PM, Eric Dumazet wrote:
>>
>> On Fri, 2016-12-02 at 15:23 -0800, Martin KaFai Lau wrote:
>>>
>>> When XDP prog is attached, it is currently limiting
>>> MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN) which is 1514
>>> in x86.
>>>
>>> AFAICT, since mlx4 is doing one page per packet for XDP,
>>> we can at least raise the MTU limitation up to
>>> PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this patch is
>>> doing.  It will be useful in the next patch which allows
>>> XDP program to extend the packet by adding new header(s).
>>>
>>> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
>>> ---
>>
>>
>> Have you tested your patch on a host with PAGE_SIZE = 64 KB ?
>>
>> Looks XDP really kills arches with bigger pages :(
>
>
> I'm afraid xdp mlx[45] support was not tested on arches
> with 64k pages at all. Not just this patch.

Yep, in mlx5 page per packet became the default, with or without XDP,
unlike mlx4.
currently we allow 64KB pages per packet! which is wrong and need to be fixed.

I will get to this task soon.

> I think people who care about such archs should test?

We do test mlx5 and mlx4 on PPC arch. other than we require more
memory than we need, we don't see any issues. and we don't test XDP on
those archs.

> Note page per packet is not a hard requirement for all drivers
> and all archs. For mlx[45] it was the easiest and the most
> convenient way to achieve desired performance.
> If there are ways to do the same performance differently,
> I'm all ears :)
>

when bigger pages, i.e  PAGE_SIZE > 8K, my current low hanging fruit
options for mlx5 are
1. start sharing pages for multi packets.
2. Go back to the SKB allocator (allocate ring of SKBs on advance
rather than page per packet/s).

this means that default RX memory scheme will be different than XDP's
on such ARCHs (XDP wil still use page per packet)

Alexei, we should start considering PPC archs for XDP use cases,
demanding page per packet on those archs is a little bit heavy
requirement
