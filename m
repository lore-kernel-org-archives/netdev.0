From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 14:19:18 +0200
Message-ID: <20140827141918.198cba38@redhat.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755814AbaH0MTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 08:19:33 -0400
In-Reply-To: <20140825.163458.1117073971092495452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2014 16:34:58 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> Given Jesper's performance numbers, it's not the way to go.
> 
> Instead, go with a signalling scheme via new boolean skb->xmit_more.
> 
> This has several advantages:
> 
> 1) Nearly trivial driver support, just protect the tail pointer
>    update with the skb->xmit_more check.
> 
> 2) No extra indirect calls in the non-deferral cases.

Even-though it is obvious that this new API skb->xmit_more will not
hurt performance, especially given skb->xmit_more is always 0 in this
kernel, I've still run my pktgen performance tests.

Compared to baseline[1]: (averaged 5609929 pps) (details below signature)
 * (1/5609929*10^9)-(1/5603728*10^9) = -0.197ns

As expected, this API does not hurt performance (as -0.197ns is below
our accuracy levels).

[1] http://thread.gmane.org/gmane.linux.network/327254/focus=327838
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

Results: on branch bulking02
----------------------------

Kernel with skb->xmit_more API.

Kernel at:
 * commit a3d1214688d ("neigh: document gc_thresh2")

With no HT:
 * ethtool -C eth5 rx-usecs 30
 * tuned-adm profile latency-performance
Results (pktgen):
 * instant rx:1 tx:5604056 pps n:250 average: rx:1 tx:5604013 pps
  (instant variation TX 0.001 ns (min:-0.114 max:0.104) RX 0.000 ns)
 * instant rx:1 tx:5603388 pps n:87 average: rx:1 tx:5603872 pps
  (instant variation TX -0.015 ns (min:-0.031 max:0.060) RX 0.000 ns)
 * instant rx:1 tx:5604332 pps n:429 average: rx:1 tx:5603300 pps
  (instant variation TX 0.033 ns (min:-0.094 max:0.881) RX 0.000 ns)
 * Average: (5604013+5603872+5603300)/3 = 5603728

Compared to baseline: (averaged 5609929 pps)
 * (1/5609929*10^9)-(1/5603728*10^9) = -0.197ns
