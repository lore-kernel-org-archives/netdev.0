From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
 vhost-net
Date: Thu, 17 Dec 2009 13:50:08 -0800
Message-ID: <1261086608.26700.149.camel@w-sridhar.beaverton.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com>
	 <20091217112754.GA7755@ff.dom.local>
	 <20091217114535.GA30429@gondor.apana.org.au>
	 <20091217114937.GA30503@gondor.apana.org.au>
	 <20091217120856.GA30774@gondor.apana.org.au>
	 <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
	 <20091217134408.GB31964@gondor.apana.org.au>
	 <OF6A94FA41.B9EF2995-ON6525768F.004B99AC-6525768F.004F1634@in.ibm.com>
	 <20091217143635.GA388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:34493 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756610AbZLQVuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 16:50:15 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBHLjngu002430
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 16:45:49 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHLoBjs1896550
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 16:50:11 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHLoA7q004334
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:50:11 -0200
In-Reply-To: <20091217143635.GA388@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-17 at 22:36 +0800, Herbert Xu wrote:
> On Thu, Dec 17, 2009 at 08:05:02PM +0530, Krishna Kumar2 wrote:
> >
> > I think the bug is in this check:
> > 
> > +     if (vi->capacity >= 2 + MAX_SKB_FRAGS) {
> > +           /* Suppress further xmit interrupts. */
> > +           vi->svq->vq_ops->disable_cb(vi->svq);
> > +           napi_complete(xmit_napi);
> > +
> > +           /* Don't wake it if link is down. */
> > +           if (likely(netif_carrier_ok(vi->vdev)))
> > +                 netif_wake_queue(vi->dev);
> > +     }
> > 
> > We wake up too fast, just enough space for one more skb to be sent
> > before the queue is stopped again. And hence no more messages about
> > queue full, but lot of requeues. The qdisc code is doing the correct
> > thing, but we need to increase the limit here.
> > 
> > Can we try with some big number, 64, 128?
> 
> Good point.  Sridhar, could you please test doubling or quadrupling
> the threshold? 128 is probably a bit too much though as the ring
> only has 256 entries.

Increasing the wakeup threshold value reduced the number of requeues, but
didn't eliminate them. The throughput improved a little, but the CPU utilization
went up.
I don't see any 'queue full' warning messages from the driver and hence the driver
is not returning NETDEV_TX_BUSY. The requeues are happening in sch_direct_xmit()
as it is finding that the tx queue is stopped.

I could not get 2.6.31 virtio-net driver to work with 2.6.32 kernel by simply
replacing virtio-net.c. The compile and build went through fine, but the guest
is not seeing the virtio-net device when it comes up. 
I think it is a driver issue, not a core issue as I am able to get good results
by not stopping the queue early in start_xmit() and dropping the skb when xmit_skb()
fails even with 2.6.32 kernel. I think this behavior is somewhat similar to 2.6.31
virtio-net driver as it caches 1 skb and drops any further skbs when ring is full
in its start_xmit routine. 

2.6.32 + Rusty's xmit_napi v2 patch
-----------------------------------
$ ./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.1 (192.168.122.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    60.03      3255.22   87.16    82.57    2.193   4.156  
$ tc -s qdisc show dev eth0 
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 24524210050 bytes 1482737 pkt (dropped 0, overlimits 0 requeues 339101) 
 rate 0bit 0pps backlog 0b 0p requeues 339101 

2.6.32 + Rusty's xmit_napi v2 patch + wakeup threshold=64
---------------------------------------------------------
$ ./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.1 (192.168.122.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    60.03      3356.71   95.41    89.56    2.329   4.372  
[sridhar@localhost ~]$ tc -s qdisc show dev eth0 
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 25290227186 bytes 1555119 pkt (dropped 0, overlimits 0 requeues 78179) 
 rate 0bit 0pps backlog 0b 0p requeues 78179 

2.6.32 + Rusty's xmit_napi v2 patch + wakeup threshold=128
----------------------------------------------------------
$./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.1 (192.168.122.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    60.03      3413.79   96.30    89.79    2.311   4.309  
[sridhar@localhost ~]$ tc -s qdisc show dev eth0 
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 25719585472 bytes 1579448 pkt (dropped 0, overlimits 0 requeues 40299) 
 rate 0bit 0pps backlog 0b 0p requeues 40299 

2.6.32 + Rusty's xmit_napi v2 patch + don't stop early & drop skb on fail patch
-------------------------------------------------------------------------------
$./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.1 (192.168.122.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    60.03      7741.65   70.09    72.84    0.742   1.542  
[sridhar@localhost ~]$ tc -s qdisc show dev eth0 
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 58149531018 bytes 897991 pkt (dropped 0, overlimits 0 requeues 1) 
 rate 0bit 0pps backlog 0b 0p requeues 1



