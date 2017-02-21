From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 15:09:07 -0800
Message-ID: <20170221150907.5ae68ffa@cakuba.netronome.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:9308 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753239AbdBUXJc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 18:09:32 -0500
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

I still have a few worries about this patch set...

On Tue, 21 Feb 2017 11:34:09 -0800, Tom Herbert wrote:
> This patch set generalizes XDP by making the hooks in drivers to be
> generic. This has a number of advantages:
> 
>   - Allows a means to pipeline XDP programs together

Does it add anything beyond what we already can achieve with tail
calls?  Is there expectations that users will install independent
black box/pre-compiled programs on the same interface?

>   - Reduces the amount of code and complexity needed in drivers to
>     manage XDP

Other than for Mellanox drivers the savings are in *teen lines of code?

>   - Provides a more structured environment that is extensible to new
>     features while being mostly transparent to the drivers

So far all features we added required explicit driver support.
Checksumming support as an example will require driver changes, too.
Generalized way to call programs is probably not going to buy us much?

>   - Allow XDP programs to be set per device or per queue

Some drivers already provide that even though we don't have a user API
to set it.

>   - Moves management of BPF programs out of driver into a common
>     infrastructure

I appreciate this one, but IMHO this generalized infrastructure is way
too complicated for the purpose.  Why not simply place an XDP program
pointer into netdev and napi and provide driver with a helper to install
the program there?  Or am I simply not understanding the benefits of
the generalized hooks?

I probably have a slightly unique perspective caring about offloads but
IMHO the cost of this patchset outweighs the benefits right now.  You
haven't actually implement the OFFLOAD command at all (grep for
XDP_OFFLOAD_BPF) but having to deal with the intermediary layer will
certainly complicate things here.  

There are also miscellaneous optimizations which are possible when
drivers can inspect the program, like only reserving headroom if
program may use header adjust...  it does seem to me that this set
introduces a lot of complexity and only superficial driver
simplifications.  I would personally rather wait with infrastructure
like this until John's TX-to-other netdev is well formulated.

Obviously this set will also be a major pain when backporting things,
too.
