From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 07/14] tcp: export data delivery rate
Date: Sat, 17 Sep 2016 11:56:59 +0800
Message-ID: <201609171104.7NaqQo41%fengguang.wu@intel.com>
References: <1474051743-13311-8-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:17387 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753480AbcIPTvX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 15:51:23 -0400
Content-Disposition: inline
In-Reply-To: <1474051743-13311-8-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yuchung,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Neal-Cardwell/tcp-BBR-congestion-control-algorithm/20160917-025323
config: arm-nhk8815_defconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All error/warnings (new ones prefixed by >>):

   In file included from arch/arm/include/asm/div64.h:126:0,
                    from include/linux/kernel.h:142,
                    from include/linux/crypto.h:21,
                    from include/crypto/hash.h:16,
                    from net/ipv4/tcp.c:250:
   net/ipv4/tcp.c: In function 'tcp_get_info':
   include/asm-generic/div64.h:207:28: warning: comparison of distinct pointer types lacks a cast
     (void)(((typeof((n)) *)0) == ((uint64_t *)0)); \
                               ^
>> net/ipv4/tcp.c:2794:3: note: in expansion of macro 'do_div'
      do_div(rate, intv);
      ^~~~~~
   In file included from arch/arm/include/asm/atomic.h:14:0,
                    from include/linux/atomic.h:4,
                    from include/linux/crypto.h:20,
                    from include/crypto/hash.h:16,
                    from net/ipv4/tcp.c:250:
   include/asm-generic/div64.h:220:25: warning: right shift count >= width of type [-Wshift-count-overflow]
     } else if (likely(((n) >> 32) == 0)) {  \
                            ^
   include/linux/compiler.h:167:40: note: in definition of macro 'likely'
    # define likely(x) __builtin_expect(!!(x), 1)
                                           ^
>> net/ipv4/tcp.c:2794:3: note: in expansion of macro 'do_div'
      do_div(rate, intv);
      ^~~~~~
   In file included from arch/arm/include/asm/div64.h:126:0,
                    from include/linux/kernel.h:142,
                    from include/linux/crypto.h:21,
                    from include/crypto/hash.h:16,
                    from net/ipv4/tcp.c:250:
>> include/asm-generic/div64.h:224:22: error: passing argument 1 of '__div64_32' from incompatible pointer type [-Werror=incompatible-pointer-types]
      __rem = __div64_32(&(n), __base); \
                         ^
>> net/ipv4/tcp.c:2794:3: note: in expansion of macro 'do_div'
      do_div(rate, intv);
      ^~~~~~
   In file included from include/linux/kernel.h:142:0,
                    from include/linux/crypto.h:21,
                    from include/crypto/hash.h:16,
                    from net/ipv4/tcp.c:250:
   arch/arm/include/asm/div64.h:32:24: note: expected 'uint64_t * {aka long long unsigned int *}' but argument is of type 'u32 * {aka unsigned int *}'
    static inline uint32_t __div64_32(uint64_t *n, uint32_t base)
                           ^~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/do_div +2794 net/ipv4/tcp.c

  2778		} while (u64_stats_fetch_retry_irq(&tp->syncp, start));
  2779		info->tcpi_segs_out = tp->segs_out;
  2780		info->tcpi_segs_in = tp->segs_in;
  2781	
  2782		notsent_bytes = READ_ONCE(tp->write_seq) - READ_ONCE(tp->snd_nxt);
  2783		info->tcpi_notsent_bytes = max(0, notsent_bytes);
  2784	
  2785		info->tcpi_min_rtt = tcp_min_rtt(tp);
  2786		info->tcpi_data_segs_in = tp->data_segs_in;
  2787		info->tcpi_data_segs_out = tp->data_segs_out;
  2788	
  2789		info->tcpi_delivery_rate_app_limited = tp->rate_app_limited ? 1 : 0;
  2790		rate = READ_ONCE(tp->rate_delivered);
  2791		intv = READ_ONCE(tp->rate_interval_us);
  2792		if (rate && intv) {
  2793			rate = rate * tp->mss_cache * USEC_PER_SEC;
> 2794			do_div(rate, intv);
  2795			put_unaligned(rate, &info->tcpi_delivery_rate);
  2796		}
  2797	}
  2798	EXPORT_SYMBOL_GPL(tcp_get_info);
  2799	
  2800	static int do_tcp_getsockopt(struct sock *sk, int level,
  2801			int optname, char __user *optval, int __user *optlen)
  2802	{

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--FCuugMFkClbJLl1L
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--FCuugMFkClbJLl1L--
