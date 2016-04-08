From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Fri, 8 Apr 2016 15:04:52 -0700
Message-ID: <CAKgT0UcehJaKhEQCATuyp48Q0gqofk7JjwsakNo1KgJd2YH-TA@mail.gmail.com>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
	<20160407223237.11142.33072.stgit@ahduyck-xeon-server>
	<CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
	<CAKgT0Ufc8EiqCR5opSFUCE2v3hFCmnS641o+epyi+G92bD+yww@mail.gmail.com>
	<CAEh+42gjqeGK94xvVQFuiUF=c3YKY2SCWOL=y=2gBsHyUxQ+GA@mail.gmail.com>
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
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37487 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbcDHWEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 18:04:54 -0400
Received: by mail-ig0-f174.google.com with SMTP id g8so27847319igr.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 15:04:53 -0700 (PDT)
In-Reply-To: <CAEh+42gjqeGK94xvVQFuiUF=c3YKY2SCWOL=y=2gBsHyUxQ+GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 2:40 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Thu, Apr 7, 2016 at 8:52 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> Just a thought.  What if I replaced NETIF_F_TSO_FIXEDID with something
>> that meant we could mange the IP ID like a NETIF_F_TSO_IPID_MANGLE
>> (advice for better name welcome).  Instead of the feature flag meaning
>> we are going to transmit packets with a fixed ID it would mean we
>> don't care about the ID and are free to mangle it as we see fit.  The
>> GSO type can retain the same meaning as far as that requiring the same
>> ID for all, but the feature would mean we will take fixed and convert
>> it to incrementing, or incrementing and convert it to fixed.
>
> I saw the new version of the code that you posted with this idea and
> now that I understand it better, it seems like a reasonable choice to
> me - it's nice that it is consistent with GRO and not tunnel specific.
> It also makes behavior consistent across drivers in regards to
> incrementing IDs in the default case, which was one of my concerns
> from before.
>
> Maybe I missed it but I didn't see any checks for the DF bit being set
> when we transmit a packet with NETIF_F_TSO_MANGLEID. Even if I am
> comfortable mangling my IDs in the DF case, I don't think this would
> ever extend to non-DF packets. In the documentation you noted that it
> is the driver's responsibility to do this check but I couldn't find it
> in either ixgbe or igb. It would also be nice if the core stack could
> enforce it somehow as well rather than each driver.

Yeah I had glossed over that in the igb and ixgbe patches.  A check is
only really needed for the incrementing to non-incrementing case and I
wasn't sure how common it was to have TCP with an IP header that
didn't set the DF bit.  In the case of the outer headers igb and ixgbe
will increment the IP ID always so we don't have to worry about if DF
is set of not there.  For the inner headers I had fudged it a bit and
didn't add the validation.  If needed I can see about adding that
shortly.

- Alex
