From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 00/10] Implement batching skb API
Date: Fri, 20 Jul 2007 12:01:49 +0530
Message-ID: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, jagana@us.ibm.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, sri@us.ibm.com,
	hadi@cyberus.ca, netdev@vger.kernel.org
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
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

Hi Dave, Roland, everyone,

In May, I had proposed creating an API for sending 'n' skbs to a driver to
reduce lock overhead, DMA operations, and specific to drivers that have
completion notification like IPoIB - reduce completion handling ("[RFC] New
driver API to speed up small packets xmits" @
http://marc.info/?l=linux-netdev&m=117880900818960&w=2). I had also sent
initial test results for E1000 which showed minor improvements (but also
got degradations) @http://marc.info/?l=linux-netdev&m=117887698405795&w=2.

After fine-tuning qdisc and other changes, I modified IPoIB to use this API,
and now get good gains. Summary for TCP & No Delay: 1 process improves for
all cases from 1.4% to 49.5%; 4 process has almost identical improvements
from -1.7% to 59.1%; 16 process case also improves in the range of -1.2% to
33.4%; while 64 process doesn't have much improvement (-3.3% to 12.4%). UDP
was tested with 1 process netperf with small increase in BW but big
improvement in Service Demand. Netperf latency tests show small drop in
transaction rate (results in separate attachment).

To verify that performance does not degrade with batching turned off (as is
the case for all existing drivers), I ran tests with tx_batch_skbs=0 vs the
original code, without getting real degradation. Also enabled all kernel
debugs to catch panics, warnings, memory free use bugs, etc, and simulated
driver errors to get coverage on core & IPoIB error paths. Testing was on
2-CPU X-series systems and 8-CPU PPC64 Power5 systems using IPoIB over mthca,
and E1000 (used driver that Jamal had converted but didn't get improvement).
On i386, the size of the kernel (drivers are modules) increased by:
	text: 0.007% data: 0.007% bss: 0% total: 0.03%.

There is a parallel WIP by Jamal but the two implementations are completely
different since the code bases from the start were separate. Key changes:
	- Use a single qdisc interface to avoid code duplication and reduce
	  maintainability (sch_generic.c size reduces by ~9%).
	- Has per device configurable parameter to turn on/off batching.
	- qdisc_restart gets slightly modified while looking simple without
	  any checks for batching vs regular code (infact only two lines have
	  changed - 1. instead of dev_dequeue_skb, a new batch-aware function
	  is called; and 2. an extra call to hard_start_xmit_batch.
	- Batching algo/processing is different (eg. if qdisc_restart() finds
	  one skb in the batch list, it will try to batch more (upto a limit)
	  instead of sending that out and batching the rest in the next call.
	- No change in__qdisc_run other than a new argument (from DM's idea).
	- Applies to latest net-2.6.23 compared to 2.6.22-rc4 code.
	- Jamal's code has a separate hw prep handler called from the stack,
	  and results are accessed in driver during xmit later.
	- Jamal's code has dev->xmit_win which is cached by the driver. Mine
	  has dev->xmit_slots but this is used only by the driver while the
	  core has a different mechanism to find how many skbs to batch.
	- Completely different structure/design & coding styles.
(This patch will work with drivers updated by Jamal, Matt & Michael Chan with
minor modifications - rename xmit_win to xmit_slots & rename batch handler)

Patches are described as:
	Mail 0/10  : This mail.
	Mail 1/10  : HOWTO documentation.
	Mail 2/10  : Networking include file changes.
	Mail 3/10  : dev.c changes.
	Mail 4/10  : net-sysfs.c changes.
	Mail 5/10  : sch_generic.c changes.
	Mail 6/10  : IPoIB include file changes.
	Mail 7/10  : IPoIB verbs changes
	Mail 8/10  : IPoIB multicast, CM changes
	Mail 9/10  : IPoIB xmit API addition
	Mail 10/10 : IPoIB xmit internals changes (ipoib_ib.c)

I am also sending separately an attachment with results (across 10 run
cycle), test scripts and a script to analyze results.

Thanks to Sridhar & Shirley Ma for code reviews; Evgeniy, Jamal & Sridhar for
suggesting to put driver skb list on netdev instead of on skb to avoid
requeue; and David Miller for explanation on using batching only when the
queue is woken up.

Please review and provide feedback/ideas; and consider for inclusion.

Thanks,

- KK
