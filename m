From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 09:58:59 -0700
Message-ID: <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35466 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbbEYQ7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 12:59:03 -0400
Received: by iesa3 with SMTP id a3so75823323ies.2
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 09:59:01 -0700 (PDT)
In-Reply-To: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 11:42 -0400, John A. Sullivan III wrote:
> Hello, all.  I hope this is the correct list for this question.  We are
> having serious problems on high BDP networks using GRE tunnels.  Our
> traces show it to be a TCP Window problem.  When we test without GRE,
> throughput is wire speed and traces show the window size to be 16MB
> which is what we configured for r/wmem_max and tcp_r/wmem.  When we
> switch to GRE, we see over a 90% drop in throughput and the TCP window
> size seems to peak at around 500K.
> 
> What causes this and how can we get the GRE tunnels to use the max
> window size? Thanks - John

Hi John

Is it for a single flow or multiple ones ? Which kernel versions on
sender and receiver ? What is the nominal speed of non GRE traffic ?

What is the brand/model of receiving NIC  ? Is GRO enabled ?

It is possible receiver window is impacted because of GRE encapsulation
making skb->len/skb->truesize ratio a bit smaller, but not by 90%.

I suspect some more trivial issues, like receiver overwhelmed by the
extra load of GRE encapsulation.

1) Non GRE session

lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H lpaa24 -Cc -t OMNI
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa24.prod.google.com () port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
tcpi_rtt 70 tcpi_rttvar 7 tcpi_snd_ssthresh 221 tpci_snd_cwnd 258
tcpi_reordering 3 tcpi_total_retrans 711
Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1912320     6291456     16384  10.00   22386.89   10^6bits/s  1.20  S      2.60   S      0.211   0.456   usec/KB  

2) GRE session

lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 7.7.7.24 -Cc -t OMNI
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.7.24 () port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
tcpi_rtt 76 tcpi_rttvar 7 tcpi_snd_ssthresh 176 tpci_snd_cwnd 249
tcpi_reordering 3 tcpi_total_retrans 819
Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1815552     6291456     16384  10.00   22420.88   10^6bits/s  1.01  S      3.44   S      0.177   0.603   usec/KB  
