From: William Tu <u9012063@gmail.com>
Subject: Re: [RFC PATCH net-next] bpf: fix potential percpu map overcopy to user.
Date: Tue, 18 Oct 2016 22:31:13 -0700
Message-ID: <CALDO+SaebqahYHn2PU=nk6mYOMjRp+F8PKb3cFaGMv4_xjLwZg@mail.gmail.com>
References: <1476636088-9268-1-git-send-email-u9012063@gmail.com> <20161019005004.GA87961@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34700 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbcJSFby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 01:31:54 -0400
Received: by mail-io0-f194.google.com with SMTP id f5so1022650ioj.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 22:31:54 -0700 (PDT)
In-Reply-To: <20161019005004.GA87961@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ...
>> -     if (copy_to_user(uvalue, value, value_size) != 0)
>> +     if (copy_to_user(uvalue, value, min_t(u32, usize, value_size)) != 0)
>>               goto free_value;
>
> I think such approach won't actually fix anything. User space
> may lose some of the values and won't have any idea what was lost.
> I think we need to fix sample code to avoid using sysconf(_SC_NPROCESSORS_CONF)
> and use /sys/devices/system/cpu/possible instead.
> I would argue that glibc should be fixed as well since relying on
> ls -d /sys/devices/system/cpu/cpu[0-9]*|wc -l turned out to be incorrect.
>

Thanks for the feedback. I think glibc is correct. The
_SC_NPROCESSORS_CONF presents the number of processors
configured/populated and is indeed "ls
/sys/devices/system/cpu/cpu[0-9]*|wc -l". This means the actual number
of CPUs installed on your system. On the other hand, the
num_possible_cpus() includes both the installed CPUs and the empty CPU
socket/slot, in order to support CPU hotplug.

As a example, one of my dual socket motherboard with 1 CPU installed has
# /sys/devices/system/cpu/possible
0-239
# /sys/devices/system/cpu/cpu[0-9]*|wc -l
12
Note that these 12 cpus could be online/offline by
# echo 1/0 > /sys/devices/system/cpu/cpuX/online
Even if it is offline, the entry is still there.

Thinking about another solution, maybe we should use
"num_present_cpus()" which means the configured/populated CPUs and the
value is the same as sysconf(_SC_NPROCESSORS_CONF). Consider:
1) cpuX is online/offline: the num_present_cpus() remains the same.
2) new cpu is hotplug into the empty socket: the num_present_cpus()
gets updates, and also the sysconf(_SC_NPROCESSORS_CONF).

+++ b/kernel/bpf/syscall.c
@@ -297,7 +297,7 @@ static int map_lookup_elem(union bpf_attr *attr)

        if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH ||
            map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
-               value_size = round_up(map->value_size, 8) * num_possible_cpus();
+               value_size = round_up(map->value_size, 8) * num_present_cpus();
        else
                value_size = map->value_size;

Thanks. Regards,
William
