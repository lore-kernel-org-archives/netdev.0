From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 15:00:28 -0800
Message-ID: <CAKgT0UdLw62nxCdiieLQrZxkyyoJxSpK1AmCP63SQeCPCpNW3g@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129.110634.1678121731419241040.davem@davemloft.net>
	<1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129194434.GC17127@oracle.com>
	<1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
	<1454103195.7627.76.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0Udwjgmbwd2StNm-e-02Th4NHetb_FMbrU=KOCHf_90YbA@mail.gmail.com>
	<1454106518.7627.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34821 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbcA2XA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 18:00:29 -0500
Received: by mail-ig0-f180.google.com with SMTP id t15so47376521igr.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 15:00:29 -0800 (PST)
In-Reply-To: <1454106518.7627.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 2:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-29 at 14:08 -0800, Alexander Duyck wrote:
>
>> It also means DMA becomes dramatically slower as it introduces a
>> partial write access for the start of every frame.  It is why we had
>> set NET_IP_ALIGN to 0 on x86 since DMA was becoming more expensive
>> when unaligned then reading IP unaligned headers.
>
> Well, I guess that if you have an arch where DMA accesses are slow and
> NET_IP_ALIGN = 2, you are out of luck. This is why some platforms are
> better than others.

The other bit you forgot to mention was an IOMMU.  That is another
per-architecture thing that can really slow us down.  Back when I
rewrote the receive path I was dealing with a number of performance
complaints on PowerPC.  The approach I took with the Intel drivers was
supposed to be the best compromise for IOMMU, DMA alignment, and IP
header alignment.

>>
>> The gain on recvmsg would probably be minimal.  The only time I have
>> seen any significant speed-up for copying is if you can get both ends
>> aligned to something like 16B.
>
> On modern intel cpus, this does not matter at all, sure. It took a while
> before "rep movsb" finally did the right thing.
>
> memcpy() and friends implementations are much slower on some older
> arches (when dealing with unaligned src/dst)
>
> arch/mips/lib/memcpy.S is a gem ;)

Yeah.  I can imagine.  The fact is you can't may everybody happy so I
am good with just trying to support the majority architectures as best
as possible if a few have to take a performance hit for an unaligned
memcpy then so be it.

- Alex
