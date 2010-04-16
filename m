From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 11:35:36 -0700
Message-ID: <l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:48728 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322Ab0DPSfl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 14:35:41 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [10.3.21.12])
	by smtp-out.google.com with ESMTP id o3GIZceo031573
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 20:35:38 +0200
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq12.eem.corp.google.com with ESMTP id o3GIZawn012752
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 20:35:37 +0200
Received: by pwj8 with SMTP id 8so2304865pwj.24
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 11:35:36 -0700 (PDT)
In-Reply-To: <1271401007.16881.3762.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Results with "tbench 16" on an 8 core Intel machine.

No RPS/RFS:  2155 MB/sec
RPS (0ff mask): 1700 MB/sec
RFS: 1097

I am not particularly surprised by the results, using loopback
interface already provides good parallelism and RPS/RFS really would
only add overhead and more trips between CPUs (last part is why RPS <
RFS I suspect)-- I guess this is why we've never enabled RPS on
loopback :-)

Eric, do you have a particular concern that this could affect a real wo=
rkload?

Tom


On Thu, Apr 15, 2010 at 11:56 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 15 avril 2010 =E0 23:33 -0700, David Miller a =E9crit :
>> From: Tom Herbert <therbert@google.com>
>> Date: Thu, 15 Apr 2010 22:47:08 -0700 (PDT)
>>
>> > Version 5 of RFS:
>> > - Moved rps_sock_flow_sysctl into net/core/sysctl_net_core.c as a
>> > static function.
>> > - Apply limits to rps_sock_flow_entires systcl and rps_flow_count
>> > sysfs variable.
>>
>> I've read this over a few times and I think it's ready to go into
>> net-next-2.6, we can tweak things as-needed from here on out.
>>
>> Eric, what do you think?
>
> I read the patch and found no error.
>
> I booted a test machine and performed some tests
>
> I am a bit worried of a tbench regression I am looking at right now.
>
> if RFS disabled , tbench 16 =A0 -> =A04408.63 MB/sec
>
>
> # grep . /sys/class/net/lo/queues/rx-0/*
> /sys/class/net/lo/queues/rx-0/rps_cpus:00000000
> /sys/class/net/lo/queues/rx-0/rps_flow_cnt:8192
> # cat /proc/sys/net/core/rps_sock_flow_entries
> 8192
>
>
> echo ffff >/sys/class/net/lo/queues/rx-0/rps_cpus
>
> tbench 16 -> 2336.32 MB/sec
>
>
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
---------
> =A0 PerfTop: =A0 14561 irqs/sec =A0kernel:86.3% [1000Hz cycles], =A0(=
all, 16 CPUs)
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
---------
>
> =A0 =A0 =A0 =A0 =A0 =A0 samples =A0pcnt function =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 DSO
> =A0 =A0 =A0 =A0 =A0 =A0 _______ _____ ______________________________ =
__________________________________________________________
>
> =A0 =A0 =A0 =A0 =A0 =A0 2664.00 =A05.1% copy_user_generic_string =A0 =
=A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 2323.00 =A04.4% acpi_os_read_port =A0 =A0 =A0=
 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmli=
nux
> =A0 =A0 =A0 =A0 =A0 =A0 1641.00 =A03.1% _raw_spin_lock_irqsave =A0 =A0=
 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 1260.00 =A02.4% schedule =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/bu=
ild/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 1159.00 =A02.2% _raw_spin_lock =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vml=
inux
> =A0 =A0 =A0 =A0 =A0 =A0 1051.00 =A02.0% tcp_ack =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/bu=
ild/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0991.00 =A01.9% tcp_sendmsg =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/bu=
ild/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0922.00 =A01.8% tcp_recvmsg =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/bu=
ild/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0821.00 =A01.6% child_run =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/usr/bin/tbench
> =A0 =A0 =A0 =A0 =A0 =A0 =A0766.00 =A01.5% all_string_sub =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 /usr/bin/tbench
> =A0 =A0 =A0 =A0 =A0 =A0 =A0630.00 =A01.2% __switch_to =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/bu=
ild/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0608.00 =A01.2% __GI_strchr =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/lib/tls/libc-2.3.4.so
> =A0 =A0 =A0 =A0 =A0 =A0 =A0606.00 =A01.2% ipt_do_table =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build=
/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0600.00 =A01.1% __GI_strstr =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/lib/tls/libc-2.3.4.so
> =A0 =A0 =A0 =A0 =A0 =A0 =A0556.00 =A01.1% __netif_receive_skb =A0 =A0=
 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmli=
nux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0504.00 =A01.0% tcp_transmit_skb =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vml=
inux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0502.00 =A01.0% tick_nohz_stop_sched_tick =A0=
 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0481.00 =A00.9% _raw_spin_unlock_irqrestore=
 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0473.00 =A00.9% next_token =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 /usr/bin/tbench
> =A0 =A0 =A0 =A0 =A0 =A0 =A0449.00 =A00.9% ip_rcv =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirt=
y/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0423.00 =A00.8% call_function_single_interr=
upt /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0422.00 =A00.8% ia32_sysenter_target =A0 =A0=
 =A0 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0420.00 =A00.8% compat_sys_socketcall =A0 =A0=
 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0401.00 =A00.8% mod_timer =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/bu=
ild/vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0400.00 =A00.8% process_backlog =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/=
vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0399.00 =A00.8% ip_queue_xmit =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/=
vmlinux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0387.00 =A00.7% select_task_rq_fair =A0 =A0=
 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmli=
nux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0377.00 =A00.7% _raw_spin_lock_bh =A0 =A0 =A0=
 =A0 =A0 =A0 =A0/lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmli=
nux
> =A0 =A0 =A0 =A0 =A0 =A0 =A0360.00 =A00.7% tcp_v4_rcv =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 /lib/modules/2.6.34-rc3-03375-ga4fbf84-dirty/bu=
ild/vmlinux
>
> But if RFS is on, why activating rps_cpus change tbench ?
>
>
>
>
