From: Bill Fink <billfink@mindspring.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Fri, 14 Sep 2007 03:20:55 -0400
Message-ID: <20070914032055.8f96449b.billfink@mindspring.com>
References: <46CF7B13.3020701@psc.edu>
	<20070826044134.eabd18cf.billfink@mindspring.com>
	<46D229AA.6020900@psc.edu>
	<20070826.190420.41652839.davem@davemloft.net>
	<1188257019.4250.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com, kaber@trash.net,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, jheffner@psc.edu, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1188257019.4250.55.camel@localhost>
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

On Mon, 27 Aug 2007, jamal wrote:

> On Sun, 2007-26-08 at 19:04 -0700, David Miller wrote:
> 
> > The transfer is much better behaved if we ACK every two full sized
> > frames we copy into the receiver, and therefore don't stretch ACK, but
> > at the cost of cpu utilization.
> 
> The rx coalescing in theory should help by accumulating more ACKs on the
> rx side of the sender. But it doesnt seem to do that i.e For the 9K MTU,
> you are better off to turn off the coalescing if you want higher
> numbers. Also some of the TOE vendors (chelsio?) claim to have fixed
> this by reducing bursts on outgoing packets.
>  
> Bill:
> who suggested (as per your email) the 75usec value and what was it based
> on measurement-wise? 

Belatedly getting back to this thread.  There was a recent myri10ge
patch that changed the default value for tx/rx interrupt coalescing
to 75 usec claiming it was an optimum value for maximum throughput
(and is also mentioned in their external README documentation).

I also did some empirical testing to determine the effect of different
values of TX/RX interrupt coalescing on 10-GigE network performance,
both with TSO enabled and with TSO disabled.  The actual test runs
are attached at the end of this message, but the results are summarized
in the following table (network performance in Mbps).

		        TX/RX interrupt coalescing in usec (both sides)
		   0	  15	  30	  45	  60	  75	  90	 105

TSO enabled	8909	9682	9716	9725	9739	9745	9688	9648
TSO disabled	9113	9910	9910	9910	9910	9910	9910	9910

TSO disabled performance is always better than equivalent TSO enabled
performance.  With TSO enabled, the optimum performance is indeed at
a TX/RX interrupt coalescing value of 75 usec.  With TSO disabled,
performance is the full 10-GigE line rate of 9910 Mbps for any value
of TX/RX interrupt coalescing from 15 usec to 105 usec.

> BTW, thanks for the finding the energy to run those tests and a very
> refreshing perspective. I dont mean to add more work, but i had some
> queries;
> On your earlier tests, i think that Reno showed some significant
> differences on the lower MTU case over BIC. I wonder if this is
> consistent? 

Here's a retest (5 tests each):

TSO enabled:

TCP Cubic (initial_ssthresh set to 0):

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5007.6295 MB /  10.06 sec = 4176.1807 Mbps 36 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4950.9279 MB /  10.06 sec = 4130.2528 Mbps 36 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4917.1742 MB /  10.05 sec = 4102.5772 Mbps 35 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4948.7920 MB /  10.05 sec = 4128.7990 Mbps 36 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4937.5765 MB /  10.05 sec = 4120.6460 Mbps 35 %TX 99 %RX

TCP Bic (initial_ssthresh set to 0):

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5005.5335 MB /  10.06 sec = 4172.9571 Mbps 36 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5001.0625 MB /  10.06 sec = 4169.2960 Mbps 36 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4957.7500 MB /  10.06 sec = 4135.7355 Mbps 36 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4957.3777 MB /  10.06 sec = 4135.6252 Mbps 36 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5059.1815 MB /  10.05 sec = 4221.3546 Mbps 37 %TX 99 %RX

TCP Reno:

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4973.3532 MB /  10.06 sec = 4147.3589 Mbps 36 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4984.4375 MB /  10.06 sec = 4155.2131 Mbps 36 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4995.6841 MB /  10.06 sec = 4166.2734 Mbps 36 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4982.2500 MB /  10.05 sec = 4156.7586 Mbps 36 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4989.9796 MB /  10.05 sec = 4163.0949 Mbps 36 %TX 99 %RX

TSO disabled:

TCP Cubic (initial_ssthresh set to 0):

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5075.8125 MB /  10.02 sec = 4247.3408 Mbps 99 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5056.0000 MB /  10.03 sec = 4229.9621 Mbps 100 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5047.4375 MB /  10.03 sec = 4223.1203 Mbps 99 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5066.1875 MB /  10.03 sec = 4239.1659 Mbps 100 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4986.3750 MB /  10.03 sec = 4171.9906 Mbps 99 %TX 100 %RX

TCP Bic (initial_ssthresh set to 0):

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5040.5625 MB /  10.03 sec = 4217.3521 Mbps 100 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5049.7500 MB /  10.03 sec = 4225.4585 Mbps 99 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5076.5000 MB /  10.03 sec = 4247.6632 Mbps 100 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5017.2500 MB /  10.03 sec = 4197.4990 Mbps 100 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5013.3125 MB /  10.03 sec = 4194.8851 Mbps 100 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5036.0625 MB /  10.03 sec = 4213.9195 Mbps 100 %TX 100 %RX

TCP Reno:

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5006.8750 MB /  10.02 sec = 4189.6051 Mbps 99 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5028.1250 MB /  10.02 sec = 4207.4553 Mbps 100 %TX 99 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5021.9375 MB /  10.02 sec = 4202.2668 Mbps 99 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5000.5625 MB /  10.03 sec = 4184.3109 Mbps 99 %TX 100 %RX
[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5025.1250 MB /  10.03 sec = 4204.7378 Mbps 99 %TX 100 %RX

Not too much variation here, and not quite as high results
as previously.  Some further testing reveals that while this
time I mainly get results like (here for TCP Bic with TSO
disabled):

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4958.0625 MB /  10.02 sec = 4148.9361 Mbps 100 %TX 99 %RX

I also sometimes get results like:

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5882.1875 MB /  10.00 sec = 4932.5549 Mbps 100 %TX 90 %RX

The higher performing results seem to correspond to when there's a
somewhat lower receiver CPU utilization.  I'm not sure but there
could also have been an effect from running the "-M1460" test after
the 9000 byte jumbo frame test (no jumbo tests were done at all prior
to running the above sets of 5 tests, although I did always discard
an initial "warmup" test, and now that I think about it some of
those initial discarded "warmup" tests did have somewhat anomalously
high results).

> A side note: Although the experimentation reduces the variables (eg
> tying all to CPU0), it would be more exciting to see multi-cpu and
> multi-flow sender effect (which IMO is more real world). 

These systems are intended as test systems for 10-GigE networks,
and as such it's important to get as consistently close to full
10-GigE line rate as possible, and that's why the interrupts and
nuttcp application are tied to CPU0, with almost all other system
applications tied to CPU1.

Now on another system that's intended as a 10-GigE firewall system,
it has 2 Myricom 10-GigE NICs with the interrupts for eth2 tied to
CPU0 and the interrupts for CPU1 tied to CPU1.  In IP forwarding
tests of this system, I have basically achieved full bidirectional
10-GigE line rate IP forwarding with 9000 byte jumbo frames.

chance4 -> chance6 -> chance9 4.85 Gbps rate limited TCP stream
chance5 -> chance6 -> chance9 4.85 Gbps rate limited TCP stream
chance7 <- chance6 <- chance8 10.0 Gbps non-rate limited TCP stream

[root@chance7 ~]# nuttcp -Ic4tc9 -Ri4.85g -w10m 192.168.88.8 192.168.89.16 & \
    nuttcp -Ic5tc9 -Ri4.85g -w10m -P5100 -p5101 192.168.88.9 192.168.89.16 & \
    nuttcp -Ic7rc8 -r -w10m 192.168.89.15
c4tc9:  5778.6875 MB /  10.01 sec = 4842.7158 Mbps 100 %TX 42 %RX
c5tc9:  5778.9375 MB /  10.01 sec = 4843.1595 Mbps 100 %TX 40 %RX
c7rc8: 11509.1875 MB /  10.00 sec = 9650.8009 Mbps 99 %TX 74 %RX

If there's some other specific test you'd like to see, and it's not
too difficult to set up and I have some spare time, I'll see what I
can do.

						-Bill



Testing of effect of RX/TX interrupt coalescing on 10-GigE network performance
(both with TSO enabled and with TSO disabled):
--------------------------------------------------------------------------------

No RX/TX interrupt coalescing (either side):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
10649.8750 MB /  10.03 sec = 8908.9806 Mbps 97 %TX 100 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
10879.5000 MB /  10.02 sec = 9112.5141 Mbps 99 %TX 99 %RX

RX/TX interrupt coalescing set to 15 usec (both sides):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11546.7500 MB /  10.00 sec = 9682.0785 Mbps 99 %TX 90 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.9375 MB /  10.00 sec = 9910.3702 Mbps 100 %TX 92 %RX

RX/TX interrupt coalescing set to 30 usec (both sides):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11587.1250 MB /  10.00 sec = 9715.9489 Mbps 99 %TX 81 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.8125 MB /  10.00 sec = 9910.3040 Mbps 100 %TX 81 %RX

RX/TX interrupt coalescing set to 45 usec (both sides):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11597.8750 MB /  10.00 sec = 9724.9902 Mbps 99 %TX 76 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.6250 MB /  10.00 sec = 9910.0933 Mbps 100 %TX 77 %RX

RX/TX interrupt coalescing set to 60 usec (both sides):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11614.7500 MB /  10.00 sec = 9739.1323 Mbps 100 %TX 74 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.4375 MB /  10.00 sec = 9909.9995 Mbps 100 %TX 76 %RX

RX/TX interrupt coalescing set to 75 usec (both sides):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11621.7500 MB /  10.00 sec = 9745.0993 Mbps 100 %TX 72 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.0625 MB /  10.00 sec = 9909.7881 Mbps 100 %TX 75 %RX

RX/TX interrupt coalescing set to 90 usec (both sides):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11553.1250 MB /  10.00 sec = 9687.6458 Mbps 100 %TX 71 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.4375 MB /  10.00 sec = 9910.0837 Mbps 100 %TX 73 %RX

RX/TX interrupt coalescing set to 105 usec (both sides):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11505.7500 MB /  10.00 sec = 9647.8558 Mbps 99 %TX 69 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.4375 MB /  10.00 sec = 9910.0530 Mbps 100 %TX 74 %RX
