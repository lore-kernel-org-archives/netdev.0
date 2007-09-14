From: jamal <hadi@cyberus.ca>
Subject: TSO, TCP Cong control etc
Date: Fri, 14 Sep 2007 09:44:00 -0400
Message-ID: <1189777440.4266.77.camel@localhost>
References: <46CF7B13.3020701@psc.edu>
	 <20070826044134.eabd18cf.billfink@mindspring.com>
	 <46D229AA.6020900@psc.edu> <20070826.190420.41652839.davem@davemloft.net>
	 <1188257019.4250.55.camel@localhost>
	 <20070914032055.8f96449b.billfink@mindspring.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jheffner@psc.edu,
	rick.jones2@hp.com, krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:29150 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695AbXINNoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 09:44:06 -0400
Received: by nz-out-0506.google.com with SMTP id s18so664030nze
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 06:44:05 -0700 (PDT)
In-Reply-To: <20070914032055.8f96449b.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ive changed the subject to match content..

On Fri, 2007-14-09 at 03:20 -0400, Bill Fink wrote:
> On Mon, 27 Aug 2007, jamal wrote:
> 
> > Bill:
> > who suggested (as per your email) the 75usec value and what was it based
> > on measurement-wise? 
> 
> Belatedly getting back to this thread.  There was a recent myri10ge
> patch that changed the default value for tx/rx interrupt coalescing
> to 75 usec claiming it was an optimum value for maximum throughput
> (and is also mentioned in their external README documentation).

I would think such a value would be very specific to the ring size and
maybe even the machine in use. 

> I also did some empirical testing to determine the effect of different
> values of TX/RX interrupt coalescing on 10-GigE network performance,
> both with TSO enabled and with TSO disabled.  The actual test runs
> are attached at the end of this message, but the results are summarized
> in the following table (network performance in Mbps).
> 
> 		        TX/RX interrupt coalescing in usec (both sides)
> 		   0	  15	  30	  45	  60	  75	  90	 105
> 
> TSO enabled	8909	9682	9716	9725	9739	9745	9688	9648
> TSO disabled	9113	9910	9910	9910	9910	9910	9910	9910
>
> TSO disabled performance is always better than equivalent TSO enabled
> performance.  With TSO enabled, the optimum performance is indeed at
> a TX/RX interrupt coalescing value of 75 usec.  With TSO disabled,
> performance is the full 10-GigE line rate of 9910 Mbps for any value
> of TX/RX interrupt coalescing from 15 usec to 105 usec.

Interesting results. I think J Heffner made a very compelling
description the other day based on your netstat results at the receiver
as to what is going on (refer to the comments on stretch ACKs). If the
receiver is fixed, then youd see better numbers from TSO. 

The 75 microsecs is very benchmarky in my opinion. If i was to pick a
different app or different NIC or run on many cpus with many apps doing
TSO, i highly doubt that will be the right number.


> Here's a retest (5 tests each):
> 
> TSO enabled:
> 
> TCP Cubic (initial_ssthresh set to 0):
[..]

> TCP Bic (initial_ssthresh set to 0):
[..]
> 
> TCP Reno:
> 
[..]
> TSO disabled:
> 
> TCP Cubic (initial_ssthresh set to 0):
> 
[..]
> TCP Bic (initial_ssthresh set to 0):
> 
[..]
> TCP Reno:
> 
[..]
> Not too much variation here, and not quite as high results
> as previously.  

BIC seems to be on average better followed by CUBIC followed by Reno.
The difference this time maybe because you set the ssthresh to 0
(hopefully every run) and so Reno is definetely going to perform less
better since it is a lot less agressive in comparison to other two.

> Some further testing reveals that while this
> time I mainly get results like (here for TCP Bic with TSO
> disabled):
> 
> [root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
>  4958.0625 MB /  10.02 sec = 4148.9361 Mbps 100 %TX 99 %RX
> 
> I also sometimes get results like:
> 
> [root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
>  5882.1875 MB /  10.00 sec = 4932.5549 Mbps 100 %TX 90 %RX
> 

not good.

> The higher performing results seem to correspond to when there's a
> somewhat lower receiver CPU utilization.  I'm not sure but there
> could also have been an effect from running the "-M1460" test after
> the 9000 byte jumbo frame test (no jumbo tests were done at all prior
> to running the above sets of 5 tests, although I did always discard
> an initial "warmup" test, and now that I think about it some of
> those initial discarded "warmup" tests did have somewhat anomalously
> high results).

If you didnt reset the ssthresh on every run, could it have been cached
and used on subsequent runs?

> > A side note: Although the experimentation reduces the variables (eg
> > tying all to CPU0), it would be more exciting to see multi-cpu and
> > multi-flow sender effect (which IMO is more real world). 
> 
> These systems are intended as test systems for 10-GigE networks,
> and as such it's important to get as consistently close to full
> 10-GigE line rate as possible, and that's why the interrupts and
> nuttcp application are tied to CPU0, with almost all other system
> applications tied to CPU1.

Sure, good benchmark. You get to know how well you can do.

> Now on another system that's intended as a 10-GigE firewall system,
> it has 2 Myricom 10-GigE NICs with the interrupts for eth2 tied to
> CPU0 and the interrupts for CPU1 tied to CPU1.  In IP forwarding
> tests of this system, I have basically achieved full bidirectional
> 10-GigE line rate IP forwarding with 9000 byte jumbo frames.

In forwarding a more meaningful metric would be pps. The cost per packet
tends to dominate the results over the cost/byte.
9K jumbo frames at 10G is less than 500Kpps - so i dont see that machine
you are using sweating at all. To give you a comparison on a lower end
opteron a single CPU i can generate with batching pktgen 1Mpps; Robert
says he can do that even without batching on an opteron closer to what
you are using. So if you want to run that test, youd need to use
incrementally smaller packets.

> If there's some other specific test you'd like to see, and it's not
> too difficult to set up and I have some spare time, I'll see what I
> can do.

Well, the more interesting tests would be to go full throttle on all
CPUs you have and target one (or more) receivers. i.e you simulate a
real server. Can the utility you have be bound to a cpu? If yes, you
should be able to achieve this without much effort.

Thanks a lot Bill for the effort.

cheers,
jamal

