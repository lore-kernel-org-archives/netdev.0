From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Thu, 7 Apr 2016 16:52:08 -0700
Message-ID: <CAKgT0Ufc8EiqCR5opSFUCE2v3hFCmnS641o+epyi+G92bD+yww@mail.gmail.com>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
	<20160407223237.11142.33072.stgit@ahduyck-xeon-server>
	<CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34734 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbcDGXwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 19:52:14 -0400
Received: by mail-io0-f170.google.com with SMTP id 2so113185423ioy.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 16:52:14 -0700 (PDT)
In-Reply-To: <CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 7, 2016 at 4:22 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Thu, Apr 7, 2016 at 7:32 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch adds support for a feature I am calling IP ID mangling.  It is
>> basically just another way of saying the IP IDs that are transmitted by the
>> tunnel may not match up with what would normally be expected.  Specifically
>> what will happen is in the case of TSO the IP IDs on the headers will be a
>> fixed value so a given TSO will repeat the same inner IP ID value gso_segs
>> number of times.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>
> If I'm understanding this correctly, enabling IP ID mangling will help
> performance on ixgbe since it will allow it to do GSO partial instead
> of plain GSO but it will hurt performance on i40e since it will drop
> from TSO to plain GSO.

Right.  However the option is currently defaulted to off, and can be
enabled per tunnel endpoint.  So if you had an ixgbe to i40e link you
could enable it on the end with the ixgbe and you should see good
performance in both directions.

> Assuming that's right, it seems like it will make it hard to chose the
> right setting without knowledge of which hardware is in use. I guess
> what we really want is "I care about nicely incrementing IP IDs" vs.
> "I don't care as long as the DF bit is set". That second case is
> really what this flag is trying to say but it seems like it is
> enforcing too much in the i40e case - I don't think anyone wants to go
> out of their way to make IP IDs jump around if incrementing is faster.

Right.  The problem is trying to sort out all the GRO/GSO bits.  I was
probably being a bit too conservative after the last few iterations
for the GRO fixes.

Just a thought.  What if I replaced NETIF_F_TSO_FIXEDID with something
that meant we could mange the IP ID like a NETIF_F_TSO_IPID_MANGLE
(advice for better name welcome).  Instead of the feature flag meaning
we are going to transmit packets with a fixed ID it would mean we
don't care about the ID and are free to mangle it as we see fit.  The
GSO type can retain the same meaning as far as that requiring the same
ID for all, but the feature would mean we will take fixed and convert
it to incrementing, or incrementing and convert it to fixed.

- Alex
