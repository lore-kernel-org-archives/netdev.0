From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 06 Oct 2015 10:05:15 +0200
Message-ID: <561380BB.4040506@iogearbox.net>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com> <1444078101-29060-2-git-send-email-ast@plumgrid.com> <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com> <20151006071347.GB14093@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55845 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbJFIFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 04:05:24 -0400
In-Reply-To: <20151006071347.GB14093@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2015 09:13 AM, Ingo Molnar wrote:
>
> * Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> On 10/5/15 3:14 PM, Daniel Borkmann wrote:
>>> One scenario that comes to mind ... what happens when there are kernel
>>> pointers stored in skb->cb[] (either from the current layer or an old
>>> one from a different layer that the skb went through previously, but
>>> which did not get overwritten)?
>>>
>>> Socket filters could read a portion of skb->cb[] also when unprived and
>>> leak that out through maps. I think the verifier doesn't catch that,
>>> right?
>>
>> grrr. indeed. previous layer before sk_filter() can leave junk in there.
>
> Could this be solved by activating zeroing/sanitizing of this data if there's an
> active BPF function around that can access that socket?

I think this check could only be done in sk_filter() for testing these
conditions (unprivileged user + access to cb area), so it would need to
happen from outside a native eBPF program. :/ Also classic BPF would
then need to test for it, since a socket filter doesn't really know
whether native eBPF is loaded there or a classic-to-eBPF transformed one,
and classic never makes use of this. Anyway, it could be done by adding
a bit flag cb_access:1 to the bpf_prog, set it during eBPF verification
phase, and test it inside sk_filter() if I see it correctly.

The reason is that this sanitizing must only be done in the 'top-level'
program that is run from sk_filter() _directly_, because a user at any
time could decide to put an already loaded eBPF fd into a tail call map.
And cb[] is then used to pass args/state around between two programs,
thus it cannot be unconditionally cleared from within the program. The
association to a socket filter (SO_ATTACH_BPF) happens at a later time
after a native eBPF program has already been loaded via bpf(2).

Thanks,
Daniel
