From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net v2] bpf: disallow arithmetic operations on context
 pointer
Date: Tue, 17 Oct 2017 11:14:47 +0100
Message-ID: <2fa32a00-cfd3-8e67-2236-745a062d884c@solarflare.com>
References: <20171016181655.16366-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <oss-drivers@netronome.com>, <alexei.starovoitov@gmail.com>,
        <daniel@iogearbox.net>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([148.163.129.52]:54158 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757559AbdJQKOx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 06:14:53 -0400
In-Reply-To: <20171016181655.16366-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/10/17 19:16, Jakub Kicinski wrote:
> Commit f1174f77b50c ("bpf/verifier: rework value tracking")
> removed the crafty selection of which pointer types are
> allowed to be modified.  This is OK for most pointer types
> since adjust_ptr_min_max_vals() will catch operations on
> immutable pointers.  One exception is PTR_TO_CTX which is
> now allowed to be offseted freely.
>
> The intent of aforementioned commit was to allow context
> access via modified registers.  The offset passed to
> ->is_valid_access() verifier callback has been adjusted
> by the value of the variable offset.
>
> What is missing, however, is taking the variable offset
> into account when the context register is used.  Or in terms
> of the code adding the offset to the value passed to the
> ->convert_ctx_access() callback.  This leads to the following
> eBPF user code:
>
>      r1 += 68
>      r0 = *(u32 *)(r1 + 8)
>      exit
>
> being translated to this in kernel space:
>
>    0: (07) r1 += 68
>    1: (61) r0 = *(u32 *)(r1 +180)
>    2: (95) exit
>
> Offset 8 is corresponding to 180 in the kernel, but offset
> 76 is valid too.  Verifier will "accept" access to offset
> 68+8=76 but then "convert" access to offset 8 as 180.
> Effective access to offset 248 is beyond the kernel context.
> (This is a __sk_buff example on a debug-heavy kernel -
> packet mark is 8 -> 180, 76 would be data.)
>
> Dereferencing the modified context pointer is not as easy
> as dereferencing other types, because we have to translate
> the access to reading a field in kernel structures which is
> usually at a different offset and often of a different size.
> To allow modifying the pointer we would have to make sure
> that given eBPF instruction will always access the same
> field or the fields accessed are "compatible" in terms of
> offset and size...
>
> Disallow dereferencing modified context pointers and add
> to selftests the test case described here.
>
> Fixes: f1174f77b50c ("bpf/verifier: rework value tracking")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> Dave, a merge note - in net-next this will need env to be passed
> to verbose().
>
> v2:
>  - spell dereference correctly.
>
>  kernel/bpf/verifier.c                       |  8 ++++++--
>  tools/testing/selftests/bpf/test_verifier.c | 14 ++++++++++++++
>  2 files changed, 20 insertions(+), 2 deletions(-)
Acked-by: Edward Cree <ecree@solarflare.com>
