From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 16:10:40 +0200
Message-ID: <58F8C160.6010905@iogearbox.net>
References: <1492637460.22185.6.camel@sipsolutions.net>          (sfid-20170419_233114_060429_CAFE85B8) <1492640459.22185.7.camel@sipsolutions.net>      <58F7FA6D.5030000@iogearbox.net> <1492668065.3109.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34892 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032297AbdDTOLF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:11:05 -0400
In-Reply-To: <1492668065.3109.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 08:01 AM, Johannes Berg wrote:
> On Thu, 2017-04-20 at 02:01 +0200, Daniel Borkmann wrote:
>>
>> Yeah, should work as well for the 32 bit archs, on 64 bit we
>> have this effectively already:
>
> Right.
>
> [...]
>
>> Can you elaborate on why this works for mac80211? It uses cb
>> only up to that point from where you invoke the prog?
>
> No, it works because then I can move a u64 field to the same offset,
> and save/restore it across the BPF call :)

Right.

> But I don't have a *pointer* field to move there, and no space for the
> alignment anyway (already using all 48 bytes).
>
> Come to think of it - somebody had proposed extensions to this by
> passing an on-stack pointer in addition to the data in the cb.
>
> Perhaps we can extend BPF to have an optional second argument, and
> track a second context around the verifier, if applicable? Then we can
> solve all of this really easily, because it means we don't always have
> to go from the SKB context but could go from the other one (which could
> be that on-stack buffer).

I think this would be a rather more complex operation on the BPF side,
it would need changes from LLVM (which assumes initial ctx sits in r1),
verifier for tracking this ctx2, all the way down to JITs plus some way
to handle 1 and 2 argument program calls generically. Much easier to
pass additional meta data for the program via cb[], for example.

> Alternatively I can clear another pointer (u64) in the CB, store a
> pointer there, and always emit code following that pointer - should be
> possible right?

What kind of pointer? If it's something like data_end as read-only, then
this needs to be tracked in the verifier in addition, of course. Other
option you could do (depending on what you want to achieve) is to have
a bpf_probe_read() version as a helper for your prog type that would
further walk that pointer/struct (similar to tracing) where this comes
w/o any backward compat guarantees, though.
