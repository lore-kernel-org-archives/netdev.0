From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Sun, 31 Jul 2016 08:25:12 -0700
Message-ID: <CALDO+SaVhA4GB+=-LnbZpWyx15wgc8PRFXVD4dO-O5kb+hJE9g@mail.gmail.com>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
 <20160729064722.GA54517@ast-mbp.thefacebook.com> <579B0B9F.8040805@iogearbox.net>
 <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com>
 <579BF2A1.7000709@iogearbox.net> <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
 <20160730053415.GA78880@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33457 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbcGaP0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 11:26:41 -0400
Received: by mail-it0-f65.google.com with SMTP id d65so10319906ith.0
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2016 08:25:52 -0700 (PDT)
In-Reply-To: <20160730053415.GA78880@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> >>    num_possible_cpu == 64
>> >>    num_online_cpu == 2 == sysconf(_SC_NPROCESSORS_CONF)
> ...
>> >> To fix it, I could either
>> >> 1). declare values array based on num_possible_cpu in test_map.c,
>> >>    long values[64];
>> >> or 2) in kernel, only copying 8*2 = 16 byte from kernel to user.
> ...
>> Since percpu array adds variable length of data passing between kernel
>> and userspace, I wonder if we should add a 'value_len' field in 'union
>> bpf_attr' so kernel knows how much data to copy to user?
>
> I think the first step is to figure out why num_possible is 64,
> since it hurts all per-cpu allocations. If it is a widespread issue,
> it hurts a lot of VMs.
> Hopefully it's not the case, since in my kvm setup num_possible==num_online
> qemu version 2.4.0
> booting with -enable-kvm -smp N
>
Thanks. I'm using VMware Fusion with 2 vcpu, running Fedora 23.

I tried on my another physical machine (Xeon E3), indeed
"num_possible==num_online". In fact, num_online shouldn't be an issue.
As long as num_possible == sysconf(SC_NPROCESSORS_CONF), then kernel
and user are consistent about the size of data copied.

Diving into more details:
when calling sysconf(_SC_NPROCESSORS_CONF), strace shows that it does
"open("/sys/devices/system/cpu",
O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
And in my /sys/devices/system/cpu, I have cpu0 and cpu1,
kernel_max = 63
possible = 0-63
present = 0-1

So sysconf simply reads these entries configured by kernel. Looking at
kernel code, "arch/x86/configs/x86_64_defconfig" sets
CONFIG_NR_CPUS=64, and later on set_cpu_possible() is called at
arch/x86/kernel/smpboot.c, which parses the ACPI multiprocessor table
and configured new value. Based on these observations, I think
different hypervisor may have different ways of emulating ACPI
processor table or BIOS implementation thus these values differ.

Regards,
William
