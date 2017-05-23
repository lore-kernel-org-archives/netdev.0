From: Edward Cree <ecree@solarflare.com>
Subject: Re: Alignment in BPF verifier
Date: Tue, 23 May 2017 15:41:08 +0100
Message-ID: <f882c40e-bd50-f08e-afd8-f6396fc24ebc@solarflare.com>
References: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
 <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
 <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
 <20170519.163957.1950740987459934279.davem@davemloft.net>
 <591F7A28.3020004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <alexei.starovoitov@gmail.com>,
        <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:37496 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965197AbdEWOlY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:41:24 -0400
In-Reply-To: <591F7A28.3020004@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm still plugging away at this... it's going to be quite a big patch and
 rewrite a lot of stuff (and I'm not sure I'll be able to break it into
 smaller bisectable patches).
And of course I have more questions.  In check_packet_ptr_add(), we
 forbid adding a negative constant to a packet ptr.  Is there some
 principled reason for that, or is it just because the bounds checking is
 hard?  It seems like, if imm + reg->off > 0 (suitably carefully checked
 to avoid overflow etc.), then the subtraction should be legal.  Indeed,
 even if the reg->off (fixed part of offset) is zero, if the variable part
 is known (min_value) to be >= -imm, the subtraction should be safe.

On 20/05/17 00:05, Daniel Borkmann wrote:
> Besides PTR_TO_PACKET also PTR_TO_MAP_VALUE_OR_NULL uses it to
> track all registers (incl. spilled ones) with the same reg->id
> that originated from the same map lookup. After the reg type is
> then migrated to either PTR_TO_MAP_VALUE (resp. CONST_PTR_TO_MAP
> for map in map) or UNKNOWN_VALUE depending on the branch, the
> reg->id is then reset to 0 again. Whole reason for this is that
> LLVM generates code where it can move and/or spill a reg of type
> PTR_TO_MAP_VALUE_OR_NULL to other regs before we do the NULL
> test on it, and later on it expects that the spilled or moved
> regs work wrt access. So they're marked with an id and then all
> of them are type migrated. So here meaning of reg->id is different
> than in PTR_TO_PACKET case.
Hmm, that means that we can't do arithmetic on a
 PTR_TO_MAP_VALUE_OR_NULL, we have to convert it to a PTR_TO_MAP_VALUE
 first by NULL-checking it.  That's probably fine, but I can just about
 imagine some compiler optimisation reordering them.  Any reason not to
 split this out into a different reg->field, rather than overloading id?
Of course that would need (more) caution wrt. states_equal(), but it
 looks like I'll be mangling that a lot anyway - for instance, we don't
 want to just use memcmp() to compare alignments, we want to check that
 our alignment is stricter than the old alignment.  (Of course memcmp()
 is a conservative check, so the "memcmp() the whole reg_state" fast
 path can remain.)

-Ed
