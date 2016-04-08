From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Fri, 8 Apr 2016 18:40:47 -0300
Message-ID: <CAEh+42gjqeGK94xvVQFuiUF=c3YKY2SCWOL=y=2gBsHyUxQ+GA@mail.gmail.com>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
 <20160407223237.11142.33072.stgit@ahduyck-xeon-server> <CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
 <CAKgT0Ufc8EiqCR5opSFUCE2v3hFCmnS641o+epyi+G92bD+yww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:34684 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759046AbcDHVlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 17:41:05 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 068452034E
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 21:41:04 +0000 (UTC)
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8E679202FF
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 21:41:02 +0000 (UTC)
Received: by mail-qg0-f49.google.com with SMTP id f52so101687160qga.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 14:41:02 -0700 (PDT)
In-Reply-To: <CAKgT0Ufc8EiqCR5opSFUCE2v3hFCmnS641o+epyi+G92bD+yww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 7, 2016 at 8:52 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> Just a thought.  What if I replaced NETIF_F_TSO_FIXEDID with something
> that meant we could mange the IP ID like a NETIF_F_TSO_IPID_MANGLE
> (advice for better name welcome).  Instead of the feature flag meaning
> we are going to transmit packets with a fixed ID it would mean we
> don't care about the ID and are free to mangle it as we see fit.  The
> GSO type can retain the same meaning as far as that requiring the same
> ID for all, but the feature would mean we will take fixed and convert
> it to incrementing, or incrementing and convert it to fixed.

I saw the new version of the code that you posted with this idea and
now that I understand it better, it seems like a reasonable choice to
me - it's nice that it is consistent with GRO and not tunnel specific.
It also makes behavior consistent across drivers in regards to
incrementing IDs in the default case, which was one of my concerns
from before.

Maybe I missed it but I didn't see any checks for the DF bit being set
when we transmit a packet with NETIF_F_TSO_MANGLEID. Even if I am
comfortable mangling my IDs in the DF case, I don't think this would
ever extend to non-DF packets. In the documentation you noted that it
is the driver's responsibility to do this check but I couldn't find it
in either ixgbe or igb. It would also be nice if the core stack could
enforce it somehow as well rather than each driver.
