From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sparc: bpf_jit: fix loads from negative offsets
Date: Wed, 24 Sep 2014 15:08:37 -0400 (EDT)
Message-ID: <20140924.150837.1990547182303548810.davem@davemloft.net>
References: <1411505410-25215-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbaIXTIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 15:08:39 -0400
In-Reply-To: <1411505410-25215-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 23 Sep 2014 13:50:10 -0700

> - fix BPF_LD|ABS|IND from negative offsets:
>   make sure to sign extend lower 32 bits in 64-bit register
>   before calling C helpers from JITed code, otherwise 'int k'
>   argument of bpf_internal_load_pointer_neg_helper() function
>   will be added as large unsigned integer, causing packet size
>   check to trigger and abort the program.
> 
>   It's worth noting that JITed code for 'A = A op K' will affect
>   upper 32 bits differently depending whether K is simm13 or not.
>   Since small constants are sign extended, whereas large constants
>   are stored in temp register and zero extended.
>   That is ok and we don't have to pay a penalty of sign extension
>   for every sethi, since all classic BPF instructions have 32-bit
>   semantics and we only need to set correct upper bits when
>   transitioning from JITed code into C.
> 
> - though instructions 'A &= 0' and 'A *= 0' are odd, JIT compiler
>   should not optimize them out
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks for fixing this.

What we could do longer-term is change is_simm13() into is_simm12()
and therefore know that all constants loaded are 32-bit zero extended
regardless of size.

BTW, there is a trick to load arbitrary negative 32-bit constants sign
extended to 64-bit, in just two instructions:

	sethi	%(~value), reg
	xor	reg, ~(0x400 | (value & 0x3ff)), reg

Or something like that, it's been a while.  GCC knows how to emit
that sequence too.

Anyways, we could adjust the JIT to do that too.
