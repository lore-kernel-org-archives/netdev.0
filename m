From: sdrb@onet.eu
Subject: Re: Variable download speed
Date: Wed, 24 Feb 2016 10:59:23 +0100 (CET)
Message-ID: <alpine.LNX.2.20.1602241044310.29937@localhost.localdomain>
References: <alpine.LNX.2.20.1602231223530.29937@localhost.localdomain> <56CC8E86.7000102@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo75.poczta.onet.pl ([141.105.16.25]:33500 "EHLO
	smtpo75.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbcBXJ7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 04:59:31 -0500
In-Reply-To: <56CC8E86.7000102@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Feb 2016, Rick Jones wrote:

> On 02/23/2016 03:24 AM, sdrb@onet.eu wrote:
>>  Hi,
>>
>>  I've got a problem with network on one of my embedded boards.
>>  I'm testing download speed of 256MB file from my PC to embedded board
>>  through 1Gbit ethernet link using ftp.
>>
>>  The problem is that sometimes I achieve 25MB/s and sometimes it is only
>>  14MB/s. There are also situations where the transfer speed starts at
>>  14MB/s and after a few seconds achieves 25MB/s.
>>  I've caught the second case with tcpdump and I noticed that when the speed
>>  is 14MB/s - the tcp window size is 534368 bytes and when the speed
>>  achieved 25MB/s the tcp window size is 933888.
>>
>>  My question is: what causes such dynamic change in the window size (while
>>  transferring data)?  Is it some kernel parameter wrong set or something
>>  like this?
>>  Do I have any influence on such dynamic change in tcp window size?
>
>
> If an application using TCP does not make an explicit setsockopt() call to 
> set the SO_SNDBUF and/or SO_RCVBUF size, then the socket buffer and TCP 
> window size will "autotune" based on what the stack believes to be the 
> correct thing to do.  It will be bounded by the values in the tcp_rmem and 
> tcp_wmem sysctl settings:
>
>
> net.ipv4.tcp_rmem = 4096	87380	6291456
> net.ipv4.tcp_wmem = 4096	16384	4194304
>
> Those are min, initial, max, units of octets (bytes).
>
> If on the other hand an application makes an explicit setsockopt() call, 
> that will be the size of the socket buffer, though it will be "clipped" by 
> the values of:
>
> net.core.rmem_max = 4194304
> net.core.wmem_max = 4194304
>
> Those sysctls will default to different values based on how much memory is in 
> the system.  And I think in the case of those last two, I have tweaked them 
> myself away from their default values.
>
> You might also look at the CPU utilization of all the CPUs of your embedded 
> board, as well as the link-level statistics for your interface, and the 
> netstat statistics.  You would be looking for saturation, and "excessive" 
> drop rates.  I would also suggest testing network performance with something 
> other than FTP.  While one can try to craft things so there is no storage I/O 
> of note, it would still be better to use a network-specific tool such as 
> netperf or iperf.  Minimize the number of variables.
>
> happy benchmarking,

Hi,
To be honest I don't know if "wget" uses setsockopt() in this case.

As you suggested I observed the system information while using wget.

"top" shows that kernel thread which is used by ethernet driver uses 100% 
of first cpu and "wget" application uses at the same time 85% of second 
cpu.


More interesting are the information from vmstat:
procs -----------memory---------- ---swap-- -----io---- -system-- 
------cpu-----
  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id 
wa st
  0  0      0 119688      4  81096    0    0     0     0   55   24  0  6 93 
0  0
  0  0      0 119664      4  81132    0    0     0     0  632 1223  0  0 
100  0  0
  0  0      0 119664      4  81156    0    0     0     0  640 1300  0  0 
100  0  0
  0  0      0 119664      4  81156    0    0     0     0  632 1284  0  0 
100  0  0
  0  0      0 119664      4  81152    0    0     0     0  633 1283  0  0 
100  0  0
  0  0      0 119604      4  81148    0    0     0     0  637 1292  0  0 
100  0  0
  0  0      0 119604      4  81148    0    0     0     0  634 1289  0  0 
100  0  0
  0  0      0 119604      4  81144    0    0     0     0  637 1395  0  0 
100  0  0
  0  0      0 119604      4  81140    0    0     0     0  639 1296  0  0 
100  0  0
  0  0      0 119604      4  81132    0    0     0     0  633 1282  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  638 1298  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  635 1288  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  634 1283  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  626 1273  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  634 1287  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  633 1286  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  635 1399  0  0 
100  0  0
  0  0      0 119604      4  81128    0    0     0     0  638 1287  0  0 
100  0  0
  0  0      0 119604      4  81136    0    0     0     0  633 1286  0  0 
100  0  0
  0  0      0 119468      4  81168    0    0     0     0  669 1422  1  0 99 
0  0
start of wget at 14MB/s
  4  0      0 119444      4  81240    0    0     0     0 3541 6869  0 18 82 
0  0
  4  0      0 119444      4  81276    0    0     0     0 10200 20032  4 55 
40  0  0
  4  0      0 119444      4  81276    0    0     0     0 10175 19981  3 57 
39  0  0
  4  0      0 119444      4  81272    0    0     0     0 10170 19986  5 57 
37  0  0
  5  0      0 119444      4  81272    0    0     0     0 10158 19950  4 60 
36  0  0
  6  0      0 119412      4  81272    0    0     0     0 9711 19316  7 56 
37  0  0
  3  0      0 119460      4  81288    0    0     0     0 1828 3400  4 89  7 
0  0
speed 25MB/s
  4  0      0 119460      4  81288    0    0     0     0 1674 3044  9 89  2 
0  0
  4  0      0 119460      4  81288    0    0     0     0 1606 2929  4 93  2 
0  0
  4  0      0 119460      4  81288    0    0     0     0 1560 2832  2 93  4 
0  0
  5  0      0 119460      4  81284    0    0     0     0 1552 2806  3 94  3 
0  0
  4  0      0 119460      4  81280    0    0     0     0 1624 2945  2 95  3 
0  0
  5  0      0 119460      4  81276    0    0     0     0 1228 2165  6 93  1 
0  0
end of wget transmission
  0  0      0 119580      4  81276    0    0     0     0 1066 1935  2 26 72 
0  0
  0  0      0 119604      4  81280    0    0     0     0  608 1043  0  0 
100  0  0


Looks like when the wget transmission starts at 14MB/s - there are a lot 
of interrupts and context switchings (irqs: 10000 cs:20000), but when the 
speed increases to 25MB/s number of interrupts decreases to about 1500.
I suppose that in such a case the ethernet driver is suspected.


I've tested also as you suggested the throughput using iperf - and there 
is no such significant difference in download speed like in wget case.


sdrb
