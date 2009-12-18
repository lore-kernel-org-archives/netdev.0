From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Fri, 18 Dec 2009 19:16:48 +0530
Message-ID: <OF8D9C1F06.BEC391A1-ON65257690.003D170F-65257690.004AAB85@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com>	 <20091217112754.GA7755@ff.dom.local>
	 <20091217114535.GA30429@gondor.apana.org.au>	 <20091217114937.GA30503@gondor.apana.org.au>
	 <20091217120856.GA30774@gondor.apana.org.au>	 <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
	 <20091217134408.GB31964@gondor.apana.org.au>	 <OF6A94FA41.B9EF2995-ON6525768F.004B99AC-6525768F.004F1634@in.ibm.com>
	 <20091217143635.GA388@gondor.apana.org.au> <1261086608.26700.149.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:45484 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbZLRNfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 08:35:42 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBID93bS014767
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 18:39:03 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBIDZc3P2629760
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 19:05:38 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBIDZbDJ023365
	for <netdev@vger.kernel.org>; Sat, 19 Dec 2009 00:35:38 +1100
In-Reply-To: <1261086608.26700.149.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala <sri@us.ibm.com> wrote on 12/18/2009 03:20:08 AM:

> Increasing the wakeup threshold value reduced the number of requeues, but
> didn't eliminate them. The throughput improved a little, but the CPU
> utilization
> went up.
> I don't see any 'queue full' warning messages from the driver and
> hence the driver
> is not returning NETDEV_TX_BUSY. The requeues are happening in
> sch_direct_xmit()
> as it is finding that the tx queue is stopped.
>
> I could not get 2.6.31 virtio-net driver to work with 2.6.32 kernel by
simply
> replacing virtio-net.c. The compile and build went through fine, butthe
guest
> is not seeing the virtio-net device when it comes up.
> I think it is a driver issue, not a core issue as I am able to get
> good results
> by not stopping the queue early in start_xmit() and dropping the skb
> when xmit_skb()
> fails even with 2.6.32 kernel. I think this behavior is somewhat
> similar to 2.6.31
> virtio-net driver as it caches 1 skb and drops any further skbs when
> ring is full
> in its start_xmit routine.
>
> 2.6.32 + Rusty's xmit_napi v2 patch
> -----------------------------------
> $ ./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.
> 122.1 (192.168.122.1) port 0 AF_INET
> Recv   Send    Send                          Utilization       Service
Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send
Recv
> Size   Size    Size     Time     Throughput  local    remote   local
remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB
us/KB
>
>  87380  16384  16384    60.03      3255.22   87.16    82.57    2.193
4.156
> $ tc -s qdisc show dev eth0
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1
> 1 1 1 1 1 1 1
>  Sent 24524210050 bytes 1482737 pkt (dropped 0, overlimits 0 requeues
339101)
>  rate 0bit 0pps backlog 0b 0p requeues 339101
>
> 2.6.32 + Rusty's xmit_napi v2 patch + wakeup threshold=64
> ---------------------------------------------------------
> $ ./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.
> 122.1 (192.168.122.1) port 0 AF_INET
> Recv   Send    Send                          Utilization       Service
Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send
Recv
> Size   Size    Size     Time     Throughput  local    remote   local
remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB
us/KB
>
>  87380  16384  16384    60.03      3356.71   95.41    89.56    2.329
4.372
> [sridhar@localhost ~]$ tc -s qdisc show dev eth0
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1
> 1 1 1 1 1 1 1
>  Sent 25290227186 bytes 1555119 pkt (dropped 0, overlimits 0 requeues
78179)
>  rate 0bit 0pps backlog 0b 0p requeues 78179
>
> 2.6.32 + Rusty's xmit_napi v2 patch + wakeup threshold=128
> ----------------------------------------------------------
> $./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.
> 122.1 (192.168.122.1) port 0 AF_INET
> Recv   Send    Send                          Utilization       Service
Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send
Recv
> Size   Size    Size     Time     Throughput  local    remote   local
remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB
us/KB
>
>  87380  16384  16384    60.03      3413.79   96.30    89.79    2.311
4.309
> [sridhar@localhost ~]$ tc -s qdisc show dev eth0
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1
> 1 1 1 1 1 1 1
>  Sent 25719585472 bytes 1579448 pkt (dropped 0, overlimits 0 requeues
40299)
>  rate 0bit 0pps backlog 0b 0p requeues 40299
>
> 2.6.32 + Rusty's xmit_napi v2 patch + don't stop early & drop skb onfail
patch
>
-------------------------------------------------------------------------------

> $./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.
> 122.1 (192.168.122.1) port 0 AF_INET
> Recv   Send    Send                          Utilization       Service
Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send
Recv
> Size   Size    Size     Time     Throughput  local    remote   local
remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB
us/KB
>
>  87380  16384  16384    60.03      7741.65   70.09    72.84    0.742
1.542
> [sridhar@localhost ~]$ tc -s qdisc show dev eth0
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0
1__dev_xmit_skb
> 1 1 1 1 1 1 1
>  Sent 58149531018 bytes 897991 pkt (dropped 0, overlimits 0 requeues 1)
>  rate 0bit 0pps backlog 0b 0p requeues 1

Is the "drop skb" patch doing:
-                 return NETDEV_TX_BUSY;
+
+                 /* drop the skb under stress. */
+                 vi->dev->stats.tx_dropped++;
+                 kfree_skb(skb);
+                 return NETDEV_TX_OK;

Why is dropped count zero in the last test case?

sch_direct_xmit is called from two places, and if it finds
the txq stopped, it was called from __dev_xmit_skb (where
the previous sucessful xmit had stopped the queue). This
means the device is still stopping and restarting 1000's
of times a min, and each restart fills up the device h/w
queue with the backlogged skbs resulting in another stop.
Isn't the txqlen set to 1000 in ether_setup? Can you
increase the restart limit to a really high value, like
1/2 or 3/4th of the queue should be empty? Another thing
to test is to simultaneously set txqueuelen to a big value.

Requeue does not seem to be the reason for BW drop since
it barely improved when requeue's reduced from 340K to 40K.
So, as Jarek suggested, GSO could be reason. You could try
testing with 64K I/O size (with GSO enabled) to get
comparable results.

thanks,

- KK

