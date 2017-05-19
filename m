From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Thu, 18 May 2017 18:22:40 -0700
Message-ID: <17a1c4a2-68d7-0f8f-f009-b97706d67ceb@fb.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <97910214-213c-c5c6-4a02-adc16cd836aa@fb.com>
 <c8e4ce49-5707-3d6d-c8c2-80dd8335d981@solarflare.com>
 <739ef342-728c-de57-c2a2-03fa85b3a246@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>,
        David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46511 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755832AbdESBXQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 21:23:16 -0400
In-Reply-To: <739ef342-728c-de57-c2a2-03fa85b3a246@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/18/17 9:38 AM, Edward Cree wrote:
> On 18/05/17 15:49, Edward Cree wrote:
>> Here's one idea that seemed to work when I did a couple of experiments:
>> let A = (a;am), B = (b;bm) where the m are the masks
>> Σ = am + bm + a + b
>> χ = Σ ^ (a + b) /* unknown carries */
>> μ = χ | am | bm /* mask of result */
>> then A + B = ((a + b) & ~μ; μ)
>>
>> The idea is that we find which bits change between the case "all x are
>>  1" and "all x are 0", and those become xs too.

 > https://gist.github.com/ecree-solarflare/0665d5b46c2d8d08de2377fbd527de8d

I played with it quite a bit trying to break it and have to
agree that the above algorithm works.
At least for add and sub I think it's solid.
Still feels a bit magical, since it gave me better results
than I could envision for my test vectors.

In your .py I'd only change __str__(self) to print them in mask,value
as the order they're passed into constructor to make it easier to read.
The bin(self) output is the most useful, of course.
We should carry it into the kernel too for debugging.

> And now I've found a similar algorithm for subtraction, which (again) I
>  can't prove but it seems to work.
> α = a + am - b
> β = a - b - bm
> χ = α ^ β
> μ = χ | α | β
> then A - B = ((a - b) & ~μ; μ)
> Again we're effectively finding the max. and min. values, and XORing
>  them to find unknown carries.
>
> Bitwise operations are easy, of course;
> /* By assumption, a & am == b & bm == 0 */
> A & B = (a & b; (a | am) & (b | bm) & ~(a & b))
> A | B = (a | b; (am | bm) & ~(a | b))
> /* It bothers me that & and | aren't symmetric, but I can't fix it */
> A ^ B = (a ^ b; am | bm)
>
> as are shifts by a constant (just shift 0s into both number and mask).
>
> Multiplication by a constant can be done by decomposing into shifts
>  and adds; but it can also be done directly; here we find (a;am) * k.
> π = a * k
> γ = am * k
> then A * k = (π; 0) + (0; γ), for which we use our addition algo.
>
> Multiplication of two unknown values is a nightmare, as unknown bits
>  can propagate all over the place.  We can do a shift-add
>  decomposition where the adds for unknown bits have all the 1s in
>  the addend replaced with xs.  A few experiments suggest that this
>  works, regardless of the order of operands.  For instance
>  110x * x01 comes out as either
>     110x
> + xx0x
> = xxxx0x
> or
>      x0x
>    x01
> + x01
> = xxxx0x
> We can slightly optimise this by handling all the 1 bits in one go;
>  that is, for (a;am) * (b;bm) we first find (a;am) * b using our
>  multiplication-by-a-constant algo above, then for each bit in bm
>  we find (a;am) * bit and force all its nonzero bits to unknown;
>  finally we add all our components.

this mul algo I don't completely understand. It feels correct,
but I'm not sure we really need it for the kernel.
For all practical cases llvm will likely emit shifts or sequence
of adds and shifts, so multiplies by crazy non-optimizable constant
or variable are rare and likely the end result is going to be
outside of packet boundary, so it will be rejected anyway and
precise alignment tracking doesn't matter much.
What I love about the whole thing that it works for access into
packet, access into map values and in the future for any other
variable length access.

> Don't even ask about division; that scrambles bits so hard that the

yeah screw div and mod. We have an option to disable div/mod altogether
under some new 'prog_flags', since it has this ugly 'div by 0'
exception path. We don't even have 'signed division' instruction and
llvm errors like:
     errs() << "Unsupport signed division for DAG: ";
     errs() << "Please convert to unsigned div/mod.\n";
and no one complained. It just means that division is extremely rare.

Are you planning to work on the kernel patch for this algo?
Once we have it the verifier will be smarter regarding
alignment tracking than any compiler i know :)
