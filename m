From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Tue, 22 Apr 2014 21:59:32 -0700
Message-ID: <CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<20140422.235745.1219194947074686642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:45172 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbaDWE7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 00:59:33 -0400
Received: by mail-we0-f169.google.com with SMTP id w62so345978wes.14
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 21:59:32 -0700 (PDT)
In-Reply-To: <20140422.235745.1219194947074686642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 22, 2014 at 8:57 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue, 22 Apr 2014 20:18:57 -0700
>
>> exisiting BPF verifier allows uninitialized access to registers,
>> 'ret A' is considered to be a valid filter.
>> So initialize A and X to zero to prevent leaking kernel memory
>> In the future BPF verifier will be rejecting such filters
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Has the code always been like this?

the previous interpreter had:
unsigned int sk_run_filter(const struct sk_buff *skb,
                           const struct sock_filter *fentry)
{
        void *ptr;
        u32 A = 0;                      /* Accumulator */
        u32 X = 0;                      /* Index Register */
...
so it wasn't affected.

> Did the eBPF changes introduce this problem either directly or
> indirectly?

this bug is an oversight on my side.
I believe in the net-next it should be fixed by making verifier smarter
instead of wasting run time cycles to initialize regs.
For now the same fix is needed for both net and net-next.
We can remove extra assignments when verifier becomes smarter.
ebpf verifier that I posted earlier had checks for uninitialized regs and stack.
I missed lack of uninit regs part in classic verifier when ebpf verifier and jit
were dropped from the patch set.
Sorry about this slip.
