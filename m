From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: add missing rcu protection when releasing
 programs from prog_array
Date: Fri, 29 May 2015 16:22:43 -0700
Message-ID: <5568F4C3.5010007@plumgrid.com>
References: <1432866362-8154-1-git-send-email-ast@plumgrid.com> <55682D1C.3070607@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36679 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbbE2XWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 19:22:45 -0400
Received: by pacux9 with SMTP id ux9so28594836pac.3
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 16:22:45 -0700 (PDT)
In-Reply-To: <55682D1C.3070607@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/29/15 2:10 AM, Daniel Borkmann wrote:
>>
>> +static void __prog_put_rcu(struct rcu_head *rcu)
>> +{
>> +    struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux,
>> rcu);
>> +
>> +    free_used_maps(aux);
>> +    bpf_prog_free(aux->prog);
>
> Not sure if it's worth it to move these two into a common helper shared
> with bpf_prog_put()? Probably only in case that code should get further
> extended.

I though about it too, but my recent re-reading of net/core/filter.c
taught me otherwise. We have too many tiny helper functions that
are hiding meaning instead of helping.
Like instead of having two pieces of the code:
do1(); do2(); do3(); and do1(); do2();
if we introduce a helper foo() { do1(); do2(); } and the code will do:
foo(), do3() and foo()
when the helper is close enough to invocation it's still easy to read,
but overtime the whole thing, imo, will become a mess. For example,
we have prog_release, prog_free, filter_release and all combinations
with and without __ prefix and _rcu suffix.
I think some of this stuff should be 'unhelpered'.
Like __sk_filter_release() and __bpf_prog_release() should be removed.
Of course, it's a grey line when to introduce a helper and when not to,
but just because two lines are close enough between two functions it
doesn't mean that helper is warranted. In this bpf_prog_put() case
I think helper is not needed _today_. If it grows, we'll reconsider.
