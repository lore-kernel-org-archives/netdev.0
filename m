From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: gigaset: freeing an active object
Date: Fri, 27 Nov 2015 20:20:25 -0500
Message-ID: <56590159.4080404@hurleysoftware.com>
References: <56587467.8050102@oracle.com>
 <1448647077.6523.33.camel@tiscali.nl> <56589DD9.2060508@oracle.com>
 <1448670517.6523.67.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net, tilman@imap.cc,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Paul Bolle <pebolle@tiscali.nl>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36181 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbK1BU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 20:20:28 -0500
Received: by igcph11 with SMTP id ph11so35227952igc.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 17:20:28 -0800 (PST)
In-Reply-To: <1448670517.6523.67.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/2015 07:28 PM, Paul Bolle wrote:
> (A few quick notes follow. The hope here is basically that my display of
> ignorance might trigger others to speak up while I'm still pondering on
> this bug.)
> 
> On vr, 2015-11-27 at 13:15 -0500, Sasha Levin wrote:
>> On 11/27/2015 12:57 PM, Paul Bolle wrote:
>>> On vr, 2015-11-27 at 10:19 -0500, Sasha Levin wrote:
>>>> Fuzzing with syzkaller on the latest -next kernel produced this
>>>> error:
>>>
>>> (syzkaller is new to me. I'll have to do some web searches.)
>>
>> It's a new fancy syscall/ioctl fuzzer, 
>> https://github.com/google/syzkaller/blob/master/README.md
> 
> Thanks.
> 
> That fuzzer apparently requires either CONFIG_KASAN, CONFIG_KTSAN, or
> CONFIG_UBSAN, none of which I'm familiar with.
> 
>>>> [  413.536749] WARNING: CPU: 6 PID: 25400 at
>>>> lib/debugobjects.c:263
>>>> debug_print_object+0x1c4/0x1e0()
>>>> [  413.538111] ODEBUG: free active (active state 0) object type:
>>>> timer_list hint: delayed_work_timer_fn+0x0/0x90
> 
> There are two places that add "free" here, but there's no obvious way to
> distinguish between them. Annoying.
> 
> Anyhow, this is interesting. ser-gigaset doesn't use timer_list while
> bas-gigaset does.
> 
>>>> [  413.539598] Modules linked
>>>> in:3470693efef57268844f02f5de3ab392d8cf5e209671ddd87163cb964c51065
>>>> 9
> 
> Not sure what this means. The bug concerns ser-gigaset so it's safe to
> assume the fuzzer at one point called
>     ioctl(fd, TIOCSETD, N_GIGASET_M101)

Sasha,

It would really help if you included the syzkaller-generated applet with
the bug reports; state previously established by the applet can be
crucial in understanding why the call stack looks the way it does.

Also, every generated applet that triggers a report should become
a future regression test; I'm collecting the ones pertinent to tty/serial/
ldisc (so that includes this one; if you could send me the x25 one too
would be great).

Regards,
Peter Hurley


> which would trigger the use of ser-gigaset.
> 
>>>> [  413.540448] CPU: 6 PID: 25400 Comm: syzkaller_execu Not tainted
>>>> 4.4.0-rc2-next-20151126-sasha-00005-g00d303e-dirty #2653
>>>> [  413.547614] Call Trace:
>>>> [  413.548077]  [<ffffffffa8e6b5bb>] dump_stack+0x72/0xb7
>>>> [  413.548765]  [<ffffffffa73531d3>]
>>>> warn_slowpath_common+0x113/0x140
>>>> [  413.551151]  [<ffffffffa73532cb>] warn_slowpath_fmt+0xcb/0x100
>>>> [  413.554295]  [<ffffffffa8ed0194>]
>>>> debug_print_object+0x1c4/0x1e0
>>>> [  413.556592]  [<ffffffffa8ed1035>]
>>>> __debug_check_no_obj_freed+0x215/0x7a0
>>>> [  413.560526]  [<ffffffffa8ed2b6c>]
>>>> debug_check_no_obj_freed+0x2c/0x40
>>>> [  413.561328]  [<ffffffffa77aac4c>] kfree+0x1fc/0x2f0
> 
> This should be
>     kfree(cs->hw.ser)
> 
> Note that cs->hw is a union of struct base_cardstate, struct
> ser_cardstate, and struct usb_cardstate. And it's obvious that struct
> ser_cardstate is much smaller that struct bas_cardstate. So we're
> probably free-ing some memory that, so to speak, includes
> bas_cardstate.timer_int_in, a struct timer_list. That's likely way
> beyond the end of struct ser_cardstate and so it should still contain
> garbage.
> 
>>>> [  413.561970]  [<ffffffffae74b021>] gigaset_freecshw+0xe1/0x120
>>>> [  413.562723]  [<ffffffffae70669d>] gigaset_freecs+0x2ad/0x600
>>>> [  413.564240]  [<ffffffffae74ba60>] gigaset_tty_close+0x210/0x280
>>>> [  413.565774]  [<ffffffffa95ba6f2>]
>>>> tty_ldisc_close.isra.1+0xc2/0xd0
>>>> [  413.566550]  [<ffffffffa95ba81b>] tty_ldisc_kill+0x4b/0x170
>>>> [  413.567253]  [<ffffffffa95bbba3>] tty_ldisc_release+0x183/0x240
>>>> [  413.568000]  [<ffffffffa95a507c>] tty_release+0xd1c/0xe80
>>>> [  413.570176]  [<ffffffffa78182fa>] __fput+0x32a/0x680
>>>> [  413.570888]  [<ffffffffa78186da>] ____fput+0x1a/0x20
>>>> [  413.571565]  [<ffffffffa73adf5c>] task_work_run+0x19c/0x1e0
>>>> [  413.572290]  [<ffffffffa735cae7>] do_exit+0xdf7/0x28f0
>>>> [  413.576188]  [<ffffffffa735e805>] do_group_exit+0x1b5/0x300
>>>> [  413.576905]  [<ffffffffa7382222>] get_signal+0x1182/0x1360
>>>> [  413.577627]  [<ffffffffa717b553>] do_signal+0x93/0x1690
>>>> [  413.584630]  [<ffffffffa70063b0>]
>>>> exit_to_usermode_loop+0xc0/0x1e0
>>>> [  413.585412]  [<ffffffffa7007feb>]
>>>> prepare_exit_to_usermode+0x10b/0x140
>>>> [  413.586187]  [<ffffffffb0a12c3e>] retint_user+0x8/0x23
>>>
> 
> I have no idea (yet) what triggers retint_user.
> 
> Anyhow, my first hunch is to do a s/kmalloc/kzalloc/ on
>     drv->cs = kmalloc(minors * sizeof *drv->cs, GFP_KERNEL)
> 
> in drivers/isdn/gigaset/common.c and see if this still triggers. But to
> test that I need to know how to reproduce this.
> 
> To be continued...
