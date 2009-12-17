From: Mikhail Markine <markine@google.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() ->
	cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 13:31:36 -0800
Message-ID: <4b1a0cb90912171331t3297f01aw3bf014e27cd5fb0e@mail.gmail.com>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
	 <20091217074930.GA6779@ff.dom.local>
	 <20091217133644.GD8654@ff.dom.local>
	 <1261060259.10356.112.camel@johannes.local>
	 <11218.1261066373@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:6085 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765398AbZLQVbm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:31:42 -0500
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id nBHLVdhM012900
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 21:31:40 GMT
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by wpaz21.hot.corp.google.com with ESMTP id nBHLVRwV021755
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:31:37 -0800
Received: by pzk11 with SMTP id 11so1571866pzk.14
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:31:36 -0800 (PST)
In-Reply-To: <11218.1261066373@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay,

We originally applied this patch against bond_main.c under 2.6.25
(bear with me) in response to a BUG() observed in testing:

------------[ cut here ]------------
Kernel BUG at c0039aa4 [verbose debug info unavailable]
Oops: Exception in kernel mode, sig: 5 [#1]
[SNIP]
NIP [c0039aa4] queue_delayed_work_on+0x60/0x120
LR [e1578a7c] bond_mii_monitor+0x6c/0x98 [bonding]
Call Trace:
[db401f30] [c029e0e8] 0xc029e0e8 (unreliable)
[db401f50] [e1578a7c] bond_mii_monitor+0x6c/0x98 [bonding]
[db401f60] [c003914c] run_workqueue+0xb8/0x148
[db401f90] [c0039700] worker_thread+0x70/0xd0
[db401fd0] [c003d13c] kthread+0x48/0x84
[db401ff0] [c000dab4] kernel_thread+0x44/0x60
Instruction dump:
40a2fff4 71200001 38600000 41820018 80010024 bb810010 38210020 7c0803a6
4e800020 80050010 3160ffff 7d2b0110 <0f090000> 80050004 39250004 7c004a=
78
---[ end trace ef4eb74d43ff218e ]---

This was a BUG_ON(timer_pending(timer)) call in
queue_delayed_work_on() which was called from queue_delayed_work()
which was called at the bottom of bond_mii_monitor(). This implied
that mii_work was queued twice.

In both 2.6.25 and the current HEAD of Linus' tree, mii_work is queued
up in two places: bond_mii_monitor() and bond_open(). bond_open()
calls INIT_DELAYED_WORK() prior to queue_delayed_work().

Under both kernels, if bond_mii_monitor() sleeps due to RTNL while
bond_close() is called, setting kill_timers=3D1 and calling
cancel_delayed_work(&bond->mii_work) in bond_close() accomplishes
nothing. bond_mii_monitor() will eventually wake up and call
queue_delayed_work() again. A possible explanation for the 2.6.25
kernel trace above is that bond_close() and bond_open() are called on
the same net_device in succession while bond_mii_monitor() sleeps with
the associated bond. I believe the same is still possible on HEAD.
Thoughts?

Mikhail

On Thu, Dec 17, 2009 at 8:12 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Johannes Berg <johannes@sipsolutions.net> wrote:
>
>>On Thu, 2009-12-17 at 13:36 +0000, Jarek Poplawski wrote:
>>> On Thu, Dec 17, 2009 at 02:19:46PM +0100, Johannes Berg wrote:
>>> > Jarek,
>>> >
>>> > Sorry to mail you directly, but I only saw your reply on gmane an=
d
>>> > didn't want to break up the threading etc.
>>> >
>>> > cancel_delayed_work_sync() should be ok in this case unless the w=
ork
>>> > items themselves used the rtnl,
>>>
>>> Hmm, I'm not sure I get your point, but e.g. bond_mii_monitor() wor=
k
>>> function can get rtnl_lock().
>>
>>Ok in that case you can't cancel_sync() it under rtnl. I was thinking=
 of
>>the case where it's just not ok because of other work. Sorry for the
>>confusion!
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0There's already logic in the monitors (bon=
d_mii_monitor, et al)
> to check a sentinel (kill_timers) and do nothing (not acquire rtnl) a=
nd
> return.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0What exactly is the nature of the race tha=
t doing cancel..sync
> is fixing? =C2=A0The bond_close function sets kill_timers prior to ca=
lling
> the cancel functions, so the monitor function might run once, but it
> should do nothing.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0-J
>
> ---
> =C2=A0 =C2=A0 =C2=A0 =C2=A0-Jay Vosburgh, IBM Linux Technology Center=
, fubar@us.ibm.com
>
