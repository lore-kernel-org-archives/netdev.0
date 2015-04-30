From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Wed, 29 Apr 2015 18:16:35 -0700
Message-ID: <20150430011633.GA12674@Alexeis-MBP.westell.com>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <55417545.30103@iogearbox.net>
 <20150430003019.GE7025@acer.localdomain>
 <55417A3A.50405@iogearbox.net>
 <20150430004839.GG7025@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150430004839.GG7025@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 30, 2015 at 02:48:39AM +0200, Patrick McHardy wrote:
> Netfilter is based on hook chains. The cost when only using a single hook
> is minimal (as Pablo showed in his numbers), but even if only using
> TC and a single netfilter classifier chain, there has to be some relative
> ordering and the hooks provide this in a generic way.

Unfortunately the numbers that Pablo shown are not measuring
the right thing.

> 840203pps 403Mb/sec

this is 20 times less than what they should be.
Something else were measured together with netif_receive_skb.

I've applied these patches and see the following
for eth0 + ingress + u32:

18.0 Mpps
  21.43%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
   9.88%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
   9.79%  kpktgend_0   [cls_u32]         [k] u32_classify
   9.16%  kpktgend_0   [kernel.vmlinux]  [k] _raw_spin_lock
   8.16%  kpktgend_0   [kernel.vmlinux]  [k] nf_iterate
   5.28%  kpktgend_0   [sch_ingress]     [k] handle_ing
   4.51%  kpktgend_0   [sch_ingress]     [k] ingress_enqueue
   4.42%  kpktgend_0   [kernel.vmlinux]  [k] tc_classify_compat
   3.16%  kpktgend_0   [kernel.vmlinux]  [k] nf_hook_slow
   3.01%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
   2.70%  kpktgend_0   [kernel.vmlinux]  [k] tc_classify

without these patches:

22.4 Mpps
  25.89%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
  14.41%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
  14.05%  kpktgend_0   [kernel.vmlinux]  [k] _raw_spin_lock
  11.75%  kpktgend_0   [cls_u32]         [k] u32_classify
   6.48%  kpktgend_0   [sch_ingress]     [k] ingress_enqueue
   6.06%  kpktgend_0   [kernel.vmlinux]  [k] tc_classify_compat
   4.16%  kpktgend_0   [kernel.vmlinux]  [k] tc_classify
   3.77%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv

clearly nf_iterate/nf_hook_slow are slowing things down.

I've spent more than a week trying to speedup ingress qdisc
and, so far, got from 22.4 Mpps to 27.2 Mpps,
so this 'generalization' is totally not acceptable to me.

You're right that for 10 years no one cared about performance
of ingress qdisc, but that doesn't mean it's a wrong abstraction
and wrong architecture. Now I care about its performance and
I hope other people will do too.
So please leave ingress qdisc alone, this 'generalization'
is too costly.

That doesn't mean that netfilter shouldn't have its own hook
on ingress. Without patch 6, the set looks good.

