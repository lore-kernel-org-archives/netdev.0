From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO aggregation
Date: Thu, 13 Sep 2012 14:05:26 +0200
Message-ID: <1347537926.13103.1530.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
	 <1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	 <1347390113.13103.660.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
	 <1347392132.13103.663.camel@edumazet-glaptop>
	 <505054AE.9040901@mellanox.com>
	 <1347442394.13103.703.camel@edumazet-glaptop> <50509F30.30402@mellanox.com>
	 <5050B6FF.5050002@hp.com> <5050B9B2.5070107@mellanox.com>
	 <5050BDB5.8090200@hp.com> <50517F01.9050501@mellanox.com>
	 <1347523865.13103.1423.camel@edumazet-glaptop>
	 <CAJZOPZL8qrqYfAvcQBDB9CFy7WwztWchaMyADGBnwKpW-r1Q4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shlomo Pongartz <shlomop@mellanox.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60254 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757723Ab2IMMFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 08:05:33 -0400
Received: by bkwj10 with SMTP id j10so487621bkw.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 05:05:31 -0700 (PDT)
In-Reply-To: <CAJZOPZL8qrqYfAvcQBDB9CFy7WwztWchaMyADGBnwKpW-r1Q4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 12:59 +0300, Or Gerlitz wrote:
> On Thu, Sep 13, 2012 at 11:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > MAX_SKB_FRAGS is 16
> > skb_gro_receive() will return -E2BIG once this limit is hit.
> > If you use a MSS = 100 (instead of MSS = 1460), then GRO skb will
> > contain only at most 1700 bytes, but TSO packets can still be 64KB, if
> > the sender NIC can afford it (some NICS wont work quite well)
> 
> Hi Eric,
> 
> Addressing this assertion of yours, Shlomo showed that with ixgbe he managed
> to see GRO aggregating 32KB which means 20-21 packets that is > 16 fragments
> in this notation, can it be related to the way ixgbe is actually
> allocating skbs?
> 

Hard to say without knowing exact kernel version, as things change a lot
in this area.

You have several kind of GRO. One fast and one slow.

The slow one uses a linked list of skbs (pinfo->frag_list), while the
fast one uses fragments (pinfo->nr_frags)

For example, some drivers (mellanox one is in this lot) pull too many
bytes in skb->head and this defeats the fast GRO :
Part of payload is in skb->head, remaining part in pinfo->frags[0]

skb_gro_receive() then has to allocate a new head skb, to link skbs into
head->frag_list. The total skb->truesize is not reduced at all, its
increased.

So you might think GRO is working, but its only a hack, as one skb has a
list of skbs, and this makes TCP read() slower, and defeats TCP
coalescing as well. Whats the point of delivering fat skbs to TCP stack
if it slows down the consumer, because of increased cache line misses ?

I am not _very_ interested in the slow GRO behavior, I try to improve
the fast path.

ixgbe uses the fast GRO, at least on recent kernels.

In my tests on mellanox, it only aggregates 8 frames per skb, and still
we reach 10Gbps...

03:41:40.128074 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1563841:1575425(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128080 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1575425:1587009(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128085 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1587009:1598593(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128089 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1598593:1610177(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128093 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1610177:1621761(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128103 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1633345:1644929(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128116 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1668097:1679681(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128121 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1679681:1691265(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128134 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1714433:1726017(11584) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128146 IP 7.7.7.84.38079 > 7.7.7.83.52113: . 1749185:1759321(10136) ack 0 win 229 <nop,nop,timestamp 137349733 152427711>
03:41:40.128163 IP 7.7.7.83.52113 > 7.7.7.84.38079: . ack 1575425 win 4147 <nop,nop,timestamp 152427711 137349733>
03:41:40.128193 IP 7.7.7.83.52113 > 7.7.7.84.38079: . ack 1759321 win 3339 <nop,nop,timestamp 152427711 137349733>

And it aggregates 8 frames per skb because each individual frame uses 2 fragments :

One of 512 bytes and one of 1024 bytes : total of 1536 bytes,
instead of the typical 2048 bytes used by other NIC

To get better performance, mellanox could use only one frag
per MTU (if MTU <= 1500), using 1536 bytes frags.

I tried this and this gives now :

05:00:12.507398 IP 7.7.7.84.63422 > 7.7.7.83.37622: . 2064384:2089000(24616) ack 1 win 229 <nop,nop,timestamp 142062123 4294793380>
05:00:12.507419 IP 7.7.7.84.63422 > 7.7.7.83.37622: . 2138232:2161400(23168) ack 1 win 229 <nop,nop,timestamp 142062123 4294793380>
05:00:12.507489 IP 7.7.7.84.63422 > 7.7.7.83.37622: . 2244664:2269280(24616) ack 1 win 229 <nop,nop,timestamp 142062123 4294793380>
05:00:12.507509 IP 7.7.7.83.37622 > 7.7.7.84.63422: . ack 2244664 win 16384 <nop,nop,timestamp 4294793380 142062123>

But there is no real difference in throughput.

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6c4f935..435c35e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -96,8 +96,8 @@
 /* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
  * and 4K allocations) */
 enum {
-	FRAG_SZ0 = 512 - NET_IP_ALIGN,
-	FRAG_SZ1 = 1024,
+	FRAG_SZ0 = 1536 - NET_IP_ALIGN,
+	FRAG_SZ1 = 2048,
        FRAG_SZ2 = 4096,
        FRAG_SZ3 = MLX4_EN_ALLOC_SIZE
 };
