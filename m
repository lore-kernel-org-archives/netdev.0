From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Tue, 14 Oct 2014 22:01:11 -0400 (EDT)
Message-ID: <20141014.220111.179628329028952302.davem@davemloft.net>
References: <CALCETrUYBed_TBacxoDPMphM5y=iqxho2isrDruOQi=pmK2yoQ@mail.gmail.com>
	<20141014.160056.2113064815910782529.davem@davemloft.net>
	<CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org, tgraf@suug.ch
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755840AbaJOCBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 22:01:13 -0400
In-Reply-To: <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 14 Oct 2014 15:16:46 -0700

> It's at least remotely possible that there's something that assumes
> that assumes that the availability of NETLINK_RX_RING implies
> NETLINK_TX_RING, which would be unfortunate.

I already found one such case, nlmon :-/

It also reminds me that I'll have to update
Documentation/networking/netlink_mmap.txt

Thomas, the context is that we have to remove NETLINK_TX_RING support
(there is absolutely no way whatsoever to reliably keep some thread of
control from modifying the underlying pages while we parse and
validate the netlink request).

I'd like to be able to do so while retaining NETLINK_RX_RING because
that works fine and is great for monitoring when the rate of events
is high.

But I already have found userland pieces of code, like nlmon, which
assume that if one is present then both must be present.

I really think this means I'll have to remove all of the netlink
mmap() support in order to prevent from breaking applications. :(

The other option is to keep NETLINK_TX_RING, but copy the data into
a kernel side buffer before acting upon it.
