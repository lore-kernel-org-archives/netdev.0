From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: [PATCH] arch/tile: fix rwlock so would-be write lockers don't
 block new readers
Date: Tue, 23 Nov 2010 09:36:31 +0800
Message-ID: <AANLkTim1YyujwGZfenU_m52HEJJSFmTg3Wswn2DkqA3a@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	<4CDF1945.8090101@tilera.com>
	<AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
	<201011151425.oAFEPU3W005682@farm-0010.internal.tilera.com>
	<AANLkTikGj+zG9OqVJseKh4fGqQNnqnJpHgcaaXOL8nNi@mail.gmail.com>
	<4CEA71AD.5010606@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38176 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932409Ab0KWBgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 20:36:33 -0500
In-Reply-To: <4CEA71AD.5010606@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/11/22 Chris Metcalf <cmetcalf@tilera.com>:
> On 11/22/2010 12:39 AM, Cypher Wu wrote:
>> 2010/11/15 Chris Metcalf <cmetcalf@tilera.com>:
>>> This avoids a deadlock in the IGMP code where one core gets a read
>>> lock, another core starts trying to get a write lock (thus blocking
>>> new readers), and then the first core tries to recursively re-acquire
>>> the read lock.
>>>
>>> We still try to preserve some degree of balance by giving priority
>>> to additional write lockers that come along while the lock is held
>>> for write, so they can all complete quickly and return the lock to
>>> the readers.
>>>
>>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
>>> ---
>>> This should apply relatively cleanly to 2.6.26.7 source code too.
>>> [...]
>>
>> I've finished my business trip and tested that patch for more than an
>> hour and it works. The test is still running now.
>>
>> But it seems there still has a potential problem: we used ticket lock
>> for write_lock(), and if there are so many write_lock() occurred, is
>> 256 ticket enough for 64 or even more cores to avoiding overflow?
>> Since is we try to write_unlock() and there's already write_lock()
>> waiting we'll only adding current ticket.
>
> This is OK, since each core can issue at most one (blocking) write_lock(),
> and we have only 64 cores.  Future >256 core machines will be based on
> TILE-Gx anyway, which doesn't have the 256-core limit since it doesn't use
> the spinlock_32.c implementation.
>
> --
> Chris Metcalf, Tilera Corp.
> http://www.tilera.com
>
>

Say, if core A try to write_lock() rwlock and current_ticket_ is 0 and
it write next_ticket_ to 1, when it processing the lock, core B try to
write_lock() again and write next_ticket_ to 2, then when A
write_unlock() it seen that (current_ticket_+1) is not equal to
next_ticket_, so it increment current_ticket_, and core B get the
lock. If core A try write_lock again before core B write_unlock, it
will increment next_ticket_ to 3. And so on.
This may rarely happened, I've tested it yesterday for several hours
it goes very well under pressure.


-- 
Cyberman Wu
http://www.meganovo.com
