From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Tue, 14 Aug 2007 14:32:31 +0530
Message-ID: <OF40D779D8.313D6ADF-ON65257337.002E936E-65257337.0031AB8C@in.ibm.com>
References: <20070808.034900.85820906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808.034900.85820906.davem@davemloft.net>
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
