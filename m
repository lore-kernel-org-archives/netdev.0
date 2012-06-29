From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 01:04:29 -0700 (PDT)
Message-ID: <20120629.010429.52786940228506998.davem@davemloft.net>
References: <1340947448.29822.41.camel@edumazet-glaptop>
	<20120628.222934.767995619021650710.davem@davemloft.net>
	<1340949008.29822.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	ycheng@google.com, ncardwell@google.com, mattmathis@google.com
To: eric.dumazet@gmail.com
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1340949008.29822.73.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jun 2012 07:50:08 +0200

> Hmm, problem is the sender thinks the packet was queued for
> transmission.
> 
>         ret = macvlan_queue_xmit(skb, dev);
>         if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
>                 struct macvlan_pcpu_stats *pcpu_stats;
> 
>                 pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
>                 u64_stats_update_begin(&pcpu_stats->syncp);
>                 pcpu_stats->tx_packets++;
>                 pcpu_stats->tx_bytes += len;
>                 u64_stats_update_end(&pcpu_stats->syncp);
>         } else {
>                 this_cpu_inc(vlan->pcpu_stats->tx_dropped);
>         }

Ok, that is the meaning this has taken on.  Same test exists in
vlan_dev.c and this test used to be present also in the ipip.h macros
some time ago.

Nobody really does anything special with this value, except to
translate it to a zero 0 when propagating back to sockets.

The only thing it guards is the selection of which statistic to
increment.

For all practical purposes it is treated as NET_XMIT_SUCCESS except in
one location, pktgen, where it causes the errors counter to increment.

Looking this over, I'd say we should just get rid of it.
