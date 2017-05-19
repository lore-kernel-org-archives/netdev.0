From: David Miller <davem@davemloft.net>
Subject: Re: Alignment in BPF verifier
Date: Fri, 19 May 2017 16:48:40 -0400 (EDT)
Message-ID: <20170519.164840.57148340718700773.davem@davemloft.net>
References: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
        <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
        <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756760AbdESUsm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:48:42 -0400
In-Reply-To: <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 19 May 2017 21:00:13 +0100

> Here's what I'm thinking of doing:
> struct bpf_reg_state {
>     enum bpf_reg_type type;
>     union {
>         /* valid when type == PTR_TO_PACKET */
>         u16 range;
> 
>         /* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
>          *   PTR_TO_MAP_VALUE_OR_NULL
>          */
>         struct bpf_map *map_ptr;
>     };
>     /* Used to find other pointers with the same variable base, so they
>      * can share range and align knowledge.
>      */
>     u32 id;
>     u32 off; /* fixed part of pointer offset */
>     /* For scalar types (CONST_IMM | UNKNOWN_VALUE), this represents our
>      * knowledge of the actual value.
>      * For pointer types, this represents the variable part of the offset
>      * from the pointed-to object, and is shared with all bpf_reg_states
>      * with the same id as us.
>      */
>     struct tnum align;
>     /* Used to determine if any memory access using this register will
>      * result in a bad access. These two fields must be last.
>      * See states_equal()
>      * These refer to the same value as align, not necessarily the actual
>      * contents of the register.
>      */
>     s64 min_value;
>     u64 max_value;
> };

Be very careful with the layout of bpf_reg_state.

There are layout dependencies in the state pruning.  Please take a look
at states_equal().  It is walking the set of registers at two snapshot
locations and trying to see if they are "equivalent".

What's happening here is that the verifier makes a stack of all branch
points in the program.  On the first pass it analyzes the register
values taking one of the two paths a branch takes.  Then when it hits
the end of the program, on that path, to BPF_EXIT it starts popping
the entries on the stack.

The naive implementation would pop each stack entry, and then traverse
the other arm of the branch.  But for programs with lots of branches
this gets very expensive.

So at each stack pop, the verifier tries to determine if it can skip
traversing the branch's other path.  And it does this by analyzing
register state.

The tests are basically:

		if (memcmp(rold, rcur, sizeof(*rold)) == 0)
			continue;

exact equivalent, then we're fine.

		/* If the ranges were not the same, but everything else was and
		 * we didn't do a variable access into a map then we are a-ok.
		 */
		if (!varlen_map_access &&
		    memcmp(rold, rcur, offsetofend(struct bpf_reg_state, id)) == 0)
			continue;

We didn't do any variable MAP accesses, and everything in the register
"up to and including member ID" is the same, we're fine.

And then we drop down into some packet pointer specific tests to try
and optimize things further.

So you have to be careful what you place before and/or after 'id'.

Probably we need to put the alignment stuff before 'id' so that it
is considered by the offsetofend() length memcmp().

Hope that helps.
