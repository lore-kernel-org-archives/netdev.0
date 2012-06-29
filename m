From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 07:50:08 +0200
Message-ID: <1340949008.29822.73.camel@edumazet-glaptop>
References: <1340945592.29822.8.camel@edumazet-glaptop>
	<20120628.221252.2220466000873887315.davem@davemloft.net>
	<1340947448.29822.41.camel@edumazet-glaptop>
	<20120628.222934.767995619021650710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	ycheng@google.com, ncardwell@google.com, mattmathis@google.com
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <20120628.222934.767995619021650710.davem@davemloft.net>
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

On Thu, 2012-06-28 at 22:29 -0700, David Miller wrote:

> I am pretty sure the behavior in RED is intentional.
> 
> It's a soft push back on TCP.
> 

tcp_enter_cwr() is called the same for DROP and CN

> We're taking this path when we are unable to sucessfully ECN mark a
> packet.  But our intention was to do so.
> 

Hmm, problem is the sender thinks the packet was queued for
transmission.

        ret = macvlan_queue_xmit(skb, dev);
        if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
                struct macvlan_pcpu_stats *pcpu_stats;

                pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
                u64_stats_update_begin(&pcpu_stats->syncp);
                pcpu_stats->tx_packets++;
                pcpu_stats->tx_bytes += len;
                u64_stats_update_end(&pcpu_stats->syncp);
        } else {
                this_cpu_inc(vlan->pcpu_stats->tx_dropped);
        }

NET_XMIT_CN has a lazy semantic it seems.

I will just dont rely on it.
