From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: unsafe locks seen with netperf on net-2.6.29 tree
Date: Sat, 27 Dec 2008 12:38:55 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com>
	 <20081225112658.GA7260@gondor.apana.org.au>
 <1230300535.9487.292.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Eric Dumazet <dada1@cosmosbay.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63914 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536AbYL0TjJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 14:39:09 -0500
In-Reply-To: <1230300535.9487.292.camel@twins>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra wrote:
> On Thu, 2008-12-25 at 22:26 +1100, Herbert Xu wrote:
>> On Thu, Dec 25, 2008 at 10:25:44AM +0000, Jeff Kirsher wrote:
>>>
>>> [ 1439.758437]
>>> ====================================================== [
>>> 1439.758724] [ INFO: soft-safe -> soft-unsafe lock order detected ]
>>> [ 1439.758868] 2.6.28-rc8-net-next-igb #13 [ 1439.759007]
>>> ------------------------------------------------------ [
>>> 1439.759150] netperf/22302 [HC0[0]:SC0[1]:HE1:SE0] is trying to
>>> acquire: [ 1439.759293]  (&fbc->lock){--..}, at:
>>> [<ffffffff803691a6>] __percpu_counter_add+0x4a/0x6d [ 1439.759581]
>>> [ 1439.759582] and this task is already holding:
>>> [ 1439.759853]  (slock-AF_INET){-+..}, at: [<ffffffff804fdca6>]
>>> tcp_close+0x16c/0x2da [ 1439.760137] which would create a new lock
>>> dependency: [ 1439.762122]  (slock-AF_INET){-+..} ->
>>> (&fbc->lock){--..}
>>
>> This is a false positive.  The lock slock is not a normal lock.
>> It's an ancient creature that's a spinlock in interrupt context
>> and a semaphore in process context.
>>
>> In particular, holding slock in process context does not disable
>> softirqs and you're still allowed to take the spinlock portion of
>> slock on the same CPU through an interrupt.  What happens is that
>> the softirq will notice that the slock is already taken by process
>> context, and defer the work for later.
>
> Which doesn't seem to be relevant to the report in question.
>
> What happens is that two different percpu counters with different irq
> semantics get put in the same class (I suspect Eric never tested this
> stuff with lockdep enabled).
>
> Does the below -- which isn't even compile tested solve the issue?
>
> Jeff, would you, in future, take care not to word wrap splats like
> that,
> it takes way too much effort to untangle that mess.
>
> ---
> Subject: lockdep: annotate percpu_counter
>
> Classify percpu_counter instances similar to regular lock objects --
> that is, per instantiation site.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/percpu_counter.h |   14 ++++++++++----
>  lib/percpu_counter.c           |   18 ++++--------------
>  lib/proportions.c              |    6 +++---
>  mm/backing-dev.c               |    2 +-
>  4 files changed, 18 insertions(+), 22 deletions(-)
>
> diff --git a/include/linux/percpu_counter.h
> b/include/linux/percpu_counter.h
> index 9007ccd..a074d77 100644
> --- a/include/linux/percpu_counter.h
> +++ b/include/linux/percpu_counter.h
> @@ -30,8 +30,16 @@ struct percpu_counter {
>  #define FBC_BATCH    (NR_CPUS*4)
>  #endif
>
> -int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
> -int percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount);
> +int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
> +                       struct lock_class_key *key);
> +
> +#define percpu_counter_init(fbc, value)                                      \
> +     do {                                                            \
> +             static struct lock_class_key __key;                     \
> +                                                                     \
> +             __percpu_counter_init(fbc, value, &__key);              \
> +     } while (0)
> +
>  void percpu_counter_destroy(struct percpu_counter *fbc);
>  void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
>  void __percpu_counter_add(struct percpu_counter *fbc, s64 amount,
> s32 batch); @@ -85,8 +93,6 @@ static inline int
>       percpu_counter_init(struct percpu_counter *fbc, s64 amount) return
>  0; }
>
> -#define percpu_counter_init_irq percpu_counter_init
> -
>  static inline void percpu_counter_destroy(struct percpu_counter *fbc)
>  {
>  }
> diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
> index b255b93..4bb0ed3 100644
> --- a/lib/percpu_counter.c
> +++ b/lib/percpu_counter.c
> @@ -68,11 +68,11 @@ s64 __percpu_counter_sum(struct percpu_counter
>  *fbc) }
>  EXPORT_SYMBOL(__percpu_counter_sum);
>
> -static struct lock_class_key percpu_counter_irqsafe;
> -
> -int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
> +int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
> +                       struct lock_class_key *key)
>  {
>       spin_lock_init(&fbc->lock);
> +     lockdep_set_class(&fbc->lock, key);
>       fbc->count = amount;
>       fbc->counters = alloc_percpu(s32);
>       if (!fbc->counters)
> @@ -84,17 +84,7 @@ int percpu_counter_init(struct percpu_counter
>  *fbc, s64 amount) #endif
>       return 0;
>  }
> -EXPORT_SYMBOL(percpu_counter_init);
> -
> -int percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount)
> -{
> -     int err;
> -
> -     err = percpu_counter_init(fbc, amount);
> -     if (!err)
> -             lockdep_set_class(&fbc->lock, &percpu_counter_irqsafe);
> -     return err;
> -}
> +EXPORT_SYMBOL(__percpu_counter_init);
>
>  void percpu_counter_destroy(struct percpu_counter *fbc)
>  {
> diff --git a/lib/proportions.c b/lib/proportions.c
> index 4f387a6..7367f2b 100644
> --- a/lib/proportions.c
> +++ b/lib/proportions.c
> @@ -83,11 +83,11 @@ int prop_descriptor_init(struct prop_descriptor
>       *pd, int shift) pd->index = 0;
>       pd->pg[0].shift = shift;
>       mutex_init(&pd->mutex);
> -     err = percpu_counter_init_irq(&pd->pg[0].events, 0);
> +     err = percpu_counter_init(&pd->pg[0].events, 0);
>       if (err)
>               goto out;
>
> -     err = percpu_counter_init_irq(&pd->pg[1].events, 0);
> +     err = percpu_counter_init(&pd->pg[1].events, 0);
>       if (err)
>               percpu_counter_destroy(&pd->pg[0].events);
>
> @@ -191,7 +191,7 @@ int prop_local_init_percpu(struct
>       prop_local_percpu *pl) spin_lock_init(&pl->lock);
>       pl->shift = 0;
>       pl->period = 0;
> -     return percpu_counter_init_irq(&pl->events, 0);
> +     return percpu_counter_init(&pl->events, 0);
>  }
>
>  void prop_local_destroy_percpu(struct prop_local_percpu *pl)
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 801c08b..a7c6c56 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -223,7 +223,7 @@ int bdi_init(struct backing_dev_info *bdi)
>       bdi->max_prop_frac = PROP_FRAC_BASE;
>
>       for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
> -             err = percpu_counter_init_irq(&bdi->bdi_stat[i], 0);
> +             err = percpu_counter_init(&bdi->bdi_stat[i], 0);
>               if (err)
>                       goto err;
>       }

This patch fails to compile:

mm/backing-dev.c: In function 'bdi_init':
mm/backing-dev.c:226: error: expected expression bedore 'do'

Thakns,
Emil
