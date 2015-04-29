From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next] netif_receive_skb performance
Date: Tue, 28 Apr 2015 19:11:27 -0700
Message-ID: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34606 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031315AbbD2CLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 22:11:41 -0400
Received: by pdbqa5 with SMTP id qa5so13581634pdb.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 19:11:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

there were many requests for performance numbers in the past, but not
everyone has access to 10/40G nics and we need a common way to talk
about RX path performance without overhead of driver RX. That's
especially important when making changes to netif_receive_skb.

One would think that using pktgen and xmit into veth would do the trick,
but that's not the case, since clone/burst parameters are not avaiable, so
such approach doesn't stress rx path.
The patch 1 introduces 'rx' mode for pktgen which instead of sending
packets via ndo_start_xmit, delivers them to stack via netif_receive_skb.

It's typical usage:
$ sudo ./pktgen.sh eth0
...
Result: OK: 232376(c232372+d3) usec, 10000000 (60byte,0frags)
  43033682pps 20656Mb/sec (20656167360bps) errors: 10000000

which says that netif_receive_skb->ip_rcv->kfree_skb can drop cloned
packets at the rate of 43 M packet per second.
'pref report' looks as expected:
  37.69%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
  25.81%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
   7.22%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
   5.68%  kpktgend_0   [pktgen]          [k] pktgen_thread_worker

In this case pktgen script configured to use skb->dmac != eth0's mac,
so skb->pkt_type == PACKET_OTHERHOST and skbs are dropped immediately
by ip_rcv as expected.

Configuring dmac == eth0's mac we'll see 6.5 Mpps and 'perf report':
  21.97%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
   9.64%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
   8.44%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
   7.19%  kpktgend_0   [kernel.vmlinux]  [k] __skb_clone
   6.89%  kpktgend_0   [kernel.vmlinux]  [k] fib_validate_source
   5.36%  kpktgend_0   [kernel.vmlinux]  [k] ip_route_input_noref
   5.18%  kpktgend_0   [kernel.vmlinux]  [k] udp_v4_early_demux
   4.57%  kpktgend_0   [kernel.vmlinux]  [k] consume_skb
   4.42%  kpktgend_0   [kernel.vmlinux]  [k] skb_release_data
   3.90%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv_finish

The profile dump looks as expected for RX of UDP packets without local socket
except presence of __skb_clone. It's there since pktgen does
skb->users += burst and first thing ip_rcv does is skb_share_check.
So not exactly representative for normal udp receive, but precise enough to
simulate udp receive with taps on eth0 which do skb_clone as well.

My main goal was to benchmark ingress qdisc.
So here are the numbers:
raw netif_receive_skb->ip_rcv->kfree_skb - 43 Mpps
adding ingress qdisc to eth0 drops performance to - 26 Mpps
adding 'u32 match u32 0 0' drops if further to - 22.4 Mpps
All as expected.

Now let's remove ingress spin_lock (the goal of John's patches) - 24.5 Mpps
Note this is single core receive. The boost from removal will be much higher
on a real nic with multiple cores servicing rx irqs.

With my experimental replacement of ingress_queue/sch_ingress with
ingress_filter_list and 'u32 match u32 0 0' classifier - 26.2 Mpps

Experimental ingress_filter_list and JITed bpf 'return 0' program - 27.2 Mpps

So there is definitely room for further improvements in ingress
qdisc beyond dropping spin_lock.

Few other numbers for comparison with dmac == eth0 mac:
no qdisc, with conntrack and empty iptables - 2.2 Mpps
   7.65%  kpktgend_0   [nf_conntrack]    [k] nf_conntrack_in
   7.62%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
   5.44%  kpktgend_0   [kernel.vmlinux]  [k] __call_rcu.constprop.63
   3.71%  kpktgend_0   [kernel.vmlinux]  [k] nf_iterate
   3.59%  kpktgend_0   [ip_tables]       [k] ipt_do_table

no qdisc, unload conntrack, keep empty iptables - 5.4 Mpps 
  18.17%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
   8.31%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
   7.97%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
   7.53%  kpktgend_0   [ip_tables]       [k] ipt_do_table

no qdisc, unload conntrack, unload iptables - 6.5 Mpps
  21.97%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
   9.64%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
   8.44%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
   7.19%  kpktgend_0   [kernel.vmlinux]  [k] __skb_clone
   6.89%  kpktgend_0   [kernel.vmlinux]  [k] fib_validate_source

After I'm done with ingress qdisc improvements, I'm planning
to look at netif_receive_skb itself, since it looks a bit too hot.

Alexei Starovoitov (1):
  pktgen: introduce 'rx' mode

 net/core/pktgen.c |   30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

-- 
1.7.9.5
