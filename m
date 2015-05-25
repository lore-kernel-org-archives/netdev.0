From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 10:53:38 -0700
Message-ID: <1432576418.4060.175.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37312 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbEYRxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 13:53:40 -0400
Received: by igbsb11 with SMTP id sb11so37445624igb.0
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 10:53:39 -0700 (PDT)
In-Reply-To: <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 09:58 -0700, Eric Dumazet wrote:

> 1) Non GRE session
> 
> lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H lpaa24 -Cc -t OMNI
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa24.prod.google.com () port 0 AF_INET
> tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
> tcpi_rtt 70 tcpi_rttvar 7 tcpi_snd_ssthresh 221 tpci_snd_cwnd 258
> tcpi_reordering 3 tcpi_total_retrans 711
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
> Final       Final                                             %     Method %      Method                          
> 1912320     6291456     16384  10.00   22386.89   10^6bits/s  1.20  S      2.60   S      0.211   0.456   usec/KB  
> 
> 2) GRE session
> 
> lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 7.7.7.24 -Cc -t OMNI
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.7.24 () port 0 AF_INET
> tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
> tcpi_rtt 76 tcpi_rttvar 7 tcpi_snd_ssthresh 176 tpci_snd_cwnd 249
> tcpi_reordering 3 tcpi_total_retrans 819
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
> Final       Final                                             %     Method %      Method                          
> 1815552     6291456     16384  10.00   22420.88   10^6bits/s  1.01  S      3.44   S      0.177   0.603   usec/KB  

Scratch these numbers, they were quite wrong (7.7.7.24 was not using a
GRE tunnel)

Correct experiment :


1) No GRE tunnel

lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H lpaa24 -Cc -t OMNI -l 10
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa24.prod.google.com () port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
tcpi_rtt 82 tcpi_rttvar 11 tcpi_snd_ssthresh 356 tpci_snd_cwnd 358
tcpi_reordering 3 tcpi_total_retrans 288
Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
2492928     6291456     16384  10.03   31426.29   10^6bits/s  1.14  S      4.82   S      0.143   0.603   usec/KB  


2) GRE tunnel 
----------------------------------------------
lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 10.7.8.152 -Cc -t OMNI -l 10
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.7.8.152 () port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1476 tcpi_rcv_ssthresh 28720
tcpi_rtt 165 tcpi_rttvar 27 tcpi_snd_ssthresh 263 tpci_snd_cwnd 264
tcpi_reordering 81 tcpi_total_retrans 26
Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1216512     6291456     16384  10.00   8471.24    10^6bits/s  2.82  S      2.56   S      1.308   1.190   usec/KB  

Bottleneck here is the sender, because NIC does not support GRE/TSO, so we
spend lot of time doing segmentation and TX checksum, consuming a full cpu core.
