From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Mon, 1 Aug 2016 09:07:41 -0700
Message-ID: <20160801160738.GA99707@ast-mbp.thefacebook.com>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
 <20160729064722.GA54517@ast-mbp.thefacebook.com>
 <579B0B9F.8040805@iogearbox.net>
 <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com>
 <579BF2A1.7000709@iogearbox.net>
 <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
 <20160730053415.GA78880@ast-mbp.thefacebook.com>
 <CALDO+SaVhA4GB+=-LnbZpWyx15wgc8PRFXVD4dO-O5kb+hJE9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36669 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbcHAQId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 12:08:33 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so10154785pab.3
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2016 09:07:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALDO+SaVhA4GB+=-LnbZpWyx15wgc8PRFXVD4dO-O5kb+hJE9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 31, 2016 at 08:25:12AM -0700, William Tu wrote:
> >> >>    num_possible_cpu == 64
> >> >>    num_online_cpu == 2 == sysconf(_SC_NPROCESSORS_CONF)
> > ...
> >> >> To fix it, I could either
> >> >> 1). declare values array based on num_possible_cpu in test_map.c,
> >> >>    long values[64];
> >> >> or 2) in kernel, only copying 8*2 = 16 byte from kernel to user.
> > ...
> >> Since percpu array adds variable length of data passing between kernel
> >> and userspace, I wonder if we should add a 'value_len' field in 'union
> >> bpf_attr' so kernel knows how much data to copy to user?
> >
> > I think the first step is to figure out why num_possible is 64,
> > since it hurts all per-cpu allocations. If it is a widespread issue,
> > it hurts a lot of VMs.
> > Hopefully it's not the case, since in my kvm setup num_possible==num_online
> > qemu version 2.4.0
> > booting with -enable-kvm -smp N
> >
> Thanks. I'm using VMware Fusion with 2 vcpu, running Fedora 23.
> 
> I tried on my another physical machine (Xeon E3), indeed
> "num_possible==num_online". In fact, num_online shouldn't be an issue.
> As long as num_possible == sysconf(SC_NPROCESSORS_CONF), then kernel
> and user are consistent about the size of data copied.
> 
> Diving into more details:
> when calling sysconf(_SC_NPROCESSORS_CONF), strace shows that it does
> "open("/sys/devices/system/cpu",
> O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
> And in my /sys/devices/system/cpu, I have cpu0 and cpu1,
> kernel_max = 63
> possible = 0-63
> present = 0-1

glibc is doing
ls -d /sys/devices/system/cpu/cpu*
http://osxr.org:8080/glibc/source/sysdeps/unix/sysv/linux/getsysstats.c?v=glibc-2.14#0180
And /sys/devices/system/cpu/possible shows 0-63 while only two dirs 'cpu0' and 'cpu1'
are there?!
If my understanding of cpu_dev_register_generic() in drivers/base/cpu.c 
is correct the number of 'cpu*' dirs should be equal to possible_cpu.
Could you please debug why is that the case, because then it's probably
a bug on the kernel side.
I think it's correct for glibc to rely on the number of 'cpu*' dirs.
Did you boot with possible_cpus=64 command line arg by any chance?

> So sysconf simply reads these entries configured by kernel. Looking at
> kernel code, "arch/x86/configs/x86_64_defconfig" sets
> CONFIG_NR_CPUS=64, and later on set_cpu_possible() is called at
> arch/x86/kernel/smpboot.c, which parses the ACPI multiprocessor table
> and configured new value. Based on these observations, I think
> different hypervisor may have different ways of emulating ACPI
> processor table or BIOS implementation thus these values differ.

What behavior do you see in ESX ?
btw, rhel7 ships with nr_cpus=5120 and ubuntu default is 256,
so this lack of acpi in vmware fusion will lead to possible_cpu=5120,
a lot of pain in per-cpu allocator and linux VMs will not be happy.
I think vmware has to be fixed first regardless of what we find
out about 'cpu*' vs /sys/devices/system/cpu/possible
