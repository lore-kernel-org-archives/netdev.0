From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Tue, 14 Aug 2007 15:09:24 +0530
Message-ID: <OF93F27F60.0D1A3D8F-ON65257337.0034CF00-65257337.00350BD7@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:41114 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173AbXHNJrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 05:47:06 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7E9fQU94538394
	for <netdev@vger.kernel.org>; Tue, 14 Aug 2007 19:41:28 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7E9gOwB098470
	for <netdev@vger.kernel.org>; Tue, 14 Aug 2007 19:42:25 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7E9cmEQ001139
	for <netdev@vger.kernel.org>; Tue, 14 Aug 2007 19:38:50 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Forgot to mention one thing:

> This fix reduced
> retransmissions from 180,000 to 55,000 or so. When I changed IPoIB
> driver to use iterative sends of each skb instead of creating multiple
> Work Request's, that number went down to 15].

This also reduced TCP No Delay performance from huge percentages like
200-400% and now is almost the same as original code. So fixing this
problem in IPoIB (driver?) will enable to use the multiple Work Request
& Work Completion, rather than limiting batching to single WR/WC.

thanks,

- KK


__________________

Hi Dave,

David Miller <davem@davemloft.net> wrote on 08/08/2007 04:19:00 PM:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> Date: Wed, 08 Aug 2007 15:01:14 +0530
>
> > RESULTS: The performance improvement for TCP No Delay is in the range
of -8%
> >    to 320% (with -8% being the sole negative), with many individual
tests
> >    giving 50% or more improvement (I think it is to do with the hw
slots
> >    getting full quicker resulting in more batching when the queue gets
> >    woken). The results for TCP is in the range of -11% to 93%, with
most
> >    of the tests (8/12) giving improvements.
>
> Not because I think it obviates your work, but rather because I'm
> curious, could you test a TSO-in-hardware driver converted to
> batching and see how TSO alone compares to batching for a pure
> TCP workload?
>
> I personally don't think it will help for that case at all as
> TSO likely does better job of coalescing the work _and_ reducing
> bus traffic as well as work in the TCP stack.

I used E1000 (guess the choice is OK as e1000_tso returns TRUE. My
hw is 82547GI).

You are right, it doesn't help TSO case at all (infact degrades). Two
things to note though:
      - E1000 may not be suitable for adding batching (which is no
        longer a new API, as I have changed it already).
      - Small skbs where TSO doesn't come into picture still seems to
        improve. A couple of cases for large skbs did result in some
        improved (like 4K, TCP No Delay, 32 procs).

[Total segments retransmission for original code test run: 2220 & for
new code test run: 1620. So the retransmission problem that I was
getting seems to be an IPoIB bug, though I did have to fix one bug
in my networking component where I was calling qdisc_run(NULL) for
regular xmit path and change to always use batching. The problem is
that skb1 - skb10 may be present in the queue after each of them
failed to be sent out, then net_tx_action fires which batches all of
these into the blist and tries to send them out again, which also
fails (eg tx lock fail or queue full), then the next single skb xmit
will send the latest skb ignoring the 10 skbs that are already waiting
in the batching list. These 10 skbs are sent out only the next time
net_tx_action is called, so out of order skbs result. This fix reduced
retransmissions from 180,000 to 55,000 or so. When I changed IPoIB
driver to use iterative sends of each skb instead of creating multiple
Work Request's, that number went down to 15].

I ran 3 iterations of 45 sec tests (total 1 hour 16 min, but I will
run a longer one tonight). The results are (results in KB/s, and %):

Test Case                      Org BW       New BW      % Change

                              TCP
                            --------
Size:32 Procs:1                 1848        3918        112.01
Size:32 Procs:8                 21888       21555       -1.52
Size:32 Procs:32                19317       22433       16.13

Size:256 Procs:1                15584       25991       66.78
Size:256 Procs:8                110937      74565       -32.78
Size:256 Procs:32               105767      98967       -6.42

Size:4096 Procs:1               81910       96073       17.29
Size:4096 Procs:8               113302      94040       -17.00
Size:4096 Procs:32              109664      105522      -3.77

                            TCP No Delay:
                            --------------
Size:32 Procs:1                 2688        3177        18.19
Size:32 Procs:8                 6568        10588       61.20
Size:32 Procs:32                6573        7838        19.24

Size:256 Procs:1                7869        12724       61.69
Size:256 Procs:8                65652       45652       -30.46
Size:256 Procs:32               95114       112279      18.04

Size:4096 Procs:1               95302       84664       -11.16
Size:4096 Procs:8               111119      89111       -19.80
Size:4096 Procs:32              109249      113919      4.27

I will submit Rev4 with suggested changes (including single merged
API) on Thursday after some more testing.

Thanks,

- KK

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

