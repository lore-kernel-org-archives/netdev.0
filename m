From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH v2] net/irda: fix lockdep annotation
Date: Mon, 16 Jan 2017 22:11:41 +0100
Message-ID: <CACT4Y+YkQT=VANfHurWY=LCqc2CP999=0bh2gyjTvem2Nhokgw@mail.gmail.com>
References: <20170116145129.102159-1-dvyukov@google.com> <201701170149.G5mmkfWa%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, Dave Jones <davej@redhat.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        David Miller <davem@davemloft.net>,
        Alexander Potapenko <glider@google.com>,
        andreyknvl <andreyknvl@google.com>,
        netdev <netdev@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33238 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751104AbdAPVMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:12:03 -0500
Received: by mail-lf0-f49.google.com with SMTP id k86so92761836lfi.0
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 13:12:02 -0800 (PST)
In-Reply-To: <201701170149.G5mmkfWa%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 7:09 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Dmitry,
>
> [auto build test ERROR on tip/locking/core]
> [also build test ERROR on v4.10-rc4 next-20170116]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Dmitry-Vyukov/net-irda-fix-lockdep-annotation/20170117-001737
> config: i386-defconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All error/warnings (new ones prefixed by >>):
>
>    In file included from include/linux/mmzone.h:7:0,
>                     from include/linux/gfp.h:5,
>                     from include/linux/slab.h:14,
>                     from drivers/gpu/drm/i915/i915_sw_fence.c:10:
>    drivers/gpu/drm/i915/i915_sw_fence.c: In function '__i915_sw_fence_wake_up_all':
>>> include/linux/spinlock.h:217:3: error: void value not ignored as it ought to be
>       (void)subclass;      \
>
>>> include/linux/spinlock.h:335:2: note: in expansion of macro 'raw_spin_lock_irqsave_nested'
>      raw_spin_lock_irqsave_nested(spinlock_check(lock), flags, subclass); \
>      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>> drivers/gpu/drm/i915/i915_sw_fence.c:68:2: note: in expansion of macro 'spin_lock_irqsave_nested'
>      spin_lock_irqsave_nested(&x->lock, flags, 1 + !!continuation);
>      ^~~~~~~~~~~~~~~~~~~~~~~~


Mailed v3.

> vim +217 include/linux/spinlock.h
>
>    211                  typecheck(unsigned long, flags);                        \
>    212                  flags = _raw_spin_lock_irqsave_nested(lock, subclass);  \
>    213          } while (0)
>    214  #else
>    215  #define raw_spin_lock_irqsave_nested(lock, flags, subclass)             \
>    216          do {                                                            \
>  > 217                  (void)subclass;                                         \
>    218                  typecheck(unsigned long, flags);                        \
>    219                  flags = _raw_spin_lock_irqsave(lock);                   \
>    220          } while (0)
>    221  #endif
>    222
>    223  #else
>    224
>    225  #define raw_spin_lock_irqsave(lock, flags)              \
>    226          do {                                            \
>    227                  typecheck(unsigned long, flags);        \
>    228                  _raw_spin_lock_irqsave(lock, flags);    \
>    229          } while (0)
>    230
>    231  #define raw_spin_lock_irqsave_nested(lock, flags, subclass)     \
>    232          raw_spin_lock_irqsave(lock, flags)
>    233
>    234  #endif
>    235
>    236  #define raw_spin_lock_irq(lock)         _raw_spin_lock_irq(lock)
>    237  #define raw_spin_lock_bh(lock)          _raw_spin_lock_bh(lock)
>    238  #define raw_spin_unlock(lock)           _raw_spin_unlock(lock)
>    239  #define raw_spin_unlock_irq(lock)       _raw_spin_unlock_irq(lock)
>    240
>    241  #define raw_spin_unlock_irqrestore(lock, flags)         \
>    242          do {                                                    \
>    243                  typecheck(unsigned long, flags);                \
>    244                  _raw_spin_unlock_irqrestore(lock, flags);       \
>    245          } while (0)
>    246  #define raw_spin_unlock_bh(lock)        _raw_spin_unlock_bh(lock)
>    247
>    248  #define raw_spin_trylock_bh(lock) \
>    249          __cond_lock(lock, _raw_spin_trylock_bh(lock))
>    250
>    251  #define raw_spin_trylock_irq(lock) \
>    252  ({ \
>    253          local_irq_disable(); \
>    254          raw_spin_trylock(lock) ? \
>    255          1 : ({ local_irq_enable(); 0;  }); \
>    256  })
>    257
>    258  #define raw_spin_trylock_irqsave(lock, flags) \
>    259  ({ \
>    260          local_irq_save(flags); \
>    261          raw_spin_trylock(lock) ? \
>    262          1 : ({ local_irq_restore(flags); 0; }); \
>    263  })
>    264
>    265  /**
>    266   * raw_spin_can_lock - would raw_spin_trylock() succeed?
>    267   * @lock: the spinlock in question.
>    268   */
>    269  #define raw_spin_can_lock(lock) (!raw_spin_is_locked(lock))
>    270
>    271  /* Include rwlock functions */
>    272  #include <linux/rwlock.h>
>    273
>    274  /*
>    275   * Pull the _spin_*()/_read_*()/_write_*() functions/declarations:
>    276   */
>    277  #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
>    278  # include <linux/spinlock_api_smp.h>
>    279  #else
>    280  # include <linux/spinlock_api_up.h>
>    281  #endif
>    282
>    283  /*
>    284   * Map the spin_lock functions to the raw variants for PREEMPT_RT=n
>    285   */
>    286
>    287  static __always_inline raw_spinlock_t *spinlock_check(spinlock_t *lock)
>    288  {
>    289          return &lock->rlock;
>    290  }
>    291
>    292  #define spin_lock_init(_lock)                           \
>    293  do {                                                    \
>    294          spinlock_check(_lock);                          \
>    295          raw_spin_lock_init(&(_lock)->rlock);            \
>    296  } while (0)
>    297
>    298  static __always_inline void spin_lock(spinlock_t *lock)
>    299  {
>    300          raw_spin_lock(&lock->rlock);
>    301  }
>    302
>    303  static __always_inline void spin_lock_bh(spinlock_t *lock)
>    304  {
>    305          raw_spin_lock_bh(&lock->rlock);
>    306  }
>    307
>    308  static __always_inline int spin_trylock(spinlock_t *lock)
>    309  {
>    310          return raw_spin_trylock(&lock->rlock);
>    311  }
>    312
>    313  #define spin_lock_nested(lock, subclass)                        \
>    314  do {                                                            \
>    315          raw_spin_lock_nested(spinlock_check(lock), subclass);   \
>    316  } while (0)
>    317
>    318  #define spin_lock_nest_lock(lock, nest_lock)                            \
>    319  do {                                                                    \
>    320          raw_spin_lock_nest_lock(spinlock_check(lock), nest_lock);       \
>    321  } while (0)
>    322
>    323  static __always_inline void spin_lock_irq(spinlock_t *lock)
>    324  {
>    325          raw_spin_lock_irq(&lock->rlock);
>    326  }
>    327
>    328  #define spin_lock_irqsave(lock, flags)                          \
>    329  do {                                                            \
>    330          raw_spin_lock_irqsave(spinlock_check(lock), flags);     \
>    331  } while (0)
>    332
>    333  #define spin_lock_irqsave_nested(lock, flags, subclass)                 \
>    334  do {                                                                    \
>  > 335          raw_spin_lock_irqsave_nested(spinlock_check(lock), flags, subclass); \
>    336  } while (0)
>    337
>    338  static __always_inline void spin_unlock(spinlock_t *lock)
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
