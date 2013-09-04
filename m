From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Wed, 04 Sep 2013 13:26:56 +0800
Message-ID: <5226C4A0.6040709@redhat.com>
References: <1377816595.8277.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755374Ab3IDF1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 01:27:08 -0400
In-Reply-To: <1377816595.8277.54.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2013 06:49 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> - Uses perfect flow match (not stochastic hash like SFQ/FQ_codel)
> - Uses the new_flow/old_flow separation from FQ_codel
> - New flows get an initial credit allowing IW10 without added delay.
> - Special FIFO queue for high prio packets (no need for PRIO + FQ)
> - Uses a hash table of RB trees to locate the flows at enqueue() time
> - Smart on demand gc (at enqueue() time, RB tree lookup evicts old
>   unused flows)
> - Dynamic memory allocations.
> - Designed to allow millions of concurrent flows per Qdisc.
> - Small memory footprint : ~8K per Qdisc, and 104 bytes per flow.
> - Single high resolution timer for throttled flows (if any).
> - One RB tree to link throttled flows.
> - Ability to have a max rate per flow. We might add a socket option
>   to add per socket limitation.
>
> Attempts have been made to add TCP pacing in TCP stack, but this
> seems to add complex code to an already complex stack.
>
> TCP pacing is welcomed for flows having idle times, as the cwnd
> permits TCP stack to queue a possibly large number of packets.
>
[...]
>
> FQ gets a bunch of tunables as :
>
>   limit : max number of packets on whole Qdisc (default 10000)
>
>   flow_limit : max number of packets per flow (default 100)
>
>   quantum : the credit per RR round (default is 2 MTU)
>
>   initial_quantum : initial credit for new flows (default is 10 MTU)
>
>   maxrate : max per flow rate (default : unlimited)
>
>   buckets : number of RB trees (default : 1024) in hash table.
>                (consumes 8 bytes per bucket)
>
>   [no]pacing : disable/enable pacing (default is enable)
>
> All of them can be changed on a live qdisc.
>
> $ tc qd add dev eth0 root fq help
> Usage: ... fq [ limit PACKETS ] [ flow_limit PACKETS ]
>               [ quantum BYTES ] [ initial_quantum BYTES ]
>               [ maxrate RATE  ] [ buckets NUMBER ]
>               [ [no]pacing ]
>
> $ tc -s -d qd
> qdisc fq 8002: dev eth0 root refcnt 32 limit 10000p flow_limit 100p buckets 256 quantum 3028 initial_quantum 15140
>  Sent 216532416 bytes 148395 pkt (dropped 0, overlimits 0 requeues 14)
>  backlog 0b 0p requeues 14
>   511 flows, 511 inactive, 0 throttled
>   110 gc, 0 highprio, 0 retrans, 1143 throttled, 0 flows_plimit
>
>
> [1] Except if initial srtt is overestimated, as if using
> cached srtt in tcp metrics. We'll provide a fix for this issue.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
> v2: added initial_quantum support

I see both degradation and jitter when using fq with virtio-net. Guest
to guest performance drops from 8Gb/s to 3Gb/s-7Gb/s. Guest to local
host drops from 8Gb/s to 4Gb/s-6Gb/s. Guest to external host with ixgbe
drops from 9Gb/s to 7Gb/s

I didn't meet the issue when using sfq or disabling pacing.

So it looks like it was caused by the inaccuracy and jitter of the
pacing estimation in a virt guest?
