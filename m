From: Eric Dumazet <edumazet@google.com>
Subject: Re: [net-next:master 200/201] net/ipv4/inet_hashtables.c:620:13:
 warning: division by zero
Date: Tue, 26 May 2015 21:19:35 -0700
Message-ID: <CANn89iJJcN+eeCihxEEXToVLtRiDUoPRz-p8JcMiNLMs8LxgyQ@mail.gmail.com>
References: <201505271224.1OjJSiKk%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, netdev <netdev@vger.kernel.org>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33828 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbE0ETg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 00:19:36 -0400
Received: by igbhj9 with SMTP id hj9so77484570igb.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 21:19:35 -0700 (PDT)
In-Reply-To: <201505271224.1OjJSiKk%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This report seems bogus ?

The divide is guarded by

if (sizeof(spinlock_t) != 0) {
    ....
}



On Tue, May 26, 2015 at 9:09 PM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   d6a4e26afb80c049e7f94e1b7b506dcda61eee88
> commit: 095dc8e0c3686d586a01a50abc3e1bb9ac633054 [200/201] tcp: fix/cleanup inet_ehash_locks_alloc()
> config: cris-etrax-100lx_v2_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 095dc8e0c3686d586a01a50abc3e1bb9ac633054
>   # save the attached .config to linux build tree
>   make.cross ARCH=cris
>
> All warnings:
>
>    net/ipv4/inet_hashtables.c: In function 'inet_ehash_locks_alloc':
>>> net/ipv4/inet_hashtables.c:620:13: warning: division by zero [-Wdiv-by-zero]
>
> vim +620 net/ipv4/inet_hashtables.c
>
>    604          int i;
>    605
>    606          for (i = 0; i < INET_LHTABLE_SIZE; i++) {
>    607                  spin_lock_init(&h->listening_hash[i].lock);
>    608                  INIT_HLIST_NULLS_HEAD(&h->listening_hash[i].head,
>    609                                        i + LISTENING_NULLS_BASE);
>    610                  }
>    611  }
>    612  EXPORT_SYMBOL_GPL(inet_hashinfo_init);
>    613
>    614  int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
>    615  {
>    616          unsigned int i, nblocks = 1;
>    617
>    618          if (sizeof(spinlock_t) != 0) {
>    619                  /* allocate 2 cache lines or at least one spinlock per cpu */
>  > 620                  nblocks = max_t(unsigned int,
>    621                                  2 * L1_CACHE_BYTES / sizeof(spinlock_t),
>    622                                  1);
>    623                  nblocks = roundup_pow_of_two(nblocks * num_possible_cpus());
>    624
>    625                  /* no more locks than number of hash buckets */
>    626                  nblocks = min(nblocks, hashinfo->ehash_mask + 1);
>    627
>    628                  hashinfo->ehash_locks = kmalloc_array(nblocks, sizeof(spinlock_t),
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
