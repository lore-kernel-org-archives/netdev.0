From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Wed, 3 May 2017 20:30:22 -0700
Message-ID: <d809baa4-c864-af99-38af-fbcb6637ca2b@fb.com>
References: <20170503.095251.353611409224180200.davem@davemloft.net>
 <20170503.120634.1673036085707133455.davem@davemloft.net>
 <6a5fa930-cb76-8eee-94c7-7c5fe8fb8cdc@fb.com>
 <20170503.133512.310640909764585408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44576 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932588AbdEDDaq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 23:30:46 -0400
In-Reply-To: <20170503.133512.310640909764585408.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 10:35 AM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Wed, 3 May 2017 09:54:42 -0700
>
>> /usr/include/asm/types.h -> asm-generic/int-ll64.h
>> as far as I can see that should be the same on most archs.
>> Why doesn't it work for sparc?
>
> You can't assume anything about the kernel headers installed,
> on my debian Sparc box /usr/include/asm/types.h is below.
>
> They do things this way to facilitate multiarch building.  I think
> it's pretty reasonable.
>
> #ifndef _SPARC_TYPES_H
> #define _SPARC_TYPES_H
> /*
>  * This file is never included by application software unless
>  * explicitly requested (e.g., via linux/types.h) in which case the
>  * application is Linux specific so (user-) name space pollution is
>  * not a major issue.  However, for interoperability, libraries still
>  * need to be careful to avoid a name clashes.
>  */
>
> #if defined(__sparc__)
>
> #include <asm-generic/int-ll64.h>
>
> #ifndef __ASSEMBLY__
>
> typedef unsigned short umode_t;
>
> #endif /* __ASSEMBLY__ */
>
> #endif /* defined(__sparc__) */

if it was something like
#ifdef __sparc__
...
#else
#include_next <asm/types.h>

I would buy that debian folks indeed care about multi-arch, but
what above does is making #include <linux/types.h> to be a nop
for any cross-compiler on sparc that included it.
Which is probably quite painful to debug as we found out.
You're right that we cannot assume much about /usr/include craziness.
In that sense adding __native_arch__ macro is also wrong, since
it assumes sane /usr/include without inline asm or other things
that clang for bpf arch can consume.
In that sense the only way to be independent from arch dependent
things in /usr/include is to put all arch specific headers
into our own dir in tools/selftests/ (or may be tools/bpf/include)
and point clang to that. I think the list of .h in there will be
limited. Only things like linux/types.h and gnu/stubs.h,
so it will be manageable.
Thoughts?
