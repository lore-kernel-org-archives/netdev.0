From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
 vhost-net
Date: Wed, 16 Dec 2009 09:42:41 -0800
Message-ID: <1260985361.11648.15.camel@w-sridhar.beaverton.ibm.com>
References: <20091213122512.GA17255@gondor.apana.org.au>
	 <200912161311.40644.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:38411 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762670AbZLPRmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 12:42:53 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBGHXc5A025573
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 12:33:38 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBGHghEx1364116
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 12:42:45 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBGHggVm011286
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 12:42:43 -0500
In-Reply-To: <200912161311.40644.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-16 at 13:11 +1030, Rusty Russell wrote:
> Sridhar, if you simply remove the dev_warn() does that restore some
> performance?  I'll work on a proper fix for 2.6.33 now.

Here is the comparision of a 60sec TCP STREAM test from 2.6.31.6 and 2.6.32 guests
to a 2.6.32 host with vhost-net patches.
Removing the dev_warn() in 2.6.32 doesn't make any significant difference
in throughput. I think the requeues are the main cause for the regression.
Will try your xmit NAPI patch.

linux-2.6.32
------------
$ ./netperf -c -C -H 192.168.122.1 -t TCP_STREAM  -l60
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.1 (192.168.122.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    60.03      3279.98   81.48    77.79    2.035   3.885  
$ tc -s qdisc show dev eth0
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 24708777531 bytes 1469482 pkt (dropped 0, overlimits 0 requeues 283575) 
 rate 0bit 0pps backlog 0b 0p requeues 283575 
$ ip -s link show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 54:52:00:35:e3:74 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    97000940   1469585  0       0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    3233946817 1469533  0       0       0       0      

linux-2.6.31.6
--------------
$ ./netperf -c -C -H 192.168.122.1 -t TCP_STREAM -l60
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.1 (192.168.122.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    60.03      8038.48   69.44    71.02    0.708   1.448  
$ tc -s qdisc show dev eth0
qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 60378698117 bytes 937388 pkt (dropped 0, overlimits 0 requeues 61) 
 rate 0bit 0pps backlog 0b 0p requeues 61 
$ ip -s link show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 54:52:00:35:e3:73 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    54702188   828655   0       0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    248753779  937399   0       7       0       0     


