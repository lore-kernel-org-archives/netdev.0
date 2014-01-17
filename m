From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Fri, 17 Jan 2014 13:18:55 +0100
Message-ID: <52D91FAF.8090109@samsung.com>
References: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
 <1386603119.30495.331.camel@edumazet-glaptop2.roam.corp.google.com>
 <52A6BAC6.4090407@samsung.com>
 <1386685557.30495.344.camel@edumazet-glaptop2.roam.corp.google.com>
 <52D7F8EF.1050407@samsung.com>
 <1389889754.31367.406.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1389889754.31367.406.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 16.01.2014 17:29, Eric Dumazet pisze:
> On Thu, 2014-01-16 at 16:21 +0100, Andrzej Pietrasiewicz wrote:
>> W dniu 10.12.2013 15:25, Eric Dumazet pisze:
>>> On Tue, 2013-12-10 at 07:55 +0100, Andrzej Pietrasiewicz wrote:
>>>> W dniu 09.12.2013 16:31, Eric Dumazet pisze:
>>>>> On Mon, 2013-12-09 at 12:47 +0100, Andrzej Pietrasiewicz wrote:
>>>>>> NOT FOR COMMITTING TO MAINLINE.
>>>>>>
>>>>>> With g_ether loaded the sk occasionally becomes 0xffffffff.
>>>>>> It happens usually after transferring few hundreds of kilobytes to few
>>>>>> tens of megabytes. If sk is 0xffffffff then dereferencing it causes
>>>>>> kernel panic.
>>>>>>
>>>>>> This is a *workaround*. I don't know enough net code to understand the core
>>>>>> of the problem. However, with this patch applied the problems are gone,
>>>>>> or at least pushed farther away.
>>>>>
>>>>> Is it happening on SMP or UP ?
>>>>
>>>> UP build, S5PC110
>>>
>>> OK
>>>
>>> I believe you need additional debugging to track the exact moment
>>> 0xffffffff is fed to 'sk'
>>>
>>> It looks like a very strange bug, involving a problem in some assembly
>>> helper, register save/restore, compiler bug or stack corruption or
>>> something.
>>>
>>
>> I started with adding WARN_ON(sk == 0xffffffff); just before return in
>> __inet_lookup_established(), and the problem was gone. So this looks
>> very strange, like a toolchain problem.
>
> Or a timing issue. Adding a WARN_ON() adds extra instructions and might
> really change the assembly output.
>
>>
>> I used gcc-linaro-arm-linux-gnueabihf-4.8-2013.05.
>>
>> If I change the toolchain to
>>
>> gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415
>>
>> the problem seems to have gone away.
>
> Its totally possible some barrier was not properly handled by the
> compiler. You could disassemble the function on both toolchains and
> try to spot the issue.
>

So I gave it a try.

Below is a part of assembly code (ARM) which corresponds to the last
lines of the __inet_lookup_established():

C source:
=========
found:
	rcu_read_unlock();
	return sk;
}

assembly for toolchain 4.7:
===========================
c0333bb8:	ebf4bb6e 	bl	c0062978 <__rcu_read_unlock>
c0333bbc:	e51b0030 	ldr	r0, [fp, #-48]	; 0x30
c0333bc0:	e24bd028 	sub	sp, fp, #40	; 0x28
c0333bc4:	e89daff0 	ldm	sp, {r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}
c0333bc8:	e5132018 	ldr	r2, [r3, #-24]


assembly for toolchain 4.8:
===========================
c033ff5c:	ebf4927e 	bl	c006495c <__rcu_read_unlock>
c033ff60:	e24bd028 	sub	sp, fp, #40	; 0x28
c033ff64:	e51b0030 	ldr	r0, [fp, #-48]	; 0x30
c033ff68:	e89daff0 	ldm	sp, {r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}
c033ff6c:	e5113018 	ldr	r3, [r1, #-24]

What can be seen is that the usage of registers is slightly different,
and, what is more important, the _order_ of ldr/sub is different.
Now, if I swap the instructions at offsets c033ff60 and c033ff64
in the 4.8-generated vmlinux, the problem seems gone! Well, at least
the binary behaves the same way as the 4.7-generated one.

Here is a _hypothesis_ of what _might_ be happening:

The function in question puts its return value in the register r0.
In both cases the return value is fetched from a memory location
relative #-48 to what the frame pointer points to. However,
in the 4.7-generated binary the ldr executes in the branch delay slot,
whereas in the 4.8-generated binary it is the sub which executes
in the branch delay slot. That way, in the 4.7-generated binary the return
value is fetched before __rcu_read_unlock begins, but in the
4.8-generated binary it is fetched some time later. Which might be
enough for someone else to schedule in and break the data to be
copied to r0 and returned from the function.

As I said, this is just a hypothesis.

AP
