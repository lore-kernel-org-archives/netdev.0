From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Choppy TCP send performance
Date: Fri, 28 May 2010 15:08:37 -0700
Message-ID: <4C003EE5.6070602@hp.com>
References: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>	<1275081377.2472.13.camel@edumazet-laptop> <AANLkTilZxoSEGOhmWdk2RbIGMmCMi2yNJm9rUwIzDIoL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Tim Heath <theath@greenplum.com>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:37431 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab0E1WIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 18:08:41 -0400
In-Reply-To: <AANLkTilZxoSEGOhmWdk2RbIGMmCMi2yNJm9rUwIzDIoL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Unless you think your application will run over 10G, or over a WAN, you 
shouldn't need anywhere near the size of socket buffer you are getting via 
autotuning to be able to achieve "link-rate" - link rate with a 1GbE LAN 
connection can be achieved quite easily with a 256KB socket buffer.

The first test here is with autotuning going - disregard what netperf reports 
for the socket buffer sizes here - it is calling getsockopt() before connect() 
and before the end of the connection():

raj@spec-ptd2:~/netperf2_trunk$ src/netperf -H s9 -v 2 -l 30 -- -m 128K
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to s9.cup.hp.com 
(16.89.132.29) port 0 AF_INET : histogram
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384 131072    30.01     911.50

Alignment      Offset         Bytes    Bytes       Sends   Bytes    Recvs
Local  Remote  Local  Remote  Xfered   Per                 Per
Send   Recv    Send   Recv             Send (avg)          Recv (avg)
     8       8      0       0 3.42e+09  131074.49     26090   11624.79 294176

Maximum
Segment
Size (bytes)
   1448


Histogram of time spent in send() call.
UNIT_USEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_USEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_USEC  :    0:    3: 21578:  378:   94:   20:    3:    2:    0:    4
UNIT_MSEC     :    0:    4:    2:    0:    0:  780: 3215:    6:    0:    1
TEN_MSEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_MSEC  :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
UNIT_SEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_SEC       :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
 >100_SECS: 0
HIST_TOTAL:      26090


Next, we have netperf make an explicit setsockopt() call for 128KB socket 
buffers, which will get us 256K.  Notice that the bandwidth remains the same, 
but the distribution of the time spent in send() changes.  It gets squeezed more 
towards the middle of the range from before.

<unk$ src/netperf -H s9 -v 2 -l 30 -- -m 128K -s 128K -S 128K
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to s9.cup.hp.com 
(16.89.132.29) port 0 AF_INET : histogram
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

262142 262144 131072    30.00     911.91

Alignment      Offset         Bytes    Bytes       Sends   Bytes    Recvs
Local  Remote  Local  Remote  Xfered   Per                 Per
Send   Recv    Send   Recv             Send (avg)          Recv (avg)
     8       8      0       0 3.42e+09  131074.74     26091   11361.40 301008

Maximum
Segment
Size (bytes)
   1448


Histogram of time spent in send() call.
UNIT_USEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_USEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_USEC  :    0:  401:   64:   10:    0:    0:    1:  279: 10237: 3914
UNIT_MSEC     :    0: 11149:   31:    0:    4:    0:    0:    0:    0:    0
TEN_MSEC      :    0:    1:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_MSEC  :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
UNIT_SEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_SEC       :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
 >100_SECS: 0
HIST_TOTAL:      26091

happy benchmarking,

rick jones


Just for grins, netperf asking for 64K socket buffers:

<unk$ src/netperf -H s9 -v 2 -l 30 -- -m 128K -s 64K -S 64K
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to s9.cup.hp.com 
(16.89.132.29) port 0 AF_INET : histogram
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

131072 131072 131072    30.00     921.12

Alignment      Offset         Bytes    Bytes       Sends   Bytes    Recvs
Local  Remote  Local  Remote  Xfered   Per                 Per
Send   Recv    Send   Recv             Send (avg)          Recv (avg)
     8       8      0       0 3.454e+09  131074.33     26354   11399.69 303020

Maximum
Segment
Size (bytes)
   1448


Histogram of time spent in send() call.
UNIT_USEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_USEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_USEC  :    0:    2:    0:    0:    0:    7: 2672: 1831:   19:    1
UNIT_MSEC     :    0: 21811:    6:    0:    4:    0:    0:    0:    0:    0
TEN_MSEC      :    0:    1:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_MSEC  :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
UNIT_SEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_SEC       :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
 >100_SECS: 0
HIST_TOTAL:      26354
