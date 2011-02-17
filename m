From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Thu, 17 Feb 2011 17:49:46 -0500
Message-ID: <4D5DA60A.8080201@tilera.com>
References: <20110217044917.GA2653@cr0.nay.redhat.com>	<AANLkTikkro-_9pv5uJ4+SqYh9Fr480_96Wh1Pv6Pvtez@mail.gmail.com>	<20110217054237.GB2653@cr0.nay.redhat.com> <20110216.214625.189707123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <xiyou.wangcong@gmail.com>, <cypher.w@gmail.com>,
	<linux-kernel@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110216.214625.189707123.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/17/2011 12:46 AM, David Miller wrote:
> From: Am=E9rico Wang <xiyou.wangcong@gmail.com>
> Date: Thu, 17 Feb 2011 13:42:37 +0800
>
>> On Thu, Feb 17, 2011 at 01:04:14PM +0800, Cypher Wu wrote:
>>>> Have you turned CONFIG_LOCKDEP on?
>>>>
>>>> I think Eric already converted that rwlock into RCU lock, thus
>>>> this problem should disappear. Could you try a new kernel?
>>>>
>>>> Thanks.
>>>>
>>> I haven't turned CONFIG_LOCKDEP on for test since I didn't get too
>>> much information when we tried to figured out the former deadlock.
>>>
>>> IGMP used read_lock() instead of read_lock_bh() since usually
>>> read_lock() can be called recursively, and today I've read the
>>> implementation of MIPS, it's should also works fine in that situati=
on.
>>> The implementation of TILEPro cause problem since after it use TNS =
set
>>> the lock-val to 1 and hold the original value and before it re-set
>>> lock-val a new value, it a race condition window.
>>>
>> I see no reason why you can't call read_lock_bh() recursively,
>> read_lock_bh() is roughly equalent to local_bh_disable() + read_lock=
(),
>> both can be recursive.
>>
>> But I may miss something here. :-/
> IGMP is doing this so that taking the read lock does not stop packet
> processing.
>
> TILEPro's rwlock implementation is simply buggy and needs to be fixed=
=2E

Cypher, thanks for tracking this down with a good bug report.

The fix is to disable interrupts for the arch_read_lock family of metho=
ds.=20
In my fix I'm using the "hard" disable that locks out NMIs as well, so =
that
in the event the NMI handler needs to share an rwlock with regular code=
 it
would be possible (plus, it's more efficient).  I believe it's not
necessary to worry about similar protection for the arch_write_lock
methods, since they aren't guaranteed to be re-entrant anyway (you'd ha=
ve
to use write_lock_irqsave or equivalent).

I'll send the patch to LKML after letting it bake internally for a litt=
le
while.

Thanks again!

--=20
Chris Metcalf, Tilera Corp.
http://www.tilera.com
