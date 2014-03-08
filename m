From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sat, 08 Mar 2014 07:27:41 -0800
Message-ID: <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:60894 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaCHP1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 10:27:43 -0500
Received: by mail-pb0-f50.google.com with SMTP id md12so5421007pbc.37
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 07:27:43 -0800 (PST)
In-Reply-To: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-08 at 01:13 -0500, Ming Chen wrote:
> Hi,
> 
> We have an Intel 82599EB dual-port 10GbE NIC, which has 128 tx queues
> (64 per port and we used only one port). We found only 12 of the tx
> queues are enabled, where 12 is number of CPUs of our system.
> 
> We realized that, in the driver code, adapter->num_tx_queues (which
> decides netdev->real_num_tx_queues) is indirectly set to "min_t(int,
> IXGBE_MAX_RSS_INDICES, num_online_cpus())". It looks like the limit is
> for RSS. But why tx queues is also set to the same as rx queues?
> 
> The problem of having a small number of tx queues is high probability
> of hash collision in skb_tx_hash(). If we have a small number of
> long-lived data-intensive TCP flows, the hash collision can causes
> unfairness. We found this problem during our benchmarking of NFS when
> identical NFS clients are getting very different throughput when
> reading a big file from the server. We call this problem Hash-Cast. If
> interested, you can take a look at this poster:
> http://www.fsl.cs.sunysb.edu/~mchen/fast14poster-hashcast-portrait.pdf
> 
> Can anybody take a loot at this? It would be better to have all tx
> queues enabled by default. If this is unlikely to happen, is there a
> way to reconfigure the NIC so that we can use all tx queues if we
> want?
> 
> FYI, our kernel version is 3.12.0, but I found the same limit of tx
> queues in the code of the latest kernel. I am counting the number of
> enabled queues using "ls /sys/class/net/p3p1/queues| grep -c tx-"
> 
> Best,

Quite frankly, with a 1Gbe link, I would just use FQ and your problem
would disappear.

(I also use FQ with 40Gbe links if that matters)

For a 1Gbe link, the following command is more than enough.

tc qdisc replace dev eth0 root fq

Also, following patch would probably help fairness. I'll submit an
official and more complete patch later.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bc0fb0fc7552..296c201516d1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1911,8 +1911,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 * of queued bytes to ensure line rate.
 		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
-		limit = max_t(unsigned int, sysctl_tcp_limit_output_bytes,
-			      sk->sk_pacing_rate >> 10);
+		limit = 2 * skb->truesize;
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
