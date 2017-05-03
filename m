From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Wed, 3 May 2017 09:54:42 -0700
Message-ID: <6a5fa930-cb76-8eee-94c7-7c5fe8fb8cdc@fb.com>
References: <20170503041443.3125777-1-ast@fb.com>
 <20170503.095251.353611409224180200.davem@davemloft.net>
 <20170503.120634.1673036085707133455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56702 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751394AbdECQzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 12:55:06 -0400
In-Reply-To: <20170503.120634.1673036085707133455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 9:06 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 03 May 2017 09:52:51 -0400 (EDT)
>
>> From: Alexei Starovoitov <ast@fb.com>
>> Date: Tue, 2 May 2017 21:14:43 -0700
>>
>>> -D__x86_64__ workaround was used to make /usr/include/features.h
>>> to follow expected path through the system include headers.
>>> This is not portable.
>>> Instead define dummy stubs.h which is used by 'clang -target bpf'
>>>
>>> Fixes: 6882804c916b ("selftests/bpf: add a test for overlapping packet range checks")
>>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>>
>> Applied, thanks for getting rid of this wart.
>
> Actually, we're now back to the orignal problem I had on sparc.
>
> The issue is that you cannot resolve the core kernel __u?? types
> unless __sparc__ is properly defined.
>
> In file included from /home/davem/src/GIT/net/tools/testing/selftests/bpf/test_pkt_access.c:8:
> In file included from ../../../include/uapi/linux/bpf.h:10:
> /usr/include/linux/types.h:27:9: error: unknown type name '__u16'
> typedef __u16 __bitwise __le16;
>         ^
>
> We really have to do the change I mentioned the first time I brought
> up this issue, which is to get this via a variable set in the
> per-arch top-level Makefile

I'd really like to avoid depending on kernel configuration.
This bit:
GENDIR := ../../../../include/generated
GENHDR := $(GENDIR)/autoconf.h
is already ugly, since it doesn't work in setups that build 
out-of-source like ours.

As far as I can see
test_pkt_access.c:8 ->
tools/include/uapi/linux/bpf.h:10 ->
tools/include/linux/types.h:9 ->
/usr/include/asm/types.h -> asm-generic/int-ll64.h
as far as I can see that should be the same on most archs.
Why doesn't it work for sparc?

We can also copy paste include/uapi/asm-generic/int-ll64.h to
bpf/asm/types.h or something.
Since here we're compiling for bpf architecture adding
__x86_64__ or __sparc__ or __whatever_native_arch_here__ is incorrect.
It really should be bpf's arch types.h
Inside of it we can use '#ifdef __BPF__' to be more accurate which
is builtin macro for clang.
