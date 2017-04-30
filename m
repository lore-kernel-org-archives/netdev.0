From: David Miller <davem@davemloft.net>
Subject: Re: assembler mnenomics for call/tailcall plus maps...
Date: Sun, 30 Apr 2017 11:27:27 -0400 (EDT)
Message-ID: <20170430.112727.832791813264677235.davem@davemloft.net>
References: <398986a4-ef4b-6631-c6eb-96505e0a5849@fb.com>
        <20170429.143835.270339931242716768.davem@davemloft.net>
        <c9ff0d0c-b91b-c3dc-654e-8b1c1a4c92f0@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753525AbdD3P1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 11:27:32 -0400
In-Reply-To: <c9ff0d0c-b91b-c3dc-654e-8b1c1a4c92f0@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 23:35:30 -0700

> On 4/29/17 11:38 AM, David Miller wrote:
>> or, taking it one step further, do the following since we know this
>> maps to a 32-bit FD:
>>
>> 	mov32	r1, %map(hash_map)
> 
> hence this approach won't work without serious elf loader hacks.
> The kernel needs to see ldimm64 because after it validated map_fd,
> it will store real 'struct bpf_map *' pointer into this ldimm64
> instruction and it will clear 'src_reg' markings.

I didn't see this part, now it all makes sense why ldimm64 is used
and I therefore think we should keep it this way.

> So from interpreter and from JITs point of view there are no
> special ldimm64 instructions. All ldimm64 are moving 64-bit
> constant into a register. It's only verifier that knows that
> some of these constants are real pointers.
> 
>> In GCC it will be simple to get the backend to emit this, various
>> options exist.  We can make it a special "__attribute__((map))", or
>> use address spaces to annotate the map object.  And then when the
>> ldimm64 or whatever instruction is emitted, and it sees the symbol
>> referenced has this special type, it will emit "%%map(%s)" instead of
>> just "%s" for the symbol name in the asembler output.
> 
> I like the %map(symbol) idea.
> I think it fits the whole thing quite well.
> Not sure though how gcc will know that it needs to emit %map(..)

I just explained it in that paragraph above :-)

struct bpf_map_def SEC("maps") jmp_table __attribute__((map)) = {

And when referenced by an instruction the bpf gcc backend can see that
the "map" attribute is set and emit the appropriate %map() string into
the assembler.

We can even make the special map attribute do the SEC("") part too.

> I take all the blame for not documenting this thing properly.
> The elf loader in samples/bpf/bpf_load.c should have been temporary.
> Its only purpose was to have minimal demo to parse elf and load it.
> I didn't expect the .o approach to come that far.
> My bet was on iovisor/bcc approach where elf file is never generated.
> C->bpf is compiled in memory and loaded into the kernel completely
> without elf and without relocations.

I think it is better to have real objects for introspection (even
after session is complete) and for testing under simulators (one of
which I plan to write).

And if we linked a real final static object, elf header would be all
that would be needed to find execution entry point.
