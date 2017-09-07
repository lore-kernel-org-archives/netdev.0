From: Henrik Austad <henrik@austad.us>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 7 Sep 2017 07:34:11 +0200
Message-ID: <20170907053411.GA6580@sisyphus.home.austad.us>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33048 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbdIGFeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 01:34:37 -0400
Received: by mail-lf0-f43.google.com with SMTP id s11so22053402lfe.0
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 22:34:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
> Hi,
>=20
> This patchset is an RFC on a proposal of how the Traffic Control subsyste=
m can
> be used to offload the configuration of traffic shapers into network devi=
ces
> that provide support for them in HW. Our goal here is to start upstreaming
> support for features related to the Time-Sensitive Networking (TSN) set of
> standards into the kernel.

Nice to see that others are working on this as well! :)

A short disclaimer; I'm pretty much anchored in the view "linux is the=20
end-station in a TSN domain", is this your approach as well, or are you=20
looking at this driver to be used in bridges as well? (because that will=20
affect the comments on time-aware shaper and frame preemption)

Yet another disclaimer; I am not a linux networking subsystem expert. Not=
=20
by a long shot! There are black magic happening in the internals of the=20
networking subsystem that I am not even aware of. So if something I say or=
=20
ask does not make sense _at_all_, that's probably why..

I do know a tiny bit about TSN though, and I have been messing around=20
with it for a little while, hence my comments below

> As part of this work, we've assessed previous public discussions related =
to TSN
> enabling: patches from Henrik Austad (Cisco), the presentation from Eric =
Mann
> at Linux Plumbers 2012, patches from Gangfeng Huang (National Instruments=
) and
> the current state of the OpenAVNU project (https://github.com/AVnu/OpenAv=
nu/).

/me eyes Cc ;p

> Overview
> =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Time-sensitive Networking (TSN) is a set of standards that aim to address
> resources availability for providing bandwidth reservation and bounded la=
tency
> on Ethernet based LANs. The proposal described here aims to cover mainly =
what is
> needed to enable the following standards: 802.1Qat, 802.1Qav, 802.1Qbv and
> 802.1Qbu.
>=20
> The initial target of this work is the Intel i210 NIC, but other controll=
ers'
> datasheet were also taken into account, like the Renesas RZ/A1H RZ/A1M gr=
oup and
> the Synopsis DesignWare Ethernet QoS controller.

NXP has a TSN aware chip on the i.MX7 sabre board as well </fyi>

> Proposal
> =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Feature-wise, what is covered here are configuration interfaces for HW
> implementations of the Credit-Based shaper (CBS, 802.1Qav), Time-Aware sh=
aper
> (802.1Qbv) and Frame Preemption (802.1Qbu). CBS is a per-queue shaper, wh=
ile
> Qbv and Qbu must be configured per port, with the configuration covering =
all
> queues. Given that these features are related to traffic shaping, and tha=
t the
> traffic control subsystem already provides a queueing discipline that off=
loads
> config into the device driver (i.e. mqprio), designing new qdiscs for the
> specific purpose of offloading the config for each shaper seemed like a g=
ood
> fit.

just to be clear, you register sch_cbs as a subclass to mqprio, not as a=20
root class?

> For steering traffic into the correct queues, we use the socket option
> SO_PRIORITY and then a mechanism to map priority to traffic classes / Tx =
queues.
> The qdisc mqprio is currently used in our tests.

Right, fair enough, I'd prefer the TSN qdisc to be the root-device and=20
rather have mqprio for high priority traffic and another for 'everything=20
else'', but this would work too. This is not that relevant at this stage I=
=20
guess :)

> As for the shapers config interface:
>=20
>  * CBS (802.1Qav)
>=20
>    This patchset is proposing a new qdisc called 'cbs'. Its 'tc' cmd line=
 is:
>    $ tc qdisc add dev IFACE parent ID cbs locredit N hicredit M sendslope=
 S \
>      idleslope I

So this confuses me a bit, why specify sendSlope?

    sendSlope =3D portTransmitRate - idleSlope

and portTransmitRate is the speed of the MAC (which you get from the=20
driver). Adding sendSlope here is just redundant I think.

Also, does this mean that when you create the qdisc, you have locked the=20
bandwidth for the scheduler? Meaning, if I later want to add another=20
stream that requires more bandwidth, I have to close all active streams,=20
reconfigure the qdisc and then restart?

>    Note that the parameters for this qdisc are the ones defined by the
>    802.1Q-2014 spec, so no hardware specific functionality is exposed her=
e.

You do need to know if the link is brought up as 100 or 1000 though - which=
=20
the driver already knows.

>  * Time-aware shaper (802.1Qbv):
>=20
>    The idea we are currently exploring is to add a "time-aware", priority=
 based
>    qdisc, that also exposes the Tx queues available and provides a mechan=
ism for
>    mapping priority <-> traffic class <-> Tx queues in a similar fashion =
as
>    mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line woul=
d be:

As far as I know, this is not supported by i210, and if time-aware shaping=
=20
is enabled in the network - you'll be queued on a bridge until the window=
=20
opens as time-aware shaping is enforced on the tx-port and not on rx. Is=20
this required in this driver?

>    $ $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4    \
>      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                         \
> 	   queues 0 1 2 3                                              \
>      	   sched-file gates.sched [base-time <interval>]               \
>            [cycle-time <interval>] [extension-time <interval>]

That was a lot of priorities! 802.1Q lists 8 priorities, where does these=
=20
16 come from?

You map pri 0,1 to queue 2, pri 2 to queue 1 (Class B), pri 3 to queue 0=20
(class A) and everythign else to queue 3. This is what I would expect,=20
except for the additional 8 priorities.

>    <file> is multi-line, with each line being of the following format:
>    <cmd> <gate mask> <interval in nanoseconds>
>=20
>    Qbv only defines one <cmd>: "S" for 'SetGates'
>=20
>    For example:
>=20
>    S 0x01 300
>    S 0x03 500
>=20
>    This means that there are two intervals, the first will have the gate
>    for traffic class 0 open for 300 nanoseconds, the second will have
>    both traffic classes open for 500 nanoseconds.

Are you aware of any hw except dedicated switching stuff that supports=20
this? (meant as "I'm curious and would like to know")

>    Additionally, an option to set just one entry of the gate control list=
 will
>    also be provided by 'taprio':
>=20
>    $ tc qdisc (...) \
>         sched-row <row number> <cmd> <gate mask> <interval>  \
>         [base-time <interval>] [cycle-time <interval>] \
>         [extension-time <interval>]
>=20
>=20
>  * Frame Preemption (802.1Qbu):

So Frame preemption is nice, but my understanding of Qbu is that the real=
=20
benefit is at the bridges and not in the endpoints. As jumbo-frames is=20
explicitly disallowed in Qav, the maximum latency incurred by a frame in=20
flight is 12us on a 1Gbps link. I am not sure if these 12us is what will be=
=20
the main delay in your application.

Or have I missed some crucial point here?

>    To control even further the latency, it may prove useful to signal whi=
ch
>    traffic classes are marked as preemptable. For that, 'taprio' provides=
 the
>    preemption command so you set each traffic class as preemptable or not:
>=20
>    $ tc qdisc (...) \
>         preemption 0 1 1 1
>=20
>  * Time-aware shaper + Preemption:
>=20
>    As an example of how Qbv and Qbu can be used together, we may specify
>    both the schedule and the preempt-mask, and this way we may also
>    specify the Set-Gates-and-Hold and Set-Gates-and-Release commands as
>    specified in the Qbu spec:
>=20
>    $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4 \
>      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                    \
> 	   queues 0 1 2 3                                         \
>      	   preemption 0 1 1 1                                     \
> 	   sched-file preempt_gates.sched
>=20
>     <file> is multi-line, with each line being of the following format:
>     <cmd> <gate mask> <interval in nanoseconds>
>=20
>     For this case, two new commands are introduced:
>=20
>     "H" for 'set gates and hold'
>     "R" for 'set gates and release'
>=20
>     H 0x01 300
>     R 0x03 500

So my understanding of all of this is that you configure the *total*=20
bandwith for each class when you load the qdisc and then let userspace=20
handle the rest. Is this correct?

In my view, it would be nice if the qdisc had some notion about streams so=
=20
that you could create a stream, feed frames to it and let the driver pace=
=20
them out. (The fewer you queue, the shorter the delay). This will also=20
allow you to enforce per-stream bandwidth restrictions. I don't see how you=
=20
can do this here unless you want to do this in userspace.

Do you have any plans for adding support for multiplexing streams? If you=
=20
have multiple streams, how do you enforce that one stream does not eat into=
=20
the bandwidth of another stream? AFAIK, this is something the network must=
=20
enforce, but I see no option of doing som here.

> Testing this RFC
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> For testing the patches of this RFC only, you can refer to the samples and
> helper script being added to samples/tsn/ and the use the 'mqprio' qdisc =
to
> setup the priorities to Tx queues mapping, together with the 'cbs' qdisc =
to
> configure the HW shaper of the i210 controller:

I will test it, feedback will be provided soon! :)

Thanks!
-Henrik

> 1) Setup priorities to traffic classes to hardware queues mapping
> $ tc qdisc replace dev enp3s0 parent root mqprio num_tc 3 \
>      map 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 queues 1@0 1@1 2@2 hw 0
>=20
> 2) Check scheme. You want to get the inner qdiscs ID from the bottom up
> $ tc -g  class show dev enp3s0
>=20
> Ex.:
> +---(802a:3) mqprio
> |    +---(802a:6) mqprio
> |    +---(802a:7) mqprio
> |
> +---(802a:2) mqprio
> |    +---(802a:5) mqprio
> |
> +---(802a:1) mqprio
>      +---(802a:4) mqprio
>=20
>  * Here '802a:4' is Tx Queue #0 and '802a:5' is Tx Queue #1.
>=20
> 3) Calculate CBS parameters for classes A and B. i.e. BW for A is 20Mbps =
and
>    for B is 10Mbps:
> $ ./samples/tsn/calculate_cbs_params.py -A 20000 -a 1500 -B 10000 -b 1500
>=20
> 4) Configure CBS for traffic class A (priority 3) as provided by the scri=
pt:
> $ tc qdisc replace dev enp3s0 parent 802a:4 cbs locredit -1470 \
>      hicredit 30 sendslope -980000 idleslope 20000
>=20
> 5) Configure CBS for traffic class B (priority 2):
> $ tc qdisc replace dev enp3s0 parent 802a:5 cbs \
>      locredit -1485 hicredit 31 sendslope -990000 idleslope 10000
>=20
> 6) Run Listener, compiled from samples/tsn/listener.c
> $ ./listener -i enp3s0
>=20
> 7) Run Talker for class A (prio 3 here), compiled from samples/tsn/talker=
=2Ec
> $ ./talker -i enp3s0 -p 3
>=20
>  * The bandwidth displayed on the listener output at this stage should be=
 very
>    close to the one configured for class A.
>=20
> 8) You can also run a Talker for class B (prio 2 here)
> $ ./talker -i enp3s0 -p 2
>=20
>  * The bandwidth displayed on the listener output now should increase to =
very
>    close to the one configured for class A + class B.

Because you grab both class A *and* B, or because B will eat what A does=20
not use?

-H

> Authors
> =3D=3D=3D=3D=3D=3D=3D
>  - Andre Guedes <andre.guedes@intel.com>
>  - Ivan Briano <ivan.briano@intel.com>
>  - Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>  - Vinicius Gomes <vinicius.gomes@intel.com>
>=20
>=20
> Andre Guedes (2):
>   igb: Add support for CBS offload
>   samples/tsn: Add script for calculating CBS config
>=20
> Jesus Sanchez-Palencia (1):
>   sample: Add TSN Talker and Listener examples
>=20
> Vinicius Costa Gomes (2):
>   net/sched: Introduce the user API for the CBS shaper
>   net/sched: Introduce Credit Based Shaper (CBS) qdisc
>=20
>  drivers/net/ethernet/intel/igb/e1000_defines.h |  23 ++
>  drivers/net/ethernet/intel/igb/e1000_regs.h    |   8 +
>  drivers/net/ethernet/intel/igb/igb.h           |   6 +
>  drivers/net/ethernet/intel/igb/igb_main.c      | 349 +++++++++++++++++++=
++++++
>  include/linux/netdevice.h                      |   1 +
>  include/uapi/linux/pkt_sched.h                 |  29 ++
>  net/sched/Kconfig                              |  11 +
>  net/sched/Makefile                             |   1 +
>  net/sched/sch_cbs.c                            | 286 ++++++++++++++++++++
>  samples/tsn/calculate_cbs_params.py            | 112 ++++++++
>  samples/tsn/listener.c                         | 254 ++++++++++++++++++
>  samples/tsn/talker.c                           | 136 ++++++++++
>  12 files changed, 1216 insertions(+)
>  create mode 100644 net/sched/sch_cbs.c
>  create mode 100755 samples/tsn/calculate_cbs_params.py
>  create mode 100644 samples/tsn/listener.c
>  create mode 100644 samples/tsn/talker.c
>=20
> --
> 2.14.1

--=20
Henrik Austad

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmw2lMACgkQ6k5VT6v45lltRwCg+rd/w2gqa5OPA4/hBgPAFRRP
h+MAoMaDCUVDbO7nLuVEZJfdFOGFEzp6
=QTPb
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--
