From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Sun, 13 Nov 2011 17:00:30 +0200
Message-ID: <1321196430.2425.2.camel@sasha>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>
	 <20111113102428.GD15322@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: penberg@kernel.org, kvm@vger.kernel.org, mingo@elte.hu,
	asias.hejun@gmail.com, gorcunov@gmail.com,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111113102428.GD15322@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-11-13 at 12:24 +0200, Michael S. Tsirkin wrote:
> On Sat, Nov 12, 2011 at 12:12:01AM +0200, Sasha Levin wrote:
> > This is a patch based on Krishna Kumar's patch series which implements
> > multiple VQ support for virtio-net.
> > 
> > The patch was tested with ver3 of the patch.
> > 
> > Cc: Krishna Kumar <krkumar2@in.ibm.com>
> > Cc: Michael S. Tsirkin <mst@redhat.com>
> > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > Cc: virtualization@lists.linux-foundation.org
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> 
> Any performance numbers?

I tried finding a box with more than two cores so I could test it on
something like that as well.

>From what I see this patch causes a performance regression on my 2 core
box.

I'll send an updated KVM tools patch in a bit as well.

Before:

# netperf -H 192.168.33.4,ipv4 -t TCP_RR
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
to 192.168.33.4 (192.168.33.4) port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

16384  87380  1        1       10.00    11160.63   
16384  87380

# netperf -H 192.168.33.4,ipv4 -t UDP_RR
MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
to 192.168.33.4 (192.168.33.4) port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

122880 122880 1        1       10.00    12072.64   
229376 229376

# netperf -H 192.168.33.4,ipv4 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    4654.50

netperf -H 192.168.33.4,ipv4 -t TCP_STREAM -- -m 128
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384    128    10.00     635.45

# netperf -H 192.168.33.4,ipv4 -t UDP_STREAM           
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

122880   65507   10.00      113894      0    5968.54
229376           10.00       89373           4683.54

# netperf -H 192.168.33.4,ipv4 -t UDP_STREAM -- -m 128
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

122880     128   10.00      550634      0      56.38
229376           10.00      398786             40.84


After:

# netperf -H 192.168.33.4,ipv4 -t TCP_RR
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
to 192.168.33.4 (192.168.33.4) port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

16384  87380  1        1       10.00    8952.47   
16384  87380

# netperf -H 192.168.33.4,ipv4 -t UDP_RR
MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
to 192.168.33.4 (192.168.33.4) port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

122880 122880 1        1       10.00    9534.52   
229376 229376

# netperf -H 192.168.33.4,ipv4 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.13    2278.23

# netperf -H 192.168.33.4,ipv4 -t TCP_STREAM -- -m 128
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384    128    10.00     623.27   

# netperf -H 192.168.33.4,ipv4 -t UDP_STREAM
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

122880   65507   10.00      136930      0    7175.72
229376           10.00       16726            876.51

# netperf -H 192.168.33.4,ipv4 -t UDP_STREAM -- -m 128
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.33.4 (192.168.33.4) port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

122880     128   10.00      982492      0     100.61
229376           10.00      249597             25.56

-- 

Sasha.

