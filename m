From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Sat, 21 Jul 2007 09:18:41 -0400
Message-ID: <1185023921.5192.45.camel@localhost>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	sri@us.ibm.com, jagana@us.ibm.com, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
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


I am (have been) under extreme travel mode - so i will have high latency
in follow ups.

On Fri, 2007-20-07 at 12:01 +0530, Krishna Kumar wrote:
> Hi Dave, Roland, everyone,
> 
> In May, I had proposed creating an API for sending 'n' skbs to a driver to
> reduce lock overhead, DMA operations, and specific to drivers that have
> completion notification like IPoIB - reduce completion handling ("[RFC] New
> driver API to speed up small packets xmits" @
> http://marc.info/?l=linux-netdev&m=117880900818960&w=2). I had also sent
> initial test results for E1000 which showed minor improvements (but also
> got degradations) @http://marc.info/?l=linux-netdev&m=117887698405795&w=2.
> 

Add to that context: that i have been putting out patches on this over
the last 3+ years as well as several public presentations = last one
being: http://vger.kernel.org/jamal_netconf2006.sxi

My main problem (and obstacles to submitting the patches) has been a
result of not doing the approriate testing - i had been testing
forwarding path (in all my results post the latest patches) when i
should really have been testing the improvement of the tx path. 

> There is a parallel WIP by Jamal but the two implementations are completely
> different since the code bases from the start were separate. Key changes:
> 	- Use a single qdisc interface to avoid code duplication and reduce
> 	  maintainability (sch_generic.c size reduces by ~9%).
> 	- Has per device configurable parameter to turn on/off batching.
> 	- qdisc_restart gets slightly modified while looking simple without
> 	  any checks for batching vs regular code (infact only two lines have
> 	  changed - 1. instead of dev_dequeue_skb, a new batch-aware function
> 	  is called; and 2. an extra call to hard_start_xmit_batch.

> 	- No change in__qdisc_run other than a new argument (from DM's idea).
> 	- Applies to latest net-2.6.23 compared to 2.6.22-rc4 code.

All the above are cosmetic differences. To me is the highest priority
is making sure that batching is useful and what the limitations are.
At some point, when all looks good - i dont mind adding an ethtool
interface to turn off/on batching, merge with the new qdisc restart path
instead of having a parallel path, solicit feedback on naming, where to
allocate structs etc etc. All that is low prio if batching across a
variety of hardware and applications doesnt prove useful. At the moment,
i am unsure theres consistency to justify push batching in.

Having said that below are the main architectural differences we have
which is what we really need to discuss and see what proves useful:

>         - Batching algo/processing is different (eg. if
>           qdisc_restart() finds
> 	  one skb in the batch list, it will try to batch more (upto a limit)
> 	  instead of sending that out and batching the rest in the next call.

This sounds a little more aggressive but maybe useful.
I have experimented with setting upper bound limits (current patches
have a pktgen interface to set the max to send) and have concluded that
it is unneeded. Probing by letting the driver tell you what space is
available has proven to be the best approach. I have been meaning to
remove the code in pktgen which allows these limits.
 
> 	- Jamal's code has a separate hw prep handler called from the stack,
> 	  and results are accessed in driver during xmit later.

I have explained the reasoning to this a few times. A recent response to
Michael Chan is here:
http://marc.info/?l=linux-netdev&m=118346921316657&w=2
And heres a response to you that i havent heard back on:
http://marc.info/?l=linux-netdev&m=118355539503924&w=2

My tests so far indicate this interface is useful. It doesnt apply well
to some drivers (for example i dont use it in tun) - which makes it
optional but useful nevertheless. I will be more than happy to kill this
if i can find cases where it proves to be a bad idea.

> 	- Jamal's code has dev->xmit_win which is cached by the driver. Mine
> 	  has dev->xmit_slots but this is used only by the driver while the
> 	  core has a different mechanism to find how many skbs to batch.

This is related to the first item.

> 	- Completely different structure/design & coding styles.
> (This patch will work with drivers updated by Jamal, Matt & Michael Chan with
> minor modifications - rename xmit_win to xmit_slots & rename batch handler)

Again, cosmetics (and indication you are morphing towards me).

So if i was to sum up this, (it would be useful discussion to have on
these) the real difference is:

a) you have an extra check on refilling the skb list when you find that
it has a single skb. I tagged this as being potentially useful.
b) You have a check for some upper bound on the number of skbs to send
to the driver. I tagged this as unnecessary - the interface is still on
in my current code, so it shouldnt be hard to show one way or other.
c) You dont have prep_xmit()

Add to that list any other architectural differences i may have missed
and lets discuss and hopefully make some good progress.

cheers,
jaaml
