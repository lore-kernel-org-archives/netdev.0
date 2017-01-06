From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v1 1/2] bpf: add a longest prefix match trie map
 implementation
Date: Fri, 6 Jan 2017 11:59:01 -0800
Message-ID: <586FF705.9080003@fb.com>
References: <20161229172855.14910-1-daniel@zonque.org>
 <20161229172855.14910-2-daniel@zonque.org> <586E7366.1010708@iogearbox.net>
 <586EA627.6020404@iogearbox.net>
 <2edd2b2b-a89e-0df0-c1dc-fdaee2315597@zonque.org>
 <586F74C9.3020305@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dh.herrmann@gmail.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41266 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750972AbdAFT7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:59:38 -0500
In-Reply-To: <586F74C9.3020305@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/6/17 2:43 AM, Daniel Borkmann wrote:
> On 01/05/2017 09:14 PM, Daniel Mack wrote:
> [...]
>> In my use case, the actual value of a node is in fact ignored, all that
>> matters is whether a node exists in a trie or not. The test code uses
>> u64 for its tests.
>>
>> I can change it around so that the value size can be defined by
>> userspace, but ideally it would also support 0-byte lengths then. The
>> bpf map syscall handler should handle the latter just fine if I read the
>> code correctly?
>
> Right now no map is allowed to have value size of 0, but since kmalloc()
> would return ZERO_SIZE_PTR in such case, it looks like it should
> work^tm, although I haven't checked whether it's guaranteed that all
> the copy_{from,to}_user() implementations work with 0 size as well
> and whether ubsan would complain on the ZERO_SIZE_PTR for memcpy() etc.
> Perhaps better to reject value size of 0 initially and later on follow
> up with making the syscall code more robust for such cases (afaik, for
> the htab this was also on todo.)?

yes. the support for value_size=0 was on todo list pretty much as
soon as htab was introduced and early on the verifier was done the way
to make sure such case should work as-is from bpf program point of view,
but for syscall lookup/update commands I didn't want to add checks
for zero value until it's actually needed. So definitely some work
around syscall handling is needed.
Also agree that for lpm I would check value_size > 0 initially and
then relax it for hash and lpm together.
