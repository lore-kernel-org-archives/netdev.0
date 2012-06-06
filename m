From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 06 Jun 2012 20:42:22 +0200
Message-ID: <1339008142.26966.40.camel@edumazet-glaptop>
References: <jqo7op$t6f$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Edwards <grant.b.edwards@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44986 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062Ab2FFSm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 14:42:28 -0400
Received: by eaak11 with SMTP id k11so2078443eaa.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 11:42:27 -0700 (PDT)
In-Reply-To: <jqo7op$t6f$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 18:32 +0000, Grant Edwards wrote:
> I'm tracking down a problem that appears to be caused by a change in
> the behavior of alloc_skb() introduced in kernel version 3.2.  In
> kernel versions prior to 3.2, calling alloc_skb(1350), returned an
> sk_buff with a tailroom of around 1400 bytes (safely below the default
> Ethernet frame size limit of 1500).
> 
> In 3.2 and later, calling alloc_skb(1350) returns an sk_buff with a
> tailroom of about 1850.
> 
> Why has the "extra" space increased from 60 bytes to 500 bytes?
> 

Because of kmalloc-2048 being used. Previous kernels were losing this
space. We are now able to expand some packets without extra
re-allocation/copy.

> [It's always possible that I've unintentionally changed something in
> the kernel configs that causes this, but I've tried to build the
> kernels as identically as possible.]
> 
> The kernel module that's started failing fills the allocated sk_buff
> until tailroom() indicates it is full and then sends it.  The problem
> is that sending a packet with a length of 1850 won't work (it's a
> MAC-layer Ethernet packet).

This code seems buggy.

> 
> I've found man pages for alloc_skb() from a few years ago that state
> explicitly that alloc_skb(_size_) will allocate a new sk_buff with no
> headroom and a tail room of _size_ bytes.  This doesn't seem to be the
> case for recent kernels.  Is there any documentation stating what the
> current behavior is supposed to be?
> 
> Are callers to alloc_skb() supposed to check the tailroom and
> reserve() an appropriate number of bytes such that the tailroom is
> correct?
> 

If you allocate skbs with 1500 bytes, you probably should check skb->len
more than tailroom...

> Is the tailroom of the allocated sk_buff guaranteed to be at least as
> large as the requested size, or does application code also have to
> check for tailroom less than the requested size?
> 
> The ultimate question I'm trying to answer is what is the "right" way
> to allocate an sk_buff that has a size appropriate for an Ethernet
> frame assuming an MTU of 1500?
> 

I dont know what to answer. Could you point the code in question ?
