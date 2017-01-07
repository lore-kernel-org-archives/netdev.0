From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 3/4] secure_seq: use SipHash in place of MD5
Date: Sat, 07 Jan 2017 16:37:36 -0500 (EST)
Message-ID: <20170107.163736.2224609477435674963.davem@davemloft.net>
References: <20170107144057.15432-1-Jason@zx2c4.com>
        <20170107144057.15432-4-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiggers3@gmail.com, jeanphilippe.aumasson@gmail.com,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ak@linux.intel.com,
        David.Laight@aculab.com, tom@herbertland.com,
        hannes@stressinduktion.org, eric.dumazet@gmail.com
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932642AbdAGVhl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 16:37:41 -0500
In-Reply-To: <20170107144057.15432-4-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Sat,  7 Jan 2017 15:40:56 +0100

> This gives a clear speed and security improvement. Siphash is both
> faster and is more solid crypto than the aging MD5.
> 
> Rather than manually filling MD5 buffers, for IPv6, we simply create
> a layout by a simple anonymous struct, for which gcc generates
> rather efficient code. For IPv4, we pass the values directly to the
> short input convenience functions.
> 
> 64-bit x86_64:
> [    1.683628] secure_tcpv6_sequence_number_md5# cycles: 99563527
> [    1.717350] secure_tcp_sequence_number_md5# cycles: 92890502
> [    1.741968] secure_tcpv6_sequence_number_siphash# cycles: 67825362
> [    1.762048] secure_tcp_sequence_number_siphash# cycles: 67485526
> 
> 32-bit x86:
> [    1.600012] secure_tcpv6_sequence_number_md5# cycles: 103227892
> [    1.634219] secure_tcp_sequence_number_md5# cycles: 94732544
> [    1.669102] secure_tcpv6_sequence_number_siphash# cycles: 96299384
> [    1.700165] secure_tcp_sequence_number_siphash# cycles: 86015473
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

This and the next patch are a real shame, performance wise, on cpus
that have single-instruction SHA1 and MD5 implementations.  Sparc64
has both, and I believe x86_64 can do SHA1 these days.

It took so long to get those instructions into real silicon, and then
have software implemented to make use of them as well.

Who knows when we'll see SipHash widely deployed in any instruction
set, if at all, right?  And by that time we'll possibly find out that
"Oh shit, this SipHash thing has flaws!" and we'll need
DIPPY_DO_DA_HASH and thus be forced back to a software implementation
again.

I understand the reasons why these patches are being proposed, I just
thought I'd mention the issue of cpus that implement secure hash
algorithm instructions.
