From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet
 WQE (Striding RQ)
Date: Sun, 17 Apr 2016 17:29:31 -0700
Message-ID: <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
	 <1460928725-18741-6-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34049 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbcDRA3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 20:29:35 -0400
Received: by mail-pf0-f179.google.com with SMTP id c20so74593808pfc.1
        for <netdev@vger.kernel.org>; Sun, 17 Apr 2016 17:29:34 -0700 (PDT)
In-Reply-To: <1460928725-18741-6-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 00:31 +0300, Saeed Mahameed wrote:

> Performance tested on ConnectX4-Lx 50G.
> To isolate the feature under test, the numbers below were measured with
> HW LRO turned off. We verified that the performance just improves when
> LRO is turned back on.
> 
> * Netperf single TCP stream:
> - BW raised by 10-15% for representative packet sizes:
>   default, 64B, 1024B, 1478B, 65536B.
> 
> * Netperf multi TCP stream:
> - No degradation, line rate reached.
> 
> * Pktgen: packet rate raised by 5-10% for traffic of different message
> sizes: 64B, 128B, 256B, 1024B, and 1500B.
> 
> * Pktgen: packet loss in bursts of small messages (64byte),
> single stream:
> - | num packets | packets loss before | packets loss after
>   |     2K      |       ~ 1K          |       0
>   |     8K      |       ~ 6K          |       0
>   |     16K     |       ~13K          |       0
>   |     32K     |       ~28K          |       0
>   |     64K     |       ~57K          |     ~24K


As I already mentioned, allocated order-5 pages and hoping host only
receives friendly traffic is very optimistic.

A 192 bytes frame, is claiming to consume 192 bytes frag with your new
allocation strategy. (skb->truesize is kind of minimal)

In reality, it can prevent a whole 131072 bytes of memory from being
reclaimed/freed. TCP stack will not consider such skb has a candidate
for collapsing in case of memory pressure or hostile peer.

Your tests are obviously run on a freshly booted host, where all
physical memory can be consumed for networking buffers.

Even with order-3 pages, we have problems (at Facebook and Google) on
hosts that we do not reboot every day.

At the time order-5 allocations fail, it is already too late, as maybe
thousands of out-of-order TCP packets might have consumed all the memory
and the host will die.

/proc/sys/net/ipv4/tcp_mem by default allows TCP to use up to 10% of
hysical memory, assuming skb->truesize is true.

In your schem, TCP might never notice it uses 100% of the ram for
packets stored in out or order queues, since a frag will hold 32 times
more pages than really announced.

If really you need to allocate physically contiguous memory, have you
considered converting the order-5 pages into 32 order-0 ones ?

This way, a 192 bytes frame sitting in one socket would hold one order-0
page in the worst case, and TCP wont be allowed to use all physical
memory.
