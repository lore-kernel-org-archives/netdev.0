From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 3/4] secure_seq: use SipHash in place of MD5
Date: Sat, 07 Jan 2017 20:42:37 -0500 (EST)
Message-ID: <20170107.204237.1849847777260495687.davem@davemloft.net>
References: <20170107144057.15432-4-Jason@zx2c4.com>
        <20170107.163736.2224609477435674963.davem@davemloft.net>
        <20170107220911.GB8327@zzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ak@linux.intel.com,
        David.Laight@aculab.com, tom@herbertland.com,
        hannes@stressinduktion.org, eric.dumazet@gmail.com, luto@kernel.org
To: ebiggers3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50416 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933164AbdAHBml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 20:42:41 -0500
In-Reply-To: <20170107220911.GB8327@zzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Biggers <ebiggers3@gmail.com>
Date: Sat, 7 Jan 2017 14:09:11 -0800

> Well, except those instructions aren't actually used in these
> places.  Although x86_64 SHA1-NI accelerated SHA-1 is available in
> the Linux crypto API, it seems that in kernel code it remains
> impractical to use these instructions on small amounts of data
> because they use XMM registers, which means the overhead of
> kernel_fpu_begin()/kernel_fpu_end() must be incurred.  Furthermore,
> kernel_fpu_begin() is not allowed in all contexts so there has to be
> a fallback.
> 
> Out of curiosity, is this actually a solvable problem, e.g. by
> making the code using the XMM registers responsible for saving and
> restoring the ones clobbered, or by optimizing
> kernel_fpu_begin()/kernel_fpu_end()?  Or does it in fact remain
> impractical for such instructions to be used for applications like
> this one?

On x86 making the FPU save more tractible in situations like this is
really hard and will make the code significantly more complex.

It's simpler and cheaper on sparc64, and unlike on x86 there aren't
any fundament restrictions on where FPU stuff can be used.  This is
because we don't have "save all the FPU state" instructions and have
to do it all by hand anyways.

However I will note that just like x86, sparc64 doesn't override the
md5_transform() in lib/md5.c like it should.
