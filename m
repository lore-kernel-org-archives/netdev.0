From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 22:37:17 +0100
Message-ID: <1354311437.11754.459.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
	 <1354230100.3299.40.camel@edumazet-glaptop>
	 <1354269846.11754.381.camel@localhost>
	 <1354287134.3299.67.camel@edumazet-glaptop>
	 <1354290335.11754.447.camel@localhost>
	 <1354293469.3299.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755357Ab2K3Vjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 16:39:48 -0500
In-Reply-To: <1354293469.3299.81.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 08:37 -0800, Eric Dumazet wrote:
> On Fri, 2012-11-30 at 16:45 +0100, Jesper Dangaard Brouer wrote:
> > On Fri, 2012-11-30 at 06:52 -0800, Eric Dumazet wrote:
> 
> > 
> > > I dont know how you expect that many
> > > datagrams being correctly reassembled with ipfrag_high_thresh=262144 
> > 
> > That's my point... I'm showing that its not possible, with out current
> > implementation!
> 
> What I was saying is that the limits are too small, and we should
> increase them for this particular need.
> 
> This has little to do with the underlying algo.

Actual data is an engineers best friend.

[root@dragon ~]# sysctl -w net/ipv4/ipfrag_high_thresh=$((4<<20))
net.ipv4.ipfrag_high_thresh = 4194304
[root@dragon ~]# sysctl -w net/ipv4/ipfrag_low_thresh=$((3<<20))
net.ipv4.ipfrag_low_thresh = 3145728


[jbrouer@firesoul ~]$ netperf -H 192.168.51.2 -T0,0 -t UDP_STREAM -l 20 &\
 netperf -p 1337 -H 192.168.31.2 -T7,7 -t UDP_STREAM -l 20
[1] 18573
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.51.2 (192.168.51.2) port 0 AF_INET : cpu bind
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.31.2 (192.168.31.2) port 0 AF_INET : cpu bind
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

229376   65507   20.00      363315      0    9519.86
212992           20.00        7297            191.20

Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

229376   65507   20.00      366927      0    9614.48
212992           20.00       10437            273.48


This test is 2x10G with straight NUMA nodes (meaning optimal NUMA
allocation where the incoming netperf packets are received by kernel and
delivered to netserver on the same NUMA node).


Come on Eric, you are smart than this.  When will you realize, that
dropping partly completed fragment queue are bad for performance? (And
thus a bad algorithmic choice in the evictor)


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
