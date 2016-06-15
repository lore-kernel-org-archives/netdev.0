From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 4/5] netdev: implement infrastructure for threadable napi
 irq
Date: Wed, 15 Jun 2016 22:12:45 +0800
Message-ID: <201606152241.5pafsDna%fengguang.wu@intel.com>
References: <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on tip/irq/core]
[also build test ERROR on v4.7-rc3 next-20160615]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Paolo-Abeni/genirq-threadable-IRQ-support/20160615-214836
config: cris-etrax-100lx_v2_defconfig (attached as .config)
compiler: cris-linux-gcc (GCC) 4.6.3
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=cris 

All error/warnings (new ones prefixed by >>):

>> net/core/dev.c:3457:5: warning: "CONFIG_IRQ_FORCED_THREADING" is not defined [-Wundef]
   net/core/dev.c: In function '____napi_schedule':
>> net/core/dev.c:3516:3: error: implicit declaration of function 'napi_threaded_poll' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors

vim +/napi_threaded_poll +3516 net/core/dev.c

  3451	EXPORT_SYMBOL(netdev_max_backlog);
  3452	
  3453	int netdev_tstamp_prequeue __read_mostly = 1;
  3454	int netdev_budget __read_mostly = 300;
  3455	int weight_p __read_mostly = 64;            /* old backlog weight */
  3456	
> 3457	#if CONFIG_IRQ_FORCED_THREADING
  3458	static int napi_poll(struct napi_struct *n, struct list_head *repoll);
  3459	
  3460	static void napi_threaded_poll(struct napi_struct *napi)
  3461	{
  3462		unsigned long time_limit = jiffies + 2;
  3463		struct list_head dummy_repoll;
  3464		int budget = netdev_budget;
  3465		bool again = true;
  3466	
  3467		if (test_and_set_bit(NAPI_STATE_SCHED_THREAD, &napi->state))
  3468			return;
  3469	
  3470		local_irq_enable();
  3471		INIT_LIST_HEAD(&dummy_repoll);
  3472	
  3473		while (again) {
  3474			/* ensure that the poll list is not empty */
  3475			if (list_empty(&dummy_repoll))
  3476				list_add(&napi->poll_list, &dummy_repoll);
  3477	
  3478			budget -= napi_poll(napi, &dummy_repoll);
  3479	
  3480			if (napi_disable_pending(napi))
  3481				again = false;
  3482			else if (!test_bit(NAPI_STATE_SCHED, &napi->state))
  3483				again = false;
  3484			else if (kthread_should_stop())
  3485				again = false;
  3486	
  3487			if (!again || unlikely(budget <= 0 ||
  3488					       time_after_eq(jiffies, time_limit))) {
  3489				/* no need to reschedule if we are going to stop */
  3490				if (again)
  3491					cond_resched_softirq();
  3492				time_limit = jiffies + 2;
  3493				budget = netdev_budget;
  3494				rcu_bh_qs();
  3495				__kfree_skb_flush();
  3496			}
  3497		}
  3498	
  3499		clear_bit(NAPI_STATE_SCHED_THREAD, &napi->state);
  3500		local_irq_disable();
  3501	}
  3502	
  3503	static inline bool napi_is_threaded(struct napi_struct *napi)
  3504	{
  3505		return current == napi->thread;
  3506	}
  3507	#else
  3508	#define napi_is_threaded(napi) 0
  3509	#endif
  3510	
  3511	/* Called with irq disabled */
  3512	static inline void ____napi_schedule(struct softnet_data *sd,
  3513					     struct napi_struct *napi)
  3514	{
  3515		if (napi_is_threaded(napi)) {
> 3516			napi_threaded_poll(napi);
  3517			return;
  3518		}
  3519		list_add_tail(&napi->poll_list, &sd->poll_list);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--EeQfGwPcQSOJBaQU
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--EeQfGwPcQSOJBaQU--
