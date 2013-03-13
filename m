From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: packet fanout rollover during socket
 overload
Date: Wed, 13 Mar 2013 15:25:17 +0100
Message-ID: <1363184717.13690.53.camel@edumazet-glaptop>
References: <1363100153-24433-1-git-send-email-willemb@google.com>
	 <1363102664-5174-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:62234 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab3CMOZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:25:21 -0400
Received: by mail-ea0-f181.google.com with SMTP id z10so467503ead.40
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 07:25:20 -0700 (PDT)
In-Reply-To: <1363102664-5174-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-12 at 11:37 -0400, Willem de Bruijn wrote:
> Minimize packet drop in a fanout group. If one socket is full,
> roll over packets to another from the group. The intended use is
> to maintain flow affinity during normal load using an rxhash or
> cpu fanout policy, while dispersing unexpected traffic storms that
> hit a single cpu, such as spoofed-source DoS flows. This mechanism
> breaks affinity for flows arriving at saturated sockets during
> those conditions.
> 
> The patch adds a fanout policy ROLLOVER that rotates between sockets,
> filling each socket before moving to the next. It also adds a fanout
> flag ROLLOVER. If passed along with any other fanout policy, the
> primary policy is applied until the chosen socket is full. Then,
> rollover selects another socket, to delay packet drop until the
> entire system is saturated.
> 
> Probing sockets is not free. Selecting the last used socket, as
> rollover does, is a greedy approach that maximizes chance of
> success, at the cost of extreme load imbalance. In practice, with
> sufficiently long queues to handle rate, sockets are drained in
> parallel and load balance looks uniform in `top`.
> 
> To avoid contention, scales counters with number of sockets and
> accesses them lockfree. Values are bounds checked to ensure
> correctness. An alternative would be to use atomic rr_cur.
> 
> Tested using an application with 9 threads pinned to CPUs, one socket
> per thread and sufficient busywork per packet operation to limits each
> thread to handling 32 Kpps. When sent 500 Kpps single UDP stream
> packets, a FANOUT_CPU setup processes 32 Kpps in total without this
> patch, 270 Kpps with the patch. Tested with read() and with a packet
> ring (V1).
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  include/linux/if_packet.h |   2 +
>  net/packet/af_packet.c    | 112 ++++++++++++++++++++++++++++++++++++----------
>  2 files changed, 90 insertions(+), 24 deletions(-)


> -static struct sock *fanout_demux_cpu(struct packet_fanout *f, struct sk_buff *skb, unsigned int num)
> +static unsigned int fanout_demux_rollover(struct packet_fanout *f,
> +					  struct sk_buff *skb,
> +					  unsigned int idx, unsigned int skip,
> +					  unsigned int num)
>  {
> -	unsigned int cpu = smp_processor_id();
> +	unsigned int i, j;
>  
> -	return f->arr[cpu % num];
> +	i = j = min(f->next[idx], (int) f->num_members - 1);

min_t(int, f->next[idx], f->num_members - 1);

BTW, num_members can be 0

You really should do 

int members = ACCESS_ONCE(f->num_members) - 1;

if (members < 0)
	return idx;

and only use members in your loop.


> +	do {
> +		if (i != skip && packet_rcv_has_room(pkt_sk(f->arr[i]), skb)) {
> +			if (i != j)
> +				f->next[idx] = i;
> +			return i;
> +		}
> +		if (++i >= f->num_members)
> +			i = 0;
> +	} while (i != j && idx < f->num_members);
> +
> +	return idx;
> +}
> +
