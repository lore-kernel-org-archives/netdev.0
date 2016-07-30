From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Fri, 29 Jul 2016 22:23:06 -0700
Message-ID: <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
 <20160729064722.GA54517@ast-mbp.thefacebook.com> <579B0B9F.8040805@iogearbox.net>
 <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com> <579BF2A1.7000709@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33147 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcG3FXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 01:23:47 -0400
Received: by mail-io0-f195.google.com with SMTP id y195so10991126iod.0
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 22:23:46 -0700 (PDT)
In-Reply-To: <579BF2A1.7000709@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2016 at 5:19 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 07/29/2016 10:03 PM, William Tu wrote:
>>
>> Hi Daniel and Alexei,
>>
>> Thanks for the reply. My apology for too brief description. In short,
>> in my environment, running samples/bpf/test_map always segfault under
>> percpu array/hash map operations. I think it's due to stack
>> corruption.
>>
>> I'm not using ARM. It's x86 in a VM with 2 vcpu. By printk() in kernel, I
>> got
>>    num_possible_cpu == 64
>>    num_online_cpu == 2 == sysconf(_SC_NPROCESSORS_CONF)
>
>
> Ok, thanks for the data!
>
>> So at samples/bpf/test_maps.c, test_percpu_arraymap_sanity(),
>> we define:
>>    long values[nr_cpus]; //nr_cpus=2
>>
>>    ... // create map and update map ...
>>
>>    /* check that key=0 is also found and zero initialized */
>>    assert(bpf_lookup_elem(map_fd, &key, values) == 0 &&
>>              values[0] == 0 && values[nr_cpus - 1] == 0);
>>
>> Here we enter the bpf syscall, calls into kernel "map_lookup_elem()"
>> and we calculate:
>>    value_size = round_up(map->value_size, 8) * num_possible_cpus();
>>    // which in my case 8 * 64 = 512
>>    ...
>>    // then copy to user, which writes 512B to the "values[nr_cpus]" on
>> stack
>>    if (copy_to_user(uvalue, value, value_size) != 0)
>>
>> And I think this 512B write to userspace corrupts the userspace stack
>> and causes a coredump. After bpf_lookup_elem() calls, gdb shows
>> 'values' points to memory address 0x0.
>>
>> To fix it, I could either
>> 1). declare values array based on num_possible_cpu in test_map.c,
>>    long values[64];
>> or 2) in kernel, only copying 8*2 = 16 byte from kernel to user.
>
>
> But I think the patch of using num_online_cpus() would also not be correct
> in the sense that f.e. your application could alloc an array at time X
> where map lookup at time Y would not fit to the expectations anymore due
> to CPU hotplugging (since apparently _SC_NPROCESSORS_CONF maps to online
> CPUs in some cases). So also there you could potentially corrupt your
> application or mem allocator in user space, or not all your valid data
> might get copied, hmm.
>
Yes, you're right. CPU hotplugging might cause the same issue.

Since percpu array adds variable length of data passing between kernel
and userspace, I wonder if we should add a 'value_len' field in 'union
bpf_attr' so kernel knows how much data to copy to user?

Regards,
William
