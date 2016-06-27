From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: do not use stack storage in crypto
 operations
Date: Mon, 27 Jun 2016 10:51:58 -0400 (EDT)
Message-ID: <20160627.105158.605041440961301398.davem@davemloft.net>
References: <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
	<1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
	<1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcF0Ow2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:52:28 -0400
In-Reply-To: <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 25 Jun 2016 18:09:35 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Some arches have virtually mapped kernel stacks, or will soon have.
> 
> tcp_md5_hash_header() uses an automatic variable to copy tcp header
> before mangling th->check and calling crypto function, which might
> be problematic on such arches.
> 
> So use percpu storage as we already do for the pseudo header,
> and reduce number of crypto functions calls, as these headers
> are ridiculously small.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andy Lutomirski <luto@amacapital.net>
> ---
> I am not sure the md5 crypto functions have a problem with data backed
> in virtually mapped stacks, but this patch seems to remove the doubt.

In a non-SMP build this storage will be in the kernel image itself.

And this violates the crypto layer's requirements.

It has to be memory taken from the page allocator or kmalloc.  So
before vmalloc'd stacks, the current code is perfectly fine.  And
with vmalloc'd stacks this patch trades one bug for another.
