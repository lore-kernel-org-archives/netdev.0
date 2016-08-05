From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Date: Fri, 5 Aug 2016 09:00:25 -0700
Message-ID: <CAKgT0Ue2vikpFwqTyAEgYsH0iKgOajXvp_F-CMuZfz-cLggrrg@mail.gmail.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com> <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160803174107.GA38399@ast-mbp.thefacebook.com> <20160804181913.26ee17b9@redhat.com>
 <CAKgT0UdbVK6Ti9drCQFfa0MyU40Kh=Hu=BtDTRCqqsSiBvJ7rg@mail.gmail.com>
 <20160805035534.GA56390@ast-mbp.thefacebook.com> <CAKgT0Uc0=10xhcJJ+55rBv=YNPgPLmHb8x82CKbj+N895JQY5Q@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D5F50B52E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-mm <linux-mm@kvack.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35741 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422681AbcHEQA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 12:00:26 -0400
Received: by mail-io0-f194.google.com with SMTP id q83so24555116iod.2
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2016 09:00:26 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F50B52E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 5, 2016 at 8:33 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexander Duyck
>> Sent: 05 August 2016 16:15
> ...
>> >
>> > interesting idea. Like dma_map 1GB region and then allocate
>> > pages from it only? but the rest of the kernel won't be able
>> > to use them? so only some smaller region then? or it will be
>> > a boot time flag to reserve this pseudo-huge page?
>>
>> Yeah, something like that.  If we were already talking about
>> allocating a pool of pages it might make sense to just setup something
>> like this where you could reserve a 1GB region for a single 10G device
>> for instance.  Then it would make the whole thing much easier to deal
>> with since you would have a block of memory that should perform very
>> well in terms of DMA accesses.
>
> ISTM that the main kernel allocator ought to be keeping a cache
> of pages that are mapped into the various IOMMU.
> This might be a per-driver cache, but could be much wider.
>
> Then if some code wants such a page it can be allocated one that is
> already mapped.
> Under memory pressure the pages could then be reused for other purposes.
>
> ...
>> In the Intel drivers for instance if the frame
>> size is less than 256 bytes we just copy the whole thing out since it
>> is cheaper to just extend the header copy rather than taking the extra
>> hit for get_page/put_page.
>
> How fast is 'rep movsb' (on cached addresses) on recent x86 cpu?
> It might actually be worth unconditionally copying the entire frame
> on those cpus.

The cost for rep movsb on modern x86 is about 1 cycle for every 16
bytes plus some fixed amount of setup time.  The time it usually takes
for something like an atomic operation can vary but it is usually in
the 10s of cycles when you factor in a get_page/put_page which is why
I ended up going with 256 being the upper limit as I recall since that
allowed for the best performance without starting to incur any
penalty.

> A long time ago we found the breakeven point for the copy to be about
> 1kb on sparc mbus/sbus systems - and that might not have been aligning
> the copy.

I wouldn't know about other architectures.

- Alex
