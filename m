From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 01/14] qed: Add CONFIG_QED_SRIOV
Date: Tue, 10 May 2016 11:02:09 -0700
Message-ID: <CAKgT0UdvLpAxcCuNHZy6BJQyDiDOkpoJprjBXLM-43N5pGXOOg@mail.gmail.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1462799963-23547-2-git-send-email-Yuval.Mintz@qlogic.com>
	<20160509.151429.403288621356878412.davem@davemloft.net>
	<CO2PR11MB00887DD775313A8DC3F39FA597710@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:32856 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbcEJSCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:02:10 -0400
Received: by mail-io0-f174.google.com with SMTP id f89so25672946ioi.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 11:02:09 -0700 (PDT)
In-Reply-To: <CO2PR11MB00887DD775313A8DC3F39FA597710@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 10:16 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>  > From: Yuval Mintz <Yuval.Mintz@qlogic.com>
>> Date: Mon, 9 May 2016 16:19:10 +0300
>>
>> > +   /* bitmap indicating which fields hold valid values */
>> > +   aligned_u64 valid_bitmap;
>>
>> There is absolutely no reason to use aligned_u64 here.  That type is for handling
>> a specific issue in user facing APIs, which this is not.
>
> I'm not entirely convinced this is true; If we'll not enforce the alignment
> of this 64-bit field, it's possible there will be differences between 32-bit
> and 64-bit machines versions of this struct.
> You have to recall that this is going to be copied via DMA between PF and VF,
> so they must have the exact same representation of the structure.
>
> [If I'm wrong on the technical part here, please correct me; I vaguely
> seem to recall that this was already discussed on bnx2x's implementation
> of the hw-channel which also uses aligned u64 fields]

I think your change does have an impact, I just don't know if you
really realize what it will get you.  Specifically what using the
aligned_u64 is doing is forcing qed_bulletin_content to be u64 aligned
and introducing two holes in qed_bulletin on 32 bit platforms where
dma_addr_t might be 32 bit, and adding a 4 bytes of padding after
size.

My advice would be to update phys to be a u64 instead of a dma_addr_t.
That way it won't change size depending on 32 or 64 bit architecture.
Then you could align qed_bulletin to 8 bytes so that the size of the
structure remains constant on both 32 and 64 bit systems.

- Alex
