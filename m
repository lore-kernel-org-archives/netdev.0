From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] udp/v6: prefetch rmem_alloc in
 udp6_queue_rcv_skb()
Date: Thu, 22 Jun 2017 22:49:57 +0200
Message-ID: <20170622224957.323f1bab@redhat.com>
References: <9152ab05a2fe6b6230b44b7a23056b367ca19f5e.1498127002.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46984 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750847AbdFVUuG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 16:50:06 -0400
In-Reply-To: <9152ab05a2fe6b6230b44b7a23056b367ca19f5e.1498127002.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jun 2017 15:01:22 +0200
Paolo Abeni <pabeni@redhat.com> wrote:

> very similar to commit dd99e425be23 ("udp: prefetch
> rmem_alloc in udp_queue_rcv_skb()"), this allows saving a cache
> miss when the BH is bottle-neck for UDP over ipv6 packet
> processing, e.g. for small packets when a single RX NIC ingress
> queue is in use.
> 
> Performances under flood when multiple NIC RX queues used are
> unaffected, but when a single NIC rx queue is in use, this
> gives ~8% performance improvement.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Testing IPv4 UDP on top of this patch, with ip_early_demux enabled.
I'm impressed, we can now to almost 3 Mpps UDP (across two CPUs) :-)))
Last time I tested on this machine it was around 2.3Mpps.

Good work Paolo! :-)

[jbrouer@skylake src]$ sysctl net/ipv4/ip_early_demux=1
net.ipv4.ip_early_demux = 1
[jbrouer@skylake src]$ 
[jbrouer@skylake src]$ sudo taskset -c 2 ./udp_sink --port 9 --count $((10**6)) --repeat 1000 --recvmsg --connect
          	run      count   	ns/pkt	pps		cycles	payload
recvmsg   	run:  0	 1000000	341.62	2927192.65	1369	18	 demux:1 c:1
recvmsg   	run:  1	 1000000	350.81	2850569.36	1406	18	 demux:1 c:1
recvmsg   	run:  2	 1000000	352.18	2839478.74	1411	18	 demux:1 c:1
recvmsg   	run:  3	 1000000	341.43	2928871.10	1368	18	 demux:1 c:1
recvmsg   	run:  4	 1000000	350.65	2851810.35	1405	18	 demux:1 c:1
recvmsg   	run:  5	 1000000	350.91	2849751.29	1406	18	 demux:1 c:1
recvmsg   	run:  6	 1000000	342.68	2918138.00	1373	18	 demux:1 c:1
recvmsg   	run:  7	 1000000	351.37	2845969.40	1408	18	 demux:1 c:1
recvmsg   	run:  8	 1000000	351.07	2848452.09	1407	18	 demux:1 c:1

https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
