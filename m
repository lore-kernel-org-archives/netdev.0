From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Fri, 18 Feb 2011 16:51:37 -0500
Message-ID: <4D5EE9E9.2000407@tilera.com>
References: <4D5DA60A.8080201@tilera.com>	<20110217.145333.232751283.davem@davemloft.net>	<4D5DA96D.5060200@tilera.com>	<20110217.151147.35033921.davem@davemloft.net>	<4D5DACC5.60105@tilera.com> <AANLkTim1F679mmnbHnYkvi6ZDojxD-tPGer4F+61C+di@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <xiyou.wangcong@gmail.com>,
	<linux-kernel@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim1F679mmnbHnYkvi6ZDojxD-tPGer4F+61C+di@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/17/2011 10:16 PM, Cypher Wu wrote:
> On Fri, Feb 18, 2011 at 7:18 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>> The interrupt architecture on Tile allows a write to a special-purpose
>> register to put you into a "critical section" where no interrupts or faults
>> are delivered.  So we just need to bracket the read_lock operations with
>> two SPR writes; each takes six machine cycles, so we're only adding 12
>> cycles to the total cost of taking or releasing a read lock on an rwlock
> I agree that just lock interrupt for read operations should be enough,
> but read_unlock() is also the place we should lock interrupt, right?
> If interrupt occurred when it hold lock-val after TNS deadlock still
> can occur.

Correct; that's what I meant by "read_lock operations".  This include lock,
trylock, and unlock.

> When will you release out that patch? Since time is tight, so maybe
> I've to fix-up it myself.

I heard from one of our support folks that you were asking through that
channel, so I asked him to go ahead and give you the spinlock sources
directly.  I will be spending time next week syncing up our internal tree
with the public git repository so you'll see it on LKML at that time.

> 1. If we use SPR_INTERRUPT_CRITICAL_SECTION it will disable all the
> interrupt which claimed 'CM', is that right? Should we have to same
> its original value and restore it later?

We don't need to save and restore, since INTERRUPT_CRITICAL_SECTION is
almost always zero except in very specific situations.

> 2. Should we lock interrupt for the whole operation of
> read_lock()/read_unlock(), or we should leave interrupt critical
> section if it run into  __raw_read_lock_slow() and before have to
> delay_backoff() some time, and re-enter interrupt critical section
> again before TNS?

Correct, the fix only holds the critical section around the tns and the
write-back, not during the delay_backoff().

> Bye the way, other RISC platforms, say ARM and MIPS, use store
> conditional rather that TNS a temp value for lock-val, does Fx have
> similar instructions?

TILEPro does not have anything more than test-and-set; TILE-Gx (the 64-bit
processor) has a full array of atomic instructions.

> Adding that to SPR writes should be fine, but it may cause interrupt
> delay a little more that other platform's read_lock()?

A little, but I think it's in the noise relative to the basic cost of
read_lock in the absence of full-fledged atomic instructions.

> Another question: What NMI in the former mail means?

Non-maskable interrupt, such as performance counter interrupts.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
