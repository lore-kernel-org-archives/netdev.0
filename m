From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Sat, 19 Feb 2011 12:07:30 +0800
Message-ID: <AANLkTi=uQTQjrXn4_w-YwKCutpENFdFrxQed5kVKXTDF@mail.gmail.com>
References: <4D5DA60A.8080201@tilera.com>
	<20110217.145333.232751283.davem@davemloft.net>
	<4D5DA96D.5060200@tilera.com>
	<20110217.151147.35033921.davem@davemloft.net>
	<4D5DACC5.60105@tilera.com>
	<AANLkTim1F679mmnbHnYkvi6ZDojxD-tPGer4F+61C+di@mail.gmail.com>
	<4D5EE9E9.2000407@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46965 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab1BSEHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 23:07:32 -0500
In-Reply-To: <4D5EE9E9.2000407@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 19, 2011 at 5:51 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> On 2/17/2011 10:16 PM, Cypher Wu wrote:
>> On Fri, Feb 18, 2011 at 7:18 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>>> The interrupt architecture on Tile allows a write to a special-purpose
>>> register to put you into a "critical section" where no interrupts or faults
>>> are delivered.  So we just need to bracket the read_lock operations with
>>> two SPR writes; each takes six machine cycles, so we're only adding 12
>>> cycles to the total cost of taking or releasing a read lock on an rwlock
>> I agree that just lock interrupt for read operations should be enough,
>> but read_unlock() is also the place we should lock interrupt, right?
>> If interrupt occurred when it hold lock-val after TNS deadlock still
>> can occur.
>
> Correct; that's what I meant by "read_lock operations".  This include lock,
> trylock, and unlock.
>
>> When will you release out that patch? Since time is tight, so maybe
>> I've to fix-up it myself.
>
> I heard from one of our support folks that you were asking through that
> channel, so I asked him to go ahead and give you the spinlock sources
> directly.  I will be spending time next week syncing up our internal tree
> with the public git repository so you'll see it on LKML at that time.
>
>> 1. If we use SPR_INTERRUPT_CRITICAL_SECTION it will disable all the
>> interrupt which claimed 'CM', is that right? Should we have to same
>> its original value and restore it later?
>
> We don't need to save and restore, since INTERRUPT_CRITICAL_SECTION is
> almost always zero except in very specific situations.
>
>> 2. Should we lock interrupt for the whole operation of
>> read_lock()/read_unlock(), or we should leave interrupt critical
>> section if it run into  __raw_read_lock_slow() and before have to
>> delay_backoff() some time, and re-enter interrupt critical section
>> again before TNS?
>
> Correct, the fix only holds the critical section around the tns and the
> write-back, not during the delay_backoff().
>
>> Bye the way, other RISC platforms, say ARM and MIPS, use store
>> conditional rather that TNS a temp value for lock-val, does Fx have
>> similar instructions?
>
> TILEPro does not have anything more than test-and-set; TILE-Gx (the 64-bit
> processor) has a full array of atomic instructions.
>
>> Adding that to SPR writes should be fine, but it may cause interrupt
>> delay a little more that other platform's read_lock()?
>
> A little, but I think it's in the noise relative to the basic cost of
> read_lock in the absence of full-fledged atomic instructions.
>
>> Another question: What NMI in the former mail means?
>
> Non-maskable interrupt, such as performance counter interrupts.
>
> --
> Chris Metcalf, Tilera Corp.
> http://www.tilera.com
>
>

I've got your source code, thank you very much.

There is still two more question:
1. Why we merge the inlined code and the *_slow into none inlined functions?
2. I've seen the use of 'mb()' in unlock operation, but we don't use
that in the lock operation.

I've released a temporary version with that modification under our
customer' demand, since they want to do a long time test though this
weekend. I'll appreciate that if you gave some comment on my
modifications:

*** /opt/TileraMDE-2.1.0.98943/tilepro/src/sys/linux/include/asm-tile/spinlock_32.h
    2010-04-02 11:07:47.000000000 +0800
--- include/asm-tile/spinlock_32.h      2011-02-18 17:09:40.000000000 +0800
***************
*** 12,17 ****
--- 12,27 ----
   *   more details.
   *
   * 32-bit SMP spinlocks.
+  *
+  *
+  * The use of TNS instruction cause race condition for system call and
+  * interrupt, so we have to lock interrupt when we trying lock-value.
+  * However, since write_lock() is exclusive so if we really need to
+  * operate it in interrupt then system call have to use write_lock_irqsave(),
+  * So it don't need to lock interrupt here.
+  * Spinlock is also exclusive so we don't take care about it.
+  *
+  * Modified by Cyberman Wu on Feb 18th, 2011.
   */

  #ifndef _ASM_TILE_SPINLOCK_32_H
*************** void __raw_read_unlock_slow(raw_rwlock_t
*** 86,91 ****
--- 96,114 ----
  void __raw_write_lock_slow(raw_rwlock_t *, u32);
  void __raw_write_unlock_slow(raw_rwlock_t *, u32);

+
+ static inline void __raw_read_lock_enter_critical(void)
+ {
+       BUG_ON(__insn_mfspr(SPR_INTERRUPT_CRITICAL_SECTION));
+       __insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 1);
+ }
+
+ static inline void __raw_read_lock_leave_critical(void)
+ {
+       __insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 0);
+ }
+
+
  /**
   * __raw_read_can_lock() - would read_trylock() succeed?
   */
*************** static inline int __raw_write_can_lock(r
*** 107,121 ****
   */
  static inline void __raw_read_lock(raw_rwlock_t *rwlock)
  {
!       u32 val = __insn_tns((int *)&rwlock->lock);
        if (unlikely(val << _RD_COUNT_WIDTH)) {
  #ifdef __TILECC__
  #pragma frequency_hint NEVER
  #endif
                __raw_read_lock_slow(rwlock, val);
                return;
        }
        rwlock->lock = val + (1 << _RD_COUNT_SHIFT);
  }

  /**
--- 130,148 ----
   */
  static inline void __raw_read_lock(raw_rwlock_t *rwlock)
  {
!     u32 val;
!       __raw_read_lock_enter_critical();
!       /*u32 */val = __insn_tns((int *)&rwlock->lock);
        if (unlikely(val << _RD_COUNT_WIDTH)) {
  #ifdef __TILECC__
  #pragma frequency_hint NEVER
  #endif
                __raw_read_lock_slow(rwlock, val);
+               __raw_read_lock_leave_critical();
                return;
        }
        rwlock->lock = val + (1 << _RD_COUNT_SHIFT);
+       __raw_read_lock_leave_critical();
  }

  /**
*************** static inline void __raw_write_lock(raw_
*** 140,154 ****
  static inline int __raw_read_trylock(raw_rwlock_t *rwlock)
  {
        int locked;
!       u32 val = __insn_tns((int *)&rwlock->lock);
        if (unlikely(val & 1)) {
  #ifdef __TILECC__
  #pragma frequency_hint NEVER
  #endif
!               return __raw_read_trylock_slow(rwlock);
        }
        locked = (val << _RD_COUNT_WIDTH) == 0;
        rwlock->lock = val + (locked << _RD_COUNT_SHIFT);
        return locked;
  }

--- 167,187 ----
  static inline int __raw_read_trylock(raw_rwlock_t *rwlock)
  {
        int locked;
!     u32 val;
!       __raw_read_lock_enter_critical();
!       /*u32 */val = __insn_tns((int *)&rwlock->lock);
        if (unlikely(val & 1)) {
  #ifdef __TILECC__
  #pragma frequency_hint NEVER
  #endif
!               // return __raw_read_trylock_slow(rwlock);
!               locked =__raw_read_trylock_slow(rwlock);
!               __raw_read_lock_leave_critical();
!               return locked;
        }
        locked = (val << _RD_COUNT_WIDTH) == 0;
        rwlock->lock = val + (locked << _RD_COUNT_SHIFT);
+       __raw_read_lock_leave_critical();
        return locked;
  }

*************** static inline void __raw_read_unlock(raw
*** 184,198 ****
--- 217,234 ----
  {
        u32 val;
        mb();
+       __raw_read_lock_enter_critical();
        val = __insn_tns((int *)&rwlock->lock);
        if (unlikely(val & 1)) {
  #ifdef __TILECC__
  #pragma frequency_hint NEVER
  #endif
                __raw_read_unlock_slow(rwlock);
+               __raw_read_lock_leave_critical();
                return;
        }
        rwlock->lock = val - (1 << _RD_COUNT_SHIFT);
+       __raw_read_lock_leave_critical();
  }



--- /opt/TileraMDE-2.1.0.98943/tilepro/src/sys/linux/arch/tile/lib/spinlock_32.c
       2010-04-02 11:08:02.000000000 +0800
+++ arch/tile/lib/spinlock_32.c 2011-02-18 16:05:31.000000000 +0800
@@ -98,7 +98,18 @@ static inline u32 get_rwlock(raw_rwlock_
 #ifdef __TILECC__
 #pragma frequency_hint NEVER
 #endif
+            /*
+             * get_rwlock() now have to be called in Interrupt
+             * Critical Section, so it can't be called in the
+             * these __raw_write_xxx() anymore!!!!!
+             *
+             * We leave Interrupt Critical Section for making
+             * interrupt delay minimal.
+             * Is that really needed???
+             */
+            __raw_read_lock_leave_critical();
                        delay_backoff(iterations++);
+            __raw_read_lock_enter_critical();
                        continue;
                }
                return val;
@@ -152,7 +163,14 @@ void __raw_read_lock_slow(raw_rwlock_t *
        do {
                if (!(val & 1))
                        rwlock->lock = val;
+        /*
+         * We leave Interrupt Critical Section for making
+         * interrupt delay minimal.
+         * Is that really needed???
+         */
+        __raw_read_lock_leave_critical();
                delay_backoff(iterations++);
+        __raw_read_lock_enter_critical();
                val = __insn_tns((int *)&rwlock->lock);
        } while ((val << RD_COUNT_WIDTH) != 0);
        rwlock->lock = val + (1 << RD_COUNT_SHIFT);
@@ -166,23 +184,30 @@ void __raw_write_lock_slow(raw_rwlock_t
         * when we compare them.
         */
        u32 my_ticket_;
+       u32 iterations = 0;

-       /* Take out the next ticket; this will also stop would-be readers. */
-       if (val & 1)
-               val = get_rwlock(rwlock);
-       rwlock->lock = __insn_addb(val, 1 << WR_NEXT_SHIFT);
+       /*
+        * Wait until there are no readers, then bump up the next
+        * field and capture the ticket value.
+        */
+       for (;;) {
+               if (!(val & 1)) {
+                       if ((val >> RD_COUNT_SHIFT) == 0)
+                               break;
+                       rwlock->lock = val;
+               }
+               delay_backoff(iterations++);
+               val = __insn_tns((int *)&rwlock->lock);
+       }

-       /* Extract my ticket value from the original word. */
+       /* Take out the next ticket and extract my ticket value. */
+       rwlock->lock = __insn_addb(val, 1 << WR_NEXT_SHIFT);
        my_ticket_ = val >> WR_NEXT_SHIFT;

-       /*
-        * Wait until the "current" field matches our ticket, and
-        * there are no remaining readers.
-        */
+       /* Wait until the "current" field matches our ticket. */
        for (;;) {
                u32 curr_ = val >> WR_CURR_SHIFT;
-               u32 readers = val >> RD_COUNT_SHIFT;
-               u32 delta = ((my_ticket_ - curr_) & WR_MASK) + !!readers;
+               u32 delta = ((my_ticket_ - curr_) & WR_MASK);
                if (likely(delta == 0))
                        break;


-- 
Cyberman Wu
