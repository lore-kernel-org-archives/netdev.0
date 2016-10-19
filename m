From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next] bpf: fix potential percpu map overcopy to
 user.
Date: Wed, 19 Oct 2016 12:05:53 +0200
Message-ID: <58074581.1000601@iogearbox.net>
References: <1476636088-9268-1-git-send-email-u9012063@gmail.com> <20161019005004.GA87961@ast-mbp.thefacebook.com> <CALDO+SaebqahYHn2PU=nk6mYOMjRp+F8PKb3cFaGMv4_xjLwZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33755 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944286AbcJSPRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:17:32 -0400
In-Reply-To: <CALDO+SaebqahYHn2PU=nk6mYOMjRp+F8PKb3cFaGMv4_xjLwZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2016 07:31 AM, William Tu wrote:
>> ...
>>> -     if (copy_to_user(uvalue, value, value_size) != 0)
>>> +     if (copy_to_user(uvalue, value, min_t(u32, usize, value_size)) != 0)
>>>                goto free_value;
>>
>> I think such approach won't actually fix anything. User space
>> may lose some of the values and won't have any idea what was lost.
>> I think we need to fix sample code to avoid using sysconf(_SC_NPROCESSORS_CONF)
>> and use /sys/devices/system/cpu/possible instead.
>> I would argue that glibc should be fixed as well since relying on
>> ls -d /sys/devices/system/cpu/cpu[0-9]*|wc -l turned out to be incorrect.
>
> Thanks for the feedback. I think glibc is correct. The
> _SC_NPROCESSORS_CONF presents the number of processors
> configured/populated and is indeed "ls
> /sys/devices/system/cpu/cpu[0-9]*|wc -l". This means the actual number
> of CPUs installed on your system. On the other hand, the

In glibc __get_nprocs_conf() seems to try a number of things, first it
tries equivalent of /sys/devices/system/cpu/cpu[0-9]*|wc -l, if that fails,
depending on the config, it either tries to count cpus in /proc/cpuinfo,
or returns the _SC_NPROCESSORS_ONLN value instead. If /proc/cpuinfo has
some issue, it returns just 1 worst case. _SC_NPROCESSORS_ONLN will parse
/sys/devices/system/cpu/online, if that fails it looks into /proc/stat
for cpuX entries, and if also that fails for some reason, /proc/cpuinfo
is consulted (and returning 1 if unlikely all breaks down).

> num_possible_cpus() includes both the installed CPUs and the empty CPU
> socket/slot, in order to support CPU hotplug.

Correct.

> As a example, one of my dual socket motherboard with 1 CPU installed has
> # /sys/devices/system/cpu/possible
> 0-239
> # /sys/devices/system/cpu/cpu[0-9]*|wc -l
> 12
> Note that these 12 cpus could be online/offline by
> # echo 1/0 > /sys/devices/system/cpu/cpuX/online
> Even if it is offline, the entry is still there.
>
> Thinking about another solution, maybe we should use
> "num_present_cpus()" which means the configured/populated CPUs and the
> value is the same as sysconf(_SC_NPROCESSORS_CONF). Consider:
> 1) cpuX is online/offline: the num_present_cpus() remains the same.
> 2) new cpu is hotplug into the empty socket: the num_present_cpus()
> gets updates, and also the sysconf(_SC_NPROCESSORS_CONF).
>
> +++ b/kernel/bpf/syscall.c
> @@ -297,7 +297,7 @@ static int map_lookup_elem(union bpf_attr *attr)
>
>          if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH ||
>              map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
> -               value_size = round_up(map->value_size, 8) * num_possible_cpus();
> +               value_size = round_up(map->value_size, 8) * num_present_cpus();
>          else
>                  value_size = map->value_size;

But as you say in 2) that also has a chance of being racy on CPU hotplug
compared to num_possible_cpus() which is fixed at boot time.

Documentation/cputopology.txt +106 says /sys/devices/system/cpu/possible
outputs cpu_possible_mask. That is the same as in num_possible_cpus(), so
first step would be to fix the buggy example code, imho.

What perhaps could be done in a second step to reduce overhead is an option
for bpf(2) to pass in a cpu mask similarly as for sched_{get,set}affinity()
syscalls, where user space can construct a mask via CPU_SET(3). For the
syscall time, kernel would lock hot plugging via get_online_cpus() and
put_online_cpus(), it would check whether passed CPUs are online to query
and if so then it would copy the values into the user provided buffer. I'd
think this might be useful in a number of ways anyway.

Thanks,
Daniel
