From: Guy Harris <guy@alum.mit.edu>
Subject: Re: Problems with TPACKET_V3 delivery of wakeups (and empty buffer blocks)
Date: Mon, 4 Aug 2014 21:52:27 -0700
Message-ID: <C7B99DBD-8362-4A39-B9AD-D7AC14880DA5@alum.mit.edu>
References: <FBF13AD0-7721-4CEF-94AE-A14C1B06E84C@alum.mit.edu> <53DF3F44.6090804@redhat.com> <CAAsGZS5GNcYhXz5cD9W2iOR9mKHLJi9NpksKW5YGdPr9mb3ZnQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:53875 "EHLO d.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752121AbaHEEwg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 00:52:36 -0400
In-Reply-To: <CAAsGZS5GNcYhXz5cD9W2iOR9mKHLJi9NpksKW5YGdPr9mb3ZnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 4, 2014, at 8:23 PM, chetan loke <loke.chetan@gmail.com> wrote:

> Empty buffer blocks have to be delivered. The patch explains it why.

If by "the patch" you mean

	https://lkml.org/lkml/2011/6/21/463

and the comment

> E2) Also implemented basic timeout mechanism to close 'a' current block.
>     That way, user-space won't be blocked forever on an idle link.
>     This is a much needed feature while monitoring multiple ports.
>     Look at 3) below.

then that's presumably referring to 3.4.2 in

> 3) Port aggregation analysis:
>    Multiple ports are viewed/analyzed as one logical pipe.
>    Example:
>    3.1) up-stream    path can be tapped in eth1
>    3.2) down-stream  path can be tapped in eth2
>    3.3) Network TAP splits Rx/Tx paths and then feeds to eth1,eth2.
> 
>    If both eth1,eth2 need to be viewed as one logical channel,
>    then that implies we need to timesort the packets as they come across
>    eth1,eth2.
> 
>    3.4) But following issues further complicates the problem:
>         3.4.1)What if one stream is bursty and other is flowing
>               at line rate?
>         3.4.2)How long do we wait before we can actually make a
>               decision in the app-space and bail-out from the spin-wait?

and presumably this is referring to some mechanism by which eth1 and eth2 are handled by *one* socket, because if it's handled by *two* sockets, you use select()/poll()/epoll() on the two sockets, and, when *either* of the devices either fills up a block or times out, a wakeup is delivered to its socket and userland wakes up.

And even if there's some reason why a wakeup has to be delivered when the timer expires even if *no* packets are available, what is the reason why you don't just deliver a wakeup but *no* buffer blocks, so that userland just says "well, I woke up, but there are no buffer blocks available for that particular socket, so there's nothing to process for that socket"?