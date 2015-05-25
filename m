From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 13:41:34 -0700
Message-ID: <1432586494.4060.183.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432579766.32671.66.camel@jasiiieee.pacifera.com>
	 <1432580733.4060.178.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432581685.32671.80.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33374 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbEYUlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 16:41:36 -0400
Received: by igbpi8 with SMTP id pi8so44481240igb.0
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 13:41:35 -0700 (PDT)
In-Reply-To: <1432581685.32671.80.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 15:21 -0400, John A. Sullivan III wrote:

> 
> Thanks, Eric. I really appreciate the help. This is a problem holding up
> a very high profile, major project and, for the life of me, I can't
> figure out why my TCP window size is reduced inside the GRE tunnel.
> 
> Here is the netem setup although we are using this merely to reproduce
> what we are seeing in production.  We see the same results bare metal to
> bare metal across the Internet.
> 
> qdisc prio 10: root refcnt 17 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 32578077286 bytes 56349187 pkt (dropped 15361, overlimits 0 requeues 61323)
>  backlog 0b 1p requeues 61323
> qdisc netem 101: parent 10:1 limit 1000 delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc netem 102: parent 10:2 limit 1000 delay 40.0ms
>  Sent 32434562015 bytes 54180984 pkt (dropped 15361, overlimits 0 requeues 0)
>  backlog 0b 1p requeues 0
> qdisc netem 103: parent 10:3 limit 1000 delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> 
> root@router-001:~# tc -s qdisc show dev eth2
> qdisc prio 2: root refcnt 17 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 296515482689 bytes 217794609 pkt (dropped 11719, overlimits 0 requeues 5307)
>  backlog 0b 2p requeues 5307
> qdisc netem 21: parent 2:1 limit 1000 delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc netem 22: parent 2:2 limit 1000 delay 40.0ms
>  Sent 289364020190 bytes 212892539 pkt (dropped 11719, overlimits 0 requeues 0)
>  backlog 0b 2p requeues 0
> qdisc netem 23: parent 2:3 limit 1000 delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> I'm not sure how helpful these stats are as we did set this router up
> for packet loss at one point.  We did suspect netem at some point and
> did things like change the limit but that had no effect.


80 ms at 1Gbps -> you need to hold about 6666 packets in your netem
qdisc, not 1000.

tc qdisc ... netem ... limit 8000 ...

(I see you added 40ms both ways, so you need 3333 packets in forward,
and 1666 packets for the ACK packets)

I tried a netem 80ms here and got following with default settings (no
change in send/receive windows)


lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 10.7.8.152 -Cc -t OMNI -l 20
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.7.8.152 () port 0 AF_INET
tcpi_rto 281000 tcpi_ato 0 tcpi_pmtu 1476 tcpi_rcv_ssthresh 28720
tcpi_rtt 80431 tcpi_rttvar 304 tcpi_snd_ssthresh 2147483647 tpci_snd_cwnd 2215
tcpi_reordering 3 tcpi_total_retrans 0
Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
4194304     6291456     16384  20.17   149.54     10^6bits/s  0.40  S      0.78   S      10.467  20.554  usec/KB  


Now with 16MB I got :
