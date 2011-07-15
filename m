From: Rick Jones <rick.jones2@hp.com>
Subject: Does it matter that autotuning grows the socket buffers on a request/response
 test?
Date: Fri, 15 Jul 2011 14:20:08 -0700
Message-ID: <4E20AF08.6010409@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:20324 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab1GOVUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 17:20:09 -0400
Received: from g4t0009.houston.hp.com (g4t0009.houston.hp.com [16.234.32.26])
	by g4t0017.houston.hp.com (Postfix) with ESMTP id 5037C387C2
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 21:20:09 +0000 (UTC)
Received: from [16.89.244.213] (tardy.cup.hp.com [16.89.244.213])
	by g4t0009.houston.hp.com (Postfix) with ESMTP id 1EE5CC084
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 21:20:09 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was getting ready to do some aggregate netperf request/response tests, 
using the bits that will be the 2.5.0 release of netperf, where the 
"omni" tests are the default.  This means that rather than seeing the 
initial socket buffer sizes I started seeing the final socket buffer sizes.

Previously I'd explicitly looked at the final socket buffer sizes during 
TCP_STREAM tests, and emails about that are burried in the archive.  But 
I'd never looked explicitly for request/response tests.

What surprised me was that a TCP request/response test with single-byte 
requests and responses, and TCP_NODELAY set, could have its socket 
buffers grown with say no more than 31 transactions outstanding at one 
time - ie no more than 31 bytes outstanding on the connection in any one 
direction at any one time.

It does seem repeatable

# HDR="-P 1";for b in 28 29 30 31; do netperf -t omni $HDR -H 
15.184.3.62 -- -r 1 -b $b -D -O foo; HDR="-P 0"; done
OMNI Send|Recv TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 15.184.3.62 
(15.184.3.62) port 0 AF_INET : nodelay : histogram
Local       Local       Remote      Remote      Request Response Initial 
  Elapsed Throughput Throughput
Send Socket Recv Socket Send Socket Recv Socket Size    Size     Burst 
   Time               Units
Size        Size        Size        Size        Bytes   Bytes 
Requests (sec)
Final       Final       Final       Final 

16384       87380       16384       87380       1       1        28 
   10.00   200464.51  Trans/s
16384       87380       16384       87380       1       1        29 
   10.00   204136.24  Trans/s
121200      87380       121200      87380       1       1        30 
   10.00   198229.08  Trans/s
121200      87380       121200      87380       1       1        31 
   10.00   196986.98  Trans/s


# HDR="-P 1";for b in 28 29 30 31; do netperf -t omni $HDR -H 
15.184.3.62 -- -r 1 -b $b -D -O foo; HDR="-P 0"; done
OMNI Send|Recv TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 15.184.3.62 
(15.184.3.62) port 0 AF_INET : nodelay : histogram
Local       Local       Remote      Remote      Request Response Initial 
  Elapsed Throughput Throughput
Send Socket Recv Socket Send Socket Recv Socket Size    Size     Burst 
   Time               Units
Size        Size        Size        Size        Bytes   Bytes 
Requests (sec)
Final       Final       Final       Final 

16384       87380       16384       87380       1       1        28 
   10.00   202550.00  Trans/s
16384       87380       16384       87380       1       1        29 
   10.00   194460.50  Trans/s
121200      87380       121200      87380       1       1        30 
   10.00   199372.34  Trans/s
121200      87380       121200      87380       1       1        31 
   10.00   196089.33  Trans/s



The initial burst code does try to "walk up" to the number of 
outstanding requests to avoid getting things lumped together thanks to 
cwnd (*).  Though, a tcpdump trace does show the occasional segment of 
length > 1:

# tcpdump -r /tmp/trans.pcap  tcp and not port 12865 | awk '{print $NF}' 
| sort -n | uniq -c
reading from file /tmp/trans.pcap, link-type EN10MB (Ethernet)
      17 0
1903752 1
      28 2
      29 3
      10 4
      11 5
       9 6
      14 7
      18 8
       9 9
      12 10
       3 11

Still, should that have caused the socket buffers to grow?  FWIW, it 
isn't all single-byte transactions for a burst size of 29 either:

# tcpdump -r /tmp/trans_29.pcap  tcp and not port 12865 | awk '{print 
$NF}' | sort -n | uniq -c
reading from file /tmp/trans_29.pcap, link-type EN10MB (Ethernet)
      13 0
1771215 1
       4 2
       2 3
       3 4
       2 5
       2 6
       1 7
       2 8
       1 9
       1 11

but that does not seem to grow the socket buffers. 2.6.38-8-server on 
both sides through a Mellanox MT26438 operating as 10GbE.

rick jones

* #ifdef WANT_FIRST_BURST
	/* so, since we've gotten a response back, update the
	   bookkeeping accordingly.  there is one less request
	   outstanding and we can put one more out there than before. */
	requests_outstanding -= 1;
	if ((request_cwnd < first_burst_size) &&
	    (NETPERF_IS_RR(direction))) {
	  request_cwnd += 1;
	  if (debug) {
	    fprintf(where,
		    "incr req_cwnd to %d first_burst %d reqs_outstndng %d\n",
		    request_cwnd,
		    first_burst_size,
		    requests_outstanding);
	  }
	}
#endif

Also, some larger burst sizes also cause the receive socket buffer to 
increase:

# HDR="-P 1";for b in 0 1 2 4 16 64 128 256; do netperf -t omni $HDR -H 
15.184.3.62 -- -r 1 -b $b -D -O foo; HDR="-P 0"; done
OMNI Send|Recv TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 15.184.3.62 
(15.184.3.62) port 0 AF_INET : nodelay : histogram
Local       Local       Remote      Remote      Request Response Initial 
  Elapsed Throughput Throughput
Send Socket Recv Socket Send Socket Recv Socket Size    Size     Burst 
   Time               Units
Size        Size        Size        Size        Bytes   Bytes 
Requests (sec)
Final       Final       Final       Final 

16384       87380       16384       87380       1       1        0 
   10.00   20838.10   Trans/s
16384       87380       16384       87380       1       1        1 
   10.00   38204.89   Trans/s
16384       87380       16384       87380       1       1        2 
   10.00   52497.02   Trans/s
16384       87380       16384       87380       1       1        4 
   10.00   70641.97   Trans/s
16384       87380       16384       87380       1       1        16 
   10.00   136965.24  Trans/s
121200      87380       121200      87380       1       1        64 
   10.00   197037.63  Trans/s
121200      87380       16384       87380       1       1        128 
   10.00   203092.56  Trans/s
121200      313248      121200      349392      1       1        256 
   10.00   163766.32  Trans/s
