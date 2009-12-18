From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
 vhost-net
Date: Fri, 18 Dec 2009 11:13:21 -0800
Message-ID: <1261163601.9365.82.camel@w-sridhar.beaverton.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com>
	 <20091217112754.GA7755@ff.dom.local>
	 <20091217114535.GA30429@gondor.apana.org.au>
	 <20091217114937.GA30503@gondor.apana.org.au>
	 <20091217120856.GA30774@gondor.apana.org.au>
	 <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
	 <20091217134408.GB31964@gondor.apana.org.au>
	 <OF6A94FA41.B9EF2995-ON6525768F.004B99AC-6525768F.004F1634@in.ibm.com>
	 <20091217143635.GA388@gondor.apana.org.au>
	 <1261086608.26700.149.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42891 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbZLRTNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 14:13:48 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBIJ6AmT031701
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 12:06:10 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBIJDTrH128152
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 12:13:30 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBIJFLgg023376
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 12:15:22 -0700
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 19:16 +0530, Krishna Kumar2 wrote:

> >
> > 2.6.32 + Rusty's xmit_napi v2 patch + don't stop early & drop skb onfail
> patch
> >
> -------------------------------------------------------------------------------
> 
> > $./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
> > TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.
> > 122.1 (192.168.122.1) port 0 AF_INET
> > Recv   Send    Send                          Utilization       Service
> Demand
> > Socket Socket  Message  Elapsed              Send     Recv     Send
> Recv
> > Size   Size    Size     Time     Throughput  local    remote   local
> remote
> > bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB
> us/KB
> >
> >  87380  16384  16384    60.03      7741.65   70.09    72.84    0.742
> 1.542
> > [sridhar@localhost ~]$ tc -s qdisc show dev eth0
> > qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0
> 1__dev_xmit_skb
> > 1 1 1 1 1 1 1
> >  Sent 58149531018 bytes 897991 pkt (dropped 0, overlimits 0 requeues 1)
> >  rate 0bit 0pps backlog 0b 0p requeues 1
> 
> Is the "drop skb" patch doing:
> -                 return NETDEV_TX_BUSY;
> +
> +                 /* drop the skb under stress. */
> +                 vi->dev->stats.tx_dropped++;
> +                 kfree_skb(skb);
> +                 return NETDEV_TX_OK;

Yes. This is the patch i used with plain 2.6.32. But with Rusty's patch,
i also commented out the if condition that stops the queue early in
start_xmit().
> 
> Why is dropped count zero in the last test case?

The dropped count reported by 'tc' are drops at the qdisc level and are
counted via qdisc_drop(). The drops at the driver level are counted as
net_device stats and are reported by ip -s link command. I see a few drops(5-6)
in a 60sec run with 2.6.31 kernel.
> 
> sch_direct_xmit is called from two places, and if it finds
> the txq stopped, it was called from __dev_xmit_skb (where
> the previous sucessful xmit had stopped the queue). This
> means the device is still stopping and restarting 1000's
> of times a min, and each restart fills up the device h/w
> queue with the backlogged skbs resulting in another stop.
> Isn't the txqlen set to 1000 in ether_setup? Can you
> increase the restart limit to a really high value, like
> 1/2 or 3/4th of the queue should be empty? Another thing
> to test is to simultaneously set txqueuelen to a big value.

txqueuelen limits the qdisc queue, not the device transmit queue.
The device tx queue length is set by qemu and defaults to 256 for
virtio-net. So a reasonable wakeup threshhold could be 64/128 and
it does reduce the number of requeues.

> 
> Requeue does not seem to be the reason for BW drop since
> it barely improved when requeue's reduced from 340K to 40K.
> So, as Jarek suggested, GSO could be reason. You could try
> testing with 64K I/O size (with GSO enabled) to get
> comparable results.

Yes. with 64K messages, i am getting comparable thruput, in fact
slightly better although cpu utilization is higher. So it looks like
the better thruput with 2.6.31 kernel with 16K message size is a 
side-effect of the drops.

I think Rusty's patch with 1/4 of tx ring as wakeup threshold is the first
step to address the queue full warnings in 2.6.32. With further tuning
it may be possible to eliminate the requeues.

2.6.32 + Rusty's xmit_napi_v2 patch

$ ./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60 -- -m 65536
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.1 (192.168.122.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  65536    60.03      8200.80   92.52    91.63    0.924   1.831  
$ tc -s qdisc show dev eth0 
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 61613336514 bytes 1208233 pkt (dropped 0, overlimits 0 requeues 237750) 
 rate 0bit 0pps backlog 0b 0p requeues 237750 
$ ip -s link show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 54:52:00:35:e3:74 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    59348763   899170   0       0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    1483793932 1208230  0       0       0       0      

Thanks
Sridhar

