From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Sat, 23 Aug 2014 15:51:26 +0100
Message-ID: <20140823145126.GB24116@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <20140823092458.GC1854@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33804 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbaHWOvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 10:51:32 -0400
Content-Disposition: inline
In-Reply-To: <20140823092458.GC1854@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/14 at 11:24am, Jiri Pirko wrote:
> Sat, Aug 23, 2014 at 12:53:34AM CEST, sfeldma@cumulusnetworks.com wro=
te:
> >
> >On Aug 22, 2014, at 12:39 PM, John Fastabend <john.fastabend@gmail.c=
om> wrote:
> >> - this requires OVS to be loaded to work. If all I want is
> >>   direct access to the hardware flow tables requiring openvswitch.=
ko
> >>   shouldn't be needed IMO. For example I may want to use the
> >>   hardware flow tables with something not openvswitch and we
> >>   shouldn't preclude that.
> >>=20
> >
> >The intent is to use openvswitch.ko=E2=80=99s struct sw_flow to prog=
ram hardware via the ndo_swdev_flow_* ops, but otherwise be independent=
 of OVS.  So the upper layer of the driver is struct sw_flow and any mo=
dule above the driver can construct a struct sw_flow and push it down v=
ia ndo_swdev_flow_*.  So your non-OVS use-case should be handled.  OVS =
is another use-case.  struct sw_flow should not be OVS-aware, but rathe=
r a generic flow match/action sufficient to offload the data plane to H=
W.
>=20
> Yes. I was thinking about simple Netlink API that would expose direct
> sw_flow manipulation (ndo_swdev_flow_* wrapper) to userspace. I will
> think abou that more and perhaps add it to my next patchset version.

I agree that this might help to give a better API consumption example
for everyone not familiar with OVS.

> >> - Also there is no programmatic way to learn which flows are
> >>   in hardware and which in software. There is a pr_warn but
> >>   that doesn't help when interacting with the hardware remotely.
> >>   I need some mechanism to dump the set of hardware tables and
> >>   the set of software tables.
> >
> >Agreed, we need a way to annotate which flows are installed hardware=
=2E
>=20
> Yes, we discussed that already. We need to make OVS daemon hw-offload
> aware indicating which flow it want/prefers to be offloaded. This is =
I
> believe easily extentable feature and can be added whenever the right
> time is.

I think the swdev flow API is good as-is. The bitmask specyfing the
offload preference with all the granularity (offload-or-fail,
try-to-offload, never-offload) needed can be added later, either in
OVS only or in swdev itself.

What is unclear in this patch is how OVS user space can know which
flows are offloaded and which aren't. A status field would help here
which indicates either: flow inserted and offloaded, flow inserted but
not offloaded. Given that, the API consumer can easily keep track of
which flows are currently offloaded.

Also, I'm not sure whether flow expiration is something the API must
take care of. The current proposal assumes that HW flows are only
ever removed by the API itself. Could the switch CPU run code which
removes flows as well? That would call for Netlink notifications.
Not that it's needed at this stage of the code but maybe worth
considerating for the API design.

> >> - Simply duplicating the software flow/action into
> >>   hardware may not optimally use the hardware tables. If I have
> >>   a TCAM in hardware for instance. (This is how I read the patch
> >>   let me know if I missed something)
> >
> >The hardware-specific driver is the right place to handle optimizing=
 the flow/action in hardware since only the driver can know the size/sh=
ape of the device.  struct sw_flow is a generic flow description; how (=
or if) a flow gets programmed into hardware must be handled in the swde=
v driver.  If the device driver can=E2=80=99t make the sw_flow fit into=
 HW because of resource limitations or the flow simply can=E2=80=99t be=
 represented in HW, then the flow is SW only. =20
> >
> >In the rocker driver posted in this patch set, the steps are to pars=
e the struct sw_flow to figure out what type of flow match/action we=E2=
=80=99re dealing with (L2 or L3 or L4, ucast or mcast, ipv4 or ipv6, et=
c) and then install the correct entries into the corresponding device t=
ables within the constraints of the device=E2=80=99s pipeline.  Any opt=
imizations, like coalescing HW entries, is something only the driver ca=
n do.

The later examples definitely make sense and I'm not argueing against
that. There is also a non hardware capabilities perspective that I
would like to present:

1) TCAM capacity is limtied, we offload based on some priority assigned
to flows.  Some are critical and need to be in HW, others are best effo=
rt,
others never go into hardware. An API user will likely want to offload
best-effort flows until some watermark is reached and then switch to
critical flows only. The driver is not the right place for high level
optimization like this. The kernel API might but doesn't really have to
either because it would mean we need APIs to transfer all of the
needed context for the decision in the kernel. It might be easier to
expose the hardware context to user space instead and handle these
kind of optimizations in something like Quagga.

2) There is definitely a desire to allow adapting the software flow tab=
le
based on the hardware capabilities. Example, given a route like this:

   20.1.0.0/16, mark=3D50, tos=3D0x12, actions: output:eth1

The hardware can satisfy everything except the mark=3D50 match. Given a
a blind 1:1 copy between hardware and software we cannot offload
because a mach would be illegal. With the full context as available
north of the API, this could be translated into something like this:

  HW: 20.1.0.0/16, tos=3D0x12, actions: meta=3D1, output:cpu
  SW: meta=3D1, mark=3D50, output:eth1

This will allow for partial offloads to bypass expensive masked flow
table lookups by converting them into efficient flat exact match
tables, offload TC classifiers, nftables or even the existing L2 and
L3 forwarding path.

In summary, I think the swdev API as proposed is a good start as the
in-kernel flow abstraction is sufficient for many API users but we
should consider enabling the model described above as well once we
have the basic model put in place. I will be very interested in helping
out on this for both existing classifiers and OVS flow tables.


> >> - I need a way to specify put this flow/action in hardware,
> >>   put this flow/action in software, or put this in both software
> >>   and hardware.
> >>=20
> >
> >This seems above the swdev layer.  In other words, don=E2=80=99t cal=
l ndo_swdev_flow_* if you don=E2=80=99t want flow match/action install =
in HW.

It can certainly be done northbound but this seems like a basic
requirement and we might end up avoiding the code duplication and
extending the API instead.
