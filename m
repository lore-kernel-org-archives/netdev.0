From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 6 Jun 2012 18:32:57 +0000 (UTC)
Message-ID: <jqo7op$t6f$1@dough.gmane.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:47850 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634Ab2FFSdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 14:33:23 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ScL2k-0000tb-U6
	for netdev@vger.kernel.org; Wed, 06 Jun 2012 20:33:18 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 20:33:18 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 20:33:18 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm tracking down a problem that appears to be caused by a change in
the behavior of alloc_skb() introduced in kernel version 3.2.  In
kernel versions prior to 3.2, calling alloc_skb(1350), returned an
sk_buff with a tailroom of around 1400 bytes (safely below the default
Ethernet frame size limit of 1500).

In 3.2 and later, calling alloc_skb(1350) returns an sk_buff with a
tailroom of about 1850.

Why has the "extra" space increased from 60 bytes to 500 bytes?

[It's always possible that I've unintentionally changed something in
the kernel configs that causes this, but I've tried to build the
kernels as identically as possible.]

The kernel module that's started failing fills the allocated sk_buff
until tailroom() indicates it is full and then sends it.  The problem
is that sending a packet with a length of 1850 won't work (it's a
MAC-layer Ethernet packet).

I've found man pages for alloc_skb() from a few years ago that state
explicitly that alloc_skb(_size_) will allocate a new sk_buff with no
headroom and a tail room of _size_ bytes.  This doesn't seem to be the
case for recent kernels.  Is there any documentation stating what the
current behavior is supposed to be?

Are callers to alloc_skb() supposed to check the tailroom and
reserve() an appropriate number of bytes such that the tailroom is
correct?

Is the tailroom of the allocated sk_buff guaranteed to be at least as
large as the requested size, or does application code also have to
check for tailroom less than the requested size?

The ultimate question I'm trying to answer is what is the "right" way
to allocate an sk_buff that has a size appropriate for an Ethernet
frame assuming an MTU of 1500?

-- 
Grant Edwards               grant.b.edwards        Yow! Let's send the
                                  at               Russians defective
                              gmail.com            lifestyle accessories!
