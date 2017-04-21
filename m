From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 1/5] nfp: make use of the DMA_ATTR_SKIP_CPU_SYNC attr
Date: Fri, 21 Apr 2017 10:10:59 -0700
Message-ID: <CAJpBn1zyDv_U-hXD2cmoUCH5+_L8ibo1s2-eXV08VEmBcsfifg@mail.gmail.com>
References: <20170421142052.107388-1-jakub.kicinski@netronome.com>
 <20170421142052.107388-2-jakub.kicinski@netronome.com> <CAKgT0UfdbLV9tdYZXVQK6U2cF1Ljzc27uuVoNaZF-rHcmLUnPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, oss-drivers@netronome.com,
        Jakub Kicinski <kubakici@wp.pl>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:36133 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423890AbdDUSxE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:53:04 -0400
Received: by mail-qt0-f173.google.com with SMTP id g60so76670476qtd.3
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:53:04 -0700 (PDT)
In-Reply-To: <CAKgT0UfdbLV9tdYZXVQK6U2cF1Ljzc27uuVoNaZF-rHcmLUnPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 8:07 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Fri, Apr 21, 2017 at 7:20 AM, Jakub Kicinski
> <jakub.kicinski@netronome.com> wrote:
>> DMA unmap may destroy changes CPU made to the buffer.  To make XDP
>> run correctly on non-x86 platforms we should use the
>> DMA_ATTR_SKIP_CPU_SYNC attribute.
>>
>> Thanks to using the attribute we can now push the sync operation to
>> the common code path from XDP handler.
>>
>> A little bit of variable name reshuffling is required to bring the
>> code back to readable state.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>
> So I see where you added the sync_single_for_cpu, but what about the
> sync_single_for_device? It needs to be called for the buffer before
> you assign it for Rx. On x86 it won't really matter but for proper
> utilization of the DMA API you need to sync the buffer even for Rx
> just to make certain that the cache lines are evicted prior to the
> device attempting to write to the buffer.

Ah, indeed, thanks for catching this.  We need to invalidate the
caches in case they are dirty and could get written back between the
device DMA and sync_for_cpu, correct?
