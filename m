From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Fri, 29 Jul 2016 13:03:25 -0700
Message-ID: <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
 <20160729064722.GA54517@ast-mbp.thefacebook.com> <579B0B9F.8040805@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35700 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbcG2UEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 16:04:06 -0400
Received: by mail-io0-f194.google.com with SMTP id q83so10349618iod.2
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 13:04:05 -0700 (PDT)
In-Reply-To: <579B0B9F.8040805@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel and Alexei,

Thanks for the reply. My apology for too brief description. In short,
in my environment, running samples/bpf/test_map always segfault under
percpu array/hash map operations. I think it's due to stack
corruption.

I'm not using ARM. It's x86 in a VM with 2 vcpu. By printk() in kernel, I got
  num_possible_cpu == 64
  num_online_cpu == 2 == sysconf(_SC_NPROCESSORS_CONF)

So at samples/bpf/test_maps.c, test_percpu_arraymap_sanity(),
we define:
  long values[nr_cpus]; //nr_cpus=2

  ... // create map and update map ...

  /* check that key=0 is also found and zero initialized */
  assert(bpf_lookup_elem(map_fd, &key, values) == 0 &&
            values[0] == 0 && values[nr_cpus - 1] == 0);

Here we enter the bpf syscall, calls into kernel "map_lookup_elem()"
and we calculate:
  value_size = round_up(map->value_size, 8) * num_possible_cpus();
  // which in my case 8 * 64 = 512
  ...
  // then copy to user, which writes 512B to the "values[nr_cpus]" on stack
  if (copy_to_user(uvalue, value, value_size) != 0)

And I think this 512B write to userspace corrupts the userspace stack
and causes a coredump. After bpf_lookup_elem() calls, gdb shows
'values' points to memory address 0x0.

To fix it, I could either
1). declare values array based on num_possible_cpu in test_map.c,
  long values[64];
or 2) in kernel, only copying 8*2 = 16 byte from kernel to user.

Regards,
William


On Fri, Jul 29, 2016 at 12:54 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 07/29/2016 08:47 AM, Alexei Starovoitov wrote:
>>
>> On Thu, Jul 28, 2016 at 05:42:21PM -0700, William Tu wrote:
>>>
>>> The total size of value copy_to_user() writes to userspace should
>>> be the (current number of cpu) * (value size), instead of
>>> num_possible_cpus() * (value size).  Found by samples/bpf/test_maps.c,
>>> which always copies 512 byte to userspace, crashing the userspace
>>> program stack.
>>
>>
>> hmm. I'm missing something. The sample code assumes no cpu hutplug,
>> so sysconf(_SC_NPROCESSORS_CONF) == num_possible_cpu == num_online_cpu,
>> unless there is crazy INIT_ALL_POSSIBLE config option is used.
>
>
> Are you using ARM by chance? What is the count that you get in
> user space and from kernel side?
>
> http://lists.infradead.org/pipermail/linux-arm-kernel/2011-June/054177.html
