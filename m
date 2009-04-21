From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Tue, 21 Apr 2009 08:46:36 -0700
Message-ID: <20090421084636.198b181e@nehalam>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	<87eivnpqde.fsf@basil.nowhere.org>
	<65634d660904202026r7d73f810s700bacb8756e0967@mail.gmail.com>
	<49ED967B.4070105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55574 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416AbZDUPqn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 11:46:43 -0400
In-Reply-To: <49ED967B.4070105@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Apr 2009 11:48:43 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Tom Herbert a =C3=A9crit :
> > On Mon, Apr 20, 2009 at 3:32 AM, Andi Kleen <andi@firstfloor.org> w=
rote:
> >> Tom Herbert <therbert@google.com> writes:
> >>
> >>> +static int netif_cpu_for_rps(struct net_device *dev, struct sk_b=
uff *skb)
> >>> +{
> >>> +     cpumask_t mask;
> >>> +     unsigned int hash;
> >>> +     int cpu, count =3D 0;
> >>> +
> >>> +     cpus_and(mask, dev->soft_rps_cpus, cpu_online_map);
> >>> +     if (cpus_empty(mask))
> >>> +             return smp_processor_id();
> >> There's a race here with CPU hotunplug I think. When a CPU is hotu=
nplugged
> >> in parallel you can still push packets to it even though they are =
not
> >> drained. You probably need some kind of drain callback in a CPU ho=
tunplug
> >> notifier that eats all packets left over.
> >>
> > We will look at that, the hotplug support may very well be lacking =
in the patch.
> >=20
> >>> +got_hash:
> >>> +     hash %=3D cpus_weight_nr(mask);
> >> That looks rather heavyweight even on modern CPUs. I bet it's 40-5=
0+ cycles
> >> alone forth the hweight and the division. Surely that can be done =
better?
> >>
> > Agreed, I will try to pull in the RX hash from Dave Miller's remote
> > softirq patch.
> >=20
> >> Also I suspect some kind of runtime switch for this would be usefu=
l.
> >>
> >> Also the manual set up of the receive mask seems really clumpsy. C=
ouldn't
> >> you set that up dynamically based on where processes executing rec=
vmsg()
> >> are running?
> >>
> > We have done exactly that.  It works very well in many cases
> > (application + platform combinations), but I haven't found it to be
> > better than doing the hash in all cases.  I could provide the patch=
,
> > but it might be more of a follow patch to this base one.
>=20
> Hello Tom
>=20
> I was thinking about your patch (and David's one), and thought it cou=
ld be
> possible to spread packets to other cpus only if current one is under=
 stress.
>=20
> A posssible metric would be to test if softirq is handled by ksoftirq=
d
> (stress situation) or not.
>=20
> Under moderate load, we could have one active cpu (and fewer cache li=
ne
> transferts), keeping good latencies.
>=20
> I tried alternative approach to solve the Multicast problem raised so=
me time ago,
> but still have one cpu handling one device. Only wakeups were defered=
 to a
> workqueue (and possibly another cpu) if running from ksoftirq only.
> Patch not yet ready for review, but based on a previous patch that wa=
s more
> intrusive (touching kernel/softirq.c)
>=20
> Under stress, your idea permits to use more cpus for a fast NIC and g=
et better
> throughput. Its more generic.

I would like to see some way to have multiple CPU's pulling packets and=
 adapting
the number of CPU's being used based on load. Basically, turn all devic=
e is into
receive multiqueue. The mapping could be adjusted by user level (see ir=
qbalancer).
