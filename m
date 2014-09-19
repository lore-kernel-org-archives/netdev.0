From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: qdisc/trafgen: Measuring effect of qdisc bulk dequeue, with trafgen
Date: Fri, 19 Sep 2014 12:35:36 +0200
Message-ID: <20140919123536.636fa226@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbaISKf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 06:35:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This experiment were about finding the tipping-point, when bulking
from the qdisc kicks in.  This is an artificial benchmark.

This testing relates to my qdisc bulk dequeue patches:
 http://thread.gmane.org/gmane.linux.network/328829/focus=328951

My point have always been, we should only start bulking packets when
really needed, I dislike attempts to delay TX in antisipation of
packets arriving shortly (due to the added latency).  IMHO the qdisc
layer seems the right place "see" when bulking makes sense.

The reason behind this test is, there is two code paths in the qdisc
layer.  1) when qdisc is empty we allow packet to directly call
sch_direct_xmit(), 2) when qdisc contains packet we go through a more
expensive process of enqueue, dequeue and possibly rescheduling a
softirq.

Thus, the cost when the qdisc kicks-in should be slightly higher.  My
qdisc bulk dequeue patch, should help us actually getting faster in
this case.  Below results (with dequeue bulking max 4 packets) show
that, this was true, as expected the locking cost were reduced, giving
us an actual speedup.


Testing this tipping point is hard, but found an trafgen setup, that
were just balancing on this tipping point, single CPU 1Gbit/s setup
driver igb.

 # trafgen --cpp --dev eth1 --conf udp_example02_const.trafgen -V  --qdisc-path -t0 --cpus 1

With this specific trafgen setup, I could show that: when qdisc queue
was empty I could not hit wirespeed 1G.

* instant rx:0 tx:1423314 pps n:60 average: rx:0 tx:1423454 pps
  (instant variation TX -0.069 ns (min:-0.707 max:0.392) RX 0.000 ns)

Perf showed the top#1 (13.49%) item was _raw_spin_lock called 81.32%
by sch_direct_xmit() and 16.92% by __dev_queue_xmit()

Sometimes by itself trafgen, creates a qdisc backlog, and _then_ the
qdisc bulking kicks-in. Resulting in full 1G wirespeed.

* instant rx:0 tx:1489324 pps n:29 average: rx:0 tx:1489263 pps
 (instant variation TX 0.028 ns (min:-0.040 max:0.028) RX 0.000 ns)
* Diff: (1/1423314*10^9)-(1/1489324*10^9) = 31ns

The process could be triggered by e.g. starting a netperf on another
CPU, cause qdisc to backlog for the trafgen-qdisc, when stopping the
netperf the trafgen-qdisc keep backlogged (at least for a while), and
NOW it hits wirespeed 1G.

Perf record/diff showed exactly what was expect: The _raw_spin_lock
was now top#3 with 6.09% (down with 7.20%).  The distribution of
callers (of _raw_spin_lock) have changed (and sort-of swapped) with
58.64% by __dev_queue_xmit() and only 33.54% by sch_direct_xmit().

# perf diff
# Baseline    Delta  Symbol
# no-bulk    bulk(4)
# ........  .......  .........................
    13.55%   -7.20%  [k] _raw_spin_lock
    11.88%   -0.06%  [k] sock_alloc_send_pskb
     6.24%   +0.12%  [k] packet_snd
     3.66%   -1.34%  [k] igb_tx_map
     3.58%   +0.07%  [k] __alloc_skb
     2.86%   +0.16%  [k] __dev_queue_xmit

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
