From: Bill Fink <billfink@mindspring.com>
Subject: Re: Autotuning and send buffer size
Date: Fri, 11 Jul 2008 17:01:09 -0400
Message-ID: <20080711170109.c4e42546.billfink@mindspring.com>
References: <20080711150208.GA15305@citi.umich.edu>
	<48778EC6.8070507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jim Rees <rees@umich.edu>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:33099 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602AbYGKVBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 17:01:16 -0400
In-Reply-To: <48778EC6.8070507@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jul 2008, Rick Jones wrote:

> > I don't undestand how a "too big" sender buffer can hurt performance.  I
> > have not measured what size the sender's buffer is in the autotuning case.
> 
> In broad handwaving terms, TCP will have no more data outstanding at one 
> time than the lesser of:
> 
> *) what the application has sent
> *) the current value of the computed congestion window
> *) the receiver's advertised window
> *) the quantity of data TCP can hold in its retransmission queue
> 
> That last one is, IIRC directly related to "SO_SNDBUF"
> 
> That leads to an hypothesis of all of those being/growing large enough 
> to overflow a queue somewhere - for example an interface's transmit 
> queue and causing retransmissions.  Ostensibly, one could check that in 
> ifconfig and/or netstat statistics.

The latest 6.0.1-beta version of nuttcp, available at:

	http://lcp.nrl.navy.mil/nuttcp/beta/nuttcp-6.0.1.c

will report TCP retransmission info.

I did some tests on 10-GigE and TCP retransmissions weren't an issue,
but specifying too large a socket buffer size did have a performance
penalty (tests run on 2.6.20.7 kernel).

First, using a 512 KB socket buffer:

[root@chance8 ~]# repeat 10 taskset 1 nuttcp -f-beta -M1460 -w512k 192.168.88.13 | ./mam 7
 5620.7500 MB /  10.01 sec = 4709.4941 Mbps 99 %TX 66 %RX 0 retrans
 5465.5000 MB /  10.01 sec = 4579.4129 Mbps 100 %TX 63 %RX 0 retrans
 5704.0625 MB /  10.01 sec = 4781.2377 Mbps 100 %TX 71 %RX 0 retrans
 5398.5000 MB /  10.01 sec = 4525.1052 Mbps 99 %TX 62 %RX 0 retrans
 5691.6250 MB /  10.01 sec = 4770.8076 Mbps 99 %TX 71 %RX 0 retrans
 5404.1875 MB /  10.01 sec = 4529.8749 Mbps 99 %TX 64 %RX 0 retrans
 5698.3125 MB /  10.01 sec = 4776.3878 Mbps 100 %TX 70 %RX 0 retrans
 5400.6250 MB /  10.01 sec = 4526.8575 Mbps 100 %TX 65 %RX 0 retrans
 5694.7500 MB /  10.01 sec = 4773.3970 Mbps 100 %TX 71 %RX 0 retrans
 5440.9375 MB /  10.01 sec = 4558.8289 Mbps 100 %TX 64 %RX 0 retrans

min/avg/max = 4525.1052/4653.1404/4781.2377

I specified a TCP MSS of 1460 to force use of standard 1500-byte
Ethernet IP MTU since my default mode is to use 9000-byte jumbo
frames (I also have TSO disabled).

Then, using a 10 MB socket buffer:

[root@chance8 ~]# repeat 10 taskset 1 nuttcp -f-beta -M1460 -w10m 192.168.88.13 | ./mam 7
 5675.8750 MB /  10.01 sec = 4757.6071 Mbps 100 %TX 66 %RX 0 retrans
 5717.6250 MB /  10.01 sec = 4792.6069 Mbps 100 %TX 72 %RX 0 retrans
 5679.0000 MB /  10.01 sec = 4760.2204 Mbps 100 %TX 70 %RX 0 retrans
 5444.3125 MB /  10.01 sec = 4563.4777 Mbps 99 %TX 63 %RX 0 retrans
 5689.0625 MB /  10.01 sec = 4768.6363 Mbps 100 %TX 72 %RX 0 retrans
 5583.1875 MB /  10.01 sec = 4679.8851 Mbps 100 %TX 67 %RX 0 retrans
 5647.1250 MB /  10.01 sec = 4731.5889 Mbps 100 %TX 68 %RX 0 retrans
 5605.2500 MB /  10.01 sec = 4696.5324 Mbps 100 %TX 68 %RX 0 retrans
 5609.2500 MB /  10.01 sec = 4701.7601 Mbps 100 %TX 66 %RX 0 retrans
 5633.0000 MB /  10.01 sec = 4721.6696 Mbps 100 %TX 65 %RX 0 retrans

min/avg/max = 4563.4777/4717.3984/4792.6069

Not much difference (about a 1.38 % increase).

But then switching to a 100 MB socket buffer:

[root@chance8 ~]# repeat 10 taskset 1 nuttcp -f-beta -M1460 -w100m 192.168.88.13 | ./mam 7
 4887.6250 MB /  10.01 sec = 4095.2239 Mbps 99 %TX 68 %RX 0 retrans
 4956.0625 MB /  10.01 sec = 4152.5652 Mbps 100 %TX 68 %RX 0 retrans
 4935.3750 MB /  10.01 sec = 4136.9084 Mbps 99 %TX 69 %RX 0 retrans
 4962.5000 MB /  10.01 sec = 4159.6409 Mbps 100 %TX 69 %RX 0 retrans
 4919.9375 MB /  10.01 sec = 4123.9685 Mbps 100 %TX 68 %RX 0 retrans
 4947.0625 MB /  10.01 sec = 4146.7009 Mbps 100 %TX 69 %RX 0 retrans
 5071.0625 MB /  10.01 sec = 4250.6175 Mbps 100 %TX 75 %RX 0 retrans
 4958.3125 MB /  10.01 sec = 4156.1080 Mbps 100 %TX 71 %RX 0 retrans
 5078.3750 MB /  10.01 sec = 4256.7461 Mbps 100 %TX 74 %RX 0 retrans
 4955.1875 MB /  10.01 sec = 4151.8279 Mbps 100 %TX 67 %RX 0 retrans

min/avg/max = 4095.2239/4163.0307/4256.7461

This did take about a 8.95 % performance hit.

And using TCP autotuning:

[root@chance8 ~]# repeat 10 taskset 1 nuttcp -f-beta -M1460 192.168.88.13 | ./mam 7
 5673.6875 MB /  10.01 sec = 4755.7692 Mbps 100 %TX 66 %RX 0 retrans
 5659.3125 MB /  10.01 sec = 4743.6986 Mbps 99 %TX 67 %RX 0 retrans
 5835.5000 MB /  10.01 sec = 4891.3760 Mbps 99 %TX 70 %RX 0 retrans
 4985.5625 MB /  10.01 sec = 4177.2838 Mbps 99 %TX 68 %RX 0 retrans
 5753.0000 MB /  10.01 sec = 4820.2951 Mbps 100 %TX 67 %RX 0 retrans
 5536.8750 MB /  10.01 sec = 4641.0910 Mbps 100 %TX 63 %RX 0 retrans
 5610.5625 MB /  10.01 sec = 4702.8626 Mbps 100 %TX 62 %RX 0 retrans
 5576.5625 MB /  10.01 sec = 4674.3628 Mbps 100 %TX 66 %RX 0 retrans
 5573.5625 MB /  10.01 sec = 4671.8411 Mbps 100 %TX 64 %RX 0 retrans
 5550.0000 MB /  10.01 sec = 4652.0684 Mbps 100 %TX 65 %RX 0 retrans

min/avg/max = 4177.2838/4673.0649/4891.3760

For the 10-GigE testing there was no performance penalty using the
TCP autotuning, getting basically the same performance as the "-w512k"
test case.  Perhaps this is because the send socket buffer size never
gets up to the 100 MB levels for 10-GigE where it would be an issue
(GigE may have lower thresholds for encountering the issue).

While I was it, I decided to also check the CPU affinity issue,
since these tests are CPU limited, and re-ran the "-w512k" test
case on CPU 1 (using "taskset 2"):

[root@chance8 ~]# repeat 10 taskset 2 nuttcp -f-beta -M1460 -w512k 192.168.88.13 | ./mam 7
 4942.0625 MB /  10.01 sec = 4142.5086 Mbps 100 %TX 56 %RX 0 retrans
 4833.4375 MB /  10.01 sec = 4051.4628 Mbps 100 %TX 52 %RX 0 retrans
 5291.0000 MB /  10.01 sec = 4434.9701 Mbps 99 %TX 63 %RX 0 retrans
 5287.7500 MB /  10.01 sec = 4432.2468 Mbps 100 %TX 62 %RX 0 retrans
 5011.7500 MB /  10.01 sec = 4200.9007 Mbps 99 %TX 56 %RX 0 retrans
 5198.5625 MB /  10.01 sec = 4355.7784 Mbps 100 %TX 62 %RX 0 retrans
 4981.0000 MB /  10.01 sec = 4173.4818 Mbps 100 %TX 54 %RX 0 retrans
 4991.1250 MB /  10.01 sec = 4183.6394 Mbps 100 %TX 55 %RX 0 retrans
 5234.7500 MB /  10.01 sec = 4387.8510 Mbps 99 %TX 60 %RX 0 retrans
 4994.3125 MB /  10.01 sec = 4186.3108 Mbps 100 %TX 57 %RX 0 retrans

min/avg/max = 4051.4628/4254.9150/4434.9701

This took about a 8.56 % performance hit relative to running the
same test on CPU 0, which is also the CPU that handles the 10-GigE
NIC interrupts.  Note the test systems are dual-CPU but single-core
(dual 2.8 GHz AMD Opterons).

						-Bill
