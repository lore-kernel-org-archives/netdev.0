From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next] filter: add bpf_optimize_div()
Date: Fri, 21 Nov 2014 13:22:03 +0400
Message-ID: <CAOJe8K13=RXfUccVqLk-73-STJC9b2n5OL=ZRwySeOCtVmi6kw@mail.gmail.com>
References: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org>
	<CAMEtUuw1q_=CuZOHqd1WDd8ZE+bo-CNsbQ4rFPgRRVy7H1Q4uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:46103 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaKUJWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 04:22:05 -0500
Received: by mail-yk0-f181.google.com with SMTP id 142so2086561ykq.40
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 01:22:03 -0800 (PST)
In-Reply-To: <CAMEtUuw1q_=CuZOHqd1WDd8ZE+bo-CNsbQ4rFPgRRVy7H1Q4uA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/14, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Thu, Nov 20, 2014 at 11:42 AM, Denis Kirjanov <kda@linux-powerpc.org>
> wrote:
>> optimize_div() found in  mips bpf jit is really usefull
>> for other arches. So let's put it in filter.h
>>
>> CC: Alexei Starovoitov <ast@plumgrid.com>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> ---
>>  include/linux/filter.h | 11 +++++++++++
>>  1 file changed, 11 insertions(+)
>>
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index ca95abd..b385637 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> +
>> +static inline int bpf_optimize_div(u32 *k)
>
> 'inline' is unnecessary
>
>> +{
>> +       /* power of 2 divides can be implemented with right shift */
>> +       if (!(*k & (*k-1))) {
>> +               *k = ilog2(*k);
>> +               return 1;
>> +       }
>> +
>> +       return 0;
>> +}
>
> I don't think it makes sense to add a helper function
> without first user. If you really want to use it
> in ppc, make this change as part of the series.
> In the 1st patch move it out of mips and use it in
> mips jit and 2nd patch use it in ppc.

Heh, actually we already have it: is_power_of_2()

>
> Also since you mentioned mips...
> if (k == 1 || optimize_div(&k)) {
>   ctx->flags |= SEEN_A;
>   emit_jit_reg_move(r_A, r_zero, ctx);
> this is definitely wrong in there.
>
I'll check it

> Also with such helper function we'd need to be
> careful not to modify 'k' in place, otherwise
> multi-pass jit algorithm would be broken.
>
> In general I don't think such optimizations
> belong in kernel at all. User space should be doing this.
>
