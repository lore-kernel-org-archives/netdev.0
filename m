From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 11:32:59 +0800
Message-ID: <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45697 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788Ab0KLDdB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 22:33:01 -0500
In-Reply-To: <1289489007.17691.1310.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 11 novembre 2010 =E0 21:49 +0800, Cypher Wu a =E9crit :
>
> Hi
>
> CC netdev, since you ask questions about network stuff _and_ rwlock
>
>
>> I'm using TILEPro and its rwlock in kernel is a liitle different tha=
n
>> other platforms. It have a priority for write lock that when tried i=
t
>> will block the following read lock even if read lock is hold by
>> others. Its code can be read in Linux Kernel 2.6.36 in
>> arch/tile/lib/spinlock_32.c.
>
> This seems a bug to me.
>
> read_lock() can be nested. We used such a schem in the past in iptabl=
es
> (it can re-enter itself),
> and we used instead a spinlock(), but with many discussions with lkml
> and Linus himself if I remember well.
>
It seems not a problem that read_lock() can be nested or not since
rwlock doesn't have 'owner', it's just that should we give
write_lock() a priority than read_lock() since if there have a lot
read_lock()s then they'll starve write_lock().
We should work out a well defined behavior so all the
platform-dependent raw_rwlock has to design under that principle.
>
>>
>> That different could cause a deadlock in kernel if we join/leave
>> Multicast Group simultaneous and frequently on mutlicores. IGMP
>> message is sent by
>>
>> igmp_ifc_timer_expire() -> igmpv3_send_cr() -> igmpv3_sendpack()
>>
>> in timer interrupt, igmpv3_send_cr() will generate the sk_buff for
>> IGMP message with mc_list_lock read locked and then call
>> igmpv3_sendpack() with it unlocked.
>> But if we have so many join/leave messages have to generate and it
>> can't be sent in one sk_buff then igmpv3_send_cr() -> add_grec() wil=
l
>> call igmpv3_sendpack() to send it and reallocate a new buffer. When
>> the message is sent:
>>
>> __mkroute_output() -> ip_check_mc()
>>
>> will read lock mc_list_lock again. If there is another core is try
>> write lock mc_list_lock between the two read lock, then deadlock
>> ocurred.
>>
>> The rwlock on other platforms I've check, say, PowerPC, x86, ARM, is
>> just read lock shared and write_lock mutex, so if we've hold read lo=
ck
>> the write lock will just wait, and if there have a read lock again i=
t
>> will success.
>>
>> So, What's the criteria of rwlock design in the Linux kernel? Is tha=
t
>> read lock re-hold of IGMP a design error in Linux kernel, or the rea=
d
>> lock has to be design like that?
>>
>
> Well, we try to get rid of all rwlocks in performance critical sectio=
ns.
>
> I would say, if you believe one rwlock can justify the special TILE
> behavior you tried to make, then we should instead migrate this rwloc=
k
> to a RCU + spinlock schem (so that all arches benefit from this work,
> not only TILE)

IGMP in not very performance critical so maybe rwlock is enough?

>
>> There is a other thing, that the timer interrupt will start timer on
>> the same in_dev, should that be optimized?
>>
>
> Not sure I understand what you mean.

Since mc_list & mc_tomb is shared list in the kernel we needn't to
start multiple timers on different cores for them, we can synchronize
it on one core.

>
>> BTW: If we have so many cores, say 64, is there other things we have
>> to think about spinlock? If there have collisions ocurred, should we
>> just read the shared memory again and again, or just a very little
>> 'delay' is better? I've seen relax() is called in the implementation
>> of spinlock on TILEPro platform.
>> --
>
> Is TILE using ticket spinlocks ?
>

What ticket spinlocks means? Could you explain a little, pls:) I'm not
familiar with Linux kernel, I'm trying to get more understanding of it
since I'm working on Linux platform now.

>
>
