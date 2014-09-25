From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 16:57:38 +0200
Message-ID: <20140925165738.646d0783@redhat.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<54234225.5000503@mojatatu.com>
	<20140925102505.494acab1@redhat.com>
	<54240F34.1050707@mojatatu.com>
	<CA+mtBx8Nie9AiCG6iuY+EN7HiLAe-bxWpZxTpRhASmYabRUyFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	brouer@redhat.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbaIYO6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 10:58:05 -0400
In-Reply-To: <CA+mtBx8Nie9AiCG6iuY+EN7HiLAe-bxWpZxTpRhASmYabRUyFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2014 07:40:33 -0700
Tom Herbert <therbert@google.com> wrote:

> A few test results in patch 0 are good. I like to have results for
> with and without patch. These should two things: 1) Any regressions
> caused by the patch 2) Performance gains (in that order of importance
> :-) ). There doesn't need to be a lot here, just something reasonably
> representative, simple, and should be easily reproducible. My
> expectation in bulk dequeue is that we should see no obvious
> regression and hopefully an improvement in CPU utilization-- are you
> able to verify this?

We are saving 3% CPU, as I described in my post with subject:
"qdisc/UDP_STREAM: measuring effect of qdisc bulk dequeue":
 http://thread.gmane.org/gmane.linux.network/331152/focus=331154

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

A nitpick is that, this testing were done on V2 of the patchset.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
