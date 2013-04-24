From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 18:07:23 -0700
Message-ID: <1366765643.8964.51.camel@edumazet-glaptop>
References: <1366762196.8964.46.camel@edumazet-glaptop>
	 <1366763847-9279-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:61261 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473Ab3DXBH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 21:07:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id bh4so824406pad.40
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 18:07:25 -0700 (PDT)
In-Reply-To: <1366763847-9279-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 20:37 -0400, Willem de Bruijn wrote:
> A cpu executing the network receive path sheds packets when its input
> queue grows to netdev_max_backlog. A single high rate flow (such as a
> spoofed source DoS) can exceed a single cpu processing rate and will
> degrade throughput of other flows hashed onto the same cpu.
> 
> This patch adds a more fine grained hashtable. If the netdev backlog
> is above a threshold, IRQ cpus track the ratio of total traffic of
> each flow (using 4096 buckets, configurable). The ratio is measured
> by counting the number of packets per flow over the last 256 packets
> from the source cpu. Any flow that occupies a large fraction of this
> (set at 50%) will see packet drop while above the threshold.
> 
> Tested:
> Setup is a muli-threaded UDP echo server with network rx IRQ on cpu0,
> kernel receive (RPS) on cpu0 and application threads on cpus 2--7
> each handling 20k req/s. Throughput halves when hit with a 400 kpps
> antagonist storm. With this patch applied, antagonist overload is
> dropped and the server processes its complete load.
> 
> The patch is effective when kernel receive processing is the
> bottleneck. The above RPS scenario is a extreme, but the same is
> reached with RFS and sufficient kernel processing (iptables, packet
> socket tap, ..).
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> 


>  /*
>   * Incoming packets are placed on per-cpu queues
>   */
> @@ -1808,6 +1821,10 @@ struct softnet_data {
>  	unsigned int		dropped;
>  	struct sk_buff_head	input_pkt_queue;
>  	struct napi_struct	backlog;
> +
> +#ifdef CONFIG_NET_FLOW_LIMIT
> +	struct sd_flow_limit	*flow_limit;
> +#endif
>  };


I guess flow_limit could be put before csd, as its a read only field by
its owner.
This need more testing and is a minor detail.

Acked-by: Eric Dumazet <edumazet@google.com>
