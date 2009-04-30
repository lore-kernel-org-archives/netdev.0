From: =?ISO-8859-1?B?SmVucyBM5eVz?= <jelaas@gmail.com>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 12:51:16 +0200
Message-ID: <96ff3930904300351x60842bc1me0431c856f631773@mail.gmail.com>
References: <606676310904291600u40e44187g4cfc104007b24fce@mail.gmail.com>
	 <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	 <20090430.022417.07019547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@whydna.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:45545 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbZD3KvS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 06:51:18 -0400
Received: by ewy24 with SMTP id 24so1808807ewy.37
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 03:51:16 -0700 (PDT)
In-Reply-To: <20090430.022417.07019547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/4/30, David Miller <davem@davemloft.net>:
> From: Jens L=E5=E5s <jelaas@gmail.com>
>  Date: Thu, 30 Apr 2009 11:07:35 +0200
>
>
>  > RX-side looks good. TX-side looks like what we also got with vanil=
la linux.
>  >
>  > What we do is patch all drivers with a custom select_queue functio=
n
>  > that selects the same outgoing queue as the incoming queue. With a=
 one
>  > to one mapping of queues to CPUs you can also use the processor id=
=2E
>  >
>  > This way we get performance.
>
>
> I don't understand why this can even be necessary.
>
>  With the current code, the RX queue of a packet becomes
>  the hash for the TX queue.
>
>  If all the TX activity is happening on one TX queue then
>  there is a bug somewhere.

If I remember correctly we got use of several tx-queues and not one.
The hashed distribution missed a few of the tx-queues though. And it
also looked like some rx-queues got mapped on top of the same
tx-queue.

At the time we reasoned this behaviour was expected from the hashed ran=
domizing.
We may certainly have misunderstood this and a one to one mapping
should be expected.

Hopefully the case where we have several devices and want
TX-completion to match rx-queue can also be solved. (The assumption
that tx-completion needs to run on the same CPU may also be proved
wrong. But we havent seen this in tests sofar.)

The main problem though was that the mapping is randomized. We wanted
to set smp_affinity correctly for tx to match rx. That was actually
the main reason for our local hacks.

>
>  Either the receiving device isn't invoking skb_record_rx_queue()
>  correctly, or there is some bug in how we compute the TX hash.
>
>  Everyone adds their own hacks, but that absolutely should not be
>  necessary, the kernel is essentially doing what you are adding
>  hacks for.
>
>  The only possible problems are bugs in the code, and we should find
>  those bugs instead of constantly talking about 'local select_queue
>  hacks we add to our cool driver for performance' :-/

We certainly dont consider the hacks cool in any way. They were only
for a specific purpose and a specific kernel-version.

Cheers,
Jens
