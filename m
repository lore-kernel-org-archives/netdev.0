From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 1/3] net: Split netdev_alloc_frag into
 __alloc_page_frag and add __napi_alloc_frag
Date: Wed, 26 Nov 2014 21:29:17 -0800
Message-ID: <CAMEtUuxChWng-QFF=ziq=PLUkSZu1CD1brHUH9OHBg_4AL3FxQ@mail.gmail.com>
References: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
	<20141127000557.1617.88261.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:51502 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaK0F3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 00:29:18 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so3042025qcq.25
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 21:29:17 -0800 (PST)
In-Reply-To: <20141127000557.1617.88261.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 4:05 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> This patch splits the netdev_alloc_frag function up so that it can be used
> on one of two page frag pools instead of being fixed on the
> netdev_alloc_cache.  By doing this we can add a NAPI specific function
> __napi_alloc_frag that accesses a pool that is only used from softirq
> context.  The advantage to this is that we do not need to call
> local_irq_save/restore which can be a significant savings.
>
> I also took the opportunity to refactor the core bits that were placed in
> __alloc_page_frag.  First I updated the allocation to do either a 32K
> allocation or an order 0 page.  Then I also rewrote the logic to work from
> the end of the page to the start.  By doing this the size value doesn't
> have to be used unless we have run out of space for page fragments.
> Finally I cleaned up the atomic bits so that we just do an
> atomic_sub_return and if that returns 0 then we set the page->_count via an
> atomic_set.  This way we can remove the extra conditional for the
> atomic_read since it would have led to an atomic_inc in the case of success
> anyway.

Nice simplification. Complicated, but looks good to me.
I think only replacement of loop with 32k+page begs
better explanation in the commit log. I'm guessing you're
killing intermediate sizes to simplify the code?

Thank you for doing it. It's a great improvement.
