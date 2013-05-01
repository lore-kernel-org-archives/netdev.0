From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] af_unix: fix a fatal race with bit fields
Date: Wed, 01 May 2013 15:14:19 -0400 (EDT)
Message-ID: <20130501.151419.1237664751661506825.davem@davemloft.net>
References: <1367372393.22115.6.camel@pasglop>
	<20130501.033650.703182794549888825.davem@davemloft.net>
	<1367421843.11020.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org, paulus@samba.org,
	ambrose@google.com, linuxppc-dev@lists.ozlabs.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919Ab3EATOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:14:21 -0400
In-Reply-To: <1367421843.11020.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 May 2013 08:24:03 -0700

> [PATCH v2] af_unix: fix a fatal race with bit fields
> 
> Using bit fields is dangerous on ppc64/sparc64, as the compiler [1]
> uses 64bit instructions to manipulate them.
> If the 64bit word includes any atomic_t or spinlock_t, we can lose
> critical concurrent changes.
> 
> This is happening in af_unix, where unix_sk(sk)->gc_candidate/
> gc_maybe_cycle/lock share the same 64bit word.
> 
> This leads to fatal deadlock, as one/several cpus spin forever
> on a spinlock that will never be available again.
> 
> A safer way would be to use a long to store flags.
> This way we are sure compiler/arch wont do bad things.
> 
> As we own unix_gc_lock spinlock when clearing or setting bits,
> we can use the non atomic __set_bit()/__clear_bit().
> 
> recursion_level can share the same 64bit location with the spinlock,
> as it is set only with this spinlock held.
> 
> [1] bug fixed in gcc-4.8.0 :
> http://gcc.gnu.org/bugzilla/show_bug.cgi?id=52080
> 
> Reported-by: Ambrose Feinstein <ambrose@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
