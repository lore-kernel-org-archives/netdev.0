From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net v2] selftests/bpf: fix broken build due to types.h
Date: Wed, 17 May 2017 17:46:14 -0700
Message-ID: <78eb5911-d001-d27a-18ef-86d47aa2f2ff@fb.com>
References: <20170517221805.1593973-1-yhs@fb.com>
 <591CD540.1040305@iogearbox.net>
 <20170517.190149.1446382466519323776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43969 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752971AbdERAqk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 20:46:40 -0400
In-Reply-To: <20170517.190149.1446382466519323776.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/17/17 4:01 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Thu, 18 May 2017 00:57:04 +0200
> 
>> On 05/18/2017 12:18 AM, Yonghong Song wrote:
>>> Commit 0a5539f66133 ("bpf: Provide a linux/types.h override
>>> for bpf selftests.") caused a build failure for
>>> tools/testing/selftest/bpf
>>> because of some missing types:
>>>       $ make -C tools/testing/selftests/bpf/
>>>       ...
>>>       In file included from
>>>       /home/yhs/work/net-next/tools/testing/selftests/bpf/test_pkt_access.c:8:
>>>       ../../../include/uapi/linux/bpf.h:170:3: error: unknown type name
>>>       '__aligned_u64'
>>>                       __aligned_u64   key;
>>>       ...
>>>       /usr/include/linux/swab.h:160:8: error: unknown type name
>>>       '__always_inline'
>>>       static __always_inline __u16 __swab16p(const __u16 *p)
>>>       ...
>>> The type __aligned_u64 is defined in linux:include/uapi/linux/types.h.
>>>
>>> The fix is to copy missing type definition into
>>> tools/testing/selftests/bpf/include/uapi/linux/types.h.
>>> Adding additional include "string.h" resolves __always_inline issue.
>>>
>>> Fixes: 0a5539f66133 ("bpf: Provide a linux/types.h override for bpf
>>> selftests.")
>>> Signed-off-by: Yonghong Song <yhs@fb.com>
>>
>> Can you elaborate why string.h specifically? Can't we define the
>> __always_inline ourselves?
> 
> That way it comes from compiler.h

Just a little bit correction. The __always_inline is not from 
compiler.h. The compiler.h is inside kernel source tree. Currently,
programs in selftests do not directly referencing kernel header
files (except test_verifier trying to do with alignment)

======
#ifdef HAVE_GENHDR
# include "autoconf.h"
#else
# if defined(__i386) || defined(__x86_64) || defined(__s390x__) || 
defined(__aarch64__)
#  define CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS 1
# endif
#endif
=====
(The above part may be gone soon with recent alignment tracking patch)

[yhs@localhost include]$ pwd
/usr/include
[yhs@localhost include]$ find . -name "compiler.h"
[yhs@localhost include]$

The __always_inline comes from sys/cdefs.h
sys/cdefs.h:# define __always_inline __inline __attribute__ 
((__always_inline))

The following is the include chain leading to __always_inline:
string.h
    features.h
       sys/cdefs.h

Yes, it is deeply embedded in chain of header files and hard
to figure out intuitively....

Yonghong

> 
> Probably it would have been better to have the BPF linux/types.h bring
> it in.
> 
> Sorry I applied this so quickly, I wanted this regression fixed as fast
> as possible.
> 
