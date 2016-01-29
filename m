From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 13:16:02 -0800
Message-ID: <CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129.110634.1678121731419241040.davem@davemloft.net>
	<1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129194434.GC17127@oracle.com>
	<1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35310 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbcA2VQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:16:04 -0500
Received: by mail-io0-f180.google.com with SMTP id d63so85285162ioj.2
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 13:16:03 -0800 (PST)
In-Reply-To: <1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 12:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-29 at 14:44 -0500, Sowmini Varadhan wrote:
>> On (01/29/16 11:37), Eric Dumazet wrote:
>> >
>> > I have no idea why reading iph->saddr or iph->daddr would not hit the
>> > problem, but accessing the 32bit ipv6 flow label would be an issue.
>> >
>> > Something is fishy.
>>
>> I was wondering about this myself. Even on sparc, I only first
>> ran into the errors for ipv6. I dont know if the fact that the
>> saddr is memcpy'ed masks the error (even though the problem
>> is still there).
>
> Oh right, recent work in flow dissector added all these memcpy()
>
> I was still looking at linux-4.3 ;)

It has to be something recent.  I know back when I wrote the code I
tested it on a few different architectures and had to add a few bits
in __skb_get_poff so that it would read doff as a u8 instead of
bitfield in a u32.

Looking at the code it seems like this should be an easy fix.  Just
swap the two lines that acquire and test the flow label with the check
for dissector_uses_key(... _KEY_FLOW_LABEL).  Then ixgbe will stop
trying to grab flow labels.

- Alex
