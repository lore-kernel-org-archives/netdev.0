From: Bill Fink <billfink@mindspring.com>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Wed, 16 May 2007 02:44:09 -0400
Message-ID: <20070516024409.53049682.billfink@mindspring.com>
References: <20070509023131.70e2cc45.billfink@mindspring.com>
	<20070510113215.f5ff2d34.billfink@mindspring.com>
	<2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu>
	<20070510.133522.99205764.davem@davemloft.net>
	<20070510134547.7ec30308@freepuppy>
	<002301c79345$c45ffd00$4a580e98@ncsu2cc0c3fa00>
	<20070512120739.371ada4f.billfink@mindspring.com>
	<649aecc70705120945q58ae79c9r8ff2dc5557658d1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Injong Rhee" <rhee@eos.ncsu.edu>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, rhee@ncsu.edu,
	netdev@vger.kernel.org
To: "SANGTAE HA" <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:42409 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760257AbXEPGoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 02:44:19 -0400
In-Reply-To: <649aecc70705120945q58ae79c9r8ff2dc5557658d1e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sangtae,

On Sat, 12 May 2007, Sangtae Ha wrote:

> Hi Bill,
> 
> This is the small patch that has been applied to 2.6.22.
> Also, there is "limited slow start", which is an experimental RFC
> (RFC3742), to surmount this large increase during slow start.
> But, your kernel might not have this. Please check there is a sysctl
> variable "tcp_max_ssthresh".

I reviewed RFC3742.  It seems to me to be problematic for 10-GigE and
faster nets, although it might be OK for GigE nets.

Take the case of a 10-GigE net connecting two sites with an 85 ms RTT
(real world case I am interested in connecting an East coast and
West coast site).  That equates to:

	gwiz% bc -l
	scale=10
	10^10*0.085/9000/8
	11805.5555555555

up to 11806 9000-byte jumbo frame packets possibly in flight during
one RTT at full 10-GigE line rate.  Using the formula from RFC3742:

	log(max_ssthresh) + (cwnd - max_ssthresh)/(max_ssthresh/2)

[note I believe the formula should have a "+1"]

and the recommended value for max_ssthresh of 100 gives:

	gwiz% bc -l
	scale=10
	l(100)/l(2)+(11806-100)/(100/2)
	240.7638561902

That's 241 RTTs to get up to full 10-GigE line rate, or a total
period of 241*0.085 = 20.485 seconds.  And if you were using
standard 1500-byte packets, the numbers would become up to 70834
packets in flight during one RTT, 1422 RTTs to achieve full 10-GigE
line rate, which results in a total period of 120.870 seconds.
Considering that international links can have even larger RTTs
and the future will bring 100-GigE links, it doesn't appear this
method scales well to extremely high performance, large RTT paths.

For 10-GigE, max_ssthresh would need to be scaled up to 1000.
Combined with using 9000-byte jumbo frames, this results in:

	gwiz% bc -l
	scale=10
	l(1000)/l(2)+(11806-1000)/(1000/2)
	31.5777842854

That's only 32 RTTs to achieve full 10-GigE line rate, or a total
period of 2.720 seconds (compared to a bare minimum of 14 RTTs
and 1.190 seconds).  Again using standard 1500-byte packets would
take six times as long.  And while a 1000/2=500 packet increase may
seem like a lot, it's only 4.2% of the available 10-GigE bandwidth,
which is the same percentage as a 100/2=50 packet increase on a
GigE network.

BTW there seems to be a calculation error in RFC3742.  They give an
example of a congestion window of 83000 packets (with max_ssthresh
set to 100).  If you do the calculation based on the formula given
(which I believe to be correct), the number of RTTs works out to
be 1665.  If you drop the "/2" from the formula, only then do you
get 836 RTTs as indicated in the RFC example.

My 2.6.20.7 kernel does not have a tcp_max_ssthresh variable, but
it is an undocumented variable in 2.6.21-git13, so I may do some
more tests if and when I can get that working.

I applied your tcp_cubic.c patch to my 2.6.20.7 kernel and ran some
additional tests.  The results were basically the same, which is to
be expected since you indicated the change didn't affect the slow start
behavior.

I did run a couple of new tests, transferring a fixed 1 GB amount
of data, and reducing the amount of buffering to the netem delay
emulator so it could only sustain a data rate of about 1.6 Gbps.

First with the default cubic slow start behavior:

[root@lang2 ~]# cat /proc/version
Linux version 2.6.20.7-cubic21 (root@lang2.eiger.nasa.atd.net) (gcc version 4.1.1 20060525 (Red Hat 4.1.1-1)) #2 SMP Tue May 15 03:14:33 EDT 2007

[root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
cubic

[root@lang2 ~]# cat /sys/module/tcp_cubic/parameters/initial_ssthresh
100

[root@lang2 ~]# netstat -s | grep -i retrans
    22360 segments retransmited
    17850 fast retransmits
    4503 retransmits in slow start
    4 sack retransmits failed

[root@lang2 ~]# nuttcp -n1g -i1 -w60m 192.168.89.15
    6.8188 MB /   1.00 sec =   56.9466 Mbps
   16.2097 MB /   1.00 sec =  135.9795 Mbps
   25.4553 MB /   1.00 sec =  213.5377 Mbps
   35.6750 MB /   1.00 sec =  299.2676 Mbps
   43.9124 MB /   1.00 sec =  368.3687 Mbps
   52.2266 MB /   1.00 sec =  438.1139 Mbps
   62.1045 MB /   1.00 sec =  520.9765 Mbps
   73.9136 MB /   1.00 sec =  620.0401 Mbps
   87.7820 MB /   1.00 sec =  736.3775 Mbps
  104.2480 MB /   1.00 sec =  874.5074 Mbps
  117.8259 MB /   1.00 sec =  988.3441 Mbps
  139.7266 MB /   1.00 sec = 1172.1969 Mbps
  171.8384 MB /   1.00 sec = 1441.5107 Mbps

 1024.0000 MB /  13.44 sec =  639.2926 Mbps 7 %TX 7 %RX

[root@lang2 ~]# netstat -s | grep -i retrans
    22360 segments retransmited
    17850 fast retransmits
    4503 retransmits in slow start
    4 sack retransmits failed

It took 13.44 seconds to transfer 1 GB of data, never experiencing
any congestion.

Now with the standard aggressive Reno "slow start" behavior, which
experiences "congestion" at about 1.6 Gbps:

[root@lang2 ~]# echo 0 >> /sys/module/tcp_cubic/parameters/initial_ssthresh
[root@lang2 ~]# cat /sys/module/tcp_cubic/parameters/initial_ssthresh
0

[root@lang2 ~]# nuttcp -n1g -i1 -w60m 192.168.89.15
   34.5728 MB /   1.00 sec =  288.7865 Mbps
  108.0847 MB /   1.00 sec =  906.6994 Mbps
  160.3540 MB /   1.00 sec = 1345.0124 Mbps
  180.6226 MB /   1.00 sec = 1515.3385 Mbps
  195.5276 MB /   1.00 sec = 1640.2125 Mbps
  199.6750 MB /   1.00 sec = 1675.0192 Mbps

 1024.0000 MB /   6.70 sec = 1282.1900 Mbps 17 %TX 31 %RX

[root@lang2 ~]# netstat -s | grep -i retrans
    25446 segments retransmited
    20936 fast retransmits
    4503 retransmits in slow start
    4 sack retransmits failed

It only took 6.70 seconds to transfer 1 GB of data.  Note all the
retransmits were fast retransmits.

And finally with the standard aggressive Reno "slow start" behavior,
with no congestion experienced (increased the amount of buffering to
the netem delay emulator):

[root@lang2 ~]# nuttcp -n1g -i1 -w60m 192.168.89.15
   69.9829 MB /   1.01 sec =  583.0183 Mbps
  837.8787 MB /   1.00 sec = 7028.6427 Mbps

 1024.0000 MB /   2.14 sec = 4005.2066 Mbps 52 %TX 32 %RX

[root@lang2 ~]# netstat -s | grep -i retrans
    25446 segments retransmited
    20936 fast retransmits
    4503 retransmits in slow start
    4 sack retransmits failed

It then only took 2.14 seconds to transfer 1 GB of data.

That's all for now.

						-Bill



> Thanks,
> Sangtae
> 
> 
> On 5/12/07, Bill Fink <billfink@mindspring.com> wrote:
> > On Thu, 10 May 2007, Injong Rhee wrote:
> >
> > > Oops. I thought Bill was using 2.6.20 instead of 2.6.22 which should contain
> > > our latest update.
> >
> > I am using 2.6.20.7.
> >
> > > Regarding slow start behavior, the latest version should not change though.
> > > I think it would be ok to change the slow start of bic and cubic to the
> > > default slow start. But what we observed is that when BDP is large,
> > > increasing cwnd by two times is really an overkill. consider increasing from
> > > 1024 into 2048 packets..maybe the target is somewhere between them. We have
> > > potentially a large number of packets flushed into the network. That was the
> > > original motivation to change slow start from the default into a more gentle
> > > version. But I see the point that Bill is raising. We are working on
> > > improving this behavior in our lab. We will get back to this topic in a
> > > couple of weeks after we finish our testing and produce a patch.
> >
> > Is it feasible to replace the version of cubic in 2.6.20.7 with the
> > new 2.1 version of cubic without changing the rest of the kernel, or
> > are there kernel changes/dependencies that would prevent that?
> >
> > I've tried building and running a 2.6.21-git13 kernel, but am having
> > some difficulties.  I will be away the rest of the weekend so won't be
> > able to get back to this until Monday.
> >
> >                                                 -Bill
> >
> > P.S.  When getting into the the 10 Gbps range, I'm not sure there's
> >       any way to avoid the types of large increases during "slow start"
> >       that you mention, if you want to achieve those kinds of data
> >       rates.
> >
> >
> >
> > > ----- Original Message -----
> > > From: "Stephen Hemminger" <shemminger@linux-foundation.org>
> > > To: "David Miller" <davem@davemloft.net>
> > > Cc: <rhee@ncsu.edu>; <billfink@mindspring.com>; <sangtae.ha@gmail.com>;
> > > <netdev@vger.kernel.org>
> > > Sent: Thursday, May 10, 2007 4:45 PM
> > > Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
> > >
> > >
> > > > On Thu, 10 May 2007 13:35:22 -0700 (PDT)
> > > > David Miller <davem@davemloft.net> wrote:
> > > >
> > > >> From: rhee@ncsu.edu
> > > >> Date: Thu, 10 May 2007 14:39:25 -0400 (EDT)
> > > >>
> > > >> >
> > > >> > Bill,
> > > >> > Could you test with the lastest version of CUBIC? this is not the
> > > >> > latest
> > > >> > version of it you tested.
> > > >>
> > > >> Rhee-sangsang-nim, it might be a lot easier for people if you provide
> > > >> a patch against the current tree for users to test instead of
> > > >> constantly pointing them to your web site.
> > > >> -
> > > >
> > > > The 2.6.22 version should have the latest version, that I know of.
> > > > There was small patch from 2.6.21 that went in.
> >
> 
