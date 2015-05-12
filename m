From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Tue, 12 May 2015 14:22:40 -0700
Message-ID: <55526F20.9020704@plumgrid.com>
References: <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia> <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net> <20150510234313.GA3176@salvia> <555044D8.3080606@plumgrid.com> <20150511133245.GA4430@salvia> <1431354912.566.15.camel@edumazet-glaptop2.roam.corp.google.com> <555134F4.80007@plumgrid.com> <1431387038.566.47.camel@edumazet-glaptop2.roam.corp.google.com> <20150512125526.GA3822@salvia> <5551FFA7.4060709@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34873 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933761AbbELVWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 17:22:43 -0400
Received: by pdbqd1 with SMTP id qd1so27416168pdb.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 14:22:42 -0700 (PDT)
In-Reply-To: <5551FFA7.4060709@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/15 6:27 AM, Daniel Borkmann wrote:
>
>> What's the i-cache size in your testbed?
>
> For the Xeon E3-1240, I get (via lscpu):
>
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              256K
> L3 cache:              8192K

my E5-1630 v3 @ 3.70GHz:
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              10240K

I think it's not cpu that is causing discrepancies
between our numbers, but the difference in compilers or flags.

Looking at Pablo's perf profile:
     36.12%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
     18.46%  kpktgend_0  [kernel.kallsyms]  [k] atomic_dec_and_test
     15.87%  kpktgend_0  [kernel.kallsyms]  [k] deliver_ptype_list_skb
      5.04%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
      4.81%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
      4.11%  kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
      3.89%  kpktgend_0  [kernel.kallsyms]  [k] ip_rcv

It means that deliver_ptype_list_skb() is not inlined, which is odd
and atomic_dec_and_test() from kfree_skb() is also not inlined either.
Both functions are marked 'static inline'. So I suspect the kernel was
compiled with some broken gcc or CONFIG_CC_OPTIMIZE_FOR_SIZE is set.
If gcc is old/broken, it's really bad, since it can be mis-optimizing
bunch of other things.
If optimize_for_size is set, then it's not great for performance
either, since compiler will be trying way too hard to squeeze
code size and losing performance left and right.
btw, there is patch pending on lkml to make
atomic_dec_and_test() __always_inline.

-Os is also causing static_key to ignore 'unlikely', so all cold
branches are generated as fall through which causing I-cache misses.
I've looked at net/core/dev.s with -Os and it's not pretty.
bstats_update, deliver_skb, deliver_ptype_list_skb are all not inlined.

There was a thread on lkml recently to request better behaving -Os from
gcc guys, but I think it didn't go anywhere.
