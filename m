From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 14:08:41 -0800
Message-ID: <CAKgT0Udwjgmbwd2StNm-e-02Th4NHetb_FMbrU=KOCHf_90YbA@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129.110634.1678121731419241040.davem@davemloft.net>
	<1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129194434.GC17127@oracle.com>
	<1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
	<1454103195.7627.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38796 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756927AbcA2WIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 17:08:42 -0500
Received: by mail-ig0-f178.google.com with SMTP id mw1so43214626igb.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 14:08:42 -0800 (PST)
In-Reply-To: <1454103195.7627.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 1:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-29 at 13:16 -0800, Alexander Duyck wrote:
>
>> It has to be something recent.  I know back when I wrote the code I
>> tested it on a few different architectures and had to add a few bits
>> in __skb_get_poff so that it would read doff as a u8 instead of
>> bitfield in a u32.
>>
>> Looking at the code it seems like this should be an easy fix.  Just
>> swap the two lines that acquire and test the flow label with the check
>> for dissector_uses_key(... _KEY_FLOW_LABEL).  Then ixgbe will stop
>> trying to grab flow labels.
>
> Note that if we properly align headers, we also align TCP/UDP payload.
>
> Meaning that copying data in recvmsg() is likely faster in some cpus.
> (The ones having NET_IP_ALIGN set to 2 presumably)

It also means DMA becomes dramatically slower as it introduces a
partial write access for the start of every frame.  It is why we had
set NET_IP_ALIGN to 0 on x86 since DMA was becoming more expensive
when unaligned then reading IP unaligned headers.

The gain on recvmsg would probably be minimal.  The only time I have
seen any significant speed-up for copying is if you can get both ends
aligned to something like 16B.

- Alex
