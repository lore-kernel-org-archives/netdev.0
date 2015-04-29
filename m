From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH RFC net-next] netif_receive_skb performance
Date: Wed, 29 Apr 2015 11:37:41 +0200
Message-ID: <5540A665.7030406@iogearbox.net>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53620 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031630AbbD2Jhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 05:37:51 -0400
In-Reply-To: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2015 04:11 AM, Alexei Starovoitov wrote:
...
> It's typical usage:
> $ sudo ./pktgen.sh eth0
> ...
> Result: OK: 232376(c232372+d3) usec, 10000000 (60byte,0frags)
>    43033682pps 20656Mb/sec (20656167360bps) errors: 10000000
...
> My main goal was to benchmark ingress qdisc.
> So here are the numbers:
> raw netif_receive_skb->ip_rcv->kfree_skb - 43 Mpps
> adding ingress qdisc to eth0 drops performance to - 26 Mpps
> adding 'u32 match u32 0 0' drops if further to - 22.4 Mpps
> All as expected.
>
> Now let's remove ingress spin_lock (the goal of John's patches) - 24.5 Mpps
> Note this is single core receive. The boost from removal will be much higher
> on a real nic with multiple cores servicing rx irqs.
>
> With my experimental replacement of ingress_queue/sch_ingress with
> ingress_filter_list and 'u32 match u32 0 0' classifier - 26.2 Mpps
>
> Experimental ingress_filter_list and JITed bpf 'return 0' program - 27.2 Mpps
>
> So there is definitely room for further improvements in ingress
> qdisc beyond dropping spin_lock.

Is the below the case where the conntracker has always a miss and thus
each time needs to create new entries, iow pktgen DoS with random IPs?

> Few other numbers for comparison with dmac == eth0 mac:
> no qdisc, with conntrack and empty iptables - 2.2 Mpps
>     7.65%  kpktgend_0   [nf_conntrack]    [k] nf_conntrack_in
>     7.62%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
>     5.44%  kpktgend_0   [kernel.vmlinux]  [k] __call_rcu.constprop.63
>     3.71%  kpktgend_0   [kernel.vmlinux]  [k] nf_iterate
>     3.59%  kpktgend_0   [ip_tables]       [k] ipt_do_table
>
> no qdisc, unload conntrack, keep empty iptables - 5.4 Mpps
>    18.17%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
>     8.31%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
>     7.97%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
>     7.53%  kpktgend_0   [ip_tables]       [k] ipt_do_table
>
> no qdisc, unload conntrack, unload iptables - 6.5 Mpps
>    21.97%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
>     9.64%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
>     8.44%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
>     7.19%  kpktgend_0   [kernel.vmlinux]  [k] __skb_clone
>     6.89%  kpktgend_0   [kernel.vmlinux]  [k] fib_validate_source
>
> After I'm done with ingress qdisc improvements, I'm planning
> to look at netif_receive_skb itself, since it looks a bit too hot.
...
