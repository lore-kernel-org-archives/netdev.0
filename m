From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 6 Jun 2012 18:59:19 +0000 (UTC)
Message-ID: <jqo9a6$ah6$1@dough.gmane.org>
References: <jqo7op$t6f$1@dough.gmane.org>
 <1339008142.26966.40.camel@edumazet-glaptop>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37726 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756557Ab2FFS7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 14:59:37 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ScLSA-0004hk-82
	for netdev@vger.kernel.org; Wed, 06 Jun 2012 20:59:34 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 20:59:34 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 20:59:34 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-06-06, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2012-06-06 at 18:32 +0000, Grant Edwards wrote:
>
>> I'm tracking down a problem that appears to be caused by a change in
>> the behavior of alloc_skb() introduced in kernel version 3.2.  In
>> kernel versions prior to 3.2, calling alloc_skb(1350), returned an
>> sk_buff with a tailroom of around 1400 bytes (safely below the
>> default Ethernet frame size limit of 1500).
>> 
>> In 3.2 and later, calling alloc_skb(1350) returns an sk_buff with a
>> tailroom of about 1850.
>> 
>> Why has the "extra" space increased from 60 bytes to 500 bytes?
>
> Because of kmalloc-2048 being used. Previous kernels were losing this
> space. We are now able to expand some packets without extra
> re-allocation/copy.
>
>> [It's always possible that I've unintentionally changed something in
>> the kernel configs that causes this, but I've tried to build the
>> kernels as identically as possible.]
>> 
>> The kernel module that's started failing fills the allocated sk_buff
>> until tailroom() indicates it is full and then sends it.  The problem
>> is that sending a packet with a length of 1850 won't work (it's a
>> MAC-layer Ethernet packet).
>
> This code seems buggy.

It is with today's alloc_skb().

At the time it was written (probably 10+ years ago) it was relying on
the documented API for alloc_skb() that stated alloc_skb() either
returned an sk_buff of the requested size or it failed.

>> I've found man pages for alloc_skb() from a few years ago that state
>> explicitly that alloc_skb(_size_) will allocate a new sk_buff with no
>> headroom and a tail room of _size_ bytes.  This doesn't seem to be the
>> case for recent kernels.  Is there any documentation stating what the
>> current behavior is supposed to be?
>> 
>> Are callers to alloc_skb() supposed to check the tailroom and
>> reserve() an appropriate number of bytes such that the tailroom is
>> correct?
>
> If you allocate skbs with 1500 bytes, you probably should check skb->len
> more than tailroom...

I can do that -- assuming it's backwards compatible with older kernels
as well (let's say as far back as 2.6 -- we stopped trying to support
2.4 kernels last year).

>> Is the tailroom of the allocated sk_buff guaranteed to be at least as
>> large as the requested size, or does application code also have to
>> check for tailroom less than the requested size?
>> 
>> The ultimate question I'm trying to answer is what is the "right" way
>> to allocate an sk_buff that has a size appropriate for an Ethernet
>> frame assuming an MTU of 1500?
>
> I dont know what to answer. Could you point the code in question?

Sure:

   alloc_skb(dev->hard_header_len + 1340)

The intent was to allocate a frame that we can guarantee we can send
out via the Ethernet device 'dev'.  Sometime 12-14 years ago, somebody
pulled the number "1340" out of the air under the assumption that the
resulting sk_buff would always be safely under the Ethernet limit of
1500 bytes.

That worked until kernel 3.2 came out, at which time we started ending
up with 1800 byte frames.

-- 
Grant Edwards               grant.b.edwards        Yow! I've read SEVEN
                                  at               MILLION books!!
                              gmail.com            
