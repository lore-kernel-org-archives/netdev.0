From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: gigaset: freeing an active object
Date: Sun, 29 Nov 2015 13:22:14 -0500
Message-ID: <565B4256.6080101@hurleysoftware.com>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Tilman Schmidt <tilman@imap.cc>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34075 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbbK2SWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 13:22:17 -0500
Received: by igvg19 with SMTP id g19so57042640igv.1
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 10:22:16 -0800 (PST)
In-Reply-To: <565B1A1B.8020503@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tilman,

On 11/29/2015 10:30 AM, Tilman Schmidt wrote:
> Hi Sasha,
> 
> thanks for the report. As the original author of the code in question, I
> am somewhat at a loss what to make of it.
> 
> Am 27.11.2015 um 16:19 schrieb Sasha Levin:
>> Fuzzing with syzkaller on the latest -next kernel produced this error:
> 
> Is there a way to know the actual sequence of events that triggered this
> warning?
> 
>> [  413.536749] WARNING: CPU: 6 PID: 25400 at lib/debugobjects.c:263 debug_print_object+0x1c4/0x1e0()
>> [  413.538111] ODEBUG: free active (active state 0) object type: timer_list hint: delayed_work_timer_fn+0x0/0x90
> 
> This message seems to indicate that an object of type timer_list was
> freed which was still active. However the driver in question
> (ser_gigaset) does not use any timers.
> 
> What are the exact conditions for producing this message? IOW how does
> the ODEBUG code determine that an object of type timer_list is being
> freed, and that it is still in use?
> 
> Are there any messages from ser_gigaset or another one of the gigaset
> drivers before that warning?
> 
>> [  413.539598] Modules linked in:3470693efef57268844f02f5de3ab392d8cf5e209671ddd87163cb964c510659
> 
> This message does not tell me anything. What does that hex string after
> the colon mean?
> 
>> [  413.540448] CPU: 6 PID: 25400 Comm: syzkaller_execu Not tainted 4.4.0-rc2-next-20151126-sasha-00005-g00d303e-dirty #2653
>> [  413.547614] Call Trace:
>> [  413.548077]  [<ffffffffa8e6b5bb>] dump_stack+0x72/0xb7
>> [  413.548765]  [<ffffffffa73531d3>] warn_slowpath_common+0x113/0x140
>> [  413.551151]  [<ffffffffa73532cb>] warn_slowpath_fmt+0xcb/0x100
>> [  413.554295]  [<ffffffffa8ed0194>] debug_print_object+0x1c4/0x1e0
>> [  413.556592]  [<ffffffffa8ed1035>] __debug_check_no_obj_freed+0x215/0x7a0
>> [  413.560526]  [<ffffffffa8ed2b6c>] debug_check_no_obj_freed+0x2c/0x40
>> [  413.561328]  [<ffffffffa77aac4c>] kfree+0x1fc/0x2f0
> 
> Judging from the backtrace below this must be the call
> 
>         kfree(cs->hw.ser);
> 
> in drivers/isdn/gigaset/ser-gigaset.c line 375.
> cs->hw.ser is of type struct ser_cardstate *.
> struct ser_cardstate consists of a struct platform_device, a struct
> completion, an atomic_t and a pointer. No timer_list.
> 
>> [  413.561970]  [<ffffffffae74b021>] gigaset_freecshw+0xe1/0x120
> 
> There are functions by this name in all three Gigaset hardware dependent
> modules (bas_gigaset, ser_gigaset and usb_gigaset), but ...
> 
>> [  413.562723]  [<ffffffffae70669d>] gigaset_freecs+0x2ad/0x600
>> [  413.564240]  [<ffffffffae74ba60>] gigaset_tty_close+0x210/0x280
> 
> this function only exists in ser_gigaset.

The platform_device embedded in struct ser_cardstate hasn't been released when
you kfree() the memory it's in.

Regards,
Peter Hurley
