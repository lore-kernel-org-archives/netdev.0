From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Sun, 22 Jul 2007 11:57:54 +0530
Message-ID: <OF0F9581FE.472D94A6-ON65257320.001FC787-65257320.00238386@in.ibm.com>
References: <1185023921.5192.45.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, kaber@trash.net, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, davem@davemloft.net, herbert@gondor.apana.org.au
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1185023921.5192.45.camel@localhost>
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

Hi Jamal,

J Hadi Salim <j.hadi123@gmail.com> wrote on 07/21/2007 06:48:41 PM:

> >    - Use a single qdisc interface to avoid code duplication and reduce
> >      maintainability (sch_generic.c size reduces by ~9%).
> >    - Has per device configurable parameter to turn on/off batching.
> >    - qdisc_restart gets slightly modified while looking simple without
> >      any checks for batching vs regular code (infact only two lines
have
> >      changed - 1. instead of dev_dequeue_skb, a new batch-aware
function
> >      is called; and 2. an extra call to hard_start_xmit_batch.
>
> >    - No change in__qdisc_run other than a new argument (from DM's
idea).
> >    - Applies to latest net-2.6.23 compared to 2.6.22-rc4 code.
>
> All the above are cosmetic differences. To me is the highest priority
> is making sure that batching is useful and what the limitations are.
> At some point, when all looks good - i dont mind adding an ethtool
> interface to turn off/on batching, merge with the new qdisc restart path
> instead of having a parallel path, solicit feedback on naming, where to
> allocate structs etc etc. All that is low prio if batching across a
> variety of hardware and applications doesnt prove useful. At the moment,
> i am unsure theres consistency to justify push batching in.

Batching need not be useful for every hardware. If there is hardware that
is useful to exploit batching (like clearly IPoIB is a good candidate as
both the TX and the TX completion path can handle multiple skb processing,
and I haven't looked at other drivers to see if any of them can do
something
similar), then IMHO it makes sense to enable batching for that hardware. It
is upto the other drivers to determine whether converting to the batching
API makes sense or not. And as indicated, the total size increase for
adding
the kernel support is also insignificant - 0.03%, or 1164 Bytes (using the
'size' command).

> Having said that below are the main architectural differences we have
> which is what we really need to discuss and see what proves useful:
>
> >         - Batching algo/processing is different (eg. if
> >           qdisc_restart() finds
> >      one skb in the batch list, it will try to batch more (upto a
limit)
> >      instead of sending that out and batching the rest in the next
call.
>
> This sounds a little more aggressive but maybe useful.
> I have experimented with setting upper bound limits (current patches
> have a pktgen interface to set the max to send) and have concluded that
> it is unneeded. Probing by letting the driver tell you what space is
> available has proven to be the best approach. I have been meaning to
> remove the code in pktgen which allows these limits.

I don't quite agree with that approach, eg, if the blist is empty and the
driver tells there is space for one packet, you will add one packet and
the driver sends it out and the device is stopped (with potentially lot of
skbs on dev->q). Then no packets are added till the queue is enabled, at
which time a flood of skbs will be processed increasing latency and holding
lock for a single longer duration. My approach will mitigate holding lock
for longer times and instead send skbs to the device as long as we are
within
the limits.

Infact in my rev2 patch (being today or tomorrow after handling Patrick's
and
Stephen's comments), I am even removing the driver specific xmit_slots as I
find it is adding bloat and requires more cycles than calculating the value
each time xmit is done (ofcourse in your approach it is required since the
stack uses it).

> >    - Jamal's code has a separate hw prep handler called from the stack,
> >      and results are accessed in driver during xmit later.
>
> I have explained the reasoning to this a few times. A recent response to
> Michael Chan is here:
> http://marc.info/?l=linux-netdev&m=118346921316657&w=2

Since E1000 doesn't seem to use the TX lock on RX (atleast I couldn't find
it),
I feel having prep will not help as no other cpu can execute the queue/xmit
code anyway (E1000 is also a LLTX driver). Other driver that hold tx lock
could
get improvement however.

> And heres a response to you that i havent heard back on:
> http://marc.info/?l=linux-netdev&m=118355539503924&w=2

That is because it answered my query :) It is what I was expecting, but
thanks
for the explanation.

> My tests so far indicate this interface is useful. It doesnt apply well

I wonder if you tried enabling/disabling 'prep' on E1000 to see how the
performance is affected. If it helps, I guess you could send me a patch to
add that and I can also test it to see what the effect is. I didn't add it
since IPoIB wouldn't be able to exploit it (unless someone is kind enough
to show me how to).

> So if i was to sum up this, (it would be useful discussion to have on
> these) the real difference is:
>
> a) you have an extra check on refilling the skb list when you find that
> it has a single skb. I tagged this as being potentially useful.

It is very useful since extra processing is not required for one skb case -
you remove it from list and unnecessarily add it to a different list and
then
delete it immediately in the driver when all that was required is to pass
the
skb directly to the driver using it's original API (ofcourse the caveat is
that
I also have a check to add that *single* skb to the blist in case there are
already earlier skbs on the blist, this helps in batching and more
importantly -
to send skbs in order).

> b) You have a check for some upper bound on the number of skbs to send
> to the driver. I tagged this as unnecessary - the interface is still on
> in my current code, so it shouldnt be hard to show one way or other.

Explained earlier wrt latency.

> c) You dont have prep_xmit()
>
> Add to that list any other architectural differences i may have missed
> and lets discuss and hopefully make some good progress.

I think the code I have is ready and stable, and the issues pointed out so
far is also incorporated and to be sent out today. Please let me know if
you want to add something to it.

Thanks for your review/comments,

- KK
