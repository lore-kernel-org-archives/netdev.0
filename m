From: Wengang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Mon, 29 Dec 2014 15:13:28 +0800
Message-ID: <54A0FF18.8040406@oracle.com>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com> <20141125.010741.450666241983239119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141125.010741.450666241983239119.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

This is a real case not a potential crash. The call stack is like this:

crash> bt
PID: 47323 TASK: ffff881722954140 CPU: 13 COMMAND: "arping"
#0 [ffff881518437860] machine_kexec at ffffffff8103aac9
#1 [ffff8815184378d0] crash_kexec at ffffffff810b9943
#2 [ffff8815184379a0] oops_end at ffffffff8150e9b8
#3 [ffff8815184379d0] no_context at ffffffff8104855c
#4 [ffff881518437a10] __bad_area_nosemaphore at ffffffff81048685
#5 [ffff881518437a60] bad_area_nosemaphore at ffffffff810487e3
#6 [ffff881518437a70] do_page_fault at ffffffff81511558
#7 [ffff881518437b80] page_fault at ffffffff8150df55
[exception RIP: packet_snd+608]
RIP: ffffffff814ddbc0 RSP: ffff881518437c38 RFLAGS: 00010282
RAX: ffffffffa0316040 RBX: ffff881518437e58 RCX: 0000000000000000
RDX: 0000000000000048 RSI: 0000000000000038 RDI: ffff88172508a080
RBP: ffff881518437ca8 R8: ffff88176568f400 R9: 0000000000000038
R10: ffff88172508a080 R11: 0000000000000000 R12: ffff8817e94f2080
R13: ffff8817eba0f400 R14: ffff8817eaef6000 R15: 0000000000000038
ORIG_RAX: ffffffffffffffff CS: 0010 SS: 0018
#8 [ffff881518437cb0] packet_sendmsg at ffffffff814ddee3
#9 [ffff881518437cc0] sock_sendmsg at ffffffff8142ad3f
#10 [ffff881518437e40] sys_sendto at ffffffff8142af09
#11 [ffff881518437f80] system_call_fastpath at ffffffff81515c42
RIP: 00007f4a03095853 RSP: 00007fffad354bf8 RFLAGS: 00010202
RAX: 000000000000002c RBX: ffffffff81515c42 RCX: 00007f4a02fde7ce
RDX: 0000000000000038 RSI: 00007fffad354ab0 RDI: 0000000000000003
RBP: 0000000000000038 R8: 00007f4a03b87e00 R9: 0000000000000020
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f4a03b87e00
R13: 00007f4a03b87e4c R14: 00007fffad354ae4 R15: 00007f4a03b87e98
ORIG_RAX: 000000000000002c CS: 0033 SS: 002b

Though the crash is not based on mainline code, mainline has the same i=
ssue.

I think Or Gerlitz answered the question "IPOIB should not work over=20
bonding as it requires that the device use ARPHRD_ETHER.".

IPoIB devices can be enslaved to both bonding and teaming in their HA m=
ode,
the bond device type becomes ARPHRD_INFINIBAND when this happens.

So, what information else do you need?

thanks,
wengang


=E4=BA=8E 2014=E5=B9=B411=E6=9C=8825=E6=97=A5 14:07, David Miller =E5=86=
=99=E9=81=93:
> From: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 25 Nov 2014 13:36:08 +0800
>
>> When last slave of a bonding master is removed, the bonding then doe=
s not work.
>> At the time if packet_snd is called against with a master net_device=
, it calls
>> then header_ops->create which points to slave's header_ops. In case =
the slave
>> is ipoib and the module is unloaded, header_ops would point to inval=
id address.
>> Accessing it will cause problem.
>> This patch tries to fix this issue by moving ipoib_header_ops to vml=
inux to keep
>> it valid even when ipoib module is unloaded.
>>
>> Signed-off-by: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> IPOIB should not work over bonding as it requires that the device
> use ARPHRD_ETHER.
>
> Someone mentioned this, and I did not see any response.
>
> Please show how a legitimate real bonding configuration can be
> created, reproduce a stray memory access, and therefore potentially
> cause a crash.
>
> Using various debugging features of the kernel should allow you to
> trigger an assertion quite easily if this bug really exists.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
