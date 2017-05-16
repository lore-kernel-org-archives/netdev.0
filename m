From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Tue, 16 May 2017 15:53:06 -0700
Message-ID: <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>,
        David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43626 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751342AbdEPWxf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 18:53:35 -0400
In-Reply-To: <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/17 5:37 AM, Edward Cree wrote:
> On 15/05/17 17:04, David Miller wrote:
>> If we use 1<<31, then sequences like:
>>
>> 	R1 = 0
>> 	R1 <<= 2
>>
>> do silly things.
> Hmm.  It might be a bit late for this, but I wonder if, instead of handling
>  alignments as (1 << align), you could store them as -(1 << align), i.e.
>  leading 1s followed by 'align' 0s.
> Now the alignment of 0 is 0 (really 1 << 32), which doesn't change when
>  left-shifted some more.  Shifts of other numbers' alignments also do the
>  right thing, e.g. align(6) << 2 = (-2) << 2 = -8 = align(6 << 2).  Of
>  course you do all this in unsigned, to make sure right shifts work.
> This also makes other arithmetic simple to track; for instance, align(a + b)
>  is at worst align(a) | align(b).  (Of course, this bound isn't tight.)
> A number is 2^(n+1)-aligned if the 2^n bit of its alignment is cleared.
> Considered as unsigned numbers, smaller values are stricter alignments.

following this line of thinking it feels that it should be possible
to get rid of 'aux_off' and 'aux_off_align' and simplify the code.
I mean we can always do
dst_reg->min_align = min(dst_reg->min_align, src_reg->min_align);

and don't use 'off' as part of alignment checks at all.
So this bit:
if ((ip_align + reg_off + off) % size != 0) {
can be removed
and replaced with
a = alignof(ip_align)
a = min(a, reg->align)
if (a % size != 0)
and do this check always and not only after if (reg->id)

In check_packet_ptr_add():
- if (had_id)
-  dst_reg->aux_off_align = min(dst_reg->aux_off_align,
-                               src_reg->min_align);
- else
-  dst_reg->aux_off_align = src_reg->min_align;

+ if (had_id)
+  dst_reg->min_align = min(dst_reg->min_align, src_reg->min_align);
+ else
+  dst_reg->min_align = src_reg->min_align;

in that sense packet_ptr_add() will be no different than
align logic we do in adjust_reg_min_max_vals()

Thoughts?
