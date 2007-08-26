From: Bill Fink <billfink@mindspring.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Sun, 26 Aug 2007 04:41:34 -0400
Message-ID: <20070826044134.eabd18cf.billfink@mindspring.com>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	<20070821.212229.82050253.davem@davemloft.net>
	<46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
	<1187906650.4279.16.camel@localhost>
	<1187907903.4279.28.camel@localhost> <46CE0BA1.60206@hp.com>
	<20070823231820.2ae52cc0.billfink@mindspring.com>
	<46CF7B13.3020701@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, mcarlson@broadcom.com,
	rdreier@cisco.com, hadi@cyberus.ca, kaber@trash.net,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: John Heffner <jheffner@psc.edu>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46CF7B13.3020701@psc.edu>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Aug 2007, John Heffner wrote:

> Bill Fink wrote:
> > Here you can see there is a major difference in the TX CPU utilization
> > (99 % with TSO disabled versus only 39 % with TSO enabled), although
> > the TSO disabled case was able to squeeze out a little extra performance
> > from its extra CPU utilization.  Interestingly, with TSO enabled, the
> > receiver actually consumed more CPU than with TSO disabled, so I guess
> > the receiver CPU saturation in that case (99 %) was what restricted
> > its performance somewhat (this was consistent across a few test runs).
> 
> One possibility is that I think the receive-side processing tends to do 
> better when receiving into an empty queue.  When the (non-TSO) sender is 
> the flow's bottleneck, this is going to be the case.  But when you 
> switch to TSO, the receiver becomes the bottleneck and you're always 
> going to have to put the packets at the back of the receive queue.  This 
> might help account for the reason why you have both lower throughput and 
> higher CPU utilization -- there's a point of instability right where the 
> receiver becomes the bottleneck and you end up pushing it over to the 
> bad side. :)
> 
> Just a theory.  I'm honestly surprised this effect would be so 
> significant.  What do the numbers from netstat -s look like in the two 
> cases?

Well, I was going to check this out, but I happened to reboot the
system and now I get somewhat different results.

Here are the new results, which should hopefully be more accurate
since they are on a freshly booted system.

TSO enabled and GSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11610.6875 MB /  10.00 sec = 9735.9526 Mbps 100 %TX 75 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5029.6875 MB /  10.06 sec = 4194.6931 Mbps 36 %TX 100 %RX

TSO disabled and GSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11817.9375 MB /  10.00 sec = 9909.7773 Mbps 99 %TX 77 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5823.3125 MB /  10.00 sec = 4883.2429 Mbps 100 %TX 82 %RX

The TSO disabled case got a little better performance even for
9000 byte jumbo frames.  For the "-M1460" case eumalating a
standard 1500 byte Ethernet MTU, the performance was significantly
better and used less CPU on the receiver (82 % versus 100 %)
although it did use significantly more CPU on the transmitter
(100 % versus 36 %).

TSO disabled and GSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11609.5625 MB /  10.00 sec = 9734.9859 Mbps 99 %TX 75 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5001.4375 MB /  10.06 sec = 4170.6739 Mbps 52 %TX 100 %RX

The GSO enabled case is very similar to the TSO enabled case,
except that for the "-M1460" test the transmitter used more
CPU (52 % versus 36 %), which is to be expected since TSO has
hardware assist.

Here's the beforeafter delta of the receiver's "netstat -s"
statistics for the TSO enabled case:

Ip:
    3659898 total packets received
    3659898 incoming packets delivered
    80050 requests sent out
Tcp:
    2 passive connection openings
    3659897 segments received
    80050 segments send out
TcpExt:
    33 packets directly queued to recvmsg prequeue.
    104956 packets directly received from backlog
    705528 packets directly received from prequeue
    3654842 packets header predicted
    193 packets header predicted and directly queued to user
    4 acknowledgments not containing data received
    6 predicted acknowledgments

And here it is for the TSO disabled case (GSO also disabled):

Ip:
    4107083 total packets received
    4107083 incoming packets delivered
    1401376 requests sent out
Tcp:
    2 passive connection openings
    4107083 segments received
    1401376 segments send out
TcpExt:
    2 TCP sockets finished time wait in fast timer
    48486 packets directly queued to recvmsg prequeue.
    1056111048 packets directly received from backlog
    2273357712 packets directly received from prequeue
    1819317 packets header predicted
    2287497 packets header predicted and directly queued to user
    4 acknowledgments not containing data received
    10 predicted acknowledgments

For the TSO disabled case, there are a huge amount more TCP segments
sent out (1401376 versus 80050), which I assume are ACKs, and which
could possibly contribute to the higher throughput for the TSO disabled
case due to faster feedback, but not explain the lower CPU utilization.
There are many more packets directly queued to recvmsg prequeue
(48486 versus 33).  The numbers for packets directly received from
backlog and prequeue in the TCP disabled case seem bogus to me so
I don't know how to interpret that.  There are only about half as
many packets header predicted (1819317 versus 3654842), but there
are many more packets header predicted and directly queued to user
(2287497 versus 193).  I'll leave the analysis of all this to those
who might actually know what it all means.

I also ran another set of tests that may be of interest.  I changed
the rx-usecs/tx-usecs interrupt coalescing parameter from the
recommended optimum value of 75 usecs to 0 (no coalescing), but
only on the transmitter.  The comparison discussions below are
relative to the previous tests where rx-usecs/tx-usecs were set
to 75 usecs.

TSO enabled and GSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11812.8125 MB /  10.00 sec = 9905.6640 Mbps 100 %TX 75 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 7701.8750 MB /  10.00 sec = 6458.5541 Mbps 100 %TX 56 %RX

For 9000 byte jumbo frames it now gets a little better performance
and almost matches the 10-GigE line rate performance of the TSO
disabled case.  For the "-M1460" test, it gets substantially better
performance (6458.5541 Mbps versus 4194.6931 Mbps) at the expense
of much higher transmitter CPU utilization (100 % versus 36 %),
although the receiver CPU utilization is much less (56 % versus 100 %).

TSO disabled and GSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11817.3125 MB /  10.00 sec = 9909.4058 Mbps 100 %TX 76 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4081.2500 MB /  10.00 sec = 3422.3994 Mbps 99 %TX 41 %RX

For 9000 byte jumbo frames the results are essentially the same.
For the "-M1460" test, the performance is significantly worse
(3422.3994 Mbps versus 4883.2429 Mbps) even though the transmitter
CPU utilization is saturated in both cases, but the receiver CPU
utilization is about half (41 % versus 82 %).

TSO disabled and GSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11813.3750 MB /  10.00 sec = 9906.1090 Mbps 99 %TX 77 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 3939.1875 MB /  10.00 sec = 3303.2814 Mbps 100 %TX 41 %RX

For 9000 byte jumbo frames the performance is a little better,
again approaching 10-GigE line rate.  But for the "-M1460" test,
the performance is significantly worse (3303.2814 Mbps versus
4170.6739 Mbps) even though the transmitter consumes much more
CPU (100 % versus 52 %).  In this case though the receiver has
a much lower CPU utilization (41 % versus 100 %).

						-Bill
