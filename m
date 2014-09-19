From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: qdisc/UDP_STREAM: measuring effect of qdisc bulk dequeue
Date: Fri, 19 Sep 2014 12:44:25 +0200
Message-ID: <20140919124425.1fdfb5ee@redhat.com>
References: <20140919123536.636fa226@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbaISKok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 06:44:40 -0400
In-Reply-To: <20140919123536.636fa226@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 19 Sep 2014 12:35:36 +0200
Jesper Dangaard Brouer <jbrouer@redhat.com> wrote:
 
> This testing relates to my qdisc bulk dequeue patches:
>  http://thread.gmane.org/gmane.linux.network/328829/focus=328951


I will quickly followup, with a more real-life use-case for qdisc layer
dequeue bulking (as Eric dislikes my artificial benchmarks ;-)).

Using UDP_STREAM on 1Gbit/s driver igb, I can show that the
_raw_spin_lock calls are reduced with approx 3%, when enabling
bulking of just 2 packets.

This test can only demonstrates a CPU usage reduction, as the
throughput is already at maximum link (bandwidth) capacity.


Notice netperf option "-m 1472" which makes sure we are not sending
UDP IP-fragments::

 netperf -H 192.168.111.2 -t UDP_STREAM -l 120 -- -m 1472


Results from perf diff::

 # Command: perf diff
 # Event 'cycles'
 # Baseline  Delta    Symbol
 # no-bulk   bulk(1)
 # ........  .......  .........................................
 #
     7.05%   -3.03%  [k] _raw_spin_lock
     6.34%   +0.23%  [k] copy_user_enhanced_fast_string
     6.30%   +0.26%  [k] fib_table_lookup
     3.03%   +0.01%  [k] __slab_free
     3.00%   +0.08%  [k] intel_idle
     2.49%   +0.05%  [k] sock_alloc_send_pskb
     2.31%   +0.30%  netperf  [.] send_omni_inner
     2.12%   +0.12%  netperf  [.] send_data
     2.11%   +0.10%  [k] udp_sendmsg
     1.96%   +0.02%  [k] __ip_append_data
     1.48%   -0.01%  [k] __alloc_skb
     1.46%   +0.07%  [k] __mkroute_output
     1.34%   +0.05%  [k] __ip_select_ident
     1.29%   +0.03%  [k] check_leaf
     1.27%   +0.09%  [k] __skb_get_hash

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


Settings::

 export N=0; sudo sh -c "echo $N > /proc/sys/net/core/qdisc_bulk_dequeue_limit"; \
 grep -H . /proc/sys/net/core/qdisc_bulk_dequeue_limit
 /proc/sys/net/core/qdisc_bulk_dequeue_limit:0

 export N=1; sudo sh -c "echo $N > /proc/sys/net/core/qdisc_bulk_dequeue_limit"; \
 grep -H . /proc/sys/net/core/qdisc_bulk_dequeue_limit
 /proc/sys/net/core/qdisc_bulk_dequeue_limit:1
