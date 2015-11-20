From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network stream fairness
Date: Fri, 20 Nov 2015 10:16:54 -0800
Message-ID: <1448043414.22599.287.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5640BEAC.10404@axis.com>
	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5640C15E.805@axis.com>
	 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <564F3D3D.7050004@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35180 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759999AbbKTSQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 13:16:56 -0500
Received: by pacej9 with SMTP id ej9so123316294pac.2
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 10:16:55 -0800 (PST)
In-Reply-To: <564F3D3D.7050004@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-11-20 at 16:33 +0100, Niklas Cassel wrote:

> I've been able to reproduce this on a ARMv7, single core, 100 Mbps NIC.
> Kernel vanilla 4.3, driver has BQL implemented, but is unfortunately not upstreamed.
> 
> ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: on
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off
> 
> ip addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
>     link/ether 00:40:8c:18:58:c8 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.0.136/24 brd 192.168.0.255 scope global eth0
>        valid_lft forever preferred_lft forever
> 
> # before iperf3 run
> tc -s -d qdisc
> qdisc noqueue 0: dev lo root refcnt 2 
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc fq_codel 0: dev eth0 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
>  Sent 21001 bytes 45 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>   new_flows_len 0 old_flows_len 0
> 
> sysctl net.ipv4.tcp_congestion_control
> net.ipv4.tcp_congestion_control = cubic
> 
> # after iperf3 run
> tc -s -d qdisc
> qdisc noqueue 0: dev lo root refcnt 2 
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc fq_codel 0: dev eth0 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
>  Sent 5618224754 bytes 3710914 pkt (dropped 0, overlimits 0 requeues 1) 
>  backlog 0b 0p requeues 1 
>   maxpacket 1514 drop_overlimit 0 new_flow_count 2 ecn_mark 0
>   new_flows_len 0 old_flows_len 0
> 
> Note that it appears stable for 411 seconds before you can see the
> congestion window growth. It appears that the amount of time you have
> to wait before things go downhill varies a lot.
> No switch was used between the server and client; they were connected directly.

Hi Niklas

Your results seem to show there is no special issue ;)

With TSO off and GSO off, there is no way a 'TSO autosizing' patch would
have any effect, since this code path is not taken.

You have to wait 400 seconds before getting into a mode where one of the
flow gets bigger cwnd (25 instead of 16), and then TCP cubic simply
shows typical unfairness ...

If you absolutely need to guarantee a given throughput per flow, you
might consider using fq packet scheduler and SO_MAX_PACING_RATE socket
option.

Thanks !
