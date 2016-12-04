From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCN net-next] net_sched: gen_estimator: complete rewrite of
 rate estimators
Date: Sun, 4 Dec 2016 20:42:38 +0800
Message-ID: <201612042054.bTPqn6d2%fengguang.wu@intel.com>
References: <1480835273.18162.457.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:47603 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbcLDMnM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Dec 2016 07:43:12 -0500
Content-Disposition: inline
In-Reply-To: <1480835273.18162.457.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Eric,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/net_sched-gen_estimator-complete-rewrite-of-rate-estimators/20161204-185201
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   include/net/sock.h:467: warning: No description found for parameter '__sk_flags_offset[0]'
   include/net/sock.h:467: warning: No description found for parameter 'sk_uid'
   net/core/gen_stats.c:209: warning: No description found for parameter 'ptr'
   net/core/gen_stats.c:209: warning: Excess function parameter 'b' description in 'gnet_stats_copy_rate_est'
   net/core/gen_stats.c:209: warning: Excess function parameter 'r' description in 'gnet_stats_copy_rate_est'
>> net/core/gen_estimator.c:191: warning: No description found for parameter 'ptr'
>> net/core/gen_estimator.c:191: warning: Excess function parameter 'est' description in 'gen_kill_estimator'
   net/core/gen_estimator.c:221: warning: No description found for parameter 'ptr'
>> net/core/gen_estimator.c:221: warning: Excess function parameter 'rate_est' description in 'gen_replace_estimator'
   net/core/gen_estimator.c:233: warning: No description found for parameter 'ptr'
>> net/core/gen_estimator.c:233: warning: Excess function parameter 'rate_est' description in 'gen_estimator_active'

vim +/ptr +191 net/core/gen_estimator.c

2db8f09a Eric Dumazet        2016-12-03  185   * @est: rate estimator
^1da177e Linus Torvalds      2005-04-16  186   *
2db8f09a Eric Dumazet        2016-12-03  187   * Removes the rate estimator.
0929c2dd Ranko Zivojnovic    2007-07-16  188   *
^1da177e Linus Torvalds      2005-04-16  189   */
2db8f09a Eric Dumazet        2016-12-03  190  void gen_kill_estimator(struct net_rate_estimator __rcu **ptr)
^1da177e Linus Torvalds      2005-04-16 @191  {
2db8f09a Eric Dumazet        2016-12-03  192  	struct net_rate_estimator *est;
^1da177e Linus Torvalds      2005-04-16  193  
2db8f09a Eric Dumazet        2016-12-03  194  	est = xchg((__force struct net_rate_estimator **)ptr, NULL);
2db8f09a Eric Dumazet        2016-12-03  195  	if (est) {
2db8f09a Eric Dumazet        2016-12-03  196  		del_timer_sync(&est->timer);
2db8f09a Eric Dumazet        2016-12-03  197  		kfree_rcu(est, rcu);
^1da177e Linus Torvalds      2005-04-16  198  	}
^1da177e Linus Torvalds      2005-04-16  199  }
c1b56878 Stephen Hemminger   2008-11-25  200  EXPORT_SYMBOL(gen_kill_estimator);
^1da177e Linus Torvalds      2005-04-16  201  
^1da177e Linus Torvalds      2005-04-16  202  /**
96750162 Jarek Poplawski     2008-01-21  203   * gen_replace_estimator - replace rate estimator configuration
^1da177e Linus Torvalds      2005-04-16  204   * @bstats: basic statistics
e9fc2f05 Luis de Bethencourt 2016-03-19  205   * @cpu_bstats: bstats per cpu
^1da177e Linus Torvalds      2005-04-16  206   * @rate_est: rate estimator statistics
^1da177e Linus Torvalds      2005-04-16  207   * @stats_lock: statistics lock
edb09eb1 Eric Dumazet        2016-06-06  208   * @running: qdisc running seqcount (might be NULL)
^1da177e Linus Torvalds      2005-04-16  209   * @opt: rate estimator configuration TLV
^1da177e Linus Torvalds      2005-04-16  210   *
^1da177e Linus Torvalds      2005-04-16  211   * Replaces the configuration of a rate estimator by calling
^1da177e Linus Torvalds      2005-04-16  212   * gen_kill_estimator() and gen_new_estimator().
^1da177e Linus Torvalds      2005-04-16  213   *
^1da177e Linus Torvalds      2005-04-16  214   * Returns 0 on success or a negative error code.
^1da177e Linus Torvalds      2005-04-16  215   */
c1a8f1f1 Eric Dumazet        2009-08-16  216  int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
22e0f8b9 John Fastabend      2014-09-28  217  			  struct gnet_stats_basic_cpu __percpu *cpu_bstats,
2db8f09a Eric Dumazet        2016-12-03  218  			  struct net_rate_estimator __rcu **ptr,
edb09eb1 Eric Dumazet        2016-06-06  219  			  spinlock_t *stats_lock,
edb09eb1 Eric Dumazet        2016-06-06  220  			  seqcount_t *running, struct nlattr *opt)
^1da177e Linus Torvalds      2005-04-16 @221  {
2db8f09a Eric Dumazet        2016-12-03  222  	return gen_new_estimator(bstats, cpu_bstats, ptr, stats_lock, running, opt);
^1da177e Linus Torvalds      2005-04-16  223  }
c1b56878 Stephen Hemminger   2008-11-25  224  EXPORT_SYMBOL(gen_replace_estimator);
^1da177e Linus Torvalds      2005-04-16  225  
c1b56878 Stephen Hemminger   2008-11-25  226  /**
c1b56878 Stephen Hemminger   2008-11-25  227   * gen_estimator_active - test if estimator is currently in use
2db8f09a Eric Dumazet        2016-12-03  228   * @rate_est: rate estimator
c1b56878 Stephen Hemminger   2008-11-25  229   *
244e6c2d Jarek Poplawski     2008-11-26  230   * Returns true if estimator is active, and false if not.
c1b56878 Stephen Hemminger   2008-11-25  231   */
2db8f09a Eric Dumazet        2016-12-03  232  bool gen_estimator_active(struct net_rate_estimator __rcu **ptr)
c1b56878 Stephen Hemminger   2008-11-25 @233  {
2db8f09a Eric Dumazet        2016-12-03  234  	return !!rcu_access_pointer(*ptr);
2db8f09a Eric Dumazet        2016-12-03  235  }
2db8f09a Eric Dumazet        2016-12-03  236  EXPORT_SYMBOL(gen_estimator_active);

:::::: The code at line 191 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--h31gzZEtNLTqOjlF
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--h31gzZEtNLTqOjlF--
