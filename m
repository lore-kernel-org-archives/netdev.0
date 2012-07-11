From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 17:11:58 +0200
Message-ID: <1342019518.3265.8116.camel@edumazet-glaptop>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	mattmathis@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1341933215.3265.5476.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 17:13 +0200, Eric Dumazet wrote:
> This introduce TSQ (TCP Small Queues)
> 
> TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &
> device queues), to reduce RTT and cwnd bias, part of the bufferbloat
> problem.
> 
> sk->sk_wmem_alloc not allowed to grow above a given limit,
> allowing no more than ~128KB [1] per tcp socket in qdisc/dev layers at a
> given time.
> 
> TSO packets are sized/capped to half the limit, so that we have two
> TSO packets in flight, allowing better bandwidth use.
> 
> As a side effect, setting the limit to 40000 automatically reduces the
> standard gso max limit (65536) to 40000/2 : It can help to reduce
> latencies of high prio packets, having smaller TSO packets.
> 
> This means we divert sock_wfree() to a tcp_wfree() handler, to
> queue/send following frames when skb_orphan() [2] is called for the
> already queued skbs.
> 
> Results on my dev machine (tg3 nic) are really impressive, using
> standard pfifo_fast, and with or without TSO/GSO. Without reduction of
> nominal bandwidth.
> 
> I no longer have 3MBytes backlogged in qdisc by a single netperf
> session, and both side socket autotuning no longer use 4 Mbytes.
> 
> As skb destructor cannot restart xmit itself ( as qdisc lock might be
> taken at this point ), we delegate the work to a tasklet. We use one
> tasklest per cpu for performance reasons.
> 
> 
> 
> [1] New /proc/sys/net/ipv4/tcp_limit_output_bytes tunable
> [2] skb_orphan() is usually called at TX completion time,
>   but some drivers call it in their start_xmit() handler.
>   These drivers should at least use BQL, or else a single TCP
>   session can still fill the whole NIC TX ring, since TSQ will
>   have no effect.

I am going to send an official patch (I'll put a v3 tag in it)

I believe I did a full implementation, including the xmit() done
by the user at release_sock() time, if the tasklet found socket owned by
the user.

Some bench results about the choice of 128KB being the default value:

64KB seems the 'good' value on 10Gb links to reach max throughput on my
lab machines (ixgbe adapters).

Using 128KB is a very conservative value to allow link rate on 20Gbps.

Still, it allows less than 1ms of buffering on a Gbit link, and less
than 8ms on 100Mbit link (instead of 130ms without Small Queues)


Tests using a single TCP flow.

Tests on 10Gbit links :


echo 16384 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 16 tpci_snd_cwnd 79
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
392360      392360      16384  20.00   1389.53    10^6bits/s  0.52  S      4.30   S      0.737   1.014   usec/KB  

echo 24576 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 33 tpci_snd_cwnd 86
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
396976      396976      16384  20.00   1483.03    10^6bits/s  0.45  S      4.51   S      0.603   0.997   usec/KB  

echo 32768 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 19 tpci_snd_cwnd 100
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
461600      461600      16384  20.00   2039.67    10^6bits/s  0.64  S      5.17   S      0.620   0.830   usec/KB  

echo 49152 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 28 tpci_snd_cwnd 207
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
955512      955512      16384  20.00   4448.86    10^6bits/s  1.19  S      11.16  S      0.526   0.822   usec/KB  

echo 65536 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 399 tpci_snd_cwnd 488
tcpi_reordering 127 tcpi_total_retrans 75
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
2460328     2460328     16384  20.00   5975.12    10^6bits/s  1.81  S      14.65  S      0.595   0.803   usec/KB  

echo 81920 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 24 tpci_snd_cwnd 236
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1144768     1144768     16384  20.00   5190.08    10^6bits/s  1.56  S      12.63  S      0.591   0.798   usec/KB  

echo 98304 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 20 tpci_snd_cwnd 644
tcpi_reordering 59 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
2991168     2991168     16384  20.00   5976.00    10^6bits/s  1.60  S      14.61  S      0.526   0.801   usec/KB  

echo 114688 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 23 tpci_snd_cwnd 683
tcpi_reordering 59 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
3161960     3161960     16384  20.00   5975.14    10^6bits/s  1.42  S      14.78  S      0.469   0.810   usec/KB  

echo 131072 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 23 tpci_snd_cwnd 591
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
2728056     2728056     16384  20.00   5976.16    10^6bits/s  1.71  S      14.62  S      0.562   0.802   usec/KB  

echo 147456 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 27 tpci_snd_cwnd 697
tcpi_reordering 64 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
3240432     3240432     16384  20.00   5975.64    10^6bits/s  1.51  S      14.78  S      0.498   0.811   usec/KB  

echo 163840 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 18 tpci_snd_cwnd 710
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
3277360     3277360     16384  20.00   5975.56    10^6bits/s  1.59  S      14.79  S      0.525   0.811   usec/KB  

echo 180224 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 32 tpci_snd_cwnd 701
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
3235816     3235816     16384  20.00   5976.80    10^6bits/s  1.56  S      14.61  S      0.514   0.801   usec/KB  

echo 196608 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 502 tpci_snd_cwnd 690
tcpi_reordering 127 tcpi_total_retrans 37
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
3185040     3185040     16384  20.00   5975.46    10^6bits/s  1.50  S      14.67  S      0.493   0.804   usec/KB  

echo 262144 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 16 tpci_snd_cwnd 721
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
3448152     3448152     16384  20.00   5975.49    10^6bits/s  1.57  S      14.78  S      0.516   0.811   usec/KB  

echo 524288 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 202000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 2000 tcpi_rttvar 750 tcpi_snd_ssthresh 16 tpci_snd_cwnd 927
tcpi_reordering 53 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
4194304     4194304     16384  20.01   5976.61    10^6bits/s  1.63  S      14.56  S      0.538   0.798   usec/KB  

echo 1048576 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
tcpi_rto 202000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 2500 tcpi_rttvar 750 tcpi_snd_ssthresh 17 tpci_snd_cwnd 1272
tcpi_reordering 90 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
4194304     4194304     16384  20.01   5975.11    10^6bits/s  1.64  S      14.69  S      0.541   0.805   usec/KB  



Tests on Gbit link :


echo 16384 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 30 tpci_snd_cwnd 274
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1264784     1264784     16384  20.01   689.70     10^6bits/s  0.22  S      15.05  S      0.634   7.149   usec/KB  

echo 24576 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 43 tpci_snd_cwnd 245
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1130920     1130920     16384  20.01   860.21     10^6bits/s  0.25  S      16.05  S      0.576   6.112   usec/KB  

echo 32768 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 36 tpci_snd_cwnd 229
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1057064     1057064     16384  20.01   867.76     10^6bits/s  0.28  S      15.46  S      0.634   5.839   usec/KB  

echo 49152 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 32 tpci_snd_cwnd 293
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1352488     1352488     16384  20.01   873.61     10^6bits/s  0.21  S      16.25  S      0.483   6.095   usec/KB  

echo 65536 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 48 tpci_snd_cwnd 274
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1264784     1264784     16384  20.01   875.90     10^6bits/s  0.19  S      15.56  S      0.421   5.822   usec/KB  

echo 81920 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 18 tpci_snd_cwnd 246
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1135536     1135536     16384  20.01   879.10     10^6bits/s  0.26  S      15.92  S      0.590   5.935   usec/KB  

echo 98304 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 20 tpci_snd_cwnd 361
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1666376     1666376     16384  20.02   880.30     10^6bits/s  0.25  S      16.07  S      0.560   5.980   usec/KB  

echo 114688 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 41 tpci_snd_cwnd 281
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1297096     1297096     16384  20.01   881.30     10^6bits/s  0.26  S      15.96  S      0.569   5.933   usec/KB  

echo 131072 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 30 tpci_snd_cwnd 292
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1347872     1347872     16384  20.01   880.43     10^6bits/s  0.23  S      16.71  S      0.511   6.219   usec/KB  

echo 147456 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 202000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 2000 tcpi_rttvar 750 tcpi_snd_ssthresh 31 tpci_snd_cwnd 286
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1320176     1320176     16384  20.01   880.57     10^6bits/s  0.24  S      16.62  S      0.534   6.187   usec/KB  

echo 163840 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 19 tpci_snd_cwnd 406
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1874096     1874096     16384  20.02   880.23     10^6bits/s  0.25  S      17.08  S      0.550   6.358   usec/KB  

echo 180224 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 202000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 2000 tcpi_rttvar 750 tcpi_snd_ssthresh 27 tpci_snd_cwnd 304
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1403264     1403264     16384  20.01   880.34     10^6bits/s  0.22  S      16.03  S      0.501   5.965   usec/KB  

echo 196608 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 202000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 2000 tcpi_rttvar 750 tcpi_snd_ssthresh 42 tpci_snd_cwnd 365
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1684840     1684840     16384  20.02   879.73     10^6bits/s  0.26  S      16.82  S      0.578   6.267   usec/KB  

echo 262144 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 202000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 2875 tcpi_rttvar 750 tcpi_snd_ssthresh 27 tpci_snd_cwnd 471
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
2174136     2174136     16384  20.01   879.89     10^6bits/s  0.25  S      18.52  S      0.556   6.898   usec/KB  

echo 524288 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 205000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 5000 tcpi_rttvar 750 tcpi_snd_ssthresh 42 tpci_snd_cwnd 627
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
2894232     2894232     16384  20.03   879.84     10^6bits/s  0.25  S      17.12  S      0.564   6.374   usec/KB  

echo 1048576 >/proc/sys/net/ipv4/tcp_limit_output_bytes
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
tcpi_rto 209000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 9875 tcpi_rttvar 750 tcpi_snd_ssthresh 33 tpci_snd_cwnd 950
tcpi_reordering 3 tcpi_total_retrans 0
Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
4194304     4194304     16384  20.03   880.70     10^6bits/s  0.25  S      18.44  S      0.560   6.861   usec/KB  
