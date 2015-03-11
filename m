From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] enic: use netdev_dma_alloc
Date: Wed, 11 Mar 2015 10:51:33 -0700
Message-ID: <550080A5.3070401@gmail.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com> <1426009384-11544-3-git-send-email-_govind@gmx.com> <54FF50B0.3080900@redhat.com> <alpine.LNX.2.03.1503111428210.3394@ws.cisco> <55004A73.3040904@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1CAFB899@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:46341 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbCKRvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:51:36 -0400
Received: by pabli10 with SMTP id li10so13092208pab.13
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:51:36 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAFB899@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 10:34 AM, David Laight wrote:
> From: Alexander Duyck
> ...
>>> Is this behaviour platform dependent? I tested this patch for more
>>> than a month
>>> and I did not face any issue. I ran normal traffic like ssh, nfs and
>>> iperf/netperf.
>>> Is there a special scenario when this could occur?
>> Yes it depends on the platform and IOMMU used.  For an example take a
>> loot at the SWIOTLB implementation.  I always assumed if I can work with
>> that when it is doing bounce buffers I can work with any IOMMU or platform.
>>
>>> Will using DMA_BIDIRECTIONAL and sync_to_cpu & sync_to_device solve this?
>>> Each desc should have different dma address to write to. Can you
>>> explain me how
>>> this can happen?
>> No that won't help.  The issue is that when the page is mapped you
>> should not be updating any fields in the page until it is unmapped.
>> Since you have multiple buffers mapped to a single page you should be
>> waiting until the entire page is unmapped.
> Isn't the 'unit of memory for dma sync' a cache line, not a page?

Yes, but the problem is the entire page is mapped, and unmapped and that
triggers a syncronization over the entire page, not just the most recent
buffer within the page that was used.

The problem is the API maps an order 3 page and then is using chunks of
it for receive buffers, but then the last buffer unmaps the entire page
which could invalidate any CPU side accesses to the page while it was
still mapped.

In order to make it workable it would have to be mapped bidirectional
and on the last unmap everything that isn't the last buffer would have
to be synced for device before the page is unmapped which would likely
be more expensive than just avoiding all of this by identifying the page
as being shared and cloning the header out of the page frag.

> You certainly need to test on systems without cache coherent io.
>
> 	David

I agree.

- Alex
