From: "Matthew Faulkner" <matthew.faulkner@gmail.com>
Subject: Re: Throughput Bug?
Date: Fri, 19 Oct 2007 16:41:42 +0100
Message-ID: <c565abbb0710190841g6ea4b424vbd5acf8e2fbc4d1c@mail.gmail.com>
References: <c565abbb0710180854j6f2f756sdd390161bafd1c4a@mail.gmail.com>
	 <20071019014419.6ac8a6a0.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netperf-feedback@netperf.org,
	netperf-talk@netperf.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:28248 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbXJSPlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 11:41:45 -0400
Received: by rv-out-0910.google.com with SMTP id k20so493160rvb
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 08:41:45 -0700 (PDT)
In-Reply-To: <20071019014419.6ac8a6a0.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I removed the socket sizes in an attempt to reproduce your results
Rick and i managed to do so, but only when i launch netperf by typing
in the follow cmd in to the bash shell.

/home/cheka/netperf-2.4.4/src/netperf -T 0,0 -l 10 -t TCP_STREAM -c
100 -C 100 -f M -P 0 -- -m 523

As soon as i try to launch netperf (with the same line as i do manual)
from within a script of any form (be it php or bash) the difference
between 523 and 524 appears again.

The php script i'm using is pasted below (it's the same as the bash
script that comes with netperf to provide the tcp_stream)

<?php
        $START=522;
        $END=524;
        $MULT=1;
        $ADD=1;
        $MAXPROC=1; // This is the maximum number of CPU's you have so
we can assign the client to different CPUs to show the same problem
between 523 and 524 does not occur unless it's on CPU 0 and CPU 0

        $DURATION = 10; // Length of test
        $LOC_CPU = "-c 100"; // Report the local CPU info
        $REM_CPU = "-C 100"; // Report the remove CPU info

       $NETSERVER = "netserver"; //path to netserver
       $NETPERF = "netperf"; // path to netperf

        for($i=0; $i<=$MAXPROC; $i++) {
                echo "0,$i\n";
                $MESSAGE = $START;

                while($MESSAGE <= $END) {
                        passthru('killall netserver > /dev/null'); //
tried it with and without the following restarts of netserver
                        passthru('sleep 5');
                        passthru("$NETSERVER");
                        passthru('sleep 5');
                        echo "$NETPERF -T 0,$i -l $DURATION -t
TCP_STREAM $LOC_CPU $REM_CPU -f M -P 0 -- -m $MESSAGE\n"; // let's see
what we try to exec
                        passthru("$NETPERF -T 0,$i -l $DURATION -t
TCP_STREAM $LOC_CPU $REM_CPU -f M -P 0 -- -m $MESSAGE"); // exec it -
this will also print to screen
                        passthru('sleep 5'); // sleep
                        $MESSAGE += $ADD;
                        $MESSAGE *= $MULT;
                }
        }
?>


On 19/10/2007, Bill Fink <billfink@mindspring.com> wrote:
> On Thu, 18 Oct 2007, Matthew Faulkner wrote:
>
> > Hey all
> >
> > I'm using netperf to perform TCP throughput tests via the localhost
> > interface. This is being done on a SMP machine. I'm forcing the
> > netperf server and client to run on the same core. However, for any
> > packet sizes below 523 the throughput is much lower compared to the
> > throughput when the packet sizes are greater than 524.
> >
> > Recv   Send    Send                          Utilization       Service Demand
> > Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> > Size   Size    Size     Time     Throughput  local    remote   local   remote
> > bytes  bytes   bytes    secs.    MBytes  /s  % S      % S      us/KB   us/KB
> >  65536  65536    523    30.01        81.49   50.00    50.00    11.984  11.984
> >  65536  65536    524    30.01       460.61   49.99    49.99    2.120   2.120
> >
> > The chances are i'm being stupid and there is an obvious reason for
> > this, but when i put  the server and client on different cores i don't
> > see this effect.
> >
> > Any help explaining this will be greatly appreciated.
> >
> > Machine details:
> >
> > Linux 2.6.22-2-amd64 #1 SMP Thu Aug 30 23:43:59 UTC 2007 x86_64 GNU/Linux
> >
> > sched_affinity is used by netperf internally to set the core affinity.
>
> I don't know if it's relevant, but note that 524 bytes + 52 bytes
> of IP(20)/TCP(20)/TimeStamp(12) overhead gives a 576 byte packet,
> which is the specified size that all IP routers must handle (and
> the smallest value possible during PMTU discovery I believe).  A
> message size of 523 bytes would be 1 less than that.  Could this
> possibly have to do with ABC (possibly try disabling it if set)?
>
>                                                 -Bill
>
