From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 01/17] shm-signal: shared-memory signals
Date: Wed, 01 Apr 2009 09:57:33 -0400
Message-ID: <49D372CD.5000601@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184252.28333.70623.stgit@dev.haskins.net> <49D280C0.8010802@redhat.com> <49D283F7.7030508@novell.com> <49D285AE.7030604@redhat.com> <49D35A2B.10907@novell.com> <49D35D12.6080209@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig47790774A0D63CC8E8B97E5F"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D35D12.6080209@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig47790774A0D63CC8E8B97E5F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> Note that this is exactly what I do (though it is device specific).
>> venet-tap has a ioq_notifier registered on its "rx" ring (which is the=

>> tx-ring for the guest) that simply calls ioq_notify_disable() (which
>> calls shm_signal_disable() under the covers) and it wakes its
>> rx-thread.  This all happens in the context of the hypercall, which th=
en
>> returns and allows the vcpu to re-enter guest mode immediately.
>>  =20
> I think this is suboptimal.

Heh, yes I know this is your (well documented) position, but I
respectfully disagree. :)

CPUs are not getting much faster, but they are rapidly getting more
cores.  If we want to continue to make software run increasingly faster,
we need to actually use those cores IMO.  Generally this means split
workloads up into as many threads as possible as long as you can keep
pipelines filed.

>   The ring is likely to be cache hot on the current cpu, waking a
> thread will introduce scheduling latency + IPI
This part is a valid criticism, though note that Linux is very adept at
scheduling so we are talking mere ns/us range here, which is dwarfed by
the latency of something like your typical IO device (e.g. 36us for a
rtt packet on 10GE baremetal, etc).  The benefit, of course, is the
potential for increased parallelism which I have plenty of data to show
we are very much taking advantage of here (I can saturate two cores
almost completely according to LTT traces, one doing vcpu work, and the
other running my "rx" thread which schedules the packet on the hardware)

> +cache-to-cache transfers.
This one I take exception to.  While it is perfectly true that splitting
the work between two cores has a greater cache impact than staying on
one, you cannot look at this one metric alone and say "this is bad".=20
Its also a function of how efficiently the second (or more) cores are
utilized.  There will be a point in the curve where the cost of cache
coherence will become marginalized by the efficiency added by the extra
compute power.  Some workloads will invariably be on the bad end of that
curve, and therefore doing the work on one core is better.  However, we
cant ignore that there will others that are on the good end of this
spectrum either.  Otherwise, we risk performance stagnation on our
effectively uniprocessor box ;).  In addition, the task-scheduler will
attempt to co-locate tasks that are sharing data according to a best-fit
within the cache hierarchy.  Therefore, we will still be sharing as much
as possible (perhaps only L2, L3, or a local NUMA domain, but this is
still better than nothing)

The way I have been thinking about these issues is something I have been
calling "soft-asics".  In the early days, we had things like a simple
uniprocessor box with a simple dumb ethernet.  People figured out that
if you put more processing power into the NIC, you could offload that
work from the cpu and do more in parallel.   So things like checksum
computation and segmentation duties were a good fit.  More recently, we
see even more advanced hardware where you can do L2 or even L4 packet
classification right in the hardware, etc.  All of these things are
effectively parallel computation, and it occurs in a completely foreign
cache domain!

So a lot of my research has been around the notion of trying to use some
of our cpu cores to do work like some of the advanced asic based offload
engines do.  The cores are often under utilized anyway, and this will
bring some of the features of advanced silicon to commodity resources.=20
They also have the added flexibility that its just software, so you can
change or enhance the system at will.

So if you think about it, by using threads like this in venet-tap, I am
effectively using other cores to do csum/segmentation (if the physical
hardware doesn't support it), layer 2 classification (linux bridging),
filtering (iptables in the bridge), queuing, etc as if it was some
"smart" device out on the PCI bus.  The guest just queues up packets
independently in its own memory, while the device just "dma's" the data
on its own (after the initial kick).  The vcpu is keeping the pipeline
filled on its side independently.

>
> On a benchmark setup, host resources are likely to exceed guest
> requirements, so you can throw cpu at the problem and no one notices.
Sure, but with the type of design I have presented this still sorts
itself out naturally even if the host doesn't have the resources.  For
instance, if there is a large number of threads competing for a small
number of cores, we will simply see things like the rx-thread stalling
and going to sleep, or the vcpu thread backpressuring and going idle
(and therefore sleeping).  All of these things are self throttling.  If
you don't have enough resources to run a workload at a desirable
performance level, the system wasn't sized right to begin with. ;)

>   But I think the bits/cycle figure will decrease, even if bits/sec
> increases.
>
Note that this isn't necessarily a bad thing.  I think studies show that
most machines are generally idle a significant percentage of the time,
and this will likely only get worse as we get more and more cores.  So
if I have to consume more cycles to get more bits on the wire, thats
probably ok with most of my customers.   If its not, it would be trivial
to make the venet threading policy a tunable parameter.

-Greg



--------------enig47790774A0D63CC8E8B97E5F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknTcs0ACgkQlOSOBdgZUxn1AACfY7vu8gz8XHr/hNHSctT8JIHb
UPMAn1iBgUKB3JkYYirYAtI7DtLxLyYf
=8NtR
-----END PGP SIGNATURE-----

--------------enig47790774A0D63CC8E8B97E5F--
