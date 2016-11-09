From: Josef Bacik <jbacik@fb.com>
Subject: Re: 484611357c19 introduces arbitrary kernel write bug (root-only)
Date: Tue, 8 Nov 2016 21:02:53 -0500
Message-ID: <d3c60ae6-7c48-7735-eabd-014d3ece7845@fb.com>
References: <CAG48ez0mP4xwv6vnKRJ+rcdXYyA1wGnCWsbkKUgWGSBbMtgFMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <security@kernel.org>, <netdev@vger.kernel.org>
To: Jann Horn <jannh@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58203 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751316AbcKICDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 21:03:18 -0500
In-Reply-To: <CAG48ez0mP4xwv6vnKRJ+rcdXYyA1wGnCWsbkKUgWGSBbMtgFMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2016 07:23 PM, Jann Horn wrote:
> In 484611357c19 (not in any stable kernel yet), functionality is
> introduced that allows root (and afaics nobody else, since nobody else
> is allowed to perform pointer arithmetic) to basically write to (and
> read from) arbitrary kernel memory. There are multiple bugs in the
> validation logic:
>
>  - A bitwise AND of values in the ranges [a,b] and [c,d] is assumed to
> always result in a value
>    >= a&b. However, for the combination of ranges [1,1] and [1,2],
> this calculates a minimum of 1
>    while actually, 1&2 is zero. This is the bug that my crasher
> (below) triggers.

Ugh crap.  I had this logic right before, but changed it to deal with the case 
of -value & -value which would make the min_value -value.  Instead if min and 
max are both positive then the min should be 0.  I'll fix this up and add a 
testcase, nice catch.

>  - a%b is assumed to always be smaller than b-1. However, for b==0,
> this will calculate an upper
>    limit of -1 while the values will actually always be zero.

Yup you're right.

>  - I'm not sure about this, but I think that, when only one end of the
> range is bounded, the logic will
>    incorrectly also treat the other end as a bounded, and because of
> the usage of bound
>    placeholders that are smaller than the actual maximum values, this
> could be used to perform
>    out-of-bounds accesses.

Yeah I think you're right, if we have register A min bounded at say 
REGISTER_MAX_VALUE, and then have register B not min bounded at all so we 
default to the REGISTER_MIN_VALUE we and did a add we could end up thinking the 
minimum was 0, when it could be anything.  I'll fix this as well.

Thanks for looking at all this, I'll get this fixed up in the morning with test 
cases and send it out,

Josef
