From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Thu, 24 Nov 2016 18:30:14 -0800
Message-ID: <1480041014.8455.522.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161125120947.142c3af5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33548 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbcKYCaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 21:30:17 -0500
Received: by mail-pf0-f169.google.com with SMTP id d2so12076388pfd.0
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 18:30:16 -0800 (PST)
In-Reply-To: <20161125120947.142c3af5@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-25 at 12:09 +1100, Stephen Rothwell wrote:
> Hi all,
> 
> This is a typical user error report i.e. a net well specified one :-)
> 
> I am using a 6in4 tunnel from my Linux server at home (since my ISP
> does not provide native IPv6) to another hosted Linus server (that has
> native IPv6 connectivity).  The throughput for IPv6 connections has
> dropped from megabits per second to 10s of kilobits per second.
> 
> First, I am using Debian supplied kernels, so strike one, right?
> 
> Second, I don't actually remember when the problem started - it probably
> started when I upgraded from a v4.4 based kernel to a v4.7 based one.
> This server does not get rebooted very often as it runs hosted services
> for quite a few people (its is ozlabs.org ...).
> 
> I tried creating the same tunnel to another hosted server I have access
> to that is running a v3.16 based kernel and the performance is fine
> (actually upward of 40MB/s).
> 
> I noticed from a tcpdump on the hosted server that (when I fetch a
> large file over HTTP) the server is sending packets larger than the MTU
> of the tunnel.  These packets don't get acked and are later resent as
> MTU sized packets.  I will then send more larger packets and repeat ...


tcpdump shows big packets because SIT supports TSO (since linux-3.13)

lpaa23:~# ip -6 ro get 2002:af6:798::1
2002:af6:798::1 via fe80:: dev sixtofour0  src 2002:af6:797::  metric
1024  pref medium
lpaa23:~# ./netperf -H 2002:af6:798::1
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to
2002:af6:798::1 () port 0 AF_INET6
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    10374.64   

lpaa23:~# ethtool -k sixtofour0|grep seg
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: on
	tx-tcp-psp-segmentation: off [fixed]
generic-segmentation-offload: on
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
tx-ggre-segmentation: off [fixed]


> 
> The mtu of the tunnel is set to 1280 (though leaving it unset and using
> the default gave the same results).  The tunnel is using sit and is
> statically set up at both ends (though the hosted server end does not
> specify a remote ipv4 end point).
> 
> Is there anything else I can tell you?  Testing patches is a bit of a
> pain, unfortunately, but I was hoping that someone may remember
> something that may have caused this.

You could use "perf record -a -g -e skb:kfree_skb" to see where packets
are dropped on the sender.

You also could try to disable TSO and see if this makes a difference

ethtool -K sixtofour0 tso off
