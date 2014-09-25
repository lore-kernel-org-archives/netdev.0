From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 08:12:15 -0700
Message-ID: <1411657935.16953.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com> <54234225.5000503@mojatatu.com>
	 <20140925102505.494acab1@redhat.com> <54240F34.1050707@mojatatu.com>
	 <CA+mtBx8Nie9AiCG6iuY+EN7HiLAe-bxWpZxTpRhASmYabRUyFA@mail.gmail.com>
	 <20140925165738.646d0783@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:48520 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbaIYPMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 11:12:17 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so2707149pad.0
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 08:12:16 -0700 (PDT)
In-Reply-To: <20140925165738.646d0783@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 16:57 +0200, Jesper Dangaard Brouer wrote:

> We are saving 3% CPU, as I described in my post with subject:
> "qdisc/UDP_STREAM: measuring effect of qdisc bulk dequeue":
>  http://thread.gmane.org/gmane.linux.network/331152/focus=331154
> 
> Using UDP_STREAM on 1Gbit/s driver igb, I can show that the
> _raw_spin_lock calls are reduced with approx 3%, when enabling
> bulking of just 2 packets.
> 
> This test can only demonstrates a CPU usage reduction, as the
> throughput is already at maximum link (bandwidth) capacity.
> 
> Notice netperf option "-m 1472" which makes sure we are not sending
> UDP IP-fragments::
> 
>  netperf -H 192.168.111.2 -t UDP_STREAM -l 120 -- -m 1472
> 
> Results from perf diff::
> 
>  # Command: perf diff
>  # Event 'cycles'
>  # Baseline  Delta    Symbol
>  # no-bulk   bulk(1)
>  # ........  .......  .........................................
>  #
>      7.05%   -3.03%  [k] _raw_spin_lock
>      6.34%   +0.23%  [k] copy_user_enhanced_fast_string
>      6.30%   +0.26%  [k] fib_table_lookup
>      3.03%   +0.01%  [k] __slab_free
>      3.00%   +0.08%  [k] intel_idle
>      2.49%   +0.05%  [k] sock_alloc_send_pskb
>      2.31%   +0.30%  netperf  [.] send_omni_inner
>      2.12%   +0.12%  netperf  [.] send_data
>      2.11%   +0.10%  [k] udp_sendmsg
>      1.96%   +0.02%  [k] __ip_append_data
>      1.48%   -0.01%  [k] __alloc_skb
>      1.46%   +0.07%  [k] __mkroute_output
>      1.34%   +0.05%  [k] __ip_select_ident
>      1.29%   +0.03%  [k] check_leaf
>      1.27%   +0.09%  [k] __skb_get_hash
> 
> A nitpick is that, this testing were done on V2 of the patchset.
> 

You could avoid the fib_table_lookup() cost by using netperf -- -N -n

(connected UDP sockets)

And of course reduce message sizes to increase pps
