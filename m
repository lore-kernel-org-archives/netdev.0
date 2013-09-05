From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Thu, 05 Sep 2013 11:34:01 +0800
Message-ID: <5227FBA9.8030604@redhat.com>
References: <1377816595.8277.54.camel@edumazet-glaptop>  <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>  <5226D39C.9070401@redhat.com> <1378290638.7360.85.camel@edumazet-glaptop> <1378294029.7360.92.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364Ab3IEDeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 23:34:13 -0400
In-Reply-To: <1378294029.7360.92.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2013 07:27 PM, Eric Dumazet wrote:
> On Wed, 2013-09-04 at 03:30 -0700, Eric Dumazet wrote:
>> > On Wed, 2013-09-04 at 14:30 +0800, Jason Wang wrote:
>> > 
>>>> > > > And tcpdump would certainly help ;)
>>> > > 
>>> > > See attachment.
>>> > > 
>> > 
>> > Nothing obvious on tcpdump (only that lot of frames are missing)
>> > 
>> > 1) Are you capturing part of the payload only (like tcpdump -s 128)
>> > 
>> > 2) What is the setup.
>> > 
>> > 3) tc -s -d qdisc
> If you use FQ in the guest, then it could be that high resolution timers
> have high latency ?

Not sure, but it should not affect so much. And I'm using kvm-clock in
guest whose overhead should be very small.
>
> So FQ arms short timers, but effective duration could be much longer.
>
> Here I get a smooth latency of up to ~3 us
>
> lpq83:~# ./netperf -H lpq84 ; ./tc -s -d qd ; dmesg | tail -n1
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84.prod.google.com () port 0 AF_INET
> Recv   Send    Send                          
> Socket Socket  Message  Elapsed              
> Size   Size    Size     Time     Throughput  
> bytes  bytes   bytes    secs.    10^6bits/sec  
>
>  87380  16384  16384    10.00    9410.82   
> qdisc fq 8005: dev eth0 root refcnt 32 limit 10000p flow_limit 100p buckets 1024 quantum 3028 initial_quantum 15140 
>  Sent 50545633991 bytes 33385894 pkt (dropped 0, overlimits 0 requeues 19) 
>  rate 9258Mbit 764335pps backlog 0b 0p requeues 19 
>   117 flow, 115 inactive, 0 throttled
>   0 gc, 0 highprio, 0 retrans, 96861 throttled, 0 flows_plimit
> [  572.551664] latency = 3035 ns
>
>
> What do you get with this debugging patch ?

I'm getting about 13us-19us, one run like:

 netperf -H 192.168.100.5; tc -s -d qd; dmesg | tail -n1
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.100.5 () port 0 AF_INET : demo
Recv   Send    Send                         
Socket Socket  Message  Elapsed             
Size   Size    Size     Time     Throughput 
bytes  bytes   bytes    secs.    10^6bits/sec 

 87380  16384  16384    10.00    4542.09  
qdisc fq 8001: dev eth0 root refcnt 2 [Unknown qdisc, optlen=64]
 Sent 53652327205 bytes 35580150 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
[  201.320565] latency = 14905 ns

One interesting thing is if I switch from kvm-clock to acpi_pm which has
much more overhead, the latency increase to about 50ns, and the
throughput drops very quickly.
netperf -H 192.168.100.5; tc -s -d qd; dmesg | tail -n1
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.100.5 () port 0 AF_INET : demo
Recv   Send    Send                         
Socket Socket  Message  Elapsed             
Size   Size    Size     Time     Throughput 
bytes  bytes   bytes    secs.    10^6bits/sec 

 87380  16384  16384    10.00    2262.46  
qdisc fq 8001: dev eth0 root refcnt 2 [Unknown qdisc, optlen=64]
 Sent 56611533075 bytes 37550429 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
[  474.121689] latency = 51841 ns
