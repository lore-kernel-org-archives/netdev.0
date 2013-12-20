From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Toeplitz library functions
Date: Thu, 19 Dec 2013 17:38:29 -0800
Message-ID: <1387503509.19078.412.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312191635460.9677@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:59289 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756716Ab3LTBib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 20:38:31 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so1932802pad.24
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 17:38:30 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312191635460.9677@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 16:41 -0800, Tom Herbert wrote:
> Introduce Toeplitz hash functions. Toeplitz is a hash used primarily in
> NICs to perform RSS flow steering.  This is a software implementation
> of that. In order to make the hash calculation efficient, we precompute
> the possible hash values for each inidividual byte of input. The input
> length is up to 36 bytes, so we make an array of cache[36][256].

I really don't see how this can be faster than just a normal arithmetic
computation.

Modern cpus can do ~100+ instructions during the time needed to bring
one byte from memory.

On a moderate load and cold cache, hashing 16 bytes need more than 500
nsec (between 60 to 100 ns per cache line miss)

It seems this really can be done with maybe 5 or 6 instructions per bit.

The 8 bits per byte can unroll the inner loop and use no conditional
branch. (No need to search next bit, this is way too expensive)

Sort of :

https://github.com/YanVugenfirer/kvm-guest-drivers-windows/blob/master/NetKVM/DebugTools/RSS-Toeplitz/WinToeplitz.c

But a bit optimized ;)

test  $1,%dl
mov   %ecx,%edx
cmove $0,%edx
xor   %edx,%edi
rol   $1,%rcx

test  $2,%dl
mov   %ecx,%edx
cmove $0,%edx
xor   %edx,%edi
rol   $1,%rcx

test  $4,%dl
mov   %ecx,%edx
cmove $0,%edx
xor   %edx,%edi
rol   $1,%rcx

test  $8,%dl
mov   %ecx,%edx
cmove $0,%edx
xor   %edx,%edi
rol   $1,%rcx

Oh well...
