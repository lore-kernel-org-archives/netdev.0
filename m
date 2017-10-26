From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint
 trace_tcp_retransmit_synack()
Date: Thu, 26 Oct 2017 11:13:27 +0800
Message-ID: <201710261134.MUf5E7cp%fengguang.wu@intel.com>
References: <20171024235709.2186047-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, alexei.starovoitov@gmail.com, kafai@fb.com,
        ast@fb.com, netdev@vger.kernel.org, liu.song.a23@gmail.com,
        Song Liu <songliubraving@fb.com>
To: Song Liu <songliubraving@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:41973 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752021AbdJZDO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 23:14:29 -0400
Content-Disposition: inline
In-Reply-To: <20171024235709.2186047-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Song,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Song-Liu/tcp-add-tracepoint-trace_tcp_retransmit_synack/20171026-010651
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +281 include/trace/events/tcp.h

   241	
   242		TP_PROTO(const struct sock *sk, const struct request_sock *req),
   243	
   244		TP_ARGS(sk, req),
   245	
   246		TP_STRUCT__entry(
   247			__field(const void *, skaddr)
   248			__field(const void *, req)
   249			__field(__u16, sport)
   250			__field(__u16, dport)
   251			__array(__u8, saddr, 4)
   252			__array(__u8, daddr, 4)
   253			__array(__u8, saddr_v6, 16)
   254			__array(__u8, daddr_v6, 16)
   255		),
   256	
   257		TP_fast_assign(
   258			struct inet_request_sock *ireq = inet_rsk(req);
   259			struct in6_addr *pin6;
   260			__be32 *p32;
   261	
   262			__entry->skaddr = sk;
   263			__entry->req = req;
   264	
   265			__entry->sport = ireq->ir_num;
   266			__entry->dport = ntohs(ireq->ir_rmt_port);
   267	
   268			p32 = (__be32 *) __entry->saddr;
   269			*p32 = ireq->ir_loc_addr;
   270	
   271			p32 = (__be32 *) __entry->daddr;
   272			*p32 = ireq->ir_rmt_addr;
   273	
 > 274	#if IS_ENABLED(CONFIG_IPV6)
   275			if (sk->sk_family == AF_INET6) {
   276				pin6 = (struct in6_addr *)__entry->saddr_v6;
   277				*pin6 = ireq->ir_v6_loc_addr;
   278				pin6 = (struct in6_addr *)__entry->daddr_v6;
   279				*pin6 = ireq->ir_v6_rmt_addr;
   280			} else
 > 281	#endif
   282			{
   283				pin6 = (struct in6_addr *)__entry->saddr_v6;
   284				ipv6_addr_set_v4mapped(ireq->ir_loc_addr, pin6);
   285				pin6 = (struct in6_addr *)__entry->daddr_v6;
   286				ipv6_addr_set_v4mapped(ireq->ir_rmt_addr, pin6);
   287			}
   288		),
   289	
   290		TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c",
   291			  __entry->sport, __entry->dport,
   292			  __entry->saddr, __entry->daddr,
   293			  __entry->saddr_v6, __entry->daddr_v6)
   294	);
   295	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
